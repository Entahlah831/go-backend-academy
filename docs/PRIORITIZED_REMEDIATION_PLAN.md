# Go Backend Academy — Prioritized Findings & Remediation Plan (`v2.4.0` -> `v2.5.0`)

Every finding below includes its ID, Severity (`P0`–`P3`), Affected File/Component, Reproduction Steps, Expected vs. Actual Behavior, Root Cause, User Impact, Concrete Correction, and Verification Procedure.

---

## P0 Findings (Critical Learning Blockers, Multi-User Collisions & Severe UI Clutter)

### `P0-UX-001` — 11-Item Sidebar + Open Right Diagnostics Dock Overwhelms Learners on Arrival
- **Severity**: `P0`
- **Affected Component**: `web/index.html` (`#left-sidebar`, `#right-diag-panel`, `switchView()`)
- **Reproduction Steps**:
  1. Open `https://academy.entahlah831.uk/` at `1440x900`.
  2. Observe the left sidebar (11 numbered views + 36 lesson links + 6 doc links) and the right `#right-diag-panel` open simultaneously on the Dashboard.
- **Expected Behavior**: A clean, focused learning workspace with at most 4–5 primary navigation modes, a single clear primary CTA (`Continue Learning` / `Start Lesson 0.0A`), and auxiliary developer drawers (`Inspector`) closed until requested.
- **Actual Observed Behavior**: 3 columns compete for attention on first load; beginners do not know where to look or click first.
- **Root Cause**: `switchView('dashboard')` explicitly un-hides `#right-diag-panel` (`dp.classList.toggle('hidden', viewName !== 'dashboard')`), and all 11 sub-tools are listed flatly in `#primary-nav`.
- **Recommended Correction**:
  1. Group navigation into **4 Primary Workspace Tabs/Modes**: `Learn` (Path & Curriculum), `Labs` (Unified 5-Lab Switcher), `Case Studies` (14 Blueprints & Architecture), and `Practice` (Quizzes & Flashcards).
  2. Default `#right-diag-panel` to `hidden` on all views unless explicitly toggled via `#btn-toggle-diag-drawer`.
- **Verification Procedure**: Load `/` in a clean browser session; verify only 2 panes (clean sidebar + focused main workspace) are visible and `#right-diag-panel` has class `hidden`.

### `P0-UX-002` — Curriculum Lesson View Stacks 8 Mega-Cards (~2,500 Words) Without Guided Step Progression
- **Severity**: `P0`
- **Affected Component**: `web/index.html` (`#view-curriculum`), `web/app-bridge.js` (`renderPedagogyPanel`)
- **Reproduction Steps**:
  1. Click `3. Curriculum Lessons` -> select any lesson.
  2. Scroll down: observe the Stage Banner + Inline Quiz at the very top, followed by Title/Diagram, 3-Tier Switcher, all 12 Engineering Pillars expanded in a 3-column grid, Anti-Pattern vs Production Code, Exercise Runner, and Notes.
- **Expected Behavior**: A guided, distraction-free **4-Step Lesson Mode** (`1. Concept & Mental Model` -> `2. Code Comparison` -> `3. Hands-On Exercise` -> `4. Mastery Check & Notes`) with an optional `"All-in-One Scroll View"` toggle, and `Core Mechanics (1–4)` selected by default on the 12 Pillars instead of all 12 cards at once.
- **Actual Observed Behavior**: All 8 sections and all 12 pillar cards render simultaneously, causing severe scroll fatigue and disorientation.
- **Recommended Correction**: Add a 4-step segmented workspace bar inside `#view-curriculum` that reveals one focused learning stage at a time (with `"Next Step →"` buttons at the bottom of each stage and a `"Compact / Full Scroll"` toggle), and move the `Quick Mastery Check` quiz to Step 4 (after the concept and exercise, not above the lesson title!).
- **Verification Procedure**: Open any lesson; confirm Step 1 (`Concept & Mental Model`) is focused by default, only 4 pillar cards show initially, and clicking `Step 3: Hands-On Exercise` focuses the coding workspace cleanly.

### `P0-AUTH-001` — Hardcoded `usr_local_default` Causes Multi-User Progress/Notes Collision on Public VPS
- **Severity**: `P0`
- **Affected Component**: `web/index.html`, `web/app-bridge.js`, `internal/platform/database/content.go`
- **Reproduction Steps**:
  1. Open `https://academy.entahlah831.uk/` from Browser A and save a personal note or mark a lesson completed.
  2. Open `https://academy.entahlah831.uk/` from Browser B (incognito or another device): Browser B overwrites and reads Browser A's `usr_local_default` progress and notes in PostgreSQL.
