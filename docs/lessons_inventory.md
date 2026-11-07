# Go Backend Academy — Lessons Inventory (T0.2)

> Generated: November 7, 2026  
> Authoritative source: `seed/sqlite/001_seed_data.sql`, `seed/sqlite/002_beginner_stages_seed.sql`, and `seed/sqlite/003_v2_5_stage_bridges_and_sections.sql`.  
> Total Lessons: **41 lessons** (24 Core Production Lessons + 17 Beginner/Bridge Stages A–J).

---

## 1. Executive Mapping to Master Plan Target (Section 5.2)

The Master Plan identifies 24 curriculum targets (Level 0 to Level 10). The Go Backend Academy platform covers all 24 targets, expanded across 41 curated lessons with explicit prerequisites and learning outcomes:

| Level | Plan Slot | Master Plan Target | Existing Lesson ID(s) | Title in Platform | Status |
|---|---|---|---|---|---|
| **0** | **0.1** | Setup & cara kerja Go | `l0-stage-a-what-is-backend`<br>`l0-stage-a-git-go-workspace`<br>`l0-backend-http-lifecycle` | 0.0A What is a Backend?<br>0.0B Installing Go & First main.go<br>0.1 Client-Server Architecture & HTTP Lifecycle | ✅ Exceeds (3 lessons) |
| **0** | **0.2** | Architecture & Stateless Concepts | `l0-stateless-vs-stateful-arch`<br>`l0-rest-json-api-contracts` | 0.2 Stateless vs Stateful Systems<br>0.3 REST Idempotency & JSON API Contracts | ✅ Complete |
| **1** | **1.1** | Tipe, variabel, fungsi, control flow | `l1-stage-b-variables-types-zerovalues`<br>`l1-stage-b-control-flow-loops-functions` | 1.0A Go Variables, Types & Zero Values<br>1.0B Conditionals, Loops, Functions & Multi-returns | ✅ Complete |
| **1** | **1.2** | Slice, map, struct, pointer | `l1-stage-b-slices-maps-iteration`<br>`l1-stage-b-structs-methods-pointers`<br>`l1-memory-slices-maps-escape` | 1.0C Arrays, Slices, Maps & Range Loops<br>1.0D Structs, Methods & Value vs Pointer Receivers<br>1.1 Slices, Maps, Escape Analysis & Memory | ✅ Exceeds (3 lessons) |
| **2** | **2.1** | Error handling | `l1-stage-b-interfaces-errors-fundamentals`<br>`l1-interfaces-errors-generics` | 1.0E Explicit Error Handling, Custom Errors & Defer<br>1.2 Implicit Interfaces, Errors as Values & Generics | ✅ Complete |
| **2** | **2.2** | Interface & composition | `l1-stage-b-interfaces-errors-fundamentals`<br>`l1-interfaces-errors-generics` | 1.0E Interfaces & Defer<br>1.2 Implicit Interfaces & Composition | ✅ Complete |
| **2** | **2.3** | Package, module, testing dasar | `l1-toolchain-modules-packages`<br>`l1-stage-b-json-files-unit-testing` | 1.0 Toolchain, MVS & internal/ Packages<br>1.0F JSON Tags, File I/O & First Go Test | ✅ Complete |
| **3** | **3.1** | HTTP server dengan `net/http` | `l3-stage-d-first-http-server-crud`<br>`l3-net-http-routers` | 3.0 Building Your First Go HTTP Server: Handlers & ServeMux<br>3.1 net/http (Go 1.22+) vs Chi, Gin & Fiber | ✅ Exceeds (2 lessons) |
| **3** | **3.2** | JSON, validasi, batas ukuran body | `l3-validation-openapi-ratelimit` | 3.2 Request Validation, Rate Limiting & OpenAPI 3.1 | ✅ Complete |
| **3** | **3.3** | Middleware & `context` | `l3-net-http-routers` (Sections 2–4) | 3.1 Middleware Patterns & Graceful Shutdown | ✅ Complete |
| **4** | **4.1** | SQL dasar & desain tabel | `l4-stage-e-sql-relational-fundamentals`<br>`l4-acid-isolation-mvcc` | 4.0 SQL from Scratch: Keys, Normalization & JOINs<br>4.1 Relational vs NoSQL, MVCC, ACID & Indexes | ✅ Exceeds (2 lessons) |
| **4** | **4.2** | `database/sql` aman | `l5-stage-e-database-sql-crud-basics`<br>`l5-db-ecosystem-comparison` | 5.0 Connecting Go to SQL: Scan, Params & Tx<br>5.1 database/sql vs pgx/v5 vs sqlc vs ORMs | ✅ Exceeds (2 lessons) |
| **4** | **4.3** | Transaction & migration | `l5-migrations-transactions-prepared`<br>`l4-partitioning-replication-sharding` | 5.2 Zero-Downtime SQL Migrations & Prepared Statements<br>4.2 Replication Lag, Sharding & PITR | ✅ Complete |
| **5** | **5.1** | Goroutine & channel | `l2-stage-c-goroutines-channels-waitgroup` | 2.0 Concurrency 101: Goroutines, Buffered Channels & WaitGroup | ✅ Complete |
| **5** | **5.2** | `sync`, race, mutex | `l2-gmp-channels-context-workers` | 2.1 GMP Scheduler, Select, Mutexes & Worker Pools | ✅ Complete |
| **5** | **5.3** | `context` & worker pool | `l2-gmp-channels-context-workers` | 2.1 Context Cancellation & Bounded Worker Pools | ✅ Complete |
| **6** | **6.1** | Testing HTTP & DB | `l7-stage-g-table-driven-tests-httptest`<br>`l7-testing-fuzzing-benchmarks`<br>`l7-integration-testcontainers-ci` | 7.0 Testing 101: Table-Driven Unit Tests<br>7.1 Table-Driven Tests, httptest, Testcontainers<br>7.2 Fakes vs Mocks, Real DB Testing & CI | ✅ Exceeds (3 lessons) |
| **6** | **6.2** | Profiling & benchmark | `l2-profiling-pprof-benchmarks` | 2.2 CPU/Heap pprof, sync.Pool, Contention Profiling | ✅ Complete |
| **7** | **7.1** | Keamanan API (OWASP API Top 10) | `l6-security-auth-owasp` | 6.1 Argon2id, JWT vs Sessions, RBAC, SQLi & OWASP Top 10 | ✅ Complete |
| **7** | **7.2** | AuthN/AuthZ | `l6-stage-f-password-hashing-bearer-auth`<br>`l6-oauth2-oidc-rbac-abac` | 6.0 Security 101: Password Hashing & Bearer Tokens<br>6.2 OAuth 2.0 with PKCE, OIDC & Secrets Rotation | ✅ Exceeds (2 lessons) |
| **8** | **8.1** | Layered → Hexagonal | `l8-stage-h-handler-service-repo-layers`<br>`l8-clean-hexagonal-ddd` | 8.0 Architecture 101: Handler, Service & Repository Layers<br>8.1 Layered vs Clean vs Hexagonal (Ports & Adapters) | ✅ Exceeds (2 lessons) |
| **8** | **8.2** | Modular monolith vs microservices | `l8-modular-monolith-cqrs-boundaries` | 8.2 Enforcing Modular Monolith Boundaries & CQRS | ✅ Complete |
| **9** | **9.1** | Config, logging, observability | `l9-caching-queues-outbox-sagas`<br>`l9-grpc-websockets-otel-tracing` | 9.1 Redis Caching, Kafka, Outbox & OpenTelemetry<br>9.2 gRPC & Protobuf Contracts, WebSockets & Distributed Tracing | ✅ Complete |
| **9** | **9.2** | Graceful shutdown, Docker, deploy | `l10-devops-docker-k8s-production`<br>`l10-reverse-proxy-cicd-rollback-dr` | 10.1 Multi-Stage Distroless Docker Builds & K8s Probes<br>10.2 Caddy/Nginx Reverse Proxies, Canary & Rollbacks | ✅ Complete |
| **10** | **10.1** | Capstone | `l10-stage-j-capstone-production-blueprint` | 10.3 Progressive Capstone: CLI & CRUD to Production Distributed Service | ✅ Complete |

