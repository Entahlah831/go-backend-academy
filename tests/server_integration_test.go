package tests

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"net/http"
	"net/http/cookiejar"
	"net/http/httptest"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/gobackendacademy/platform/internal/config"
	"github.com/gobackendacademy/platform/internal/modules/diagnostics"
	"github.com/gobackendacademy/platform/internal/platform/database"
	httpplatform "github.com/gobackendacademy/platform/internal/platform/http"
	"github.com/gobackendacademy/platform/internal/platform/logger"
	"github.com/gobackendacademy/platform/seed"
)

func setupTestServer(t *testing.T) (*httpplatform.Server, *httptest.Server) {
	t.Helper()
	dbFile := filepath.Join(t.TempDir(), "test_academy.db")
	t.Setenv("DB_DRIVER", "sqlite")
	t.Setenv("SQLITE_PATH", dbFile)
	t.Setenv("SQLITE_DSN", "")
	t.Setenv("WEB_STATIC_DIR", "../web")
	t.Setenv("RATE_LIMIT_RPS", "10000")
	t.Setenv("RATE_LIMIT_BURST", "10000")

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("config.Load() failed: %v", err)
	}
	log := logger.New(io.Discard, "test")
	store, err := database.Open(context.Background(), cfg)
	if err != nil {
		t.Fatalf("database.Open() failed: %v", err)
	}
	t.Cleanup(func() { _ = store.Close() })

	srv := httpplatform.NewServer(cfg, log, store)
	ts := httptest.NewServer(srv.Handler())
	t.Cleanup(ts.Close)
	return srv, ts
}

func TestLivenessAndReadinessSeparation(t *testing.T) {
	srv, ts := setupTestServer(t)

	resp, err := http.Get(ts.URL + "/healthz")
	if err != nil || resp.StatusCode != http.StatusOK {
		t.Fatalf("expected /healthz 200 OK, got err=%v status=%d", err, resp.StatusCode)
	}
	_ = resp.Body.Close()

	srv.SetShuttingDown(true)
	readyResp, err := http.Get(ts.URL + "/readyz")
	if err != nil {
		t.Fatalf("GET /readyz failed: %v", err)
	}
	defer readyResp.Body.Close()
	if readyResp.StatusCode != http.StatusServiceUnavailable {
		t.Errorf("expected /readyz 503 during shutdown, got %d", readyResp.StatusCode)
	}

	liveResp, err := http.Get(ts.URL + "/healthz")
	if err != nil {
		t.Fatalf("GET /healthz during shutdown failed: %v", err)
	}
	defer liveResp.Body.Close()
	if liveResp.StatusCode != http.StatusOK {
		t.Errorf("expected /healthz to remain 200 OK during shutdown, got %d", liveResp.StatusCode)
	}
}

func TestReadyzFailsWhenDatabaseClosedAndOpenFailsOnUnreachablePostgres(t *testing.T) {
	dbFile := filepath.Join(t.TempDir(), "readyz.db")
	t.Setenv("DB_DRIVER", "sqlite")
	t.Setenv("SQLITE_PATH", dbFile)
	t.Setenv("SQLITE_DSN", "")

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("config.Load() failed: %v", err)
	}
	log := logger.New(io.Discard, "test")
	store, err := database.Open(context.Background(), cfg)
	if err != nil {
		t.Fatalf("database.Open() failed: %v", err)
	}
	srv := httpplatform.NewServer(cfg, log, store)
	ts := httptest.NewServer(srv.Handler())
	defer ts.Close()

	// Closing the underlying SQL pool must cause /readyz to report 503 Service Unavailable
	_ = store.Close()
	readyResp, err := http.Get(ts.URL + "/readyz")
	if err != nil {
		t.Fatalf("GET /readyz failed: %v", err)
	}
	defer readyResp.Body.Close()
	if readyResp.StatusCode != http.StatusServiceUnavailable {
		t.Errorf("expected /readyz 503 when database is closed, got %d", readyResp.StatusCode)
	}

	// Configuring DB_DRIVER=postgres against an unreachable port must fail fast (no silent memory fallback)
	t.Setenv("DB_DRIVER", "postgres")
	t.Setenv("POSTGRES_HOST", "127.0.0.1")
	t.Setenv("POSTGRES_PORT", "59999")
	t.Setenv("POSTGRES_USER", "academy")
	t.Setenv("POSTGRES_PASSWORD", "secret")
	t.Setenv("POSTGRES_DB", "gobackendacademy")
	t.Setenv("POSTGRES_DSN", "")
	t.Setenv("DB_CONNECT_TIMEOUT_SEC", "1")

	pgCfg, err := config.Load()
	if err != nil {
		t.Fatalf("config.Load() for postgres failed: %v", err)
	}
	if _, err := database.Open(context.Background(), pgCfg); err == nil {
		t.Fatalf("expected database.Open() to fail fast when PostgreSQL is unreachable, but got nil error")
	}
}

func TestDotEnvAndDynamicDatabasePortConfig(t *testing.T) {
	envPath := filepath.Join(t.TempDir(), ".env.custom")
	envContent := strings.Join([]string{
		"PORT=9191",
		"HOST=127.0.0.1",
		"DB_DRIVER=postgres",
		"POSTGRES_HOST=db.internal.local",
		"POSTGRES_PORT=15432",
		"POSTGRES_USER=gba_admin",
		"POSTGRES_PASSWORD=\"p@ss:w/rd\"",
		"POSTGRES_DB=gba_prod",
		"POSTGRES_SSLMODE=require",
	}, "\n")
	if err := os.WriteFile(envPath, []byte(envContent), 0o600); err != nil {
		t.Fatalf("writing custom .env failed: %v", err)
	}

	// Ensure clean env before loading .env file
	for _, k := range []string{"PORT", "HOST", "DB_DRIVER", "POSTGRES_HOST", "POSTGRES_PORT", "POSTGRES_USER", "POSTGRES_PASSWORD", "POSTGRES_DB", "POSTGRES_SSLMODE", "POSTGRES_DSN"} {
		t.Setenv(k, "")
		_ = os.Unsetenv(k)
	}

	loaded, err := config.LoadDotEnv(envPath)
	if err != nil || !loaded {
		t.Fatalf("LoadDotEnv failed: loaded=%v err=%v", loaded, err)
	}

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("config.Load() after LoadDotEnv failed: %v", err)
	}
	if cfg.ListenAddr() != "127.0.0.1:9191" {
		t.Errorf("expected ListenAddr 127.0.0.1:9191, got %s", cfg.ListenAddr())
	}
	if cfg.PostgresPort != 15432 || cfg.PostgresHost != "db.internal.local" {
		t.Errorf("expected PostgresHost=db.internal.local PostgresPort=15432, got %s:%d", cfg.PostgresHost, cfg.PostgresPort)
	}
	if !strings.Contains(cfg.PostgresDSN, "db.internal.local:15432/gba_prod") || !strings.Contains(cfg.PostgresDSN, "sslmode=require") {
		t.Errorf("unexpected constructed PostgresDSN: %s", cfg.PostgresDSN)
	}
	// DBTarget must never leak the password
	if strings.Contains(cfg.DBTarget(), "p@ss") {
		t.Errorf("DBTarget leaked password: %s", cfg.DBTarget())
	}

	// Invalid integer in environment must fail config.Load()
	t.Setenv("POSTGRES_PORT", "not-a-port")
	if _, err := config.Load(); err == nil {
		t.Errorf("expected config.Load() to reject non-integer POSTGRES_PORT")
	}
}

