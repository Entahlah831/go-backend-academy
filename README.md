# Go Backend Academy — Production Engineering, Architecture & Offline Diagnostics Platform

**Go Backend Academy** is a comprehensive, 100% offline-capable Go backend engineering platform teaching developers from networking and Go runtime fundamentals (Levels 0–2) through HTTP service engineering, relational/NoSQL database internals, the Go database ecosystem, OWASP API security, testing/fuzzing, software architecture, distributed systems, and production DevOps (Levels 3–10).

## 1. Key Architectural Improvements in v2.0

1. **100% Offline Go Code Review & Diagnostics Lab (Zero Cloud AI / Zero API Keys)**:
   * Replaced the legacy "AI Mentor" with a transparent, deterministic **Go Code Review & Diagnostics Lab** (`internal/modules/diagnostics`).
   * Evaluates Go code against structured rules (`GO-SEC-001..004`, `GO-DB-001..002`, `GO-CONC-001`, `GO-ERR-001`, `GO-PERF-001`) and, when the Go toolchain is installed locally, executes `go vet` in an isolated temporary directory with strict timeouts.
   * Every finding reports its `rule_id`, `classification` (`confirmed_diagnostic`, `potential_issue`, `educational_heuristic`, or `no_finding_detected`), `severity`, `line`, `why_it_matters`, `suggested_correction`, `related_lesson_id`, and official documentation URL—and explicitly states the limitations of static analysis.
   * Includes an optional `OptionalAssistantProvider` abstraction (`AI_PROVIDER=none` by default) that never requires network access or API keys.
2. **Engine-Specific Versioned Database Migrations & Normalized 20-Table Schema**:
   * Separate verified migrations and seeds for **PostgreSQL 17/18** (`migrations/postgres/`, `seed/postgres/`) and **SQLite 3.40+ WAL** (`migrations/sqlite/`, `seed/sqlite/`) with explicit `.up.sql` and `.down.sql` rollback scripts.
3. **Pragmatic Modular Monolith Architecture**:
   * Clean separation across `cmd/server`, `internal/config`, `internal/platform/{database,http,logger}`, and `internal/modules/{diagnostics,recommendations,...}` using pure Go 1.23+ standard library packages (`net/http`, `database/sql`, `log/slog`).
   * Built-in `RequestID`, `CORSAllowlist` (with `Vary: Origin`), `TokenBucket` rate limiting, `PanicRecovery`, `http.MaxBytesReader`, decoupled `/healthz` (liveness) vs `/readyz` (readiness with DB `PingContext`), and static web serving at `GET /`.
4. **Hardened Docker & DevOps Setup**:
   * `make docker-down` safely stops containers without destroying persistent PostgreSQL volumes (`pgdata`), while `make docker-clean-volumes` provides an explicit warning before volume removal.
   * Database ports bind to `127.0.0.1` by default, credentials use `.env` interpolation (`${POSTGRES_PASSWORD:?error}`), and Redis is placed behind an optional `--profile cache`.

## 2. Repository Structure

```text
go-backend-academy/
├── cmd/server/main.go               # Server entrypoint with graceful SIGINT/SIGTERM draining
├── internal/
│   ├── config/config.go             # Environment configuration & fail-fast validation
│   ├── platform/
│   │   ├── database/db.go           # Connection pool tuning (MaxOpenConns/MaxIdleConns) & store
│   │   ├── http/                    # Middleware (RequestID, CORS, RateLimit, Recovery) & router
│   │   └── logger/logger.go         # Structured JSON slog logger
│   └── modules/
│       ├── diagnostics/analyzer.go  # Offline Go Code Review & Diagnostics Lab + go vet runner
│       └── recommendations/engine.go# Prerequisite- and mistake-driven Recommendation Engine
├── frontend/                        # Modular Svelte + TypeScript + Vite source tree
│   ├── src/{layouts,pages,services,stores,types}/
│   ├── package.json
│   └── vite.config.ts
├── migrations/
│   ├── postgres/                    # 001_initial_schema.up.sql & .down.sql (PostgreSQL 17+)
│   └── sqlite/                      # 001_initial_schema.up.sql & .down.sql (SQLite 3.40+ WAL)
├── seed/
│   ├── postgres/001_seed_data.sql   # PostgreSQL seed (ON CONFLICT DO NOTHING)
│   └── sqlite/001_seed_data.sql     # SQLite seed (verified with PRAGMA foreign_keys = ON)
├── docs/
│   ├── PROJECT_AUDIT.md             # Complete P0–P3 engineering audit
│   ├── IMPLEMENTATION_STATUS.md     # Verified feature matrix
│   ├── ARCHITECTURE.md              # System architecture & middleware pipeline
│   ├── DATABASE_DESIGN.md           # 20-table relational schema & PITR backup guide
│   ├── CONTENT_REVIEW.md            # Technical accuracy & spec vs runtime separation
│   └── decisions/                   # Architectural Decision Records (ADR-001, ADR-002)
├── tests/server_integration_test.go # httptest integration, readiness, and diagnostics tests
├── web/index.html                   # Compiled self-contained web application served at GET /
├── Dockerfile                       # Multi-stage non-root build with HEALTHCHECK
├── docker-compose.yml               # Local stack (Go + PostgreSQL 17 + optional Redis profile)
├── Makefile                         # Build, test, migration, and safe Docker commands
└── .env.example                     # Documented environment configuration template
```

## 3. Quick Start & Verification Commands

> **Catatan Database:** Untuk jalur SQLite lokal pakai `make run`; untuk Docker gunakan Postgres (`docker compose up` / `make docker-up`).

### Local Development (SQLite WAL or In-Memory Mode)

```bash
cp .env.example .env
make migrate-sqlite
make seed-sqlite
make run
# Open http://localhost:8080
```

### Production Stack with PostgreSQL 17 (Docker Compose)

```bash
cp .env.example .env
# Set POSTGRES_PASSWORD in .env, then start Go + PostgreSQL 17:
POSTGRES_PASSWORD=local_dev_secret make docker-up

# Stop containers safely WITHOUT deleting database volumes:
make docker-down
```

### Running Tests & Static Analysis

```bash
make vet
make test-race
```
