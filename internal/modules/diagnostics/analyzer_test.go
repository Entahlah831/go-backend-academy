package diagnostics_test

import (
	"context"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/gobackendacademy/platform/internal/modules/diagnostics"
)

func TestAnalyzerDetectsHardcodedSecretAndPort(t *testing.T) {
	analyzer := diagnostics.NewAnalyzer(false, 3*time.Second, "none", "", "")
	code := `package main

// User sample test case
const ServerPort = "8080"
const DatabasePassword = "prod-secret-password"
`

	report := analyzer.AnalyzeCode(context.Background(), code)
	if report.SummaryStatus != "findings_detected" {
		t.Fatalf("expected findings_detected, got %s", report.SummaryStatus)
	}

	foundSecret := false
	foundPort := false
	for _, f := range report.Findings {
		if f.RuleID == "GO-SEC-007" {
			foundSecret = true
		}
		if f.RuleID == "GO-HTTP-001" {
			foundPort = true
		}
	}

	if !foundSecret {
		t.Errorf("expected GO-SEC-007 to trigger for DatabasePassword")
	}
	if !foundPort {
		t.Errorf("expected GO-HTTP-001 to trigger for ServerPort")
	}
}

func TestAnalyzerCleanCodeNoFindings(t *testing.T) {
	analyzer := diagnostics.NewAnalyzer(false, 3*time.Second, "none", "", "")
	code := `package main

import (
	"context"
	"database/sql"
	"fmt"
)

func GetUserEmail(ctx context.Context, db *sql.DB, userID string) (string, error) {
	var email string
	err := db.QueryRowContext(ctx, "SELECT email FROM users WHERE id = $1", userID).Scan(&email)
	if err != nil {
		return "", fmt.Errorf("querying user %s: %w", userID, err)
	}
	return email, nil
}
`

	report := analyzer.AnalyzeCode(context.Background(), code)
	seriousFindings := 0
	for _, f := range report.Findings {
		if f.Severity != "info" {
			seriousFindings++
		}
	}
	if seriousFindings != 0 {
		t.Errorf("expected 0 serious findings for clean sample, got %d", seriousFindings)
	}
}

func TestIsolatedGoVetClassification(t *testing.T) {
	if _, err := exec.LookPath("go"); err != nil {
		t.Skip("go compiler not available on host, skipping vet test")
	}

	analyzer := diagnostics.NewAnalyzer(true, 3*time.Second, "none", "", "")
	// Snippet without import (incomplete snippet)
	code := `package main
func main() {
	println("hello")
	x := undeclaredVar
	_ = x
}
`
	report := analyzer.AnalyzeCode(context.Background(), code)
	for _, f := range report.Findings {
		if f.RuleID == "GO-VET-001" {
			// If undeclaredVar causes build error, it should be classified as potential_issue (Snippet tidak lengkap),
			// not confirmed_diagnostic!
			if strings.Contains(f.Description, "undeclared") {
				if f.Classification != diagnostics.ClassificationPotentialIssue {
					t.Errorf("expected incomplete snippet to be classified as potential_issue, got %s", f.Classification)
				}
				if !strings.Contains(f.Title, "Snippet Tidak Lengkap") {
					t.Errorf("expected title to indicate Snippet Tidak Lengkap, got %s", f.Title)
				}
			}
		}
	}
}
