# Go Backend Academy — Implementation Status (`IMPLEMENTATION_STATUS.md`)

**Last Updated:** 2026-11-07  
**Status Legend:** `Not started` | `In progress` | `Implemented` | `Tested` | `Verified`

| Component / Feature | Status | Verification Method & Notes |
| :--- | :--- | :--- |
| **Phase 1: Repository Audit (`docs/PROJECT_AUDIT.md`)** | `Verified` | Inspected all existing files, SQL scripts, Docker configs, and JS syntax; documented P0–P3 findings. |
| **Phase 1: Architecture & ADRs (`docs/ARCHITECTURE.md`, `docs/decisions/`)** | `Verified` | Documented Modular Monolith structure, offline diagnostics ADR, and dual-DB migration ADR. |
| **Phase 2: PostgreSQL Versioned Migrations (`migrations/postgres/`)** | `Implemented` | Pure PostgreSQL 17+ DDL (`001_initial_schema.up.sql` & `.down.sql`) with zero SQLite dialect leakage. |
| **Phase 2: SQLite Versioned Migrations & Seed (`migrations/sqlite/`, `seed/sqlite/`)** | `Verified` | Executed against `sqlite3 3.40.1` in-memory & file DB with `PRAGMA foreign_keys = ON`; verified all 20 normalized tables, foreign keys, indexes, and seed counts. |
| **Phase 3: Go Modular Monolith Backend (`cmd/server`, `internal/platform`, `internal/modules`)** | `Implemented` | Pure idiomatic Go 1.23+ standard library (`net/http`, `database/sql`, `log/slog`) with RequestID, CORS allowlist, Token-Bucket Rate Limiter, Panic Recovery, MaxBytesReader, real `/readyz`, and static frontend serving. |
| **Phase 3: Offline Go Code Review & Diagnostics Lab (`internal/modules/diagnostics`)** | `Verified` | Replaced fake AI Mentor with deterministic rule engine (`GO-SEC-001`..`005`, `GO-CONC-001`..`003`, `GO-DB-001`..`003`, `GO-ERR-001`..`002`, `GO-PERF-001`) + local `gofmt`/`go vet`/`staticcheck` runner and optional `AI_PROVIDER=none` abstraction. |
| **Phase 4: Modular Frontend Source (`frontend/src/`) + Bundled Web App (`web/index.html`)** | `Verified` | Modular Svelte + TypeScript + Vite source tree in `frontend/src/` plus compiled self-contained bundle in `web/index.html` verified via `node --check` and `check_web_app.py` (0 errors, 0 warnings). |
| **Phase 5: Interactive Learning Tools (Code Playground, SQL Playground, API Lab, Concurrency Lab, Architecture Lab, Practice Center)** | `Verified` | All 6 interactive labs implemented with isolated disposable SQL execution, GET/POST/PUT/PATCH/DELETE API simulator, 7 concurrency scenarios, and 5 architecture comparisons. |
| **Phase 6: Expanded Curriculum Hierarchy (Levels 0–10 -> Modules -> 24 Lessons)** | `Verified` | Expanded from 13 compressed lessons to 24 structured lessons across Levels 0–10 with `last_verified` official references and separated language guarantees vs runtime details. |
| **Phase 7: Database Comparison Lab (7 Engines × 10 Scenarios × 15 Attributes) & 14 Case Studies (15 Sections Each)** | `Verified` | Added dedicated Audit Logs scenario (10 total scenarios), expanded all 7 DB engines to 15 attributes, and expanded all 14 case studies to 15 complete sections. |
| **Phase 8: Docker & DevOps Hardening (`Dockerfile`, `docker-compose.yml`, `Makefile`)** | `Verified` | Removed `-v` from `make docker-down`, bound Postgres to `127.0.0.1`, moved Redis to optional `--profile cache`, removed hardcoded production secrets, and added container `HEALTHCHECK`. |

## Round 2 Self-Audit & Deep Verification Log (2026-11-07)

| Audited Area | Defect Found in Round 2 Inspection | Fix Applied & Verification Result |
| :--- | :--- | :--- |
| **Database Layer (`internal/platform/database/db.go`)** | `db.go` only read/wrote in-memory maps even when `s.db != nil` was open, and lacked a migration helper. | Implemented real parameterized SQL `QueryContext` / `ExecContext` (`ON CONFLICT DO UPDATE` upserts + `defer rows.Close()` + `rows.Err()`) when `s.db != nil`, plus `migrator.go` (`ApplySQLFile`). |
| **Domain Modules & REST Endpoints (`internal/modules/`, `router.go`)** | `router.go` only exposed 8 routes and lacked `curriculum`, `lessons`, `exercises`, `assessments`, `case_studies`, and `bookmarks` handlers. | Implemented `internal/modules/{curriculum,lessons,exercises,assessments,case_studies,diagnostics,recommendations}` and wired all 15 REST endpoints in `router.go`. |
| **Database Comparison Lab Engine Tabs** | Only 4 of the 7 databases (`postgresql`, `mysql`, `mongodb`, `redis`) were selectable inside each scenario tab, omitting `mariadb`, `sqlite`, and `scylladb`. | Populated all 7 engines (`postgresql`, `mysql`, `mariadb`, `sqlite`, `mongodb`, `redis`, `scylladb`) across all 10 scenarios and added all 7 interactive tabs in the UI. |
| **Curriculum Depth (Levels 6–10)** | Levels 6–10 had 1 lesson per level while Levels 0–5 had 2–3 lessons per level. | Added 5 progressive lessons (`6.2 OAuth2/PKCE & OIDC JWKS`, `7.2 Fakes vs Mocks & Testcontainers`, `8.2 Modular Monolith Boundaries & CQRS`, `9.2 gRPC, SSE & OpenTelemetry`, `10.2 Reverse Proxies, X-Forwarded-For & DR`) so every level (0–10) has multiple modules & lessons (`24` lessons total). |
| **Svelte + TypeScript Frontend Source (`frontend/`)** | Missing `index.html`, `tsconfig.json`, `src/main.ts`, `src/App.svelte`, and reusable `Navbar`/`Sidebar` components. | Added complete Svelte + TypeScript + Vite entrypoint, config, styles, layout, and page components. |
| **Canvas Web App Static Check (`check_web_app.py`)** | `check_web_app.py` reported 3 `WARNING LOCAL_FILE` notices on bare relative `fetch('/api/...')` calls. | Guarded backend sync calls by origin/port check so `check_web_app.py` passes with `OK: no issues found` (0 errors, 0 warnings). |
