package config

import (
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	AppEnv            string
	Host              string
	Port              int
	ReadHeaderTimeout time.Duration
	ReadTimeout       time.Duration
	WriteTimeout      time.Duration
	IdleTimeout       time.Duration
	ShutdownTimeout   time.Duration
	WebStaticDir      string

	// Database selection: "sqlite" (default, persistent file), "postgres", or
	// "memory" (in-process SQLite that is wiped when the process exits).
	DBDriver string

	// SQLite: SQLiteDSN is either taken verbatim from SQLITE_DSN or built from SQLITE_PATH.
	SQLitePath string
	SQLiteDSN  string

	// PostgreSQL: PostgresDSN is either taken verbatim from POSTGRES_DSN or built
	// from POSTGRES_HOST / POSTGRES_PORT / POSTGRES_USER / POSTGRES_PASSWORD /
	// POSTGRES_DB / POSTGRES_SSLMODE, so the port and credentials follow .env.
	PostgresHost     string
	PostgresPort     int
	PostgresUser     string
	PostgresPassword string
	PostgresDB       string
	PostgresSSLMode  string
	PostgresDSN      string

	DBMaxOpenConns    int
	DBMaxIdleConns    int
	DBConnMaxLifetime time.Duration
	DBConnectTimeout  time.Duration
	DBAutoMigrate     bool
	DBAutoSeed        bool

	CORSAllowedOrigins   map[string]bool
	RateLimitRPS         float64
	RateLimitBurst       float64
	TrustedProxyCIDRs    []*net.IPNet
	MaxRequestBodyBytes  int64
	EnableLocalToolchain bool
	SandboxTimeout       time.Duration
	AIProvider           string
	AIBaseURL            string
	AIModel              string
}

var validSSLModes = map[string]bool{
	"disable": true, "allow": true, "prefer": true, "require": true, "verify-ca": true, "verify-full": true,
}

