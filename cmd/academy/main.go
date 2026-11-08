package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
)

type ExercisePackage struct {
	ExerciseID  string            `json:"exercise_id"`
	Title       string            `json:"title"`
	Description string            `json:"description"`
	Files       map[string]string `json:"files"`
}

func defaultServerURL() string {
	if u := os.Getenv("GBA_SERVER_URL"); u != "" {
		return strings.TrimRight(u, "/")
	}
	return "http://localhost:8080"
}

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	command := os.Args[1]
	switch command {
	case "fetch":
		if err := runFetch(os.Args[2:]); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	case "help", "-h", "--help":
		printUsage()
	default:
		fmt.Fprintf(os.Stderr, "Perintah tidak dikenal: %q\n\n", command)
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println(`Go Backend Academy CLI (v2.6) - Alat Latihan & Verifikasi Lokal Offline

Penggunaan:
  academy fetch <exercise_id> [flags]   Unduh starter code, unit test, dan go.mod untuk latihan lokal
  academy help                          Tampilkan bantuan ini

Flags untuk 'fetch':
  --dir string       Folder tujuan penyimpanan (default: ./exercises/<exercise_id>)
  --server string    URL backend Go Academy (default: http://localhost:8080 atau $GBA_SERVER_URL)

Contoh:
  academy fetch ex-l0-stage-a-what-is-backend
  cd exercises/ex-l0-stage-a-what-is-backend
  go test -v ./...`)
}

func runFetch(args []string) error {
	fs := flag.NewFlagSet("fetch", flag.ContinueOnError)
	var dirFlag string
	var serverFlag string

	fs.StringVar(&dirFlag, "dir", "", "Folder tujuan penyimpanan")
	fs.StringVar(&serverFlag, "server", defaultServerURL(), "URL backend Go Academy")

	if err := fs.Parse(args); err != nil {
		return err
	}

	positional := fs.Args()
	if len(positional) < 1 {
		return fmt.Errorf("argumen <exercise_id> diperlukan.\nContoh: academy fetch ex-l0-stage-a-what-is-backend")
	}

	exerciseID := positional[0]
	serverURL := strings.TrimRight(serverFlag, "/")

	outDir := dirFlag
	if outDir == "" {
		outDir = filepath.Join("exercises", exerciseID)
	}

	client := &http.Client{
		Timeout: 15 * time.Second,
	}

	endpoint := fmt.Sprintf("%s/api/v1/exercises/%s/package", serverURL, exerciseID)
	req, err := http.NewRequest(http.MethodGet, endpoint, nil)
	if err != nil {
		return fmt.Errorf("membuat request: %w", err)
	}
	req.Header.Set("User-Agent", "GoBackendAcademy-CLI/2.6")

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("gagal menghubungi server di %s (%w).\nPastikan server aktif ('make run') atau gunakan flag --server <URL>", serverURL, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusNotFound {
		return fmt.Errorf("latihan %q tidak ditemukan di server (%s)", exerciseID, endpoint)
	}
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("server merespons kode status %d: %s", resp.StatusCode, string(body))
	}

	var pkg ExercisePackage
	if err := json.NewDecoder(resp.Body).Decode(&pkg); err != nil {
		return fmt.Errorf("membaca respons paket: %w", err)
	}

	if err := os.MkdirAll(outDir, 0755); err != nil {
		return fmt.Errorf("membuat direktori %q: %w", outDir, err)
	}

	fmt.Printf("[OK] Mengunduh paket latihan: %s\n", pkg.Title)
	fmt.Printf("ID Latihan: %s\n", pkg.ExerciseID)
	fmt.Printf("Direktori : %s\n\n", outDir)

	for filename, content := range pkg.Files {
		filePath := filepath.Join(outDir, filename)
		if err := os.WriteFile(filePath, []byte(content), 0644); err != nil {
			return fmt.Errorf("menulis file %s: %w", filePath, err)
		}
		fmt.Printf("  + Menulis %s (%d bytes)\n", filename, len(content))
	}

	fmt.Println("\nLangkah selanjutnya untuk menguji secara offline di laptop Anda:")
	fmt.Printf("  cd %s\n", outDir)
	fmt.Println("  go test -v ./...")
	return nil
}
