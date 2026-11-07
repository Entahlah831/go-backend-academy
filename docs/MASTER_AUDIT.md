# Go Backend Academy — Phase 0 Master Repository & Truthful Audit (`MASTER_AUDIT.md`)

**Audit Date:** 2026-11-07
**Scope:** Complete source-code, configuration, database, frontend, curriculum, and test verification across `c:\Users\12\Downloads\projects\go-backend-academy`
**Execution Phase:** Phase 0 Only (Truthful Discovery & Audit — No Application Source Code Modified)

---

## 1. Executive Summary

We inspected every file in the repository (`go.mod`, `cmd/server/main.go`, `internal/**`, `migrations/**`, `seed/**`, `frontend/**`, `web/**`, `tests/**`, `Dockerfile`, `docker-compose.yml`, `Makefile`, `.env.example`, and `docs/**`) and executed baseline checks on the host machine (`go1.27.1 windows/amd64`, `node v26.1.0`, `sqlite3 3.50.6`).

While the repository has solid HTTP middleware, a deterministic offline static analyzer (`internal/modules/diagnostics/analyzer.go`), a clean Hallmark v2.0.0 `Console` UI in `web/index.html`, and valid SQLite/PostgreSQL schema DDL files, **three fundamental architectural & pedagogical blockers remain**:

1. **Priority #1 Blocker — Database & Persistence Are Silently In-Memory Only (`P0-DB-01` .. `P0-DB-04`)**:
   - `go.mod` contains **zero** database driver dependencies (only `go 1.23.0`). Neither `modernc.org/sqlite` nor `github.com/jackc/pgx/v5/stdlib` is imported anywhere in the Go codebase.
   - `sql.Drivers()` returns `[]` (empty slice) at runtime.
   - In `internal/platform/database/db.go` (`lines 44–75`), `Open()` loops over `sql.Drivers()`. Because `hasDriver` is always `false`, `Open()` **silently skips `sql.Open()` and `db.PingContext()`**, leaves `s.db = nil`, and returns no error—even when `DB_DRIVER=postgres` or `DB_DRIVER=sqlite` is explicitly configured!
   - In `db.go` (`lines 82–90`), `Ping()` returns `nil` when `s.db == nil`, causing `GET /readyz` (`internal/platform/http/router.go:119`) to report `200 OK {"status":"ready","db_driver":"sqlite"}` when **no database connection exists at all**.
   - Even if a driver were registered, `ApplySQLFile()` (`internal/platform/database/migrator.go`) is **never called anywhere in the codebase** (0 references across all `.go` files), so migrations and seeds are never executed by the Go server on startup.
   - All learner data (progress, bookmarks, notes, exercise attempts) is stored only in volatile Go `map`s inside `Store` and is **100% lost on server restart**.

2. **Priority #2 Blocker — Split-Brain Frontend Architecture (`P0-FE-01` .. `P0-FE-04`)**:
   - The repository contains two completely separate frontends:
     1. `web/index.html` (`557,770 bytes`, `6,086 lines`): A monolithic HTML+CSS+Vanilla JS application containing all `PLATFORM_DATA` and all 11 interactive views.
     2. `frontend/` (Svelte 5 + TypeScript + Vite): An incomplete 38-line shell (`frontend/src/App.svelte`) where 10 out of 11 navigation views hit an `{:else}` branch rendering a placeholder box: `Active Module View: {activeView}`.
   - Running `npm run build` in `frontend/` (`vite.config.ts` sets `outDir: '../web'`) **overwrites `web/index.html` with the 38-line placeholder Svelte app**, destroying 95% of the application!
   - `web/index.html` is also largely disconnected from the Go backend REST API:
     - `GET /api/v1/curriculum`, `GET /api/v1/lessons`, `GET /api/v1/quizzes`, `GET /api/v1/case-studies`, `POST /api/v1/recommendations`, `GET /api/v1/progress`, `GET /api/v1/bookmarks`, `POST /api/v1/bookmarks`, and `GET /api/v1/notes` are **never called by `web/index.html`**.
     - `POST /api/v1/progress` (`line 5943`) and `POST /api/v1/notes` (`line 6070`) are gated behind `if (window.location && window.location.port === '8080')`, which silently stops working if the user runs the server on any other `PORT` or behind Caddy/Nginx on port `80`/`443`.
     - Bookmark toggling (`line 5932`) never calls `POST /api/v1/bookmarks`, and exercise verification (`line 5030`) never calls `POST /api/v1/exercises/verify`.