---

## 2. Complete Inventory of All 41 Lessons in Repository

### Stage A & Level 0: Foundations & Architecture (5 lessons)
1. `l0-stage-a-what-is-backend` (Level 1 / Order 1) — *0.0A What is a Backend? Servers, Terminal, Files, Processes & Ports*
   - Prerequisites: None
   - Difficulty: Beginner
2. `l0-stage-a-git-go-workspace` (Level 1 / Order 2) — *0.0B Installing Go, Terminal Commands, Git Basics & Your First main.go*
   - Prerequisites: Terminal basics
   - Difficulty: Beginner
3. `l0-backend-http-lifecycle` (Level 1 / Order 1) — *0.1 Client-Server Architecture, DNS/TCP/TLS & HTTP Request Lifecycle*
   - Prerequisites: None
   - Difficulty: Beginner
4. `l0-stateless-vs-stateful-arch` (Level 1 / Order 2) — *0.2 Stateless vs Stateful Systems, AuthN vs AuthZ & Monolith vs Microservices*
   - Prerequisites: HTTP basics
   - Difficulty: Beginner-Intermediate
5. `l0-rest-json-api-contracts` (Level 1 / Order 3) — *0.3 REST Idempotency, JSON Marshaling Internals & Backward-Compatible API Contracts*
   - Prerequisites: HTTP verbs
   - Difficulty: Intermediate

