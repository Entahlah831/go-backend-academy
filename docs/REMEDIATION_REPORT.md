# Go Backend Academy — Comprehensive Remediation Report (`REMEDIATION_REPORT.md`)

**Date:** 2026-11-07  
**Repository:** `github.com/gobackendacademy/platform`  
**Verified Toolchain:** `go1.27.1 windows/amd64`, `node v26.1.0`, `python 3.14.4` (`sqlite3 3.50.4`)

---

## 1. Remediation Checklist & Priority Matrix (P0 → P3)

| ID | Priority | Component | Summary | Status | Verification Command |
| :--- | :---: | :--- | :--- | :---: | :--- |
| **REM-P0-01** | **P0** | `tests/server_integration_test.go` | Fix `go vet` failure (`using liveResp before checking for errors` at line 58) | **Verified** | `go vet ./...` (0 warnings/errors) |
| **REM-P0-02** | **P0** | `internal/platform/database/db.go`, `internal/platform/http/router.go`, `internal/modules/exercises/service.go` | Fix FK constraint failures on unprovisioned `user_id` (`ensureUser`), validate `status` (`in_progress`\|`completed`) & `item_type` (`lesson`\|`case_study`\|`db_scenario`) in HTTP handlers/store, validate known `lesson_id`/`exercise_id`, and generate unique attempt IDs (`att_<ex>_<hex>_<seq>`) so multiple attempts on the same exercise never collide on `PRIMARY KEY` | **Verified** | `go test -v ./...` & `sqlite_check.py` |
| **REM-P1-01** | **P1** | `web/index.html`, `internal/modules/exercises/service.go` | Fix comment-stuffing vulnerability (`/* ... */` bypassed 24/24 exercises) and starter signature false-passes (`starterNoStep: 3` on `l2-profiling-pprof-benchmarks`, `l3-validation-openapi-ratelimit`, `l5-db-ecosystem-comparison`) by stripping Go comments (`StripGoComments`) and checking implementation expressions | **Verified** | `node grader_test.js` (`starterAsIs: 0`, `starterNoStep: 0`, `solution: 24`, `stuffed: 0`) & `go test -v ./...` |
| **REM-P1-02** | **P1** | `internal/modules/diagnostics/analyzer.go`, `web/index.html`, `seed/` | Eliminate False Positives (`FP1` pkg-level `regexp.MustCompile`, `FP2` parameterized query with `fmt.Sprintf` in `log.Println`) and False Negatives (`FN1` SQL `+` concatenation, `FN2` unclosed `rows` masked by `f.Close()`, `FN3` goroutine data race with `WaitGroup` `GO-CONC-002`, `FN4` goroutine leak with `ctx` in comment `GO-CONC-001`, `FN5` `&http.Client{}` without `Timeout` `GO-SEC-003`, `FN6` unchecked `_` error `GO-ERR-002`) | **Verified** | `node analyzer_fpfn_test.js` & `go test -v -run TestAnalyzerFalsePositiveAndFalseNegativeProbes ./...` |
| **REM-P2-01** | **P2** | `web/index.html`, `seed/sqlite/001_seed_data.sql`, `seed/postgres/001_seed_data.sql` | Fix technical & syntax defects in curriculum Go snippets: (1) `l2-gmp-channels-context-workers.solution` mixed tab+space indent and `break` inside `select` only exiting `select` instead of `for` loop; (2) `l6-security-auth-owasp.solution` `ValidateWebhookIP` missing `addr = addr.Unmap()` allowing IPv4-mapped IPv6 (`::ffff:127.0.0.1`) SSRF bypass; (3) `l7-testing-fuzzing-benchmarks.corrected` unescaped literal newline inside Go string `"   \t\n "`; (4) standalone type declarations & `gofmt` cleanliness across all 24 lessons | **Verified** | `python check_strings.py` (0 errors across 119 snippets) & `gofmt` / `go vet` |
| **REM-P3-01** | **P3** | `tests/server_integration_test.go`, `docs/`, `projects/` | Add regression test suite covering all remediated bugs, build static server binary (`bin/go-backend-academy.exe`), and package remediated deliverables into `projects/` | **Verified** | `go build`, `go vet ./...`, `go test -v ./...` |

