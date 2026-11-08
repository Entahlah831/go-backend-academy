# Go Backend Academy — Changelog (`CHANGELOG.md`)

All notable changes to the Go Backend Academy project are documented in this file.

---

## [v2.6.0] — 2026-11-08 (Security Hardening, Cookie Sessions, 41 AST Graders & Diagnostics Precision)

### Security & Architecture (P0 / P1)
- **HttpOnly Cookie Session Lifecycle (P0-1, P1-6)** (`internal/platform/http/router.go`, `internal/platform/database/db.go`, `web/app-bridge.js`):
  - User identity is strictly derived server-side from HttpOnly `gba_session` cookie; client query parameters and request bodies can no longer inject or spoof arbitrary `user_id`.
  - Sessions store SHA-256 token hashes with UTC timestamps; hourly background ticker purges expired sessions (`PurgeExpiredSessions`).
  - Automatic `Secure` cookie flag negotiation based on TLS or trusted reverse proxy `X-Forwarded-Proto: https`.
  - Added atomic migration endpoint `POST /api/v1/session/claim-legacy` seamlessly transferring legacy client `localStorage` progress to authenticated session.
- **AST Grader Scoping & Anti-Bypass (P0-2, P0-3)** (`internal/modules/exercises/ast_verifier.go`, `content/exercises.json`, `seed/sqlite/`, `seed/postgres/`):
  - Scoped `MustCall` strictly to target function body, rejecting dead calls placed in outer scope.
  - String literals are blanked during Go token checks, defeating fake string stuffing.
  - Populated all 41 AST rules in `exercise_rules` and all 41 behavioral test suites in `exercise_tests`, verified with zero drift across SQLite and PostgreSQL seeds.
- **Precise Diagnostics & Line Numbers (P1-7)** (`internal/modules/diagnostics/`):
  - Fixed line number reporting to point to exact AST node line.
  - Scoped `defer rows.Close()` to enclosing function declaration to eliminate cross-function false positives.
  - Added `GO-SEC-007` (hardcoded secret in string literal/constant) and `GO-HTTP-001` (hardcoded network port).
- **Curriculum & Quiz Completion (P1-2, P1-3)** (`content/quizzes.json`, `content/curriculum.json`):
  - Every curriculum level now has >= 3 comprehensive multiple-choice quiz questions with detailed explanations.
  - Aligned curriculum display numbering (`1.1`, `1.2`, `1.3`) with canonical section headings.
- **Repository & Container Hygiene (P2)**:
  - Untracked binary `bin/go-backend-academy.exe` from git, reducing repository footprint.
  - Pinned Docker builder to `golang:1.24-alpine` and updated default `TRUSTED_PROXY_CIDRS` to localhost `127.0.0.1/32,::1/128`.

---

## [v2.5.0] — 2026-11-08 (Content Pipeline & Path Traversal Mitigations)

### Fixed
- **Static Handler Path Traversal (F-05)**: Rejected dotfile segments in `handleStaticFrontend` to protect sensitive files.
- **Content Single Source of Truth**: Added `tools/gen-content` CLI with SHA-256 `manifest.json` verification.
- **Telemetry Honesty (F-01)**: Replaced fake 12ms execution latency and simulated test output with honest AST invariant checks.

---

## [v2.3.0] — 2026-11-07 (Master Rework: Real SQL Persistence, `.env` Port/Access Config, Stages A–J Curriculum & Full API Integration)