func TestPersistenceAcrossServerRestartsAndMigrationsCycle(t *testing.T) {
	dbPath := filepath.Join(t.TempDir(), "persistent_academy.db")
	t.Setenv("DB_DRIVER", "sqlite")
	t.Setenv("SQLITE_PATH", dbPath)
	t.Setenv("SQLITE_DSN", "")

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("config.Load() failed: %v", err)
	}
	log := logger.New(io.Discard, "test")

	// --- Server Instance #1 ---
	store1, err := database.Open(context.Background(), cfg)
	if err != nil {
		t.Fatalf("store1 Open failed: %v", err)
	}
	srv1 := httpplatform.NewServer(cfg, log, store1)
	ts1 := httptest.NewServer(srv1.Handler())

	// 1. Save progress and capture session cookie
	sessCookie, _ := postJSONWithCookie(t, ts1.URL+"/api/v1/progress", map[string]any{
		"lesson_id": "l0-backend-http-lifecycle",
		"status":    "completed",
	}, http.StatusOK, nil)
	if sessCookie == nil {
		t.Fatalf("expected gba_sid cookie to be returned")
	}

	// 2. Save note using session cookie
	postJSONWithCookie(t, ts1.URL+"/api/v1/notes", map[string]any{
		"lesson_id": "l0-backend-http-lifecycle",
		"content":   "Persisted across SQLite restart!",
	}, http.StatusOK, sessCookie)

	// 3. Save bookmark
	postJSONWithCookie(t, ts1.URL+"/api/v1/bookmarks", map[string]any{
		"item_type": "case_study",
		"item_id":   "cs-01-task-api",
		"note":      "Reference architecture",
	}, http.StatusOK, sessCookie)

	// 4. Record exercise attempt
	postJSONWithCookie(t, ts1.URL+"/api/v1/exercises/verify", map[string]any{
		"exercise_id":     "ex-l0-stage-a-what-is-backend",
		"code":            "package main\nfunc DefaultPort() string { return \":8080\" }",
		"required_tokens": []string{},
	}, http.StatusOK, sessCookie)

	// 5. Record quiz attempt
	postJSONWithCookie(t, ts1.URL+"/api/v1/quizzes/qz-1/attempts", map[string]any{
		"answers": []int{1},
	}, http.StatusOK, sessCookie)

	// Shut down Server #1 and close database connection completely
	ts1.Close()
	if err := store1.Close(); err != nil {
		t.Fatalf("closing store1: %v", err)
	}

	// --- Server Instance #2 (fresh process simulation against the same SQLite file) ---
	store2, err := database.Open(context.Background(), cfg)
	if err != nil {
		t.Fatalf("store2 Open failed: %v", err)
	}
	defer store2.Close()
	srv2 := httpplatform.NewServer(cfg, log, store2)
	ts2 := httptest.NewServer(srv2.Handler())
	defer ts2.Close()

	// Verify progress survived restart (using session cookie)
	var progResp struct {
		Progress map[string]string `json:"progress"`
	}
	getJSONWithCookie(t, ts2.URL+"/api/v1/progress", &progResp, sessCookie)
	if progResp.Progress["l0-backend-http-lifecycle"] != "completed" {
		t.Errorf("progress lost across restart: %+v", progResp.Progress)
	}

	// Verify note survived restart
	var notesResp struct {
		Notes map[string]string `json:"notes"`
	}
	getJSONWithCookie(t, ts2.URL+"/api/v1/notes", &notesResp, sessCookie)
	if notesResp.Notes["l0-backend-http-lifecycle"] != "Persisted across SQLite restart!" {
		t.Errorf("notes lost across restart: %+v", notesResp.Notes)
	}

	// Verify bookmark survived restart
	var bmResp struct {
		Bookmarks []struct {
			ItemID string `json:"item_id"`
			Note   string `json:"note"`
		} `json:"bookmarks"`
	}
	getJSONWithCookie(t, ts2.URL+"/api/v1/bookmarks", &bmResp, sessCookie)
	if len(bmResp.Bookmarks) != 1 || bmResp.Bookmarks[0].ItemID != "cs-01-task-api" {
		t.Errorf("bookmarks lost across restart: %+v", bmResp.Bookmarks)
	}

	// Verify exercise attempt survived restart
	var exAttResp struct {
		Attempts []database.ExerciseAttemptRecord `json:"attempts"`
	}
	getJSONWithCookie(t, ts2.URL+"/api/v1/exercises/attempts", &exAttResp, sessCookie)
	if len(exAttResp.Attempts) != 1 || !exAttResp.Attempts[0].Passed {
		t.Errorf("exercise attempts lost across restart: %+v", exAttResp.Attempts)
	}

	// Verify quiz attempt survived restart
	var qzAttResp struct {
		Attempts []struct {
			QuizID string `json:"quiz_id"`
			Score  int    `json:"score"`
		} `json:"attempts"`
	}
	getJSONWithCookie(t, ts2.URL+"/api/v1/quiz-attempts", &qzAttResp, sessCookie)
	if len(qzAttResp.Attempts) != 1 || qzAttResp.Attempts[0].Score != 1 {
		t.Errorf("quiz attempts lost across restart: %+v", qzAttResp.Attempts)
	}

	// Verify MigrateDown -> MigrateUp -> Seed cycle works cleanly
	reverted, err := store2.MigrateDown(context.Background(), 2)
	if err != nil || len(reverted) != 2 {
		t.Fatalf("MigrateDown failed: reverted=%v err=%v", reverted, err)
	}
	applied, err := store2.MigrateUp(context.Background())
	if err != nil || len(applied) != 2 {
		t.Fatalf("MigrateUp after Down failed: applied=%v err=%v", applied, err)
	}
	seeded, err := store2.Seed(context.Background())
	if err != nil || len(seeded) == 0 {
		t.Fatalf("Seed after MigrateUp failed: seeded=%v err=%v", seeded, err)
	}
}

