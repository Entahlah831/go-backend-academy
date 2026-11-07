# Go Backend Academy — Technical Content Audit (`TECHNICAL_CONTENT_AUDIT.md`)

**Audit Date:** 2026-11-07
**Scope:** Audit of all 24 existing lessons, 14 real-world case studies, 10 database scenarios, 7 database engine profiles, 5 quizzes, 10 flashcards, 24 exercises, and interactive labs (`web/index.html` and `seed/*.sql`).

---

## 1. Go Code Snippets & Exercises Audit

| Category | Total Audited | Verified Clean (`gofmt` & `go vet`) | Issues / Pedagogical Gaps Found | Action Required |
| :--- | :---: | :---: | :--- | :--- |
| **Lesson `.correctedCode` Snippets** | `24` | `24 / 24` | All 24 compile/format cleanly, including `addr = addr.Unmap()` in `l6-security-auth-owasp` and proper `for`/`select` cancellation in `l2-gmp-channels-context-workers`. However, each lesson only provides **1 incorrect + 1 corrected** snippet instead of the 5 progressive examples required by Part 4 § 8 (Minimal -> Annotated -> Realistic -> Incorrect -> Corrected). | Add **Minimal Working Example**, **Annotated Step-by-Step Example**, and **Realistic Example** alongside the existing Incorrect vs Corrected comparison. |
| **Lesson `.starterCode` & `.solutionCode` Exercises** | `24` | `24 / 24` | Comment-stuffing (`/* ... */`) and signature false-passes are blocked (`0/24` stuffed pass, `24/24` solution pass). However, exercises are only graded in the browser via JS token checks (`runCurrentExerciseTests`), never sent to `POST /api/v1/exercises/verify`, and lessons lack a separate **Guided Practice** task before the **Independent Exercise**. | Connect the frontend exercise runner to `POST /api/v1/exercises/verify` (persisting attempts in SQLite/PostgreSQL) and add a **Guided Practice** walkthrough to every lesson. |
| **Go Playground Templates (`PLAYGROUND_TEMPLATES`)** | `4` | `4 / 4` | The 4 templates (`http_graceful`, `worker_pool`, `tx_retry`, `ssrf_dialer`) are valid Go snippets, but the Playground only runs static rule diagnostics (`analyzeGoCodeOffline`) and does not clearly badge whether code is being statically inspected vs compiled/executed by the host Go toolchain. | Add an explicit execution-mode banner and wire a local sandboxed `go vet` / `go test` check when connected to the Go backend with `ENABLE_LOCAL_GO_TOOLCHAIN=true`. |

---

## 2. SQL, Database Lab & Migrations Content Audit

| Component | Dialect / Scope | Technical Accuracy Status | Findings & Required Improvements |
| :--- | :--- | :--- | :--- |
| **`migrations/postgres/001_initial_schema.up.sql`** | PostgreSQL 17+ | **Valid DDL** | Uses `TIMESTAMPTZ`, `NOW()`, `ON CONFLICT DO NOTHING`. Needs schema extension to store `prerequisites_json`, `learning_objectives_json`, `vocabulary_json`, `guided_practice_json`, and `knowledge_check_json` for the reconstructed curriculum. |
| **`migrations/sqlite/001_initial_schema.up.sql`** | SQLite 3.40+ (WAL) | **Valid DDL (Minor Comment Typo)** | Line 2 header comment erroneously says `PostgreSQL 17+ Normalized Schema`. Needs the same curriculum schema columns as PostgreSQL so both engines stay 100% parity-matched. |
| **SQL Playground (`PLATFORM_DATA.sqlDatasets`)** | 3 Presets (`select_indexed_orders`, `anti_pattern_offset`, `keyset_seek_pagination`) | **Static Simulation Disguised as Executor (`P1`)** | Clicking `Execute SQL & EXPLAIN` in `web/index.html:5243` ignores any edits made by the user in `#sql-pg-editor` and simply displays the preset `rows` and `explainWithIndex` / `explainWithoutIndex` strings! Per Part 1 § 3 ("Never claim a real EXPLAIN ANALYZE result if the query was not executed") and Part 6, we must either: (a) execute read-only sandboxed SQLite queries against an isolated disposable in-memory SQLite connection on the backend (`POST /api/v1/sql-playground/execute` with `EXPLAIN QUERY PLAN`), AND (b) clearly label the PostgreSQL `EXPLAIN (ANALYZE, BUFFERS)` comparison as a recorded reference benchmark with explicit hardware/dataset disclosures. |
| **7 Database Engines × 15 Attributes (`PLATFORM_DATA.dbEngines`)** | PostgreSQL 18, MySQL 8.4, MariaDB 11.4, SQLite 3.40+, MongoDB 8.0, Redis 7.4, ScyllaDB | **Verified Complete** | All 7 engines and all 15 engineering attributes are present and technically accurate (distinguishing PostgreSQL heap + MVCC `xmin`/`xmax` from MySQL InnoDB clustered primary key + undo logs and SQLite WAL single-writer locks). |
| **10 Database Scenarios (`PLATFORM_DATA.dbScenarios`)** | Financial ledger, E-commerce, Auth, Sessions, Analytics, Caching, Inventory, Audit Logs, Event Storage, Offline apps | **Verified Complete** | All 10 scenarios include all 7 engine tabs (`postgresql`, `mysql`, `mariadb`, `sqlite`, `mongodb`, `redis`, `scylladb`). |

---

## 3. Security, Performance & Spec-vs-Runtime Accuracy Audit

1. **Go Spec Guarantees vs `gc` Runtime Implementation Details**:
   - Existing lessons (`1.0`, `1.1`, `1.2`, `2.1`) accurately describe 24-byte slice headers, 16-byte `iface` words, 8-byte struct alignment, and 2KB initial goroutine stacks on 64-bit `gc` (`GOARCH=amd64`/`arm64`), and distinguish them from Go Language Specification guarantees. This distinction must be preserved and explicitly labeled in all new Stage B and Stage F lessons.
2. **PostgreSQL Row-Level Security (RLS) in Case Study #12 (`cs-12-multitenant-saas`)**:
   - Properly includes `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;` and `ALTER TABLE ... FORCE ROW LEVEL SECURITY;` and notes that table owners/superusers bypass RLS unless `FORCE ROW LEVEL SECURITY` and a non-superuser role are used.
3. **SSRF Protection (`l6-security-auth-owasp`)**:
   - Properly uses `net.Dialer.Control` socket-time IP verification with `addr = addr.Unmap()` to prevent DNS rebinding and IPv4-mapped IPv6 (`::ffff:127.0.0.1` / `::ffff:169.254.169.254`) bypasses.
4. **Panic Handling Nuance (Addendum § E)**:
   - Needs an explicit educational callout and lesson section explaining a critical Go `net/http` nuance: **`net/http` (`conn.serve`) has a built-in `recover()` that catches panics on the request handler goroutine and closes the connection without crashing the process, whereas a `panic` inside a child goroutine (`go func() { ... }()`) cannot be caught by HTTP middleware `RecoveryMiddleware` and immediately crashes the entire Go binary!**

---

## 4. Assessments (Quizzes & Flashcards) Audit

- Currently, there are only **5 global quiz questions** (`qz-1` to `qz-5`) and **10 flashcards** across the entire 24-lesson platform.
- None of the individual lessons have their own **Knowledge Check** section.
- Per Part 4 § 14 and Part 5 § 2, every lesson must include a targeted **Knowledge Check** with per-option explanations (why the right answer is right and why each distractor is wrong), and passing the lesson's Knowledge Check + Exercise must feed into the **Lesson Mastery System**.