### Stage B & Level 1: Go Language Mastery (9 lessons)
6. `l1-stage-b-variables-types-zerovalues` (Level 2 / Order 1) — *1.0A Go Variables, Primitive Types, Zero Values & Formatting (fmt)*
   - Prerequisites: Go installed
   - Difficulty: Beginner
7. `l1-stage-b-control-flow-loops-functions` (Level 2 / Order 2) — *1.0B Conditionals (if/switch), For Loops, Functions & Multiple Return Values*
   - Prerequisites: Variables & types
   - Difficulty: Beginner
8. `l1-stage-b-slices-maps-iteration` (Level 2 / Order 3) — *1.0C Working with Collections: Arrays, Slices, Maps & Range Loops*
   - Prerequisites: Loops & functions
   - Difficulty: Beginner
9. `l1-stage-b-structs-methods-pointers` (Level 2 / Order 4) — *1.0D Structs, Methods, Value vs Pointer Receivers & Safe Nil Checks*
   - Prerequisites: Collections
   - Difficulty: Beginner-Intermediate
10. `l1-stage-b-interfaces-errors-fundamentals` (Level 2 / Order 5) — *1.0E Interfaces, Explicit Error Handling, Custom Errors & Defer*
    - Prerequisites: Structs & pointers
    - Difficulty: Beginner-Intermediate
11. `l1-stage-b-json-files-unit-testing` (Level 2 / Order 6) — *1.0F JSON Struct Tags, File I/O, Environment Variables & Your First Go Test*
    - Prerequisites: Interfaces & error handling
    - Difficulty: Beginner-Intermediate
12. `l1-toolchain-modules-packages` (Level 2 / Order 4) — *1.0 Go Toolchain, Module Minimal Version Selection (MVS), internal/ Packages & Struct Layout*
    - Prerequisites: Basic Go
    - Difficulty: Intermediate
13. `l1-memory-slices-maps-escape` (Level 2 / Order 5) — *1.1 Slices, Maps, Pointers, Stack vs Heap & Escape Analysis*
    - Prerequisites: Memory concepts
    - Difficulty: Intermediate-Advanced
14. `l1-interfaces-errors-generics` (Level 2 / Order 6) — *1.2 Implicit Interfaces, Composition, Errors as Values & Generics*
    - Prerequisites: Type system
    - Difficulty: Advanced

### Stage C & Level 2: Concurrency & Runtime Internals (3 lessons)
15. `l2-stage-c-goroutines-channels-waitgroup` (Level 3 / Order 0) — *2.0 Concurrency 101: Your First Goroutine, Buffered Channels & sync.WaitGroup*
    - Prerequisites: Go functions & error handling
    - Difficulty: Beginner-Intermediate
