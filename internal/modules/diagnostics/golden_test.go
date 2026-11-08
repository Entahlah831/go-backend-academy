package diagnostics_test

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"testing"
	"time"

	"github.com/gobackendacademy/platform/internal/modules/diagnostics"
)

func TestGoldenDiagnostics(t *testing.T) {
	analyzer := diagnostics.NewAnalyzer(false, 3*time.Second, "none", "", "")

	files, err := filepath.Glob(filepath.Join("testdata", "*.go.txt"))
	if err != nil {
		t.Fatalf("glob testdata failed: %v", err)
	}
	if len(files) == 0 {
		t.Fatal("no testdata files found in testdata/*.go.txt")
	}

	for _, file := range files {
		testName := strings.TrimSuffix(filepath.Base(file), ".go.txt")
		t.Run(testName, func(t *testing.T) {
			src, err := os.ReadFile(file)
			if err != nil {
				t.Fatalf("reading %s: %v", file, err)
			}

			expectedFile := strings.TrimSuffix(file, ".go.txt") + ".expected.json"
			expectedBytes, err := os.ReadFile(expectedFile)
			if err != nil {
				t.Fatalf("reading %s: %v", expectedFile, err)
			}

			var expectedRules []string
			if err := json.Unmarshal(expectedBytes, &expectedRules); err != nil {
				t.Fatalf("unmarshaling %s: %v", expectedFile, err)
			}
			sort.Strings(expectedRules)

			report := analyzer.AnalyzeCode(context.Background(), string(src))

			var actualRules []string
			for _, f := range report.Findings {
				actualRules = append(actualRules, f.RuleID)
			}
			sort.Strings(actualRules)

			if len(expectedRules) != len(actualRules) {
				t.Fatalf("test %s rule count mismatch: got %v, want %v", testName, actualRules, expectedRules)
			}
			for i := range expectedRules {
				if expectedRules[i] != actualRules[i] {
					t.Errorf("test %s mismatch at index %d: got %s, want %s (all: got %v, want %v)",
						testName, i, actualRules[i], expectedRules[i], actualRules, expectedRules)
				}
			}
		})
	}
}