func TestUnknownRouteReturns404ProblemJSON(t *testing.T) {
	_, ts := setupTestServer(t)
	resp, err := http.Get(ts.URL + "/api/v1/does-not-exist")
	if err != nil {
		t.Fatalf("GET unknown route failed: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusNotFound {
		t.Errorf("expected 404 Not Found on unknown route, got %d", resp.StatusCode)
	}
}

func TestCurriculumLessonsCaseStudiesAndSQLPlaygroundEndpoints(t *testing.T) {
	_, ts := setupTestServer(t)

	for _, path := range []string{
		"/api/v1/curriculum",
		"/api/v1/modules",
		"/api/v1/lessons",
		"/api/v1/lessons/l0-stage-a-what-is-backend",
		"/api/v1/lessons/l0-backend-http-lifecycle",
		"/api/v1/quizzes",
		"/api/v1/quizzes/qz-0-foundations",
		"/api/v1/quizzes/qz-1",
		"/api/v1/case-studies",
		"/api/v1/case-studies/cs-01-task-api",
		"/api/v1/db-scenarios",
		"/api/v1/diagnostics/rules",
		"/curriculum-stages.js",
		"/app-bridge.js",
	} {
		resp, err := http.Get(ts.URL + path)
		if err != nil {
			t.Fatalf("GET %s failed: %v", path, err)
		}
		_ = resp.Body.Close()
		if resp.StatusCode != http.StatusOK {
			t.Errorf("expected 200 OK from %s, got %d", path, resp.StatusCode)
		}
	}

	var curData struct {
		Levels  []any `json:"levels"`
		Lessons []any `json:"lessons"`
	}
	getJSON(t, ts.URL+"/api/v1/curriculum", &curData)
	if len(curData.Levels) != 11 || len(curData.Lessons) != 41 {
		t.Errorf("expected 11 levels and 41 Stage A-J lessons in SQL database, got levels=%d lessons=%d", len(curData.Levels), len(curData.Lessons))
	}

	// Verify SQL Playground Sandbox executes real read-only SELECT + EXPLAIN QUERY PLAN
	var sqlRes struct {
		Columns   []string   `json:"columns"`
		Rows      [][]string `json:"rows"`
		RowCount  int        `json:"row_count"`
		QueryPlan []string   `json:"query_plan"`
	}
	raw := postJSON(t, ts.URL+"/api/v1/sql-playground/execute", map[string]any{
		"query":   "SELECT c.full_name, COUNT(o.id) AS orders_count FROM customers c JOIN orders o ON o.customer_id = c.id WHERE o.status = 'paid' GROUP BY c.id ORDER BY orders_count DESC",
		"explain": true,
	}, http.StatusOK)
	if err := json.Unmarshal(raw, &sqlRes); err != nil {
		t.Fatalf("decoding sql playground response: %v", err)
	}
	if sqlRes.RowCount != 2 || len(sqlRes.QueryPlan) == 0 {
		t.Errorf("expected 2 grouped rows and non-empty query_plan, got rows=%d plan=%v", sqlRes.RowCount, sqlRes.QueryPlan)
	}

	// Verify SQL Playground rejects mutating queries
	postJSON(t, ts.URL+"/api/v1/sql-playground/execute", map[string]any{
		"query": "DROP TABLE orders",
	}, http.StatusBadRequest)
}

func TestStrictJSONDecodingRejectsUnknownFieldsAndTrailingData(t *testing.T) {
	_, ts := setupTestServer(t)

	for _, path := range []string{
		"/api/v1/progress",
		"/api/v1/bookmarks",
		"/api/v1/notes",
		"/api/v1/exercises/verify",
		"/api/v1/diagnostics/analyze",
		"/api/v1/recommendations",
		"/api/v1/sql-playground/execute",
	} {
		// Unknown field must return 400
		resp, err := http.Post(ts.URL+path, "application/json", strings.NewReader(`{"unexpected_field": 123}`))
		if err != nil {
			t.Fatalf("POST %s failed: %v", path, err)
		}
		_ = resp.Body.Close()
		if resp.StatusCode != http.StatusBadRequest {
			t.Errorf("expected 400 Bad Request for unknown field on %s, got %d", path, resp.StatusCode)
		}
	}

	// Trailing JSON token must return 400
	resp, err := http.Post(ts.URL+"/api/v1/diagnostics/analyze", "application/json", strings.NewReader(`{"code":"package main"}{"code":"extra"}`))
	if err != nil {
		t.Fatalf("POST trailing JSON failed: %v", err)
	}
	_ = resp.Body.Close()
	if resp.StatusCode != http.StatusBadRequest {
		t.Errorf("expected 400 Bad Request for trailing JSON tokens, got %d", resp.StatusCode)
	}
}

func TestOfflineCodeDiagnosticsLab(t *testing.T) {
	_, ts := setupTestServer(t)

	payload, _ := json.Marshal(map[string]string{
		"code": `func Bad(db *sql.DB, r *http.Request) {
			q := fmt.Sprintf("SELECT * FROM users WHERE id = '%s'", r.URL.Query().Get("id"))
			rows, err := db.Query(q)
			if err != nil { panic(err) }
			go func() { http.Get("http://example.com") }()
		}`,
	})

	resp, err := http.Post(ts.URL+"/api/v1/diagnostics/analyze", "application/json", bytes.NewReader(payload))
	if err != nil {
		t.Fatalf("POST /api/v1/diagnostics/analyze failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected 200 OK, got %d", resp.StatusCode)
	}

	var report diagnostics.AnalysisReport
	if err := json.NewDecoder(resp.Body).Decode(&report); err != nil {
		t.Fatalf("decoding report: %v", err)
	}

	if !report.OfflineMode {
		t.Errorf("expected OfflineMode=true")
	}
	if len(report.Findings) < 4 {
		t.Errorf("expected at least 4 findings (GO-SEC-001, GO-DB-001, GO-ERR-001, GO-CONC-001), got %d", len(report.Findings))
	}
	if report.StaticAnalysisLimitations == "" {
		t.Errorf("expected non-empty StaticAnalysisLimitations")
	}
}

func TestAnalyzerFalsePositiveAndFalseNegativeProbes(t *testing.T) {
	analyzer := diagnostics.NewAnalyzer(false, 2*time.Second, "none", "", "")

	tests := []struct {
		name     string
		code     string
		wantRule string
	}{
		{
			name:     "FP1 correct pkg-level regexp + func",
			code:     "package main\nimport \"regexp\"\nvar idRe = regexp.MustCompile(`^[a-z]+$`)\nfunc valid(s string) bool { return idRe.MatchString(s) }",
			wantRule: "GO-INFO-000",
		},
		{
			name:     "FP2 parameterized query, Sprintf only for log",
			code:     `func f(db *sql.DB, id int){ rows,_:=db.Query("SELECT * FROM t WHERE id=$1",id); defer rows.Close(); log.Println(fmt.Sprintf("q %d",id)) }`,
			wantRule: "GO-INFO-000",
		},
		{
			name:     "FN1 SQL injection via + concatenation",
			code:     `func f(db *sql.DB, id string){ db.Exec("DELETE FROM t WHERE id='"+id+"'") }`,
			wantRule: "GO-SEC-001",
		},
		{
			name:     "FN2 Query leak masked by unrelated .Close()",
			code:     `func f(db *sql.DB, f *os.File){ rows,_:=db.Query("select 1"); defer f.Close(); for rows.Next(){} }`,
			wantRule: "GO-DB-001",
		},
		{
			name:     "FN3 data race with WaitGroup",
			code:     "var n int\nfunc f(){ var wg sync.WaitGroup; for i:=0;i<10;i++{ wg.Add(1); go func(){ defer wg.Done(); n++ }() }; wg.Wait() }",
			wantRule: "GO-CONC-002",
		},
		{
			name:     "FN4 goroutine leak, word ctx in a comment",
			code:     "func f(){ // ctx not used\n ch:=make(chan int); go func(){ ch<-1 }() }",
			wantRule: "GO-CONC-001",
		},
		{
			name:     "FN5 http.Client{} no timeout",
			code:     `c:=&http.Client{}; c.Get(u)`,
			wantRule: "GO-SEC-003",
		},
		{
			name:     "FN6 unchecked error",
			code:     `func f(){ x,_ := os.Open("a"); _ = x }`,
			wantRule: "GO-ERR-002",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			rep := analyzer.AnalyzeCode(context.Background(), tc.code)
			found := false
			var gotRules []string
			for _, f := range rep.Findings {
				gotRules = append(gotRules, f.RuleID)
				if f.RuleID == tc.wantRule {
					found = true
				}
			}
			if !found {
				t.Errorf("%s: expected rule %s, got %s", tc.name, tc.wantRule, strings.Join(gotRules, ", "))
			}
		})
	}
}

func TestProgressAndBookmarksRoundTripAndValidation(t *testing.T) {
	_, ts := setupTestServer(t)

	jar, _ := cookiejar.New(nil)
	client := ts.Client()
	client.Jar = jar
	saveBody, _ := json.Marshal(map[string]string{
		"lesson_id": "l4-acid-isolation-mvcc",
		"status":    "completed",
	})
	postResp, err := client.Post(ts.URL+"/api/v1/progress", "application/json", bytes.NewReader(saveBody))
	if err != nil || postResp.StatusCode != http.StatusOK {
		t.Fatalf("POST /api/v1/progress failed: %v", err)
	}
	_ = postResp.Body.Close()

	getResp, err := client.Get(ts.URL + "/api/v1/progress")
	if err != nil || getResp.StatusCode != http.StatusOK {
		t.Fatalf("GET /api/v1/progress failed: %v", err)
	}
	defer getResp.Body.Close()

	var data struct {
		Progress map[string]string `json:"progress"`
	}
	_ = json.NewDecoder(getResp.Body).Decode(&data)
	if data.Progress["l4-acid-isolation-mvcc"] != "completed" {
		t.Errorf("expected l4-acid-isolation-mvcc=completed, got %v", data.Progress)
	}

	// Regression: invalid status='started' must return 400 Bad Request
	badStatus, _ := json.Marshal(map[string]string{
		"lesson_id": "l0-backend-http-lifecycle",
		"status":    "started",
	})
	badResp, err := http.Post(ts.URL+"/api/v1/progress", "application/json", bytes.NewReader(badStatus))
	if err != nil {
		t.Fatalf("POST invalid status failed: %v", err)
	}
	_ = badResp.Body.Close()
	if badResp.StatusCode != http.StatusBadRequest {
		t.Errorf("expected 400 Bad Request for status='started', got %d", badResp.StatusCode)
	}

	// Regression: unknown lesson_id must return 400 Bad Request
	badLesson, _ := json.Marshal(map[string]string{
		"lesson_id": "nope-unknown-lesson",
		"status":    "completed",
	})
	badLessonResp, err := http.Post(ts.URL+"/api/v1/progress", "application/json", bytes.NewReader(badLesson))
	if err != nil {
		t.Fatalf("POST unknown lesson failed: %v", err)
	}
	_ = badLessonResp.Body.Close()
	if badLessonResp.StatusCode != http.StatusBadRequest {
		t.Errorf("expected 400 Bad Request for unknown lesson_id, got %d", badLessonResp.StatusCode)
	}

	// Regression: invalid bookmark item_type='quiz' must return 400 Bad Request
	badBookmark, _ := json.Marshal(map[string]string{
		"item_type": "quiz",
		"item_id":   "qz-1",
	})
	bmResp, err := http.Post(ts.URL+"/api/v1/bookmarks", "application/json", bytes.NewReader(badBookmark))
	if err != nil {
		t.Fatalf("POST invalid bookmark failed: %v", err)
	}
	_ = bmResp.Body.Close()
	if bmResp.StatusCode != http.StatusBadRequest {
		t.Errorf("expected 400 Bad Request for bookmark item_type='quiz', got %d", bmResp.StatusCode)
	}
}