16. `l2-gmp-channels-context-workers` (Level 3 / Order 7) — *2.1 GMP Scheduler, Channels, Select, Mutexes, Context & Bounded Worker Pools*
    - Prerequisites: Goroutine basics
    - Difficulty: Intermediate-Advanced
17. `l2-profiling-pprof-benchmarks` (Level 3 / Order 8) — *2.2 CPU & Heap Profiling (pprof), sync.Pool, Contention Profiling & Execution Tracer*
    - Prerequisites: Concurrency & benchmarking
    - Difficulty: Advanced

### Stage D & Level 3: HTTP Services, Routing & API Contracts (3 lessons)
18. `l3-stage-d-first-http-server-crud` (Level 4 / Order 0) — *3.0 Building Your First Go HTTP Server: Handlers, ServeMux, Status Codes & JSON CRUD*
    - Prerequisites: Basic structs, methods & JSON
    - Difficulty: Beginner-Intermediate
19. `l3-net-http-routers` (Level 4 / Order 9) — *3.1 Standard net/http (Go 1.22+) vs Chi, Gin, Echo & Fiber + Middleware & Graceful Shutdown*
    - Prerequisites: HTTP basics
    - Difficulty: Intermediate
20. `l3-validation-openapi-ratelimit` (Level 4 / Order 10) — *3.2 Request Validation, Token-Bucket Rate Limiting, CORS Allowlists & OpenAPI 3.1 Contracts*
    - Prerequisites: net/http & middleware
    - Difficulty: Intermediate-Advanced

### Stage E & Level 4: Database Internals, SQL & Schema Design (3 lessons)
21. `l4-stage-e-sql-relational-fundamentals` (Level 5 / Order 0) — *4.0 SQL from Scratch: Tables, Primary/Foreign Keys, SELECT, WHERE, JOIN, GROUP BY & Normalization*
    - Prerequisites: Basic data modeling
    - Difficulty: Beginner
22. `l4-acid-isolation-mvcc` (Level 5 / Order 11) — *4.1 Relational vs NoSQL Internals, MVCC, ACID Isolation Levels, Indexing & EXPLAIN ANALYZE*
    - Prerequisites: SQL basics
    - Difficulty: Intermediate-Advanced
23. `l4-partitioning-replication-sharding` (Level 5 / Order 12) — *4.2 Streaming Replication Lag, Declarative Partitioning, Sharding & Point-in-Time Recovery (PITR)*
    - Prerequisites: Relational storage
    - Difficulty: Advanced

### Stage E (Continued) & Level 5: Go Database Engineering & ORMs (3 lessons)
24. `l5-stage-e-database-sql-crud-basics` (Level 6 / Order 0) — *5.0 Connecting Go to SQL: database/sql, QueryContext, Scan, Parameterized Queries & Transactions*
    - Prerequisites: SQL queries & Go interfaces
    - Difficulty: Beginner-Intermediate
25. `l5-db-ecosystem-comparison` (Level 6 / Order 13) — *5.1 database/sql vs pgx/v5 vs sqlc vs GORM vs Ent vs Bun & Pool Internals*
    - Prerequisites: database/sql basics
    - Difficulty: Intermediate
26. `l5-migrations-transactions-prepared` (Level 6 / Order 14) — *5.2 Expand-and-Contract Zero-Downtime SQL Migrations, Prepared Statements & Transaction Scopes*
    - Prerequisites: Transactions & SQL schema
    - Difficulty: Intermediate-Advanced

### Stage F & Level 6: Security, Cryptography & Auth (3 lessons)
27. `l6-stage-f-password-hashing-bearer-auth` (Level 7 / Order 0) — *6.0 Security 101: Password Hashing, Bearer Tokens & HTTP Auth Middleware*
    - Prerequisites: HTTP middleware & database CRUD
    - Difficulty: Beginner-Intermediate
28. `l6-security-auth-owasp` (Level 7 / Order 15) — *6.1 Argon2id, JWT vs Sessions, OAuth2/OIDC, RBAC, SQLi/SSRF/XSS/CSRF & OWASP API Top 10*
    - Prerequisites: Auth basics
    - Difficulty: Intermediate-Advanced
