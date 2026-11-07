# Go Backend Academy — Project Context (`PROJECT_CONTEXT.md`)

**Last Updated:** 2026-11-07  
**Repository:** `github.com/gobackendacademy/platform` (`go-backend-academy/`)

---

## 1. Mission & Educational Purpose

- **Go Backend Academy** is an educational engineering platform designed to teach learners systematically to become **production-ready Go Backend Engineers**.
- The platform guides students along a structured learning roadmap from **Level 0 (Backend Engineering Fundamentals)** through **Level 10 (Production Engineering & DevOps)** across **24 deep technical lessons**.
- Beyond reading material, the application integrates interactive engineering modules:
  1. **Curriculum Lessons (Levels 0–10, 24 Lessons)**: Multi-tier conceptual depth (`Beginner Overview`, `Intermediate Technical`, `Advanced Internals`), 12-pillar engineering decision analysis, ASCII/protocol diagrams, defective vs. production-ready code comparisons, interactive coding exercises with comment-stripping verification, and official documentation citations (`last_verified: "2026-11-07"`).
  2. **14 Real-World Production Case Studies**: Each structured into 15 engineering sections (Business Scenario, Scope, Functional Requirements, Non-Functional SLAs, Architecture Style, Database Selection Rationale, Production Schema, API Contract, Key Go Implementation, Testing Strategy, Security, Performance, Deployment Topology, Common Mistakes, and Alternatives).
  3. **Database & SQL Lab**: Interactive disposable SQL playground with `EXPLAIN (ANALYZE, BUFFERS)` query plan comparison (indexed vs. unindexed), 10 real-world database scenarios, and a 7-engine × 15-attribute engineering comparison matrix (`PostgreSQL 18`, `MySQL 8.4`, `MariaDB 11.4`, `SQLite 3.40+ WAL`, `MongoDB 8.0`, `Redis 7.4`, `ScyllaDB/Cassandra`).
  4. **API & HTTP Lifecycle Simulator**: Interactive `GET`, `POST`, `PUT`, `PATCH`, and `DELETE` inspector with middleware trace (`RequestID`, `CORSAllowlist`, `RateLimiter`, `MaxBytesReader`, `AuthN`, `BOLA Object-Level AuthZ`, `Idempotency-Key`, and `SSRF` socket guards), explicitly labeled as a deterministic educational middleware simulation.
  5. **Go Code Playground & DB Ecosystem Switcher**: Production pattern templates (`net/http` graceful shutdown, context-cancelable worker pool, transaction retry/rollback wrapper, SSRF dialer control) and side-by-side Go database library comparison (`sqlc + pgx/v5`, `database/sql`, `Bun`, `GORM`, `Ent`).
  6. **Concurrency Visualizer Lab**: Interactive GMP worker-pool & context deadline simulator plus concurrency hazard pattern explorer (`Buffered vs Unbuffered channel leak`, `Data Race vs RWMutex`, `AB/BA Deadlock vs Lexicographical Lock Ordering`).
  7. **Architecture Lab**: Interactive comparison of 5 backend architectures (`Modular Monolith`, `Hexagonal / Ports & Adapters`, `Clean Architecture`, `Pragmatic Layered`, `Microservices`) with dependency diagrams, Go package layouts, and trade-offs.
  8. **100% Offline Go Code Review & Diagnostics Lab**: Deterministic static rule engine (`GO-SEC-001..003`, `GO-DB-001`, `GO-CONC-001..002`, `GO-ERR-001..002`, `GO-PERF-001`) paired with optional local `go vet` / `gofmt` execution when running on a host with the Go toolchain installed.
  9. **Practice Center**: Active-recall flashcards, diagnostic assessment quizzes with explanations, per-lesson engineering scratchpad notes, and bookmarks.

---

## 2. Core Constraints & Non-Negotiable Requirements

