# Go Backend Academy — Three-Persona Learner Journey Simulation

This audit traces three distinct learner personas navigating `https://academy.entahlah831.uk/` from initial landing to exercise completion.

---

## Persona A: Absolute Beginner (Zero Programming & Zero Backend Experience)

- **Profile**: Has never written code in any language, does not know what a terminal, environment variable, TCP port, compiler, or SQL table is.
- **Step 1 — Landing on Dashboard (`view-dashboard`)**:
  - **What they see**: A 3-column interface with 11 numbered navigation items on the left, 4 metric tiles (`0 / 36 Lessons`, `7 DBs x 10 Scenarios`, `14 x 15 Sections`), a "Personalized Next Steps" panel, 4 lab launch cards (`MVCC`, `GO-SEC-001`, `GMP Scheduler`, `Hexagonal`), and a right-hand `Offline Code Diagnostics` drawer containing `func BadHandler(w http.ResponseWriter, r *http.Request, db *sql.DB)`.
  - **Where confusion starts**: Within 5 seconds. Terms like *MVCC*, *SSRF*, *Outbox*, *GMP Scheduler*, *Hexagonal*, and *Go 1.23+ Spec Guarantees vs Runtime Internals* appear on the very first screen before any onboarding prompt asks their experience level.
- **Step 2 — Clicking `Start Learning Curriculum` -> Lesson `0.0A What is a Backend?`**:
  - **What works**: `app-bridge.js` sets `AppState.currentLessonId = 'l0-stage-a-what-is-backend'`, so they land on `0.0A What is a Backend? Servers, Terminal, Files, Processes & Ports`. The metaphor of a restaurant kitchen vs. dining room in the `Beginner Overview` tab is clear.
  - **Where understanding breaks down**:
    1. Immediately above the explanation, they see a `Quick Mastery Check` quiz asking about `os.Getenv("PORT")` and an ASCII diagram `[Browser/Mobile App] --(HTTP Request over Port :8080)--> [Go Backend Process]`.
    2. Below the 4-sentence `Beginner Overview` tab (`348 characters`), they are confronted with **12 Engineering Decision Cards** (`1. What Is It?` through `12. Performance, Security, Maintainability & Scalability`), which immediately reference `127.0.0.1:18080`, `Caddy/Nginx`, and `os.Getenv("PORT")`.
    3. In the **Exercise Runner**, they are asked to write Go code (`if v := os.Getenv("PORT"); v != "" { return v }`) **before Lesson `0.0B` (Installing Go & `main.go`) or Lesson `1.0A` (Variables & Types) or Lesson `1.0B` (`if` statements & functions) have been taught!**
- **Abandonment Risk**: **HIGH (at Lesson 0.0A Exercise)**. An absolute beginner cannot write an `if v := os.Getenv("PORT"); v != ""` short-declaration statement in Lesson 1 when variables (`:=`), `if` statements, `import "os"`, and `func` syntax are not taught until Lessons `1.0A` and `1.0B` (3 lessons later).

---

## Persona B: Basic Programmer (Knows Variables, Loops, Functions; New to Go & Backend APIs)

- **Profile**: Has written basic scripts in Python or JavaScript; understands variables, loops, and functions, but has never built an HTTP server, managed SQL connection pools, or used pointers/interfaces in Go.
- **Where they start**: Clicks `2. Learning Roadmap` or jumps directly to `Level 1 — Go Fundamentals` (`1.0A` through `1.0F`).
- **What works well**:
  - The 6 Stage B lessons (`1.0A` Variables/Zero Values -> `1.0B` Control Flow/Multiple Returns -> `1.0C` Slices/Maps -> `1.0D` Structs/Pointers -> `1.0E` Interfaces/Error Wrapping -> `1.0F` JSON/Table-Driven Tests) match their mental model and quickly teach idiomatic Go patterns (`if err != nil`, `%w`, pointer receivers).
- **Where they get stuck**:
  1. **Transition from `1.0F` to `1.1 Slices, Maps, Pointers, Stack vs Heap & Escape Analysis`**: The jump from basic slices (`1.0C`) to `runtime.hmap` 8-cell buckets, evacuated pointers, and compiler `-gcflags="-m"` escape analysis is steep, though manageable via the `Beginner`/`Intermediate` tabs.
  2. **Transition from Level 1 to Level 2 (`2.1 GMP Scheduler, Channels, Select, Mutexes, Context & Worker Pools`)**: There is **no introductory concurrency lesson** (`Stage C`). Lesson `2.1` packs **6 major concurrency topics** into a single lesson and immediately asks the learner to build a `RunBoundedPool` with `context.WithCancel`, `sync.WaitGroup`, `sync.Once`, `select`, and unbuffered channels (`55 lines of concurrent Go`).
- **Abandonment Risk**: **MEDIUM-HIGH at Lesson `2.1`**. Without a gentle ramp-up lesson covering (1) `go fn()` + `sync.WaitGroup`, (2) unbuffered vs buffered channels, and (3) `select` + `context.Context` as separate sequential steps, Lesson `2.1` forces basic programmers to copy-paste the solution.

---

## Persona C: Intermediate Developer (Has Built Basic APIs; Wants Go Production Mastery)

- **Profile**: Has built CRUD APIs in Node/Python/Go; wants deep mastery of Go runtime internals, PostgreSQL MVCC, zero-downtime migrations, OWASP API security, and distributed systems (Outbox, Saga, Singleflight).
- **Where they start**: Uses global search (`/`) or jumps across Levels 2–10, SQL Playground, Diagnostics Lab, and the 14 Production Case Studies.
- **What works exceptionally well**:
  - The **12 Engineering Decision Pillars** and **Anti-Pattern vs Production Code Comparisons** directly answer senior-level engineering questions (*Why `http.MaxBytesReader` vs `io.LimitReader`? Why `pgx/v5` + `sqlc` over GORM? Why keyset pagination over `OFFSET`? Why transactional outbox over dual-writes?*).
  - The **14 Case Studies** (each with 14–15 structured architectural sections) and the **Database Lab** (7 engines x 10 scenarios + live `EXPLAIN QUERY PLAN` toggle) provide genuine senior-level engineering value.
- **Where frustration occurs**:
  - Even for an intermediate developer, having all 12 pillar cards + 3 explanation tiers + code diffs + exercise stacked on one giant scroll without collapsible sections or a clean split-screen code mode makes scanning fatiguing.
  - In the **Go Code Playground** (`view-playground`) and **Exercise Runner**, code is checked statically rather than compiled and executed with real stdout/test output.
