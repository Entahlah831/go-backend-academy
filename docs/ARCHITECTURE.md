# Go Backend Academy — System Architecture (`ARCHITECTURE.md`)

## 1. Architectural Style: Pragmatic Modular Monolith

Go Backend Academy is architected as a **Modular Monolith** compiled into a single static Go binary that serves both the REST API (`/api/v1/*`) and the compiled frontend assets (`/`).

```text
cmd/
└── server/
    └── main.go                      # Composition root: Config -> Logger -> DB -> Modules -> HTTP Server -> Graceful Shutdown

internal/
├── config/
│   └── config.go                    # Fail-fast env loading (DB, HTTP timeouts, CORS allowlist, Rate Limit, AI_PROVIDER=none)
├── platform/
│   ├── database/
│   │   ├── db.go                    # Connection pool initialization, PingContext health check, Tx helper
│   │   └── migrator.go              # Versioned SQL migration & seed runner
│   ├── http/
│   │   ├── middleware.go            # RequestID, slog access logger, Panic recovery, CORS allowlist, Token-Bucket Rate Limiter
│   │   └── response.go              # Standardized JSON envelope & RFC 9457 Problem Details error writer
│   └── logger/
│       └── logger.go                # Structured JSON slog.Logger factory
├── modules/
│   ├── curriculum/                  # Learning paths, Levels 0-10, Modules, and 24 deep Lessons
│   ├── exercises/                   # Coding exercises, test cases, and safe offline verification
│   ├── assessments/                 # Quizzes, active-recall flashcards, and attempt scoring
│   ├── progress/                    # User progress tracking, completion timestamps, and history
│   ├── bookmarks/                   # Lesson, case-study, and DB scenario bookmarks
│   ├── notes/                       # Per-lesson engineering scratchpad notes
│   ├── diagnostics/                 # Offline Go Code Review & Diagnostics Lab (CLI toolchain + AST/pattern rules)
│   ├── recommendations/             # Prerequisite- and mistake-driven Recommendation Engine
│   └── case_studies/                # 14 Real-World Case Studies (15 sections each) & 10 DB Lab Scenarios
└── shared/
    └── types.go                     # Shared domain primitives and pagination envelopes

frontend/                            # Maintainable Svelte + TypeScript + Vite source tree
├── src/
│   ├── components/                  # Navbar, Sidebar, CodeEditor, DiagnosticCard, DiagramViewer
│   ├── layouts/                     # WorkspaceLayout.svelte (3-pane responsive layout)
│   ├── pages/                       # Dashboard, Roadmap, Curriculum, DbLab, ApiLab, CodePlayground, ConcurrencyLab, ArchitectureLab, DiagnosticsLab, Projects, PracticeCenter
│   ├── services/                    # api.ts (REST client with offline fallback)
│   ├── stores/                      # progressStore.ts, themeStore.ts
│   └── types/                       # domain.ts
├── package.json
└── vite.config.ts

migrations/
├── postgres/                        # PostgreSQL 17+ Up/Down migrations
└── sqlite/                          # SQLite 3.40+ Up/Down migrations
seed/
├── postgres/                        # PostgreSQL-compatible seed data (ON CONFLICT DO NOTHING)
└── sqlite/                          # SQLite-compatible seed data (INSERT OR IGNORE)
```

## 2. Key Architectural Guarantees

1. **100% Offline Operation (Zero Mandatory Cloud AI)**: The **Go Code Review & Diagnostics Lab** (`internal/modules/diagnostics`) runs deterministically without internet access or API keys. When running locally with the Go toolchain installed, it invokes `gofmt -d`, `go vet`, and `staticcheck` inside an isolated temporary directory with strict timeouts (`context.WithTimeout`) and combines their output with 14 educational diagnostic rules (`GO-SEC-001` through `GO-PERF-001`).
2. **Defense-in-Depth HTTP Layer**: Every request passes through `RequestID -> StructuredLogger -> PanicRecovery -> CORSAllowlist -> RateLimiter -> MaxBytesReader` before reaching any domain handler.
3. **Health vs. Readiness Separation**:
   * `GET /healthz` checks only liveness of the Go HTTP process loop (never queries the database, preventing Kubernetes restart cascades).
   * `GET /readyz` checks the atomic shutdown state and executes a bounded 500ms `db.PingContext(ctx)` against PostgreSQL/SQLite.
