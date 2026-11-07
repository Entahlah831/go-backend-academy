# Go Backend Academy — Project Overview (`PROJECT_OVERVIEW.md`)

**Version:** v2.2 (Hallmark UI/UX Redesigned Edition)  
**Repository:** `github.com/gobackendacademy/platform`

---

## 1. Executive Summary

**Go Backend Academy** is a self-contained, 100% offline-capable educational engineering platform that takes developers from foundational networking and Go runtime mechanics (`Levels 0–2`) to production HTTP services, relational/NoSQL storage internals, the Go database ecosystem, OWASP API security, testing/fuzzing, software architecture, distributed systems, and production DevOps (`Levels 3–10`).

Every concept follows a rigorous engineering loop:
**Understand → Experiment → Implement → Debug → Compare → Optimize → Apply**.

---

## 2. Technology Stack

| Layer | Technology | Role & Rationale |
| :--- | :--- | :--- |
| **Backend Runtime** | Go 1.23+ (`go1.27.1` verified) | Pure standard library (`net/http`, `database/sql`, `log/slog`, `context`, `sync/atomic`) with zero mandatory third-party module dependencies. |
| **Primary Database** | PostgreSQL 17/18 | Production relational storage (`migrations/postgres/`, `seed/postgres/`). |
| **Local / Embedded DB** | SQLite 3.40+ (WAL mode) & In-Memory Store | Zero-setup local development (`migrations/sqlite/`, `seed/sqlite/`) with full foreign-key enforcement (`PRAGMA foreign_keys = ON`). |
| **Web Application** | Self-Contained HTML/CSS/JS Bundle (`web/index.html`) + Modular Svelte/TS Source (`frontend/src/`) | Served directly by the Go binary at `GET /` and compatible with standalone offline browser preview. |
| **Design System** | Hallmark v2.0.0 (`Atmospheric Minimalism & High-Craft Dark UI`) | Token-driven CSS custom properties (`--bg-canvas`, `--bg-surface`, `--text-primary`, `--accent`, etc.), intentional dark/light polarity, tabular numerals, and zero visual bloat. |
| **Static Analysis** | Offline Diagnostics Engine (`internal/modules/diagnostics`) | Deterministic rule evaluation (`GO-SEC-*`, `GO-DB-*`, `GO-CONC-*`, `GO-ERR-*`, `GO-PERF-*`) + isolated local `go vet` / `gofmt` execution. |

---

## 3. Core Platform Capabilities

1. **Structured Learning Path (Levels 0–10, 24 Lessons)**:
   - Progressive conceptual tiers (`Beginner`, `Intermediate`, `Advanced Internals`).
   - 12-point engineering decision matrix per lesson.
   - Side-by-side anti-pattern vs. production-ready Go code with failure mechanism analysis.
   - Comment-stripping interactive exercise verifier with hints, test assertions, and reference solutions.
2. **Interactive Engineering Labs (5 Specialized Workspaces)**:
   - **Go Code Playground**: Production pattern templates + Go DB library switcher (`sqlc + pgx/v5`, `database/sql`, `Bun`, `GORM`, `Ent`).
   - **SQL & Database Lab**: Disposable sandbox dataset query runner, indexed vs. unindexed `EXPLAIN (ANALYZE, BUFFERS)` comparator, 10 production scenarios, and 7-engine × 15-attribute matrix.
   - **API & HTTP Simulator**: `GET`/`POST`/`PUT`/`PATCH`/`DELETE` request builder with step-by-step middleware pipeline trace.
   - **Concurrency Lab**: Interactive GMP worker-pool timeline simulator and synchronization hazard explorer.
   - **Architecture Lab**: 5 backend architecture patterns compared across structure, dependency direction, and trade-offs.
3. **14 Real-World Case Studies**:
   - Production blueprints covering Task APIs, Auth/OIDC, URL Shorteners, Full-Text CMS, E-Commerce Outbox, Flash-Sale Inventory, WebSocket Chat, S3 Storage, Notifications, GiST Slot Reservations, Double-Entry Ledgers, Multi-Tenant RLS, Event-Driven Sagas, and 50k+ RPS Public APIs.
4. **Practice & Reinforcement Center**:
   - Active-recall flashcards, diagnostic multiple-choice quizzes with per-option explanations, personal engineering notes, and lesson bookmarks.
5. **Offline Code Review & Diagnostics Lab**:
   - Transparent static analysis classifying findings into `confirmed_diagnostic`, `potential_issue`, `educational_heuristic`, and `no_finding_detected` with explicit static analysis limitation disclosures.