// Load reads configuration from the process environment. Invalid values are
// reported as errors instead of silently falling back to defaults, so a typo
// in .env (for example POSTGRES_PORT=54x2) stops startup with a clear message.
func Load() (*Config, error) {
	p := &envParser{}

	originsRaw := getEnv("CORS_ALLOWED_ORIGINS", "http://localhost:8080,http://127.0.0.1:8080,http://localhost:5173")
	allowedOrigins := make(map[string]bool)
	for _, o := range strings.Split(originsRaw, ",") {
		if trimmed := strings.TrimSpace(o); trimmed != "" {
			allowedOrigins[trimmed] = true
		}
	}

	trustedCIDRSRaw := getEnv("TRUSTED_PROXY_CIDRS", "127.0.0.1/32,::1/128,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16")
	var trustedNets []*net.IPNet
	for _, cidr := range strings.Split(trustedCIDRSRaw, ",") {
		if trimmed := strings.TrimSpace(cidr); trimmed != "" {
			_, ipNet, err := net.ParseCIDR(trimmed)
			if err != nil {
				if ip := net.ParseIP(trimmed); ip != nil {
					mask := 32
					if ip.To4() == nil {
						mask = 128
					}
					ipNet = &net.IPNet{IP: ip, Mask: net.CIDRMask(mask, mask)}
				} else {
					p.errs = append(p.errs, fmt.Errorf("invalid TRUSTED_PROXY_CIDRS entry %q: %w", trimmed, err))
					continue
				}
			}
			trustedNets = append(trustedNets, ipNet)
		}
	}

	cfg := &Config{
		AppEnv:            getEnv("APP_ENV", "development"),
		Host:              strings.TrimSpace(os.Getenv("HOST")),
		Port:              p.int("PORT", 8080),
		ReadHeaderTimeout: p.seconds("READ_HEADER_TIMEOUT_SEC", 5),
		ReadTimeout:       p.seconds("READ_TIMEOUT_SEC", 10),
		WriteTimeout:      p.seconds("WRITE_TIMEOUT_SEC", 15),
		IdleTimeout:       p.seconds("IDLE_TIMEOUT_SEC", 60),
		ShutdownTimeout:   p.seconds("SHUTDOWN_TIMEOUT_SEC", 10),
		WebStaticDir:      getEnv("WEB_STATIC_DIR", "./web"),

		DBDriver:   strings.ToLower(getEnv("DB_DRIVER", "sqlite")),
		SQLitePath: getEnv("SQLITE_PATH", "./academy.db"),
		SQLiteDSN:  os.Getenv("SQLITE_DSN"),

		PostgresHost:     getEnv("POSTGRES_HOST", "127.0.0.1"),
		PostgresPort:     p.int("POSTGRES_PORT", 5432),
		PostgresUser:     getEnv("POSTGRES_USER", "academy"),
		PostgresPassword: os.Getenv("POSTGRES_PASSWORD"),
		PostgresDB:       getEnv("POSTGRES_DB", "gobackendacademy"),
		PostgresSSLMode:  getEnv("POSTGRES_SSLMODE", "disable"),
		PostgresDSN:      os.Getenv("POSTGRES_DSN"),

		DBMaxOpenConns:    p.int("DB_MAX_OPEN_CONNS", 25),
		DBMaxIdleConns:    p.int("DB_MAX_IDLE_CONNS", 10),
		DBConnMaxLifetime: time.Duration(p.int("DB_CONN_MAX_LIFETIME_MIN", 30)) * time.Minute,
		DBConnectTimeout:  p.seconds("DB_CONNECT_TIMEOUT_SEC", 5),
		DBAutoMigrate:     p.bool("DB_AUTO_MIGRATE", true),
		DBAutoSeed:        p.bool("DB_AUTO_SEED", true),

		CORSAllowedOrigins:   allowedOrigins,
		RateLimitRPS:         float64(p.int("RATE_LIMIT_RPS", 20)),
		RateLimitBurst:       float64(p.int("RATE_LIMIT_BURST", 40)),
		TrustedProxyCIDRs:    trustedNets,
		MaxRequestBodyBytes:  int64(p.int("MAX_REQUEST_BODY_BYTES", 1048576)),
		EnableLocalToolchain: p.bool("ENABLE_LOCAL_GO_TOOLCHAIN", true),
		SandboxTimeout:       time.Duration(p.int("SANDBOX_TIMEOUT_MS", 3000)) * time.Millisecond,
		AIProvider:           getEnv("AI_PROVIDER", "none"),
		AIBaseURL:            getEnv("AI_BASE_URL", "http://127.0.0.1:11434"),
		AIModel:              getEnv("AI_MODEL", ""),
	}

	errs := p.errs
	check := func(cond bool, format string, args ...any) {
		if !cond {
			errs = append(errs, fmt.Errorf(format, args...))
		}
	}

	check(cfg.Port >= 1 && cfg.Port <= 65535, "invalid PORT %d: must be between 1 and 65535", cfg.Port)
	for name, d := range map[string]time.Duration{
		"READ_HEADER_TIMEOUT_SEC": cfg.ReadHeaderTimeout, "READ_TIMEOUT_SEC": cfg.ReadTimeout,
		"WRITE_TIMEOUT_SEC": cfg.WriteTimeout, "IDLE_TIMEOUT_SEC": cfg.IdleTimeout,
		"SHUTDOWN_TIMEOUT_SEC": cfg.ShutdownTimeout, "DB_CONNECT_TIMEOUT_SEC": cfg.DBConnectTimeout,
		"SANDBOX_TIMEOUT_MS": cfg.SandboxTimeout,
	} {
		check(d > 0, "invalid %s: must be greater than zero", name)
	}
	check(cfg.DBMaxOpenConns >= 1, "invalid DB_MAX_OPEN_CONNS %d: must be at least 1", cfg.DBMaxOpenConns)
	check(cfg.DBMaxIdleConns >= 0 && cfg.DBMaxIdleConns <= cfg.DBMaxOpenConns,
		"invalid DB_MAX_IDLE_CONNS %d: must be between 0 and DB_MAX_OPEN_CONNS (%d)", cfg.DBMaxIdleConns, cfg.DBMaxOpenConns)
	check(cfg.DBConnMaxLifetime >= 0, "invalid DB_CONN_MAX_LIFETIME_MIN: must not be negative")
	check(cfg.RateLimitRPS > 0, "invalid RATE_LIMIT_RPS: must be greater than zero")
	check(cfg.RateLimitBurst >= 1, "invalid RATE_LIMIT_BURST: must be at least 1")
	check(cfg.MaxRequestBodyBytes > 0, "invalid MAX_REQUEST_BODY_BYTES: must be greater than zero")
	check(cfg.AIProvider == "none" || cfg.AIProvider == "ollama",
		"unsupported AI_PROVIDER %q: must be 'none' (default offline) or 'ollama'", cfg.AIProvider)

	switch cfg.DBDriver {
	case "sqlite":
		if cfg.SQLiteDSN == "" {
			check(strings.TrimSpace(cfg.SQLitePath) != "", "SQLITE_PATH must not be empty when DB_DRIVER=sqlite")
			cfg.SQLiteDSN = BuildSQLiteDSN(cfg.SQLitePath)
		}
	case "postgres":
		if cfg.AppEnv == "production" {
			check(strings.TrimSpace(cfg.PostgresPassword) != "" && !strings.Contains(strings.ToLower(cfg.PostgresPassword), "change_this"),
				"production error: POSTGRES_PASSWORD must not be empty or contain default placeholder 'change_this'")
			if cfg.PostgresSSLMode == "disable" {
				slog.Default().Warn("production security warning: POSTGRES_SSLMODE is set to 'disable'; transport encryption should be enabled in production")
			}
		}
		if cfg.PostgresDSN == "" {
			check(cfg.PostgresPort >= 1 && cfg.PostgresPort <= 65535, "invalid POSTGRES_PORT %d: must be between 1 and 65535", cfg.PostgresPort)
			check(strings.TrimSpace(cfg.PostgresHost) != "", "POSTGRES_HOST must not be empty when DB_DRIVER=postgres")
			check(strings.TrimSpace(cfg.PostgresUser) != "", "POSTGRES_USER must not be empty when DB_DRIVER=postgres")
			check(strings.TrimSpace(cfg.PostgresDB) != "", "POSTGRES_DB must not be empty when DB_DRIVER=postgres")
			check(validSSLModes[cfg.PostgresSSLMode], "invalid POSTGRES_SSLMODE %q", cfg.PostgresSSLMode)
			cfg.PostgresDSN = BuildPostgresDSN(cfg.PostgresHost, cfg.PostgresPort, cfg.PostgresUser, cfg.PostgresPassword, cfg.PostgresDB, cfg.PostgresSSLMode)
		}
	case "memory":
		// In-process SQLite; nothing to validate.
	default:
		errs = append(errs, fmt.Errorf("unsupported DB_DRIVER %q: must be 'sqlite', 'postgres', or 'memory'", cfg.DBDriver))
	}

	if len(errs) > 0 {
		return nil, errors.Join(errs...)
	}
	return cfg, nil
}

