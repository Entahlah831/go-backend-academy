# Go Backend Academy — Agent & Engineering Guidelines (`AGENTS.md`)

This file defines mandatory project-level engineering and design instructions for any coding agent or contributor working on **Go Backend Academy**.

---

## 1. Core Engineering Rules

1. **Preserve the Existing Technology Stack**:
   - Backend: Pure Go standard library (`net/http`, `database/sql`, `log/slog`, `context`) in `cmd/server` and `internal/`.
   - Database: Dual-engine support for PostgreSQL 17+ (`migrations/postgres/`, `seed/postgres/`) and SQLite 3.40+ WAL (`migrations/sqlite/`, `seed/sqlite/`).
   - Frontend: Self-contained compiled web bundle in `web/index.html` (served at `GET /`) paired with modular Svelte + TypeScript source files in `frontend/src/`.
2. **Avoid Unnecessary Dependencies**:
   - Do not add heavy frontend runtime frameworks, icon CDN packs that break offline rendering, or unverified third-party Go modules to `go.mod`.
3. **Prioritize Maintainability**:
   - Keep code modular, well-structured, and consistent with CSS custom property design tokens.
4. **Preserve Existing Routes and Functionality**:
   - Never break or remove `/healthz`, `/readyz`, `/api/v1/curriculum`, `/api/v1/lessons`, `/api/v1/exercises/verify`, `/api/v1/quizzes`, `/api/v1/case-studies`, `/api/v1/diagnostics/analyze`, `/api/v1/recommendations`, `/api/v1/progress`, `/api/v1/bookmarks`, `/api/v1/notes`, or `GET /`.
   - Preserve all 24 curriculum lessons, 14 case studies, 10 DB scenarios, 7 DB engine matrices, 5 architecture lab views, concurrency simulations, flashcards, quizzes, exercise graders, and `SafeStore` localStorage keys (`gba_v2_*`).
5. **Verify Changes with Actual Tests**:
   - Always run `go vet ./...`, `go test -v ./...`, JS syntax checks, and Hallmark `sloplint.mjs` verification before claiming completion.
6. **Keep Educational Content Technically Accurate**:
   - Maintain strict separation between Go Language Specification guarantees (`go.dev/ref/spec`), `gc` runtime implementation details (`go.dev/doc/gc-guide`), and database engine internals.
   - Never make an educational simulator pretend to execute live network or database operations when it is running a deterministic simulation.
7. **Follow the Hallmark v2.0.0 Design Skill for UI Redesign Tasks**:
   - Use `.agents/skills/hallmark/SKILL.md` as the design authority.
   - Route all colors and fonts through CSS custom property tokens (`--bg-*`, `--text-*`, `--accent*`, `--border-*`, `--font-*`).
   - Respect Hallmark's Floor rules, Reflex gates, and `sloplint.mjs` checks.
8. **Do Not Introduce Cloud AI Requirements**:
   - Do not add an "AI Mentor" or require OpenAI/Anthropic/Gemini API keys. Keep `AI_PROVIDER=none` as the 100% offline default.
9. **Never Invent Statistics, Testimonials, or Product Capabilities**:
   - All progress counters, recommendations, and diagnostic results must come from real user state and deterministic analyzers.
