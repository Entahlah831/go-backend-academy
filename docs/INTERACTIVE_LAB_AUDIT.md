# Go Backend Academy — Consolidated Interactive Labs Audit (`INTERACTIVE_LAB_AUDIT.md`)

> Authoritative consolidated audit document for Interactive Labs: SQL Playground, HTTP Simulator, Concurrency Lab, and Diagnostics Lab.

---

## 1. Executive Summary
The interactive labs provide simulation and sandbox capabilities to explore runtime backend behavior without third-party dependencies:
1. **SQL Playground & Database Sandbox**
2. **HTTP Lifecycle & Middleware Simulator**
3. **Concurrency & GMP Scheduler Lab**
4. **Architecture Comparison Lab (5 Patterns)**
5. **Go Code Review & Diagnostics Lab**

---

## 2. Lab Status & Technical Findings

### 2.1 SQL Playground (F-10)
- **Current State:** Runs in-memory queries against sample e-commerce schema (`customers`, `orders`, `order_items`, `outbox_events`).
- **Remediation Plan:**
  - Enforce `PRAGMA query_only = ON` at SQLite engine level.
  - Implement statement keyword filtering (`SELECT`, `WITH`, `EXPLAIN`).
  - Block administrative tokens (`ATTACH`, `DETACH`, `PRAGMA`, `load_extension`).
  - Generate a scaled ~50,000 row dataset with recursive CTE for demonstrable index selectivity impact.

### 2.2 Concurrency Lab
- Visualizes GMP scheduler, worker pools, buffered vs. unbuffered channel blocks, and mutex deadlocks.
- Simulation parameters (workers, jobs, timeout) respond to user slider adjustments.

### 2.3 Diagnostics Lab (F-04, F-09)
- Operates in `AI_PROVIDER=none` mode (100% offline deterministic static analysis).
- Includes AST-based and regex rules:
  - `GO-SEC-001`: SQL Injection
  - `GO-SEC-002`: Path Traversal
  - `GO-SEC-003`: Hardcoded JWT Secret
  - `GO-SEC-007`: Hardcoded Secret / Credential Literal
  - `GO-HTTP-001`: Hardcoded Network Port
  - `GO-DB-001`: Unclosed `sql.Rows`
  - `GO-CONC-001`: Concurrent Variable Mutation without Mutex
  - `GO-ERR-001`: Unhandled Error
  - `GO-PERF-001`: String Concatenation in Loop
- Local `go vet` execution uses isolated sandboxing with process concurrency limits.