1. **Educational & Technical Accuracy**:
   - Explicitly separate **Go Language Specification guarantees** (`go.dev/ref/spec`) from **Go `gc` runtime implementation details** (`go.dev/doc/gc-guide`) and **database engine-specific internals** (PostgreSQL MVCC/SSI/RLS vs. MySQL InnoDB Undo Logs/Next-Key Locks).
   - Never fabricate benchmark numbers; always state workload, row count, cache state, and hardware assumptions.
   - Never make a simulator appear to execute live code or mutate production databases when it runs an educational simulation.
2. **Zero Cloud AI & Zero API Key Dependencies**:
   - AI Mentor and external cloud AI API dependencies are **not wanted**.
   - The platform must remain **100% functional offline** without requiring paid AI services, external network calls, or API keys (`AI_PROVIDER=none` by default).
3. **Preservation of Existing Functionality & Content**:
   - All existing routes, REST API endpoints (`/healthz`, `/readyz`, `/api/v1/*`), database schemas, localStorage persistence (`SafeStore` `gba_v2_*`), 24 lessons, 14 case studies, 10 DB scenarios, 7 DB engines, exercises, quizzes, flashcards, and offline diagnostics must be preserved intact.
4. **Comprehensive UI/UX Redesign Goal**:
   - The previous interface suffered from severe visual crowding, information overload (11 flat top-level sidebar items + 24 lesson links + 6 doc links + a permanent right-hand diagnostics dock + nested cards and multi-colored badges everywhere).
   - The redesign applies the **Hallmark v2.0.0** design standard to transform Go Backend Academy into a calm, focused, structured, high-craft engineering academy that reduces cognitive overload without sacrificing educational depth.

---

## 3. Summary of Previous Technical Audits & Remediations (v2.0 → v2.1)

Based on the verified workspace audit (`docs/PROJECT_AUDIT.md`) and remediation log (`docs/REMEDIATION_REPORT.md`):

- **Toolchain & Build Cleanliness**: Verified with `go1.27.1 windows/amd64`, `node v26.1.0`, and `python 3.14.4` (`sqlite3 3.50.4`). `go vet ./...`, `go build`, and `go test -v ./...` pass with 0 errors and 0 warnings.
- **Database Integrity (`REM-P0-02`)**: Separate PostgreSQL 17+ (`migrations/postgres/`, `seed/postgres/`) and SQLite 3.40+ WAL (`migrations/sqlite/`, `seed/sqlite/`) schemas across 20 normalized tables. Automatic `ensureUser` provisioning, strict validation of `status` (`in_progress` | `completed`) and `item_type` (`lesson` | `case_study` | `db_scenario`), and collision-free unique exercise attempt IDs (`att_<ex>_<hex>_<seq>`).
- **Comment-Stripping Exercise Grader (`REM-P1-01`)**: Both `internal/modules/exercises/service.go` (`StripGoComments`) and `web/index.html` (`stripGoCommentsJS`) strip `//` and `/* ... */` comments before evaluating implementation invariants (`0/24` starter pass, `0/24` comment-stuffed pass, `24/24` solution pass).
- **Scope-Aware Offline Diagnostics (`REM-P1-02`)**: Eliminated false positives (`FP1` package-level `regexp.MustCompile`, `FP2` parameterized SQL with `fmt.Sprintf` in logging) and false negatives (`FN1` SQL `+` concatenation, `FN2` `rows` leak masked by `f.Close()`, `FN3` goroutine shared-variable race `GO-CONC-002`, `FN4` comment-masked goroutine leak `GO-CONC-001`, `FN5` `&http.Client{}` without `Timeout` `GO-SEC-003`, `FN6` discarded `_` error `GO-ERR-002`).
- **Verified Curriculum Go Snippets (`REM-P2-01`)**: All 24 lesson solution and corrected snippets are `gofmt`-formatted and `go vet`-clean, including `addr = addr.Unmap()` for IPv4-mapped IPv6 SSRF protection in Level 6.1 and proper `for`/`select` context cancellation in Level 2.1.

---

## 4. Environment & Documentation Transfer Note

- All project context and documentation files are organized in `go-backend-academy/docs/` for direct repository reference and manual transfer to external project management tools (such as ChatGPT Projects) if desired. No automated remote ChatGPT Project transfer was executed, as this environment operates directly on the local workspace filesystem.
