// Package sqlplayground executes learner SQL queries inside an isolated,
// in-memory SQLite database populated with realistic backend tables (users,
// orders, payments, outbox_events, inventory_items). Only read-only statements
// (SELECT, WITH, EXPLAIN) are permitted so learners can safely practice
// JOINs, aggregations, window functions, and index query plans.
package sqlplayground

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"

	_ "modernc.org/sqlite"
)

var (
	ErrEmptyQuery     = errors.New("query must not be empty")
	ErrForbiddenQuery = errors.New("only read-only SELECT, WITH, or EXPLAIN queries are permitted in the SQL sandbox")
)

const maxResultRows = 200

type QueryRequest struct {
	Query    string `json:"query"`
	Explain  bool   `json:"explain"`
	UseIndex *bool  `json:"use_index,omitempty"`
}

type QueryResponse struct {
	Columns     []string   `json:"columns"`
	Rows        [][]string `json:"rows"`
	RowCount    int        `json:"row_count"`
	Truncated   bool       `json:"truncated"`
	QueryPlan   []string   `json:"query_plan,omitempty"`
	ExecutionMs int64      `json:"execution_ms"`
	Engine      string     `json:"engine"`
}

type Sandbox struct {
	timeout time.Duration
}

func NewSandbox(timeout time.Duration) *Sandbox {
	if timeout <= 0 {
		timeout = 2 * time.Second
	}
	return &Sandbox{timeout: timeout}
}

func isReadOnlyStatement(q string) bool {
	trimmed := strings.TrimSpace(q)
	// Strip leading SQL line comments
	for strings.HasPrefix(trimmed, "--") {
		if nl := strings.IndexByte(trimmed, '\n'); nl >= 0 {
			trimmed = strings.TrimSpace(trimmed[nl+1:])
		} else {
			return false
		}
	}
	if trimmed == "" {
		return false
	}
	// Reject multiple statements separated by semicolons
	withoutTrailingSemi := strings.TrimSpace(strings.TrimSuffix(trimmed, ";"))
	if strings.Contains(withoutTrailingSemi, ";") {
		return false
	}
	upper := strings.ToUpper(withoutTrailingSemi)
	if !(strings.HasPrefix(upper, "SELECT ") || strings.HasPrefix(upper, "WITH ") || strings.HasPrefix(upper, "EXPLAIN ")) {
		return false
	}
	forbidden := []string{"INSERT ", "UPDATE ", "DELETE ", "DROP ", "ALTER ", "CREATE ", "ATTACH ", "DETACH ", "PRAGMA ", "VACUUM ", "REPLACE "}
	for _, kw := range forbidden {
		if strings.Contains(upper, kw) {
			return false
		}
	}
	return true
}

func (s *Sandbox) Execute(parentCtx context.Context, req QueryRequest) (QueryResponse, error) {
	q := strings.TrimSpace(req.Query)
	if q == "" {
		return QueryResponse{}, ErrEmptyQuery
	}
	if !isReadOnlyStatement(q) {
		return QueryResponse{}, ErrForbiddenQuery
	}

	ctx, cancel := context.WithTimeout(parentCtx, s.timeout)
	defer cancel()

	db, err := sql.Open("sqlite", "file::memory:?_pragma=foreign_keys(ON)")
	if err != nil {
		return QueryResponse{}, fmt.Errorf("opening sandbox db: %w", err)
	}
	defer db.Close()
	db.SetMaxOpenConns(1)

	if _, err := db.ExecContext(ctx, sandboxBootstrapSQL); err != nil {
		return QueryResponse{}, fmt.Errorf("seeding sandbox schema: %w", err)
	}
	if req.UseIndex != nil && !*req.UseIndex {
		if _, err := db.ExecContext(ctx, `DROP INDEX IF EXISTS idx_orders_customer_status_created; DROP INDEX IF EXISTS idx_order_items_order;`); err != nil {
			return QueryResponse{}, fmt.Errorf("dropping sandbox indexes: %w", err)
		}
	}

	start := time.Now()
	rows, err := db.QueryContext(ctx, q)
	if err != nil {
		return QueryResponse{}, fmt.Errorf("SQL execution error: %w", err)
	}
	defer rows.Close()

	cols, err := rows.Columns()
	if err != nil {
		return QueryResponse{}, err
	}

	outRows := [][]string{}
	truncated := false
	for rows.Next() {
		if len(outRows) >= maxResultRows {
			truncated = true
			break
		}
		raw := make([]sql.NullString, len(cols))
		dest := make([]any, len(cols))
		for i := range raw {
			dest[i] = &raw[i]
		}
		if err := rows.Scan(dest...); err != nil {
			return QueryResponse{}, err
		}
		record := make([]string, len(cols))
		for i, v := range raw {
			if v.Valid {
				record[i] = v.String
			} else {
				record[i] = "NULL"
			}
		}
		outRows = append(outRows, record)
	}
	if err := rows.Err(); err != nil {
		return QueryResponse{}, err
	}
	elapsed := time.Since(start).Milliseconds()

	var plan []string
	upper := strings.ToUpper(strings.TrimSpace(q))
	if req.Explain && !strings.HasPrefix(upper, "EXPLAIN") {
		planRows, pErr := db.QueryContext(ctx, "EXPLAIN QUERY PLAN "+q)
		if pErr == nil {
			defer planRows.Close()
			for planRows.Next() {
				var id, parent, notused int
				var detail string
				if planRows.Scan(&id, &parent, &notused, &detail) == nil {
					plan = append(plan, detail)
				}
			}
		}
	}

	return QueryResponse{
		Columns:     cols,
		Rows:        outRows,
		RowCount:    len(outRows),
		Truncated:   truncated,
		QueryPlan:   plan,
		ExecutionMs: elapsed,
		Engine:      "SQLite 3 (Isolated In-Memory Read-Only Sandbox)",
	}, nil
}