29. `l6-oauth2-oidc-rbac-abac` (Level 7 / Order 16) — *6.2 OAuth 2.0 with PKCE, OpenID Connect (JWKS), RBAC vs ABAC & Secrets Rotation*
    - Prerequisites: JWT & API security
    - Difficulty: Advanced

### Stage G & Level 7: Testing, Verification & Fuzzing (3 lessons)
30. `l7-stage-g-table-driven-tests-httptest` (Level 8 / Order 0) — *7.0 Testing 101: Writing Table-Driven Unit Tests & Testable Pure Functions*
    - Prerequisites: Functions & structs
    - Difficulty: Beginner-Intermediate
31. `l7-testing-fuzzing-benchmarks` (Level 8 / Order 17) — *7.1 Table-Driven Tests, httptest, Testcontainers, Fuzzing & Benchmarking*
    - Prerequisites: Unit testing
    - Difficulty: Intermediate
32. `l7-integration-testcontainers-ci` (Level 8 / Order 18) — *7.2 Fakes vs Mocks, Real Database Integration Testing & Reproducible CI Pipelines*
    - Prerequisites: Docker & testing
    - Difficulty: Advanced

### Stage H & Level 8: Architecture, Clean Code & Boundaries (3 lessons)
33. `l8-stage-h-handler-service-repo-layers` (Level 9 / Order 0) — *8.0 Architecture 101: Separating Handler, Service & Repository Without Boilerplate*
    - Prerequisites: HTTP handlers & database CRUD
    - Difficulty: Beginner-Intermediate
34. `l8-clean-hexagonal-ddd` (Level 9 / Order 19) — *8.1 Layered vs Clean vs Hexagonal (Ports & Adapters), DDD, CQRS & Modular Monolith*
    - Prerequisites: Architectural layering
    - Difficulty: Intermediate-Advanced
35. `l8-modular-monolith-cqrs-boundaries` (Level 9 / Order 20) — *8.2 Enforcing Modular Monolith Boundaries, CQRS Read Models & Domain Modeling*
    - Prerequisites: Hexagonal architecture
    - Difficulty: Advanced

### Stage I & Level 9: Distributed Systems, Caching & Messaging (3 lessons)
36. `l9-stage-i-redis-cache-aside-backoff` (Level 10 / Order 0) — *9.0 Distributed 101: Redis Cache-Aside Mental Model & Exponential Backoff Retries*
    - Prerequisites: HTTP services & error handling
    - Difficulty: Beginner-Intermediate
37. `l9-caching-queues-outbox-sagas` (Level 10 / Order 21) — *9.1 Redis Caching (Singleflight), Kafka vs RabbitMQ vs NATS, Outbox Pattern, Sagas & OpenTelemetry*
    - Prerequisites: Redis & messaging
    - Difficulty: Intermediate-Advanced
38. `l9-grpc-websockets-otel-tracing` (Level 10 / Order 22) — *9.2 gRPC & Protobuf Contracts, WebSockets vs SSE & OpenTelemetry Distributed Tracing*
    - Prerequisites: Distributed tracing & streaming
    - Difficulty: Advanced

### Stage J & Level 10: DevOps, Production Readiness & Capstone (3 lessons)
39. `l10-devops-docker-k8s-production` (Level 11 / Order 23) — *10.1 Multi-Stage Distroless Docker Builds, Kubernetes Probes, Caddy/Nginx & Disaster Recovery*
    - Prerequisites: Go binary building & Docker
    - Difficulty: Intermediate-Advanced
40. `l10-reverse-proxy-cicd-rollback-dr` (Level 11 / Order 24) — *10.2 Caddy & Nginx Reverse Proxies, Trusted X-Forwarded-For, Canary Rollbacks & Disaster Recovery*
    - Prerequisites: Production deployment
    - Difficulty: Advanced
41. `l10-stage-j-capstone-production-blueprint` (Level 11 / Order 99) — *10.3 Progressive Capstone Roadmap: From CLI & CRUD API to Production Distributed Service*
    - Prerequisites: Levels 0–9
    - Difficulty: Capstone / Senior
