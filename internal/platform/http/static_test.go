package httpplatform

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"github.com/gobackendacademy/platform/internal/config"
	"github.com/gobackendacademy/platform/internal/platform/database"
	"github.com/gobackendacademy/platform/internal/platform/logger"
)

func TestStaticFrontendBlocksDotfiles(t *testing.T) {
	tmpDir := t.TempDir()

	// Create normal static file
	if err := os.WriteFile(filepath.Join(tmpDir, "style.css"), []byte("body { color: red; }"), 0o600); err != nil {
		t.Fatalf("failed to write style.css: %v", err)
	}

	// Create hidden dotfile inside a dot folder
	dotFolder := filepath.Join(tmpDir, ".hallmark")
	if err := os.MkdirAll(dotFolder, 0o700); err != nil {
		t.Fatalf("failed to mkdir .hallmark: %v", err)
	}
	dotFile := filepath.Join(dotFolder, "secret.html")
	if err := os.WriteFile(dotFile, []byte("<h1>secret</h1>"), 0o600); err != nil {
		t.Fatalf("failed to write secret.html: %v", err)
	}

	t.Setenv("DB_DRIVER", "memory")
	t.Setenv("WEB_STATIC_DIR", tmpDir)

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("config.Load() failed: %v", err)
	}
	cfg.WebStaticDir = tmpDir

	store, err := database.Open(context.Background(), cfg)
	if err != nil {
		t.Fatalf("database.Open() failed: %v", err)
	}
	defer store.Close()

	srv := NewServer(cfg, logger.New(io.Discard, "test"), store)
	ts := httptest.NewServer(srv.Handler())
	defer ts.Close()

	// 1. Normal file should be served with 200 OK
	resNormal, err := http.Get(ts.URL + "/style.css")
	if err != nil {
		t.Fatalf("GET /style.css failed: %v", err)
	}
	if resNormal.StatusCode != http.StatusOK {
		t.Errorf("expected 200 OK for /style.css, got %d", resNormal.StatusCode)
	}

	// 2. Dotfile / hidden folder should be BLOCKED with 404 Not Found
	resDot, err := http.Get(ts.URL + "/.hallmark/secret.html")
	if err != nil {
		t.Fatalf("GET /.hallmark/secret.html failed: %v", err)
	}
	if resDot.StatusCode != http.StatusNotFound {
		t.Errorf("expected 404 Not Found for dotfile, got %d", resDot.StatusCode)
	}
}