---

## 2. Detailed Per-Issue Remediation Log

### REM-P0-01 — `go vet ./...` Failure in `tests/server_integration_test.go`
* **Original Problem:** Running `go vet ./...` failed with exit code 1: `tests\server_integration_test.go:58:8: using liveResp before checking for errors`.
* **Root Cause:** `TestLivenessAndReadinessSeparation` called `liveResp, _ := http.Get(ts.URL + "/healthz")` and immediately executed `defer liveResp.Body.Close()` without checking `err != nil`.
* **Files Modified:** `tests/server_integration_test.go`
* **Solution:** Captured `err` from `http.Get(ts.URL + "/healthz")` and checked `if err != nil { t.Fatalf(...) }` prior to `defer liveResp.Body.Close()`.
* **Verification Results:** `go vet ./...` exits 0 with zero warnings.
* **Remaining Limitations:** None.

---

### REM-P0-02 — Database Foreign Key, CHECK, and Primary Key Collision Defects
* **Original Problem:**
  1. `internal/modules/exercises/service.go` hardcoded `ID: "att_" + req.ExerciseID`. A second submission for the same exercise failed with `UNIQUE constraint failed: exercise_attempts.id`.
  2. `POST /api/v1/progress` accepted any arbitrary `status` string (such as `"started"`) and unknown `lesson_id`s, and `POST /api/v1/bookmarks` accepted arbitrary `item_type` values (such as `"quiz"`), violating the SQL schema's `CHECK` and `FOREIGN KEY` constraints when `PRAGMA foreign_keys = ON`.
  3. Passing a non-seeded `user_id` (such as `"usr_test"` in `TestProgressAndBookmarksRoundTrip`) violated the `users(id)` foreign key in SQL mode.
* **Root Cause:** Missing domain input validation in HTTP handlers/store, lack of automatic `users` row provisioning (`ensureUser`), and deterministic collision in `exercise_attempts.id`.
* **Files Modified:**
  * `internal/platform/database/db.go`
  * `internal/modules/exercises/service.go`
  * `internal/modules/lessons/service.go`
  * `internal/platform/http/router.go`
  * `tests/server_integration_test.go`
* **Solution:**
  1. Added `IsValidProgressStatus` (`in_progress` | `completed`), `IsValidBookmarkType` (`lesson` | `case_study` | `db_scenario`), and `lessonsSvc.HasLesson(id)` checks in both `router.go` (returning `400 Bad Request` RFC 9457 Problem JSON) and `db.go`.
  2. Added `Store.ensureUser(ctx, userID)` (`INSERT INTO users ... ON CONFLICT (id) DO NOTHING`) before inserting child records in `user_progress`, `user_notes`, `user_bookmarks`, and `exercise_attempts`.
  3. Added `NormalizeExerciseID` and `nextAttemptID` (`att_<canonicalExID>_<randHex>_<seq>`) in `internal/modules/exercises/service.go`.
* **Verification Results:** Verified via `TestProgressAndBookmarksRoundTripAndValidation` and `TestExerciseVerifyMultipleAttemptsAndCommentStuffingRejection` in `go test -v ./...`.
* **Remaining Limitations:** Pure standard-library mode (`go.mod` without CGo or third-party SQL drivers) uses the validated in-memory store at runtime unless compiled with a registered `database/sql` driver (`sqlite` or `postgres`).

---

### REM-P1-01 — Exercise Grader Comment-Stuffing Bypass & Starter Signature False-Pass
* **Original Problem:**
  1. `grader_test.js` demonstrated that all **24 / 24** exercises passed when the solution tokens were pasted inside a `/* ... */` block comment followed by `func x(){}` (`stuffed: 24`).
  2. Removing `// STEP:` from the starter code without writing any solution passed **3 / 24** exercises (`l2-profiling-pprof-benchmarks`, `l3-validation-openapi-ratelimit`, `l5-db-ecosystem-comparison`, `starterNoStep: 3`) because the checked identifiers (`maxPooledCap`, `ratePerSec`, `burstMax`, `reservedSuperuserConns`, `replicaCount`) were already present in the starter function's parameter signature.