3. **Priority #3 Blocker — Curriculum Is Not Beginner-Friendly and Lacks a True Zero-to-Production Pathway (`P0-CURR-01` .. `P0-CURR-04`)**:
   - The curriculum starts at **Lesson 0.1 (`l0-backend-http-lifecycle`)**, which immediately throws complete beginners into `UDP/53`, `TCP 3-way handshake`, `TLS 1.3 ClientHello + KeyShare`, `epoll_ctl(EPOLL_CTL_ADD/MOD)`, `syscall.EAGAIN`, `runtime.gopark`, `http.MaxBytesReader`, and `Slowloris DoS`—before teaching what a backend is, how to use a terminal, how to run `go run main.go`, or what `package main`, `func`, `struct`, `slice`, `pointer`, or `error` mean!
   - All **24 Go Programming Fundamentals** topics (variables, types, zero values, control flow, loops, functions, multiple returns, pointers, structs, methods, slices, maps, interfaces, errors, packages, JSON, file I/O, basic testing) are either completely missing or compressed into 3 dense intermediate/advanced lessons (`1.0`, `1.1`, `1.2`) that immediately jump to 64-bit struct alignment padding, `runtime.hmap` buckets, compiler escape analysis (`-gcflags="-m"`), and `runtime.iface` `itab` pointer internals.
   - SQL and database fundamentals (`CREATE TABLE`, `SELECT`, `WHERE`, `JOIN`, `GROUP BY`, primary/foreign keys, basic normalization, basic `database/sql` CRUD) are completely skipped; Level 4 (`4.1`) starts directly at `PostgreSQL xmin/xmax MVCC tuples, Heap-Only Tuples (HOT), Write Skew, and ScyllaDB LSM-Trees`.
   - Lessons lack explicit prerequisite declarations, vocabulary tables, step-by-step code walkthroughs, guided practice vs independent exercises, and per-lesson knowledge checks.

---

## 2. Verification of the Critical Remediation Addendum (A – H)

### A. Database Driver and Startup Integrity

