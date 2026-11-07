package httpplatform

import (
	"crypto/rand"
	"encoding/hex"
	"log/slog"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"
)

func RequestIDMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		reqID := r.Header.Get("X-Request-ID")
		if reqID == "" {
			var b [8]byte
			_, _ = rand.Read(b[:])
			reqID = "req_" + hex.EncodeToString(b[:])
		}
		w.Header().Set("X-Request-ID", reqID)
		next.ServeHTTP(w, r)
	})
}

func SecurityHeadersMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("X-Frame-Options", "DENY")
		w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
		next.ServeHTTP(w, r)
	})
}

func RecoveryMiddleware(logger *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if rec := recover(); rec != nil {
					logger.Error("recovered from HTTP handler panic",
						slog.Any("panic", rec),
						slog.String("path", r.URL.Path),
					)
					WriteProblem(w, r, http.StatusInternalServerError, "INTERNAL_ERROR", "Internal Server Error", "An unexpected panic was recovered safely.")
				}
			}()
			next.ServeHTTP(w, r)
		})
	}
}

func LoggingMiddleware(logger *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			next.ServeHTTP(w, r)
			logger.Info("http_request",
				slog.String("method", r.Method),
				slog.String("path", r.URL.Path),
				slog.String("request_id", w.Header().Get("X-Request-ID")),
				slog.Duration("duration", time.Since(start)),
			)
		})
	}
}

func CORSMiddleware(allowedOrigins map[string]bool) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Add("Vary", "Origin")
			origin := r.Header.Get("Origin")
			if origin != "" && allowedOrigins[origin] {
				w.Header().Set("Access-Control-Allow-Origin", origin)
				w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
				w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Request-ID, Idempotency-Key")
			}
			if r.Method == http.MethodOptions {
				w.WriteHeader(http.StatusNoContent)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

type tokenBucket struct {
	tokens     float64
	lastRefill time.Time
}

type RateLimiter struct {
	mu             sync.Mutex
	buckets        map[string]*tokenBucket
	rate           float64
	burst          float64
	trustedProxies []*net.IPNet
	stopCh         chan struct{}
}

func inNets(ip net.IP, nets []*net.IPNet) bool {
	for _, n := range nets {
		if n != nil && n.Contains(ip) {
			return true
		}
	}
	return false
}

// ClientIP resolves the actual client IP, respecting X-Forwarded-For ONLY when connecting
// via a configured trusted proxy (scanning from right to left to skip intermediate trusted proxies).
func ClientIP(r *http.Request, trusted []*net.IPNet) string {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		host = r.RemoteAddr
	}
	ip := net.ParseIP(host)
	if ip == nil || !inNets(ip, trusted) {
		return host // direct connection or untrusted proxy: do NOT trust X-Forwarded-For!
	}
	xff := r.Header.Get("X-Forwarded-For")
	if xff == "" {
		return host
	}
	parts := strings.Split(xff, ",")
	for i := len(parts) - 1; i >= 0; i-- {
		candStr := strings.TrimSpace(parts[i])
		candIP := net.ParseIP(candStr)
		if candIP != nil && !inNets(candIP, trusted) {
			return candIP.String()
		}
	}
	return host
}

func NewRateLimiter(rate, burst float64) *RateLimiter {
	return NewRateLimiterWithTrusted(rate, burst, nil)
}

func NewRateLimiterWithTrusted(rate, burst float64, trusted []*net.IPNet) *RateLimiter {
	rl := &RateLimiter{
		buckets:        make(map[string]*tokenBucket),
		rate:           rate,
		burst:          burst,
		trustedProxies: trusted,
		stopCh:         make(chan struct{}),
	}
	go rl.cleanupLoop()
	return rl
}

func (rl *RateLimiter) Stop() {
	select {
	case <-rl.stopCh:
	default:
		close(rl.stopCh)
	}
}

func (rl *RateLimiter) cleanupLoop() {
	ticker := time.NewTicker(2 * time.Minute)
	defer ticker.Stop()
	for {
		select {
		case <-rl.stopCh:
			return
		case now := <-ticker.C:
			rl.mu.Lock()
			for k, v := range rl.buckets {
				if now.Sub(v.lastRefill) > 5*time.Minute {
					delete(rl.buckets, k)
				}
			}
			rl.mu.Unlock()
		}
	}
}

func (rl *RateLimiter) Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		host := ClientIP(r, rl.trustedProxies)

		rl.mu.Lock()
		now := time.Now()
		// Bound rate-limiter map to prevent memory exhaustion under spoofed IP floods
		if len(rl.buckets) > 10000 {
			for k, v := range rl.buckets {
				if now.Sub(v.lastRefill) > 5*time.Minute {
					delete(rl.buckets, k)
				}
			}
		}
		b, exists := rl.buckets[host]
		if !exists {
			b = &tokenBucket{tokens: rl.burst, lastRefill: now}
			rl.buckets[host] = b
		} else {
			elapsed := now.Sub(b.lastRefill).Seconds()
			if elapsed > 0 {
				b.tokens += elapsed * rl.rate
				if b.tokens > rl.burst {
					b.tokens = rl.burst
				}
				b.lastRefill = now
			}
		}

		if b.tokens < 1.0 {
			rl.mu.Unlock()
			w.Header().Set("Retry-After", "1")
			WriteProblem(w, r, http.StatusTooManyRequests, "RATE_LIMITED", "Too Many Requests", "Token bucket rate limit exceeded; retry after 1 second.")
			return
		}
		b.tokens -= 1.0
		rl.mu.Unlock()

		next.ServeHTTP(w, r)
	})
}
