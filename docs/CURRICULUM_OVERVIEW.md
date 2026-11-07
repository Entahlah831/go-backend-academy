# Go Backend Academy — Curriculum Overview (`CURRICULUM_OVERVIEW.md`)

**Last Updated:** 2026-11-07  
**Total Levels:** 11 (`Level 0` – `Level 10`)  
**Total Modules:** 22  
**Total Lessons:** 24 (`24/24` with interactive exercises, 3-tier explanations, 12-pillar matrices, and verified official references)  
**Total Production Case Studies:** 14 (`15` engineering sections each)  
**Total Database Scenarios:** 10 across 7 database engines (`15` attributes per engine)

---

## 1. Complete Curriculum Map (Levels 0–10 → 24 Lessons)

| Level | Lesson ID | Title | Difficulty | Primary Focus & Exercise |
| :---: | :--- | :--- | :---: | :--- |
| **0** | `l0-backend-http-lifecycle` | **0.1 Client-Server Architecture, DNS/TCP/TLS & HTTP Request Lifecycle** | Beginner | DNS/TCP/TLS 1.3 handshakes, Go netpoller (`epoll`/`kqueue`), `http.Server` timeouts, `http.MaxBytesReader`. |
| **0** | `l0-stateless-vs-stateful-arch` | **0.2 Stateless vs Stateful Systems, AuthN vs AuthZ & Monolith vs Microservices** | Beginner | Stateless compute tiers, horizontal scaling, AuthN vs. Object-Level AuthZ (`BOLA`). |
| **0** | `l0-rest-json-api-contracts` | **0.3 REST Idempotency, JSON Marshaling Internals & Backward-Compatible API Contracts** | Beginner | HTTP method idempotency, pointer DTOs for `PATCH`, `DisallowUnknownFields()`. |
| **1** | `l1-toolchain-modules-packages` | **1.0 Go Toolchain, Module MVS, `internal/` Packages & Struct Layout** | Beginner | Minimal Version Selection, `internal/` visibility, UTF-8 rune decoding (`utf8.DecodeRuneInString`), struct padding. |
| **1** | `l1-memory-slices-maps-escape` | **1.1 Slices, Maps, Pointers, Stack vs Heap & Escape Analysis** | Intermediate | 24-byte slice header, sub-slice backing array memory leaks, `copy()` detachment, `-gcflags="-m"`. |
| **1** | `l1-interfaces-errors-generics` | **1.2 Implicit Interfaces, Composition, Errors as Values & Generics** | Intermediate | `iface`/`eface` runtime representation, `%w` error wrapping, `errors.Is` / `errors.As`, type parameters. |
| **2** | `l2-gmp-channels-context-workers` | **2.1 GMP Scheduler, Channels, Select, Mutexes, Context & Bounded Worker Pools** | Intermediate | GMP work-stealing scheduler, `hchan` internals, buffered vs. unbuffered channel leaks, `context.Context` worker pools. |
| **2** | `l2-profiling-pprof-benchmarks` | **2.2 CPU & Heap Profiling (`pprof`), `sync.Pool` & Execution Tracer** | Advanced | `runtime/pprof`, `sync.Pool` capacity guards (`maxPooledCap`) to prevent memory pinning, `runtime/trace`. |
| **3** | `l3-net-http-routers` | **3.1 Standard `net/http` (Go 1.22+) vs Chi, Gin, Echo & Fiber + Graceful Shutdown** | Intermediate | Go 1.22+ method/wildcard mux routing, composable middleware chains, `X-Request-ID`, panic recovery, `SIGTERM` draining. |
| **3** | `l3-validation-openapi-ratelimit` | **3.2 Request Validation, Token-Bucket Rate Limiting, CORS Allowlists & OpenAPI 3.1** | Intermediate | Token-bucket rate calculation, `Vary: Origin` CORS safety, RFC 9457 Problem Details. |
| **4** | `l4-acid-isolation-mvcc` | **4.1 Relational vs NoSQL Internals, MVCC, ACID Isolation Levels, Indexing & `EXPLAIN ANALYZE`** | Advanced | PostgreSQL `xmin`/`xmax` vs. MySQL InnoDB Undo Logs, Lost Update prevention, deterministic lock ordering. |
| **4** | `l4-partitioning-replication-sharding` | **4.2 Streaming Replication Lag, Declarative Partitioning, Sharding & PITR** | Advanced | WAL streaming replication, read-your-own-writes routing under lag, range/hash partitioning, PITR backups. |
| **5** | `l5-db-ecosystem-comparison` | **5.1 `database/sql` vs `pgx/v5` vs `sqlc` vs GORM vs Ent vs Bun & Pool Internals** | Intermediate | Driver/ORM trade-offs, calculating `MaxOpenConns` and `MaxIdleConns` across K8s replicas. |
| **5** | `l5-migrations-transactions-prepared` | **5.2 Expand-and-Contract Zero-Downtime SQL Migrations & Transaction Scopes** | Advanced | `CREATE INDEX CONCURRENTLY`, `LOCK_TIMEOUT`, avoiding AccessExclusiveLock table stalls. |
| **6** | `l6-security-auth-owasp` | **6.1 Argon2id, JWT vs Sessions, SQLi/SSRF/XSS/CSRF & OWASP API Top 10** | Advanced | `netip.ParseAddr` + `addr.Unmap()` SSRF protection, `subtle.ConstantTimeCompare`, OWASP API 2023. |
| **6** | `l6-oauth2-oidc-rbac-abac` | **6.2 OAuth 2.0 with PKCE, OpenID Connect (JWKS), RBAC vs ABAC & Secrets Rotation** | Advanced | Authorization Code + PKCE (`S256`), JWKS key rotation (`kid`), permission matrix verification. |
| **7** | `l7-testing-fuzzing-benchmarks` | **7.1 Table-Driven Tests, `httptest`, Fuzzing (`go test -fuzz`) & Benchmarking** | Intermediate | Subtests (`t.Run`), `go test -fuzz` UTF-8 boundary invariants, `b.ReportAllocs()`. |
| **7** | `l7-integration-testcontainers-ci` | **7.2 Fakes vs Mocks, Real Database Integration Testing & Reproducible CI Pipelines** | Advanced | In-memory fakes vs. brittle mocks, ephemeral PostgreSQL containers, deterministic CI gates. |
| **8** | `l8-clean-hexagonal-ddd` | **8.1 Layered vs Clean vs Hexagonal (Ports & Adapters), DDD & Constructor DI** | Advanced | Consumer-defined interfaces, inward dependency rule, exact `int64` basis-point monetary math. |
| **8** | `l8-modular-monolith-cqrs-boundaries` | **8.2 Enforcing Modular Monolith Boundaries, CQRS Read Models & Domain Modeling** | Advanced | Cross-module schema isolation, module table prefix enforcement, CQRS projections. |
| **9** | `l9-caching-queues-outbox-sagas` | **9.1 Redis Singleflight, Kafka vs RabbitMQ vs NATS, Outbox Pattern & Sagas** | Advanced | `singleflight.Group` stampede prevention, Transactional Outbox, Circuit Breaker state machine (`CLOSED`/`OPEN`/`HALF_OPEN`). |
| **9** | `l9-grpc-websockets-otel-tracing` | **9.2 gRPC & Protobuf Contracts, WebSockets vs SSE & OpenTelemetry Tracing** | Advanced | W3C `traceparent` (`00-<traceID>-<spanID>-<flags>`) parsing, gRPC deadlines, WebSocket backpressure. |
| **10** | `l10-devops-docker-k8s-production` | **10.1 Multi-Stage Distroless Docker Builds, Kubernetes Probes & `GOMEMLIMIT`** | Advanced | `GOMEMLIMIT` (85% of cgroup memory limit), decoupled `/healthz` vs `/readyz` probes. |
| **10** | `l10-reverse-proxy-cicd-rollback-dr` | **10.2 Caddy & Nginx Reverse Proxies, Trusted `X-Forwarded-For`, Canary Rollbacks & DR** | Advanced | Rightmost trusted proxy IP extraction from `X-Forwarded-For`, canary deployments, DR drills. |