| Requirement | Actual Status in Codebase | Source Code Evidence |
| :--- | :--- | :--- |
| 1. Register actual PostgreSQL and SQLite drivers | **NOT IMPLEMENTED (`FAIL`)** | `go.mod` (`lines 1–3`) has 0 `require` directives; no `_ "modernc.org/sqlite"` or `_ "github.com/jackc/pgx/v5/stdlib"` exists anywhere in `internal/` or `cmd/`. |
| 2. Verify `sql.Drivers()` reports expected drivers | **NOT IMPLEMENTED (`FAIL`)** | `sql.Drivers()` returns `[]` at runtime. |
| 3. Verify selected DB driver matches `DB_DRIVER` | **PARTIAL** | `config.go:76` checks `sqlite`, `postgres`, or `memory`, but `db.go:45` ignores the driver if it is not registered in `sql.Drivers()`. |
| 4. Never silently fall back to in-memory storage when PostgreSQL or SQLite is configured | **VIOLATED (`FAIL`)** | `internal/platform/database/db.go:44–75`: When `hasDriver == false`, `Open()` silently returns an in-memory `Store` with `s.db = nil` instead of returning an error. |
| 5. Fail startup when requested persistent DB cannot be initialized | **VIOLATED (`FAIL`)** | Because `hasDriver` is `false`, setting `DB_DRIVER=postgres` with an invalid or unreachable `POSTGRES_DSN` still boots the server and logs `db_driver=postgres` while running in-memory! |
| 6. Real connection validation using `PingContext` | **BYPASSED (`FAIL`)** | `db.go:68` only calls `db.PingContext` inside `if hasDriver { ... }`, which is dead code because `hasDriver` is always `false`. |
| 7. Database initialization, migration execution, graceful shutdown | **NOT WIRED (`FAIL`)** | `internal/platform/database/migrator.go` defines `ApplySQLFile()`, but it has **0 callers** in the entire repository. |
| 8. Make `/readyz` reflect actual database readiness | **VIOLATED (`FAIL`)** | `db.go:82–90`: `Ping()` returns `nil` when `s.db == nil`. Therefore `GET /readyz` (`router.go:119`) returns `200 OK` even when `DB_DRIVER=postgres` has no database connection. |
| 9. Test that data persists after application restart | **FAILS (`FAIL`)** | All writes go to in-memory Go maps (`s.progress`, `s.bookmarks`, `s.notes`, `s.attempts`) and vanish when the process exits. |
| 10. Expose in-memory mode as an explicit mode with clear limitations | **PARTIAL** | `DB_DRIVER=memory` is allowed in `config.go:76`, but `sqlite` and `postgres` also silently run in memory without warning. |

### B. Frontend and Static Asset Integration

| Requirement | Actual Status in Codebase | Source Code Evidence |
| :--- | :--- | :--- |
| 1. Establish one authoritative frontend source | **VIOLATED (`FAIL`)** | Dual sources exist: `web/index.html` (6,086 lines) and `frontend/src/` (Svelte skeleton). |
| 2. Complete Svelte + TypeScript application (no placeholder views) | **VIOLATED (`FAIL`)** | `frontend/src/App.svelte:33–37` renders `Active Module View: {activeView}` for 10 of the 11 views (`dashboard`, `roadmap`, `curriculum`, `dblab`, `apilab`, `playground`, `concurrencylab`, `archlab`, `projects`, `practice`). |
| 3. Ensure Vite builds all assets into configured output dir | **BROKEN (`FAIL`)** | `frontend/vite.config.ts:7` outputs to `../web`, which overwrites the working `web/index.html` with the incomplete Svelte skeleton. Also `frontend/node_modules` is not installed. |
| 4. Verify Go server serves `index.html`, JS, CSS, fonts, images | **PARTIAL (`FAIL`)** | `internal/platform/http/router.go:328–348` (`handleStaticFrontend`) only serves `/`, `/index.html`, `/tokens.css`, and `/base.css`. Any `/assets/*.js` or `/assets/*.css` generated by Vite returns `404 Resource Not Found` (`application/problem+json`)! |
| 5. Correct SPA fallback without returning `index.html` for missing JS/CSS/API | **PARTIAL** | Currently returns 404 JSON for everything except `/`, `/index.html`, `/tokens.css`, `/base.css`, which breaks deep-linked SPA routes (e.g., `/curriculum` or `/labs/sql`). |
| 6. Test direct navigation to nested frontend routes | **NOT IMPLEMENTED (`FAIL`)** | Navigating to `/curriculum` returns HTTP 404 JSON instead of serving the SPA shell, and the frontend does not sync URL paths/hashes with view state. |
| 7. Frontend API calls use correct backend base URL | **VIOLATED (`FAIL`)** | `web/index.html:5622, 5943, 6070` hardcodes `window.location.port === '8080'`, breaking API calls on any other port or reverse proxy. |
| 8. Verify all navigation items and buttons perform real actions | **PARTIAL** | In `web/index.html`, UI buttons work locally, but bookmarks and exercise verifications never call the backend API, and backend data is never loaded on startup. |

### C. Database Migrations and Seed Integrity