const sandboxBootstrapSQL = `
CREATE TABLE customers (
	id INTEGER PRIMARY KEY,
	email TEXT NOT NULL UNIQUE,
	full_name TEXT NOT NULL,
	tier TEXT NOT NULL CHECK (tier IN ('free', 'pro', 'enterprise')),
	created_at TEXT NOT NULL
);

CREATE TABLE orders (
	id INTEGER PRIMARY KEY,
	customer_id INTEGER NOT NULL REFERENCES customers(id),
	status TEXT NOT NULL CHECK (status IN ('pending', 'paid', 'shipped', 'cancelled')),
	total_cents INTEGER NOT NULL CHECK (total_cents >= 0),
	created_at TEXT NOT NULL
);

CREATE INDEX idx_orders_customer_status_created ON orders(customer_id, status, created_at DESC);

CREATE TABLE order_items (
	id INTEGER PRIMARY KEY,
	order_id INTEGER NOT NULL REFERENCES orders(id),
	sku TEXT NOT NULL,
	quantity INTEGER NOT NULL CHECK (quantity > 0),
	unit_price_cents INTEGER NOT NULL CHECK (unit_price_cents >= 0)
);

CREATE INDEX idx_order_items_order ON order_items(order_id);

CREATE TABLE outbox_events (
	id INTEGER PRIMARY KEY,
	aggregate_type TEXT NOT NULL,
	aggregate_id INTEGER NOT NULL,
	event_type TEXT NOT NULL,
	published INTEGER NOT NULL DEFAULT 0,
	created_at TEXT NOT NULL
);

INSERT INTO customers (id, email, full_name, tier, created_at) VALUES
	(1, 'nadia@payments.id', 'Nadia Pratama', 'enterprise', '2026-01-10 08:15:00'),
	(2, 'bima@logistics.id', 'Bima Santoso', 'pro', '2026-02-14 10:30:00'),
	(3, 'citra@retail.id', 'Citra Wijaya', 'pro', '2026-03-01 14:20:00'),
	(4, 'davin@startup.id', 'Davin Kusuma', 'free', '2026-04-05 19:45:00');

INSERT INTO orders (id, customer_id, status, total_cents, created_at) VALUES
	(101, 1, 'paid', 450000, '2026-10-01 09:00:00'),
	(102, 1, 'shipped', 1200000, '2026-10-15 11:30:00'),
	(103, 2, 'paid', 320000, '2026-10-18 16:10:00'),
	(104, 2, 'cancelled', 150000, '2026-10-20 08:05:00'),
	(105, 3, 'pending', 89000, '2026-11-01 12:00:00'),
	(106, 1, 'paid', 780000, '2026-11-05 15:40:00');

INSERT INTO order_items (id, order_id, sku, quantity, unit_price_cents) VALUES
	(1, 101, 'GO-ARCH-BOOK', 2, 150000),
	(2, 101, 'PG-TUNING-LAB', 1, 150000),
	(3, 102, 'ENT-SUPPORT-YR', 1, 1200000),
	(4, 103, 'K8S-PROBE-KIT', 2, 160000),
	(5, 105, 'SQL-INDEX-DECK', 1, 89000),
	(6, 106, 'DIST-SYS-WORKSHOP', 1, 780000);

INSERT INTO outbox_events (id, aggregate_type, aggregate_id, event_type, published, created_at) VALUES
	(1, 'order', 101, 'order.paid', 1, '2026-10-01 09:00:01'),
	(2, 'order', 102, 'order.shipped', 1, '2026-10-15 11:30:02'),
	(3, 'order', 103, 'order.paid', 1, '2026-10-18 16:10:01'),
	(4, 'order', 105, 'order.created', 0, '2026-11-01 12:00:01'),
	(5, 'order', 106, 'order.paid', 0, '2026-11-05 15:40:01');
`
