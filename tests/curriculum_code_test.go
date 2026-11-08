package tests

import (
	"context"
	"go/parser"
	"go/token"
	"regexp"
	"strings"
	"testing"

	"github.com/gobackendacademy/platform/internal/config"
	"github.com/gobackendacademy/platform/internal/platform/database"
)

var goCodeBlockRegex = regexp.MustCompile("(?s)```go\\s+(.+?)```")

func parseGoSnippet(src string) error {
	trimmed := strings.TrimSpace(src)
	if trimmed == "" {
		return nil
	}

	// If snippet contains Dockerfile or Protobuf preamble, extract the Go code section
	if strings.Contains(trimmed, "FROM ") || strings.HasPrefix(trimmed, "#") {
		if idx := strings.Index(trimmed, "func "); idx != -1 {
			trimmed = trimmed[idx:]
		} else if idx := strings.Index(trimmed, "package "); idx != -1 {
			trimmed = trimmed[idx:]
		} else {
			return nil // Pure Dockerfile / config
		}
	} else if strings.Contains(trimmed, "message ") && strings.Contains(trimmed, "}") {
		if idx := strings.Index(trimmed, "// client.go"); idx != -1 {
			trimmed = trimmed[idx:]
		} else if idx := strings.Index(trimmed, "package "); idx != -1 {
			trimmed = trimmed[idx:]
		} else if idx := strings.Index(trimmed, "func "); idx != -1 {
			trimmed = trimmed[idx:]
		} else {
			return nil // Pure protobuf definition
		}
	}

	// If snippet is just statements, wrap in a function body
	if !strings.Contains(trimmed, "package ") {
		if !strings.Contains(trimmed, "func ") && !strings.Contains(trimmed, "type ") && !strings.Contains(trimmed, "var ") && !strings.Contains(trimmed, "const ") && !strings.Contains(trimmed, "import ") {
			trimmed = "package main\n\nfunc _() {\n" + trimmed + "\n}"
		} else {
			trimmed = "package main\n\n" + trimmed
		}
	}

	fset := token.NewFileSet()
	_, err := parser.ParseFile(fset, "snippet.go", trimmed, 0)
	return err
}

func TestAllCurriculumCodeSnippetsAndSolutionsCompile(t *testing.T) {
	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("config.Load() failed: %v", err)
	}
	t.Setenv("DB_DRIVER", "sqlite")
	t.Setenv("SQLITE_PATH", ":memory:")
	t.Setenv("SQLITE_DSN", "")

	store, err := database.Open(context.Background(), cfg)
	if err != nil {
		t.Fatalf("database.Open failed: %v", err)
	}
	defer store.Close()

	ctx := context.Background()

	// 1. Verify every Exercise Solution and Starter code parses with go/parser
	rows, err := store.DB().QueryContext(ctx, "SELECT id, starter_code, solution_code FROM exercises ORDER BY id")
	if err != nil {
		t.Fatalf("Querying exercises failed: %v", err)
	}
	defer rows.Close()

	type exerciseRecord struct {
		id           string
		starterCode  string
		solutionCode string
	}
	var exercises []exerciseRecord
	for rows.Next() {
		var rec exerciseRecord
		if err := rows.Scan(&rec.id, &rec.starterCode, &rec.solutionCode); err != nil {
			t.Fatalf("scanning exercise: %v", err)
		}
		exercises = append(exercises, rec)
	}
	if err := rows.Err(); err != nil {
		t.Fatalf("rows error: %v", err)
	}

	if len(exercises) != 41 {
		t.Fatalf("expected 41 exercises, got %d", len(exercises))
	}

	for _, ex := range exercises {
		t.Run("exercise_"+ex.id, func(t *testing.T) {
			if strings.TrimSpace(ex.solutionCode) == "" {
				t.Fatalf("exercise %s missing solution code", ex.id)
			}
			if err := parseGoSnippet(ex.solutionCode); err != nil {
				t.Errorf("exercise %s solution code failed parsing: %v", ex.id, err)
			}
			if strings.TrimSpace(ex.starterCode) == "" {
				t.Fatalf("exercise %s missing starter code", ex.id)
			}
			if err := parseGoSnippet(ex.starterCode); err != nil {
				t.Errorf("exercise %s starter code failed parsing: %v", ex.id, err)
			}
		})
	}

	// 2. Verify all lesson sections: CodeCorrected, CodeIncorrect, and markdown ```go code blocks
	lessons, err := store.ListLessons(ctx)
	if err != nil {
		t.Fatalf("ListLessons failed: %v", err)
	}

	totalFencedSnippets := 0
	for _, l := range lessons {
		detail, err := store.GetLessonDetail(ctx, l.ID)
		if err != nil {
			t.Fatalf("GetLessonDetail %s failed: %v", l.ID, err)
		}

		for _, sec := range detail.Sections {
			if strings.TrimSpace(sec.CodeCorrected) != "" {
				if err := parseGoSnippet(sec.CodeCorrected); err != nil {
					t.Errorf("lesson %s section %s code_corrected failed parsing: %v", l.ID, sec.ID, err)
				}
			}

			// Extract markdown ```go ... ``` code blocks from Body text
			matches := goCodeBlockRegex.FindAllStringSubmatch(sec.Body, -1)
			for idx, match := range matches {
				totalFencedSnippets++
				snippet := match[1]
				if err := parseGoSnippet(snippet); err != nil {
					t.Errorf("lesson %s section %s fenced snippet #%d failed parsing: %v\nSnippet:\n%s", l.ID, sec.ID, idx+1, err, snippet)
				}
			}
		}
	}

	if totalFencedSnippets == 0 {
		t.Errorf("expected to find and verify fenced go code snippets in lesson sections, found 0")
	}
}