| Requirement | Actual Status in Codebase | Source Code Evidence |
| :--- | :--- | :--- |
| 1. Audit migration and seed scripts separately | **VERIFIED (`PASS`)** | Inspected `migrations/postgres/*`, `migrations/sqlite/*`, `seed/postgres/*`, `seed/sqlite/*`. |
| 2. PostgreSQL SQL compatible with PostgreSQL | **VERIFIED (`PASS`)** | Uses `TIMESTAMPTZ`, `NOW()`, `ON CONFLICT DO NOTHING`. Zero `INSERT OR IGNORE`. |
| 3. SQLite SQL compatible with SQLite driver | **MINOR DEFECT (`P2`)** | `migrations/sqlite/001_initial_schema.up.sql:2` has a copy-pasted header comment saying `PostgreSQL 17+ Normalized Schema`, though its DDL uses `TIMESTAMP` and `CURRENT_TIMESTAMP` and executes cleanly in `sqlite3 3.50.6` (`levels=11, lessons=24, exercises=24, case_studies=14, db_scenarios=10`). |
| 4. No `INSERT OR IGNORE` in PostgreSQL scripts | **VERIFIED (`PASS`)** | Confirmed 0 occurrences in `migrations/postgres/` and `seed/postgres/`. |
| 5. Explicit DB-specific migrations and seeds | **VERIFIED (`PASS`)** | Separate directories exist for `postgres` and `sqlite`. |
| 6. Foreign keys, indexes, constraints, relationships | **PARTIAL (`P1`)** | Schema has 20 tables with FKs and CHECK constraints, but `db.go` only touches 5 tables (`users`, `user_progress`, `user_notes`, `user_bookmarks`, `exercise_attempts`). The other **15 seeded tables** (`curriculum_levels`, `modules`, `lessons`, `lesson_sections`, `lesson_references`, `exercises`, `exercise_test_cases`, `quizzes`, `quiz_questions`, `case_studies`, `case_study_steps`, `database_scenarios`, `diagnostic_rules`, etc.) are **never queried by the Go backend**! Instead, `internal/modules/curriculum/service.go`, `lessons/service.go`, `assessments/service.go`, and `case_studies/service.go` return hardcoded 1-line summary structs in Go memory. |
| 7. Migration version tracking | **NOT AUTOMATED (`FAIL`)** | `schema_migrations` table exists in SQL, but `migrator.go` does not check `schema_migrations` before applying migrations or record applied versions. |
| 8–10. Test clean DB init, upgrades, rollbacks against actual DB | **NOT WIRED IN GO (`FAIL`)** | `001_initial_schema.down.sql` exists for both engines, but no Go test executes `up.sql` -> `seed.sql` -> `down.sql` -> `up.sql` against a live SQLite/PostgreSQL `*sql.DB`. |

### D. Docker and Data Safety

| Requirement | Actual Status in Codebase | Source Code Evidence |
| :--- | :--- | :--- |
| 1–10. Docker Compose volumes, Redis profile, localhost port binding, `docker-down` safety | **MOSTLY VERIFIED (`PASS` with 1 P1 issue)** | `docker-compose.yml` binds ports to `127.0.0.1`, puts Redis behind `profiles: ["cache"]`, mounts `pgdata`, and `Makefile` `docker-down` runs `docker compose down` (without `-v`). **However (`P1-DOCKER-01`)**: `Dockerfile` builds the Go binary with `CGO_ENABLED=0` and copies `migrations/` and `seed/`, yet because `go.mod` has no `pgx` driver and `main.go` never runs migrations, the `academy-server` container in `docker-compose.yml` (`DB_DRIVER=postgres`) actually runs in-memory and ignores the `postgres` container! |

### E. HTTP API Security and Reliability