### Added
- **Native `.env` Loader & Dynamic Database Port/Access Configuration** (`internal/config/dotenv.go`, `internal/config/config.go`, `.env.example`, `docker-compose.yml`):
  - Server automatically loads `.env` at startup while respecting OS environment overrides.
  - Added configurable `HOST`, `PORT`, `SQLITE_PATH`, `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `POSTGRES_SSLMODE`, `DB_CONNECT_TIMEOUT_SEC`, `DB_AUTO_MIGRATE`, and `DB_AUTO_SEED`.
  - Strict validation rejects malformed integer/boolean environment variables instead of silently falling back to defaults.
- **Real SQLite & PostgreSQL Drivers, Embedded Versioned Migrations & Idempotent Seeding** (`internal/platform/database/db.go`, `migrator.go`, `content.go`, `migrations/embed.go`, `seed/embed.go`):
  - Registered `modernc.org/sqlite` (pure Go, CGO-free) and `github.com/jackc/pgx/v5/stdlib`.
  - Eliminated silent in-memory fallback when `DB_DRIVER=sqlite` or `DB_DRIVER=postgres` fails; startup now fails fast on unreachable databases, and `GET /readyz` executes a real `db.PingContext()` round-trip.
  - Added CLI migration flags (`-migrate up|down|status|seed`) and full SQL repository queries across all 20 schema tables.
- **Isolated Read-Only SQLite Sandbox for SQL Playground** (`internal/modules/sql_playground/sandbox.go`, `POST /api/v1/sql-playground/execute`):
  - Executes learner `SELECT`, `WITH`, and `EXPLAIN` queries against an isolated in-memory SQLite database with real result rows and `EXPLAIN QUERY PLAN`, rejecting mutating/DDL statements.
- **Stages A–J Zero-to-Production Curriculum Expansion (36 Lessons)** (`seed/sqlite/002_beginner_stages_seed.sql`, `seed/postgres/002_beginner_stages_seed.sql`, `web/curriculum-stages.js`, `web/app-bridge.js`):
  - Added 12 beginner & bridge lessons (`0.0A`, `0.0B`, `1.0A`–`1.0F`, `3.0`, `4.0`, `5.0`, `10.3`) so complete beginners learn servers, ports, terminal, Git, Go variables/types/zero-values, loops/functions, slices/maps, structs/pointers, interfaces/errors, JSON/testing, basic `net/http`, SQL from scratch, and `database/sql` before advanced runtime/MVCC internals.
  - Added 16-part pedagogical blueprint metadata (Stage badge, Prerequisites with jump links, Learning Objectives, Key Vocabulary, Guided Practice, Per-Lesson Knowledge Check) and **Honest Mastery State** (`Unlocked` → `Read` → `Practiced` → `Verified` → `Mastered`).
- **Port-Agnostic Full Frontend-Backend API Integration** (`web/index.html`, `web/app-bridge.js`, `frontend/src/App.svelte`, `frontend/src/services/api.ts`, `frontend/vite.config.ts`):
  - Removed hardcoded `window.location.port === '8080'` checks so the frontend connects to `/api/v1/*` and `/readyz` on any `.env` port.
  - Configured `frontend/vite.config.ts` to build into `../web/svelte-dist` so `vite build` never overwrites `web/index.html`.

---

## [v2.2.0] — 2026-11-07 (Hallmark v2.0.0 Console UI/UX Redesign)

### Added
- Centralized project documentation structure in `docs/` (`PROJECT_CONTEXT.md`, `PROJECT_OVERVIEW.md`, `PRODUCT_REQUIREMENTS.md`, `DESIGN_REQUIREMENTS.md`, `CURRICULUM_OVERVIEW.md`, `UI_UX_AUDIT.md`, `REDESIGN_PLAN.md`, `REDESIGN_REPORT.md`, `REDESIGN_TEST_RESULTS.md`, `CHANGELOG.md`).
- Project-level `AGENTS.md` instructions enforcing technical accuracy, offline-first architecture (`AI_PROVIDER=none`), route preservation, and Hallmark v2.0.0 design standards.
- Complete Hallmark v2.0.0 skill installation in `.agents/skills/hallmark/` and build history in `.hallmark/log.json`.
- Tokenized Console design system (`web/tokens.css`, `web/base.css`, and inline tokens in `web/index.html`) supporting both Dark Mode (`:root`) and Light Mode (`html[data-mode="light"]`).
- Progressive disclosure segmented filter (`All 12 Pillars`, `Core Mechanics (1 to 4)`, `Scope & Trade-Offs (5 to 8)`, `Production Impact (9 to 12)`) for the 12-Pillar Engineering Decision Analysis in Curriculum Lessons.
- `Previous Lesson` (`#btn-prev-lesson`) and `Next Lesson` (`#btn-next-lesson`) sequential navigation buttons in the Curriculum Lesson view.

### Changed
- Redesigned `web/index.html` and synchronized `frontend/src/` components under the Hallmark v2.0.0 `Console` theme (`Host Grotesk` + `Atkinson Hyperlegible Mono`), eliminating the runtime Tailwind CDN script (`https://cdn.tailwindcss.com/3.4.17`) and resolving all 68 static/render `FAIL` items and 38 `REFLEX` items (`0 FAIL, 0 REFLEX, 0 WARN`).
- Reorganized the left sidebar navigation into 4 intention-driven groups (`Home`, `Learn`, `Interactive Labs`, `Engineering Practice`) and made the right Quick Diagnostics Inspector contextual (`#btn-toggle-diag-drawer`).
- Updated `internal/platform/http/router.go` (`handleStaticFrontend`) to serve `/tokens.css` and `/base.css`.

---

## [v2.1.0] — 2026-11-07 (Post-Audit Remediated Release)

### Fixed
- **REM-P0-01**: Fixed `go vet` warning in `tests/server_integration_test.go` (`liveResp` error check before `defer liveResp.Body.Close()`).
- **REM-P0-02**: Added automatic user provisioning (`ensureUser`), strict `status` and `item_type` validation, known `lesson_id`/`exercise_id` checks, and collision-free unique exercise attempt IDs (`att_<ex>_<hex>_<seq>`).
- **REM-P1-01**: Hardened exercise grader in `web/index.html` and `internal/modules/exercises/service.go` with Go comment stripping (`StripGoComments`) to block comment-stuffing bypasses (`0/24` stuffed pass, `24/24` solution pass).
- **REM-P1-02**: Upgraded `internal/modules/diagnostics/analyzer.go` and browser offline analyzer to eliminate false positives (`FP1`, `FP2`) and false negatives (`FN1`–`FN6`).
- **REM-P2-01**: Formatted and `go vet`-verified all 24 curriculum Go code solutions and comparisons, including `addr.Unmap()` for IPv4-mapped IPv6 SSRF protection in Level 6.1.

---

## [v2.0.0] — 2026-11-07 (Modular Monolith & Offline Diagnostics Upgrade)

### Added
- Replaced legacy fake "AI Mentor" with 100% offline **Go Code Review & Diagnostics Lab** (`internal/modules/diagnostics`).
- Split PostgreSQL 17+ (`migrations/postgres/`, `seed/postgres/`) and SQLite 3.40+ WAL (`migrations/sqlite/`, `seed/sqlite/`) migrations and seeds across 20 normalized tables.
- Expanded curriculum to 11 Levels (0–10) and 24 lessons, 14 real-world case studies (15 sections each), and 10 database comparison scenarios across 7 engines.
