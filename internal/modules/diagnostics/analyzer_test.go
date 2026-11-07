package diagnostics_test

import (
	"context"
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
	"os"
)

func GetUser(ctx context.Context, db *sql.DB, id string) (string, error) {
	var email string
	err := db.QueryRowContext(ctx, "SELECT email FROM users WHERE id = $1", id).Scan(&email)
	if err != nil {
		return "", err
	}
	return email, nil
}
`

	report := analyzer.AnalyzeCode(context.Background(), code)
	if report.SummaryStatus != "no_finding_detected" {
		t.Fatalf("expected no_finding_detected for clean code, got %s", report.SummaryStatus)
	}
	if len(report.Findings) != 1 || report.Findings[0].RuleID != "GO-INFO-000" {
		t.Errorf("expected only GO-INFO-000, got %+v", report.Findings)
	}
}
