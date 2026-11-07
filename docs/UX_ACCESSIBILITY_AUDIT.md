# Go Backend Academy — UX, Cognitive Load & Hallmark Frontend Audit

This audit evaluates the frontend (`web/index.html`, `web/styles/tokens.css`, `web/styles/base.css`, `web/curriculum-stages.js`, `web/app-bridge.js`) against both **Learner UX / Cognitive Load Research** and the repository's **Hallmark `v2.0.0` (`flow.md` § App screens & `The Floor`)** design standards.

---

## 1. Root Cause Diagnosis: Why the Frontend Feels Cluttered & Unfocused

### Finding `P0-UX-001` — 11 Competing Sidebar Views + 36 Lesson Links + Right Diagnostics Dock ("3-Column Cockpit Clutter")
- **Observed**:
  - Left sidebar (`#left-sidebar`) renders **11 numbered navigation buttons** (`1. Dashboard` through `11. Practice Center`), followed immediately by `#sidebar-curriculum-list` (all 36 lessons), followed by 6 external doc links.
  - On the Dashboard (`#view-dashboard`), the right-hand **Offline Diagnostics Inspector Dock (`#right-diag-panel`)** is open by default (`dp.classList.toggle('hidden', viewName !== 'dashboard')`), creating a cramped 3-column layout where a code linter competes with the welcome hero and 4 metric cards.
- **Hallmark Violation (`flow.md` § App screens & Gate 42/58)**:
  - Hallmark specifies: *"The bar is earned familiarity: the tool disappears into the task... Colour is restrained. The accent marks the primary action, the current selection and state, nothing else... A sidebar is earned by more than about seven destinations, never reached for by reflex."*
- **Concrete Fix**:
  1. **Consolidate 11 Sidebar Views into 4 Primary Workspace Modes**:
     - **1. Learn (Curriculum & Path)** — Default focused learning workspace with a clean collapsible Level 0–10 curriculum tree in the sidebar.
     - **2. Interactive Labs (5 Sandboxes)** — One unified view with a clean segmented switcher for `SQL Lab`, `HTTP Simulator`, `Go Playground`, `Concurrency Sim`, and `Diagnostics Lab`.
     - **3. Case Studies (14 Blueprints & Architecture)** — Combines the 14 production case studies and 5-architecture comparison lab.
     - **4. Practice & Review (Quizzes, Flashcards & Overview)** — Active recall and progress telemetry.
  2. **Hide `#right-diag-panel` by Default on ALL Screens**: The right-hand Diagnostics Inspector must remain closed (`class="diag-pane hidden"`) until the user explicitly clicks the topbar `Inspector` toggle button.

### Finding `P0-UX-002` — 8 Stacked Mega-Cards Inside Curriculum View (`#view-curriculum`) With Zero Progressive Disclosure
- **Observed**:
  - Opening any lesson in `#view-curriculum` renders **8 full-width cards stacked vertically** (~2,500+ words on a single scroll), including **all 12 Engineering Decision Pillars expanded at once in a 3-column grid (`#lesson-pillars-grid`)** right above two side-by-side code editors and an interactive exercise runner.
  - Learners do not know whether to answer the `Quick Mastery Check` at the top, read the `Beginner Overview`, read the 12 pillar cards, compare the anti-pattern code, or type into the Exercise Runner at the bottom.
- **Concrete Fix (Guided 4-Step Lesson Tab / Stepper Layout)**:
  - Inside `#view-curriculum`, organize the lesson body into a **4-Step Guided Learning Flow Bar** right below the lesson title header:
    - **Step 1: Concept & Mental Model** — Shows the 3-Tier Explanation (`1. Beginner Overview` active by default, with a clear `"Continue to Step 2: Code Comparison →"` button) + Internal Mechanics Diagram + a collapsible/tabbed **12-Point Engineering Deep Dive** (showing 4 cards at a time: `Core Mechanics (1–4)` by default instead of all 12 at once).
    - **Step 2: Anti-Pattern vs Production Code** — Focused side-by-side code comparison with Failure Analysis and Engineering Reasoning.
    - **Step 3: Hands-On Coding Exercise** — Clean split-screen coding workspace (Task, Test Cases & Hints on the left; Code Editor & Verification Output on the right).
    - **Step 4: Mastery Check & Notes** — The interactive Knowledge Check question, Personal Notes, and `"Next Lesson →"` progression button.
  - Provide a `"Show All Sections (Single-Page View)"` toggle for senior engineers who prefer continuous scrolling, while keeping **Guided Step Mode** as the clean default!

### Finding `P1-UX-003` — Hallmark Floor Violations in `web/index.html` Inline `<style>`
- **Observed**:
  - While `web/styles/tokens.css` and `web/styles/base.css` have the Hallmark v2.0.0 stamp, `web/index.html` still contains a 900-line inline `<style>` block with tracked uppercase labels (`text-transform: uppercase; letter-spacing: 0.06em;` on `.nav-group-label`, `.telemetry-label`, `.pillar-num`), violating Hallmark Floor Rule #9 (*"Never an eyebrow, and never a label in tracked capitals or small caps: labels, captions, table heads, tags and nav links are the body face, a step smaller, sentence or lower case, untracked"*).
  - Multiple competing colored pills (`.tag-pill.ok`, `.tag-pill.cool`, `.tag-pill.accent`, `.btn-cool`, `.btn-ok`, `.btn-primary`) appear simultaneously in the same card header, violating Hallmark's restrained accent rule (*"The accent marks the primary action, the current selection and state, nothing else"*).

---

## 2. Accessibility & Responsive Audit Checklist

| Criterion | Status in `v2.4.0` | Observed Evidence & Required Improvement |
| :--- | :--- | :--- |
| **Keyboard Focus (`:focus-visible`)** | PASS | `tokens.css` / `base.css` and `index.html` define instantaneous `2px solid` `:focus-visible` outlines. |
| **Reduced Motion (`prefers-reduced-motion`)** | PASS | `@media (prefers-reduced-motion: reduce)` disables transitions/animations cleanly. |
| **Reading Measure (`60ch–75ch`)** | PARTIAL (`P2-UX-004`) | Prose inside `#lesson-tier-content` stretches across the full width of the center pane (`>100ch` on 1440p monitors when the right dock is closed). Cap prose containers at `max-width: 72ch`. |
| **Mobile Responsive Layout (`375px`)** | PARTIAL (`P2-UX-005`) | Sidebar collapses into `#btn-mobile-menu`, but `.grid-3` (12 pillars) and side-by-side code comparison cards require earlier breakpoint stacking at `960px` so horizontal code lines do not wrap awkwardly. |
