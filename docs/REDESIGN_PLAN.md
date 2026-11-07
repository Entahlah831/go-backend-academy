# Go Backend Academy — UI/UX Redesign Plan (`REDESIGN_PLAN.md`)

**Last Updated:** 2026-11-07  
**Design Authority:** Hallmark v2.0.0 (`.agents/skills/hallmark/SKILL.md`)

---

## 1. Redesign Objectives

1. **Eliminate Information Overload & Visual Crowding**:
   - Replace the 11-button flat sidebar + 24-lesson scroll box + permanent 384px right-hand diagnostics column with an intention-grouped navigation architecture (**Home**, **Learn**, **Labs**, **Projects**, **Practice**, **Diagnostics**) and an on-demand **Quick Inspector** drawer.
2. **Establish a Tokenized Hallmark v2.0.0 Design System**:
   - Replace arbitrary Tailwind utility color soup (`emerald`/`amber`/`rose`/`purple`/`indigo`/`sky`/`cyan` scattered across every card) with a strict token-driven palette (`--bg-canvas`, `--bg-surface`, `--bg-elevated`, `--text-primary`, `--text-secondary`, `--text-muted`, `--accent`, `--border-subtle`, `--status-*`).
3. **Elevate the Lesson Reading & Coding Experience**:
   - Provide a comfortable reading measure (`68ch`), clean section hierarchy, progressive disclosure for the 12-Pillar Engineering Analysis, side-by-side code comparison without garish colored backgrounds, and a focused interactive exercise workbench with Previous/Next lesson navigation.
4. **Give Each Interactive Lab a Purpose-Built Workspace**:
   - Organize Labs (**Go Playground**, **SQL & Database Lab**, **API Simulator**, **Concurrency Lab**, **Architecture Lab**) under a unified **Labs** workspace with clean sub-navigation and progressive disclosure for reference matrices.
5. **Preserve 100% of Existing Functionality, Data & Routes**:
   - Keep all DOM element IDs, `PLATFORM_DATA`, `SafeStore` (`gba_v2_*`), exercise verification logic, offline diagnostics rules, and backend REST API calls intact.

---

## 2. Phased Execution Plan

- [x] **Phase 0**: Project discovery, context organization (`docs/*`), and `AGENTS.md` creation.
- [x] **Phase 1**: Install and verify complete Hallmark v2.0.0 skill (`.agents/skills/hallmark/`).
- [x] **Phase 2**: Audit every existing screen and produce `docs/UI_UX_AUDIT.md`.
- [x] **Phase 3 & 4**: Define Hallmark theme deal (`Console`, dealt 2/3) & redesign the Information Architecture (`Home`, `Learn`, `Interactive Labs`, `Engineering Practice`).
- [x] **Phase 5–9**: Implement the design system, layout, navigation, and screen redesigns across `web/index.html`, `web/tokens.css`, `web/base.css`, and `frontend/src/`.
- [x] **Phase 10**: Run Hallmark `sloplint.mjs --render --kept` quality sweep and visual inspection (`0 FAIL, 0 REFLEX, 0 WARN`).
- [x] **Phase 11 & 12**: Run full functional regression testing (`go vet`, `go test`, browser journeys, 7 responsive viewports) and produce `docs/REDESIGN_REPORT.md` & `docs/REDESIGN_TEST_RESULTS.md`.