// ListenAddr returns the TCP address for http.Server (HOST may be empty to listen on all interfaces).
func (c *Config) ListenAddr() string {
	return net.JoinHostPort(c.Host, strconv.Itoa(c.Port))
}

// BuildSQLiteDSN produces a modernc.org/sqlite DSN with WAL journaling, a busy
// timeout, and foreign key enforcement enabled for every pooled connection.
func BuildSQLiteDSN(path string) string {
	return "file:" + path + "?_pragma=journal_mode(WAL)&_pragma=busy_timeout(5000)&_pragma=foreign_keys(ON)"
}

// BuildPostgresDSN produces a URL-form DSN. Credentials are escaped, so
// passwords containing characters such as '@', ':' or '/' are safe.
func BuildPostgresDSN(host string, port int, user, password, dbName, sslMode string) string {
	u := &url.URL{
		Scheme:   "postgres",
		Host:     net.JoinHostPort(host, strconv.Itoa(port)),
		Path:     "/" + dbName,
		RawQuery: url.Values{"sslmode": []string{sslMode}}.Encode(),
	}
	if password != "" {
		u.User = url.UserPassword(user, password)
	} else {
		u.User = url.User(user)
	}
	return u.String()
}

// DBTarget describes the active database without exposing secrets; safe for logs and /readyz.
func (c *Config) DBTarget() string {
	switch c.DBDriver {
	case "sqlite":
		dsn := c.SQLiteDSN
		if i := strings.Index(dsn, "?"); i >= 0 {
			dsn = dsn[:i]
		}
		return strings.TrimPrefix(dsn, "file:")
	case "postgres":
		u, err := url.Parse(c.PostgresDSN)
		if err != nil || u.Host == "" {
			return "postgres (unparseable DSN)"
		}
		user := ""
		if u.User != nil {
			user = u.User.Username() + "@"
		}
		return "postgres://" + user + u.Host + u.Path
	default:
		return "in-memory (non-persistent)"
	}
}

func getEnv(key, fallback string) string {
	if v := strings.TrimSpace(os.Getenv(key)); v != "" {
		return v
	}
	return fallback
}

// envParser accumulates parse errors so every invalid variable is reported at once.
type envParser struct {
	errs []error
}

func (p *envParser) int(key string, fallback int) int {
	v := strings.TrimSpace(os.Getenv(key))
	if v == "" {
		return fallback
	}
	parsed, err := strconv.Atoi(v)
	if err != nil {
		p.errs = append(p.errs, fmt.Errorf("invalid %s=%q: must be an integer", key, v))
		return fallback
	}
	return parsed
}

func (p *envParser) seconds(key string, fallback int) time.Duration {
	return time.Duration(p.int(key, fallback)) * time.Second
}

func (p *envParser) bool(key string, fallback bool) bool {
	v := strings.TrimSpace(os.Getenv(key))
	if v == "" {
		return fallback
	}
	parsed, err := strconv.ParseBool(v)
	if err != nil {
		p.errs = append(p.errs, fmt.Errorf("invalid %s=%q: must be true or false", key, v))
		return fallback
	}
	return parsed
}
