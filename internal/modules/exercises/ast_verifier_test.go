package exercises_test

import (
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
		MustContain: []string{"$1"},
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