func TestExerciseVerifyMultipleAttemptsAndCommentStuffingRejection(t *testing.T) {
	_, ts := setupTestServer(t)

	// 1. Comment-stuffed payload must fail even if required token appears inside a comment
	stuffedPayload, _ := json.Marshal(map[string]any{
		"exercise_id":     "ex-l0-stage-a-what-is-backend",
		"code":            "package main\n// \":8080\"\nfunc DefaultPort() string { return \"\" }",
		"required_tokens": []string{},
	})
	resp1, err := http.Post(ts.URL+"/api/v1/exercises/verify", "application/json", bytes.NewReader(stuffedPayload))
	if err != nil {
		t.Fatalf("POST /api/v1/exercises/verify #1 failed: %v", err)
	}
	defer resp1.Body.Close()
	if resp1.StatusCode != http.StatusOK {
		t.Fatalf("expected 200 OK on attempt #1, got %d", resp1.StatusCode)
	}
	var res1 struct {
		AttemptID string `json:"attempt_id"`
		Passed    bool   `json:"passed"`
	}
	_ = json.NewDecoder(resp1.Body).Decode(&res1)
	if res1.Passed {
		t.Errorf("expected comment-stuffed submission to fail, but Passed=true")
	}

	// 2. Second attempt on the exact same exercise must succeed with a distinct AttemptID
	validPayload, _ := json.Marshal(map[string]any{
		"exercise_id":     "ex-l0-stage-a-what-is-backend",
		"code":            "package main\nfunc DefaultPort() string { return \":8080\" }",
		"required_tokens": []string{},
	})
	resp2, err := http.Post(ts.URL+"/api/v1/exercises/verify", "application/json", bytes.NewReader(validPayload))
	if err != nil {
		t.Fatalf("POST /api/v1/exercises/verify #2 failed: %v", err)
	}
	defer resp2.Body.Close()
	var res2 struct {
		AttemptID string `json:"attempt_id"`
		Passed    bool   `json:"passed"`
	}
	_ = json.NewDecoder(resp2.Body).Decode(&res2)
	if !res2.Passed {
		t.Errorf("expected valid submission to pass")
	}
	if res1.AttemptID == "" || res2.AttemptID == "" || res1.AttemptID == res2.AttemptID {
		t.Errorf("expected distinct non-empty AttemptIDs across attempts, got %q and %q", res1.AttemptID, res2.AttemptID)
	}
}

func postJSON(t *testing.T, url string, payload any, wantStatus int) []byte {
	t.Helper()
	_, raw := postJSONWithCookie(t, url, payload, wantStatus, nil)
	return raw
}

func postJSONWithCookie(t *testing.T, url string, payload any, wantStatus int, cookie *http.Cookie) (*http.Cookie, []byte) {
	t.Helper()
	b, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("marshaling payload: %v", err)
	}
	req, err := http.NewRequest(http.MethodPost, url, bytes.NewReader(b))
	if err != nil {
		t.Fatalf("creating POST req: %v", err)
	}
	req.Header.Set("Content-Type", "application/json")
	if cookie != nil {
		req.AddCookie(cookie)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("POST %s failed: %v", url, err)
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != wantStatus {
		t.Fatalf("POST %s status=%d want=%d body=%s", url, resp.StatusCode, wantStatus, string(raw))
	}
	var retCookie *http.Cookie
	for _, ck := range resp.Cookies() {
		if ck.Name == "gba_sid" {
			retCookie = ck
			break
		}
	}
	if retCookie == nil {
		retCookie = cookie
	}
	return retCookie, raw
}

func getJSON(t *testing.T, url string, dst any) {
	t.Helper()
	getJSONWithCookie(t, url, dst, nil)
}

func getJSONWithCookie(t *testing.T, url string, dst any, cookie *http.Cookie) {
	t.Helper()
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		t.Fatalf("creating GET req: %v", err)
	}
	if cookie != nil {
		req.AddCookie(cookie)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("GET %s failed: %v", url, err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		raw, _ := io.ReadAll(resp.Body)
		t.Fatalf("GET %s status=%d body=%s", url, resp.StatusCode, string(raw))
	}
	if err := json.NewDecoder(resp.Body).Decode(dst); err != nil {
		t.Fatalf("decoding GET %s: %v", url, err)
	}
}

func TestAllExercisesServerSideVerification(t *testing.T) {
	srv, ts := setupTestServer(t)

	var dbExercisesCount int
	if err := srv.Store().DB().QueryRow("SELECT COUNT(*) FROM exercises").Scan(&dbExercisesCount); err != nil {
		t.Fatalf("failed querying exercises count from db: %v", err)
	}

	var curriculum struct {
		Lessons []struct {
			ID   string `json:"id"`
			Slug string `json:"slug"`
		} `json:"lessons"`
	}
	getJSON(t, ts.URL+"/api/v1/curriculum", &curriculum)

	totalExercises := 0
	for _, l := range curriculum.Lessons {
		var detail struct {
			ID       string `json:"id"`
			Slug     string `json:"slug"`
			Exercise *struct {
				ID           string `json:"id"`
				StarterCode  string `json:"starter_code"`
				SolutionCode string `json:"solution_code"`
			} `json:"exercise"`
		}
		getJSON(t, ts.URL+"/api/v1/lessons/"+l.Slug, &detail)
		if detail.Exercise == nil || detail.Exercise.ID == "" {
			t.Fatalf("lesson %s missing exercise", l.Slug)
		}
		totalExercises++

		// 1. Starter code with // STEP: removed and empty required_tokens MUST fail via DB required_pattern
		bypassAttempt := bytes.ReplaceAll([]byte(detail.Exercise.StarterCode), []byte("// STEP:"), []byte("// DONE:"))
		rawFail := postJSON(t, ts.URL+"/api/v1/exercises/verify", map[string]any{
			"exercise_id":     detail.Exercise.ID,
			"code":            string(bypassAttempt),
			"required_tokens": []string{},
		}, http.StatusOK)
		var failRes struct {
			Passed bool `json:"passed"`
		}
		_ = json.Unmarshal(rawFail, &failRes)
		if failRes.Passed {
			t.Errorf("exercise %s (%s) passed with starter code when required_tokens was empty!", detail.Exercise.ID, l.Slug)
		}

		// 2. Solution code with empty required_tokens MUST pass via DB required_pattern
		rawPass := postJSON(t, ts.URL+"/api/v1/exercises/verify", map[string]any{
			"exercise_id":     detail.Exercise.ID,
			"code":            detail.Exercise.SolutionCode,
			"required_tokens": []string{},
		}, http.StatusOK)
		var passRes struct {
			Passed      bool   `json:"passed"`
			Diagnostics string `json:"diagnostics"`
		}
		_ = json.Unmarshal(rawPass, &passRes)
		if !passRes.Passed {
			t.Errorf("exercise %s (%s) failed with canonical solution_code! diag: %s", detail.Exercise.ID, l.Slug, passRes.Diagnostics)
		}
	}
	if totalExercises != dbExercisesCount {
		t.Errorf("expected %d exercises across curriculum matching DB exercises count, got %d", dbExercisesCount, totalExercises)
	}
}

func TestServerSideQuizEvaluationAndBridgeQuizzes(t *testing.T) {
	_, ts := setupTestServer(t)

	bridgeQuizzes := []string{"qz-0-foundations", "qz-1-go-basics", "qz-4-sql-basics"}
	for _, qid := range bridgeQuizzes {
		var detail struct {
			ID        string `json:"id"`
			Level     int    `json:"level"`
			Title     string `json:"title"`
			Questions []struct {
				ID           string          `json:"id"`
				OrderIndex   int             `json:"order_index"`
				Question     string          `json:"question"`
				Options      json.RawMessage `json:"options"`
				CorrectIndex *int            `json:"correct_index,omitempty"`
				Explanation  *string         `json:"explanation,omitempty"`
			} `json:"questions"`
		}
		getJSON(t, ts.URL+"/api/v1/quizzes/"+qid, &detail)
		if len(detail.Questions) < 3 {
			t.Errorf("quiz %s must have >= 3 questions, got %d", qid, len(detail.Questions))
		}
		for i, q := range detail.Questions {
			if q.CorrectIndex != nil {
				t.Errorf("quiz %s question %d leaked correct_index!", qid, i+1)
			}
			if q.Explanation != nil {
				t.Errorf("quiz %s question %d leaked explanation before submission!", qid, i+1)
			}
		}

		// Grade submission on server with correct answers
		var expectedAnswers []int
		switch qid {
		case "qz-0-foundations":
			expectedAnswers = []int{1, 1, 2}
		case "qz-1-go-basics":
			expectedAnswers = []int{2, 0, 0}
		case "qz-4-sql-basics":
			expectedAnswers = []int{1, 1, 1}
		}

		rawRes := postJSON(t, ts.URL+"/api/v1/quizzes/"+qid+"/attempts", map[string]any{
			"answers": expectedAnswers,
		}, http.StatusOK)

		var attemptRes struct {
			Score          int `json:"score"`
			TotalQuestions int `json:"total_questions"`
			Results        []struct {
				QuestionID   string `json:"question_id"`
				Selected     int    `json:"selected"`
				CorrectIndex int    `json:"correct_index"`
				Correct      bool   `json:"correct"`
				Explanation  string `json:"explanation"`
			} `json:"results"`
		}
		if err := json.Unmarshal(rawRes, &attemptRes); err != nil {
			t.Fatalf("unmarshaling attempt response: %v", err)
		}

		if attemptRes.Score != len(expectedAnswers) || attemptRes.TotalQuestions != len(expectedAnswers) {
			t.Errorf("quiz %s expected perfect score %d/%d, got %d/%d", qid, len(expectedAnswers), len(expectedAnswers), attemptRes.Score, attemptRes.TotalQuestions)
		}
		for i, r := range attemptRes.Results {
			if !r.Correct {
				t.Errorf("quiz %s question %d expected correct, got false", qid, i+1)
			}
			if r.Explanation == "" {
				t.Errorf("quiz %s question %d expected explanation after evaluation, got empty string", qid, i+1)
			}
		}
	}
}