---

## 2. 14 Real-World Production Case Studies

1. **CS-01**: Personal Task Management API (`Pragmatic Layered` • `SQLite WAL / PostgreSQL`)
2. **CS-02**: Authentication & Authorization Service (`Hexagonal` • `PostgreSQL + Redis`)
3. **CS-03**: High-Throughput URL Shortener (`Cache-Aside + Singleflight` • `PostgreSQL + Redis`)
4. **CS-04**: Blog & CMS Backend with Full-Text Search (`Modular Monolith` • `PostgreSQL tsvector + GIN`)
5. **CS-05**: E-Commerce Checkout & Order Orchestration (`Hexagonal + Outbox` • `PostgreSQL + Redis`)
6. **CS-06**: Flash-Sale Inventory Management System (`CQRS + Atomic Locking` • `PostgreSQL + Redis Lua`)
7. **CS-07**: Real-Time WebSocket Chat & Presence (`Stateful Hub + Pub/Sub` • `ScyllaDB / Partitioned PG + Redis`)
8. **CS-08**: Secure Object & File Storage Service (`Pre-Signed S3 Control Plane` • `PostgreSQL + S3/MinIO`)
9. **CS-09**: Multi-Channel Notification Delivery Service (`Worker Pool + Circuit Breaker` • `PostgreSQL + RabbitMQ/Kafka`)
10. **CS-10**: Booking & Time-Slot Reservation System (`GiST Exclusion Constraint` • `PostgreSQL btree_gist`)
11. **CS-11**: Payment Processing & Double-Entry Ledger (`Two-Phase State Machine` • `PostgreSQL SERIALIZABLE`)
12. **CS-12**: Multi-Tenant B2B SaaS with Row-Level Security (`Shared Schema + FORCE RLS` • `PostgreSQL 18 RLS`)
13. **CS-13**: Event-Driven Distributed Order Processing (`Saga + Outbox` • `PostgreSQL + Kafka`)
14. **CS-14**: High-Traffic Low-Latency Public API (50k+ RPS) (`L1/L2 Cache + Load Shedding` • `PostgreSQL + Read Replicas + Redis`)
