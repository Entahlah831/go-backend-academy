# Go Backend Academy — Design Requirements (`DESIGN_REQUIREMENTS.md`)

**Last Updated:** 2026-11-07  
**Design Standard:** Hallmark v2.0.0

---

## 1. Product Identity & Aesthetic Direction

Go Backend Academy is a **purpose-built engineering academy and developer workbench**—not a generic SaaS marketing template, not a flashy analytics dashboard, and not a plain static documentation dump.

- **Hallmark Primary Category**: `developer_console_platform_tool` / `documentation_knowledge_workspace`
- **Primary Paradigm**: **P4 — Atmospheric Minimalism & High-Craft Dark UI** (60%) blended with **P2 — Kinetic Typography & Neo-Brutalist Swiss Grids** (25% — exposed hairline `1px solid` structural cells, tabular monospace metadata, disciplined hierarchy) and **P3 — Scrollytelling & Choreographed Motion** (15% — progressive disclosure of complex engineering content).
- **Theme Polarity**: **Dual / Adaptive Default-Dark (`class="dark"` with full Daylight-First Light Mode toggle)**. Defaulting to a carbon-slate high-craft dark workspace (`#090D16` / `#0F1523`) matches the terminal/IDE mental model of backend engineers while providing a crisp warm-paper light mode (`#F8FAFC` / `#FFFFFF`) for daylight reading sessions.

---

## 2. Core Design Principles

1. **Learning Content Is the Primary Focus**: Long technical explanations, ASCII memory/protocol diagrams, and Go/SQL code blocks must have generous breathing room and an optimal reading measure (`60ch–72ch` for prose).
2. **Predictable, Intention-Driven Navigation**: Group the 11 views into 6 clear primary user intentions (**Home**, **Learn**, **Labs**, **Projects**, **Practice**, **Diagnostics**) rather than dumping 11 numbered buttons, 24 lesson links, and a permanent 384px right dock simultaneously.
3. **Progressive Disclosure**: Complex 12-pillar decision analyses, 7-engine × 15-attribute matrices, and 15-section case studies must be organized into scannable tabs/accordions/grouped sections so the learner is never hit with a wall of 15 nested cards at once.
4. **One Dominant Purpose Per Screen**: Eliminate the permanently open right-hand Quick Diagnostics sidebar that stole 320px–384px of horizontal space from every single view; convert it into an on-demand slide-over drawer (`Quick Inspector`) accessible from the header at any time.
5. **Comfortable Interactive Workspaces**: Code editors, SQL query runners, API request builders, and concurrency visualizers must have clean split panes with clear input/execution/output separation.
6. **Zero Visual Bloat or Fake Telemetry**: No decorative pulse dots, no rainbow badge soup, no nested card-in-card-in-card containers, and no invented statistics.

---

## 3. Token Architecture Requirements (Hallmark Floor & Craft)

All colors, fonts, spacing, radii, and elevation rules must be declared as CSS custom properties on `:root` and `html.dark`:

- **Surfaces**:
  - `--bg-canvas` (Base background)
  - `--bg-surface` (Primary card/panel surface)
  - `--bg-elevated` (Elevated control/header/code surface)
  - `--bg-glass` (Sticky header / drawer backdrop with `backdrop-filter: blur(12px)`)
  - `--bg-code` (Dedicated terminal/code block surface)
- **Typography**:
  - `--font-sans`: `'Inter', -apple-system, BlinkMacSystemFont, sans-serif`
  - `--font-display`: `'Inter', -apple-system, BlinkMacSystemFont, sans-serif` (tight tracking `-0.025em`)
  - `--font-mono`: `'JetBrains Mono', ui-monospace, SFMono-Regular, monospace`
  - Numeric alignment: `font-variant-numeric: tabular-nums` on all counters, latencies, line numbers, and progress percentages.
- **Text Hierarchy**:
  - `--text-primary`
  - `--text-secondary`
  - `--text-muted`
- **Accent & Semantic Tokens**:
  - `--accent` (Go Cyan `#00ADD8` / `#0891B2` calibrated for WCAG contrast)
  - `--accent-subtle`
  - `--border-subtle` (`1px solid` structural hairline)
  - `--border-strong`
  - `--status-success`, `--status-warning`, `--status-danger`, `--status-info`
- **Motion & Interaction**:
  - Explicit property transitions only (`transition: background-color 150ms ease, border-color 150ms ease, color 150ms ease, transform 150ms ease`). **Never** `transition: all`.
  - Full `@media (prefers-reduced-motion: reduce)` reset.
  - Accessible `:focus-visible` ring (`2px solid var(--accent)`, `outline-offset: 2px`).