* **Root Cause:** Both `runCurrentExerciseTests()` in `web/index.html` and `VerifySubmission()` in `internal/modules/exercises/service.go` matched substrings against raw source text (including comments and function signatures).
* **Files Modified:**
  * `web/index.html`
  * `internal/modules/exercises/service.go`
  * `tests/server_integration_test.go`
* **Solution:**
  1. Implemented lexical comment stripping (`StripGoComments` in Go and `stripGoCommentsJS` inside `runCurrentExerciseTests` in `web/index.html`) that strips `//...` and `/*...*/` comments while preserving string/raw-string literals.
  2. Tightened all 24 exercise assertions in `runCurrentExerciseTests()` to verify actual implementation expressions (e.g. `bufCap > 0 && bufCap <= maxPooledCap`, `elapsedSec * ratePerSec`, `pgMaxConns - reservedSuperuserConns`, `fromAccountID < toAccountID` + `return toAccountID, fromAccountID`).
* **Verification Results:** Re-running `node grader_test.js` produces:
  * `starterAsIs`: **0 / 24**
  * `starterNoStep`: **0 / 24**
  * `solution`: **24 / 24**
  * `stuffed` (comment-stuffed): **0 / 24**
* **Remaining Limitations:** Browser-side offline verification checks lexical/structural invariants rather than compiling and executing arbitrary Go code inside the browser tab; when running locally with the Go toolchain enabled, the backend Diagnostics Lab runs real `go vet`.

---

### REM-P1-02 — Static Analyzer False Positives (`FP1`, `FP2`) & False Negatives (`FN1`–`FN6`)
* **Original Problem:** `analyzer_fpfn_test.js` exposed 2 false positives and 6 false negatives:
  * `FP1`: Package-level `var idRe = regexp.MustCompile(...)` falsely triggered `GO-PERF-001`.
  * `FP2`: Parameterized `db.Query("SELECT * FROM t WHERE id=$1", id)` + `log.Println(fmt.Sprintf("q %d", id))` falsely triggered `GO-SEC-001`.
  * `FN1`: `db.Exec("DELETE FROM t WHERE id='" + id + "'")` missed `GO-SEC-001`.
  * `FN2`: `rows, _ := db.Query("select 1"); defer f.Close()` missed `GO-DB-001` because unrelated `f.Close()` masked missing `rows.Close()`.
  * `FN3`: Data race `n++` inside `go func()` with `sync.WaitGroup` missed concurrency detection (`GO-CONC-002`).
  * `FN4`: `// ctx not used` in a comment masked `GO-CONC-001` on `go func(){ ch <- 1 }()`.
  * `FN5`: `c := &http.Client{}; c.Get(u)` without `Timeout` missed `GO-SEC-003`.
  * `FN6`: `x, _ := os.Open("a")` discarding error via `_` missed `GO-ERR-002`.
* **Root Cause:** Whole-file `strings.Contains` checks on raw unstripped source code without scope tracking or variable binding inspection.
* **Files Modified:**
  * `internal/modules/diagnostics/analyzer.go`
  * `web/index.html`
  * `seed/sqlite/001_seed_data.sql`
  * `seed/postgres/001_seed_data.sql`
  * `tests/server_integration_test.go`
* **Solution:**
  1. Strip Go comments before running pattern analyzers (`FN4` resolved).
  2. Track function brace depth (`braceDepth > 0` after `func`) before flagging `regexp.MustCompile` (`FP1` resolved).
  3. Match SQL keywords specifically inside `fmt.Sprintf("...SELECT/INSERT/UPDATE/DELETE...")` or SQL string literal `+` concatenation (`FP2` and `FN1` resolved).
  4. Extract the cursor variable assigned from `.Query(` / `.QueryContext(` (e.g., `rows`) and require `<varName>.Close()` (`FN2` resolved).
  5. Added `GO-CONC-002` to detect unsynchronized variable mutations (`++`, `--`, `+=`, `-=`) inside `go func()` bodies when neither `.Lock()` nor `atomic.` is used (`FN3` resolved).
  6. Extended `GO-SEC-003` to inspect `&http.Client{...}` composite literals for missing `Timeout` (`FN5` resolved).
  7. Added `GO-ERR-002` to detect blank-identifier `_` error suppression on fallible stdlib calls (`FN6` resolved).