func TestServerRejectStringStuffingBypass(t *testing.T) {
	_, ts := setupTestServer(t)

	// F-01 regression: submitting calls inside string literals must fail AST verification
	rawFail := postJSON(t, ts.URL+"/api/v1/exercises/verify", map[string]any{
		"exercise_id": "ex-l5-db-ecosystem-comparison",
		"code": `package repo

// F-01 attack attempt: putting required call names inside string literal
var x = "db.QueryRowContext $1 errors.Is(err, sql.ErrNoRows)"
`,
		"required_tokens": []string{},
	}, http.StatusOK)

	var res struct {
		Passed      bool   `json:"passed"`
		Diagnostics string `json:"diagnostics"`
	}
	if err := json.Unmarshal(rawFail, &res); err != nil {
		t.Fatalf("unmarshaling verify response: %v", err)
	}

	if res.Passed {
		t.Fatalf("CRITICAL SECURITY FLAW: String stuffing bypass succeeded! Response: %+v", res)
	}
}

func TestExercisePackageAndLocalExecution(t *testing.T) {
	_, ts := setupTestServer(t)

	// 1. Fetch exercise package via REST API
	resp, err := http.Get(ts.URL + "/api/v1/exercises/ex-l0-stage-a-what-is-backend/package")
	if err != nil {
		t.Fatalf("GET /package failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected 200 OK, got %d", resp.StatusCode)
	}

	var pkg struct {
		ExerciseID  string            `json:"exercise_id"`
		Title       string            `json:"title"`
		Description string            `json:"description"`
		Files       map[string]string `json:"files"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&pkg); err != nil {
		t.Fatalf("decoding package: %v", err)
	}

	if pkg.ExerciseID != "ex-l0-stage-a-what-is-backend" {
		t.Errorf("expected ex-l0-stage-a-what-is-backend, got %s", pkg.ExerciseID)
	}

	for _, reqFile := range []string{"main.go", "main_test.go", "go.mod", "README.md"} {
		if _, ok := pkg.Files[reqFile]; !ok {
			t.Errorf("missing expected package file: %s", reqFile)
		}
	}

	// 2. Write package to a clean temp directory and run real go test toolchain
	workDir := filepath.Join(t.TempDir(), "local-exercise")
	if err := os.MkdirAll(workDir, 0755); err != nil {
		t.Fatalf("mkdir workDir: %v", err)
	}

	for fn, content := range pkg.Files {
		if err := os.WriteFile(filepath.Join(workDir, fn), []byte(content), 0644); err != nil {
			t.Fatalf("writing %s: %v", fn, err)
		}
	}

	// Verify starter code fails the real unit test
	cmdFail := exec.Command("go", "test", "-v", "./...")
	cmdFail.Dir = workDir
	outFail, errFail := cmdFail.CombinedOutput()
	if errFail == nil {
		t.Fatalf("expected starter code to FAIL unit test, but it passed:\n%s", string(outFail))
	}

	// 3. Write solution code and verify it PASSES the real unit test
	solutionCode := `package main

func DefaultPort() string {
	return ":8080"
}
`
	if err := os.WriteFile(filepath.Join(workDir, "main.go"), []byte(solutionCode), 0644); err != nil {
		t.Fatalf("writing solution main.go: %v", err)
	}

	cmdPass := exec.Command("go", "test", "-v", "./...")
	cmdPass.Dir = workDir
	outPass, errPass := cmdPass.CombinedOutput()
	if errPass != nil {
		t.Fatalf("expected solution code to PASS unit test, but failed: %v\nOutput:\n%s", errPass, string(outPass))
	}

	if !strings.Contains(string(outPass), "PASS") {
		t.Errorf("expected output to contain PASS, got:\n%s", string(outPass))
	}

	// 4. Verify alias /tests endpoint
	respAlias, err := http.Get(ts.URL + "/api/v1/exercises/ex-l0-stage-a-what-is-backend/tests")
	if err != nil {
		t.Fatalf("GET /tests failed: %v", err)
	}
	_ = respAlias.Body.Close()
	if respAlias.StatusCode != http.StatusOK {
		t.Errorf("expected 200 OK on alias /tests, got %d", respAlias.StatusCode)
	}
}

func TestDiagnosticRulesInSyncWithCode(t *testing.T) {
	_, ts := setupTestServer(t)

	resp, err := http.Get(ts.URL + "/api/v1/diagnostics/rules")
	if err != nil {
		t.Fatalf("GET /api/v1/diagnostics/rules: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected 200 OK, got %d", resp.StatusCode)
	}

	var res struct {
		Rules []struct {
			RuleID string `json:"rule_id"`
		} `json:"rules"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&res); err != nil {
		t.Fatalf("decoding rules: %v", err)
	}

	dbRules := map[string]bool{}
	for _, r := range res.Rules {
		dbRules[r.RuleID] = true
	}

	codeRules := diagnostics.AllRuleIDs()
	codeRuleMap := map[string]bool{}
	for _, r := range codeRules {
		codeRuleMap[r] = true
		if !dbRules[r] {
			t.Errorf("Rule %s exists in code but is missing from diagnostic_rules database table", r)
		}
	}

	for dbRule := range dbRules {
		if !codeRuleMap[dbRule] {
			t.Errorf("Rule %s exists in diagnostic_rules database table but is not registered in code", dbRule)
		}
	}
}

func TestSeedFilesUniqueAndContentHashing(t *testing.T) {
	for _, dialect := range []string{"sqlite", "postgres"} {
		files, err := fs.Glob(seed.FS, dialect+"/*.sql")
		if err != nil {
			t.Fatalf("glob seeds for %s: %v", dialect, err)
		}
		if len(files) == 0 {
			t.Fatalf("expected seed files for %s", dialect)
		}
		hashes := map[string]string{}
		for _, f := range files {
			data, err := fs.ReadFile(seed.FS, f)
			if err != nil {
				t.Fatalf("reading seed %s: %v", f, err)
			}
			h := fmt.Sprintf("%x", sha256.Sum256(data))
			if prev, exists := hashes[h]; exists {
				t.Fatalf("duplicate seed file hash detected in %s: %s and %s share hash %s", dialect, prev, f, h)
			}
			hashes[h] = f
		}
	}

	dbPath := filepath.Join(t.TempDir(), "seed_hash_test.db")
	t.Setenv("DB_DRIVER", "sqlite")
	t.Setenv("SQLITE_PATH", dbPath)
	t.Setenv("SQLITE_DSN", "")

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("config.Load() failed: %v", err)
	}
	store, err := database.Open(context.Background(), cfg)
	if err != nil {
		t.Fatalf("database.Open failed: %v", err)
	}
	defer store.Close()

	states, err := store.MigrationStatus(context.Background())
	if err != nil {
		t.Fatalf("MigrationStatus failed: %v", err)
	}

	foundHashedSeed := false
	for _, st := range states {
		if strings.HasPrefix(st.Version, "seed:") {
			foundHashedSeed = true
			if !st.Applied {
				t.Errorf("expected seed %s to be marked applied", st.Version)
			}
			parts := strings.Split(st.Version, ":")
			if len(parts) < 3 {
				t.Errorf("expected seed version with content hash, got %s", st.Version)
			}
		}
	}
	if !foundHashedSeed {
		t.Errorf("no seed records found in MigrationStatus")
	}

	reseeded, err := store.Reseed(context.Background())
	if err != nil {
		t.Fatalf("store.Reseed failed: %v", err)
	}
	if len(reseeded) == 0 {
		t.Errorf("expected seeds applied on Reseed, got %v", reseeded)
	}
}

func TestUniqueOrderIndexAndLessonListingOrder(t *testing.T) {
	dbPath := filepath.Join(t.TempDir(), "order_test.db")
	t.Setenv("DB_DRIVER", "sqlite")
	t.Setenv("SQLITE_PATH", dbPath)
	t.Setenv("SQLITE_DSN", "")

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("config.Load() failed: %v", err)
	}
	store, err := database.Open(context.Background(), cfg)
	if err != nil {
		t.Fatalf("database.Open failed: %v", err)
	}
	defer store.Close()
	ctx := context.Background()

	lessons, err := store.ListLessons(ctx)
	if err != nil {
		t.Fatalf("ListLessons failed: %v", err)
	}
	if len(lessons) != 41 {
		t.Fatalf("expected 41 lessons, got %d", len(lessons))
	}

	seenLevelOrder := map[string]string{}
	for i, l := range lessons {
		if l.DisplayNo == "" {
			t.Errorf("lesson %s missing display_no", l.ID)
		}
		key := fmt.Sprintf("%d:%d", l.LevelID, l.OrderIndex)
		if prev, ok := seenLevelOrder[key]; ok {
			t.Errorf("duplicate (level_id, order_index) = %s between %s and %s", key, prev, l.ID)
		}
		seenLevelOrder[key] = l.ID

		if i > 0 {
			prevL := lessons[i-1]
			if prevL.LevelID > l.LevelID {
				t.Errorf("lessons not ordered by level: %s (level %d) after %s (level %d)", l.ID, l.LevelID, prevL.ID, prevL.LevelID)
			} else if prevL.LevelID == l.LevelID && prevL.OrderIndex >= l.OrderIndex {
				t.Errorf("lessons within level %d not ordered by order_index: %s (order %d) after %s (order %d)", l.LevelID, l.ID, l.OrderIndex, prevL.ID, prevL.OrderIndex)
			}
		}
	}
}

