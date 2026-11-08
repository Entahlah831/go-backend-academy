package exercises_test

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gobackendacademy/platform/internal/modules/exercises"
)

func TestCheckASTValidSolution(t *testing.T) {
	src := `package main

import (
	"context"
	"database/sql"
)

func GetUser(ctx context.Context, db *sql.DB, id string) (string, error) {
	var email string
	err := db.QueryRowContext(ctx, "SELECT email FROM users WHERE id = $1", id).Scan(&email)
	if err != nil {
		return "", err
	}
	return email, nil
}`

	rule := exercises.Rule{
		TargetFunc:  "GetUser",
		MustCall:    []string{"db.QueryRowContext", "Scan"},
		NoCall:      []string{"fmt.Sprintf"},
		MustImport:  []string{"database/sql", "context"},
		MustContain: []string{"return email"},
	}

	res := exercises.CheckAST(src, rule)
	if !res.ValidSyntax {
		t.Fatalf("expected valid syntax, got: %s", res.SyntaxError)
	}
	if !res.Passed {
		t.Fatalf("expected passed, got diagnostics: %s", res.Diagnostics)
	}
	if len(res.Missing) > 0 || len(res.Violations) > 0 {
		t.Fatalf("expected 0 missing and 0 violations, got missing=%v, violations=%v", res.Missing, res.Violations)
	}
}

// TestCheckASTRejectsStringStuffingBypass verifies finding F-01:
// A string literal containing required function names must NOT satisfy AST MustCall.
func TestCheckASTRejectsStringStuffingBypass(t *testing.T) {
	src := `package repo

// Learner attempts to bypass check by putting required calls in a string variable
var x = "db.QueryRowContext $1 errors.Is(err, sql.ErrNoRows)"
`

	rule := exercises.Rule{
		MustCall: []string{"db.QueryRowContext", "errors.Is"},
	}

	res := exercises.CheckAST(src, rule)
	if !res.ValidSyntax {
		t.Fatalf("expected valid syntax, got: %s", res.SyntaxError)
	}
	if res.Passed {
		t.Fatalf("vulnerability F-01 present! Code passed with string stuffing alone: %+v", res)
	}
	if len(res.Missing) < 2 {
		t.Errorf("expected at least 2 missing calls, got: %v", res.Missing)
	}
}

func TestCheckASTDetectsProhibitedCalls(t *testing.T) {
	src := `package main

import (
	"context"
	"database/sql"
	"fmt"
)

func UnsafeQuery(ctx context.Context, db *sql.DB, id string) {
	query := fmt.Sprintf("SELECT * FROM users WHERE id = '%s'", id)
	_ = db.QueryRowContext(ctx, query)
}`

	rule := exercises.Rule{
		TargetFunc: "UnsafeQuery",
		MustCall:   []string{"db.QueryRowContext"},
		NoCall:     []string{"fmt.Sprintf"},
	}

	res := exercises.CheckAST(src, rule)
	if !res.ValidSyntax {
		t.Fatalf("expected valid syntax: %s", res.SyntaxError)
	}
	if res.Passed {
		t.Fatalf("expected failure due to prohibited fmt.Sprintf call")
	}
	if len(res.Violations) == 0 {
		t.Errorf("expected violations for fmt.Sprintf call, got none")
	}
}

func TestCheckASTReportsSyntaxError(t *testing.T) {
	src := `package main
func Broken( {
	return 42
}`

	rule := exercises.Rule{}
	res := exercises.CheckAST(src, rule)
	if res.ValidSyntax {
		t.Fatalf("expected invalid syntax for malformed Go code")
	}
	if res.Passed {
		t.Fatalf("expected not passed for syntax error")
	}
	if res.SyntaxError == "" {
		t.Fatalf("expected syntax error message, got empty")
	}
}

func TestCheckASTDetectsMissingTargetFunction(t *testing.T) {
	src := `package main
func WrongName() string {
	return ":8080"
}`

	rule := exercises.Rule{
		TargetFunc: "DefaultPort",
	}

	res := exercises.CheckAST(src, rule)
	if !res.ValidSyntax {
		t.Fatalf("expected valid syntax: %s", res.SyntaxError)
	}
	if res.Passed {
		t.Fatalf("expected failure due to missing DefaultPort function")
	}
	if len(res.Missing) == 0 {
		t.Errorf("expected missing message for DefaultPort")
	}
}

func TestDeadCallOutsideTargetRejected(t *testing.T) {
	src := `package main

import "os"

func deadCode() {
	_ = os.Getenv("PORT")
}

func DefaultPort() string {
	return ":8080"
}`
	rule := exercises.Rule{
		TargetFunc: "DefaultPort",
		MustCall:   []string{"os.Getenv"},
	}
	res := exercises.CheckAST(src, rule)
	if res.Passed {
		t.Fatalf("expected failure because os.Getenv was called outside TargetFunc, but CheckAST passed: %+v", res)
	}
}

