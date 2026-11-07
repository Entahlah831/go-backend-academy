package config

import (
	"strings"
	"testing"
)

func TestProductionPostgresPasswordGuard(t *testing.T) {
	t.Setenv("APP_ENV", "production")
	t.Setenv("DB_DRIVER", "postgres")
	t.Setenv("POSTGRES_HOST", "127.0.0.1")
	t.Setenv("POSTGRES_PORT", "5432")
	t.Setenv("POSTGRES_USER", "academy")
	t.Setenv("POSTGRES_DB", "gobackendacademy")
	t.Setenv("POSTGRES_SSLMODE", "disable")

	// Case 1: placeholder password containing "change_this"
	t.Setenv("POSTGRES_PASSWORD", "change_this_strong_password_in_prod")
	_, err := Load()
	if err == nil {
		t.Fatalf("expected config.Load() to reject default placeholder 'change_this' password in production")
	}
	if !strings.Contains(err.Error(), "POSTGRES_PASSWORD") {
		t.Errorf("expected error message to mention POSTGRES_PASSWORD, got: %v", err)
	}

	// Case 2: empty password
	t.Setenv("POSTGRES_PASSWORD", "")
	_, err = Load()
	if err == nil {
		t.Fatalf("expected config.Load() to reject empty POSTGRES_PASSWORD in production")
	}

	// Case 3: valid strong password
	t.Setenv("POSTGRES_PASSWORD", "a_truly_random_and_secure_password_9921")
	cfg, err := Load()
	if err != nil {
		t.Fatalf("unexpected error with valid production password: %v", err)
	}
	if cfg.PostgresPassword != "a_truly_random_and_secure_password_9921" {
		t.Errorf("expected password to match, got %s", cfg.PostgresPassword)
	}
}

func TestDefaultEnableLocalToolchainIsFalse(t *testing.T) {
	t.Setenv("APP_ENV", "development")
	t.Setenv("ENABLE_LOCAL_GO_TOOLCHAIN", "")
	cfg, err := Load()
	if err != nil {
		t.Fatalf("unexpected error loading default config: %v", err)
	}
	if cfg.EnableLocalToolchain != false {
		t.Errorf("expected EnableLocalToolchain to default to false, got %v", cfg.EnableLocalToolchain)
	}
}