func TestContentSingleSourceAndSeedSync(t *testing.T) {
	manifestPath := filepath.Join("..", "content", "manifest.json")
	manifestData, err := os.ReadFile(manifestPath)
	if err != nil {
		t.Fatalf("reading content manifest: %v", err)
	}

	var manifest map[string]string
	if err := json.Unmarshal(manifestData, &manifest); err != nil {
		t.Fatalf("parsing manifest: %v", err)
	}

	for filename, expectedHash := range manifest {
		p := filepath.Join("..", "content", filename)
		data, err := os.ReadFile(p)
		if err != nil {
			t.Fatalf("missing content file %s: %v", p, err)
		}
		normalized := bytes.ReplaceAll(data, []byte("\r\n"), []byte("\n"))
		actualHash := fmt.Sprintf("%x", sha256.Sum256(normalized))
		if actualHash != expectedHash {
			t.Errorf("content drift detected in %s: hash mismatch (run go run ./tools/gen-content -export)", filename)
		}
	}
}

func TestServerSideSessionIssuanceAndBounds(t *testing.T) {
	_, ts := setupTestServer(t)

	// 1. Initial request should issue gba_sid cookie
	resp, err := http.Get(ts.URL + "/api/v1/curriculum")
	if err != nil {
		t.Fatalf("GET /api/v1/curriculum failed: %v", err)
	}
	defer resp.Body.Close()

	var sessionCookie *http.Cookie
	for _, c := range resp.Cookies() {
		if c.Name == "gba_sid" {
			sessionCookie = c
			break
		}
	}
	if sessionCookie == nil {
		t.Fatalf("expected gba_sid cookie to be set on initial response")
	}
	if !sessionCookie.HttpOnly {
		t.Errorf("expected gba_sid cookie to be HttpOnly")
	}
	if sessionCookie.SameSite != http.SameSiteLaxMode {
		t.Errorf("expected gba_sid cookie to have SameSite=Lax")
	}

	client := &http.Client{}

	doReq := func(method, path string, body any, wantStatus int) []byte {
		t.Helper()
		var rdr io.Reader
		if body != nil {
			b, _ := json.Marshal(body)
			rdr = bytes.NewReader(b)
		}
		req, err := http.NewRequest(method, ts.URL+path, rdr)
		if err != nil {
			t.Fatalf("creating request: %v", err)
		}
		req.Header.Set("Content-Type", "application/json")
		req.AddCookie(sessionCookie)
		res, err := client.Do(req)
		if err != nil {
			t.Fatalf("%s %s failed: %v", method, path, err)
		}
		defer res.Body.Close()
		raw, _ := io.ReadAll(res.Body)
		if res.StatusCode != wantStatus {
			t.Fatalf("%s %s status=%d want=%d body=%s", method, path, res.StatusCode, wantStatus, string(raw))
		}
		return raw
	}

	// 2. Save progress without user_id in payload
	doReq("POST", "/api/v1/progress", map[string]any{
		"lesson_id": "l0-stage-a-what-is-backend",
		"status":    "completed",
	}, http.StatusOK)

	// Fetch progress with session cookie, verify it has l0-stage-a-what-is-backend
	rawProg := doReq("GET", "/api/v1/progress", nil, http.StatusOK)
	var progRes struct {
		Progress map[string]string `json:"progress"`
	}
	_ = json.Unmarshal(rawProg, &progRes)
	st, foundLesson := progRes.Progress["l0-stage-a-what-is-backend"]
	if !foundLesson || st != "completed" {
		t.Errorf("expected lesson to be completed in session progress, got %v", progRes.Progress)
	}

	// 3. Save bookmark without user_id
	doReq("POST", "/api/v1/bookmarks", map[string]any{
		"item_id":   "l0-stage-a-what-is-backend",
		"item_type": "lesson",
	}, http.StatusOK)

	rawBookmarks := doReq("GET", "/api/v1/bookmarks", nil, http.StatusOK)
	var bkmRes struct {
		Bookmarks []struct {
			ItemID string `json:"item_id"`
		} `json:"bookmarks"`
	}
	_ = json.Unmarshal(rawBookmarks, &bkmRes)
	if len(bkmRes.Bookmarks) == 0 || bkmRes.Bookmarks[0].ItemID != "l0-stage-a-what-is-backend" {
		t.Errorf("expected bookmark l0-stage-a-what-is-backend, got %v", bkmRes.Bookmarks)
	}

	// 4. Save note without user_id
	rawNoteResp := doReq("POST", "/api/v1/notes", map[string]any{
		"lesson_id": "l0-stage-a-what-is-backend",
		"content":   "Session-scoped test note",
	}, http.StatusOK)
	var noteSaved struct {
		Status string `json:"status"`
		NoteID string `json:"note_id"`
	}
	_ = json.Unmarshal(rawNoteResp, &noteSaved)
	if !strings.HasPrefix(noteSaved.NoteID, "not_") {
		t.Errorf("expected note_id prefix not_, got %s", noteSaved.NoteID)
	}

	rawNotes := doReq("GET", "/api/v1/notes", nil, http.StatusOK)
	var notesRes struct {
		Notes map[string]string `json:"notes"`
	}
	_ = json.Unmarshal(rawNotes, &notesRes)
	if notesRes.Notes["l0-stage-a-what-is-backend"] != "Session-scoped test note" {
		t.Errorf("expected session note content to be retained, got %v", notesRes.Notes)
	}

	// 5. Bounds test: Oversized note (> 64 KB) must fail with 400 PAYLOAD_TOO_LARGE
	hugeContent := strings.Repeat("A", 66000)
	rawErr := doReq("POST", "/api/v1/notes", map[string]any{
		"lesson_id": "l0-stage-a-what-is-backend",
		"content":   hugeContent,
	}, http.StatusBadRequest)
	if !strings.Contains(string(rawErr), "PAYLOAD_TOO_LARGE") {
		t.Errorf("expected PAYLOAD_TOO_LARGE for oversized note, got %s", string(rawErr))
	}
}

func TestCurriculumExpansionAndStructuredSections(t *testing.T) {
	srv, ts := setupTestServer(t)

	// 1. Verify 17 bridge lessons each have >= 5000 bytes across sections
	bridgeIDs := []string{
		"l0-stage-a-what-is-backend", "l0-stage-a-git-go-workspace", "l1-stage-b-variables-types-zerovalues",
		"l1-stage-b-control-flow-loops-functions", "l1-stage-b-slices-maps-iteration", "l1-stage-b-structs-methods-pointers",
		"l1-stage-b-interfaces-errors-fundamentals", "l1-stage-b-json-files-unit-testing", "l2-stage-c-goroutines-channels-waitgroup",
		"l3-stage-d-first-http-server-crud", "l4-stage-e-sql-relational-fundamentals", "l5-stage-e-database-sql-crud-basics",
		"l6-stage-f-password-hashing-bearer-auth", "l7-stage-g-table-driven-tests-httptest", "l8-stage-h-handler-service-repo-layers",
		"l9-stage-i-redis-cache-aside-backoff", "l10-stage-j-capstone-production-blueprint",
	}

	for _, id := range bridgeIDs {
		var detail struct {
			ID       string `json:"id"`
			Sections []struct {
				SectionType string `json:"section_type"`
				Body        string `json:"body"`
			} `json:"sections"`
		}
		getJSON(t, ts.URL+"/api/v1/lessons/"+id, &detail)
		if len(detail.Sections) == 0 {
			t.Fatalf("bridge lesson %s returned 0 sections", id)
		}

		totalLen := 0
		seenTypes := map[string]bool{}
		for _, s := range detail.Sections {
			totalLen += len(s.Body)
			seenTypes[s.SectionType] = true
		}
		if totalLen < 5000 {
			t.Errorf("bridge lesson %s has only %d bytes (expected >= 5000 bytes)", id, totalLen)
		}
		for _, requiredType := range []string{"goal", "analogy", "walkthrough", "pitfalls", "exercise", "deep_dive"} {
			if !seenTypes[requiredType] {
				t.Errorf("bridge lesson %s missing structured section %q", id, requiredType)
			}
		}
	}

	// 2. Verify all levels have quizzes with >= 3 questions and server grading works
	var quizzesRes struct {
		Quizzes []struct {
			ID    string `json:"id"`
			Level int    `json:"level"`
			Title string `json:"title"`
		} `json:"quizzes"`
	}
	getJSON(t, ts.URL+"/api/v1/quizzes", &quizzesRes)

	levelSeen := map[int]bool{}
	for _, q := range quizzesRes.Quizzes {
		levelSeen[q.Level] = true
	}
	for lvl := 0; lvl <= 10; lvl++ {
		if !levelSeen[lvl] {
			t.Errorf("missing assessment quiz for level %d", lvl)
		}
	}

	// 3. Test grading attempt on new quiz qz-l3-http-servers
	rawAttempt := postJSON(t, ts.URL+"/api/v1/quizzes/qz-l3-http-servers/attempts", map[string]any{
		"answers": []int{1, 1, 0},
	}, http.StatusOK)
	var res struct {
		Score          int `json:"score"`
		TotalQuestions int `json:"total_questions"`
	}
	_ = json.Unmarshal(rawAttempt, &res)
	if res.Score != 3 || res.TotalQuestions != 3 {
		t.Errorf("expected perfect score 3/3 on qz-l3-http-servers, got %d/%d", res.Score, res.TotalQuestions)
	}

	_ = srv
}

