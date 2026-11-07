# Go Backend Academy — Technical Content & Accuracy Review (`CONTENT_REVIEW.md`)

**Review Date:** 2026-11-07

## 1. Distinction Between Language Guarantees, Runtime Details & Database Behavior

All 24 curriculum lessons and 14 case studies have been audited and updated to separate:

1. **Go Language Specification Guarantees ([go.dev/ref/spec](https://go.dev/ref/spec))**:
   * Evaluation order, zero values, interface satisfaction, slice header semantics, `defer` LIFO execution per function, and memory-model happens-before edges (`sync`, channel send/receive).
2. **Go `gc` Runtime Implementation Details ([go.dev/doc/gc-guide](https://go.dev/doc/gc-guide))**:
   * 2KB initial goroutine stack size, GMP work-stealing queues (local run queue size 256), ~10ms asynchronous `SIGURG` preemption (Go 1.14+), escape analysis heuristics (`-gcflags="-m"`), and concurrent tri-color mark-and-sweep GC pacing with `GOGC` and `GOMEMLIMIT` (Go 1.19+).
3. **Database Engine-Specific Behavior**:
   * **Isolation Levels**: PostgreSQL defaults to `READ COMMITTED` and uses Serializable Snapshot Isolation (SSI) for `SERIALIZABLE` ([PostgreSQL MVCC Docs](https://www.postgresql.org/docs/current/mvcc-intro.html)); MySQL InnoDB defaults to `REPEATABLE READ` using Undo Logs and next-key locks ([MySQL Reference Manual](https://dev.mysql.com/doc/)).
   * **PostgreSQL Row-Level Security (RLS)**: Updated Case Study #12 and Level 4/6 notes to emphasize that table owners and superusers bypass RLS unless `ALTER TABLE ... FORCE ROW LEVEL SECURITY` is enabled AND the application connects via a non-superuser role (`NOBYPASSRLS`), using transaction-scoped `set_config('app.current_tenant_id', $1, true)` (`SET LOCAL`) so pooled connections never leak tenant state.
   * **OWASP API Security Top 10 (2023) Mapping ([OWASP API Top 10](https://api-security.owasp.org/editions/2023/en/0x11-t10/))**: Clarified that in the 2023 edition, SQL Injection is categorized under general injection/unsafe consumption and OWASP Web Top 10 (`A03:2021 Injection`), while `API8:2023` is **Security Misconfiguration**, `API1:2023` is **Broken Object Level Authorization (BOLA)**, `API3:2023` is **Broken Object Property Level Authorization (BOPLA / Mass Assignment)**, `API4:2023` is **Unrestricted Resource Consumption**, and `API7:2023` is **Server-Side Request Forgery (SSRF)**.
   * **Benchmark Honesty**: Removed any uncontextualized latency numbers and added explicit workload, row-count (1,000,000 rows), buffer cache state (`shared hit` vs `read`), and hardware/measurement assumptions to every `EXPLAIN (ANALYZE, BUFFERS)` example.
