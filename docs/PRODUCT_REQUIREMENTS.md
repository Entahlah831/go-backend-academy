# Go Backend Academy — Product Requirements (`PRODUCT_REQUIREMENTS.md`)

**Last Updated:** 2026-11-07  
**Status:** Active Baseline for v2.2 UI/UX Redesign

---

## 1. Target Audience & User Personas

1. **Beginners to Backend Engineering**: Need a clear starting point (Level 0), jargon-free introductory explanations before diving into kernel/runtime internals, and guided next steps.
2. **Developers Transitioning to Go**: Know HTTP/SQL from Python, Node.js, or Java, and need idiomatic Go patterns (`context.Context`, explicit value errors, implicit interfaces, `database/sql` pool tuning, `pgx/v5` + `sqlc`).
3. **Intermediate Go Engineers**: Preparing for production backend ownership; need deep understanding of GMP scheduling, escape analysis, MVCC isolation anomalies, OWASP API security (`BOLA`, `SSRF`), and zero-downtime migrations.
4. **Senior / Staff Backend Engineers**: Exploring architectural trade-offs (Modular Monolith vs. Hexagonal vs. Microservices), Transactional Outbox, Sagas, PostgreSQL Row-Level Security (`FORCE RLS`), and Kubernetes `GOMEMLIMIT` / probe design.

---

## 2. Functional Requirements

### FR-1: Home & Personalized Learning Progression
- Immediately answer: *Where am I in the learning journey? What should I study next? What have I completed? How do I resume?*
- Compute recommendations deterministically from real user state (`completedLessons`, `passedExercises`, `failedExercises`, `quizAnswers`, `triggeredRules`) without inventing activity metrics.

### FR-2: Curriculum & Lesson Reading Experience
- Support browsing the full hierarchy (`Learning Path → Level 0–10 → Module → 24 Lessons`).
- Provide a dedicated, distraction-free reading layout (`60ch–72ch` prose measure) with clear visual separation between:
  - Lesson Overview & Official Documentation References
  - System / Memory / Protocol Architecture Diagram
  - 3-Tier Conceptual Explanation (`Beginner`, `Intermediate`, `Advanced Internals`)
  - 12-Point Engineering Decision Analysis (progressively disclosed so it never overwhelms the page)
  - Incorrect vs. Production Go Code Comparison
  - Interactive Lesson Coding Exercise & Verification Suite
  - Previous / Next Lesson sequential navigation

### FR-3: Interactive Engineering Labs
- Provide dedicated workspaces for each of the 5 labs:
  1. **SQL & Database Lab**: Disposable SQL query execution, `EXPLAIN (ANALYZE, BUFFERS)` plan comparison, 10 scenario comparisons across 7 engines, and the 7-engine × 15-attribute engineering reference.
  2. **Go Code Playground**: Editable Go code templates, offline diagnostic integration, and 5-library Go DB ecosystem comparison.
  3. **API & HTTP Simulator**: Full HTTP method (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`), path preset, header, and JSON body editor with middleware execution trace.
  4. **Concurrency Lab**: Interactive worker-pool parameter controls (`workers`, `jobs`, `context timeout ms`), visual goroutine execution lanes, and concurrency hazard code inspector.
  5. **Architecture Lab**: Interactive selector and comparison across 5 backend architectures.

### FR-4: Real-World Projects & Case Studies
- Present all 14 production case studies with structured navigation across their 15 engineering sections (Problem & Requirements, Architecture & DB Rationale, Schema & Go Implementation, Testing/Security/Performance/Deployment, Mistakes & Alternatives).

### FR-5: Practice Center (Quizzes, Flashcards, Bookmarks, Notes)
- Allow learners to flip and step through active-recall flashcards.
- Provide interactive quizzes that clearly distinguish selected answers, correct answers, incorrect answers, and technical explanations.
- Persist personal engineering notes and lesson bookmarks to `localStorage` (`SafeStore`) and sync with `/api/v1/notes` and `/api/v1/bookmarks` when connected to the Go backend.

### FR-6: Offline Go Code Review & Diagnostics Lab
- Inspect user-supplied Go code offline using deterministic rules (`GO-SEC-001..003`, `GO-DB-001`, `GO-CONC-001..002`, `GO-ERR-001..002`, `GO-PERF-001`) and backend `/api/v1/diagnostics/analyze`.
- Display rule ID, classification (`confirmed_diagnostic`, `potential_issue`, `educational_heuristic`, `no_finding_detected`), severity, line number, why it matters, suggested fix, corrected code example, related lesson link, and official doc link.

---

## 3. Non-Functional Requirements

- **NFR-1 (100% Offline Capability)**: Must work with zero cloud AI services and zero external API keys.
- **NFR-2 (Responsive Across All Viewports)**: Must render cleanly with zero unintended horizontal overflow across `1920×1080`, `1440×900`, `1280×800`, `1024×768`, `768×1024`, `390×844`, and `360×800`.
- **NFR-3 (Accessibility)**: Keyboard-navigable controls, visible `:focus-visible` outlines, semantic landmarks, WCAG AA contrast, and `prefers-reduced-motion: reduce` support.
- **NFR-4 (Backend Compatibility)**: All existing Go HTTP routes, tests (`go test ./...`), and `go vet ./...` checks must continue to pass with zero regressions.