// ---------------------------------------------------------------------
// Acceptance Tests for P0-1 & P1-6: Session & Identity Hardening
// ---------------------------------------------------------------------

func TestUserIdFromQueryIgnored(t *testing.T) {
	_, ts := setupTestServer(t)

	jarA, _ := cookiejar.New(nil)
	clientA := &http.Client{Jar: jarA}

	jarB, _ := cookiejar.New(nil)
	clientB := &http.Client{Jar: jarB}

	// 1. Client A saves progress: completed
	bodyA, _ := json.Marshal(map[string]string{
		"lesson_id": "l0-backend-http-lifecycle",
		"status":    "completed",
	})
	respA, err := clientA.Post(ts.URL+"/api/v1/progress", "application/json", bytes.NewReader(bodyA))
	if err != nil || respA.StatusCode != http.StatusOK {
		t.Fatalf("clientA save progress failed: %v", err)
	}
	_ = respA.Body.Close()

	// 2. Client B saves progress: in_progress
	bodyB, _ := json.Marshal(map[string]string{
		"lesson_id": "l0-backend-http-lifecycle",
		"status":    "in_progress",
	})
	respB, err := clientB.Post(ts.URL+"/api/v1/progress", "application/json", bytes.NewReader(bodyB))
	if err != nil || respB.StatusCode != http.StatusOK {
		t.Fatalf("clientB save progress failed: %v", err)
	}
	_ = respB.Body.Close()

	// 3. Client A requests GET /api/v1/progress?user_id=usr_victim (spoofing B or anyone else)
	spoofedResp, err := clientA.Get(ts.URL + "/api/v1/progress?user_id=usr_some_other_victim")
	if err != nil || spoofedResp.StatusCode != http.StatusOK {
		t.Fatalf("clientA spoofed GET failed: %v", err)
	}
	defer spoofedResp.Body.Close()

	var data struct {
		Progress map[string]string `json:"progress"`
	}
	if err := json.NewDecoder(spoofedResp.Body).Decode(&data); err != nil {
		t.Fatalf("decoding progress: %v", err)
	}

	// Must return client A's actual status ("completed"), NEVER victim's or blank
	if got := data.Progress["l0-backend-http-lifecycle"]; got != "completed" {
		t.Fatalf("expected progress 'completed' from session cookie, got %q (user_id spoofing allowed!)", got)
	}
}

func TestNoCookieCreatesSessionOnlyForUserRoutes(t *testing.T) {
	srv, ts := setupTestServer(t)
	db := srv.Store().DB()

	countSessions := func() int {
		var n int
		_ = db.QueryRow("SELECT COUNT(*) FROM sessions").Scan(&n)
		return n
	}
	countUsers := func() int {
		var n int
		_ = db.QueryRow("SELECT COUNT(*) FROM users").Scan(&n)
		return n
	}

	initialSessions := countSessions()
	initialUsers := countUsers()

	// Healthz requests must NEVER create sessions or users
	for i := 0; i < 5; i++ {
		resp, err := http.Get(ts.URL + "/healthz")
		if err != nil || resp.StatusCode != http.StatusOK {
			t.Fatalf("healthz failed: %v", err)
		}
		_ = resp.Body.Close()
	}

	// Readyz requests must NEVER create sessions or users
	for i := 0; i < 5; i++ {
		resp, err := http.Get(ts.URL + "/readyz")
		if err != nil || resp.StatusCode != http.StatusOK {
			t.Fatalf("readyz failed: %v", err)
		}
		_ = resp.Body.Close()
	}

	// Static frontend requests must NEVER create sessions or users
	respStatic, err := http.Get(ts.URL + "/")
	if err != nil || respStatic.StatusCode != http.StatusOK {
		t.Fatalf("static / failed: %v", err)
	}
	_ = respStatic.Body.Close()

	if got := countSessions(); got != initialSessions {
		t.Fatalf("expected sessions count unchanged (%d), got %d after public/healthz requests", initialSessions, got)
	}
	if got := countUsers(); got != initialUsers {
		t.Fatalf("expected users count unchanged (%d), got %d after public/healthz requests", initialUsers, got)
	}

	// Now make a stateful user request without cookie: should create exactly 1 user & 1 session
	saveBody, _ := json.Marshal(map[string]string{
		"lesson_id": "l0-backend-http-lifecycle",
		"status":    "completed",
	})
	postResp, err := http.Post(ts.URL+"/api/v1/progress", "application/json", bytes.NewReader(saveBody))
	if err != nil || postResp.StatusCode != http.StatusOK {
		t.Fatalf("stateful request failed: %v", err)
	}
	_ = postResp.Body.Close()

	if got := countSessions(); got != initialSessions+1 {
		t.Fatalf("expected sessions count to increment by 1, got %d (initial: %d)", got, initialSessions)
	}
	if got := countUsers(); got != initialUsers+1 {
		t.Fatalf("expected users count to increment by 1, got %d (initial: %d)", got, initialUsers)
	}
}

func TestExplicitUserIDNoEmptySessionRow(t *testing.T) {
	srv, ts := setupTestServer(t)

	// Send POST with query parameter user_id (query user_id must be ignored)
	payload, _ := json.Marshal(map[string]string{
		"lesson_id": "l0-backend-http-lifecycle",
		"status":    "completed",
	})
	resp, err := http.Post(ts.URL+"/api/v1/progress?user_id=usr_query_injected", "application/json", bytes.NewReader(payload))
	if err != nil || resp.StatusCode != http.StatusOK {
		t.Fatalf("POST failed: %v", err)
	}
	_ = resp.Body.Close()

	// Verify no session with empty id or explicit injected id was created directly in sessions.id
	var emptyCount int
	err = srv.Store().DB().QueryRow("SELECT COUNT(*) FROM sessions WHERE id = '' OR id = 'usr_query_injected'").Scan(&emptyCount)
	if err != nil {
		t.Fatalf("querying sessions: %v", err)
	}
	if emptyCount != 0 {
		t.Fatalf("found %d invalid session rows with empty or unhashed token id", emptyCount)
	}

	// Verify that sending unexpected user_id in JSON body is rejected by strict JSON decoding
	injectedPayload, _ := json.Marshal(map[string]string{
		"user_id":   "usr_injected_attacker",
		"lesson_id": "l0-backend-http-lifecycle",
		"status":    "completed",
	})
	injResp, err := http.Post(ts.URL+"/api/v1/progress", "application/json", bytes.NewReader(injectedPayload))
	if err != nil {
		t.Fatalf("POST failed: %v", err)
	}
	_ = injResp.Body.Close()
	if injResp.StatusCode != http.StatusBadRequest {
		t.Fatalf("expected 400 Bad Request when body contains unknown user_id field, got %d", injResp.StatusCode)
	}
}

