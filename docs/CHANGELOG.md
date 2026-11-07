# Go Backend Academy — Changelog (`CHANGELOG.md`)

All notable changes to the Go Backend Academy project are documented in this file.

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