| Requirement | Actual Status in Codebase | Source Code Evidence |
| :--- | :--- | :--- |
| 1. Request body size limits (`MaxBytesReader`) | **IMPLEMENTED (`PASS`)** | Used on all `POST` handlers in `router.go` (`lines 142, 171, 188, 214, 261, 301`). |
| 2–3. Strict JSON decoding & rejection of trailing JSON / unknown fields | **INCONSISTENT (`FAIL - P1`)** | Only `handleDiagnosticsAnalyze` (`router.go:178`) calls `dec.DisallowUnknownFields()`. The other 5 POST handlers (`handleVerifyExercise`, `handleRecommendations`, `handleSaveProgress`, `handleSaveBookmark`, `handleSaveNote`) do **not** call `DisallowUnknownFields()`, and **none** of the 6 POST handlers check for trailing JSON tokens after the first JSON object (`dec.Decode(&extra) != io.EOF`). |
| 4–15. Request ID, Panic Recovery, Logging, CORS, Rate Limiting, Timeouts, Graceful Shutdown | **IMPLEMENTED (`PASS` with minor gaps)** | Implemented in `middleware.go` and `main.go`. Note: `LoggingMiddleware` (`middleware.go:52`) does not wrap `http.ResponseWriter` to capture the HTTP status code or bytes written. |

### F. Configuration and Dependencies

| Requirement | Actual Status in Codebase | Source Code Evidence |
| :--- | :--- | :--- |
| 1–2. Validate all env vars; invalid int/duration/enum/bool must return error instead of silent fallback | **VIOLATED (`FAIL - P1`)** | `internal/config/config.go:92–102`: `getEnvInt()` silently returns `fallback` when `strconv.Atoi(v)` fails (`PORT=abc` silently becomes `8080` instead of returning a validation error!). Similarly, `DB_MAX_OPEN_CONNS=-5`, `READ_TIMEOUT_SEC=0`, `RATE_LIMIT_RPS=-10`, or `ENABLE_LOCAL_GO_TOOLCHAIN=maybe` are not validated, and `DB_DRIVER=postgres` does not validate that `POSTGRES_DSN` is non-empty. |
| 7. Generate and commit `go.sum` | **MISSING (`FAIL - P0`)** | No `go.sum` exists because external drivers (`modernc.org/sqlite`, `github.com/jackc/pgx/v5`) have not been added yet. |

---

## 3. Prioritized Findings & Action Plan (P0 → P1 → P2)

### P0 — Critical Blockers (Must Be Resolved First)

1. **`P0-DB-01`: Register Real SQLite (`modernc.org/sqlite`) and PostgreSQL (`github.com/jackc/pgx/v5/stdlib`) Drivers & Fail Fast on Connection Errors**
   - Add pure-Go `modernc.org/sqlite` (CGo-free, works with `CGO_ENABLED=0`) and `github.com/jackc/pgx/v5` to `go.mod` and `go.sum`.
   - In `database.Open()`, require `DB_DRIVER` (`sqlite`, `postgres`, or explicit `memory`). When `sqlite` or `postgres` is selected, open the real driver, run `db.PingContext()`, and **fail startup immediately** if the connection or ping fails (never silently fall back to memory).
   - In `Store.Ping()`, if `driverName != "memory"` and `s.db == nil`, return an error so `/readyz` returns `503 Service Unavailable`.
2. **`P0-DB-02`: Automatic Versioned Migration & Seed Runner on Startup + Full SQL Repository Queries**
   - Wire `internal/platform/database/migrator.go` into `database.Open()` so that when `sqlite` or `postgres` is active, it tracks versions in `schema_migrations`, applies `001_initial_schema.up.sql` and `001_seed_data.sql` idempotently, and queries curriculum, lessons, exercises, quizzes, case studies, database scenarios, and user state (`user_progress`, `user_bookmarks`, `user_notes`, `exercise_attempts`, `quiz_attempts`) from the real SQL database.