func TestSecureCookieBehindHTTPSProxy(t *testing.T) {
	_, ts := setupTestServer(t)

	// 1. Direct connection or plain HTTP: cookie should NOT have Secure flag
	req1, _ := http.NewRequest(http.MethodPost, ts.URL+"/api/v1/progress", bytes.NewReader([]byte(`{"lesson_id":"l0-backend-http-lifecycle","status":"completed"}`)))
	req1.Header.Set("Content-Type", "application/json")
	resp1, err := http.DefaultClient.Do(req1)
	if err != nil || resp1.StatusCode != http.StatusOK {
		t.Fatalf("req1 failed: %v", err)
	}
	defer resp1.Body.Close()

	var ck1 *http.Cookie
	for _, c := range resp1.Cookies() {
		if c.Name == "gba_sid" {
			ck1 = c
			break
		}
	}
	if ck1 == nil {
		t.Fatalf("expected gba_sid cookie on req1")
	}
	if ck1.Secure {
		t.Errorf("expected Secure=false for direct HTTP connection, got true")
	}

	// 2. Behind trusted proxy with X-Forwarded-Proto: https -> cookie MUST have Secure flag
	req2, _ := http.NewRequest(http.MethodPost, ts.URL+"/api/v1/progress", bytes.NewReader([]byte(`{"lesson_id":"l0-backend-http-lifecycle","status":"completed"}`)))
	req2.Header.Set("Content-Type", "application/json")
	req2.Header.Set("X-Forwarded-Proto", "https")
	// Loopback 127.0.0.1 is in trusted proxies by default
	resp2, err := http.DefaultClient.Do(req2)
	if err != nil || resp2.StatusCode != http.StatusOK {
		t.Fatalf("req2 failed: %v", err)
	}
	defer resp2.Body.Close()

	var ck2 *http.Cookie
	for _, c := range resp2.Cookies() {
		if c.Name == "gba_sid" {
			ck2 = c
			break
		}
	}
	if ck2 == nil {
		t.Fatalf("expected gba_sid cookie on req2")
	}
	if !ck2.Secure {
		t.Errorf("expected Secure=true behind trusted HTTPS proxy, got false")
	}
}

func TestExpiredSessionsPurged(t *testing.T) {
	srv, _ := setupTestServer(t)
	ctx := context.Background()

	// Insert active session
	activeHash := "hash_active_12345"
	activeUID := "usr_active_session_test"
	if err := srv.Store().CreateSession(ctx, activeHash, activeUID, time.Now().Add(1*time.Hour)); err != nil {
		t.Fatalf("CreateSession active failed: %v", err)
	}

	// Insert expired session
	expiredHash := "hash_expired_98765"
	expiredUID := "usr_expired_session_test"
	if err := srv.Store().CreateSession(ctx, expiredHash, expiredUID, time.Now().Add(-1*time.Hour)); err != nil {
		t.Fatalf("CreateSession expired failed: %v", err)
	}

	// Purge expired sessions
	n, err := srv.Store().PurgeExpiredSessions(ctx)
	if err != nil {
		t.Fatalf("PurgeExpiredSessions failed: %v", err)
	}
	if n < 1 {
		t.Fatalf("expected at least 1 purged session, got %d", n)
	}

	// Active session still exists
	uid, err := srv.Store().GetSessionUser(ctx, activeHash)
	if err != nil || uid != activeUID {
		t.Fatalf("active session was incorrectly purged: %v", err)
	}

	// Expired session is gone
	_, err = srv.Store().GetSessionUser(ctx, expiredHash)
	if !errors.Is(err, database.ErrNotFound) {
		t.Fatalf("expected ErrNotFound for purged expired session, got %v", err)
	}
}

func TestClaimLegacyUserProgress(t *testing.T) {
	srv, ts := setupTestServer(t)
	ctx := context.Background()

	// 1. Seed legacy user data directly
	legacyUID := "usr_legacy_student_999"
	_ = srv.Store().SetLessonProgress(ctx, legacyUID, "l0-backend-http-lifecycle", "completed")
	_ = srv.Store().SaveNote(ctx, "not_legacy_001", legacyUID, "l0-backend-http-lifecycle", "My legacy notes")

	// 2. Start new client session
	jar, _ := cookiejar.New(nil)
	client := &http.Client{Jar: jar}

	// Initial request to issue session cookie
	initResp, err := client.Get(ts.URL + "/api/v1/curriculum")
	if err != nil || initResp.StatusCode != http.StatusOK {
		t.Fatalf("init curriculum failed: %v", err)
	}
	_ = initResp.Body.Close()

	// 3. Claim legacy user data
	claimPayload, _ := json.Marshal(map[string]string{
		"legacy_user_id": legacyUID,
	})
	claimResp, err := client.Post(ts.URL+"/api/v1/session/claim-legacy", "application/json", bytes.NewReader(claimPayload))
	if err != nil || claimResp.StatusCode != http.StatusOK {
		t.Fatalf("claim-legacy failed: %v", err)
	}
	_ = claimResp.Body.Close()

	// 4. Verify client session now has legacy data
	progResp, err := client.Get(ts.URL + "/api/v1/progress")
	if err != nil || progResp.StatusCode != http.StatusOK {
		t.Fatalf("GET progress failed: %v", err)
	}
	defer progResp.Body.Close()

	var data struct {
		Progress map[string]string `json:"progress"`
	}
	_ = json.NewDecoder(progResp.Body).Decode(&data)
	if data.Progress["l0-backend-http-lifecycle"] != "completed" {
		t.Fatalf("claimed progress not transferred, got: %+v", data.Progress)
	}

	// 5. Attempting to claim the same legacy ID again fails with 404 (already consumed/deleted)
	doubleClaimResp, err := client.Post(ts.URL+"/api/v1/session/claim-legacy", "application/json", bytes.NewReader(claimPayload))
	if err != nil {
		t.Fatalf("second claim request failed: %v", err)
	}
	_ = doubleClaimResp.Body.Close()
	if doubleClaimResp.StatusCode != http.StatusNotFound {
		t.Fatalf("expected 404 Not Found on claiming already claimed legacy ID, got %d", doubleClaimResp.StatusCode)
	}

	// 6. Attempting to claim another legacy ID into a session that already has progress returns 409 Conflict
	secondLegacy := "usr_legacy_student_888"
	_ = srv.Store().SetLessonProgress(ctx, secondLegacy, "l0-stateless-vs-stateful-arch", "completed")
	claimPayload2, _ := json.Marshal(map[string]string{
		"legacy_user_id": secondLegacy,
	})
	conflictResp, err := client.Post(ts.URL+"/api/v1/session/claim-legacy", "application/json", bytes.NewReader(claimPayload2))
	if err != nil {
		t.Fatalf("conflict claim request failed: %v", err)
	}
	_ = conflictResp.Body.Close()
	if conflictResp.StatusCode != http.StatusConflict {
		t.Fatalf("expected 409 Conflict on claiming into a session with existing progress, got %d", conflictResp.StatusCode)
	}

	// 7. Attempting to claim 'usr_local_default' fails with 400 Bad Request
	guestPayload, _ := json.Marshal(map[string]string{
		"legacy_user_id": "usr_local_default",
	})
	guestResp, err := client.Post(ts.URL+"/api/v1/session/claim-legacy", "application/json", bytes.NewReader(guestPayload))
	if err != nil {
		t.Fatalf("guest claim request failed: %v", err)
	}
	_ = guestResp.Body.Close()
	if guestResp.StatusCode != http.StatusBadRequest {
		t.Fatalf("expected 400 Bad Request on claiming usr_local_default, got %d", guestResp.StatusCode)
	}
}

func TestGoVersionClaimsMatchGoMod(t *testing.T) {
	// 1. Read go.mod version
	modBytes, err := os.ReadFile("../go.mod")
	if err != nil {
		t.Fatalf("reading go.mod: %v", err)
	}
	var goModVer string
	for _, line := range strings.Split(string(modBytes), "\n") {
		trimmed := strings.TrimSpace(line)
		if strings.HasPrefix(trimmed, "go ") {
			fields := strings.Fields(trimmed)
			if len(fields) >= 2 {
				goModVer = fields[1]
				break
			}
		}
	}
	if goModVer == "" {
		t.Fatalf("could not determine go version from go.mod")
	}
	parts := strings.Split(goModVer, ".")
	if len(parts) < 2 {
		t.Fatalf("invalid go.mod version format: %s", goModVer)
	}
	majorMinor := strings.Join(parts[:2], ".")
	expectedTag := fmt.Sprintf("Go %s+", majorMinor)

	// 2. Check web/index.html header badge
	htmlBytes, err := os.ReadFile("../web/index.html")
	if err != nil {
		t.Fatalf("reading web/index.html: %v", err)
	}
	if !strings.Contains(string(htmlBytes), expectedTag) {
		t.Errorf("web/index.html header badge does not contain %q matching go.mod (%s)", expectedTag, goModVer)
	}

	// 3. Check README.md
	readmeBytes, err := os.ReadFile("../README.md")
	if err != nil {
		t.Fatalf("reading README.md: %v", err)
	}
	if !strings.Contains(string(readmeBytes), expectedTag) {
		t.Errorf("README.md does not contain %q matching go.mod (%s)", expectedTag, goModVer)
	}
}