- **Expected Behavior**: Each browser learner gets an isolated, persistent learner profile (`usr_<uuid>` stored in `localStorage` and auto-provisioned via `INSERT INTO users ... ON CONFLICT DO NOTHING` on the backend).
- **Actual Observed Behavior**: All requests send `"user_id": "usr_local_default"`.
- **Recommended Correction**: Generate a persistent `gba_user_id` (`usr_` + 16 hex chars) in `SafeStore` on first visit, pass it in all `/api/v1/progress`, `/api/v1/bookmarks`, `/api/v1/notes`, and `/api/v1/exercises/verify` calls, and ensure the backend auto-upserts the `user_id` in `users` before foreign-key writes.
- **Verification Procedure**: Run an integration test with two distinct `user_id` values (`usr_alice` and `usr_bob`) verifying 100% isolated progress, notes, and bookmarks.

### `P0-CURR-001` — Lesson `0.0A` Exercise Requires Go Syntax (`os.Getenv`, `if v := ...`) Before Go Syntax Is Taught
- **Severity**: `P0`
- **Affected Component**: `web/curriculum-stages.js`, `seed/*/002_beginner_stages_seed.sql`
- **Reproduction Steps**:
  1. As an absolute beginner on Lesson 1 (`0.0A What is a Backend?`), scroll to the Exercise Runner.
  2. Read the task: `Implement ResolvePort(defaultPort string) string using os.Getenv("PORT")`.
- **Expected Behavior**: Lesson `0.0A` should test a zero-prerequisite concept (or provide the exact 3 lines of code in a beginner walkthrough directly above the editor so a first-time learner learns what `if`, `:=`, and `return` mean line-by-line before typing them).
- **Actual Observed Behavior**: The `Beginner Overview` tab only explains the restaurant metaphor (348 chars) and never shows a single line of Go syntax before the exercise asks the learner to write `if v := os.Getenv("PORT"); v != ""`.
- **Recommended Correction**: Expand the `Beginner Overview` tab in all Stage A & Stage B lessons (`0.0A`–`1.0F`) to include a **Line-by-Line Syntax Walkthrough** explaining every keyword (`package`, `import`, `func`, `:=`, `if`, `return`) used in that lesson's exercise.

---

## P1 Findings (Curriculum Bridges, SQL Lab Index Toggle, DB Search Parity & Quizzes)

### `P1-CURR-002` — Missing Beginner Bridge Lessons in Level 2 (Concurrency) and Levels 6–9
- **Severity**: `P1`
- **Affected Component**: `web/curriculum-stages.js`, `seed/*/002_beginner_stages_seed.sql`
- **Recommended Correction**: Add 5 beginner-friendly bridge lessons (`2.0 Goroutines, Channels & WaitGroup 101`, `6.0 Password Hashing & Bearer Auth Middleware 101`, `7.0 First Table-Driven Test & httptest 101`, `8.0 Handler-Service-Repository Separation 101`, `9.0 Redis Cache-Aside & Exponential Backoff 101`) bringing the total curriculum from 36 to **41 lessons** with zero difficulty spikes.

### `P1-LAB-003` — SQL Playground Backend Always Creates Composite Index Regardless of UI Checkbox
- **Severity**: `P1`
- **Affected Component**: `internal/modules/sqlplayground/service.go`, `web/app-bridge.js`
- **Recommended Correction**: Add `UseIndex bool` (`json:"use_index"`) to `sqlplayground.ExecuteRequest`. In `service.go`, only execute `CREATE INDEX idx_orders_user_status_created ...` when `req.UseIndex` is `true`. Update `web/app-bridge.js` to pass `use_index: Boolean(toggle && toggle.checked)`.

### `P1-DB-002` — 12 Stage A–J Lessons Only Have 1 Short Summary Section in `lesson_sections` Table
- **Severity**: `P1`
- **Affected Component**: `seed/sqlite/002_beginner_stages_seed.sql`, `seed/postgres/002_beginner_stages_seed.sql`
- **Recommended Correction**: Populate full `lesson_sections` rows (3 tiers + 12 pillars + code comparisons) and quiz questions for all lessons in `002_beginner_stages_seed.sql` so backend `/api/v1/search?q=...` and `/api/v1/lessons/{slug}` return full rich content matching the frontend.

### `P1-LAB-001` — Exercise Verifier Uses Static Token Matching Without Running `go test` Assertions
- **Severity**: `P1`
- **Affected Component**: `internal/modules/exercises/service.go`
- **Recommended Correction**: Add an AST/behavioral verification layer (or isolated `go test` runner when the Go toolchain is installed in the container/host, plus multi-expression structural checks) and clearly display whether verification ran via `Static AST + Token Contract` or `Live Go Test Suite`.