* **Verification Results:**
  * `node analyzer_fpfn_test.js` output:
    ```text
    FP1 correct pkg-level regexp + func              -> GO-INFO-000@L1
    FP2 parameterized query, Sprintf only for log    -> GO-INFO-000@L1
    FN1 SQL injection via + concatenation            -> GO-SEC-001@L1
    FN2 Query leak masked by unrelated .Close()      -> GO-DB-001@L1
    FN3 data race with WaitGroup                     -> GO-CONC-002@L2
    FN4 goroutine leak, word ctx in a comment        -> GO-CONC-001@L2
    FN5 http.Client{} no timeout                     -> GO-SEC-003@L1
    FN6 unchecked error                              -> GO-ERR-002@L1
    ```
  * `go test -v -run TestAnalyzerFalsePositiveAndFalseNegativeProbes ./...`: **PASS (8/8 subtests)**.
* **Remaining Limitations:** Offline pattern rules operate on single-snippet text/AST and cannot perform cross-package dataflow analysis or prove runtime lock ordering; these limitations remain explicitly disclosed in every `AnalysisReport.StaticAnalysisLimitations`.

---

### REM-P2-01 — Curriculum Go Snippets & Technical Content Accuracy
* **Original Problem:**
  1. `l2-gmp-channels-context-workers.solution` contained a `tab+space` indentation defect (`\t\t firstErr error`) and used `case <-ctx.Done(): break` inside `select` inside `for _, job := range jobs` (in Go, an unlabeled `break` inside `select` only exits the `select`, not the enclosing `for` loop).
  2. `l6-security-auth-owasp.solution` (`ValidateWebhookIP`) parsed `addr, err := netip.ParseAddr(ip)` and checked `addr.IsLoopback() || addr.IsPrivate()` without calling `addr = addr.Unmap()`, allowing IPv4-mapped IPv6 addresses (`::ffff:127.0.0.1`, `::ffff:10.0.0.1`, `::ffff:169.254.169.254`) to bypass the check (per official `net/netip` documentation).
  3. `l7-testing-fuzzing-benchmarks.corrected` contained an unescaped newline inside `"   \t\n "`, causing `gofmt` to fail with `string literal not terminated`.
  4. Four `.corrected` comparison snippets referenced domain types (`Invoice`, `User`, `PaymentGateway`, `slowRPCWithContext`) without declaring them in the snippet, causing standalone `go vet` to report `undefined` identifiers.
* **Root Cause:** Unescaped `\t\n` in JS template generation, missing `addr.Unmap()` call in `net/netip` validation, and unlabeled `break` inside `select`.
* **Files Modified:**
  * `web/index.html`
  * `seed/sqlite/001_seed_data.sql`
  * `seed/postgres/001_seed_data.sql`
* **Solution:**
  1. Replaced unlabeled `break` inside `select` in `l2-gmp-channels-context-workers.solution` with `if ctx.Err() != nil { break }` on the `for` loop + `select { case <-ctx.Done(): case jobCh <- job: }` and normalized indentation with `gofmt`.
  2. Added `addr = addr.Unmap()` in `ValidateWebhookIP` (`l6-security-auth-owasp.solution`).
  3. Properly escaped `"   \\t\\n "` in `l7-testing-fuzzing-benchmarks.corrected`.
  4. Added self-contained type declarations to `.corrected` snippets and formatted all package-level curriculum Go snippets with `gofmt`.
* **Verification Results:** Verified via `check_strings.py` (0 errors across all 119 snippets) and `check_all_go_snippets.py` (`go vet` & `gofmt`).
* **Remaining Limitations:** Intentional anti-pattern snippets (`*.incorrect`) and non-Go snippets (`*.proto`, `Dockerfile`, SQL snippets in case studies) are for educational contrast and are not meant to compile as valid Go packages.