func TestStringLiteralDoesNotSatisfyMustContain(t *testing.T) {
	src := `package main

func Process() string {
	fake := "make(map[string]int) with lock.Lock()"
	return fake
}`
	rule := exercises.Rule{
		TargetFunc:  "Process",
		MustContain: []string{"make(map", "lock.Lock()"},
	}
	res := exercises.CheckAST(src, rule)
	if res.Passed {
		t.Fatalf("expected failure because tokens were inside string literal, but CheckAST passed: %+v", res)
	}
}

type exerciseContent struct {
	Exercises []struct {
		ID           string `json:"id"`
		Title        string `json:"title"`
		StarterCode  string `json:"starter_code"`
		SolutionCode string `json:"solution_code"`
	} `json:"exercises"`
	Rules []struct {
		ExerciseID  string `json:"exercise_id"`
		TargetFunc  string `json:"target_func"`
		MustCall    any    `json:"must_call"`
		NoCall      any    `json:"no_call"`
		MustImport  any    `json:"must_import"`
		MustContain any    `json:"must_contain"`
	} `json:"exercise_rules"`
	Tests []struct {
		ExerciseID string `json:"exercise_id"`
		Filename   string `json:"filename"`
		TestCode   string `json:"test_code"`
	} `json:"exercise_tests"`
}

func parseStringSlice(v any) []string {
	if v == nil {
		return nil
	}
	switch val := v.(type) {
	case []any:
		var res []string
		for _, item := range val {
			if s, ok := item.(string); ok {
				res = append(res, s)
			}
		}
		return res
	case []string:
		return val
	case string:
		var res []string
		_ = json.Unmarshal([]byte(val), &res)
		return res
	}
	return nil
}

func TestAllExercisesHaveRulesAndPassingSolutions(t *testing.T) {
	data, err := os.ReadFile(filepath.Join("..", "..", "..", "content", "exercises.json"))
	if err != nil {
		t.Fatalf("reading exercises.json: %v", err)
	}

	var content exerciseContent
	if err := json.Unmarshal(data, &content); err != nil {
		t.Fatalf("parsing exercises.json: %v", err)
	}

	if len(content.Exercises) != 41 {
		t.Fatalf("expected 41 exercises, got %d", len(content.Exercises))
	}
	if len(content.Rules) != 41 {
		t.Fatalf("expected 41 exercise rules, got %d", len(content.Rules))
	}
	if len(content.Tests) != 41 {
		t.Fatalf("expected 41 exercise tests, got %d", len(content.Tests))
	}

	ruleMap := make(map[string]exercises.Rule)
	for _, r := range content.Rules {
		ruleMap[r.ExerciseID] = exercises.Rule{
			TargetFunc:  r.TargetFunc,
			MustCall:    parseStringSlice(r.MustCall),
			NoCall:      parseStringSlice(r.NoCall),
			MustImport:  parseStringSlice(r.MustImport),
			MustContain: parseStringSlice(r.MustContain),
		}
	}

	testMap := make(map[string]bool)
	for _, tst := range content.Tests {
		if strings.TrimSpace(tst.TestCode) != "" {
			testMap[tst.ExerciseID] = true
		}
	}

	for _, ex := range content.Exercises {
		rule, ok := ruleMap[ex.ID]
		if !ok {
			t.Errorf("exercise %s is missing an AST verification rule", ex.ID)
			continue
		}

		if !testMap[ex.ID] {
			t.Errorf("exercise %s is missing an offline unit test suite", ex.ID)
		}

		// 1. Solution code MUST pass the AST rule
		resSol := exercises.CheckAST(ex.SolutionCode, rule)
		if !resSol.ValidSyntax {
			t.Errorf("exercise %s: solution code has syntax error: %s", ex.ID, resSol.SyntaxError)
		} else if !resSol.Passed {
			t.Errorf("exercise %s: solution code failed AST check: diagnostics=%s missing=%v violations=%v",
				ex.ID, resSol.Diagnostics, resSol.Missing, resSol.Violations)
		}

		// 2. Starter code with unfinished STEP placeholder MUST NOT pass
		if strings.Contains(ex.StarterCode, "// STEP:") {
			resStarter := exercises.CheckAST(ex.StarterCode, rule)
			if resStarter.Passed && len(rule.MustContain) > 0 {
				t.Errorf("exercise %s: starter code with // STEP: passed AST check unexpectedly", ex.ID)
			}
		}
	}
}
