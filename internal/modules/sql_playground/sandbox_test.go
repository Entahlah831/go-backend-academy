package sqlplayground_test

import (
	"context"
	"strings"
	"testing"
	"time"

	sqlplayground "github.com/gobackendacademy/platform/internal/modules/sql_playground"
)

func TestSQLSandboxSafetyRules(t *testing.T) {
	sb := sqlplayground.NewSandbox(2 * time.Second)
	ctx := context.Background()

	tests := []struct {
		name      string
		query     string
		wantAllow bool
	}{
		{
			name:      "SELECT with newline",
			query:     "SELECT\n1",
			wantAllow: true,
		},
		{
			name:      "SELECT with semicolon inside string literal",
			query:     "SELECT ';'",
			wantAllow: true,
		},
		{
			name:      "SELECT with keyword inside string literal",
			query:     "SELECT 'INSERT' AS val",
			wantAllow: true,
		},
		{
			name:      "WITH mutation statement",
			query:     "WITH x AS (SELECT 1) DELETE\nFROM customers",
			wantAllow: false,
		},
		{
			name:      "ATTACH database attempt",
			query:     "ATTACH DATABASE 'evil.db' AS evil",
			wantAllow: false,
		},
		{
			name:      "Multiple statements",
			query:     "SELECT 1; SELECT 2",
			wantAllow: false,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			_, err := sb.Execute(ctx, sqlplayground.QueryRequest{Query: tc.query})
			if tc.wantAllow && err != nil {
				t.Fatalf("expected query %q to be allowed, but got error: %v", tc.query, err)
			}
			if !tc.wantAllow {
				if err == nil {
					t.Fatalf("expected query %q to be rejected, but execution succeeded", tc.query)
				}
				if !strings.Contains(err.Error(), "read-only") && !strings.Contains(err.Error(), "forbidden") {
					t.Logf("query %q rejected with error: %v", tc.query, err)
				}
			}
		})
	}
}

func TestSQLSandboxExplainQueryPlan(t *testing.T) {
	sb := sqlplayground.NewSandbox(2 * time.Second)
	ctx := context.Background()

	useIdx := true
	res, err := sb.Execute(ctx, sqlplayground.QueryRequest{
		Query:    "SELECT * FROM orders WHERE customer_id = 1",
		Explain:  true,
		UseIndex: &useIdx,
	})
	if err != nil {
		t.Fatalf("unexpected error executing explain query: %v", err)
	}
	if len(res.QueryPlan) == 0 {
		t.Errorf("expected non-empty query plan when Explain is true")
	}
}
