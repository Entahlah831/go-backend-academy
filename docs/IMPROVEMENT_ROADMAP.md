# Go Backend Academy — Improvement Roadmap (`IMPROVEMENT_ROADMAP.md`)

**Last Updated:** 2026-11-07  
**Current Release:** v2.1 (Post-Audit Remediated Release)

---

## 1. Completed Milestones (v2.0 → v2.1 Remediation)

- [x] **P0 — Toolchain & Compiler Cleanliness**: `go vet ./...`, `go build`, and `go test -v ./...` pass with 0 warnings and 0 errors.
- [x] **P0 — Database Referential Integrity & Constraint Enforcement**: Separate verified PostgreSQL 17+ and SQLite 3.40+ migrations/seeds, automatic user provisioning (`ensureUser`), strict handler/store validation for `status` (`in_progress` | `completed`) and `item_type` (`lesson` | `case_study` | `db_scenario`), and collision-free unique exercise attempt IDs (`att_<ex>_<hex>_<seq>`).
- [x] **P1 — Comment-Stuffing & Signature-Bypass Resistant Exercise Grader**: Both the browser grader (`web/index.html`) and backend verifier (`internal/modules/exercises/service.go`) strip Go line/block comments before checking implementation invariants (`0/24` comment-stuffed pass, `0/24` starter-no-STEP pass, `24/24` solution pass).
- [x] **P1 — Scope- & Statement-Aware Offline Go Diagnostics Lab**: Upgraded `internal/modules/diagnostics/analyzer.go` and browser offline analyzer to eliminate false positives (`FP1` package-level `regexp.MustCompile`, `FP2` parameterized SQL with `fmt.Sprintf` in logging) and catch false negatives (`FN1` SQL `+` concatenation, `FN2` `rows` leak masked by unrelated `.Close()`, `FN3` goroutine shared-variable data race `GO-CONC-002`, `FN4` comment-masked goroutine leak `GO-CONC-001`, `FN5` `&http.Client{}` without `Timeout` `GO-SEC-003`, `FN6` discarded `_` error `GO-ERR-002`).
- [x] **P2 — Verified Curriculum Code Snippets**: All 24 lesson solutions and corrected examples are `gofmt`-formatted and `go vet`-verified, including `addr.Unmap()` for IPv4-mapped IPv6 SSRF protection in Level 6.1 and proper `for`/`select` cancellation in Level 2.1.

---

## 2. Short-Term Engineering Roadmap (Next Iteration)

1. **Full `go/ast` & `go/types` Analyzer Passes in `internal/modules/diagnostics`**:
   * Extend the Go backend analyzer with dedicated `go/ast.Inspect` passes for struct-tag validation, `context.Context` parameter ordering, and `defer` inside `for` loops (`GO-PERF-002`).
2. **Sandboxed `go test` Runner for Lesson Exercises**:
   * When `ENABLE_LOCAL_GO_TOOLCHAIN=true` on a local developer machine, optionally execute table-driven unit tests against the learner's submitted exercise function inside an isolated temporary module directory (`go test -timeout 2s`) with network access disabled.
3. ** automated Vite Bundle Build Pipeline**:
   * Add a `make build-frontend` target that compiles `frontend/src/` directly into `web/index.html` using `vite-plugin-singlefile` so changes in `frontend/src/` and `web/index.html` stay automatically synchronized in CI.

---

## 3. Medium-Term Architecture & Content Roadmap

1. **Interactive PostgreSQL `EXPLAIN (ANALYZE, BUFFERS)` Plan Diff Visualizer**:
   * Add a visual tree comparator in the SQL Playground showing side-by-side `Seq Scan` vs `Bitmap Heap Scan` vs `Index Only Scan` node costs, `Heap Fetches`, and shared buffer hits.
2. **Expanded Distributed Systems Labs (Level 9)**:
   * Add interactive state-machine stepping for Transactional Outbox + CDC relay recovery and Saga compensating transaction idempotency under network partition scenarios.
3. **Optional Local Ollama Code Review Explanation Comparison**:
   * When a user explicitly sets `AI_PROVIDER=ollama` locally, display optional local model explanations in a secondary collapsible panel strictly separated from deterministic `go vet` and `GO-*` static rule findings.
