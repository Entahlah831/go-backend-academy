package httpplatform

import (
	"net"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestClientIPResolutionWithTrustedProxies(t *testing.T) {
	_, loopbackNet, _ := net.ParseCIDR("127.0.0.1/32")
	_, privateNet, _ := net.ParseCIDR("10.0.0.0/8")
	trusted := []*net.IPNet{loopbackNet, privateNet}

	// 1. Connection from untrusted IP trying to spoof X-Forwarded-For
	reqUntrusted := httptest.NewRequest("GET", "/", nil)
	reqUntrusted.RemoteAddr = "203.0.113.50:1234"
	reqUntrusted.Header.Set("X-Forwarded-For", "198.51.100.99")
	if got := ClientIP(reqUntrusted, trusted); got != "203.0.113.50" {
		t.Errorf("untrusted remote addr must not trust X-Forwarded-For: got %s, want 203.0.113.50", got)
	}

	// 2. Connection from trusted proxy with single client IP
	reqTrusted := httptest.NewRequest("GET", "/", nil)
	reqTrusted.RemoteAddr = "127.0.0.1:8080"
	reqTrusted.Header.Set("X-Forwarded-For", "198.51.100.99")
	if got := ClientIP(reqTrusted, trusted); got != "198.51.100.99" {
		t.Errorf("trusted proxy should resolve client IP: got %s, want 198.51.100.99", got)
	}

	// 3. Connection through multiple proxies: client -> proxy1 (untrusted/external) -> proxy2 (trusted 10.0.0.1) -> server (127.0.0.1)
	reqMulti := httptest.NewRequest("GET", "/", nil)
	reqMulti.RemoteAddr = "127.0.0.1:8080"
	reqMulti.Header.Set("X-Forwarded-For", "198.51.100.99, 10.0.0.1")
	if got := ClientIP(reqMulti, trusted); got != "198.51.100.99" {
		t.Errorf("trusted multi-proxy should skip trusted intermediate IPs from right: got %s, want 198.51.100.99", got)
	}
}

func TestRateLimiterDistinguishesProxiedClients(t *testing.T) {
	_, loopbackNet, _ := net.ParseCIDR("127.0.0.1/32")
	rl := NewRateLimiterWithTrusted(1, 1, []*net.IPNet{loopbackNet})
	defer rl.Stop()

	handler := rl.Middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	// Client A: 198.51.100.1 through 127.0.0.1 proxy
	reqA := httptest.NewRequest("GET", "/api/v1/test", nil)
	reqA.RemoteAddr = "127.0.0.1:40000"
	reqA.Header.Set("X-Forwarded-For", "198.51.100.1")
	recA1 := httptest.NewRecorder()
	handler.ServeHTTP(recA1, reqA)
	if recA1.Code != http.StatusOK {
		t.Fatalf("first request for client A should pass: %d", recA1.Code)
	}

	// Client A second request immediately -> should be rate limited (429)
	recA2 := httptest.NewRecorder()
	handler.ServeHTTP(recA2, reqA)
	if recA2.Code != http.StatusTooManyRequests {
		t.Fatalf("second request for client A should be rate limited: got %d, want 429", recA2.Code)
	}

	// Client B: 198.51.100.2 through same 127.0.0.1 proxy -> should NOT be rate limited!
	reqB := httptest.NewRequest("GET", "/api/v1/test", nil)
	reqB.RemoteAddr = "127.0.0.1:40000"
	reqB.Header.Set("X-Forwarded-For", "198.51.100.2")
	recB1 := httptest.NewRecorder()
	handler.ServeHTTP(recB1, reqB)
	if recB1.Code != http.StatusOK {
		t.Errorf("client B should have independent bucket and pass: got %d, want 200", recB1.Code)
	}
}
