# Go Backend Academy — Consolidated Curriculum & Content Audit (`CURRICULUM_AUDIT.md`)

> Authoritative consolidated audit document for Curriculum Structure, Pedagogical Depth, Technical Accuracy, and Gaps.

---

## 1. Executive Summary
The Go Backend Academy curriculum encompasses **41 lessons** (24 Core Production Lessons + 17 Beginner/Bridge Stages A–J).
This audit evaluates:
1. Progression from beginner fundamentals to distributed architecture.
2. Technical precision of Go spec guarantees vs. runtime implementation details.
3. Verification suites and exercise validity.

---

## 2. Identified Pedagogical & Technical Gaps

### 2.1 Technical Accuracy Adjustments Needed
1. **Lesson 5.0 (Pillar 7 - SQL Injection Immunity):**
   - *Current claim:* "100% immunity to SQL injection".
   - *Correction:* Parameter binding protects data values, but identifier interpolation (table/column names, `ORDER BY`) cannot be parameterized. White-listing / allowlists must be taught.
2. **Lesson 5.0 (Pillar 10 - Rows.Close & Connection Pools):**
   - *Correction:* Explain that if iteration breaks early before `Next()` returns false, the connection remains leased until `rows.Close()` is called. Always emphasize `defer rows.Close()` and checking `rows.Err()`.
3. **PostgreSQL 17/18 & Index Skip Scan:**
   - *Correction:* Ensure quiz questions clarify database versions (e.g. without skip scan in older versions vs B-tree skips).

---

## 3. Curriculum Progression Matrix

| Level | Topic Range | Difficulty | Hands-on Exercises |
|---|---|---|---|
| L0 | Setup, Backend Basics, HTTP Request Lifecycle | Beginner | 5 |
| L1 | Variables, Control Flow, Collections, Structs, Errors | Beginner-Int | 9 |
| L2 | GMP Scheduler, Concurrency, Channels, pprof | Intermediate | 3 |
| L3 | net/http, ServeMux, Middleware, Validation | Intermediate | 3 |
| L4 | SQL Relational DB, MVCC, Partitioning | Intermediate | 3 |
| L5 | database/sql, pgx, Transactions, Zero-Downtime Migrations | Intermediate | 3 |
| L6 | AuthN/AuthZ, Argon2id, JWT, OAuth2, OWASP API Top 10 | Intermediate-Adv | 3 |
| L7 | Unit Testing, httptest, Testcontainers, Fuzzing | Intermediate-Adv | 3 |
| L8 | Clean, Hexagonal, Modular Monolith, DDD | Advanced | 3 |
| L9 | Redis Caching, Kafka/RabbitMQ/NATS, Outbox Pattern | Advanced | 3 |
| L10 | Docker Multi-stage, K8s Probes, Production Capstone | Senior | 3 |