3. **`P0-FE-01`: Unify Frontend into One Authoritative Integrated Application**
   - Eliminate the split-brain between `frontend/src/` and `web/index.html`. Migrate all 11 views, data models, interactive labs, and Hallmark v2.0.0 `Console` styling into the authoritative `frontend/src/` application, configure Vite to build cleanly into `web/`, and update `router.go` (`handleStaticFrontend`) to serve all static assets (`/assets/*`, CSS, JS) and proper SPA route fallbacks (returning `404` for missing asset extensions `.js`, `.css`, `.png`, `.svg`, `/api/*` and serving `index.html` for SPA navigation routes).
   - Connect the frontend to all backend REST endpoints (`/api/v1/curriculum`, `/api/v1/lessons`, `/api/v1/exercises/verify`, `/api/v1/quizzes`, `/api/v1/case-studies`, `/api/v1/diagnostics/analyze`, `/api/v1/recommendations`, `/api/v1/progress`, `/api/v1/bookmarks`, `/api/v1/notes`) using relative `/api/v1/...` paths (no hardcoded port `8080`), with an explicit, badged Offline Fallback mode when the backend is unreachable.
4. **`P0-CURR-01`: Restructure Curriculum for True Zero-to-Production Learning (Stages A → J)**
   - Reorganize the curriculum so a complete beginner can start from Stage A (Developer & Terminal Orientation) and Stage B (24 Step-by-Step Go Programming Fundamentals lessons) before progressing to Networking (Stage C), Building the First Go HTTP API (Stage D), SQL & Database Foundations from `CREATE TABLE`/`SELECT` to `database/sql` (Stage E), Runtime & Concurrency Internals (Stage F), Production Security/Testing/Observability (Stage G), Architecture & Distributed Systems (Stage H), Deployment & Operations (Stage I), and 8 Progressive Capstone Projects (Stage J).
   - Preserve 100% of the existing 24 intermediate/advanced lessons and 14 case studies by placing them into their proper progressive stages (Stages C–I) with explicit prerequisite graphs and standardized 16-part lesson pedagogy.

### P1 — Functional, Security & Configuration Issues

1. **`P1-CFG-01`: Strict Environment Variable Validation (`internal/config/config.go`)**
   - Reject invalid integers, negative/zero timeouts, invalid booleans, invalid pool settings (`DBMaxIdleConns > DBMaxOpenConns`), and empty `POSTGRES_DSN` when `DB_DRIVER=postgres`.
2. **`P1-HTTP-01`: Strict JSON Decoding Helper Across All POST Endpoints (`internal/platform/http/router.go`)**
   - Enforce `MaxBytesReader`, `dec.DisallowUnknownFields()`, and single-JSON-value verification (`dec.Decode(&struct{}{}) == io.EOF`) across every `POST` endpoint, and log HTTP response status codes in `LoggingMiddleware`.
3. **`P1-MASTERY-01`: Real Mastery & Prerequisite Progression System**
   - Track lesson reading completion, knowledge-check quiz pass, and exercise verification pass separately so a lesson is only marked **Mastered** when its prerequisites, exercise, and knowledge check are completed.

### P2 — Pedagogical, Lab Transparency & UX Enhancements

1. **`P2-LAB-01`: Explicit Execution vs Simulation Disclosures on All 6 Interactive Labs**
   - Ensure every lab displays its 6 required disclosures (What is simulated/executed, What inputs change, What happens on change, Why output changes, Limitations, Related Lesson link).
2. **`P2-PEDAGOGY-01`: Standardized 16-Section Lesson Template with Progressive Disclosure**
   - Structure every lesson with Introduction, Prerequisites, Measurable Learning Objectives, Vocabulary Table, Beginner Explanation (with analogy limits), Mental Model Diagram, Step-by-Step Code Walkthrough, 5 Code Examples (Minimal, Annotated, Realistic, Incorrect, Corrected), Common Mistakes, Collapsible 12-Pillar Trade-Off Analysis, Real-World Application, Guided Practice, Independent Exercise, Knowledge Check Quiz, Summary, and Verified References.
