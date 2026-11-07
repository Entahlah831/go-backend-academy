# Go Backend Academy — Interactive Lab & Sandbox Red-Team Audit

All 5 interactive laboratories + the Lesson Exercise Runner were audited against empty inputs, malformed inputs, valid inputs, boundary values, and truthfulness of execution claims.

---

## 1. Curriculum Exercise Runner (`#view-curriculum` + `POST /api/v1/exercises/verify`)

- **Test 1 — Empty Code (`""` or whitespace)**:
  - **Observed**: Rejected (`FAILED`) on both client and server (`Submission is empty`).
- **Test 2 — Unmodified Starter Code (`// STEP:` or `// TODO:` present)**:
  - **Observed**: Rejected (`FAILED`) with message instructing the learner to replace the `// STEP:` placeholder.
- **Test 3 — Adversarial Bypass (`// STEP:` removed + required tokens pasted inside `//` or `/* */` comments)**:
  - **Observed**: Rejected (`FAILED`) in `v2.4.0`. Both `StripGoComments` (Go backend) and `stripGoCommentsJS` (`web/app-bridge.js`) strip line and block comments while preserving string literals before checking required tokens, and the backend merges `ExerciseRequiredPatterns` from SQLite/PostgreSQL.
- **Test 4 — Semantically Wrong Code Containing All Required Tokens (`P1-LAB-001`)**:
  - **Reproduction**: In `ex-l1-stage-b-variables-types-zerovalues` (`ComputeInvoiceCents`), submit code that contains `unitPriceCents <= 0`, `discountCents > subtotal`, and `subtotal - discountCents` inside an unreachable `if false { _ = subtotal - discountCents }` block while returning `999999`.
  - **Observed**: **Passes (`PASSED`)** because `VerifySubmission` in `internal/modules/exercises/service.go` performs token + `go vet` AST inspection rather than compiling and running unit test cases (`go test`) against `ComputeInvoiceCents`.
  - **Required Fix**: Add a sandboxed `go test` harness (with a fallback disclosure banner when `go` toolchain is unavailable or when running in static-verification mode) so actual unit test assertions validate function return values.

---

## 2. Go Code Playground (`#view-playground`)

- **Test 1 — Empty / Malformed / Valid Snippets**:
  - **Observed**: The Go Code Playground uses a pre-built template selector (`worker-pool`, `http-middleware`, `sql-tx`, `singleflight`) and runs deterministic static inspection + pre-recorded trace output for the templates, plus sends custom edits to the Diagnostics analyzer.
- **Truthfulness Issue (`P2-LAB-002`)**:
  - While the UI badge says `Sandbox`, editing a `fmt.Println("custom string")` inside a template does not execute a live Go binary to print `"custom string"` in the console output—it displays the template's reference trace and static diagnostic findings. The UI must clearly label the output pane as **Reference Execution Trace + Live Static AST Diagnostics** (or wire a sandboxed `go run` / `go test` endpoint).

---

## 3. Database & SQL Lab (`#view-dblab` + `POST /api/v1/sql-playground/execute`)

- **Test 1 — Valid `SELECT` Queries & `EXPLAIN` Toggle**:
  - **Observed**: When connected to the Go backend (`v2.4.0`), `web/app-bridge.js` sends the query to `POST /api/v1/sql-playground/execute`, which creates an isolated `:memory:` SQLite database seeded with `users`, `orders`, `payments`, and `outbox_events`, executes the `SELECT`, and runs `EXPLAIN QUERY PLAN`.
- **Test 2 — Destructive / Mutation Queries (`DROP TABLE users;`, `DELETE FROM orders;`, `PRAGMA`, multi-statement `;`)**:
  - **Observed**: Properly rejected with `HTTP 400 Bad Request` by `isReadOnlySelect(query)` in `internal/modules/sqlplayground/service.go`.
- **Test 3 — Index Toggle (`Simulate Composite Index` checkbox) Discrepancy (`P1-LAB-003`)**:
  - **Reproduction**: Toggle `#sql-pg-index-toggle` on/off in the browser while running against the live backend (`POST /api/v1/sql-playground/execute`).
  - **Observed**: `internal/modules/sqlplayground/service.go` always creates `idx_orders_user_status_created` unconditionally when seeding the `:memory:` SQLite instance (`CREATE INDEX idx_orders_user_status_created ON orders(user_id, status, created_at DESC)`), ignoring whether the user toggled the index checkbox ON or OFF in the UI!
  - **Required Fix**: Pass `"use_index": Boolean(indexToggle.checked)` in the `POST /api/v1/sql-playground/execute` request payload and only create `idx_orders_user_status_created` in the `:memory:` SQLite sandbox when `UseIndex == true` so the live SQLite `EXPLAIN QUERY PLAN` genuinely switches between `SCAN orders` (without index) and `SEARCH orders USING INDEX idx_orders_user_status_created` (with index)!

---

## 4. API & HTTP Simulator (`#view-apilab`) & Concurrency Lab (`#view-concurrencylab`)

- **API Simulator**: Interactive state-machine simulation testing combinations of HTTP Method (`GET`/`POST`/`DELETE`), Auth Token (`valid`/`expired`/`missing`), Payload Size (`2KB`/`5MB`), and Rate Limit state. Clearly works as an educational state simulator, though it should display a subtle badge clarifying `Deterministic Protocol State Simulator`.
- **Concurrency Lab**: Interactive parameter simulator for Worker Count (`1` to `64`), Channel Buffer Size, and Workload Type. Handles edge inputs safely via bounded `<select>` and range controls.

---

## 5. Offline Code Review & Diagnostics Lab (`#view-diagnostics` + `POST /api/v1/diagnostics/analyze`)

- **Test 1 — Vulnerable Code (`BadHandler` with `io.ReadAll`, `fmt.Sprintf` SQLi, `panic(err)`, uncoordinated `go func()`, `http.Get`)**:
  - **Observed**: Detects `GO-HTTP-002`, `GO-SEC-001`, `GO-DB-001`, `GO-ERR-001`, `GO-CONC-001`, and `GO-NET-001` with line numbers, severity, classification (`educational_heuristic` vs `confirmed_diagnostic`), root-cause explanation, and suggested fix.
- **Test 2 — Clean Code (`GetUserEmail` with `QueryRowContext` + `$1` + `%w`)**:
  - **Observed**: Returns 0 findings (`ClassificationNoFindingDetected`).
- **Test 3 — Commented-Out Vulnerable Code**:
  - **Observed**: Both frontend `stripComments` and backend `StripGoComments` strip commented code first so commented-out `fmt.Sprintf("SELECT ...")` does not trigger false positives.
