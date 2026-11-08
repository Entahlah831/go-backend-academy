package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
)

func TestRunFetch_Success(t *testing.T) {
	mockPackage := ExercisePackage{
		ExerciseID:  "ex-l0-stage-a-what-is-backend",
		Title:       "Konfigurasi Alamat Listen Port Default",
		Description: "Implementasikan DefaultPort()",
		Files: map[string]string{
			"main.go":      "package main\n\nfunc DefaultPort() string { return \":8080\" }\n",
			"main_test.go": "package main\n\nimport \"testing\"\n\nfunc TestDefaultPort(t *testing.T) {\n\tif got := DefaultPort(); got != \":8080\" { t.Fatal(got) }\n}\n",
			"go.mod":       "module main\n\ngo 1.23\n",
			"README.md":    "# Test README",
		},
	}

	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/api/v1/exercises/ex-l0-stage-a-what-is-backend/package" {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(mockPackage)
	}))
	defer ts.Close()

	tempDir := t.TempDir()
	outDir := filepath.Join(tempDir, "ex-out")

	err := runFetch([]string{"--server", ts.URL, "--dir", outDir, "ex-l0-stage-a-what-is-backend"})
	if err != nil {
		t.Fatalf("runFetch failed: %v", err)
	}

	for filename, expectedContent := range mockPackage.Files {
		p := filepath.Join(outDir, filename)
		data, err := os.ReadFile(p)
		if err != nil {
			t.Fatalf("file %s not created: %v", filename, err)
		}
		if string(data) != expectedContent {
			t.Fatalf("file %s content mismatch: got %q, want %q", filename, string(data), expectedContent)
		}
	}
}

func TestRunFetch_NotFound(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.NotFound(w, r)
	}))
	defer ts.Close()

	tempDir := t.TempDir()
	err := runFetch([]string{"--server", ts.URL, "--dir", tempDir, "non-existent-ex"})
	if err == nil {
		t.Fatal("expected error on 404, got nil")
	}
}
