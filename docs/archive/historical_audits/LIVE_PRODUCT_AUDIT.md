# Go Backend Academy — Live Product & Architecture Audit (`v2.4.0`)

- **Target Application**: `https://academy.entahlah831.uk/` (1Panel VPS + Cloudflare Reverse Proxy + Docker Compose `academy-server` + PostgreSQL 17)
- **Repository Snapshot Audited**: `go-backend-academy` (`v2.4.0`, 36 Lessons across Levels 0–10, 14 Case Studies, 10 DB Scenarios, 11 Diagnostic Rules)
- **Audit Scope & Safety Compliance**:
  - All runtime database and API checks were executed against an isolated local SQLite/Go test instance and non-destructive read/verify API payloads.
  - External automated headless browser probes from cloud sandboxes to `https://academy.entahlah831.uk/` are intercepted by Cloudflare edge bot filtering; therefore, live production verification is separated strictly into (a) **Observed Repository & Local Runtime Facts** and (b) **Reproducible Live VPS Audit Script** (`curl` / Python probe run directly on the VPS host).

---

## 1. Executive Summary: Can an Absolute Beginner Learn Go Backend Here Without External Help?

**Verdict: Not yet for a true zero-programming beginner (Score: 6.8/10 for Absolute Beginners; 8.6/10 for Junior Developers; 9.4/10 for Intermediate-to-Senior Engineers).**

While `v2.4.0` added 12 foundational Stage A–J lessons (expanding the curriculum from 24 to 36 lessons) and hardened exercise verification (`BF-01` through `BF-05`), three critical barriers still prevent an absolute beginner from learning smoothly without external resources:

1. **Severe Visual & Navigation Clutter ("Cockpit Overload")**:
   - The left sidebar exposes **11 top-level navigation items** (`1. Dashboard` through `11. Practice Center`), plus **36 lesson jump links**, plus **6 external documentation links** (53 clickable navigation targets visible at once).
   - On the default Dashboard view, a 3rd column (**Right Diagnostics Inspector Dock**) is open by default, compressing the center viewport and exposing static analysis rules (`GO-SEC-001`, `GO-DB-001`) before the user has even learned what a Go variable or HTTP request is.
   - Inside **View 3: Curriculum Lessons**, a single lesson renders **8 vertically stacked surface cards simultaneously** (Control Bar, Stage & Mastery Banner with inline Quiz, Title + ASCII Diagram, 3-Tier Switcher, **all 12 Engineering Pillars expanded in a 3-column grid**, Anti-Pattern vs Production Code Comparison, Interactive Exercise Runner, and Personal Notes). A learner faces ~2,200–3,000 words of dense technical prose per lesson screen with no guided step-by-step focus.
2. **Shallow Beginner Tier Explanations (~350 Characters per Lesson) & Missing Stage Bridges in Levels 2, 6, 7, 8, 9**:
   - Across all 36 lessons, the `Beginner Overview` tab averages **352 characters (~50–60 words)**—a single short paragraph rather than a step-by-step walkthrough with line-by-line code tracing.
   - While Level 0 (2 Stage A lessons) and Level 1 (6 Stage B lessons) now introduce basic syntax, **Level 2 has zero Stage C beginner lessons** and jumps immediately from `1.0F JSON & Unit Testing` into `2.1 GMP Scheduler, Channels, Select, Mutexes, Context & Worker Pools`.
3. **Static Token Matching Instead of Real Unit Test Execution + Shared Default User State (`usr_local_default`)**:
   - `POST /api/v1/exercises/verify` strips comments (`StripGoComments`) and checks required code tokens from `exercise_test_cases.required_pattern` plus `go vet` AST diagnostics, but **does not compile or run `go test`** against the learner's function. A beginner who writes all required tokens with inverted arithmetic (`subtotal + discountCents` instead of `subtotal - discountCents`) receives `PASSED` without seeing a unit test assertion failure.
   - Every visitor to `https://academy.entahlah831.uk/` currently shares `"user_id": "usr_local_default"` for server-persisted progress, bookmarks, and notes.

---

## 2. Architecture & Endpoint Inventory (Observed Facts)

| Layer / Component | Implementation File(s) | Observed Behavior & Verification Status |
| :--- | :--- | :--- |
| **HTTP Server & Routing** | `cmd/server/main.go`, `internal/platform/httpserver/server.go` | Go 1.22+ `http.ServeMux` with `ReadHeaderTimeout: 5s`, `ReadTimeout: 15s`, `WriteTimeout: 30s`, `IdleTimeout: 60s`, panic recovery, and request logging. |
| **Database Dual-Engine Layer** | `internal/platform/database/db.go`, `content.go`, `migrations.go` | Supports PostgreSQL (`pgx/v5`) and SQLite (`modernc.org/sqlite`) with automatic `$1` to `?` placeholder rewriting and embedded migrations/seeds (`001` + `002`). |
| **Curriculum & Lesson API** | `GET /api/v1/curriculum`, `GET /api/v1/lessons`, `GET /api/v1/lessons/{slug}` | Serves 11 levels and 36 lessons. **Discrepancy found (`P1-DB-002`)**: the 12 Stage A–J lessons in `002_beginner_stages_seed.sql` only populate 1 summary row in `lesson_sections` (~370 chars) compared to 12 full pillars in `web/curriculum-stages.js`. |
| **Exercise Verification API** | `POST /api/v1/exercises/verify` (`internal/modules/exercises/service.go`) | Enforces non-empty code, rejects `// TODO:` / `// STEP:`, strips `//` and `/* */` comments via `StripGoComments`, checks pipe-delimited `required_pattern` tokens from DB, and runs `go vet` when Go toolchain is present. |
| **Disposable SQL Playground API** | `POST /api/v1/sql-playground/execute` (`internal/modules/sqlplayground/service.go`) | Opens an isolated in-memory SQLite connection (`:memory:`), seeds `users`, `orders`, `payments`, `outbox_events`, enforces read-only `SELECT`/`EXPLAIN` guard, 2s timeout, 100-row cap, and returns `EXPLAIN QUERY PLAN`. |
| **Offline Diagnostics API** | `POST /api/v1/diagnostics/analyze` (`internal/modules/diagnostics/analyzer.go`) | Evaluates 11 deterministic heuristic rules (`GO-SEC-001` through `GO-ARCH-001`) + optional `go vet` AST check with explicit `FindingClassification` (`confirmed_diagnostic`, `potential_issue`, `educational_heuristic`). |
| **Learner State APIs** | `/api/v1/progress`, `/api/v1/bookmarks`, `/api/v1/notes` | Persists to SQLite/PostgreSQL, but hardcoded to `usr_local_default` on the frontend (`P0-AUTH-001`). |
