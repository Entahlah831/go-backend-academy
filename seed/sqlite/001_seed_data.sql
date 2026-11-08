-- Go Backend Academy Verified Seed Data (SQLITE)
INSERT INTO schema_migrations (version) VALUES ('001_initial_schema') ON CONFLICT(version) DO NOTHING;
INSERT INTO users (id, handle, display_name) VALUES ('usr_local_default', 'local_engineer', 'Local Backend Engineer') ON CONFLICT(id) DO NOTHING;
INSERT INTO curriculum_levels (id, level_number, slug, title, subtitle, estimated_hours) VALUES (1, 0, 'level-0-fundamentals', 'Level 0 — Backend Engineering Fundamentals', 'Client-server, HTTP/HTTPS, TCP/TLS/DNS, REST contracts, statelessness, and database interactions', 6) ON CONFLICT (id) DO UPDATE SET level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours;
INSERT INTO curriculum_levels (id, level_number, slug, title, subtitle, estimated_hours) VALUES (2, 1, 'level-1-go-fundamentals', 'Level 1 — Go Fundamentals', 'Toolchain, modules, slices/maps internals, interfaces, value errors, generics, escape analysis, and GC', 12) ON CONFLICT (id) DO UPDATE SET level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours;
INSERT INTO curriculum_levels (id, level_number, slug, title, subtitle, estimated_hours) VALUES (3, 2, 'level-2-concurrency', 'Level 2 — Intermediate & Advanced Go', 'GMP scheduler, channels, select, mutexes, context cancellation trees, worker pools, race detector, and pprof', 14) ON CONFLICT (id) DO UPDATE SET level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours;
INSERT INTO curriculum_levels (id, level_number, slug, title, subtitle, estimated_hours) VALUES (4, 3, 'level-3-http-services', 'Level 3 — HTTP Backend Engineering', 'Standard net/http (Go 1.22+ routing), middleware chains, validation, pagination, rate limiting, slog, and router comparisons', 12) ON CONFLICT (id) DO UPDATE SET level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours;
INSERT INTO curriculum_levels (id, level_number, slug, title, subtitle, estimated_hours) VALUES (5, 4, 'level-4-database-engineering', 'Level 4 — Database Engineering', 'PostgreSQL, MySQL, MariaDB, SQLite, MongoDB, Redis, ScyllaDB, MVCC, ACID isolation levels, B-Tree/GIN indexing, and EXPLAIN ANALYZE', 18) ON CONFLICT (id) DO UPDATE SET level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours;
INSERT INTO curriculum_levels (id, level_number, slug, title, subtitle, estimated_hours) VALUES (6, 5, 'level-5-go-db-ecosystem', 'Level 5 — Go Database Ecosystem', 'database/sql pool internals, pgx/v5 binary protocol, sqlc codegen, GORM, Ent, Bun, and zero-downtime migrations', 10) ON CONFLICT (id) DO UPDATE SET level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours;
INSERT INTO curriculum_levels (id, level_number, slug, title, subtitle, estimated_hours) VALUES (7, 6, 'level-6-security', 'Level 6 — Authentication & Security', 'Argon2id password hashing, JWT vs Stateful Sessions, OAuth2/OIDC, RBAC, SQLi/SSRF/XSS/CSRF, and OWASP API Security Top 10 (2023)', 14) ON CONFLICT (id) DO UPDATE SET level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours;
INSERT INTO curriculum_levels (id, level_number, slug, title, subtitle, estimated_hours) VALUES (8, 7, 'level-7-testing', 'Level 7 — Testing & Code Quality', 'Table-driven tests, subtests, httptest, Testcontainers, fuzzing (go test -fuzz), race detection, and CI pipelines', 10) ON CONFLICT (id) DO UPDATE SET level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours;
INSERT INTO curriculum_levels (id, level_number, slug, title, subtitle, estimated_hours) VALUES (9, 8, 'level-8-architecture', 'Level 8 — Software Architecture', 'Layered, Clean, Hexagonal (Ports & Adapters), DDD, Modular Monolith vs Microservices, CQRS, and pragmatic DI', 14) ON CONFLICT (id) DO UPDATE SET level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours;
INSERT INTO curriculum_levels (id, level_number, slug, title, subtitle, estimated_hours) VALUES (10, 9, 'level-9-distributed-systems', 'Level 9 — Distributed Systems', 'Redis caching strategies, Kafka vs RabbitMQ vs NATS, gRPC, Transactional Outbox, Saga pattern, Circuit Breakers, and OpenTelemetry', 16) ON CONFLICT (id) DO UPDATE SET level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours;
INSERT INTO curriculum_levels (id, level_number, slug, title, subtitle, estimated_hours) VALUES (11, 10, 'level-10-devops-production', 'Level 10 — Production Engineering & DevOps', 'Multi-stage Docker builds, distroless images, Kubernetes liveness/readiness probes, Caddy/Nginx reverse proxies, and disaster recovery', 12) ON CONFLICT (id) DO UPDATE SET level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l0-network-foundations', 1, 1, 'mod-l0-network-foundations', 'Module 0.A — Networking, Protocols & System Topologies', 'What happens on the wire from DNS resolution and TCP 3-way handshake to TLS 1.3 key exchange, HTTP/1.1 vs HTTP/2 framing, REST API contracts, and Go net/http socket handling.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l0-backend-http-lifecycle', 'mod-l0-network-foundations', 1, 3, '0.1', 'l0-backend-http-lifecycle', '0.1 Client-Server Architecture, DNS/TCP/TLS & HTTP Request Lifecycle', 'What happens on the wire from DNS resolution and TCP 3-way handshake to TLS 1.3 key exchange, HTTP/1.1 vs HTTP/2 framing, REST API contracts, and Go net/http socket handling.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l0-backend-http-lifecycle-sec-main', 'l0-backend-http-lifecycle', 'core', '0.1 Client-Server Architecture, DNS/TCP/TLS & HTTP Request Lifecycle', '{"beginner": "When you type a URL or an app fetches data, your device first looks up the server''s IP address using DNS (like a phonebook). Then it opens a reliable pipe (TCP), locks it with encryption (TLS/HTTPS), and sends a structured text message (an HTTP Request with Method, Path, Headers, and JSON Body). The Go backend reads that message, checks if you are allowed, updates the database, and replies with an HTTP Status Code (like 200 OK or 404 Not Found) and JSON data.", "intermediate": "At the transport and application layers, an HTTPS request requires DNS resolution, a 1-RTT TCP 3-way handshake, and a 1-RTT TLS 1.3 handshake before application bytes flow. In Go''s net/http package, http.Server spawns a dedicated goroutine per accepted *net.TCPConn, reusing that goroutine across multiple requests on the same HTTP/1.1 keep-alive connection or spawning per-stream goroutines in HTTP/2. REST API contracts rely on idempotent HTTP methods (GET, PUT, DELETE vs non-idempotent POST) and strict JSON serialization via encoding/json.", "advanced": "Internally, Go''s net.Conn.Read calls into internal/poll.FD.Read, which performs a non-blocking read syscall. If the socket buffer is empty (syscall.EAGAIN), the runtime invokes runtime.gopark, registering the file descriptor with epoll_ctl(EPOLL_CTL_ADD/MOD) with edge-triggered EPOLLET events and detaching the Goroutine (G) from its OS Thread (M) so the Processor (P) immediately executes other runnable goroutines. Compared to Java NIO selector threads or Node.js single-threaded libuv callbacks, Go gives you synchronous imperative code with asynchronous non-blocking epoll efficiency."}', '[Client / Browser]
   │ 1. DNS Lookup (UDP/53 or DoH) -> Resolves api.example.com to 203.0.113.42
   │ 2. TCP 3-Way Handshake (SYN -> SYN-ACK -> ACK) [1 RTT]
   │ 3. TLS 1.3 Handshake (ClientHello + KeyShare -> ServerHello + Cert + Finished) [1 RTT]
   ▼
[Reverse Proxy: Caddy / Nginx]  (Terminates TLS, enforces Rate Limit, forwards X-Forwarded-For)
   │ 4. HTTP/1.1 Keep-Alive or HTTP/2 Multiplexed Stream over Local VPC
   ▼
[Go net/http Server]
   ├── Accept Loop (epoll / kqueue network poller wakes Goroutine)
   ├── Middleware Chain (RequestID -> slog Logger -> Panic Recovery -> Auth -> Timeout)
   ├── Handler + DTO Validation (JSON Deserialization & Schema Contract Check)
   └── Connection Pool (database/sql or pgxpool) ──► [PostgreSQL / Redis]', 'package main

import (
	"encoding/json"
	"io"
	"net/http"
)

func main() {
	http.HandleFunc("/users", func(w http.ResponseWriter, r *http.Request) {
		// BUG 1: Accepts ANY HTTP method (GET, DELETE, POST) on the same route
		// BUG 2: io.ReadAll with no limit allows a 10GB payload to OOM-kill the server
		body, _ := io.ReadAll(r.Body)
		var data map[string]any
		json.Unmarshal(body, &data)
		w.Write([]byte("ok")) // BUG 3: Missing Content-Type & status code
	})
	// BUG 4: Default server has NO timeouts (vulnerable to Slowloris DoS)
	http.ListenAndServe(":8080", nil)
}', 'package main

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"os"
	"time"
)

type CreateUserRequest struct {
	Email string `json:"email"`
	Name  string `json:"name"`
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("POST /api/v1/users", func(w http.ResponseWriter, r *http.Request) {
		// Enforce 1 MB maximum payload size
		r.Body = http.MaxBytesReader(w, r.Body, 1<<20)
		defer r.Body.Close()

		var req CreateUserRequest
		dec := json.NewDecoder(r.Body)
		dec.DisallowUnknownFields() // Strict API contract enforcement
		if err := dec.Decode(&req); err != nil {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusBadRequest)
			_ = json.NewEncoder(w).Encode(map[string]string{"error": "invalid request payload"})
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		_ = json.NewEncoder(w).Encode(map[string]string{"status": "created", "email": req.Email})
	})

	srv := &http.Server{
		Addr:              ":8080",
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
	}
	slog.Info("starting hardened HTTP server", "addr", srv.Addr)
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		os.Exit(1)
	}
}', 'Explicit ReadHeaderTimeout, ReadTimeout, WriteTimeout, and IdleTimeout bound socket lifetime. http.MaxBytesReader aborts reads at the stream level before heap exhaustion, and json.Decoder.DisallowUnknownFields catches client contract drift immediately.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l0-backend-http-lifecycle-ref-1', 'l0-backend-http-lifecycle', 'Go Standard Library: net/http', 'https://pkg.go.dev/net/http', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l0-backend-http-lifecycle-ref-2', 'l0-backend-http-lifecycle', 'Go Standard Library: encoding/json', 'https://pkg.go.dev/encoding/json', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l0-backend-http-lifecycle-ref-3', 'l0-backend-http-lifecycle', 'OWASP API4:2023 Unrestricted Resource Consumption', 'https://api-security.owasp.org/editions/2023/en/0x11-t10/', '2023 Edition', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l0-backend-http-lifecycle', 'l0-backend-http-lifecycle', 'Build a Contract-Validated Health & Echo Endpoint with Slowloris Protection', 'Configure an http.Server with a 5-second ReadHeaderTimeout, 10-second ReadTimeout, and a POST /api/v1/echo handler that rejects payloads larger than 64KB using http.MaxBytesReader.', 'package main

import (
	"encoding/json"
	"net/http"
	"time"
)

func NewHardenedServer(addr string) *http.Server {
	mux := http.NewServeMux()
	mux.HandleFunc("POST /api/v1/echo", func(w http.ResponseWriter, r *http.Request) {
		// STEP: Limit r.Body to 64KB (64 << 10) using http.MaxBytesReader
		// STEP: Decode JSON with DisallowUnknownFields() and return 200 OK JSON
	})

	return &http.Server{
		Addr:    addr,
		Handler: mux,
		// STEP: Set ReadHeaderTimeout (5s), ReadTimeout (10s), WriteTimeout (15s), IdleTimeout (60s)
	}
}', 'Invarian: Hardened Server Timeouts
Invarian: Echo Max Bytes Limit
Invarian: Echo Rejects Unknown Fields
Status: 200 OK | Content-Type: application/json', 'package main

import (
	"encoding/json"
	"net/http"
	"time"
)

func NewHardenedServer(addr string) *http.Server {
	mux := http.NewServeMux()
	mux.HandleFunc("POST /api/v1/echo", func(w http.ResponseWriter, r *http.Request) {
		r.Body = http.MaxBytesReader(w, r.Body, 64<<10)
		defer r.Body.Close()

		var payload struct {
			Message string `json:"message"`
		}
		dec := json.NewDecoder(r.Body)
		dec.DisallowUnknownFields()
		if err := dec.Decode(&payload); err != nil {
			http.Error(w, `{"error":"invalid payload"}`, http.StatusBadRequest)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(payload)
	})

	return &http.Server{
		Addr:              addr,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
	}
}', 'Setting ReadHeaderTimeout protects the server during the initial header read phase, while http.MaxBytesReader wraps the underlying io.ReadCloser so that reading past 65,536 bytes immediately halts and closes the connection.', 'Add an Idempotency-Key request header check so retrying a POST request with the same UUID returns the cached response instead of re-executing.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l0-backend-http-lifecycle-tc-1', 'ex-l0-backend-http-lifecycle', 1, 'Verify srv.ReadHeaderTimeout == 5*time.Second and srv.ReadTimeout == 10*time.Second', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l0-backend-http-lifecycle-tc-2', 'ex-l0-backend-http-lifecycle', 2, 'Verify POST /api/v1/echo with >64KB payload returns 400 Bad Request', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l0-backend-http-lifecycle-tc-3', 'ex-l0-backend-http-lifecycle', 3, 'Verify POST /api/v1/echo with unknown JSON field returns 400 Bad Request', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l0-stateless-vs-stateful-arch', 'mod-l0-network-foundations', 1, 4, '0.2', 'l0-stateless-vs-stateful-arch', '0.2 Stateless vs Stateful Systems, AuthN vs AuthZ & Monolith vs Microservices', 'Why horizontal scaling depends on stateless compute nodes, how Authentication differs from Authorization, and when a Modular Monolith beats Microservices.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l0-stateless-vs-stateful-arch-sec-main', 'l0-stateless-vs-stateful-arch', 'core', '0.2 Stateless vs Stateful Systems, AuthN vs AuthZ & Monolith vs Microservices', '{"beginner": "Authentication (AuthN) answers ''Who are you?'' (logging in with password or OAuth). Authorization (AuthZ) answers ''What are you allowed to do?'' (can User A delete User B''s invoice?). A stateless backend doesn''t rely on one specific server remembering you in its RAM\u2014any server in the cluster can handle your request.", "intermediate": "When scaling horizontally behind an L7 load balancer, storing session state in a process-local Go map breaks as soon as multiple instances run. Externalizing session state to Redis or verifying cryptographic tokens makes compute nodes cattle, not pets. Similarly, a Modular Monolith enforces strict Go package boundaries (using internal/ packages) inside one binary, avoiding RPC serialization taxes until independent scaling is proven necessary.", "advanced": "Distributed microservices trade in-process function calls (~2ns) and local ACID transactions for gRPC/HTTP calls (~1\u20135ms), partial failures, clock skew, and Saga/Outbox coordination. Start with a Modular Monolith where domain modules communicate via narrow Go interfaces; if one domain later requires 10x CPU scaling, swap the interface implementation from an in-process call to a gRPC client without rewriting domain logic."}', '[Load Balancer (Round-Robin / Least-Conn)]
       ├──► [Go API Replica 1 (Stateless)] ──┐
       ├──► [Go API Replica 2 (Stateless)] ──┼──► [Shared State Layer: PostgreSQL + Redis]
       └──► [Go API Replica 3 (Stateless)] ──┘
(Any replica can serve any request without sticky sessions)', 'package auth

import "net/http"

// BUG 1: Process-local state breaks across multiple instances AND has a data race!
var loggedInUsers = map[string]string{}

func GetInvoiceHandler(w http.ResponseWriter, r *http.Request) {
	token := r.Header.Get("X-Session-Token")
	userID, ok := loggedInUsers[token] // Concurrent map read/write panic + fails on Replica 2
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	// BUG 2: Authenticates user (AuthN), but NEVER checks if userID owns invoiceID (Broken Object Level AuthZ)!
	invoiceID := r.PathValue("id")
	serveInvoiceByID(w, invoiceID, userID)
}', 'package auth

import (
	"context"
	"net/http"
)

type SessionStore interface {
	GetUserID(ctx context.Context, token string) (string, error)
}

type InvoiceRepository interface {
	GetByIDAndOwner(ctx context.Context, invoiceID, ownerUserID string) (*Invoice, error)
}

func GetInvoiceHandler(sessions SessionStore, repo InvoiceRepository) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("Authorization")
		// 1. Authentication (AuthN): Who is making the request?
		userID, err := sessions.GetUserID(r.Context(), token)
		if err != nil || userID == "" {
			http.Error(w, `{"error":"unauthorized"}`, http.StatusUnauthorized)
			return
		}

		// 2. Authorization (AuthZ): Does this specific user own this specific object?
		invoiceID := r.PathValue("id")
		inv, err := repo.GetByIDAndOwner(r.Context(), invoiceID, userID)
		if err != nil {
			http.Error(w, `{"error":"not found"}`, http.StatusNotFound)
			return
		}
		writeJSON(w, http.StatusOK, inv)
	}
}', 'Injecting SessionStore decouples compute nodes from local RAM state, and scoping repository queries by both (invoiceID, ownerUserID) makes Broken Object Level Authorization (BOLA) impossible by design.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l0-stateless-vs-stateful-arch-ref-1', 'l0-stateless-vs-stateful-arch', 'OWASP API1:2023 Broken Object Level Authorization', 'https://api-security.owasp.org/editions/2023/en/0x11-t10/', '2023 Edition', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l0-stateless-vs-stateful-arch-ref-2', 'l0-stateless-vs-stateful-arch', 'Go Modules & Internal Packages Reference', 'https://go.dev/ref/mod', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l0-stateless-vs-stateful-arch', 'l0-stateless-vs-stateful-arch', 'Enforce Object-Level Authorization (BOLA Prevention) in an HTTP Handler', 'Complete CanAccessDocument(actorUserID, actorRole, docOwnerID string) bool so that access is granted only if the actor is the document owner or has the ''admin'' role, rejecting empty IDs.', 'package security

func CanAccessDocument(actorUserID, actorRole, docOwnerID string) bool {
	// STEP: Return false if actorUserID or docOwnerID is empty
	// STEP: Return true if actorUserID == docOwnerID or actorRole == "admin"
	return false
}', 'Invarian: Owner Can Access
Invarian: Non Owner Rejected
Invarian: Admin Can Access
Invarian: Empty I Ds Rejected', 'package security

func CanAccessDocument(actorUserID, actorRole, docOwnerID string) bool {
	if actorUserID == "" || docOwnerID == "" {
		return false
	}
	return actorUserID == docOwnerID || actorRole == "admin"
}', 'Failing closed when identifiers are empty prevents zero-value string matching bugs ('''' == '''') in Go structs.', 'Extend the check to support multi-tenant isolation by verifying actorTenantID == docTenantID even for tenant admins.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l0-stateless-vs-stateful-arch-tc-1', 'ex-l0-stateless-vs-stateful-arch', 1, 'CanAccessDocument(''u1'', ''member'', ''u1'') == true', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l0-stateless-vs-stateful-arch-tc-2', 'ex-l0-stateless-vs-stateful-arch', 2, 'CanAccessDocument(''u1'', ''member'', ''u2'') == false', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l0-stateless-vs-stateful-arch-tc-3', 'ex-l0-stateless-vs-stateful-arch', 3, 'CanAccessDocument(''u1'', ''admin'', ''u2'') == true', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l0-stateless-vs-stateful-arch-tc-4', 'ex-l0-stateless-vs-stateful-arch', 4, 'CanAccessDocument('''', ''admin'', '''') == false', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l0-protocols-contracts', 1, 3, 'mod-l0-protocols-contracts', 'Module 0.B — REST Semantics, JSON Serialization & API Contracts', 'Why GET/PUT/DELETE must be idempotent while POST requires an Idempotency-Key, how encoding/json handles struct tags, zero values, and omitempty, and how to evolve API contracts without breaking clients.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l0-rest-json-api-contracts', 'mod-l0-protocols-contracts', 1, 5, '0.3', 'l0-rest-json-api-contracts', '0.3 REST Idempotency, JSON Marshaling Internals & Backward-Compatible API Contracts', 'Why GET/PUT/DELETE must be idempotent while POST requires an Idempotency-Key, how encoding/json handles struct tags, zero values, and omitempty, and how to evolve API contracts without breaking clients.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l0-rest-json-api-contracts-sec-main', 'l0-rest-json-api-contracts', 'core', '0.3 REST Idempotency, JSON Marshaling Internals & Backward-Compatible API Contracts', '{"beginner": "An API Contract is a promise between the backend and frontend: ''If you send me a JSON object with `email` and `amount_cents`, I will return HTTP 201 with an `order_id`.'' In Go, struct tags like `` `json:\"amount_cents\"` `` tell Go how to translate between Go structs and JSON text.", "intermediate": "Language Guarantee vs Standard Library Behavior: In Go''s `encoding/json`, unexported struct fields (starting with a lowercase letter) are silently ignored during marshaling and unmarshaling! Also, when designing a `PATCH /users/{id}` endpoint for partial updates, use pointer fields (`*string`, `*bool`) in the request DTO so you can check `if req.ReceiveNewsletter != nil` to distinguish ''field was not sent'' from ''client explicitly sent `false`''.", "advanced": "Internally, `encoding/json` caches struct encoder functions in a `sync.Map` keyed by `reflect.Type`. However, marshaling via `json.Marshal` allocates a full `[]byte` buffer in memory. For large responses, streaming with `json.NewEncoder(w).Encode(v)` writes via an internal pooled buffer, though note that once `w.Write` is called, HTTP status headers can no longer be changed if a marshaling error occurs mid-stream."}', 'HTTP Method Idempotency & Safety Matrix (RFC 9110):
┌──────────┬─────────┬────────────┬─────────────────────────────────────────────────────────┐
│ Method   │ Safe?   │ Idempotent?│ Engineering Contract & Retry Behavior                   │
├──────────┼─────────┼────────────┼─────────────────────────────────────────────────────────┤
│ GET      │ YES     │ YES        │ Read-only; safe for automatic L7 proxy/client retries   │
│ PUT      │ NO      │ YES        │ Full resource replacement at known URI; safe to retry   │
│ DELETE   │ NO      │ YES        │ Deleting N times leaves resource absent (200/204/404)   │
│ POST     │ NO      │ NO*        │ Creates subordinate resource; requires Idempotency-Key! │
│ PATCH    │ NO      │ NO*        │ Partial modification; idempotent only if setting values │
└──────────┴─────────┴────────────┴─────────────────────────────────────────────────────────┘', 'package userapi

type PatchUserInput struct {
	displayName string `json:"display_name"` // BUG 1: Unexported field is silently ignored by encoding/json!
	IsActive    bool   `json:"is_active"`    // BUG 2: Omitting "is_active" in JSON sets IsActive=false, deactivating the user!
}', 'package userapi

type PatchUserInput struct {
	DisplayName *string `json:"display_name,omitempty"`
	IsActive    *bool   `json:"is_active,omitempty"`
}

func ApplyPatch(u *User, in PatchUserInput) {
	if in.DisplayName != nil {
		u.DisplayName = *in.DisplayName
	}
	if in.IsActive != nil {
		u.IsActive = *in.IsActive
	}
}', 'Exported fields (`DisplayName`, `IsActive`) are visible to `encoding/json`, and pointer types (`*string`, `*bool`) remain `nil` when omitted from the JSON payload, preserving existing database values.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l0-rest-json-api-contracts-ref-1', 'l0-rest-json-api-contracts', 'Go Blog: JSON and Go', 'https://go.dev/blog/json', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l0-rest-json-api-contracts-ref-2', 'l0-rest-json-api-contracts', 'Go Standard Library: encoding/json', 'https://pkg.go.dev/encoding/json', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l0-rest-json-api-contracts', 'l0-rest-json-api-contracts', 'Implement Safe Partial PATCH Merging with Pointer DTO Fields', 'Complete MergeSettings(currentMaxConns int, currentTLS bool, patchMaxConns *int, patchTLS *bool) (int, bool) so only non-nil patch fields overwrite current settings.', 'package api

func MergeSettings(currentMaxConns int, currentTLS bool, patchMaxConns *int, patchTLS *bool) (int, bool) {
	// STEP: Only update currentMaxConns if patchMaxConns != nil
	// STEP: Only update currentTLS if patchTLS != nil
	return currentMaxConns, currentTLS
}', 'Invarian: Merge Settings Preserves Omitted Fields
Invarian: Merge Settings Applies Explicit False', 'package api

func MergeSettings(currentMaxConns int, currentTLS bool, patchMaxConns *int, patchTLS *bool) (int, bool) {
	if patchMaxConns != nil {
		currentMaxConns = *patchMaxConns
	}
	if patchTLS != nil {
		currentTLS = *patchTLS
	}
	return currentMaxConns, currentTLS
}', 'Checking `!= nil` before dereferencing allows a `PATCH` endpoint to distinguish omitted JSON properties from explicit `0` or `false` values.', 'Show how `json.Decoder.UseNumber()` preserves 64-bit integer precision when decoding into `map[string]any`.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l0-rest-json-api-contracts-tc-1', 'ex-l0-rest-json-api-contracts', 1, 'MergeSettings(25, true, nil, nil) == (25, true)', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l0-rest-json-api-contracts-tc-2', 'ex-l0-rest-json-api-contracts', 2, 'MergeSettings(25, true, nil, ptrBool(false)) == (25, false)', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l1-toolchain-types', 2, 4, 'mod-l1-toolchain-types', 'Module 1.A — Toolchain, Go Modules, Packages & Type System', 'How go.mod and go.sum guarantee reproducible cryptographic builds via Minimal Version Selection (MVS), how internal/ packages enforce compile-time encapsulation, and how struct field alignment affects memory footprint.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l1-toolchain-modules-packages', 'mod-l1-toolchain-types', 2, 7, '1.1', 'l1-toolchain-modules-packages', '1.0 Go Toolchain, Module Minimal Version Selection (MVS), internal/ Packages & Struct Layout', 'How go.mod and go.sum guarantee reproducible cryptographic builds via Minimal Version Selection (MVS), how internal/ packages enforce compile-time encapsulation, and how struct field alignment affects memory footprint.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l1-toolchain-modules-packages-sec-main', 'l1-toolchain-modules-packages', 'core', '1.0 Go Toolchain, Module Minimal Version Selection (MVS), internal/ Packages & Struct Layout', '{"beginner": "In Go, any function, struct, or variable starting with a **Capital Letter** (`User`, `GetByID`) is public (exported) to other packages, while **lowercase** (`parseToken`) is private to its package. Furthermore, any code placed inside an `internal/` folder cannot be imported by outside projects!", "intermediate": "Go Modules (`go.mod` + `go.sum`) use Minimal Version Selection (MVS): if Module A requires `lib v1.2.0` and Module B requires `lib v1.4.0`, Go always picks `v1.4.0`\u2014the oldest version that satisfies all requirements\u2014without guessing or auto-upgrading to `v1.9.0` behind your back.", "advanced": "Runtime Memory Detail: On 64-bit architectures, an `int64` or pointer (`*T`) must be aligned on an 8-byte boundary. Placing `bool` (1 byte) before `int64` (8 bytes) and another `bool` (1 byte) forces the compiler to insert 14 bytes of invisible padding, turning a 10-byte payload into a 24-byte struct. Sorting fields from 8-byte down to 1-byte types packs the struct into 16 bytes."}', '64-Bit Struct Field Padding & Alignment (8-byte word boundaries):
❌ Poor Field Order (24 bytes per struct):       ✅ Optimal Field Order (16 bytes per struct - 33% smaller!):
┌──────┬───────────────────────┐                 ┌──────────────────────────────┐
│ bool │ 7 bytes wasted pad    │ (Word 1: 8B)    │ int64 (8 bytes)              │ (Word 1: 8B)
├──────┴───────────────────────┤                 ├──────┬──────┬────────────────┤
│ int64 (8 bytes)              │ (Word 2: 8B)    │ int32│ bool │ bool │ 2B pad  │ (Word 2: 8B)
├──────┬───────────────────────┤                 └──────┴──────┴────────────────┘
│ bool │ 7 bytes wasted pad    │ (Word 3: 8B)
└──────┴───────────────────────┘', 'package cache

// BUG 1: Exported mutable global allows any package to overwrite DB timeout at runtime!
var DefaultTimeoutSeconds = 30

// BUG 2: 24 bytes per entry due to poor field alignment (wastes 80MB on 10M entries)
type MetricPoint struct {
	IsError   bool
	Timestamp int64
	IsSampled bool
}', 'package cache

import "time"

const DefaultTimeout = 30 * time.Second

// 16 bytes per entry (int64 first, followed by two 1-byte bools)
type MetricPoint struct {
	Timestamp int64
	IsError   bool
	IsSampled bool
}', 'Using `const DefaultTimeout = 30 * time.Second` provides compile-time immutability and unit safety (`time.Duration`), while ordering `int64` before `bool` saves 8 bytes per struct instance.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-toolchain-modules-packages-ref-1', 'l1-toolchain-modules-packages', 'Go Modules Reference (MVS & go.sum)', 'https://go.dev/ref/mod', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-toolchain-modules-packages-ref-2', 'l1-toolchain-modules-packages', 'Go Language Specification: Exported Identifiers', 'https://go.dev/ref/spec#Exported_identifiers', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l1-toolchain-modules-packages', 'l1-toolchain-modules-packages', 'Validate Module Path & Exported Identifier Rules', 'Implement IsExportedIdentifier(name string) bool that returns true if name is non-empty and its first rune is an uppercase letter.', 'package goast

import (
	"unicode"
	"unicode/utf8"
)

func IsExportedIdentifier(name string) bool {
	// STEP: Decode first rune with utf8.DecodeRuneInString and check unicode.IsUpper
	return false
}', 'Invarian: Is Exported Identifier', 'package goast

import (
	"unicode"
	"unicode/utf8"
)

func IsExportedIdentifier(name string) bool {
	if name == "" {
		return false
	}
	r, _ := utf8.DecodeRuneInString(name)
	return unicode.IsUpper(r)
}', 'According to the Go Language Specification, an identifier is exported if its first character is a Unicode uppercase letter (`Unicode class Lu`).', 'Check `unsafe.Sizeof(MetricPoint{})` before and after reordering struct fields.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-toolchain-modules-packages-tc-1', 'ex-l1-toolchain-modules-packages', 1, 'IsExportedIdentifier(''Server'') == true', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-toolchain-modules-packages-tc-2', 'ex-l1-toolchain-modules-packages', 2, 'IsExportedIdentifier(''server'') == false', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-toolchain-modules-packages-tc-3', 'ex-l1-toolchain-modules-packages', 3, 'IsExportedIdentifier('''') == false', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l1-memory-interfaces', 2, 5, 'mod-l1-memory-interfaces', 'Module 1.B — Memory Model, Interfaces & Error Values', 'How Go represents slices (24-byte header) and maps (hmap buckets) in memory, why sub-slicing can leak gigabytes of backing arrays, and how compiler escape analysis decides stack vs heap allocation.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l1-memory-slices-maps-escape', 'mod-l1-memory-interfaces', 2, 8, '1.2', 'l1-memory-slices-maps-escape', '1.1 Slices, Maps, Pointers, Stack vs Heap & Escape Analysis', 'How Go represents slices (24-byte header) and maps (hmap buckets) in memory, why sub-slicing can leak gigabytes of backing arrays, and how compiler escape analysis decides stack vs heap allocation.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l1-memory-slices-maps-escape-sec-main', 'l1-memory-slices-maps-escape', 'core', '1.1 Slices, Maps, Pointers, Stack vs Heap & Escape Analysis', '{"beginner": "In Go, a Slice is like a window looking at an underlying row of boxes (an Array). If two slices look at the same array, changing an item in one window is visible in the other\u2014unless one window grows too big (via append) and moves to a brand-new row of boxes. Also, Go automatically decides whether to put variables on the fast scratchpad (Stack) or the shared warehouse (Heap).", "intermediate": "A slice header is 24 bytes: pointer, length, capacity. When you pass a slice to a function, the header is copied by value, meaning mutations to s[i] mutate the caller''s backing array, whereas append(s, x) returns an updated header that must be reassigned. Escape analysis (`go build -gcflags=''-m''`) determines at compile time whether a pointer outlives its function or is stored in an interface, promoting it to the heap.", "advanced": "Two classic production memory leaks in Go involve slices and maps: (1) Slicing `header := fullPacket[:20]` retains a pointer into `fullPacket`''s backing array, preventing the tri-color GC from freeing the rest of the multi-megabyte buffer; use `bytes.Clone(fullPacket[:20])` or `copy()` to detach. (2) Go''s `runtime.hmap` never releases allocated bucket arrays when keys are deleted via `delete(m, k)`\u2014long-lived caches that spike to 10M keys and delete them all still retain the bucket memory until the map itself is recreated."}', 'Slice Header (24 bytes on 64-bit, allocated on Stack if non-escaping):
┌───────────────────┬──────────────┬──────────────┐
│ Data (*T, 8B)     │ Len (int, 8B)│ Cap (int, 8B)│
└─────────┬─────────┴──────────────┴──────────────┘
          │ points to contiguous Backing Array
          ▼
┌─────┬─────┬─────┬─────┬─────┬─────┐
│ [0] │ [1] │ [2] │ [3] │ [4] │ [5] │  (Allocated on Stack or Heap depending on size/escape)
└─────┴─────┴─────┴─────┴─────┴─────┘', 'package parser

// BUG 1: Returning a sub-slice pins the entire 10MB rawLog buffer in heap memory!
func ExtractTraceID(rawLog []byte) []byte {
	return rawLog[0:16]
}

// BUG 2: Repeated reallocations and copies because capacity is not pre-allocated
func TransformIDs(inputs []string) []string {
	var out []string
	for _, in := range inputs {
		out = append(out, "id_"+in)
	}
	return out
}', 'package parser

import "bytes"

// Detaches the 16-byte trace ID into a fresh 16-byte allocation so rawLog can be GC''d
func ExtractTraceID(rawLog []byte) []byte {
	if len(rawLog) < 16 {
		return nil
	}
	return bytes.Clone(rawLog[:16])
}

// Single allocation using known input length
func TransformIDs(inputs []string) []string {
	out := make([]string, 0, len(inputs))
	for _, in := range inputs {
		out = append(out, "id_"+in)
	}
	return out
}', 'bytes.Clone allocates an exact-sized 16-byte backing array and copies the bytes, allowing the multi-megabyte buffer to be reclaimed on the next GC cycle. make([]string, 0, len(inputs)) eliminates O(log N) array growth copies.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-memory-slices-maps-escape-ref-1', 'l1-memory-slices-maps-escape', 'Go Blog: Go Slices: usage and internals', 'https://go.dev/blog/slices-intro', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-memory-slices-maps-escape-ref-2', 'l1-memory-slices-maps-escape', 'Go Language Specification: Slice expressions', 'https://go.dev/ref/spec#Slice_expressions', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-memory-slices-maps-escape-ref-3', 'l1-memory-slices-maps-escape', 'A Guide to the Go Garbage Collector', 'https://go.dev/doc/gc-guide', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l1-memory-slices-maps-escape', 'l1-memory-slices-maps-escape', 'Fix Sub-Slice Memory Retention & Side-Effect Mutation', 'Implement SafePrefix(src []int, n int) []int that returns the first n elements in a detached backing array so that appending to the returned slice never mutates src and never pins src''s tail in memory.', 'package memory

func SafePrefix(src []int, n int) []int {
	// STEP: Bounds check n against len(src)
	// STEP: Allocate a detached slice of length n and copy elements
	return nil
}', 'Invarian: Safe Prefix Detaches Backing Array
Invarian: Safe Prefix Append Does Not Overwrite Original
Allocations: 1 allocs/op', 'package memory

func SafePrefix(src []int, n int) []int {
	if n <= 0 || len(src) == 0 {
		return nil
	}
	if n > len(src) {
		n = len(src)
	}
	out := make([]int, n)
	copy(out, src[:n])
	return out
}', 'By allocating make([]int, n) and copying, cap(out) == len(out) == n, completely decoupling out from src''s backing array.', 'Show how a 3-index slice expression src[:n:n] restricts capacity without copying when you only want to prevent append overwrites (not memory retention).') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-memory-slices-maps-escape-tc-1', 'ex-l1-memory-slices-maps-escape', 1, 'Appending to SafePrefix(src, 2) must not modify src[2]', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-memory-slices-maps-escape-tc-2', 'ex-l1-memory-slices-maps-escape', 2, 'cap(SafePrefix(src, 2)) must equal 2, not cap(src)', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l1-interfaces-errors-generics', 'mod-l1-memory-interfaces', 2, 9, '1.3', 'l1-interfaces-errors-generics', '1.2 Implicit Interfaces, Composition, Errors as Values & Generics', 'Why Go interfaces are satisfied implicitly at the consumer boundary, the infamous typed-nil interface trap, wrapping errors with %w, and when to use Type Parameters (Generics) vs interfaces.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l1-interfaces-errors-generics-sec-main', 'l1-interfaces-errors-generics', 'core', '1.2 Implicit Interfaces, Composition, Errors as Values & Generics', '{"beginner": "In Go, a struct doesn''t need to say `implements Reader`. If it has a `Read([]byte) (int, error)` method, it automatically satisfies `io.Reader`! Also, Go doesn''t throw exceptions for normal errors\u2014functions return an `error` value as their last result so you handle problems right where they happen.", "intermediate": "Define interfaces on the consumer side (''Accept interfaces, return concrete structs''). When propagating errors up the call stack, wrap them using `fmt.Errorf(\"context: %w\", err)` so callers can still inspect sentinel errors via `errors.Is(err, ErrNotFound)` or extract structured error types via `errors.As(err, &validationErr)`.", "advanced": "Understand the `runtime.iface` memory layout: an interface holds `(type, value)`. If a function declares `var err *MyCustomError = nil` and returns `err` as an `error` interface, the returned `iface` has `type = *MyCustomError` and `value = nil`, which evaluates `err != nil` as `true`. Always declare error variables as `var err error` or return explicit `nil`."}', 'Interface Value (iface = 16 bytes on 64-bit):
┌──────────────────────────────┬──────────────────────────────┐
│ tab (*itab: concrete type    │ data (unsafe.Pointer to      │
│      + method table)         │       concrete value)        │
└──────────────────────────────┴──────────────────────────────┘
CRITICAL TRAP: An interface is ONLY nil when BOTH tab == nil AND data == nil!
Assigning (*MyError)(nil) sets tab = *itab(MyError), data = 0x0  ==>  err != nil is TRUE!', 'package order

import "database/sql"

type ValidationError struct{ Msg string }
func (e *ValidationError) Error() string { return e.Msg }

func validate(amount int) *ValidationError {
	if amount <= 0 {
		return &ValidationError{Msg: "amount must be positive"}
	}
	return nil
}

// BUG 1: Returns a non-nil error interface even when validate() succeeds!
func ProcessOrder(amount int) error {
	var err *ValidationError
	err = validate(amount)
	return err // iface{tab: *ValidationError, data: nil} != nil !
}

// BUG 2: Direct equality fails when sql.ErrNoRows is wrapped with fmt.Errorf("%w")
func IsMissing(err error) bool {
	return err == sql.ErrNoRows
}', 'package order

import (
	"database/sql"
	"errors"
	"fmt"
)

type ValidationError struct{ Msg string }
func (e *ValidationError) Error() string { return e.Msg }

func validate(amount int) error {
	if amount <= 0 {
		return &ValidationError{Msg: "amount must be positive"}
	}
	return nil // Untyped nil: both tab and data are nil
}

func ProcessOrder(amount int) error {
	if err := validate(amount); err != nil {
		return fmt.Errorf("validating order amount %d: %w", amount, err)
	}
	return nil
}

func IsMissing(err error) bool {
	return errors.Is(err, sql.ErrNoRows)
}', 'Returning `error` directly from `validate` (or checking `if err != nil` before returning) guarantees a true nil interface `(nil, nil)`. Using `errors.Is` walks the entire `Unwrap()` chain safely.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-interfaces-errors-generics-ref-1', 'l1-interfaces-errors-generics', 'Go Blog: Working with Errors in Go 1.13+', 'https://go.dev/blog/go1.13-errors', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-interfaces-errors-generics-ref-2', 'l1-interfaces-errors-generics', 'Go FAQ: Why is my nil error value not equal to nil?', 'https://go.dev/doc/faq#nil_error', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-interfaces-errors-generics-ref-3', 'l1-interfaces-errors-generics', 'Go Tutorial: Getting started with Generics', 'https://go.dev/doc/tutorial/generics', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l1-interfaces-errors-generics', 'l1-interfaces-errors-generics', 'Wrap Domain Errors and Classify with errors.Is & errors.As', 'Implement ClassifyRepositoryError(err error) int that maps wrapped ErrRecordNotFound to HTTP 404 (404), wrapped *QuotaExceededError to HTTP 429 (429), and any other non-nil error to HTTP 500 (500).', 'package domain

import "errors"

var ErrRecordNotFound = errors.New("record not found")

type QuotaExceededError struct {
	Limit int
}

func (e *QuotaExceededError) Error() string { return "quota exceeded" }

func ClassifyRepositoryError(err error) int {
	if err == nil {
		return 200
	}
	// STEP: Use errors.Is for ErrRecordNotFound -> 404
	// STEP: Use errors.As for *QuotaExceededError -> 429
	return 500
}', 'Invarian: Wrapped Not Found Returns404
Invarian: Wrapped Quota Exceeded Returns429
Invarian: Nil Error Returns200', 'package domain

import "errors"

var ErrRecordNotFound = errors.New("record not found")

type QuotaExceededError struct {
	Limit int
}

func (e *QuotaExceededError) Error() string { return "quota exceeded" }

func ClassifyRepositoryError(err error) int {
	if err == nil {
		return 200
	}
	if errors.Is(err, ErrRecordNotFound) {
		return 404
	}
	var qErr *QuotaExceededError
	if errors.As(err, &qErr) {
		return 429
	}
	return 500
}', 'errors.Is checks value identity across wrapped error chains, while errors.As extracts a pointer to a specific concrete error struct from anywhere in the chain.', 'Write a generic PaginatedResponse[T any] struct that wraps []T items with TotalCount and NextCursor.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-interfaces-errors-generics-tc-1', 'ex-l1-interfaces-errors-generics', 1, 'ClassifyRepositoryError(fmt.Errorf(''db: %w'', ErrRecordNotFound)) == 404', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-interfaces-errors-generics-tc-2', 'ex-l1-interfaces-errors-generics', 2, 'ClassifyRepositoryError(fmt.Errorf(''rate: %w'', &QuotaExceededError{Limit: 10})) == 429', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l2-concurrency-runtime', 3, 7, 'mod-l2-concurrency-runtime', 'Module 2.A — GMP Scheduler, Channels & Context', 'Deep dive into the Go runtime''s GMP work-stealing scheduler, buffered vs unbuffered channels, sync.Mutex vs channels, context cancellation propagation, race detection, and leak-free worker pools.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l2-gmp-channels-context-workers', 'mod-l2-concurrency-runtime', 3, 2, '2.1', 'l2-gmp-channels-context-workers', '2.1 GMP Scheduler, Channels, Select, Mutexes, Context & Bounded Worker Pools', 'Deep dive into the Go runtime''s GMP work-stealing scheduler, buffered vs unbuffered channels, sync.Mutex vs channels, context cancellation propagation, race detection, and leak-free worker pools.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l2-gmp-channels-context-workers-sec-main', 'l2-gmp-channels-context-workers', 'core', '2.1 GMP Scheduler, Channels, Select, Mutexes, Context & Bounded Worker Pools', '{"beginner": "A Goroutine (`go fn()`) is an ultra-lightweight background worker managed by Go\u2014you can run 50,000 of them on a laptop. Channels (`chan T`) are typed pipes that let goroutines hand data to each other safely, while `context.Context` is a cancel button that tells all child workers to stop immediately if the user disconnects or times out.", "intermediate": "An unbuffered channel (`make(chan T)`) requires sender and receiver to rendezvous simultaneously; a buffered channel (`make(chan T, N)`) only blocks the sender when the buffer is full. Always use a `select` statement checking `case <-ctx.Done():` alongside channel sends/receives so goroutines exit cleanly when a request is canceled.", "advanced": "Channel operations acquire an internal `hchan.lock` mutex and copy values (unless passing pointers). For simple state protection (like a local cache or counter), `sync.Mutex`, `sync.RWMutex`, or `atomic.Int64` avoids `hchan` scheduling overhead. Furthermore, whenever spawning a child goroutine that writes a single result back to a parent waiting on a `select` with `<-ctx.Done()`, always allocate a buffered channel of size 1 (`make(chan result, 1)`) so the child can deposit its result and exit even if the parent already timed out."}', 'Go Runtime GMP Work-Stealing Scheduler:
  [P0 (Logical Processor, GOMAXPROCS)]           [P1 (Logical Processor)]
      │ Local Run Queue: [G2, G3, G4]                │ Local Run Queue: [] (Empty -> Steals half from P0!)
      ▼                                              ▼
  [M0 (OS Kernel Thread)]                        [M1 (OS Kernel Thread)]
      │ Executing G1                                 │ Executing Stolen G4
      └──► If G1 blocks on Network/Channel, G1 parks & M0 immediately runs G2!', 'package fetcher

import (
	"context"
	"errors"
)

func FetchWithTimeout(ctx context.Context) (string, error) {
	ch := make(chan string) // BUG: Unbuffered channel (size 0)!

	go func() {
		data := slowRPC()
		// If ctx.Done() fired first, NOBODY is reading from ch anymore.
		// This goroutine blocks here FOREVER, leaking memory!
		ch <- data
	}()

	select {
	case res := <-ch:
		return res, nil
	case <-ctx.Done():
		return "", errors.New("request timed out")
	}
}', 'package fetcher

import "context"

func FetchWithTimeout(ctx context.Context) (string, error) {
	// Buffer of 1 guarantees the child goroutine can always write and exit
	// even if the parent already returned on ctx.Done()
	ch := make(chan string, 1)

	go func() {
		ch <- slowRPCWithContext(ctx)
	}()

	select {
	case res := <-ch:
		return res, nil
	case <-ctx.Done():
		return "", ctx.Err()
	}
}', 'Sizing the single-producer channel to `make(chan string, 1)` decouples the child goroutine''s exit from the parent''s `select` branch. Once the child writes to the 1-slot buffer and exits, the channel and buffer become unreachable and are cleanly garbage collected.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l2-gmp-channels-context-workers-ref-1', 'l2-gmp-channels-context-workers', 'Go Blog: Go Concurrency Patterns: Pipelines and cancellation', 'https://go.dev/blog/pipelines', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l2-gmp-channels-context-workers-ref-2', 'l2-gmp-channels-context-workers', 'Go Blog: Go Concurrency Patterns: Context', 'https://go.dev/blog/context', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l2-gmp-channels-context-workers-ref-3', 'l2-gmp-channels-context-workers', 'Go Data Race Detector Manual', 'https://go.dev/doc/articles/race_detector', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l2-gmp-channels-context-workers', 'l2-gmp-channels-context-workers', 'Implement a Context-Cancelable Bounded Worker Pool', 'Write RunBoundedPool(ctx context.Context, maxWorkers int, jobs []int, fn func(context.Context, int) error) error that processes jobs concurrently using at most maxWorkers goroutines and halts early if ctx is canceled.', 'package concurrency

import (
	"context"
	"sync"
)

func RunBoundedPool(ctx context.Context, maxWorkers int, jobs []int, fn func(context.Context, int) error) error {
	// STEP: Create a jobs channel and error channel
	// STEP: Spawn maxWorkers goroutines tracked by sync.WaitGroup
	// STEP: Respect ctx.Done() so workers don''t leak on cancellation
	return nil
}', 'Invarian: Bounded Pool Respects Max Workers
Invarian: Bounded Pool Cancels On Error
Invarian: Zero Goroutine Leaks', 'package concurrency

import (
	"context"
	"sync"
)

func RunBoundedPool(ctx context.Context, maxWorkers int, jobs []int, fn func(context.Context, int) error) error {
	if maxWorkers <= 0 {
		maxWorkers = 1
	}
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	jobCh := make(chan int)
	var (
		wg       sync.WaitGroup
		firstErr error
		errOnce  sync.Once
	)

	for i := 0; i < maxWorkers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for job := range jobCh {
				if err := fn(ctx, job); err != nil {
					errOnce.Do(func() {
						firstErr = err
						cancel()
					})
					return
				}
			}
		}()
	}

	for _, job := range jobs {
		if ctx.Err() != nil {
			break
		}
		select {
		case <-ctx.Done():
		case jobCh <- job:
		}
	}
	close(jobCh)
	wg.Wait()

	if firstErr != nil {
		return firstErr
	}
	return ctx.Err()
}', 'Combining a derived `context.WithCancel`, `sync.Once` to capture the first error, and `sync.WaitGroup` guarantees bounded concurrency and deterministic worker cleanup before the function returns.', 'Replace manual channel coordination with `golang.org/x/sync/errgroup` (`g.SetLimit(maxWorkers)`) and compare readability.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l2-gmp-channels-context-workers-tc-1', 'ex-l2-gmp-channels-context-workers', 1, 'Active concurrent workers never exceed maxWorkers', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l2-gmp-channels-context-workers-tc-2', 'ex-l2-gmp-channels-context-workers', 2, 'Returning an error from fn cancels remaining queued jobs and returns that error', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l2-profiling-optimization', 3, 8, 'mod-l2-profiling-optimization', 'Module 2.B — Profiling (pprof), Execution Tracer & Memory Optimization', 'Diagnosing production CPU bottlenecks, heap allocation hotspots (alloc_space vs inuse_space), mutex contention, and goroutine leaks using runtime/pprof, go tool trace, and benchmarks.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l2-profiling-pprof-benchmarks', 'mod-l2-profiling-optimization', 3, 3, '2.2', 'l2-profiling-pprof-benchmarks', '2.2 CPU & Heap Profiling (pprof), sync.Pool, Contention Profiling & Execution Tracer', 'Diagnosing production CPU bottlenecks, heap allocation hotspots (alloc_space vs inuse_space), mutex contention, and goroutine leaks using runtime/pprof, go tool trace, and benchmarks.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l2-profiling-pprof-benchmarks-sec-main', 'l2-profiling-pprof-benchmarks', 'core', '2.2 CPU & Heap Profiling (pprof), sync.Pool, Contention Profiling & Execution Tracer', '{"beginner": "Before trying to make code ''faster'', measure it! Go includes a built-in profiler called `pprof` that shows you a map (Flamegraph) of which functions use the most CPU or create the most memory garbage.", "intermediate": "Understand the two Heap Profile modes in `pprof`: 1) `--inuse_space` shows memory that is still alive right now (use this to find memory leaks); 2) `--alloc_space` shows total memory allocated over time even if already freed by the GC (use this to find functions causing high Garbage Collector CPU usage).", "advanced": "When pooling buffers with `sync.Pool`: 1) Always `Reset()` the buffer before `Put`ting it back (or immediately after `Get`), or User B may read User A''s leftover bytes! 2) Guard against pooling abnormally huge buffers (e.g., if `buf.Cap() > 64<<10`, drop it instead of returning it to `sync.Pool`) so a single 20MB spike doesn''t pin 20MB buffers across all `P` caches."}', 'Go Profiling & Diagnostics Spectrum:
┌──────────────────────┬────────────────────────────────────────────────────────────────┐
│ Profile Type         │ What Question Does It Answer?                                  │
├──────────────────────┼────────────────────────────────────────────────────────────────┤
│ CPU Profile          │ Where is the program spending active CPU cycles (on-CPU)?      │
│ Heap (inuse_space)   │ What live objects are currently retained in RAM (memory leaks)?│
│ Heap (alloc_space)   │ What functions allocate the most temporary garbage (GC churn)? │
│ Goroutine Profile    │ Are 50,000 goroutines parked waiting on a leaked channel/lock? │
│ Mutex / Block Profile│ Which sync.Mutex or channel is serializing concurrent workers? │
└──────────────────────┴────────────────────────────────────────────────────────────────┘', 'package handler

import (
	"net/http"
	_ "net/http/pprof" // BUG 1: Registers /debug/pprof on http.DefaultServeMux!
	"regexp"
)

func IsValidCode(input string) bool {
	// BUG 2: Re-parses and compiles regex automaton on EVERY request (~15,000 ns & 30 allocs/op)!
	re := regexp.MustCompile(`^[A-Z0-9]{6,12}$`)
	return re.MatchString(input)
}', 'package handler

import (
	"net/http"
	"net/http/pprof"
	"regexp"
)

// Compiled once at startup: MatchString takes ~40ns and 0 allocs/op
var codePattern = regexp.MustCompile(`^[A-Z0-9]{6,12}$`)

func IsValidCode(input string) bool {
	return codePattern.MatchString(input)
}

// Isolated admin mux bound ONLY to 127.0.0.1:6060
func NewInternalAdminMux() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /debug/pprof/", pprof.Index)
	mux.HandleFunc("GET /debug/pprof/profile", pprof.Profile)
	mux.HandleFunc("GET /debug/pprof/symbol", pprof.Symbol)
	mux.HandleFunc("GET /debug/pprof/trace", pprof.Trace)
	return mux
}', 'Hoisting `regexp.MustCompile` to package initialization reduces allocations per call to zero, and binding `pprof` to an explicit `127.0.0.1` admin `ServeMux` prevents accidental public exposure.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l2-profiling-pprof-benchmarks-ref-1', 'l2-profiling-pprof-benchmarks', 'Go Blog: Profiling Go Programs', 'https://go.dev/blog/pprof', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l2-profiling-pprof-benchmarks-ref-2', 'l2-profiling-pprof-benchmarks', 'Go Standard Library: runtime/pprof', 'https://pkg.go.dev/runtime/pprof', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l2-profiling-pprof-benchmarks', 'l2-profiling-pprof-benchmarks', 'Safely Recycle a Pooled Buffer with Size Cap Guard', 'Implement ShouldReturnBufferToPool(bufCap, maxPooledCap int) bool that returns true only when bufCap > 0 and bufCap <= maxPooledCap so oversized buffers are not pinned in sync.Pool.', 'package poolutil

func ShouldReturnBufferToPool(bufCap, maxPooledCap int) bool {
	// STEP: Return true only if bufCap > 0 and bufCap <= maxPooledCap
	return false
}', 'Invarian: Should Return Buffer To Pool', 'package poolutil

func ShouldReturnBufferToPool(bufCap, maxPooledCap int) bool {
	return bufCap > 0 && bufCap <= maxPooledCap
}', 'Refusing to return buffers larger than 64KB (`65536`) to `sync.Pool` prevents rare multi-megabyte requests from permanently inflating memory footprint (documented in Go standard library `fmt` and `encoding/json` pools).', 'Run `go test -bench=. -benchmem` comparing `fmt.Sprintf` vs `strconv.Itoa` in a tight loop.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l2-profiling-pprof-benchmarks-tc-1', 'ex-l2-profiling-pprof-benchmarks', 1, 'ShouldReturnBufferToPool(4096, 65536) == true', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l2-profiling-pprof-benchmarks-tc-2', 'ex-l2-profiling-pprof-benchmarks', 2, 'ShouldReturnBufferToPool(1048576, 65536) == false', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l3-http-engineering', 4, 9, 'mod-l3-http-engineering', 'Module 3.A — Production HTTP Servers, Middleware & Routers', 'Building production HTTP servers, middleware chains, structured logging (log/slog), cursor pagination, token-bucket rate limiting, and comparing net/http against Chi, Gin, Echo, and Fiber.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l3-net-http-routers', 'mod-l3-http-engineering', 4, 2, '3.1', 'l3-net-http-routers', '3.1 Standard net/http (Go 1.22+) vs Chi, Gin, Echo & Fiber + Middleware & Graceful Shutdown', 'Building production HTTP servers, middleware chains, structured logging (log/slog), cursor pagination, token-bucket rate limiting, and comparing net/http against Chi, Gin, Echo, and Fiber.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l3-net-http-routers-sec-main', 'l3-net-http-routers', 'core', '3.1 Standard net/http (Go 1.22+) vs Chi, Gin, Echo & Fiber + Middleware & Graceful Shutdown', '{"beginner": "A router looks at the incoming URL and HTTP method (like `GET /users/42`) and calls the right Go function. Middleware wraps your functions like layers of an onion to handle logging, security headers, and authentication in one place. Since Go 1.22, Go''s built-in `http.ServeMux` can handle methods and `{id}` variables without needing any external library!", "intermediate": "Compare routers by `http.Handler` compatibility: `net/http` and `Chi` use standard `func(w http.ResponseWriter, r *http.Request)`, whereas `Gin` (`func(*gin.Context)`) and `Echo` (`func(echo.Context) error`) introduce custom context types. For pagination on tables >100k rows, replace `LIMIT 20 OFFSET 100000` (which forces the DB to scan and discard 100,000 rows) with keyset/cursor pagination (`WHERE (created_at, id) < ($1, $2) ORDER BY created_at DESC, id DESC LIMIT 20`).", "advanced": "During a Kubernetes rolling update, Kubernetes sends `SIGTERM` to your container while simultaneously removing its IP from `EndpointSlices`. Because kube-proxy/Ingress updates propagate asynchronously across nodes, your pod may still receive new requests for 1\u20133 seconds after `SIGTERM`. A production shutdown handler traps `SIGTERM`, marks `/readyz` as `503 Service Unavailable`, optionally pauses briefly for load-balancer propagation, and then calls `httpServer.Shutdown(ctx)` so in-flight requests finish cleanly before closing the DB pool."}', 'HTTP Framework & Router Engineering Trade-Off Spectrum:
┌──────────────────────┬────────────────────┬───────────────────┬──────────────────────────────────────────┐
│ Router / Framework   │ net/http Compatible│ Context Type      │ Primary Trade-Off & Sweet Spot           │
├──────────────────────┼────────────────────┼───────────────────┼──────────────────────────────────────────┤
│ Go 1.22+ ServeMux    │ 100% Native        │ context.Context   │ Zero deps; method+wildcard routing built │
│ Chi (go-chi/chi/v5)  │ 100% Native        │ context.Context   │ Sub-routers & middleware groups, 0 lockin│
│ Gin                  │ Custom Wrapper     │ *gin.Context      │ Fast radix tree, huge ecosystem, coupled │
│ Echo                 │ Custom Wrapper     │ echo.Context      │ Ergonomic central error handler          │
│ Fiber                │ NO (uses fasthttp) │ *fiber.Ctx        │ Unsafe zero-alloc reuse, breaks stdlib!  │
└──────────────────────┴────────────────────┴───────────────────┴──────────────────────────────────────────┘', 'package api

import (
	"fmt"
	"net/http"
)

// BUG 1: Deep OFFSET scans and discards all preceding rows (O(N) database cost)
func BuildPageQuery(page, pageSize int) string {
	offset := (page - 1) * pageSize
	return fmt.Sprintf("SELECT id, title FROM articles ORDER BY created_at DESC LIMIT %d OFFSET %d", pageSize, offset)
}

// BUG 2: Default ListenAndServe drops all in-flight customer payments on SIGTERM
func RunServer(mux http.Handler) {
	_ = http.ListenAndServe(":8080", mux)
}', 'package api

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

// O(1) Index Seek using composite index ON articles(created_at DESC, id DESC)
const KeysetPaginationSQL = `
SELECT id, title, created_at
FROM articles
WHERE (created_at, id) < ($1, $2)
ORDER BY created_at DESC, id DESC
LIMIT $3;
`

func RunGracefulServer(mux http.Handler) error {
	srv := &http.Server{
		Addr:         ":8080",
		Handler:      mux,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	errCh := make(chan error, 1)
	go func() {
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errCh <- err
		}
		close(errCh)
	}()

	select {
	case err := <-errCh:
		return err
	case <-ctx.Done():
		slog.Info("SIGTERM received, draining active connections")
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		return srv.Shutdown(shutdownCtx)
	}
}', 'Keyset pagination uses a B-Tree index seek on `(created_at DESC, id DESC)` to deliver constant sub-millisecond latency at page 1 or page 50,000. `srv.Shutdown(shutdownCtx)` stops accepting new connections and waits for active handlers to finish.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l3-net-http-routers-ref-1', 'l3-net-http-routers', 'Go Blog: Routing Enhancements for Go 1.22', 'https://go.dev/blog/routing-enhancements', 'Go 1.22+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l3-net-http-routers-ref-2', 'l3-net-http-routers', 'Go Blog: Structured Logging with slog', 'https://go.dev/blog/slog', 'Go 1.21+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l3-net-http-routers-ref-3', 'l3-net-http-routers', 'Chi Router Documentation (github.com/go-chi/chi/v5)', 'https://pkg.go.dev/github.com/go-chi/chi/v5', 'v5.1+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l3-net-http-routers', 'l3-net-http-routers', 'Build a Composable Request-ID & Panic-Recovery Middleware Chain', 'Implement WithRecoveryAndRequestID(next http.Handler) http.Handler that sets an X-Request-ID response header (reusing the incoming header or defaulting to ''req-generated'') and recovers from any downstream panic by returning HTTP 500 JSON.', 'package middleware

import "net/http"

func WithRecoveryAndRequestID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// STEP: Set X-Request-ID header on w
		// STEP: Defer recover() and return 500 JSON if next.ServeHTTP panics
		next.ServeHTTP(w, r)
	})
}', 'Invarian: Middleware Preserves Request I D
Invarian: Middleware Recovers Panic With500', 'package middleware

import "net/http"

func WithRecoveryAndRequestID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		reqID := r.Header.Get("X-Request-ID")
		if reqID == "" {
			reqID = "req-generated"
		}
		w.Header().Set("X-Request-ID", reqID)

		defer func() {
			if rec := recover(); rec != nil {
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusInternalServerError)
				_, _ = w.Write([]byte(`{"error":"internal server error"}`))
			}
		}()

		next.ServeHTTP(w, r)
	})
}', 'By registering `defer` before calling `next.ServeHTTP`, any panic inside the handler stack is isolated to the current request goroutine and translated into a clean 500 response.', 'Inject the request ID into `r.Context()` using an unexported key type `type ctxKeyRequestID struct{}` so `log/slog` handlers can log it automatically.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l3-net-http-routers-tc-1', 'ex-l3-net-http-routers', 1, 'Downstream panic returns HTTP 500 instead of crashing the test runner', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l3-net-http-routers-tc-2', 'ex-l3-net-http-routers', 2, 'Response always contains non-empty X-Request-ID header', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l3-contracts-security', 4, 10, 'mod-l3-contracts-security', 'Module 3.B — Validation, Rate Limiting, CORS & OpenAPI 3.1', 'Implementing deterministic DTO validation, per-IP/tenant token-bucket rate limiting, strict CORS origin allowlists (avoiding Access-Control-Allow-Origin: * with credentials), and OpenAPI 3.1 contract-first engineering.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l3-validation-openapi-ratelimit', 'mod-l3-contracts-security', 4, 3, '3.2', 'l3-validation-openapi-ratelimit', '3.2 Request Validation, Token-Bucket Rate Limiting, CORS Allowlists & OpenAPI 3.1 Contracts', 'Implementing deterministic DTO validation, per-IP/tenant token-bucket rate limiting, strict CORS origin allowlists (avoiding Access-Control-Allow-Origin: * with credentials), and OpenAPI 3.1 contract-first engineering.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l3-validation-openapi-ratelimit-sec-main', 'l3-validation-openapi-ratelimit', 'core', '3.2 Request Validation, Token-Bucket Rate Limiting, CORS Allowlists & OpenAPI 3.1 Contracts', '{"beginner": "Rate Limiting stops a single user or bot from sending 10,000 requests per second and crashing your server. A Token Bucket gives each user a bucket of tokens (say, 20 tokens) that refills at 10 tokens per second\u2014each request costs 1 token, and when the bucket is empty, the server returns `429 Too Many Requests`.", "intermediate": "When configuring CORS in Go, never reflect `w.Header().Set(\"Access-Control-Allow-Origin\", r.Header.Get(\"Origin\"))` unconditionally! Maintain an explicit `map[string]bool` allowlist of trusted origins, and always set `w.Header().Add(\"Vary\", \"Origin\")` so reverse proxies and CDNs do not serve Origin A''s cached headers to Origin B.", "advanced": "For an in-memory per-IP Token Bucket map (`map[netip.Addr]*bucket`) in Go, an attacker rotating through IPv6 addresses can create millions of map entries and OOM-kill your process. Always pair in-memory rate limiters with either a bounded LRU/sharded map or a background cleanup ticker that deletes buckets idle for >5 minutes."}', 'Token Bucket Rate Limiter (Rate R tokens/sec, Burst Capacity B):
  [Bucket Capacity B = 20 tokens]  <── Refills continuously at R = 10 tokens/sec
       │
       ├── Incoming HTTP Request:
       │     ├── If tokens >= 1: decrement token -> 200 OK (X-RateLimit-Remaining: N)
       │     └── If tokens < 1 : reject immediately -> 429 Too Many Requests (Retry-After: 1)', 'package middleware

import "net/http"

func InsecureCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// BUG 1: Reflects ANY attacker origin with credentials enabled!
		w.Header().Set("Access-Control-Allow-Origin", r.Header.Get("Origin"))
		w.Header().Set("Access-Control-Allow-Credentials", "true")
		// BUG 2: Missing Vary: Origin header poisons intermediate HTTP caches!
		next.ServeHTTP(w, r)
	})
}', 'package middleware

import "net/http"

func AllowlistCORS(allowedOrigins map[string]bool) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Add("Vary", "Origin")
			origin := r.Header.Get("Origin")
			if origin != "" && allowedOrigins[origin] {
				w.Header().Set("Access-Control-Allow-Origin", origin)
				w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
				w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Request-ID, Idempotency-Key")
			}
			if r.Method == http.MethodOptions {
				w.WriteHeader(http.StatusNoContent)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}', 'Checking `allowedOrigins[origin]` against a strict configuration map and always emitting `Vary: Origin` enforces least-privilege cross-origin access and safe proxy caching.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l3-validation-openapi-ratelimit-ref-1', 'l3-validation-openapi-ratelimit', 'Go x/time/rate Token Bucket Limiter', 'https://pkg.go.dev/golang.org/x/time/rate', 'v0.7+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l3-validation-openapi-ratelimit-ref-2', 'l3-validation-openapi-ratelimit', 'OWASP API8:2023 Security Misconfiguration (CORS)', 'https://api-security.owasp.org/editions/2023/en/0xa8-security-misconfiguration/', '2023 Edition', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l3-validation-openapi-ratelimit', 'l3-validation-openapi-ratelimit', 'Implement an Origin Allowlist Checker & Token Bucket Refill Calculation', 'Complete ComputeAvailableTokens(currentTokens, ratePerSec, burstMax, elapsedSec float64) float64 so that it adds elapsedSec * ratePerSec and caps the result at burstMax.', 'package ratelimit

func ComputeAvailableTokens(currentTokens, ratePerSec, burstMax, elapsedSec float64) float64 {
	// STEP: If elapsedSec > 0, add elapsedSec * ratePerSec to currentTokens
	// STEP: Clamp result so it never exceeds burstMax
	return currentTokens
}', 'Invarian: Compute Available Tokens', 'package ratelimit

func ComputeAvailableTokens(currentTokens, ratePerSec, burstMax, elapsedSec float64) float64 {
	if elapsedSec > 0 {
		currentTokens += elapsedSec * ratePerSec
	}
	if currentTokens > burstMax {
		return burstMax
	}
	return currentTokens
}', 'Continuous time-delta token refill avoids background timer goroutines for every single bucket—refill is calculated lazily on request arrival.', 'Compare memory usage of lazy time-delta token buckets against `golang.org/x/time/rate.Limiter`.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l3-validation-openapi-ratelimit-tc-1', 'ex-l3-validation-openapi-ratelimit', 1, 'ComputeAvailableTokens(5, 10, 20, 1.0) == 15', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l3-validation-openapi-ratelimit-tc-2', 'ex-l3-validation-openapi-ratelimit', 2, 'ComputeAvailableTokens(15, 10, 20, 2.0) == 20', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l4-db-internals', 5, 11, 'mod-l4-db-internals', 'Module 4.A — Storage Engines, MVCC, Indexing & Query Planning', 'Deep architectural comparison of PostgreSQL, MySQL (InnoDB), MariaDB, SQLite (WAL), MongoDB (WiredTiger), Redis, and ScyllaDB; plus MVCC, Locking, Composite B-Tree/GIN Indexes, and reading EXPLAIN ANALYZE query plans.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l4-acid-isolation-mvcc', 'mod-l4-db-internals', 5, 2, '4.1', 'l4-acid-isolation-mvcc', '4.1 Relational vs NoSQL Internals, MVCC, ACID Isolation Levels, Indexing & EXPLAIN ANALYZE', 'Deep architectural comparison of PostgreSQL, MySQL (InnoDB), MariaDB, SQLite (WAL), MongoDB (WiredTiger), Redis, and ScyllaDB; plus MVCC, Locking, Composite B-Tree/GIN Indexes, and reading EXPLAIN ANALYZE query plans.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l4-acid-isolation-mvcc-sec-main', 'l4-acid-isolation-mvcc', 'core', '4.1 Relational vs NoSQL Internals, MVCC, ACID Isolation Levels, Indexing & EXPLAIN ANALYZE', '{"beginner": "A database isn''t a magic black box\u2014without an Index, asking for `WHERE email = ''alice@example.com''` forces the database to read every single row on disk (a Sequential Scan). An Index is like a sorted book index (a B-Tree) that jumps straight to the matching row in a few steps. And Transactions (ACID) ensure that if money leaves Account A, it is guaranteed to arrive in Account B, even if the server crashes halfway through.", "intermediate": "Composite B-Tree indexes follow the Leftmost Prefix Rule: an index on `(tenant_id, status, created_at)` accelerates queries filtering on `tenant_id`, `(tenant_id, status)`, or `(tenant_id, status, created_at)`, but cannot be used as a primary index seek for a query filtering only on `status`. Furthermore, understand SQL Isolation Levels: PostgreSQL defaults to `READ COMMITTED` (each statement sees a fresh snapshot committed before that statement began), whereas MySQL InnoDB defaults to `REPEATABLE READ` (snapshot fixed at the first read in the transaction).", "advanced": "In PostgreSQL `EXPLAIN (ANALYZE, BUFFERS)`, inspect `Buffers: shared hit=X read=Y` alongside `actual time` and `loops`. A `Nested Loop` with `loops=500` executes the inner node 500 times (multiply inner `actual time` by `loops`!). Also beware MVCC write skew under `REPEATABLE READ`: two doctors on call simultaneously check `SELECT count(*) FROM doctors WHERE on_call = true` (seeing 2), and both update their own row to `false`. Because they update disjoint rows, `REPEATABLE READ` permits both commits unless you use `SERIALIZABLE` (which detects the rw-antidependency cycle via SSI and aborts one with SQLSTATE `40001`)."}', 'PostgreSQL MVCC vs MySQL InnoDB Clustered Storage:
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ PostgreSQL Heap Page (8KB): Stores Tuple Versions (xmin, xmax, ctid) directly in heap. │
│   • Secondary B-Tree Index points to physical Heap Tuple (ctid).                       │
│   • UPDATE writes a NEW tuple version (unless Heap-Only Tuple / HOT applies);          │
│     Autovacuum reclaims dead tuples later. Readers NEVER block writers!                │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ MySQL InnoDB Page (16KB): Table IS a Clustered B+Tree ordered by PRIMARY KEY.          │
│   • Secondary Index leaf stores the PRIMARY KEY value (requires double B+Tree lookup). │
│   • UPDATE modifies row in-place and writes old version to Undo Log for MVCC reads.    │
└────────────────────────────────────────────────────────────────────────────────────────┘', 'package wallet

import (
	"context"
	"database/sql"
	"errors"
)

// BUG 1: Classic TOCTOU / Lost Update under READ COMMITTED!
// Two concurrent requests both read balance=100, both subtract 80, and both set balance=20!
func WithdrawUnsafe(ctx context.Context, db *sql.DB, accountID string, amount int64) error {
	var balance int64
	_ = db.QueryRowContext(ctx, "SELECT balance FROM accounts WHERE id = $1", accountID).Scan(&balance)
	if balance < amount {
		return errors.New("insufficient funds")
	}
	_, err := db.ExecContext(ctx, "UPDATE accounts SET balance = $1 WHERE id = $2", balance-amount, accountID)
	return err
}', 'package wallet

import (
	"context"
	"database/sql"
	"errors"
)

var ErrInsufficientFunds = errors.New("insufficient funds")

// Atomic single-statement guard or explicit row lock inside a transaction:
// Deterministically prevents lost updates and double-spending.
func WithdrawAtomic(ctx context.Context, db *sql.DB, accountID string, amount int64) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	res, err := tx.ExecContext(ctx, `
		UPDATE accounts
		SET balance = balance - $1, updated_at = CURRENT_TIMESTAMP
		WHERE id = $2 AND balance >= $1
	`, amount, accountID)
	if err != nil {
		return err
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return ErrInsufficientFunds
	}

	// Insert immutable ledger entry in the same ACID transaction
	_, err = tx.ExecContext(ctx, `
		INSERT INTO ledger_entries (account_id, delta, created_at)
		VALUES ($1, -$2, CURRENT_TIMESTAMP)
	`, accountID, amount)
	if err != nil {
		return err
	}

	return tx.Commit()
}', 'The `WHERE id = $2 AND balance >= $1` predicate acquires an exclusive row-level lock on the target tuple and re-evaluates the condition after any concurrent transaction commits, guaranteeing that `balance` can never drop below zero.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l4-acid-isolation-mvcc-ref-1', 'l4-acid-isolation-mvcc', 'PostgreSQL 17+ Documentation: Chapter 13. Concurrency Control (MVCC)', 'https://www.postgresql.org/docs/current/mvcc-intro.html', 'PostgreSQL 17+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l4-acid-isolation-mvcc-ref-2', 'l4-acid-isolation-mvcc', 'PostgreSQL 17+ Documentation: 14.1. Using EXPLAIN & EXPLAIN ANALYZE', 'https://www.postgresql.org/docs/current/using-explain.html', 'PostgreSQL 17+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l4-acid-isolation-mvcc-ref-3', 'l4-acid-isolation-mvcc', 'PostgreSQL 17+ Documentation: 11.2. Index Types (B-Tree, GIN, GiST, BRIN)', 'https://www.postgresql.org/docs/current/indexes-types.html', 'PostgreSQL 17+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l4-acid-isolation-mvcc-ref-4', 'l4-acid-isolation-mvcc', 'SQLite Official Documentation: Write-Ahead Logging (WAL)', 'https://www.sqlite.org/docs.html', 'SQLite 3.45+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l4-acid-isolation-mvcc', 'l4-acid-isolation-mvcc', 'Design a Covering Composite Index & Prevent Deadlocks on Multi-Account Transfers', 'Implement LockOrder(fromAccountID, toAccountID string) (firstID, secondID string) that returns account IDs in deterministic lexicographical order before running SELECT ... FOR UPDATE so two concurrent transfers (A->B and B->A) can never deadlock.', 'package ledger

func LockOrder(fromAccountID, toAccountID string) (string, string) {
	// STEP: Return the two account IDs in ascending lexicographical order
	return fromAccountID, toAccountID
}', 'Invarian: Lock Order Prevents A B  B A  Deadlock
Lock Order for (''acc_99'', ''acc_01'') -> (''acc_01'', ''acc_99'')', 'package ledger

func LockOrder(fromAccountID, toAccountID string) (string, string) {
	if fromAccountID < toAccountID {
		return fromAccountID, toAccountID
	}
	return toAccountID, fromAccountID
}', 'Enforcing a global total ordering when acquiring row locks (`SELECT id FROM accounts WHERE id IN ($1, $2) ORDER BY id ASC FOR UPDATE`) eliminates the circular-wait condition required for a deadlock.', 'Write the PostgreSQL `CREATE INDEX` statement using `INCLUDE (amount)` to satisfy `SELECT amount FROM transfers WHERE sender_id = $1 AND created_at > $2` via an Index-Only Scan.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l4-acid-isolation-mvcc-tc-1', 'ex-l4-acid-isolation-mvcc', 1, 'LockOrder(''acct_b'', ''acct_a'') == (''acct_a'', ''acct_b'')', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l4-acid-isolation-mvcc-tc-2', 'ex-l4-acid-isolation-mvcc', 2, 'LockOrder(''acct_a'', ''acct_b'') == (''acct_a'', ''acct_b'')', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l4-scaling-databases', 5, 12, 'mod-l4-scaling-databases', 'Module 4.B — Replication, Partitioning, Sharding & Backup Recovery', 'Understanding synchronous vs asynchronous WAL replication, handling read-your-own-writes consistency across read replicas, declarative Range/Hash partitioning vs horizontal sharding, and verified PITR backups.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l4-partitioning-replication-sharding', 'mod-l4-scaling-databases', 5, 3, '4.2', 'l4-partitioning-replication-sharding', '4.2 Streaming Replication Lag, Declarative Partitioning, Sharding & Point-in-Time Recovery (PITR)', 'Understanding synchronous vs asynchronous WAL replication, handling read-your-own-writes consistency across read replicas, declarative Range/Hash partitioning vs horizontal sharding, and verified PITR backups.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l4-partitioning-replication-sharding-sec-main', 'l4-partitioning-replication-sharding', 'core', '4.2 Streaming Replication Lag, Declarative Partitioning, Sharding & Point-in-Time Recovery (PITR)', '{"beginner": "Partitioning splits one giant table (like `logs` with 500 million rows) into monthly sub-tables (`logs_2026_10`, `logs_2026_11`) inside the same database so queries only look at the current month. Replication copies your database to backup read-only servers so if the main server dies, a standby server takes over.", "intermediate": "Beware the **Read-Your-Own-Writes** anomaly with asynchronous Read Replicas: a user updates their profile on the Primary DB and their browser immediately reloads the page, hitting a Read Replica that is 50ms behind. The user sees their old profile and thinks the save failed! Fix this by routing a user''s reads to the Primary for a short window (e.g. 3 seconds) after any write, or by comparing the Primary''s `pg_current_wal_insert_lsn()` against the Replica''s `pg_last_wal_replay_lsn()`.", "advanced": "Why is `DROP TABLE logs_2025_01` on a partitioned table 10,000x faster than `DELETE FROM logs WHERE created_at < ''2025-02-01''`? Because `DELETE` in PostgreSQL must visit every row, mark its `xmax` transaction ID, write WAL records for all 50M rows, and leave dead tuples behind for `VACUUM` to clean up\u2014whereas `DETACH` + `DROP` simply unlinks the partition''s underlying OS file descriptors!"}', 'PostgreSQL WAL Streaming Replication & Read-Your-Own-Writes Consistency:
[Go API] ── 1. INSERT order (Primary DB commits & appends LSN 0/16B3748 to WAL) ──► [Primary Postgres]
   │                                                                                        │
   │ 2. Immediate GET /orders (Routed to Read Replica BEFORE LSN 0/16B3748 replays!)        │ Async WAL Stream
   └───────────────────────────────────────────────────────────────────────────────► [Read Replica (LSN 0/16B3600)]
   (Fix: Stick user to Primary for 2s after write, OR wait for pg_last_wal_replay_lsn() >= write_lsn!)', 'package dbrouter

// BUG: Immediately after a user updates their password or order, routing their next GET
// to an async replica returns stale pre-update data (Read-Your-Own-Writes violation)!
func SelectDBForRead(isReadOnlyQuery bool) string {
	if isReadOnlyQuery {
		return "replica_pool"
	}
	return "primary_pool"
}', 'package dbrouter

import "time"

func SelectDBForRead(isReadOnlyQuery bool, lastWriteAge time.Duration, safeReplicationWindow time.Duration) string {
	if !isReadOnlyQuery {
		return "primary_pool"
	}
	// If the caller performed a write recently (e.g. within the last 3 seconds),
	// route reads to primary_pool to guarantee Read-Your-Own-Writes consistency!
	if lastWriteAge >= 0 && lastWriteAge < safeReplicationWindow {
		return "primary_pool"
	}
	return "replica_pool"
}', 'Pinning a user session to the Primary pool for `safeReplicationWindow` (or until replica WAL replay LSN catches up) preserves causal consistency while still offloading 95%+ of general read traffic to replicas.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l4-partitioning-replication-sharding-ref-1', 'l4-partitioning-replication-sharding', 'PostgreSQL 17+ Documentation: Table Partitioning', 'https://www.postgresql.org/docs/current/ddl-partitioning.html', 'PostgreSQL 17+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l4-partitioning-replication-sharding-ref-2', 'l4-partitioning-replication-sharding', 'PostgreSQL 17+ Documentation: High Availability & Replication', 'https://www.postgresql.org/docs/current/high-availability.html', 'PostgreSQL 17+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l4-partitioning-replication-sharding', 'l4-partitioning-replication-sharding', 'Route Reads Safely Using Causal Write-Window Stickiness', 'Implement ChoosePool(isMutation bool, msSinceLastUserWrite int, maxReplicaLagMs int) string returning ''primary'' for mutations or when msSinceLastUserWrite <= maxReplicaLagMs, and ''replica'' otherwise.', 'package routing

func ChoosePool(isMutation bool, msSinceLastUserWrite int, maxReplicaLagMs int) string {
	// STEP: Return "primary" if isMutation is true or msSinceLastUserWrite <= maxReplicaLagMs
	return "replica"
}', 'Invarian: Choose Pool Causal Consistency', 'package routing

func ChoosePool(isMutation bool, msSinceLastUserWrite int, maxReplicaLagMs int) string {
	if isMutation || (msSinceLastUserWrite >= 0 && msSinceLastUserWrite <= maxReplicaLagMs) {
		return "primary"
	}
	return "replica"
}', 'Causal read routing eliminates the most jarring UX bug of read-replica architectures without sacrificing read scalability.', 'Write the PostgreSQL SQL query to check replication lag in bytes using `pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)` from `pg_stat_replication`.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l4-partitioning-replication-sharding-tc-1', 'ex-l4-partitioning-replication-sharding', 1, 'ChoosePool(true, 5000, 1000) == ''primary''', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l4-partitioning-replication-sharding-tc-2', 'ex-l4-partitioning-replication-sharding', 2, 'ChoosePool(false, 250, 1000) == ''primary''', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l4-partitioning-replication-sharding-tc-3', 'ex-l4-partitioning-replication-sharding', 3, 'ChoosePool(false, 2500, 1000) == ''replica''', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l5-go-db-drivers', 6, 13, 'mod-l5-go-db-drivers', 'Module 5.A — Go Database Drivers, Pools & Code Generation', 'Side-by-side comparison of the same transactional query implemented in database/sql, pgx/v5, sqlc, GORM, Ent, and Bun—evaluating type safety, runtime reflection cost, SQL control, and connection pool tuning.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l5-db-ecosystem-comparison', 'mod-l5-go-db-drivers', 6, 2, '5.1', 'l5-db-ecosystem-comparison', '5.1 database/sql vs pgx/v5 vs sqlc vs GORM vs Ent vs Bun & Pool Internals', 'Side-by-side comparison of the same transactional query implemented in database/sql, pgx/v5, sqlc, GORM, Ent, and Bun—evaluating type safety, runtime reflection cost, SQL control, and connection pool tuning.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l5-db-ecosystem-comparison-sec-main', 'l5-db-ecosystem-comparison', 'core', '5.1 database/sql vs pgx/v5 vs sqlc vs GORM vs Ent vs Bun & Pool Internals', '{"beginner": "In Go, you have four main ways to talk to a SQL database: 1) Raw SQL (`database/sql` or `pgx`), where you write SQL and scan columns into variables yourself; 2) Code Generation (`sqlc`), where you write SQL and a tool generates type-safe Go functions for you; 3) Query Builders (`Bun`), where you chain helper methods; and 4) ORMs (`GORM`), which map Go structs to tables automatically at runtime.", "intermediate": "Always remember that `*sql.DB` is NOT a single connection\u2014it is a thread-safe pool of connections created once at startup and shared across the application. When iterating over `rows, err := db.QueryContext(ctx, ...)`, you MUST call `defer rows.Close()` immediately after checking `err != nil`, and check `rows.Err()` after the `for rows.Next()` loop finishes.", "advanced": "Compare the same `GetUserOrders` operation across all four approaches: `GORM`''s `db.Preload(\"Orders\").First(&user, id)` executes two queries and uses `reflect.Value` allocation per field; `sqlc` compiles your SQL `JOIN` or `json_agg` query into direct `row.Scan(&item.ID, &item.Total)` calls over `pgx/v5`''s binary protocol, running 3x\u20135x faster with 70% fewer heap allocations per row."}', 'Go Database Access Layer Trade-Off Matrix:
┌──────────────────┬─────────────────┬─────────────────┬──────────────────┬────────────────────────┐
│ Tool / Library   │ Type Safety     │ Runtime Overhead│ SQL Control      │ Ideal Engineering Fit  │
├──────────────────┼─────────────────┼─────────────────┼──────────────────┼────────────────────────┤
│ database/sql     │ Manual Scan()   │ Low             │ 100% Raw SQL     │ Portable multi-DB code │
│ jackc/pgx/v5     │ Manual / Collect│ Lowest (Binary) │ 100% Postgres SQL│ High-perf Postgres APIs│
│ sqlc             │ Compile-Time Gen│ Lowest (ZeroRef)│ 100% Raw SQL     │ Production Go Standard │
│ Bun              │ Struct Tags     │ Low-Medium      │ High (SQL-first) │ Dynamic filter builders│
│ Ent              │ Codegen Graph   │ Medium          │ Medium (DSL)     │ Deep graph traversals  │
│ GORM             │ Runtime Reflect │ Highest         │ Medium (Hooks)   │ Rapid CRUD prototypes  │
└──────────────────┴─────────────────┴─────────────────┴──────────────────┴────────────────────────┘', 'package repo

import (
	"context"
	"database/sql"
)

func ListActiveUsers(ctx context.Context, dsn string) ([]string, error) {
	// BUG 1: Calling sql.Open on every HTTP request creates a brand new connection pool!
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, err
	}

	// BUG 2: Missing defer rows.Close() leaks the connection if Scan returns an error!
	rows, err := db.QueryContext(ctx, "SELECT email FROM users WHERE active = true")
	if err != nil {
		return nil, err
	}

	var emails []string
	for rows.Next() {
		var e string
		if err := rows.Scan(&e); err != nil {
			return nil, err // Connection remains checked out forever!
		}
		emails = append(emails, e)
	}
	// BUG 3: Never checks rows.Err() for mid-stream network/cursor failures!
	return emails, nil
}', 'package repo

import (
	"context"
	"database/sql"
	"fmt"
)

// Shared *sql.DB injected once at server startup
type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// 1. Standard database/sql implementation (same query in sqlc is 1 line: q.ListActiveUserEmails(ctx))
func (r *UserRepository) ListActiveUsers(ctx context.Context) ([]string, error) {
	const query = `SELECT email FROM users WHERE active = TRUE ORDER BY created_at DESC LIMIT 100`

	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("querying active users: %w", err)
	}
	defer rows.Close() // Guaranteed connection release back to pool

	emails := make([]string, 0, 100)
	for rows.Next() {
		var email string
		if err := rows.Scan(&email); err != nil {
			return nil, fmt.Errorf("scanning user email: %w", err)
		}
		emails = append(emails, email)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterating user rows: %w", err)
	}
	return emails, nil
}', '`defer rows.Close()` ensures the underlying network socket is returned to `*sql.DB`''s idle pool even if `rows.Scan` fails or the context is canceled mid-iteration. Checking `rows.Err()` catches broken TCP pipes during cursor streaming.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l5-db-ecosystem-comparison-ref-1', 'l5-db-ecosystem-comparison', 'Go Official Guide: Managing Connections & Querying Data (database/sql)', 'https://go.dev/doc/database/querying', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l5-db-ecosystem-comparison-ref-2', 'l5-db-ecosystem-comparison', 'pgx/v5 & pgxpool Documentation', 'https://pkg.go.dev/github.com/jackc/pgx/v5/pgxpool', 'v5.7+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l5-db-ecosystem-comparison-ref-3', 'l5-db-ecosystem-comparison', 'sqlc Official Package Reference', 'https://pkg.go.dev/github.com/kyleconroy/sqlc', 'v1.27+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l5-db-ecosystem-comparison', 'l5-db-ecosystem-comparison', 'Calculate Optimal Connection Pool Bounds per Service Replica', 'Implement ComputePoolLimits(pgMaxConns, reservedSuperuserConns, replicaCount int) (maxOpen, maxIdle int) that divides available PostgreSQL connections safely across replicas with a 50% idle ratio.', 'package dbpool

func ComputePoolLimits(pgMaxConns, reservedSuperuserConns, replicaCount int) (maxOpen, maxIdle int) {
	// STEP: Subtract reservedSuperuserConns from pgMaxConns
	// STEP: Divide evenly across replicaCount (guarding replicaCount <= 0)
	// STEP: Set maxIdle to maxOpen / 2 (minimum 1)
	return 0, 0
}', 'Invarian: Compute Pool Limits
Postgres max_connections=200, reserved=20, replicas=6 -> MaxOpenConns=30, MaxIdleConns=15', 'package dbpool

func ComputePoolLimits(pgMaxConns, reservedSuperuserConns, replicaCount int) (maxOpen, maxIdle int) {
	if replicaCount <= 0 {
		replicaCount = 1
	}
	avail := pgMaxConns - reservedSuperuserConns
	if avail < replicaCount {
		return 1, 1
	}
	maxOpen = avail / replicaCount
	maxIdle = maxOpen / 2
	if maxIdle < 1 {
		maxIdle = 1
	}
	return maxOpen, maxIdle
}', 'Sizing `MaxOpenConns` across all deployed Kubernetes pods so that `sum(MaxOpenConns * replicas) + reserved <= max_connections` prevents `FATAL: sorry, too many clients already` errors during traffic spikes.', 'Explain when you should place PgBouncer in transaction-pooling mode in front of PostgreSQL when running 50+ serverless or microservice replicas.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l5-db-ecosystem-comparison-tc-1', 'ex-l5-db-ecosystem-comparison', 1, 'ComputePoolLimits(200, 20, 6) == (30, 15)', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l5-db-ecosystem-comparison-tc-2', 'ex-l5-db-ecosystem-comparison', 2, 'ComputePoolLimits(100, 10, 10) == (9, 4)', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l5-tx-migrations', 6, 14, 'mod-l5-tx-migrations', 'Module 5.B — Zero-Downtime Migrations, Prepared Statements & Tx Propagation', 'Running zero-downtime schema migrations in PostgreSQL (CONCURRENTLY, NOT VALID constraints), avoiding long-held transactions across external HTTP calls, and understanding prepared statement caching in pgx vs PgBouncer.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l5-migrations-transactions-prepared', 'mod-l5-tx-migrations', 6, 3, '5.2', 'l5-migrations-transactions-prepared', '5.2 Expand-and-Contract Zero-Downtime SQL Migrations, Prepared Statements & Transaction Scopes', 'Running zero-downtime schema migrations in PostgreSQL (CONCURRENTLY, NOT VALID constraints), avoiding long-held transactions across external HTTP calls, and understanding prepared statement caching in pgx vs PgBouncer.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l5-migrations-transactions-prepared-sec-main', 'l5-migrations-transactions-prepared', 'core', '5.2 Expand-and-Contract Zero-Downtime SQL Migrations, Prepared Statements & Transaction Scopes', '{"beginner": "Never call an outside API (like sending an email or charging a credit card over HTTP) *inside* an open database transaction (`tx`)! While your Go code waits 2 seconds for the outside API to reply, that database connection and its locked rows are frozen, quickly using up all connections in your pool.", "intermediate": "When adding an index to a large production PostgreSQL table, always use `CREATE INDEX CONCURRENTLY idx_name ON table(col);` so writes are not blocked. Note that `CONCURRENTLY` cannot run inside a `BEGIN ... COMMIT` transaction block, so your migration runner must support non-transactional migration steps when needed.", "advanced": "Why does PostgreSQL''s lock queue cause sudden 100% outages during seemingly harmless `ALTER TABLE` statements? Because `ALTER TABLE` requests an `ACCESS EXCLUSIVE` lock. If a 10-second analytical `SELECT` is currently running on that table, `ALTER TABLE` waits in the lock queue\u2014and PostgreSQL''s lock fairness rules block *every new `SELECT`, `INSERT`, and `UPDATE`* behind the waiting `ALTER TABLE`! Always prepend `SET lock_timeout = ''2s'';` to every DDL migration so it aborts cleanly if it cannot acquire the lock immediately."}', 'Expand-and-Contract Zero-Downtime Schema Migration (Renaming/Changing a Column):
  Phase 1 (Expand)  : ADD new nullable column + trigger/dual-write in Go v1.1 (Old v1.0 pods still work!)
  Phase 2 (Backfill): Batch-update historical rows in small 5,000-row chunks (avoids long table lock)
  Phase 3 (Switch)  : Deploy Go v1.2 reading from new column + validate constraint NOT VALID -> VALIDATE
  Phase 4 (Contract): DROP legacy column in a subsequent release once zero pods reference it', 'package billing

import (
	"context"
	"database/sql"
	"net/http"
)

func ChargeCustomerBad(ctx context.Context, db *sql.DB, orderID string) error {
	tx, _ := db.BeginTx(ctx, nil)
	defer tx.Rollback()

	_, _ = tx.ExecContext(ctx, "UPDATE orders SET status = ''PROCESSING'' WHERE id = $1", orderID)

	// BUG: External network call inside an open DB transaction!
	// If payment-gateway takes 4 seconds, this DB connection & row lock are held for 4 seconds!
	resp, err := http.Post("https://api.payment.example/charge", "application/json", nil)
	if err != nil || resp.StatusCode != 200 {
		return err
	}
	return tx.Commit()
}', 'package billing

import (
	"context"
	"database/sql"
)

func ChargeCustomerSafe(ctx context.Context, db *sql.DB, gw PaymentGateway, orderID string) error {
	// Step 1: Short 1ms transaction records intent & idempotency key, then releases DB connection!
	if _, err := db.ExecContext(ctx, `
		UPDATE orders SET status = ''CHARGE_IN_FLIGHT''
		WHERE id = $1 AND status = ''PENDING''
	`, orderID); err != nil {
		return err
	}

	// Step 2: External RPC executes WITHOUT holding any database connection or row lock
	chargeID, err := gw.ChargeWithIdempotencyKey(ctx, orderID)
	if err != nil {
		_, _ = db.ExecContext(ctx, `UPDATE orders SET status = ''CHARGE_FAILED'' WHERE id = $1`, orderID)
		return err
	}

	// Step 3: Short 1ms transaction records final settlement
	_, err = db.ExecContext(ctx, `
		UPDATE orders SET status = ''PAID'', external_charge_id = $2 WHERE id = $1
	`, orderID, chargeID)
	return err
}', 'Splitting the workflow into two 1ms database state transitions around the external HTTP call reduces database connection hold time from ~2,000ms to ~2ms (a 1,000x increase in connection pool capacity).') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l5-migrations-transactions-prepared-ref-1', 'l5-migrations-transactions-prepared', 'PostgreSQL 17+ Documentation: Building Indexes Concurrently', 'https://www.postgresql.org/docs/current/sql-createindex.html#SQL-CREATEINDEX-CONCURRENTLY', 'PostgreSQL 17+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l5-migrations-transactions-prepared-ref-2', 'l5-migrations-transactions-prepared', 'Go Official Guide: Executing Transactions (database/sql)', 'https://go.dev/doc/database/execute-transactions', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l5-migrations-transactions-prepared', 'l5-migrations-transactions-prepared', 'Verify Safe Zero-Downtime PostgreSQL DDL Migration Guards', 'Implement IsSafeProductionDDL(sqlStmt string) bool that returns false if sqlStmt contains CREATE INDEX without CONCURRENTLY or ALTER TABLE without lock_timeout.', 'package migrator

import "strings"

func IsSafeProductionDDL(sqlStmt string) bool {
	upper := strings.ToUpper(sqlStmt)
	// STEP: If upper contains "CREATE INDEX" and not "CONCURRENTLY", return false
	// STEP: If upper contains "ALTER TABLE" and not "LOCK_TIMEOUT", return false
	return true
}', 'Invarian: Is Safe Production D D L', 'package migrator

import "strings"

func IsSafeProductionDDL(sqlStmt string) bool {
	upper := strings.ToUpper(sqlStmt)
	if strings.Contains(upper, "CREATE INDEX") && !strings.Contains(upper, "CONCURRENTLY") {
		return false
	}
	if strings.Contains(upper, "ALTER TABLE") && !strings.Contains(upper, "LOCK_TIMEOUT") {
		return false
	}
	return true
}', 'Automated lint rules on `migrations/*.sql` in CI catch table-locking DDL statements before they ever reach production.', 'Explain why PgBouncer in `transaction` pooling mode requires `default_query_exec_mode=simple_protocol` or PgBouncer 1.21+ `max_prepared_statements` support when using `pgx/v5`.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l5-migrations-transactions-prepared-tc-1', 'ex-l5-migrations-transactions-prepared', 1, 'IsSafeProductionDDL(''CREATE INDEX idx_a ON users(email);'') == false', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l5-migrations-transactions-prepared-tc-2', 'ex-l5-migrations-transactions-prepared', 2, 'IsSafeProductionDDL(''CREATE INDEX CONCURRENTLY idx_a ON users(email);'') == true', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l6-app-security', 7, 15, 'mod-l6-app-security', 'Module 6.A — Cryptography, AuthN/AuthZ & OWASP Defenses', 'Cryptographic password hashing with Argon2id, stateless JWT + Refresh Token rotation vs stateful sessions, RBAC, and defending against SQL Injection, SSRF, XSS, CSRF, and OWASP API Security Top 10 (2023).') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l6-security-auth-owasp', 'mod-l6-app-security', 7, 2, '6.1', 'l6-security-auth-owasp', '6.1 Argon2id, JWT vs Sessions, OAuth2/OIDC, RBAC, SQLi/SSRF/XSS/CSRF & OWASP API Top 10', 'Cryptographic password hashing with Argon2id, stateless JWT + Refresh Token rotation vs stateful sessions, RBAC, and defending against SQL Injection, SSRF, XSS, CSRF, and OWASP API Security Top 10 (2023).', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l6-security-auth-owasp-sec-main', 'l6-security-auth-owasp', 'core', '6.1 Argon2id, JWT vs Sessions, OAuth2/OIDC, RBAC, SQLi/SSRF/XSS/CSRF & OWASP API Top 10', '{"beginner": "Never store plain-text passwords! Hash them with Argon2id or bcrypt so even if your database leaks, attackers only see slow, salted hashes. Never glue user input directly into a SQL string (`\"SELECT * FROM users WHERE name = ''\" + input + \"''\"`)\u2014always use placeholders (`$1`) so the database treats user input strictly as data, never as executable SQL commands.", "intermediate": "Every OWASP API Security Top 10 (2023) risk maps to concrete Go defenses: API1 (BOLA) -> scope every query by `WHERE id = $1 AND tenant_id = $2`; API2 (Broken Auth) -> pin JWT signing algorithms and enforce constant-time comparison; API3 (Broken Object Property Level Auth / Mass Assignment) -> use dedicated request DTO structs rather than binding JSON directly into database model structs containing `IsAdmin bool`; API7 (SSRF) -> block loopback, link-local (`169.254.0.0/16`), and private RFC 1918 IPs.", "advanced": "Why does URL-string validation fail against SSRF? Because of DNS Rebinding (TOCTOU): when your validator resolves `evil.example.com`, the attacker''s DNS server returns `93.184.216.34` (public IP) with `TTL=0`. Milliseconds later, when `http.Client.Do(req)` dials `evil.example.com`, the DNS server returns `127.0.0.1` or `169.254.169.254`. The only bulletproof defense in Go is attaching a `Control` callback to `net.Dialer` inside `http.Transport.DialContext`, which inspects the actual resolved `syscall.RawConn` address (`netip.Addr`) immediately before `connect()`."}', 'Short-Lived Access JWT + Stateful Refresh Token Rotation Flow:
[Client] ── 1. POST /auth/login (Email + Password verified via Argon2id constant-time) ──► [Go Auth Service]
         ◄─ 2. Returns: Access JWT (5 min TTL, EdDSA/ES256) + HttpOnly Refresh Token (7d) ─┘
[Client] ── 3. API Request with Authorization: Bearer <Access JWT> (Verified statelessly) ─► [Go Resource API]
[Client] ── 4. POST /auth/refresh (Rotates Refresh Token Family in DB; revokes family on reuse!)', 'package webhook

import (
	"encoding/json"
	"net/http"
)

type UserModel struct {
	ID      string `json:"id"`
	Email   string `json:"email"`
	IsAdmin bool   `json:"is_admin"` // BUG 1: Exposed to client JSON Mass Assignment (OWASP API3)!
}

// BUG 2: Vulnerable to SSRF (OWASP API7:2023)!
// Attacker passes url="http://169.254.169.254/latest/meta-data/" or "http://127.0.0.1:6379/"
func PreviewWebhook(w http.ResponseWriter, r *http.Request) {
	targetURL := r.URL.Query().Get("url")
	resp, err := http.Get(targetURL)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	defer resp.Body.Close()
	_ = json.NewEncoder(w).Encode(map[string]int{"status": resp.StatusCode})
}', 'package webhook

import (
	"errors"
	"net"
	"net/netip"
	"syscall"
)

// Dedicated input DTO: IsAdmin does not exist here, preventing Mass Assignment
type UpdateProfileInput struct {
	Email       string `json:"email"`
	DisplayName string `json:"display_name"`
}

var ErrForbiddenDestination = errors.New("destination IP is private, loopback, or link-local (SSRF blocked)")

func IsSafePublicIP(ipStr string) bool {
	addr, err := netip.ParseAddr(ipStr)
	if err != nil {
		return false
	}
	if addr.IsLoopback() || addr.IsPrivate() || addr.IsLinkLocalUnicast() ||
		addr.IsLinkLocalMulticast() || addr.IsMulticast() || addr.IsUnspecified() {
		return false
	}
	return true
}

// Attached to net.Dialer.Control to block DNS-rebinding SSRF at socket connect time
func SafeDialControl(network, address string, c syscall.RawConn) error {
	host, _, err := net.SplitHostPort(address)
	if err != nil {
		return err
	}
	if !IsSafePublicIP(host) {
		return ErrForbiddenDestination
	}
	return nil
}', '`netip.ParseAddr` checks loopback (`127.0.0.1`, `::1`), RFC 1918 private ranges (`10/8`, `172.16/12`, `192.168/16`), and cloud metadata link-local addresses (`169.254.169.254`). Running this inside `net.Dialer.Control` neutralizes DNS rebinding.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l6-security-auth-owasp-ref-1', 'l6-security-auth-owasp', 'OWASP Top 10 API Security Risks – 2023', 'https://api-security.owasp.org/editions/2023/en/0x11-t10/', '2023 Edition', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l6-security-auth-owasp-ref-2', 'l6-security-auth-owasp', 'Go Standard Library: crypto/subtle', 'https://pkg.go.dev/crypto/subtle', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l6-security-auth-owasp-ref-3', 'l6-security-auth-owasp', 'Go Standard Library: net/netip', 'https://pkg.go.dev/net/netip', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l6-security-auth-owasp', 'l6-security-auth-owasp', 'Implement an SSRF-Safe IP Validator & Constant-Time API Key Verifier', 'Complete ValidateWebhookIP(ip string) error and VerifyAPIKey(provided, expected string) bool using net/netip and crypto/subtle.ConstantTimeCompare.', 'package secguard

import (
	"crypto/subtle"
	"errors"
	"net/netip"
)

func ValidateWebhookIP(ip string) error {
	// STEP: Parse ip with netip.ParseAddr and reject loopback, private, link-local, or unspecified IPs
	return nil
}

func VerifyAPIKey(provided, expected string) bool {
	// STEP: Reject empty keys and compare in constant time using subtle.ConstantTimeCompare
	return false
}', 'Invarian: Blocks Cloud Metadata I P 169 254 169 254
Invarian: Blocks Loopback And R F C1918
Invarian: Allows Public I P
Invarian: Constant Time A P I Key', 'package secguard

import (
	"crypto/subtle"
	"errors"
	"net/netip"
)

func ValidateWebhookIP(ip string) error {
	addr, err := netip.ParseAddr(ip)
	if err != nil {
		return errors.New("invalid IP address")
	}
	addr = addr.Unmap()
	if addr.IsLoopback() || addr.IsPrivate() || addr.IsLinkLocalUnicast() ||
		addr.IsLinkLocalMulticast() || addr.IsMulticast() || addr.IsUnspecified() {
		return errors.New("blocked internal or link-local IP address")
	}
	return nil
}

func VerifyAPIKey(provided, expected string) bool {
	if provided == "" || expected == "" {
		return false
	}
	return subtle.ConstantTimeCompare([]byte(provided), []byte(expected)) == 1
}', '`netip.Addr` performs zero-allocation IP classification, and `subtle.ConstantTimeCompare` prevents byte-by-byte timing side-channel attacks on secret tokens.', 'Add JWT header algorithm verification that explicitly rejects `alg: none` and `alg: HS256` when verifying an `EdDSA` public key.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l6-security-auth-owasp-tc-1', 'ex-l6-security-auth-owasp', 1, 'ValidateWebhookIP(''169.254.169.254'') != nil', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l6-security-auth-owasp-tc-2', 'ex-l6-security-auth-owasp', 2, 'ValidateWebhookIP(''10.0.0.15'') != nil', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l6-security-auth-owasp-tc-3', 'ex-l6-security-auth-owasp', 3, 'ValidateWebhookIP(''93.184.216.34'') == nil', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l6-security-auth-owasp-tc-4', 'ex-l6-security-auth-owasp', 4, 'VerifyAPIKey(''sk_live_abc'', ''sk_live_abc'') == true', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l6-identity-access', 7, 16, 'mod-l6-identity-access', 'Module 6.B — OAuth 2.0 (PKCE), OpenID Connect, RBAC/ABAC & Secrets Management', 'Implementing OAuth 2.0 Authorization Code Flow with PKCE, verifying OIDC ID Tokens via rotating JWKS public keys, designing Role-Based & Attribute-Based Access Control, and zero-downtime secret rotation.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l6-oauth2-oidc-rbac-abac', 'mod-l6-identity-access', 7, 3, '6.2', 'l6-oauth2-oidc-rbac-abac', '6.2 OAuth 2.0 with PKCE, OpenID Connect (JWKS), RBAC vs ABAC & Secrets Rotation', 'Implementing OAuth 2.0 Authorization Code Flow with PKCE, verifying OIDC ID Tokens via rotating JWKS public keys, designing Role-Based & Attribute-Based Access Control, and zero-downtime secret rotation.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l6-oauth2-oidc-rbac-abac-sec-main', 'l6-oauth2-oidc-rbac-abac', 'core', '6.2 OAuth 2.0 with PKCE, OpenID Connect (JWKS), RBAC vs ABAC & Secrets Rotation', '{"beginner": "OAuth 2.0 lets users log in via a trusted provider without giving your app their password, and OpenID Connect (OIDC) gives your Go backend a signed ID card (ID Token). RBAC (Role-Based Access Control) groups permissions into roles like `viewer`, `editor`, and `billing_admin` so you check permissions (`HasPermission(role, \"invoice:delete\")`) instead of scattering `if user.Role == \"admin\"` everywhere.", "intermediate": "When verifying JWTs or webhook HMAC signatures during a secret rotation, your Go server must accept **both** the `current` key and the `previous` key during a transition window (e.g., 24 hours). Sign all new tokens with the `current` key (`kid: \"key-2026-11\"`), while allowing verification to look up `kid` in a map containing both `key-2026-11` and `key-2026-10`.", "advanced": "Critical OIDC Security Check: Signature verification alone is NEVER sufficient! If two microservices or two client apps share an OAuth2/OIDC issuer, an attacker can take a validly signed JWT intended for `aud: \"analytics-viewer\"` and send it to `aud: \"payments-service\"`. Always assert exact `iss` match, `aud` membership, `exp > now - skew`, and `alg` allowlist."}', 'OAuth 2.0 Authorization Code + PKCE & OIDC JWKS Verification Flow:
[Client] ── 1. code_challenge = BASE64URL(SHA256(code_verifier)) ──► [Identity Provider (IdP)]
[Client] ── 2. Exchanges code + plaintext code_verifier ──────────► [Go Backend / Token Endpoint]
[Go API] ── 3. Fetches & Caches IdP /.well-known/jwks.json (Key ID "kid")
         └──► Verifies RS256/EdDSA Signature, iss, aud, exp & Tenant RBAC Permissions', 'package auth

// BUG 1: Single static secret means rotating the secret immediately logs out 100% of active users!
const SigningSecret = "hardcoded-prod-secret-do-not-do-this"

// BUG 2: Verifies signature only, ignoring iss (Issuer) and aud (Audience)!
func VerifyClaimsUnsafe(signatureValid bool, expUnix, nowUnix int64) bool {
	return signatureValid && expUnix > nowUnix
}', 'package auth

import "errors"

type TokenClaims struct {
	Issuer   string
	Audience string
	Subject  string
	Expires  int64
}

func VerifyOIDCClaims(c TokenClaims, expectedIss, expectedAud string, nowUnix int64) error {
	if c.Issuer != expectedIss {
		return errors.New("invalid token issuer (iss)")
	}
	if c.Audience != expectedAud {
		return errors.New("invalid token audience (aud)")
	}
	if nowUnix >= c.Expires {
		return errors.New("token expired (exp)")
	}
	if c.Subject == "" {
		return errors.New("missing subject (sub)")
	}
	return nil
}', 'Validating `Issuer`, `Audience`, `Expires`, and `Subject` deterministically after cryptographic signature verification ensures tokens cannot be replayed across unintended services.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l6-oauth2-oidc-rbac-abac-ref-1', 'l6-oauth2-oidc-rbac-abac', 'OWASP API2:2023 Broken Authentication & API5:2023 Broken Function Level Authorization', 'https://api-security.owasp.org/editions/2023/en/0x11-t10/', '2023 Edition', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l6-oauth2-oidc-rbac-abac-ref-2', 'l6-oauth2-oidc-rbac-abac', 'RFC 7636: Proof Key for Code Exchange (PKCE)', 'https://datatracker.ietf.org/doc/html/rfc7636', 'RFC 7636', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l6-oauth2-oidc-rbac-abac', 'l6-oauth2-oidc-rbac-abac', 'Implement Multi-Key Rotation Lookup & RBAC Permission Evaluation', 'Complete HasRBACPermission(role string, requiredPerm string, roleMatrix map[string][]string) bool so that it returns true only when requiredPerm is present in roleMatrix[role].', 'package rbac

func HasRBACPermission(role string, requiredPerm string, roleMatrix map[string][]string) bool {
	// STEP: Look up permissions slice for role in roleMatrix
	// STEP: Return true if requiredPerm is in the slice, false otherwise
	return false
}', 'Invarian: Has R B A C Permission', 'package rbac

func HasRBACPermission(role string, requiredPerm string, roleMatrix map[string][]string) bool {
	if role == "" || requiredPerm == "" || roleMatrix == nil {
		return false
	}
	for _, p := range roleMatrix[role] {
		if p == requiredPerm {
			return true
		}
	}
	return false
}', 'Failing closed on empty roles or nil maps guarantees least-privilege enforcement.', 'Add Key Ring lookup `GetVerificationKey(kid string, activeKeys map[string][]byte) ([]byte, error)` that supports zero-downtime key rotation.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l6-oauth2-oidc-rbac-abac-tc-1', 'ex-l6-oauth2-oidc-rbac-abac', 1, 'HasRBACPermission(''editor'', ''articles:write'', matrix) == true', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l6-oauth2-oidc-rbac-abac-tc-2', 'ex-l6-oauth2-oidc-rbac-abac', 2, 'HasRBACPermission(''viewer'', ''articles:delete'', matrix) == false', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l7-verification', 8, 17, 'mod-l7-verification', 'Module 7.A — Table-Driven Testing, Integration & Fuzzing', 'Writing idiomatic table-driven subtests (t.Run & t.Parallel), testing HTTP handlers with net/http/httptest, real Postgres integration tests with Testcontainers, native Go Fuzzing (go test -fuzz), and memory benchmarks.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l7-testing-fuzzing-benchmarks', 'mod-l7-verification', 8, 2, '7.1', 'l7-testing-fuzzing-benchmarks', '7.1 Table-Driven Tests, httptest, Testcontainers, Fuzzing & Benchmarking', 'Writing idiomatic table-driven subtests (t.Run & t.Parallel), testing HTTP handlers with net/http/httptest, real Postgres integration tests with Testcontainers, native Go Fuzzing (go test -fuzz), and memory benchmarks.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l7-testing-fuzzing-benchmarks-sec-main', 'l7-testing-fuzzing-benchmarks', 'core', '7.1 Table-Driven Tests, httptest, Testcontainers, Fuzzing & Benchmarking', '{"beginner": "Instead of writing 10 separate test functions that copy-paste the same setup code, Go engineers put test cases into a slice of structs (a ''table'') and loop over them with `t.Run(tc.name, ...)`. That way, adding a new edge case is just adding one line to the slice!", "intermediate": "Use `httptest.NewRequest` and `httptest.NewRecorder` to test `http.Handler` functions in microseconds without binding a real network port, or `httptest.NewServer` when testing a full HTTP client-server roundtrip. For parsers and validators, add a `Fuzz...(f *testing.F)` function so Go''s coverage-guided fuzzer automatically feeds malformed inputs to verify your code never panics.", "advanced": "Understand the limits of mocks vs fakes vs real dependencies: an in-memory Fake implementing a narrow consumer interface is great for unit-testing domain orchestration, but repository layers MUST be tested against the real database engine (e.g., PostgreSQL via Testcontainers) to validate migrations, indexes, `ON CONFLICT` clauses, and transaction isolation."}', 'Testing Trophy for Production Go Backends:
   ┌───────────────────────────────────────────┐
   │ E2E Smoke Tests (Critical User Journeys)  │  (5-10% — Full HTTP + Auth + DB)
   ├───────────────────────────────────────────┤
   │ Integration Tests (httptest + Real DB     │  (50% — Testcontainers Postgres / SQLite WAL)
   │                    via Testcontainers)    │
   ├───────────────────────────────────────────┤
   │ Table-Driven Unit & Property Fuzz Tests   │  (40% — Pure Domain Logic, Parsers, Edge Cases)
   └───────────────────────────────────────────┘', 'package slug

import (
	"strings"
	"testing"
)

// BUG 1: Panics with index out of range when input is empty or all spaces!
func NormalizeSlug(s string) string {
	trimmed := strings.TrimSpace(s)
	return strings.ToLower(trimmed[:1]) + trimmed[1:]
}

// BUG 2: Single happy-path test misses empty/whitespace/unicode inputs
func TestNormalizeSlug(t *testing.T) {
	if NormalizeSlug("GoBackend") != "goBackend" {
		t.Fail()
	}
}', 'package slug

import (
	"strings"
	"testing"
	"unicode"
	"unicode/utf8"
)

func NormalizeSlug(s string) string {
	trimmed := strings.TrimSpace(s)
	if trimmed == "" {
		return ""
	}
	r, size := utf8.DecodeRuneInString(trimmed)
	if r == utf8.RuneError {
		return ""
	}
	return string(unicode.ToLower(r)) + trimmed[size:]
}

func TestNormalizeSlug(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name string
		in   string
		want string
	}{
		{name: "ascii pascal case", in: "GoBackend", want: "goBackend"},
		{name: "empty string", in: "", want: ""},
		{name: "whitespace only", in: "   \t\n ", want: ""},
		{name: "single character", in: "A", want: "a"},
		{name: "multi-byte unicode", in: "ÜberService", want: "überService"},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			if got := NormalizeSlug(tc.in); got != tc.want {
				t.Errorf("NormalizeSlug(%q) = %q, want %q", tc.in, got, tc.want)
			}
		})
	}
}

func FuzzNormalizeSlug(f *testing.F) {
	f.Add("GoBackend")
	f.Add("")
	f.Add("   ")
	f.Add("Über")
	f.Fuzz(func(t *testing.T, input string) {
		_ = NormalizeSlug(input) // Must never panic for any arbitrary byte/string input
	})
}', 'Using `utf8.DecodeRuneInString` prevents slicing a multi-byte UTF-8 character in half (since `trimmed[:1]` slices bytes, not runes!), and `FuzzNormalizeSlug` proves panic-freedom across arbitrary byte sequences.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l7-testing-fuzzing-benchmarks-ref-1', 'l7-testing-fuzzing-benchmarks', 'Go Official Tutorial: Getting started with Fuzzing', 'https://go.dev/doc/tutorial/fuzz', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l7-testing-fuzzing-benchmarks-ref-2', 'l7-testing-fuzzing-benchmarks', 'Go Standard Library: testing & subtests', 'https://pkg.go.dev/testing', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l7-testing-fuzzing-benchmarks-ref-3', 'l7-testing-fuzzing-benchmarks', 'Go Standard Library: net/http/httptest', 'https://pkg.go.dev/net/http/httptest', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l7-testing-fuzzing-benchmarks', 'l7-testing-fuzzing-benchmarks', 'Fix a Byte-Slicing UTF-8 Bug Discovered by Go Fuzzing', 'Implement SafeTruncateRunes(s string, maxRunes int) string so that it truncates by Unicode code points (runes) rather than raw bytes, never panics on negative maxRunes, and never corrupts multi-byte UTF-8 strings.', 'package textutil

func SafeTruncateRunes(s string, maxRunes int) string {
	// STEP: If maxRunes <= 0, return ""
	// STEP: Convert or iterate runes safely so multi-byte UTF-8 characters are never split mid-byte
	return s
}', 'Invarian: Safe Truncate Runes  U T F8
PASS: FuzzSafeTruncateRunes (10,000 inputs tested, 0 panics, valid UTF-8 preserved)', 'package textutil

func SafeTruncateRunes(s string, maxRunes int) string {
	if maxRunes <= 0 || s == "" {
		return ""
	}
	count := 0
	for byteIdx := range s {
		if count == maxRunes {
			return s[:byteIdx]
		}
		count++
	}
	return s
}', 'Iterating `for byteIdx := range s` steps rune-by-rune with zero heap allocation and slices `s[:byteIdx]` at an exact rune boundary.', 'Benchmark the zero-allocation `range s` implementation against `string([]rune(s)[:maxRunes])` using `b.ReportAllocs()`.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l7-testing-fuzzing-benchmarks-tc-1', 'ex-l7-testing-fuzzing-benchmarks', 1, 'SafeTruncateRunes(''Go🚀Backend'', 3) == ''Go🚀''', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l7-testing-fuzzing-benchmarks-tc-2', 'ex-l7-testing-fuzzing-benchmarks', 2, 'SafeTruncateRunes(''hello'', -1) == ''''', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l7-testing-fuzzing-benchmarks-tc-3', 'ex-l7-testing-fuzzing-benchmarks', 3, 'utf8.ValidString(SafeTruncateRunes(anyValidUTF8, n)) == true', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l7-integration-ci', 8, 18, 'mod-l7-integration-ci', 'Module 7.B — Database Integration Tests, Test Doubles (Fakes vs Mocks) & CI Quality Gates', 'Why in-memory Fakes and real database integration tests (Testcontainers / SQLite WAL) beat brittle mock assertions, how to isolate parallel DB subtests via transactions or schemas, and designing Go CI pipelines.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l7-integration-testcontainers-ci', 'mod-l7-integration-ci', 8, 3, '7.2', 'l7-integration-testcontainers-ci', '7.2 Fakes vs Mocks, Real Database Integration Testing & Reproducible CI Pipelines', 'Why in-memory Fakes and real database integration tests (Testcontainers / SQLite WAL) beat brittle mock assertions, how to isolate parallel DB subtests via transactions or schemas, and designing Go CI pipelines.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l7-integration-testcontainers-ci-sec-main', 'l7-integration-testcontainers-ci', 'core', '7.2 Fakes vs Mocks, Real Database Integration Testing & Reproducible CI Pipelines', '{"beginner": "A **Mock** checks ''Did function A call function B with exact argument X?'', while a **Fake** is a simple working in-memory version (like a `FakeUserStore` backed by a Go `map`). In Go, writing a 15-line Fake struct is cleaner, faster, and doesn''t break every time you refactor internal helper calls!", "intermediate": "Use `t.Cleanup(func() { ... })` instead of manual cleanup at the end of a test function: `t.Cleanup` runs automatically when the test and all its child subtests finish, even if `t.Fatalf` aborted the test halfway through.", "advanced": "How do you run 50 PostgreSQL repository tests in parallel (`t.Parallel()`) in under 1 second? Boot one PostgreSQL container in `TestMain`, apply `migrations/postgres/*.up.sql` once, and in each test generate a unique `tenant_id := uuid.NewString()` (or clone from a template database `CREATE DATABASE test_xyz TEMPLATE migrated_template`). Each test operates on disjoint rows with zero lock contention."}', 'Test Double Spectrum in Go Engineering:
┌──────────────────────┬───────────────────────────────────────────────────────────────────┐
│ Technique            │ Engineering Trade-Off & Recommended Usage                         │
├──────────────────────┼───────────────────────────────────────────────────────────────────┤
│ Real DB Container    │ Gold standard for SQL repositories: verifies DDL, constraints,    │
│ (Testcontainers/SQL) │ indexes, and MVCC locking against real PostgreSQL/SQLite.         │
├──────────────────────┼───────────────────────────────────────────────────────────────────┤
│ In-Memory Fake       │ Ideal for domain service unit tests: implements a narrow 2-method │
│ (Stateful Struct)    │ consumer interface using a map + sync.Mutex. Fast & refactoring-safe│
├──────────────────────┼───────────────────────────────────────────────────────────────────┤
│ Call-Order Mock      │ Brittle if overused: couples tests to internal implementation     │
│ (gomock / testify)   │ call sequences rather than observable state/output behavior.      │
└──────────────────────┴───────────────────────────────────────────────────────────────────┘', 'package repo_test

import "testing"

var sharedSlice []string // BUG: Mutated concurrently by t.Parallel() subtests!

func TestParallelAppend(t *testing.T) {
	for _, item := range []string{"a", "b", "c"} {
		t.Run(item, func(t *testing.T) {
			t.Parallel()
			sharedSlice = append(sharedSlice, item) // DATA RACE!
		})
	}
}', 'package repo_test

import (
	"sync"
	"testing"
)

type FakeStore struct {
	mu    sync.RWMutex
	items map[string]string
}

func NewFakeStore(t *testing.T) *FakeStore {
	t.Helper()
	s := &FakeStore{items: make(map[string]string)}
	t.Cleanup(func() {
		s.mu.Lock()
		clear(s.items)
		s.mu.Unlock()
	})
	return s
}', 'Instantiating an isolated `FakeStore` per subtest (or protecting shared state with `sync.RWMutex`) and registering `t.Cleanup` makes `t.Parallel()` 100% race-free and deterministic.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l7-integration-testcontainers-ci-ref-1', 'l7-integration-testcontainers-ci', 'Go Standard Library: testing.T.Cleanup & Parallel', 'https://pkg.go.dev/testing#T.Cleanup', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l7-integration-testcontainers-ci-ref-2', 'l7-integration-testcontainers-ci', 'Go Data Race Detector Manual', 'https://go.dev/doc/articles/race_detector', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l7-integration-testcontainers-ci', 'l7-integration-testcontainers-ci', 'Build a Thread-Safe In-Memory Fake Repository for Unit Testing', 'Complete PutAndGetFake(items map[string]int, key string, val int) (int, bool) that stores val at key (initializing behavior safely if items is non-nil) and retrieves it.', 'package testfake

func PutAndGetFake(items map[string]int, key string, val int) (int, bool) {
	// STEP: If items == nil or key == "", return 0, false
	// STEP: Store items[key] = val and return val, true
	return 0, false
}', 'Invarian: Put And Get Fake', 'package testfake

func PutAndGetFake(items map[string]int, key string, val int) (int, bool) {
	if items == nil || key == "" {
		return 0, false
	}
	items[key] = val
	v, ok := items[key]
	return v, ok
}', 'Guarding against `nil` map panics (`assignment to entry in nil map`) and empty keys keeps test fakes predictable.', 'Wrap the map in a struct with `sync.RWMutex` so concurrent goroutines inside a single test can call `Put` and `Get` under `go test -race`.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l7-integration-testcontainers-ci-tc-1', 'ex-l7-integration-testcontainers-ci', 1, 'PutAndGetFake(map[string]int{}, ''user_1'', 42) == (42, true)', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l7-integration-testcontainers-ci-tc-2', 'ex-l7-integration-testcontainers-ci', 2, 'PutAndGetFake(nil, ''user_1'', 42) == (0, false)', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l8-software-arch', 9, 19, 'mod-l8-software-arch', 'Module 8.A — Clean, Hexagonal, DDD & Modular Monoliths', 'Side-by-side comparison of the same Order Fulfillment service written in 3 architectures: Pragmatic Layered, Hexagonal (Ports & Adapters), and Event-Driven CQRS—understanding when abstraction helps and when it hurts.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l8-clean-hexagonal-ddd', 'mod-l8-software-arch', 9, 2, '8.1', 'l8-clean-hexagonal-ddd', '8.1 Layered vs Clean vs Hexagonal (Ports & Adapters), DDD, CQRS & Modular Monolith', 'Side-by-side comparison of the same Order Fulfillment service written in 3 architectures: Pragmatic Layered, Hexagonal (Ports & Adapters), and Event-Driven CQRS—understanding when abstraction helps and when it hurts.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l8-clean-hexagonal-ddd-sec-main', 'l8-clean-hexagonal-ddd', 'core', '8.1 Layered vs Clean vs Hexagonal (Ports & Adapters), DDD, CQRS & Modular Monolith', '{"beginner": "Good architecture means keeping your business rules (like ''an order cannot be refunded twice'') separate from how requests arrive (HTTP or CLI) and how data is saved (PostgreSQL or SQLite). In Go, you wire things together in `main.go` by passing dependencies into `New...` functions (Dependency Injection).", "intermediate": "Compare three ways to structure a feature: 1) **Pragmatic Layered** (`internal/order/handler.go` -> `service.go` -> `repo.go`) is fast and direct for standard APIs. 2) **Hexagonal (Ports & Adapters)** puts domain aggregates and repository interfaces at the center so neither HTTP nor SQL packages are imported by the domain. 3) **CQRS** separates the Write command model (normalized ACID tables enforcing invariants) from the Read query model (denormalized views/projections optimized for fast UI queries).", "advanced": "Avoid ''interface pollution'' in Go: do not copy C#/Java patterns where every `FooService` has an `IFooService` in the same package. Instead, define narrow interfaces in the package that *calls* the dependency. When building a Modular Monolith, place each bounded context in `internal/<module>` and disallow cross-module table joins in SQL\u2014modules interact only via exported service methods or domain events."}', 'Hexagonal (Ports & Adapters) Dependency Direction in Go:
┌───────────────────────────┐          ┌───────────────────────────────┐          ┌───────────────────────────┐
│ Primary / Driving Adapters│          │      Application & Domain     │          │ Secondary / Driven        │
│  • net/http Handlers      │ ───────► │  • Domain Entities & Rules    │ ◄─────── │ Adapters                  │
│  • gRPC Server            │  Calls   │  • UseCase Service            │Implements│  • Postgres Repo (pgx)    │
│  • CLI / Kafka Consumer   │  Inbound │  • Outbound Port Interfaces   │ Outbound │  • Stripe Payment Client  │
└───────────────────────────┘  Method  │    (defined HERE in domain!)  │   Port   │  • Redis Cache Adapter    │
                                       └───────────────────────────────┘          └───────────────────────────┘
                     (All source-code dependencies point INWARD toward Domain!)', 'package checkout

import (
	"database/sql"
	"net/http"
)

// BUG: HTTP transport, SQL queries, and business discount rules are inextricably fused.
// Impossible to call this business logic from a gRPC endpoint or background worker!
func PlaceOrderHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var tier string
		_ = db.QueryRow("SELECT tier FROM users WHERE id = $1", r.Header.Get("X-User")).Scan(&tier)
		discount := 0.0
		if tier == "gold" {
			discount = 0.15
		}
		_, _ = db.Exec("INSERT INTO orders (user_id, discount) VALUES ($1, $2)", r.Header.Get("X-User"), discount)
		w.WriteHeader(201)
	}
}', 'package checkout

import (
	"context"
	"errors"
)

type CustomerTier string

const (
	TierStandard CustomerTier = "standard"
	TierGold     CustomerTier = "gold"
)

// Pure domain calculation: 100% deterministic, testable in 0.001ms with zero mocks
func CalculateDiscountCents(subtotalCents int64, tier CustomerTier) (int64, error) {
	if subtotalCents < 0 {
		return 0, errors.New("subtotal cannot be negative")
	}
	if tier == TierGold {
		return (subtotalCents * 15) / 100, nil
	}
	return 0, nil
}

// Consumer-defined outbound port interface
type OrderStore interface {
	SaveOrder(ctx context.Context, userID string, netTotalCents int64) error
}

type Service struct {
	store OrderStore
}

func NewService(store OrderStore) *Service {
	return &Service{store: store}
}

func (s *Service) PlaceOrder(ctx context.Context, userID string, subtotalCents int64, tier CustomerTier) (int64, error) {
	disc, err := CalculateDiscountCents(subtotalCents, tier)
	if err != nil {
		return 0, err
	}
	netTotal := subtotalCents - disc
	if err := s.store.SaveOrder(ctx, userID, netTotal); err != nil {
		return 0, err
	}
	return netTotal, nil
}', 'Extracting `CalculateDiscountCents` as a pure function and defining the narrow `OrderStore` port interface in the `checkout` package makes domain rules trivial to unit test and reusable across HTTP, gRPC, and CLI entrypoints.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l8-clean-hexagonal-ddd-ref-1', 'l8-clean-hexagonal-ddd', 'Go Wiki: CodeReviewComments — Interfaces', 'https://go.dev/wiki/CodeReviewComments#interfaces', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l8-clean-hexagonal-ddd-ref-2', 'l8-clean-hexagonal-ddd', 'Effective Go: Embedding & Composition', 'https://go.dev/doc/effective_go#embedding', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l8-clean-hexagonal-ddd', 'l8-clean-hexagonal-ddd', 'Refactor a Coupled Service to Use Consumer-Defined Ports & Integer Money Math', 'Implement ComputeFinalInvoiceCents(subtotalCents int64, couponBasisPoints int64, taxBasisPoints int64) (int64, error) using exact integer basis-point math (100 bps = 1%, 10000 bps = 100%) instead of lossy float64 arithmetic.', 'package billing

import "errors"

func ComputeFinalInvoiceCents(subtotalCents, couponBasisPoints, taxBasisPoints int64) (int64, error) {
	// STEP: Reject negative inputs or couponBasisPoints > 10000
	// STEP: Compute discounted = subtotalCents - (subtotalCents * couponBasisPoints) / 10000
	// STEP: Compute final = discounted + (discounted * taxBasisPoints) / 10000
	return 0, nil
}', 'Invarian: Compute Final Invoice Cents  Exact Integer Math
Subtotal $100.00 (10000c), 15% coupon (1500 bps), 10% tax (1000 bps) -> 9350 cents ($93.50)', 'package billing

import "errors"

func ComputeFinalInvoiceCents(subtotalCents, couponBasisPoints, taxBasisPoints int64) (int64, error) {
	if subtotalCents < 0 || couponBasisPoints < 0 || couponBasisPoints > 10000 || taxBasisPoints < 0 {
		return 0, errors.New("invalid billing parameters")
	}
	discount := (subtotalCents * couponBasisPoints) / 10000
	discounted := subtotalCents - discount
	tax := (discounted * taxBasisPoints) / 10000
	return discounted + tax, nil
}', 'Representing currency in smallest integer units (cents) and percentages in basis points (1/100th of 1%) eliminates IEEE-754 floating-point rounding drift in financial domain models.', 'Implement banker''s rounding (round half to even) when dividing integer basis points.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l8-clean-hexagonal-ddd-tc-1', 'ex-l8-clean-hexagonal-ddd', 1, 'ComputeFinalInvoiceCents(10000, 1500, 1000) == 9350', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l8-clean-hexagonal-ddd-tc-2', 'ex-l8-clean-hexagonal-ddd', 2, 'ComputeFinalInvoiceCents(10000, 12000, 0) returns error', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l8-boundaries-cqrs', 9, 20, 'mod-l8-boundaries-cqrs', 'Module 8.B — Modular Monolith Boundaries, CQRS Read/Write Split & Domain Events', 'How to prevent a Modular Monolith from degenerating into a tangled monolith (forbidding cross-module SQL joins, communicating via narrow service interfaces), and when CQRS read projections pay off.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l8-modular-monolith-cqrs-boundaries', 'mod-l8-boundaries-cqrs', 9, 3, '8.2', 'l8-modular-monolith-cqrs-boundaries', '8.2 Enforcing Modular Monolith Boundaries, CQRS Read Models & Domain Modeling', 'How to prevent a Modular Monolith from degenerating into a tangled monolith (forbidding cross-module SQL joins, communicating via narrow service interfaces), and when CQRS read projections pay off.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l8-modular-monolith-cqrs-boundaries-sec-main', 'l8-modular-monolith-cqrs-boundaries', 'core', '8.2 Enforcing Modular Monolith Boundaries, CQRS Read Models & Domain Modeling', '{"beginner": "A **Modular Monolith** is one Go program divided into strict departments (modules like `orders`, `payments`, `users`). Even though they live in the same database, the `orders` module is only allowed to talk to `payments` by calling its Go functions\u2014never by reaching into `payments`''s database tables directly!", "intermediate": "**CQRS (Command Query Responsibility Segregation)** means using two different models for Writing vs Reading: your **Command (Write)** path uses strict normalized tables to enforce business rules, while your **Query (Read)** path uses a fast, pre-joined SQL view or projection tailored specifically for what the UI screen needs.", "advanced": "How do you enforce Modular Monolith table ownership so a developer can''t accidentally `JOIN` another module''s table? Create separate PostgreSQL schemas (`CREATE SCHEMA orders`, `CREATE SCHEMA billing`) or prefix tables (`orders_items`, `billing_invoices`) and run a 20-line AST/SQL test in CI that scans each `internal/modules/<name>` directory and fails if any SQL query references a table outside `<name>_*`!"}', 'Modular Monolith Boundary Enforcement (No Cross-Module Table Joins!):
┌────────────────────────────────────┐       ┌────────────────────────────────────┐
│ Module A: internal/modules/orders  │       │ Module B: internal/modules/billing │
│  • Calls billing.Service.Charge() ─┼──────►│  • Exposes billing.Service API     │
│  • Owns `orders` table             │       │  • Owns `invoices` & `ledger`      │
└─────────────────┬──────────────────┘       └─────────────────┬──────────────────┘
                  │  ❌ FORBIDDEN: SELECT * FROM orders JOIN invoices ...
                  ▼                                            ▼
          [Table: orders]                             [Table: invoices]', 'package shipping

// BUG: The shipping module reaches directly into billing_invoices and users_accounts tables!
// Any schema change in billing or users now breaks shipping!
const CoupledQuery = `
SELECT s.id, u.email, b.paid_amount_cents
FROM shipping_labels s
JOIN users_accounts u ON u.id = s.user_id
JOIN billing_invoices b ON b.order_id = s.order_id;
`', 'package shipping

import "context"

// Consumer port satisfied by the billing module''s exported service
type InvoiceVerifier interface {
	IsOrderPaid(ctx context.Context, orderID string) (bool, error)
}

const ScopedShippingQuery = `
SELECT id, order_id, recipient_address
FROM shipping_labels
WHERE order_id = $1;
`', '`shipping` queries only `shipping_labels` and verifies payment status through the `InvoiceVerifier` Go interface, keeping module storage 100% decoupled.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l8-modular-monolith-cqrs-boundaries-ref-1', 'l8-modular-monolith-cqrs-boundaries', 'Go Modules & Internal Directories Specification', 'https://go.dev/doc/go1.4#internalpackages', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l8-modular-monolith-cqrs-boundaries-ref-2', 'l8-modular-monolith-cqrs-boundaries', 'PostgreSQL 17+ Documentation: Schemas & Privileges', 'https://www.postgresql.org/docs/current/ddl-schemas.html', 'PostgreSQL 17+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l8-modular-monolith-cqrs-boundaries', 'l8-modular-monolith-cqrs-boundaries', 'Enforce Module Table Ownership in a SQL Linter Check', 'Implement ViolatesModuleTableBoundary(moduleName string, referencedTable string) bool that returns true if referencedTable does not start with moduleName + "_".', 'package archlint

import "strings"

func ViolatesModuleTableBoundary(moduleName string, referencedTable string) bool {
	// STEP: Return true if referencedTable does not have prefix moduleName + "_"
	return false
}', 'Invarian: Violates Module Table Boundary', 'package archlint

import "strings"

func ViolatesModuleTableBoundary(moduleName string, referencedTable string) bool {
	if moduleName == "" || referencedTable == "" {
		return true
	}
	return !strings.HasPrefix(referencedTable, moduleName+"_")
}', 'A simple table-prefix or schema-prefix assertion in unit tests enforces Modular Monolith database boundaries automatically on every commit.', 'Show how a PostgreSQL `MATERIALIZED VIEW` can serve a CQRS read model refreshed via `REFRESH MATERIALIZED VIEW CONCURRENTLY`.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l8-modular-monolith-cqrs-boundaries-tc-1', 'ex-l8-modular-monolith-cqrs-boundaries', 1, 'ViolatesModuleTableBoundary(''orders'', ''orders_items'') == false', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l8-modular-monolith-cqrs-boundaries-tc-2', 'ex-l8-modular-monolith-cqrs-boundaries', 2, 'ViolatesModuleTableBoundary(''orders'', ''billing_invoices'') == true', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l9-distributed-patterns', 10, 21, 'mod-l9-distributed-patterns', 'Module 9.A — Caching, Messaging, Outbox & Observability', 'Preventing cache stampedes with singleflight, choosing between Kafka, RabbitMQ, and NATS, solving dual-write bugs with the Transactional Outbox Pattern, Idempotency Keys, Circuit Breakers, and OpenTelemetry tracing.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l9-caching-queues-outbox-sagas', 'mod-l9-distributed-patterns', 10, 2, '9.1', 'l9-caching-queues-outbox-sagas', '9.1 Redis Caching (Singleflight), Kafka vs RabbitMQ vs NATS, Outbox Pattern, Sagas & OpenTelemetry', 'Preventing cache stampedes with singleflight, choosing between Kafka, RabbitMQ, and NATS, solving dual-write bugs with the Transactional Outbox Pattern, Idempotency Keys, Circuit Breakers, and OpenTelemetry tracing.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l9-caching-queues-outbox-sagas-sec-main', 'l9-caching-queues-outbox-sagas', 'core', '9.1 Redis Caching (Singleflight), Kafka vs RabbitMQ vs NATS, Outbox Pattern, Sagas & OpenTelemetry', '{"beginner": "What happens if your code saves an Order to PostgreSQL, and then the server loses power 1 millisecond before sending the ''OrderCreated'' message to Kafka? The order is saved, but the warehouse never ships it! The **Outbox Pattern** solves this by saving both the Order and the ''OrderCreated'' message into PostgreSQL in the exact same database transaction, and a background worker reliably sends it to Kafka until Kafka confirms receipt.", "intermediate": "Compare the three major message brokers in Go ecosystems: **RabbitMQ** is a smart broker (AMQP exchanges, routing keys, per-message acks/priorities\u2014great for background task queues); **Apache Kafka** is a distributed partitioned append-only log (retains events on disk for days/weeks, consumer groups read by offset\u2014great for event streaming and audit logs); **NATS / JetStream** is written in Go, ultra-lightweight, and excels at low-latency pub/sub and edge/microservice messaging.", "advanced": "To prevent Cache Stampedes in Go: 1) Wrap cache-miss DB fetches in `singleflight.Group.Do(key, fn)` so 1,000 concurrent requests on the same pod collapse into 1 DB query. 2) Add random TTL jitter (`baseTTL + rand(0, 10% of baseTTL)`) when writing batch keys so 10,000 pre-warmed keys don''t expire at the exact same second. 3) Cache negative results (''not found'' sentinel) with a short 30s TTL to stop Cache Penetration attacks querying nonexistent IDs."}', 'The Dual-Write Bug vs Transactional Outbox Pattern:
❌ BROKEN DUAL WRITE:
   1. tx.Commit() to Postgres succeeds  ──►  2. Process crashes BEFORE kafka.Publish()! (Event Lost Forever!)

✅ TRANSACTIONAL OUTBOX PATTERN:
   1. Single ACID Postgres Tx:
        ├── INSERT INTO orders (...)
        └── INSERT INTO outbox_events (id, topic, payload, published_at=NULL)
   2. Outbox Relay Worker (FOR UPDATE SKIP LOCKED) or Debezium CDC reads outbox_events
        └── Publishes to Kafka/RabbitMQ/NATS (At-Least-Once) + Consumer Deduplicates by event_id!', 'package order

import (
	"context"
	"database/sql"
	"time"
)

// BUG 1: Dual-Write! If broker.Publish fails or crashes, DB and Broker are permanently inconsistent.
func CreateOrderDualWrite(ctx context.Context, db *sql.DB, broker Publisher, id string) error {
	if _, err := db.ExecContext(ctx, "INSERT INTO orders (id) VALUES ($1)", id); err != nil {
		return err
	}
	return broker.Publish(ctx, "order.created", id)
}

// BUG 2: Fixed sleep without jitter causes synchronized thundering-herd retry storms!
func FixedBackoff(attempt int) time.Duration {
	return 2 * time.Second
}', 'package order

import (
	"context"
	"database/sql"
	"math"
	"math/rand/v2"
	"time"
)

// Atomic persistence of domain entity AND outbox event in a single ACID transaction
func CreateOrderWithOutbox(ctx context.Context, db *sql.DB, orderID, payloadJSON string) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	if _, err := tx.ExecContext(ctx, `INSERT INTO orders (id, status) VALUES ($1, ''PENDING'')`, orderID); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `
		INSERT INTO outbox_events (aggregate_id, topic, payload)
		VALUES ($1, ''order.created'', $2)
	`, orderID, payloadJSON); err != nil {
		return err
	}
	return tx.Commit()
}

// Full Jitter Exponential Backoff: sleep = rand(0, min(maxDelay, baseDelay * 2^attempt))
func FullJitterBackoff(attempt int, baseDelay, maxDelay time.Duration) time.Duration {
	if attempt < 0 {
		attempt = 0
	}
	mult := math.Pow(2, float64(attempt))
	ceil := time.Duration(float64(baseDelay) * mult)
	if ceil > maxDelay || ceil <= 0 {
		ceil = maxDelay
	}
	return time.Duration(rand.Int64N(int64(ceil) + 1))
}', 'Writing to `orders` and `outbox_events` in one transaction relies on PostgreSQL WAL atomicity—either both commit or neither commits. Full-jitter exponential backoff spreads client retries uniformly across time.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l9-caching-queues-outbox-sagas-ref-1', 'l9-caching-queues-outbox-sagas', 'Go x/sync/singleflight Package Documentation', 'https://pkg.go.dev/golang.org/x/sync/singleflight', 'v0.8+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l9-caching-queues-outbox-sagas-ref-2', 'l9-caching-queues-outbox-sagas', 'Redis Official Documentation: Caching & Eviction Policies', 'https://redis.io/docs/', 'Redis 7.4', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l9-caching-queues-outbox-sagas', 'l9-caching-queues-outbox-sagas', 'Implement an Idempotent Event Consumer Guard & Circuit Breaker State Transition', 'Complete ShouldTripBreaker(consecutiveFailures, threshold int, currentState string) string that transitions a Circuit Breaker from ''CLOSED'' or ''HALF_OPEN'' to ''OPEN'' when consecutiveFailures >= threshold.', 'package resilience

func ShouldTripBreaker(consecutiveFailures, threshold int, currentState string) string {
	// STEP: If threshold <= 0, default threshold to 5
	// STEP: If currentState == "HALF_OPEN" and consecutiveFailures >= 1, return "OPEN"
	// STEP: If consecutiveFailures >= threshold, return "OPEN"
	return currentState
}', 'Invarian: Circuit Breaker Trips At Threshold
Invarian: Half Open Trips On Single Failure', 'package resilience

func ShouldTripBreaker(consecutiveFailures, threshold int, currentState string) string {
	if threshold <= 0 {
		threshold = 5
	}
	if currentState == "HALF_OPEN" && consecutiveFailures >= 1 {
		return "OPEN"
	}
	if consecutiveFailures >= threshold {
		return "OPEN"
	}
	return currentState
}', 'A circuit breaker fails fast while `OPEN`, allows a single probe request after a cooldown window (`HALF_OPEN`), and immediately reverts to `OPEN` if that probe fails.', 'Write the PostgreSQL query `INSERT INTO processed_events (event_id) VALUES ($1) ON CONFLICT (event_id) DO NOTHING` to guarantee idempotent message processing.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l9-caching-queues-outbox-sagas-tc-1', 'ex-l9-caching-queues-outbox-sagas', 1, 'ShouldTripBreaker(5, 5, ''CLOSED'') == ''OPEN''', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l9-caching-queues-outbox-sagas-tc-2', 'ex-l9-caching-queues-outbox-sagas', 2, 'ShouldTripBreaker(1, 5, ''HALF_OPEN'') == ''OPEN''', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l9-caching-queues-outbox-sagas-tc-3', 'ex-l9-caching-queues-outbox-sagas', 3, 'ShouldTripBreaker(3, 5, ''CLOSED'') == ''CLOSED''', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l9-rpc-observability', 10, 22, 'mod-l9-rpc-observability', 'Module 9.B — gRPC & Protobuf, WebSockets/SSE & Distributed Tracing (OpenTelemetry)', 'Designing strict Protobuf v3 contracts with deadlines for internal gRPC services, choosing between full-duplex WebSockets and Server-Sent Events (SSE), and propagating W3C traceparent spans with OpenTelemetry and Prometheus.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l9-grpc-websockets-otel-tracing', 'mod-l9-rpc-observability', 10, 3, '9.2', 'l9-grpc-websockets-otel-tracing', '9.2 gRPC & Protobuf Contracts, WebSockets vs SSE & OpenTelemetry Distributed Tracing', 'Designing strict Protobuf v3 contracts with deadlines for internal gRPC services, choosing between full-duplex WebSockets and Server-Sent Events (SSE), and propagating W3C traceparent spans with OpenTelemetry and Prometheus.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l9-grpc-websockets-otel-tracing-sec-main', 'l9-grpc-websockets-otel-tracing', 'core', '9.2 gRPC & Protobuf Contracts, WebSockets vs SSE & OpenTelemetry Distributed Tracing', '{"beginner": "Need to push live updates from your Go server to a browser (like live stock prices or build logs)? You don''t always need complex WebSockets! **Server-Sent Events (SSE)** is a standard HTTP response (`Content-Type: text/event-stream`) where your Go server flushes lines of text whenever an event happens, and the browser''s `EventSource` reconnects automatically if Wi-Fi drops.", "intermediate": "For internal service-to-service calls, **gRPC** uses binary **Protocol Buffers (Protobuf)** instead of text JSON. Not only is it smaller and faster to serialize, but if Service A has 400ms left on its `context.WithTimeout` deadline, gRPC automatically sends that remaining 400ms budget over the network so Service B knows to abort if time runs out!", "advanced": "How do you maintain backward and forward wire compatibility in Protobuf? Never change the field number (`= 1`, `= 2`) of an existing field, and when removing a field, add `reserved 3; reserved \"legacy_status\";` to the `.proto` message definition. Otherwise, a future developer reusing field tag `= 3` for a new `string` field will cause older binaries still deployed during a rolling update to deserialize those bytes as the old type!"}', 'W3C Trace Context Propagation Across HTTP -> gRPC -> Postgres:
[API Gateway] (Creates TraceID=4bf92f..., SpanID=00f067...)
   │ HTTP Header: traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01
   ▼
[Order Service] (Extracts context.Context -> Creates Child Span "gRPC Inventory.Reserve")
   │ gRPC Metadata: traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-a2fb4a1d1a96d312-01
   ▼
[Inventory Service] (Creates Child Span "SQL UPDATE sku_stock" -> Exports to Tempo/Jaeger)', '// order.proto
message OrderEvent {
  string order_id = 1;
  // BUG 1: Developer deleted ''int64 legacy_code = 2;'' and reused tag 2 for a string!
  // Old consumers still running in prod will corrupt data reading wire tag 2!
  string customer_note = 2;
}

// client.go
// BUG 2: Calling gRPC with context.Background() has NO deadline!
resp, err := client.ReserveStock(context.Background(), req)', '// order.proto
message OrderEvent {
  reserved 2;
  reserved "legacy_code";
  string order_id = 1;
  string customer_note = 3; // Uses fresh tag 3
}

// client.go
ctx, cancel := context.WithTimeout(parentCtx, 800*time.Millisecond)
defer cancel()
resp, err := client.ReserveStock(ctx, req)', '`reserved 2;` makes the `protoc` compiler reject any attempt to reuse field number 2, and `context.WithTimeout` sends `grpc-timeout: 800m` on the wire so both client and server release resources on timeout.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l9-grpc-websockets-otel-tracing-ref-1', 'l9-grpc-websockets-otel-tracing', 'OpenTelemetry Go SDK Official Documentation', 'https://opentelemetry.io/docs/languages/go/', 'v1.31+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l9-grpc-websockets-otel-tracing-ref-2', 'l9-grpc-websockets-otel-tracing', 'W3C Trace Context Specification (traceparent)', 'https://www.w3.org/TR/trace-context/', 'W3C Recommendation', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l9-grpc-websockets-otel-tracing', 'l9-grpc-websockets-otel-tracing', 'Validate W3C traceparent Header Format for Distributed Tracing', 'Implement IsValidW3CTraceparent(header string) bool that checks whether header splits on ''-'' into 4 parts where version is ''00'', traceID is 32 hex chars (not all zeros), and spanID is 16 hex chars.', 'package tracing

import "strings"

func IsValidW3CTraceparent(header string) bool {
	parts := strings.Split(header, "-")
	// STEP: Verify len(parts) == 4, parts[0] == "00", len(parts[1]) == 32, len(parts[2]) == 16, len(parts[3]) == 2
	// STEP: Reject all-zero traceID ("00000000000000000000000000000000")
	return false
}', 'Invarian: Is Valid W3 C Traceparent', 'package tracing

import "strings"

func IsValidW3CTraceparent(header string) bool {
	parts := strings.Split(header, "-")
	if len(parts) != 4 {
		return false
	}
	if parts[0] != "00" || len(parts[1]) != 32 || len(parts[2]) != 16 || len(parts[3]) != 2 {
		return false
	}
	if parts[1] == "00000000000000000000000000000000" || parts[2] == "0000000000000000" {
		return false
	}
	return true
}', 'The W3C Trace Context specification mandates version `00`, a 16-byte (32 hex char) non-zero `trace-id`, an 8-byte (16 hex char) non-zero `parent-id`, and a 1-byte (2 hex char) `trace-flags` field.', 'Write an `http.HandlerFunc` for Server-Sent Events (SSE) that checks `flusher, ok := w.(http.Flusher)` and streams events until `<-r.Context().Done()`.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l9-grpc-websockets-otel-tracing-tc-1', 'ex-l9-grpc-websockets-otel-tracing', 1, 'IsValidW3CTraceparent(''00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01'') == true', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l9-grpc-websockets-otel-tracing-tc-2', 'ex-l9-grpc-websockets-otel-tracing', 2, 'IsValidW3CTraceparent(''00-00000000000000000000000000000000-00f067aa0ba902b7-01'') == false', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l10-production-ops', 11, 23, 'mod-l10-production-ops', 'Module 10.A — Containers, Kubernetes Probes & DR', 'Compiling static 12MB non-root distroless Go containers, separating Kubernetes Liveness vs Readiness probes, configuring GOMEMLIMIT for container cgroups, reverse proxies, CI/CD, and PITR backup verification.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l10-devops-docker-k8s-production', 'mod-l10-production-ops', 11, 1, '10.1', 'l10-devops-docker-k8s-production', '10.1 Multi-Stage Distroless Docker Builds, Kubernetes Probes, Caddy/Nginx & Disaster Recovery', 'Compiling static 12MB non-root distroless Go containers, separating Kubernetes Liveness vs Readiness probes, configuring GOMEMLIMIT for container cgroups, reverse proxies, CI/CD, and PITR backup verification.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l10-devops-docker-k8s-production-sec-main', 'l10-devops-docker-k8s-production', 'core', '10.1 Multi-Stage Distroless Docker Builds, Kubernetes Probes, Caddy/Nginx & Disaster Recovery', '{"beginner": "When deploying a Go app with Docker, don''t ship the giant 800MB Go compiler image to your production server! Use a **Multi-Stage Dockerfile**: Stage 1 compiles your Go code into a single binary file, and Stage 2 copies *only* that binary into a tiny, locked-down image (`distroless`) that runs as a non-root user.", "intermediate": "Understand the difference between Kubernetes **Liveness** (`/healthz`) and **Readiness** (`/readyz`) probes: Liveness asks ''Is this process deadlocked and needing a reboot?'' while Readiness asks ''Should the load balancer send user traffic to this pod right now?''. If your database briefly slows down and `/healthz` checks the database, Kubernetes will kill and restart all your pods at once!", "advanced": "Tune the Go runtime for Linux cgroups: 1) Set `GOMEMLIMIT` to 85\u201390% of the container''s memory limit (e.g., `450MiB` for a `512MiB` pod) so the GC paces mark cycles before the Linux OOM killer strikes (see the official Go GC Guide). 2) For CPU-throttled containers (`resources.limits.cpu`), ensure `GOMAXPROCS` matches the container''s integer CPU quota rather than the host node''s 64 cores to avoid excessive OS thread context switching."}', 'Kubernetes Liveness vs Readiness Probe Separation (CRITICAL!):
┌──────────────────────┬───────────────────────────┬──────────────────────────────────────────────┐
│ Probe Endpoint       │ What It Must Check        │ Kubernetes Action on Failure                 │
├──────────────────────┼───────────────────────────┼──────────────────────────────────────────────┤
│ GET /healthz         │ Local process alive only  │ Restarts Container (kills pod!)              │
│ (Liveness Probe)     │ (NEVER check DB/Redis!)   │                                              │
├──────────────────────┼───────────────────────────┼──────────────────────────────────────────────┤
│ GET /readyz          │ DB Ping + Shutdown Flag   │ Removes Pod IP from Service Load Balancer    │
│ (Readiness Probe)    │ (Checks dependencies)     │ (Does NOT restart pod; prevents cascade!)    │
└──────────────────────┴───────────────────────────┴──────────────────────────────────────────────┘', '# BUG 1: 850MB image with compilers, shell, and runs as root (UID 0)!
FROM golang:1.23
WORKDIR /app
COPY . .
RUN go build -o server ./cmd/server
CMD ["./server"]

// BUG 2: Checking DB in Liveness Probe (/healthz) causes cascading pod restarts during DB maintenance!
func HandleLiveness(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if err := db.PingContext(r.Context()); err != nil {
			w.WriteHeader(http.StatusServiceUnavailable) // K8s will kill the pod!
			return
		}
		w.WriteHeader(http.StatusOK)
	}
}', '# Stage 1: Static build
FROM golang:1.23-alpine AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/app ./cmd/server

# Stage 2: 2MB Distroless non-root runtime
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /out/app /app
USER nonroot:nonroot
ENTRYPOINT ["/app"]

// Liveness (/healthz): ONLY verifies process loop responsiveness
func HandleLiveness(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(`{"status":"alive"}`))
}

// Readiness (/readyz): Checks shuttingDown atomic flag + bounded DB ping
func HandleReadiness(db *sql.DB, shuttingDown *atomic.Bool) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if shuttingDown.Load() {
			w.WriteHeader(http.StatusServiceUnavailable)
			return
		}
		ctx, cancel := context.WithTimeout(r.Context(), 500*time.Millisecond)
		defer cancel()
		if err := db.PingContext(ctx); err != nil {
			w.WriteHeader(http.StatusServiceUnavailable)
			return
		}
		w.WriteHeader(http.StatusOK)
	}
}', 'When `shuttingDown` flips to `true` on `SIGTERM` or PostgreSQL briefly blips, `/readyz` returns 503 so Kubernetes stops routing traffic to the pod while `/healthz` remains 200 OK, keeping the process alive to finish draining work and reconnect automatically.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l10-devops-docker-k8s-production-ref-1', 'l10-devops-docker-k8s-production', 'Go Official Guide: A Guide to the Go Garbage Collector (GOMEMLIMIT)', 'https://go.dev/doc/gc-guide', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l10-devops-docker-k8s-production-ref-2', 'l10-devops-docker-k8s-production', 'Docker Official Documentation: Multi-stage builds', 'https://docs.docker.com/build/building/multi-stage/', 'Docker 27+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l10-devops-docker-k8s-production-ref-3', 'l10-devops-docker-k8s-production', 'Kubernetes Official Documentation: Configure Liveness, Readiness and Startup Probes', 'https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/', 'Kubernetes 1.31+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l10-devops-docker-k8s-production', 'l10-devops-docker-k8s-production', 'Calculate Safe GOMEMLIMIT & Evaluate Readiness State', 'Implement RecommendGoMemLimitMiB(containerLimitMiB int) int (returning 85% of containerLimitMiB) and EvaluateReadiness(isShuttingDown, dbHealthy bool) int (returning 200 only when not shutting down and DB is healthy, else 503).', 'package ops

func RecommendGoMemLimitMiB(containerLimitMiB int) int {
	// STEP: Return 85% of containerLimitMiB (minimum 64 MiB)
	return 0
}

func EvaluateReadiness(isShuttingDown, dbHealthy bool) int {
	// STEP: Return 200 OK or 503 Service Unavailable
	return 503
}', 'Invarian: Recommend Go Mem Limit Mi B -> 1024 MiB container => GOMEMLIMIT=870MiB
Invarian: Evaluate Readiness', 'package ops

func RecommendGoMemLimitMiB(containerLimitMiB int) int {
	limit := (containerLimitMiB * 85) / 100
	if limit < 64 {
		return 64
	}
	return limit
}

func EvaluateReadiness(isShuttingDown, dbHealthy bool) int {
	if isShuttingDown || !dbHealthy {
		return 503
	}
	return 200
}', 'Reserving 15% headroom between `GOMEMLIMIT` and the container''s hard cgroup memory limit accommodates non-heap memory (goroutine stacks, runtime metadata, OS buffers).', 'Write a Caddyfile snippet that reverse-proxies `api.example.com` to `localhost:8080` with automatic TLS and structured access logs.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l10-devops-docker-k8s-production-tc-1', 'ex-l10-devops-docker-k8s-production', 1, 'RecommendGoMemLimitMiB(1024) == 870', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l10-devops-docker-k8s-production-tc-2', 'ex-l10-devops-docker-k8s-production', 2, 'EvaluateReadiness(false, true) == 200', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l10-devops-docker-k8s-production-tc-3', 'ex-l10-devops-docker-k8s-production', 3, 'EvaluateReadiness(true, true) == 503', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l10-devops-docker-k8s-production-tc-4', 'ex-l10-devops-docker-k8s-production', 4, 'EvaluateReadiness(false, false) == 503', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l10-proxy-cicd-dr', 11, 24, 'mod-l10-proxy-cicd-dr', 'Module 10.B — Reverse Proxies (Caddy/Nginx), CI/CD Pipelines, Canary Rollbacks & Disaster Recovery', 'Configuring Caddy and Nginx in front of Go services, preventing X-Forwarded-For IP spoofing, automating GitHub Actions CI/CD with canary rollbacks, and verifying RPO/RTO disaster recovery.') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('l10-reverse-proxy-cicd-rollback-dr', 'mod-l10-proxy-cicd-dr', 11, 2, '10.2', 'l10-reverse-proxy-cicd-rollback-dr', '10.2 Caddy & Nginx Reverse Proxies, Trusted X-Forwarded-For, Canary Rollbacks & Disaster Recovery', 'Configuring Caddy and Nginx in front of Go services, preventing X-Forwarded-For IP spoofing, automating GitHub Actions CI/CD with canary rollbacks, and verifying RPO/RTO disaster recovery.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l10-reverse-proxy-cicd-rollback-dr-sec-main', 'l10-reverse-proxy-cicd-rollback-dr', 'core', '10.2 Caddy & Nginx Reverse Proxies, Trusted X-Forwarded-For, Canary Rollbacks & Disaster Recovery', '{"beginner": "In production, you usually put a **Reverse Proxy** like **Caddy** or **Nginx** in front of your Go server to handle HTTPS certificates automatically and forward traffic to `localhost:8080`. Because the Go server sees the connection coming from the proxy (`127.0.0.1`), the proxy passes the user''s real IP in a header\u2014but your Go code must verify the request actually came from your proxy before trusting that header!", "intermediate": "How does an attacker spoof `X-Forwarded-For`? If an attacker sends `X-Forwarded-For: 8.8.8.8`, a standard proxy appends the attacker''s real IP to the end: `X-Forwarded-For: 8.8.8.8, 203.0.113.99`. If your Go code naively grabs the *first* IP (`8.8.8.8`), the attacker can pretend to be any IP address! Instead, only trust `X-Forwarded-For` when `r.RemoteAddr` is a trusted proxy, and read from the **rightmost** entry.", "advanced": "Disaster Recovery is defined by two concrete metrics: **RPO (Recovery Point Objective)**\u2014how many seconds/minutes of data loss can the business tolerate (e.g., RPO=0 with synchronous WAL standby, or RPO<60s with continuous WAL archiving)\u2014and **RTO (Recovery Time Objective)**\u2014how many minutes until service is restored after a full region/host loss. Document and rehearse your exact runbook (`pgBackRest` restore + DNS cutover) so RTO is measured, not guessed."}', 'Reverse Proxy X-Forwarded-For Spoofing Defense:
[Attacker] ── Sends fake header: "X-Forwarded-For: 1.2.3.4" ──► [Caddy / Nginx Edge Proxy]
                                                                     │ Appends true socket IP: "1.2.3.4, 203.0.113.88"
                                                                     ▼
[Go Backend] (ONLY trusts X-Forwarded-For if RemoteAddr is in TrustedProxyCIDRs, and reads RIGHTMOST untrusted IP!)', 'package realip

import (
	"net/http"
	"strings"
)

// BUG: Any client can send ''X-Forwarded-For: 1.2.3.4'' to spoof their IP and bypass rate limits!
func ExtractClientIPUnsafe(r *http.Request) string {
	xff := r.Header.Get("X-Forwarded-For")
	if xff != "" {
		return strings.TrimSpace(strings.Split(xff, ",")[0])
	}
	return r.RemoteAddr
}', 'package realip

import "strings"

func ExtractClientIPSafe(remoteIP string, xffHeader string, trustedProxies map[string]bool) string {
	// If the immediate TCP peer is NOT our trusted reverse proxy, ignore X-Forwarded-For completely!
	if !trustedProxies[remoteIP] || strings.TrimSpace(xffHeader) == "" {
		return remoteIP
	}
	parts := strings.Split(xffHeader, ",")
	// Walk from rightmost to leftmost, returning the first IP not in trustedProxies
	for i := len(parts) - 1; i >= 0; i-- {
		candidate := strings.TrimSpace(parts[i])
		if candidate != "" && !trustedProxies[candidate] {
			return candidate
		}
	}
	return remoteIP
}', 'Walking right-to-left across `X-Forwarded-For` after verifying that the TCP peer (`remoteIP`) is a trusted reverse proxy extracts the true IP appended by your edge proxy, ignoring any fake values prepended by the client.') ON CONFLICT DO NOTHING;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l10-reverse-proxy-cicd-rollback-dr-ref-1', 'l10-reverse-proxy-cicd-rollback-dr', 'MDN & RFC 7239: X-Forwarded-For Security & Rightmost Trusted Proxy Selection', 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For', 'HTTP Standard', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l10-reverse-proxy-cicd-rollback-dr-ref-2', 'l10-reverse-proxy-cicd-rollback-dr', 'Docker Official Documentation: Compose Production Best Practices', 'https://docs.docker.com/compose/how-tos/production/', 'Docker 27+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l10-reverse-proxy-cicd-rollback-dr', 'l10-reverse-proxy-cicd-rollback-dr', 'Implement Spoof-Resistant Right-to-Left X-Forwarded-For Extraction', 'Complete ResolveClientIP(remoteIP, xff string, isTrustedPeer bool) string that returns remoteIP if !isTrustedPeer or xff is empty, and otherwise returns the rightmost comma-separated IP in xff.', 'package proxy

import "strings"

func ResolveClientIP(remoteIP, xff string, isTrustedPeer bool) string {
	// STEP: If !isTrustedPeer or strings.TrimSpace(xff) == "", return remoteIP
	// STEP: Split xff by "," and return strings.TrimSpace of the last (rightmost) element
	return remoteIP
}', 'Invarian: Resolve Client I P Blocks Spoofed Leftmost
Invarian: Untrusted Peer Ignores X F F', 'package proxy

import "strings"

func ResolveClientIP(remoteIP, xff string, isTrustedPeer bool) string {
	if !isTrustedPeer || strings.TrimSpace(xff) == "" {
		return remoteIP
	}
	parts := strings.Split(xff, ",")
	return strings.TrimSpace(parts[len(parts)-1])
}', 'When a single trusted reverse proxy sits in front of Go, the proxy appends the true client socket IP as the final (rightmost) entry in `X-Forwarded-For`.', 'Extend the function to strip multiple hops of internal load balancers using a `map[string]bool` of trusted proxy IPs.') ON CONFLICT DO NOTHING;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l10-reverse-proxy-cicd-rollback-dr-tc-1', 'ex-l10-reverse-proxy-cicd-rollback-dr', 1, 'ResolveClientIP(''127.0.0.1'', ''1.1.1.1, 203.0.113.50'', true) == ''203.0.113.50''', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l10-reverse-proxy-cicd-rollback-dr-tc-2', 'ex-l10-reverse-proxy-cicd-rollback-dr', 2, 'ResolveClientIP(''198.51.100.7'', ''1.1.1.1'', false) == ''198.51.100.7''', '') ON CONFLICT (id) DO UPDATE SET exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;
INSERT INTO quizzes (id, level_id, title) VALUES ('qz-1', 2, 'Level 1 Diagnostic Quiz') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, title = EXCLUDED.title;
INSERT INTO quiz_questions (id, quiz_id, order_index, question_text, options_json, correct_index, explanation) VALUES ('qz-1-q1', 'qz-1', 1, 'A function declares `var err *ValidationError = nil` and returns `err` as an `error` return type. What does `if err := fn(); err != nil` evaluate to in the caller?', '["false, because the pointer value is nil", "true, because the returned error interface has a non-nil type descriptor (*itab) pointing to *ValidationError", "Compile-time error: cannot return *ValidationError as error", "Runtime panic: nil pointer dereference"]', 1, 'In Go, an interface value (`runtime.iface`) consists of two words: `(itab, data)`. It equals `nil` only when both words are zero. Returning a typed nil pointer sets `itab = *ValidationError` and `data = 0x0`, so `err != nil` evaluates to `true`!') ON CONFLICT (id) DO UPDATE SET quiz_id = EXCLUDED.quiz_id, order_index = EXCLUDED.order_index, question_text = EXCLUDED.question_text, options_json = EXCLUDED.options_json, correct_index = EXCLUDED.correct_index, explanation = EXCLUDED.explanation;
INSERT INTO quizzes (id, level_id, title) VALUES ('qz-2', 3, 'Level 2 Diagnostic Quiz') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, title = EXCLUDED.title;
INSERT INTO quiz_questions (id, quiz_id, order_index, question_text, options_json, correct_index, explanation) VALUES ('qz-2-q1', 'qz-2', 1, 'In a Go HTTP handler that spawns a worker goroutine to fetch data while waiting on `select { case res := <-ch: ... case <-r.Context().Done(): ... }`, how do you prevent a goroutine leak if the client disconnects early?', '["Call runtime.GC() inside the handler''s defer block", "Create `ch := make(chan Result, 1)` (buffered size 1) and pass `r.Context()` to the downstream call", "Use an unbuffered channel `make(chan Result)` and close it from the receiver", "Increase GOMAXPROCS to match concurrent requests"]', 1, 'A buffered channel of size 1 (`make(chan Result, 1)`) allows the child goroutine to deposit its single result and exit immediately even if the parent handler already exited via `<-r.Context().Done()`.') ON CONFLICT (id) DO UPDATE SET quiz_id = EXCLUDED.quiz_id, order_index = EXCLUDED.order_index, question_text = EXCLUDED.question_text, options_json = EXCLUDED.options_json, correct_index = EXCLUDED.correct_index, explanation = EXCLUDED.explanation;
INSERT INTO quizzes (id, level_id, title) VALUES ('qz-3', 5, 'Level 4 Diagnostic Quiz') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, title = EXCLUDED.title;
INSERT INTO quiz_questions (id, quiz_id, order_index, question_text, options_json, correct_index, explanation) VALUES ('qz-3-q1', 'qz-3', 1, 'You have a composite B-Tree index in PostgreSQL on `orders (tenant_id, status, created_at DESC)`. Which of the following queries CANNOT use this index as a primary leftmost B-Tree range seek?', '["SELECT * FROM orders WHERE tenant_id = $1 AND status = ''PAID'' ORDER BY created_at DESC LIMIT 20", "SELECT * FROM orders WHERE tenant_id = $1", "SELECT * FROM orders WHERE status = ''PENDING'' ORDER BY created_at DESC", "SELECT * FROM orders WHERE tenant_id = $1 AND status = ''SHIPPED''"]', 2, 'Composite B-Tree indexes are sorted lexicographically by the leading column (`tenant_id`) first. A query that omits `tenant_id` and filters only on `status` cannot jump directly to a contiguous range in the B-Tree (tanpa skip scan).') ON CONFLICT (id) DO UPDATE SET quiz_id = EXCLUDED.quiz_id, order_index = EXCLUDED.order_index, question_text = EXCLUDED.question_text, options_json = EXCLUDED.options_json, correct_index = EXCLUDED.correct_index, explanation = EXCLUDED.explanation;
INSERT INTO quizzes (id, level_id, title) VALUES ('qz-4', 7, 'Level 6 Diagnostic Quiz') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, title = EXCLUDED.title;
INSERT INTO quiz_questions (id, quiz_id, order_index, question_text, options_json, correct_index, explanation) VALUES ('qz-4-q1', 'qz-4', 1, 'Where must IP address validation happen in Go to completely block Server-Side Request Forgery (SSRF) including DNS Rebinding attacks?', '["Regex matching on the URL string before calling http.NewRequest", "Calling net.LookupIP(host) once before passing the URL to http.Get(url)", "Inside `net.Dialer.Control` attached to `http.Transport`, inspecting the resolved `netip.Addr` right before socket connection", "Setting `http.Client{Timeout: 5 * time.Second}`"]', 2, 'Checking the hostname before `http.Client.Do` is vulnerable to DNS rebinding (TOCTOU). Inspecting the resolved IP inside `net.Dialer.Control` verifies the exact socket address used by the OS kernel `connect()` syscall.') ON CONFLICT (id) DO UPDATE SET quiz_id = EXCLUDED.quiz_id, order_index = EXCLUDED.order_index, question_text = EXCLUDED.question_text, options_json = EXCLUDED.options_json, correct_index = EXCLUDED.correct_index, explanation = EXCLUDED.explanation;
INSERT INTO quizzes (id, level_id, title) VALUES ('qz-5', 11, 'Level 10 Diagnostic Quiz') ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, title = EXCLUDED.title;
INSERT INTO quiz_questions (id, quiz_id, order_index, question_text, options_json, correct_index, explanation) VALUES ('qz-5-q1', 'qz-5', 1, 'Your Go pod in Kubernetes has `resources.limits.memory: 512Mi`. What is the recommended `GOMEMLIMIT` configuration and why?', '["GOMEMLIMIT=512MiB so Go uses 100% of the container limit for heap objects", "GOMEMLIMIT=435MiB (~85% of 512Mi) so the Go GC reclaims heap memory before total RSS (heap + stacks + runtime overhead) triggers the Linux OOM killer", "Disable GC with GOGC=off and rely on Kubernetes liveness restarts", "GOMEMLIMIT=2048MiB to prevent GC CPU spikes"]', 1, 'Per the official Go GC Guide, `GOMEMLIMIT` should leave 10–15% headroom below the container''s hard cgroup limit to account for non-Go-heap memory (goroutine stacks, binary text, OS buffers).') ON CONFLICT (id) DO UPDATE SET quiz_id = EXCLUDED.quiz_id, order_index = EXCLUDED.order_index, question_text = EXCLUDED.question_text, options_json = EXCLUDED.options_json, correct_index = EXCLUDED.correct_index, explanation = EXCLUDED.explanation;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-01-task-api', 1, 'cs-01-task-api', 'Personal Task Management API', 'Beginner (Level 3–4)', 'Pragmatic Layered Architecture (Handler -> Service -> Store)', 'SQLite (WAL Mode) for local/single-node or PostgreSQL', 'A bounded CRUD domain with user-scoped tasks does not need microservice complexity or 6 layers of abstraction. A 3-package layered structure with `sqlc` + SQLite/PostgreSQL delivers clean separation and 100% testability.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-1', 'cs-01-task-api', 1, 'business_scenario', '1. Business Scenario', 'Allow authenticated users to create, prioritize, filter, and complete personal tasks with due-date reminders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-2', 'cs-01-task-api', 2, 'functional_reqs', '2. Functional Requirements', 'POST /api/v1/tasks (create task with title, priority, due_at)
GET /api/v1/tasks?status=pending&cursor=... (cursor-paginated list)
PATCH /api/v1/tasks/{id}/complete (idempotent completion)') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-3', 'cs-01-task-api', 3, 'non_functional_reqs', '3. Non-Functional Requirements', 'p99 latency < 15ms
Strict BOLA isolation (users only see their own tasks)
Zero SQL injection via parameterized queries') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-4', 'cs-01-task-api', 4, 'architecture', '4. Architecture & Rationale', 'Pragmatic Layered Architecture (Handler -> Service -> Store) — A bounded CRUD domain with user-scoped tasks does not need microservice complexity or 6 layers of abstraction. A 3-package layered structure with `sqlc` + SQLite/PostgreSQL delivers clean separation and 100% testability.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-5', 'cs-01-task-api', 5, 'database_selection', '5. Database Selection', 'SQLite (WAL Mode) for local/single-node or PostgreSQL') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-6', 'cs-01-task-api', 6, 'schema', '6. Production Schema', 'CREATE TABLE tasks (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL CHECK (length(title) BETWEEN 1 AND 200),
    priority INTEGER NOT NULL DEFAULT 2 CHECK (priority BETWEEN 1 AND 3),
    status TEXT NOT NULL DEFAULT ''PENDING'' CHECK (status IN (''PENDING'', ''DONE'')),
    due_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_tasks_user_status_created ON tasks(user_id, status, created_at DESC);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-7', 'cs-01-task-api', 7, 'api_design', '7. API Endpoint Design', 'POST /api/v1/tasks (create task with title, priority, due_at)
GET /api/v1/tasks?status=pending&cursor=... (cursor-paginated list)
PATCH /api/v1/tasks/{id}/complete (idempotent completion)
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-8', 'cs-01-task-api', 8, 'go_implementation', '8. Go Implementation Pattern', 'func (s *TaskStore) CompleteTask(ctx context.Context, taskID, userID string) error {
	res, err := s.db.ExecContext(ctx, `
		UPDATE tasks SET status = ''DONE''
		WHERE id = $1 AND user_id = $2
	`, taskID, userID)
	if err != nil {
		return err
	}
	if n, _ := res.RowsAffected(); n == 0 {
		return ErrTaskNotFound
	}
	return nil
}') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-9', 'cs-01-task-api', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-10', 'cs-01-task-api', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-11', 'cs-01-task-api', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-12', 'cs-01-task-api', 12, 'deployment', '12. Deployment Strategy', 'Single static Go binary + Litestream continuous WAL backup to S3, or Docker Compose with PostgreSQL.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-13', 'cs-01-task-api', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Querying `WHERE id = $1` without `AND user_id = $2` (allows any user to complete or view another user''s task via ID guessing); using `OFFSET` instead of cursor pagination.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-01-task-api-step-14', 'cs-01-task-api', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-02-auth-service', 2, 'cs-02-auth-service', 'Authentication & Authorization Service (OAuth2 + Argon2id + Refresh Rotation)', 'Intermediate (Level 6)', 'Hexagonal Architecture (Ports & Adapters)', 'PostgreSQL (Credentials & Refresh Families) + Redis (Revocation Deny-List & Login Rate Limit)', 'Identity requires durable ACID storage for user accounts, RBAC roles, and refresh-token rotation families (PostgreSQL), paired with sub-millisecond brute-force rate limiting in Redis.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-1', 'cs-02-auth-service', 1, 'business_scenario', '1. Business Scenario', 'Centralized identity provider issuing short-lived EdDSA JWT access tokens (5m TTL) and rotating HttpOnly refresh tokens (7d TTL) with automatic breach detection on token reuse.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-2', 'cs-02-auth-service', 2, 'functional_reqs', '2. Functional Requirements', 'POST /v1/auth/register (Argon2id hash)
POST /v1/auth/login (rate-limited + constant-time verify)
POST /v1/auth/refresh (rotates token; revokes entire family if used token is replayed)') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-3', 'cs-02-auth-service', 3, 'non_functional_reqs', '3. Non-Functional Requirements', 'Argon2id tuned to 64MB RAM, 3 iterations, 4 threads, bounded by a Go semaphore of 8 concurrent hashes
Zero timing side-channels') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-4', 'cs-02-auth-service', 4, 'architecture', '4. Architecture & Rationale', 'Hexagonal Architecture (Ports & Adapters) — Identity requires durable ACID storage for user accounts, RBAC roles, and refresh-token rotation families (PostgreSQL), paired with sub-millisecond brute-force rate limiting in Redis.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-5', 'cs-02-auth-service', 5, 'database_selection', '5. Database Selection', 'PostgreSQL (Credentials & Refresh Families) + Redis (Revocation Deny-List & Login Rate Limit)') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-6', 'cs-02-auth-service', 6, 'schema', '6. Production Schema', 'CREATE TABLE refresh_tokens (
    token_hash BYTEA PRIMARY KEY,
    family_id UUID NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_used BOOLEAN NOT NULL DEFAULT FALSE,
    revoked_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX idx_refresh_family ON refresh_tokens(family_id);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-7', 'cs-02-auth-service', 7, 'api_design', '7. API Endpoint Design', 'POST /v1/auth/register (Argon2id hash)
POST /v1/auth/login (rate-limited + constant-time verify)
POST /v1/auth/refresh (rotates token; revokes entire family if used token is replayed)
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-8', 'cs-02-auth-service', 8, 'go_implementation', '8. Go Implementation Pattern', '// If an already-used refresh token is presented again, an attacker stole the token!
// Immediately revoke the entire token family for that session.
if tokenRecord.IsUsed {
	_, _ = tx.ExecContext(ctx, `UPDATE refresh_tokens SET revoked_at = NOW() WHERE family_id = $1`, tokenRecord.FamilyID)
	_ = tx.Commit()
	return nil, ErrCompromisedTokenFamily
}') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-9', 'cs-02-auth-service', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-10', 'cs-02-auth-service', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-11', 'cs-02-auth-service', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-12', 'cs-02-auth-service', 12, 'deployment', '12. Deployment Strategy', 'Kubernetes Deployment (3 replicas) with asymmetric Ed25519 public keys published via `/.well-known/jwks.json`.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-13', 'cs-02-auth-service', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Allowing unlimited concurrent Argon2id logins (enables trivial CPU/OOM DoS with 100 parallel POST requests—always guard Argon2id behind a channel semaphore!); not rotating refresh tokens.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-02-auth-service-step-14', 'cs-02-auth-service', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-03-url-shortener', 3, 'cs-03-url-shortener', 'High-Throughput URL Shortener & Click Analytics', 'Intermediate (Level 4–5 & 9)', 'Read-Heavy Cache-Aside + Async Buffered Analytics Pipeline', 'PostgreSQL (Base62 Mapping) + Redis (Hot Redirect Cache) + ClickHouse/Timescale (Click Events)', 'Read-to-write ratio is 100:1. Redirects (`GET /{code}`) must respond in <2ms via Redis + Go `singleflight` without blocking on synchronous analytics `INSERT`s.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-1', 'cs-03-url-shortener', 1, 'business_scenario', '1. Business Scenario', 'Shorten URLs into collision-free 7-character Base62 codes and record geo/referrer click analytics without slowing down HTTP 302/307 redirects.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-2', 'cs-03-url-shortener', 2, 'functional_reqs', '2. Functional Requirements', 'POST /v1/shorten (generates Base62 ID from distributed Snowflake/sequence)
GET /{code} (307 Redirect + non-blocking click event enqueue)
GET /v1/urls/{code}/stats') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-3', 'cs-03-url-shortener', 3, 'non_functional_reqs', '3. Non-Functional Requirements', '10,000 redirects/sec per node
p99 redirect latency < 3ms
SSRF/open-redirect target validation') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-4', 'cs-03-url-shortener', 4, 'architecture', '4. Architecture & Rationale', 'Read-Heavy Cache-Aside + Async Buffered Analytics Pipeline — Read-to-write ratio is 100:1. Redirects (`GET /{code}`) must respond in <2ms via Redis + Go `singleflight` without blocking on synchronous analytics `INSERT`s.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-5', 'cs-03-url-shortener', 5, 'database_selection', '5. Database Selection', 'PostgreSQL (Base62 Mapping) + Redis (Hot Redirect Cache) + ClickHouse/Timescale (Click Events)') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-6', 'cs-03-url-shortener', 6, 'schema', '6. Production Schema', 'CREATE TABLE short_urls (
    code VARCHAR(12) PRIMARY KEY,
    original_url TEXT NOT NULL,
    creator_id UUID NOT NULL,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-7', 'cs-03-url-shortener', 7, 'api_design', '7. API Endpoint Design', 'POST /v1/shorten (generates Base62 ID from distributed Snowflake/sequence)
GET /{code} (307 Redirect + non-blocking click event enqueue)
GET /v1/urls/{code}/stats
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-8', 'cs-03-url-shortener', 8, 'go_implementation', '8. Go Implementation Pattern', '// Resolve redirect using singleflight to prevent cache stampede on viral links
val, err, _ := s.sfGroup.Do(code, func() (any, error) {
	if cached, err := s.redis.Get(ctx, "url:"+code).Result(); err == nil {
		return cached, nil
	}
	origURL, err := s.repo.GetOriginalURL(ctx, code)
	if err != nil {
		return "", err
	}
	_ = s.redis.Set(ctx, "url:"+code, origURL, 15*time.Minute).Err()
	return origURL, nil
})') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-9', 'cs-03-url-shortener', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-10', 'cs-03-url-shortener', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-11', 'cs-03-url-shortener', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-12', 'cs-03-url-shortener', 12, 'deployment', '12. Deployment Strategy', 'Edge-cached Go instances + Redis Cluster + batched background click flush worker.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-13', 'cs-03-url-shortener', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Running `UPDATE short_urls SET clicks = clicks + 1 WHERE code = $1` synchronously inside the `GET /{code}` redirect handler (serializes every click on a single row lock in PostgreSQL!).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-03-url-shortener-step-14', 'cs-03-url-shortener', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-04-blog-cms', 4, 'cs-04-blog-cms', 'Blog & Content Management Backend with Full-Text Search', 'Intermediate (Level 4–5)', 'Modular Monolith with PostgreSQL FTS (`tsvector` + GIN)', 'PostgreSQL 17/18 (Relational + Generated `tsvector` GIN Index)', 'Instead of operating a separate Elasticsearch cluster for <10M articles, PostgreSQL''s built-in `tsvector` + `GIN` index provides stemmed full-text search, ranking (`ts_rank_cd`), and ACID publishing workflows in one database.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-1', 'cs-04-blog-cms', 1, 'business_scenario', '1. Business Scenario', 'Multi-author publishing platform with draft/review/published state machine, revision history, and weighted full-text search.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-2', 'cs-04-blog-cms', 2, 'functional_reqs', '2. Functional Requirements', 'POST /v1/articles
POST /v1/articles/{id}/publish
GET /v1/articles/search?q=golang+concurrency') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-3', 'cs-04-blog-cms', 3, 'non_functional_reqs', '3. Non-Functional Requirements', 'Full-text search p95 < 10ms
Zero XSS via strict HTML sanitization (`bluemonday`) on rendered markdown') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-4', 'cs-04-blog-cms', 4, 'architecture', '4. Architecture & Rationale', 'Modular Monolith with PostgreSQL FTS (`tsvector` + GIN) — Instead of operating a separate Elasticsearch cluster for <10M articles, PostgreSQL''s built-in `tsvector` + `GIN` index provides stemmed full-text search, ranking (`ts_rank_cd`), and ACID publishing workflows in one database.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-5', 'cs-04-blog-cms', 5, 'database_selection', '5. Database Selection', 'PostgreSQL 17/18 (Relational + Generated `tsvector` GIN Index)') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-6', 'cs-04-blog-cms', 6, 'schema', '6. Production Schema', 'CREATE TABLE articles (
    id UUID PRIMARY KEY,
    slug VARCHAR(200) NOT NULL UNIQUE,
    title TEXT NOT NULL,
    body_markdown TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT ''DRAFT'',
    search_tsv TSVECTOR GENERATED ALWAYS AS (
        setweight(to_tsvector(''english'', coalesce(title, '''')), ''A'') ||
        setweight(to_tsvector(''english'', coalesce(body_markdown, '''')), ''B'')
    ) STORED
);
CREATE INDEX idx_articles_search_gin ON articles USING GIN (search_tsv);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-7', 'cs-04-blog-cms', 7, 'api_design', '7. API Endpoint Design', 'POST /v1/articles
POST /v1/articles/{id}/publish
GET /v1/articles/search?q=golang+concurrency
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-8', 'cs-04-blog-cms', 8, 'go_implementation', '8. Go Implementation Pattern', 'const searchSQL = `
SELECT id, slug, title, ts_rank_cd(search_tsv, websearch_to_tsquery(''english'', $1)) AS rank
FROM articles
WHERE status = ''PUBLISHED'' AND search_tsv @@ websearch_to_tsquery(''english'', $1)
ORDER BY rank DESC LIMIT 20;`') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-9', 'cs-04-blog-cms', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-10', 'cs-04-blog-cms', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-11', 'cs-04-blog-cms', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-12', 'cs-04-blog-cms', 12, 'deployment', '12. Deployment Strategy', 'Docker Compose / Cloud Run + CDN cache with `Surrogate-Key` purge on article update.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-13', 'cs-04-blog-cms', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Using `WHERE body_markdown ILIKE ''%term%''` without a trigram or GIN `tsvector` index, forcing a full table scan reading gigabytes of text.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-04-blog-cms-step-14', 'cs-04-blog-cms', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-05-ecommerce-backend', 5, 'cs-05-ecommerce-backend', 'E-Commerce Checkout & Order Orchestration Backend', 'Advanced (Level 8–9)', 'Hexagonal Modular Monolith + Transactional Outbox', 'PostgreSQL (Orders, Payments, Outbox) + Redis (Cart & Idempotency)', 'Checkout spans inventory reservation, coupon validation, payment intent creation, and order confirmation. Modular Monolith + Outbox guarantees atomic order creation and reliable downstream fulfillment events.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-1', 'cs-05-ecommerce-backend', 1, 'business_scenario', '1. Business Scenario', 'Process customer checkouts with strict idempotency, exact integer cent pricing, inventory reservation, and webhook reconciliation.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-2', 'cs-05-ecommerce-backend', 2, 'functional_reqs', '2. Functional Requirements', 'POST /v1/checkout (requires Idempotency-Key)
POST /v1/webhooks/payment (verifies HMAC-SHA256 signature)') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-3', 'cs-05-ecommerce-backend', 3, 'non_functional_reqs', '3. Non-Functional Requirements', 'Zero double-charges on client network retries
Exact integer money arithmetic') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-4', 'cs-05-ecommerce-backend', 4, 'architecture', '4. Architecture & Rationale', 'Hexagonal Modular Monolith + Transactional Outbox — Checkout spans inventory reservation, coupon validation, payment intent creation, and order confirmation. Modular Monolith + Outbox guarantees atomic order creation and reliable downstream fulfillment events.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-5', 'cs-05-ecommerce-backend', 5, 'database_selection', '5. Database Selection', 'PostgreSQL (Orders, Payments, Outbox) + Redis (Cart & Idempotency)') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-6', 'cs-05-ecommerce-backend', 6, 'schema', '6. Production Schema', 'CREATE TABLE orders (
    id UUID PRIMARY KEY,
    idempotency_key VARCHAR(128) NOT NULL UNIQUE,
    user_id UUID NOT NULL,
    total_cents BIGINT NOT NULL CHECK (total_cents >= 0),
    status VARCHAR(32) NOT NULL DEFAULT ''AWAITING_PAYMENT'',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-7', 'cs-05-ecommerce-backend', 7, 'api_design', '7. API Endpoint Design', 'POST /v1/checkout (requires Idempotency-Key)
POST /v1/webhooks/payment (verifies HMAC-SHA256 signature)
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-8', 'cs-05-ecommerce-backend', 8, 'go_implementation', '8. Go Implementation Pattern', '// Verify webhook HMAC signature in constant time before processing payment event
mac := hmac.New(sha256.New, webhookSecret)
mac.Write(rawBody)
expectedMAC := mac.Sum(nil)
if !hmac.Equal(providedMAC, expectedMAC) {
	return ErrInvalidWebhookSignature
}') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-9', 'cs-05-ecommerce-backend', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-10', 'cs-05-ecommerce-backend', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-11', 'cs-05-ecommerce-backend', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-12', 'cs-05-ecommerce-backend', 12, 'deployment', '12. Deployment Strategy', 'Multi-AZ Kubernetes + RDS PostgreSQL Multi-AZ.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-13', 'cs-05-ecommerce-backend', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Trusting price values sent from the frontend cart JSON instead of recalculating prices from the database catalog inside the checkout transaction.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-05-ecommerce-backend-step-14', 'cs-05-ecommerce-backend', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-06-inventory-system', 6, 'cs-06-inventory-system', 'High-Concurrency Flash-Sale Inventory Management System', 'Advanced (Level 4 & 9)', 'CQRS + Optimistic/Atomic SQL Locking + Temporary Reservation TTL', 'PostgreSQL (Source of Truth) + Redis (Flash-Sale Atomic Pre-Gate)', 'During a flash sale (50,000 users trying to buy 100 items in 2 seconds), Redis Lua `DECR` acts as an ultra-fast pre-filter so only 100 requests hit PostgreSQL''s transactional reservation table.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-1', 'cs-06-inventory-system', 1, 'business_scenario', '1. Business Scenario', 'Prevent overselling (`available_qty < 0`) under 50k RPS flash-sale contention while releasing unpaid cart holds after 10 minutes.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-2', 'cs-06-inventory-system', 2, 'functional_reqs', '2. Functional Requirements', 'POST /v1/inventory/reserve
POST /v1/inventory/commit
Background Worker: ReleaseExpiredHolds') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-3', 'cs-06-inventory-system', 3, 'non_functional_reqs', '3. Non-Functional Requirements', 'Zero overselling invariant (`available_qty >= 0`)
Automatic hold expiration') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-4', 'cs-06-inventory-system', 4, 'architecture', '4. Architecture & Rationale', 'CQRS + Optimistic/Atomic SQL Locking + Temporary Reservation TTL — During a flash sale (50,000 users trying to buy 100 items in 2 seconds), Redis Lua `DECR` acts as an ultra-fast pre-filter so only 100 requests hit PostgreSQL''s transactional reservation table.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-5', 'cs-06-inventory-system', 5, 'database_selection', '5. Database Selection', 'PostgreSQL (Source of Truth) + Redis (Flash-Sale Atomic Pre-Gate)') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-6', 'cs-06-inventory-system', 6, 'schema', '6. Production Schema', 'CREATE TABLE inventory_skus (
    sku VARCHAR(64) PRIMARY KEY,
    available_qty INTEGER NOT NULL CHECK (available_qty >= 0),
    reserved_qty INTEGER NOT NULL CHECK (reserved_qty >= 0),
    version BIGINT NOT NULL DEFAULT 1
);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-7', 'cs-06-inventory-system', 7, 'api_design', '7. API Endpoint Design', 'POST /v1/inventory/reserve
POST /v1/inventory/commit
Background Worker: ReleaseExpiredHolds
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-8', 'cs-06-inventory-system', 8, 'go_implementation', '8. Go Implementation Pattern', 'UPDATE inventory_skus
SET available_qty = available_qty - $1,
    reserved_qty = reserved_qty + $1,
    version = version + 1
WHERE sku = $2 AND available_qty >= $1;') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-9', 'cs-06-inventory-system', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-10', 'cs-06-inventory-system', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-11', 'cs-06-inventory-system', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-12', 'cs-06-inventory-system', 12, 'deployment', '12. Deployment Strategy', 'Go service with background `FOR UPDATE SKIP LOCKED` reservation reaper.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-13', 'cs-06-inventory-system', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Deducting permanent stock on ''Add to Cart'' instead of creating a time-bounded `inventory_reservations` row with an `expires_at` timestamp (allows competitors to lock up 100% of stock without paying).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-06-inventory-system-step-14', 'cs-06-inventory-system', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-07-realtime-chat', 7, 'cs-07-realtime-chat', 'Real-Time WebSocket Chat & Presence Backend', 'Advanced (Level 2 & 9)', 'Stateful WebSocket Hub per Node + Redis Pub/Sub / NATS Backplane', 'ScyllaDB / Cassandra or PostgreSQL Partitioned Tables (Messages) + Redis (Presence & Pub/Sub)', 'User A may be connected via WebSocket to Go Pod 1 while User B is connected to Go Pod 2. A Redis Pub/Sub or NATS backplane routes messages between pods, while time-ordered clustering keys store chat history.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-1', 'cs-07-realtime-chat', 1, 'business_scenario', '1. Business Scenario', 'Deliver real-time messages across rooms and direct channels with read receipts, online presence, and pagination by Snowflake/UUIDv7 message ID.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-2', 'cs-07-realtime-chat', 2, 'functional_reqs', '2. Functional Requirements', 'GET /v1/ws (WebSocket upgrade with read/write pumps)
POST /v1/rooms/{id}/messages
GET /v1/rooms/{id}/messages?before={msg_id}') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-3', 'cs-07-realtime-chat', 3, 'non_functional_reqs', '3. Non-Functional Requirements', 'Bound per-client outgoing send channel (`make(chan []byte, 64)`) to drop/disconnect slow consumers before OOM
Heartbeat Ping/Pong every 30s') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-4', 'cs-07-realtime-chat', 4, 'architecture', '4. Architecture & Rationale', 'Stateful WebSocket Hub per Node + Redis Pub/Sub / NATS Backplane — User A may be connected via WebSocket to Go Pod 1 while User B is connected to Go Pod 2. A Redis Pub/Sub or NATS backplane routes messages between pods, while time-ordered clustering keys store chat history.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-5', 'cs-07-realtime-chat', 5, 'database_selection', '5. Database Selection', 'ScyllaDB / Cassandra or PostgreSQL Partitioned Tables (Messages) + Redis (Presence & Pub/Sub)') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-6', 'cs-07-realtime-chat', 6, 'schema', '6. Production Schema', '-- Partitioned by channel_id, ordered by time-sortable message_id (UUIDv7 / Snowflake)
CREATE TABLE chat_messages (
    channel_id UUID NOT NULL,
    message_id UUID NOT NULL,
    sender_id UUID NOT NULL,
    body TEXT NOT NULL,
    PRIMARY KEY (channel_id, message_id)
);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-7', 'cs-07-realtime-chat', 7, 'api_design', '7. API Endpoint Design', 'GET /v1/ws (WebSocket upgrade with read/write pumps)
POST /v1/rooms/{id}/messages
GET /v1/rooms/{id}/messages?before={msg_id}
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-8', 'cs-07-realtime-chat', 8, 'go_implementation', '8. Go Implementation Pattern', '// Non-blocking fan-out to client send buffer: evict slow client instead of blocking entire room hub!
select {
case client.sendCh <- msgBytes:
default:
	close(client.sendCh)
	delete(h.clients, client)
}') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-9', 'cs-07-realtime-chat', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-10', 'cs-07-realtime-chat', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-11', 'cs-07-realtime-chat', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-12', 'cs-07-realtime-chat', 12, 'deployment', '12. Deployment Strategy', 'Kubernetes with sticky WebSocket load-balancer timeouts (3600s) + NATS/Redis cluster.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-13', 'cs-07-realtime-chat', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Doing a blocking `client.sendCh <- msg` inside the central room broadcast loop—one user on a stalled 2G mobile connection blocks message delivery for all 1,000 users in the room!') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-07-realtime-chat-step-14', 'cs-07-realtime-chat', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-08-file-storage', 8, 'cs-08-file-storage', 'Secure Object & File Storage Service (Pre-Signed URLs & Streaming)', 'Intermediate (Level 3 & 6)', 'Control-Plane Metadata API + Direct-to-S3/MinIO Pre-Signed Uploads', 'PostgreSQL (File Metadata, Checksums & ACLs) + S3/MinIO Object Storage', 'Proxying 2GB video uploads through Go API memory wastes bandwidth and RAM. The Go API issues short-lived S3 pre-signed `PUT` URLs with strict `Content-Length` and SHA-256 checksum constraints, or streams via `io.Reader` magic-byte sniffing.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-1', 'cs-08-file-storage', 1, 'business_scenario', '1. Business Scenario', 'Upload, virus-scan, verify MIME magic bytes, and serve private files with tenant access control.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-2', 'cs-08-file-storage', 2, 'functional_reqs', '2. Functional Requirements', 'POST /v1/files/upload-intent (returns Pre-Signed PUT URL)
POST /v1/files/{id}/finalize (verifies object header via http.DetectContentType)') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-3', 'cs-08-file-storage', 3, 'non_functional_reqs', '3. Non-Functional Requirements', 'Never trust client-provided Content-Type header or file extension
Zero path traversal (`filepath.Clean` + UUID object keys)') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-4', 'cs-08-file-storage', 4, 'architecture', '4. Architecture & Rationale', 'Control-Plane Metadata API + Direct-to-S3/MinIO Pre-Signed Uploads — Proxying 2GB video uploads through Go API memory wastes bandwidth and RAM. The Go API issues short-lived S3 pre-signed `PUT` URLs with strict `Content-Length` and SHA-256 checksum constraints, or streams via `io.Reader` magic-byte sniffing.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-5', 'cs-08-file-storage', 5, 'database_selection', '5. Database Selection', 'PostgreSQL (File Metadata, Checksums & ACLs) + S3/MinIO Object Storage') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-6', 'cs-08-file-storage', 6, 'schema', '6. Production Schema', 'CREATE TABLE stored_files (
    id UUID PRIMARY KEY,
    owner_id UUID NOT NULL,
    object_key TEXT NOT NULL UNIQUE,
    detected_mime VARCHAR(120) NOT NULL,
    size_bytes BIGINT NOT NULL CHECK (size_bytes > 0),
    sha256_hex CHAR(64) NOT NULL,
    status VARCHAR(24) NOT NULL DEFAULT ''PENDING''
);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-7', 'cs-08-file-storage', 7, 'api_design', '7. API Endpoint Design', 'POST /v1/files/upload-intent (returns Pre-Signed PUT URL)
POST /v1/files/{id}/finalize (verifies object header via http.DetectContentType)
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-8', 'cs-08-file-storage', 8, 'go_implementation', '8. Go Implementation Pattern', '// Read first 512 bytes to detect true MIME magic number (prevents .html disguised as .png XSS)
headerBuf := make([]byte, 512)
n, _ := io.ReadFull(fileStream, headerBuf)
trueMIME := http.DetectContentType(headerBuf[:n])') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-9', 'cs-08-file-storage', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-10', 'cs-08-file-storage', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-11', 'cs-08-file-storage', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-12', 'cs-08-file-storage', 12, 'deployment', '12. Deployment Strategy', 'Go API + MinIO / AWS S3 + async ClamAV scanner worker.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-13', 'cs-08-file-storage', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Using the user-supplied filename directly in `os.Create("/uploads/" + filename)` (allows `../../etc/cron.d/pwn` path traversal) or trusting `r.Header.Get("Content-Type")`.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-08-file-storage-step-14', 'cs-08-file-storage', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-09-notification-service', 9, 'cs-09-notification-service', 'Multi-Channel Notification Delivery Service (Email, SMS, Push, Webhook)', 'Advanced (Level 9)', 'Event-Driven Worker Pool + Per-Provider Circuit Breakers + Exponential Backoff & DLQ', 'PostgreSQL (Delivery Log & Templates) + RabbitMQ / Kafka (Dispatch Queues)', 'External SMS/Email providers (Twilio, SES, FCM) suffer intermittent latency and rate limits. Decoupling dispatch via queues with per-provider circuit breakers and dead-letter queues prevents provider outages from impacting core user APIs.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-1', 'cs-09-notification-service', 1, 'business_scenario', '1. Business Scenario', 'Reliably deliver transactional notifications with deduplication, provider failover, and retry backoff.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-2', 'cs-09-notification-service', 2, 'functional_reqs', '2. Functional Requirements', 'POST /v1/notifications/send
Worker: Retry with Full Jitter up to 5 attempts -> route to DLQ') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-3', 'cs-09-notification-service', 3, 'non_functional_reqs', '3. Non-Functional Requirements', 'Idempotent deduplication by `(notification_id, channel)`
Circuit breaker automatic failover from Primary SMTP to Backup SES') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-4', 'cs-09-notification-service', 4, 'architecture', '4. Architecture & Rationale', 'Event-Driven Worker Pool + Per-Provider Circuit Breakers + Exponential Backoff & DLQ — External SMS/Email providers (Twilio, SES, FCM) suffer intermittent latency and rate limits. Decoupling dispatch via queues with per-provider circuit breakers and dead-letter queues prevents provider outages from impacting core user APIs.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-5', 'cs-09-notification-service', 5, 'database_selection', '5. Database Selection', 'PostgreSQL (Delivery Log & Templates) + RabbitMQ / Kafka (Dispatch Queues)') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-6', 'cs-09-notification-service', 6, 'schema', '6. Production Schema', 'CREATE TABLE notification_deliveries (
    id UUID PRIMARY KEY,
    idempotency_key VARCHAR(128) NOT NULL UNIQUE,
    channel VARCHAR(24) NOT NULL,
    recipient TEXT NOT NULL,
    status VARCHAR(24) NOT NULL DEFAULT ''QUEUED'',
    attempt_count INTEGER NOT NULL DEFAULT 0,
    next_retry_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-7', 'cs-09-notification-service', 7, 'api_design', '7. API Endpoint Design', 'POST /v1/notifications/send
Worker: Retry with Full Jitter up to 5 attempts -> route to DLQ
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-8', 'cs-09-notification-service', 8, 'go_implementation', '8. Go Implementation Pattern', '// Poll due retries across multiple worker pods without duplicate locking:
SELECT id, channel, recipient FROM notification_deliveries
WHERE status = ''RETRY_SCHEDULED'' AND next_retry_at <= NOW()
ORDER BY next_retry_at ASC LIMIT 50
FOR UPDATE SKIP LOCKED;') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-9', 'cs-09-notification-service', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-10', 'cs-09-notification-service', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-11', 'cs-09-notification-service', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-12', 'cs-09-notification-service', 12, 'deployment', '12. Deployment Strategy', 'Stateless API + Autoscaled Queue Consumer Pods.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-13', 'cs-09-notification-service', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Sending emails synchronously inside the `POST /register` HTTP handler (adds 800ms to registration and fails user signup whenever the SMTP server blips).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-09-notification-service-step-14', 'cs-09-notification-service', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-10-booking-reservation', 10, 'cs-10-booking-reservation', 'Hotel / Flight / Clinic Booking & Time-Slot Reservation System', 'Advanced (Level 4)', 'PostgreSQL Exclusion Constraints (`btree_gist`) + ACID Transactions', 'PostgreSQL 17/18 with `btree_gist` Extension (`EXCLUDE USING gist`)', 'Application-level overlap checks (`SELECT count(*) WHERE start < $end AND end > $start`) fail under `READ COMMITTED` when two users book overlapping time ranges simultaneously. PostgreSQL''s `EXCLUDE USING gist (room_id WITH =, tstzrange(check_in, check_out) WITH &&)` enforces non-overlapping intervals at the storage index level!') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-1', 'cs-10-booking-reservation', 1, 'business_scenario', '1. Business Scenario', 'Guarantee mathematically zero double-bookings for rooms, seats, or doctor appointments across arbitrary date/time intervals.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-2', 'cs-10-booking-reservation', 2, 'functional_reqs', '2. Functional Requirements', 'POST /v1/bookings (atomic interval reservation)
DELETE /v1/bookings/{id} (cancellation)') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-3', 'cs-10-booking-reservation', 3, 'non_functional_reqs', '3. Non-Functional Requirements', '100% immunity to overlapping time-range race conditions') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-4', 'cs-10-booking-reservation', 4, 'architecture', '4. Architecture & Rationale', 'PostgreSQL Exclusion Constraints (`btree_gist`) + ACID Transactions — Application-level overlap checks (`SELECT count(*) WHERE start < $end AND end > $start`) fail under `READ COMMITTED` when two users book overlapping time ranges simultaneously. PostgreSQL''s `EXCLUDE USING gist (room_id WITH =, tstzrange(check_in, check_out) WITH &&)` enforces non-overlapping intervals at the storage index level!') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-5', 'cs-10-booking-reservation', 5, 'database_selection', '5. Database Selection', 'PostgreSQL 17/18 with `btree_gist` Extension (`EXCLUDE USING gist`)') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-6', 'cs-10-booking-reservation', 6, 'schema', '6. Production Schema', 'CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE room_bookings (
    id UUID PRIMARY KEY,
    room_id UUID NOT NULL,
    guest_id UUID NOT NULL,
    stay_period TSTZRANGE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT ''CONFIRMED'',
    EXCLUDE USING gist (
        room_id WITH =,
        stay_period WITH &&
    ) WHERE (status = ''CONFIRMED'')
);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-7', 'cs-10-booking-reservation', 7, 'api_design', '7. API Endpoint Design', 'POST /v1/bookings (atomic interval reservation)
DELETE /v1/bookings/{id} (cancellation)
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-8', 'cs-10-booking-reservation', 8, 'go_implementation', '8. Go Implementation Pattern', '_, err := db.ExecContext(ctx, `
	INSERT INTO room_bookings (id, room_id, guest_id, stay_period)
	VALUES ($1, $2, $3, tstzrange($4::timestamptz, $5::timestamptz, ''[)''))
`, bookingID, roomID, guestID, checkIn, checkOut)
// Postgres returns SQLSTATE 23P01 (exclusion_violation) if any overlap exists!') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-9', 'cs-10-booking-reservation', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-10', 'cs-10-booking-reservation', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-11', 'cs-10-booking-reservation', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-12', 'cs-10-booking-reservation', 12, 'deployment', '12. Deployment Strategy', 'PostgreSQL primary with GiST exclusion constraint.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-13', 'cs-10-booking-reservation', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Checking for overlapping dates in Go code with a `SELECT` before `INSERT` without `EXCLUDE USING gist` or `SERIALIZABLE` isolation—causes double-bookings under concurrent requests.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-10-booking-reservation-step-14', 'cs-10-booking-reservation', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-11-payment-simulation', 11, 'cs-11-payment-simulation', 'Payment Processing Gateway & Double-Entry Settlement Engine', 'Advanced (Level 6, 8 & 9)', 'Two-Phase Authorize/Capture State Machine + Immutable Double-Entry Ledger', 'PostgreSQL (`SERIALIZABLE` / Row-Locked Ledger)', 'Payments never overwrite a single float column. Every movement of funds (Authorization Hold -> Capture -> Platform Fee -> Merchant Payout -> Refund) is recorded as balanced debit/credit rows summing to zero (`SUM(amount_cents) = 0`).') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-1', 'cs-11-payment-simulation', 1, 'business_scenario', '1. Business Scenario', 'Simulate payment authorization, capture, partial refunds, and reconciliation reports with cryptographic idempotency.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-2', 'cs-11-payment-simulation', 2, 'functional_reqs', '2. Functional Requirements', 'POST /v1/payment-intents (Authorize)
POST /v1/payment-intents/{id}/capture
POST /v1/payment-intents/{id}/refund') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-3', 'cs-11-payment-simulation', 3, 'non_functional_reqs', '3. Non-Functional Requirements', 'Every transaction balances debits and credits to 0
PCI-DSS scoping: never log raw PAN/CVV in slog') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-4', 'cs-11-payment-simulation', 4, 'architecture', '4. Architecture & Rationale', 'Two-Phase Authorize/Capture State Machine + Immutable Double-Entry Ledger — Payments never overwrite a single float column. Every movement of funds (Authorization Hold -> Capture -> Platform Fee -> Merchant Payout -> Refund) is recorded as balanced debit/credit rows summing to zero (`SUM(amount_cents) = 0`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-5', 'cs-11-payment-simulation', 5, 'database_selection', '5. Database Selection', 'PostgreSQL (`SERIALIZABLE` / Row-Locked Ledger)') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-6', 'cs-11-payment-simulation', 6, 'schema', '6. Production Schema', 'CREATE TABLE journal_postings (
    id UUID PRIMARY KEY,
    transaction_id UUID NOT NULL,
    account_id UUID NOT NULL,
    amount_cents BIGINT NOT NULL, -- Debits negative, Credits positive
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-7', 'cs-11-payment-simulation', 7, 'api_design', '7. API Endpoint Design', 'POST /v1/payment-intents (Authorize)
POST /v1/payment-intents/{id}/capture
POST /v1/payment-intents/{id}/refund
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-8', 'cs-11-payment-simulation', 8, 'go_implementation', '8. Go Implementation Pattern', '// Invariant check before committing double-entry journal batch:
var netSum int64
for _, entry := range postings {
	netSum += entry.AmountCents
}
if netSum != 0 {
	return ErrUnbalancedJournalTransaction
}') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-9', 'cs-11-payment-simulation', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-10', 'cs-11-payment-simulation', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-11', 'cs-11-payment-simulation', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-12', 'cs-11-payment-simulation', 12, 'deployment', '12. Deployment Strategy', 'Isolated VPC subnet, strict mTLS, PostgreSQL synchronous replication.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-13', 'cs-11-payment-simulation', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Using `UPDATE payments SET amount = ...` instead of append-only compensating refund entries; using `float64` for currency.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-11-payment-simulation-step-14', 'cs-11-payment-simulation', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-12-multitenant-saas', 12, 'cs-12-multitenant-saas', 'Multi-Tenant B2B SaaS Backend with Row-Level Security (RLS)', 'Advanced (Level 4, 6 & 8)', 'Shared-Schema Multi-Tenancy with PostgreSQL Row-Level Security (RLS) + Tenant Context Middleware', 'PostgreSQL 17/18 with `ENABLE ROW LEVEL SECURITY`', 'In B2B SaaS, forgetting `WHERE tenant_id = $1` on a single query leaks Customer A''s data to Customer B. Enabling PostgreSQL RLS (`USING (tenant_id = current_setting(''app.current_tenant_id'')::uuid)`) enforces tenant isolation at the database engine level as a defense-in-depth safety net.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-1', 'cs-12-multitenant-saas', 1, 'business_scenario', '1. Business Scenario', 'Isolate thousands of enterprise organizations with per-tenant RBAC, custom rate limits, and guaranteed zero cross-tenant data leakage.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-2', 'cs-12-multitenant-saas', 2, 'functional_reqs', '2. Functional Requirements', 'Middleware extracts verified `tenant_id` from JWT
Transaction wrapper sets `SET LOCAL app.current_tenant_id = ...`') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-3', 'cs-12-multitenant-saas', 3, 'non_functional_reqs', '3. Non-Functional Requirements', 'Defense-in-depth tenant isolation (Application filter + Postgres RLS policy)
Per-tenant rate limiting in Redis') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-4', 'cs-12-multitenant-saas', 4, 'architecture', '4. Architecture & Rationale', 'Shared-Schema Multi-Tenancy with PostgreSQL Row-Level Security (RLS) + Tenant Context Middleware — In B2B SaaS, forgetting `WHERE tenant_id = $1` on a single query leaks Customer A''s data to Customer B. Enabling PostgreSQL RLS (`USING (tenant_id = current_setting(''app.current_tenant_id'')::uuid)`) enforces tenant isolation at the database engine level as a defense-in-depth safety net.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-5', 'cs-12-multitenant-saas', 5, 'database_selection', '5. Database Selection', 'PostgreSQL 17/18 with `ENABLE ROW LEVEL SECURITY`') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-6', 'cs-12-multitenant-saas', 6, 'schema', '6. Production Schema', 'CREATE TABLE projects (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    name TEXT NOT NULL
);
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_policy ON projects
    USING (tenant_id = current_setting(''app.current_tenant_id'', true)::uuid);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-7', 'cs-12-multitenant-saas', 7, 'api_design', '7. API Endpoint Design', 'Middleware extracts verified `tenant_id` from JWT
Transaction wrapper sets `SET LOCAL app.current_tenant_id = ...`
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-8', 'cs-12-multitenant-saas', 8, 'go_implementation', '8. Go Implementation Pattern', '// SET LOCAL scopes the setting strictly to the current transaction so pooled connections never leak tenant_id!
if _, err := tx.ExecContext(ctx, "SELECT set_config(''app.current_tenant_id'', $1, true)", tenantID); err != nil {
	return err
}') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-9', 'cs-12-multitenant-saas', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-10', 'cs-12-multitenant-saas', 10, 'security', '10. Security Considerations', 'CRITICAL POSTGRESQL RLS NOTE: Table owners and superusers bypass Row-Level Security by default! Production deployment MUST: (1) run `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;` AND `ALTER TABLE ... FORCE ROW LEVEL SECURITY;`, (2) connect from the Go application using a dedicated non-superuser role created with `NOBYPASSRLS`, and (3) set the tenant context per transaction via `SELECT set_config(''app.current_tenant_id'', $1, true)` (`SET LOCAL`) so pooled connections never leak tenant state across requests.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-11', 'cs-12-multitenant-saas', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-12', 'cs-12-multitenant-saas', 12, 'deployment', '12. Deployment Strategy', 'Kubernetes + PgBouncer (Transaction Pooling compatible with `SET LOCAL`) + PostgreSQL.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-13', 'cs-12-multitenant-saas', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Using session-level `SET app.current_tenant_id` instead of transaction-local `SET LOCAL` (or `set_config(..., true)`), which leaks the tenant context to the next HTTP request reusing that connection from the pool!') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-12-multitenant-saas-step-14', 'cs-12-multitenant-saas', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-13-event-driven-orders', 13, 'cs-13-event-driven-orders', 'Event-Driven Distributed Order Processing System (Saga Orchestrator)', 'Advanced (Level 9)', 'Saga Pattern with Compensating Transactions + Transactional Outbox + Kafka', 'PostgreSQL per Microservice + Apache Kafka Event Backbone', 'When Order Service, Payment Service, and Warehouse Service own separate databases, distributed 2-Phase Commit (XA) destroys availability. A Saga coordinates local ACID transactions via Kafka events and executes explicit compensating actions (`RefundPayment`, `ReleaseStock`) if a downstream step fails.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-1', 'cs-13-event-driven-orders', 1, 'business_scenario', '1. Business Scenario', 'Coordinate OrderCreated -> StockReserved -> PaymentCaptured -> ShipmentScheduled, rolling back via compensating events if payment fails.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-2', 'cs-13-event-driven-orders', 2, 'functional_reqs', '2. Functional Requirements', 'Saga State Machine (`STARTED -> STOCK_RESERVED -> PAID -> COMPLETED` or `COMPENSATING -> CANCELED`)
Idempotent Kafka Consumer with `processed_events` table') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-3', 'cs-13-event-driven-orders', 3, 'non_functional_reqs', '3. Non-Functional Requirements', 'Eventual consistency convergence
At-least-once event delivery with idempotent handling') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-4', 'cs-13-event-driven-orders', 4, 'architecture', '4. Architecture & Rationale', 'Saga Pattern with Compensating Transactions + Transactional Outbox + Kafka — When Order Service, Payment Service, and Warehouse Service own separate databases, distributed 2-Phase Commit (XA) destroys availability. A Saga coordinates local ACID transactions via Kafka events and executes explicit compensating actions (`RefundPayment`, `ReleaseStock`) if a downstream step fails.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-5', 'cs-13-event-driven-orders', 5, 'database_selection', '5. Database Selection', 'PostgreSQL per Microservice + Apache Kafka Event Backbone') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-6', 'cs-13-event-driven-orders', 6, 'schema', '6. Production Schema', 'CREATE TABLE saga_instances (
    saga_id UUID PRIMARY KEY,
    order_id UUID NOT NULL UNIQUE,
    current_step VARCHAR(40) NOT NULL,
    status VARCHAR(24) NOT NULL,
    payload JSONB NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-7', 'cs-13-event-driven-orders', 7, 'api_design', '7. API Endpoint Design', 'Saga State Machine (`STARTED -> STOCK_RESERVED -> PAID -> COMPLETED` or `COMPENSATING -> CANCELED`)
Idempotent Kafka Consumer with `processed_events` table
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-8', 'cs-13-event-driven-orders', 8, 'go_implementation', '8. Go Implementation Pattern', '// Compensating transaction must also be idempotent and retried until acknowledged
switch event.Type {
case "PaymentFailed":
	return s.publishOutboxCommand(ctx, tx, "inventory.release_reservation", event.OrderID)
}') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-9', 'cs-13-event-driven-orders', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-10', 'cs-13-event-driven-orders', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-11', 'cs-13-event-driven-orders', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-12', 'cs-13-event-driven-orders', 12, 'deployment', '12. Deployment Strategy', 'Multi-service Kubernetes cluster + Kafka (3+ brokers, `acks=all`, `min.insync.replicas=2`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-13', 'cs-13-event-driven-orders', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Assuming compensating transactions never fail (compensations must be retried indefinitely with alerting if stuck) or forgetting that events can arrive out of order.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-13-event-driven-orders-step-14', 'cs-13-event-driven-orders', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_studies (id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale) VALUES ('cs-14-high-traffic-api', 14, 'cs-14-high-traffic-api', 'High-Traffic Low-Latency Public API Service (50,000+ RPS Architecture)', 'Advanced Professional (Level 2, 5, 9 & 10)', 'Multi-Tier Caching (In-Process L1 LRU + Redis L2 + Singleflight) + Zero-Alloc Hot Paths + Read Replicas', 'PostgreSQL Primary + Read Replicas + Redis Cluster + Go In-Memory L1 Cache', 'At 50,000+ RPS, even Redis network roundtrips add up. Combining a short-TTL (2s) in-process sharded L1 cache, a 60s Redis L2 cache guarded by `singleflight`, `pgx/v5` binary protocol, and `GOMEMLIMIT` tuning achieves sub-2ms p99 latency.') ON CONFLICT (id) DO UPDATE SET study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-1', 'cs-14-high-traffic-api', 1, 'business_scenario', '1. Business Scenario', 'Serve high-volume public catalog/metadata reads and bursty writes with strict SLA (<5ms p99 read latency, 99.99% availability).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-2', 'cs-14-high-traffic-api', 2, 'functional_reqs', '2. Functional Requirements', 'L1 in-memory cache -> L2 Redis -> Singleflight -> Postgres Read Replica
Token-bucket rate limiting per API key
OpenTelemetry + Prometheus `/metrics` + `net/http/pprof`') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-3', 'cs-14-high-traffic-api', 3, 'non_functional_reqs', '3. Non-Functional Requirements', '< 2 heap allocations per cache-hit request
Graceful load shedding when concurrency limit is exceeded') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-4', 'cs-14-high-traffic-api', 4, 'architecture', '4. Architecture & Rationale', 'Multi-Tier Caching (In-Process L1 LRU + Redis L2 + Singleflight) + Zero-Alloc Hot Paths + Read Replicas — At 50,000+ RPS, even Redis network roundtrips add up. Combining a short-TTL (2s) in-process sharded L1 cache, a 60s Redis L2 cache guarded by `singleflight`, `pgx/v5` binary protocol, and `GOMEMLIMIT` tuning achieves sub-2ms p99 latency.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-5', 'cs-14-high-traffic-api', 5, 'database_selection', '5. Database Selection', 'PostgreSQL Primary + Read Replicas + Redis Cluster + Go In-Memory L1 Cache') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-6', 'cs-14-high-traffic-api', 6, 'schema', '6. Production Schema', '-- Partitioned high-volume table with covering index for Index-Only Scans
CREATE INDEX idx_catalog_covering ON catalog_items (tenant_id, item_key) INCLUDE (payload_json, updated_at);') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-7', 'cs-14-high-traffic-api', 7, 'api_design', '7. API Endpoint Design', 'L1 in-memory cache -> L2 Redis -> Singleflight -> Postgres Read Replica
Token-bucket rate limiting per API key
OpenTelemetry + Prometheus `/metrics` + `net/http/pprof`
• Standard Error Envelope: RFC 9457 Problem Details JSON (`type`, `title`, `status`, `detail`, `instance`)
• Request Correlation: `X-Request-ID` & W3C `traceparent` headers') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-8', 'cs-14-high-traffic-api', 8, 'go_implementation', '8. Go Implementation Pattern', '// Load shedding middleware: fail fast with 503 + Retry-After rather than queueing 100k requests until OOM
select {
case sem <- struct{}{}:
	defer func() { <-sem }()
	next.ServeHTTP(w, r)
default:
	w.Header().Set("Retry-After", "2")
	http.Error(w, `{"error":"server busy, shedding load"}`, http.StatusServiceUnavailable)
}') ON CONFLICT DO NOTHING;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-9', 'cs-14-high-traffic-api', 9, 'testing', '9. Testing Strategy', '1) Table-driven unit tests (`t.Run`, `t.Parallel`) for pure domain invariants; 2) `httptest.NewServer` + real DB container (`testcontainers-go` or SQLite WAL) testing constraint violations and concurrent race conditions (`go test -race ./...`); 3) Fuzz testing (`go test -fuzz`) on request decoders.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-10', 'cs-14-high-traffic-api', 10, 'security', '10. Security Considerations', 'Enforce object-level ownership (`WHERE id = $1 AND user_id/tenant_id = $2` — OWASP API1:2023 BOLA), bound payload size via `http.MaxBytesReader` (OWASP API4:2023), use parameterized SQL queries exclusively, and validate outbound URLs in `net.Dialer.Control` (OWASP API7:2023 SSRF).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-11', 'cs-14-high-traffic-api', 11, 'performance', '11. Performance Considerations', 'Cover hot read paths with composite B-Tree/GIN indexes verified via `EXPLAIN (ANALYZE, BUFFERS)`; replace deep `OFFSET` with keyset cursor pagination; bound `*sql.DB` / `pgxpool` connection limits (`MaxOpenConns`, `MaxIdleConns`).') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-12', 'cs-14-high-traffic-api', 12, 'deployment', '12. Deployment Strategy', 'HPA-autoscaled Distroless Go pods, `GOMEMLIMIT` tuned, Envoy/Caddy edge proxy, Prometheus + Grafana + Tempo.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-13', 'cs-14-high-traffic-api', 13, 'common_mistakes', '13. Common Engineering Mistakes', 'Allowing unbounded request queueing during downstream slowdowns instead of bounded concurrency load shedding; leaving `net/http/pprof` exposed on the public internet port instead of an internal admin port.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO case_study_steps (id, case_study_id, step_number, section_key, title, content_text) VALUES ('cs-14-high-traffic-api-step-14', 'cs-14-high-traffic-api', 14, 'alternatives', '14. Alternative Implementations', 'Can start as an internal module inside a Modular Monolith using SQLite WAL (single-node) or PostgreSQL (multi-replica), and only extract into an independent gRPC/Kafka service if organizational boundaries or asymmetric scaling (>10,000 RPS) justify the operational overhead.') ON CONFLICT (id) DO UPDATE SET case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text;
INSERT INTO database_scenarios (id, scenario_number, title, recommended_stack, rationale, engines_comparison_json) VALUES ('scen-financial-tx', 1, '1. Double-Entry Financial Transactions & Wallet Ledger', 'PostgreSQL 17/18 (Primary) + Redis (Idempotency Key Cache)', 'Financial ledgers demand strict ACID atomicity, `CHECK (balance >= 0)` constraints, immutable double-entry journal rows, and `SELECT ... FOR UPDATE` or `SERIALIZABLE` isolation. PostgreSQL guarantees zero lost updates, while Redis caches short-lived `Idempotency-Key` locks.', '{"postgresql": {"schema": "CREATE TABLE accounts (\n    id UUID PRIMARY KEY,\n    owner_id UUID NOT NULL,\n    currency CHAR(3) NOT NULL,\n    balance_cents BIGINT NOT NULL CHECK (balance_cents >= 0),\n    version BIGINT NOT NULL DEFAULT 1,\n    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()\n);\nCREATE TABLE ledger_entries (\n    id UUID PRIMARY KEY,\n    transfer_id UUID NOT NULL,\n    account_id UUID NOT NULL REFERENCES accounts(id),\n    amount_cents BIGINT NOT NULL, -- negative for debit, positive for credit\n    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()\n);\nCREATE INDEX idx_ledger_account_created ON ledger_entries(account_id, created_at DESC);", "query": "-- Deterministic deadlock-free transfer inside ACID Transaction:\nBEGIN;\nSELECT id, balance_cents FROM accounts\nWHERE id IN ($1, $2) ORDER BY id ASC FOR UPDATE;\n\nUPDATE accounts SET balance_cents = balance_cents - $3, version = version + 1\nWHERE id = $1 AND balance_cents >= $3;\n\nUPDATE accounts SET balance_cents = balance_cents + $3, version = version + 1\nWHERE id = $2;\n\nINSERT INTO ledger_entries (id, transfer_id, account_id, amount_cents)\nVALUES ($4, $5, $1, -$3), ($6, $5, $2, $3);\nCOMMIT;", "indexStrategy": "Primary B-Tree on `accounts(id)` + Composite B-Tree on `ledger_entries(account_id, created_at DESC)` for statement history.", "txBehavior": "Pessimistic row-level lock (`FOR UPDATE` ordered by `id ASC` to prevent AB/BA deadlocks) + `CHECK (balance_cents >= 0)` constraint.", "opsComplexity": "Low-Medium (Managed RDS/CloudSQL or Patroni HA with synchronous standby)."}, "mysql": {"schema": "InnoDB tables with `BIGINT NOT NULL` for `balance_cents` (MySQL < 8.0.16 ignored CHECK constraints; MySQL 8.4 enforces them). Clustered PK on `id`.", "query": "Identical `START TRANSACTION; SELECT ... FOR UPDATE; UPDATE ...; COMMIT;` workflow using `?` positional placeholders.", "indexStrategy": "Clustered PK on `accounts(id)` (use UUIDv7 binary(16) or BIGINT to avoid page splits).", "txBehavior": "InnoDB defaults to `REPEATABLE READ`; `FOR UPDATE` acquires next-key/record locks on the clustered index.", "opsComplexity": "Low-Medium."}, "mariadb": {"schema": "-- MariaDB 11.4 (InnoDB + System-Versioned Temporal Audit Option)\nInnoDB tables with `BIGINT NOT NULL` for `balance_cents` (MySQL < 8.0.16 ignored CHECK constraints; MySQL 8.4 enforces them). Clustered PK on `id`.", "query": "Identical `START TRANSACTION; SELECT ... FOR UPDATE; UPDATE ...; COMMIT;` workflow using `?` positional placeholders.\n-- Optional MariaDB temporal query: SELECT * FROM tbl FOR SYSTEM_TIME AS OF TIMESTAMP ''2026-11-07 00:00:00'';", "indexStrategy": "Clustered PK on `accounts(id)` (use UUIDv7 binary(16) or BIGINT to avoid page splits). + MariaDB built-in thread pool for high connection counts.", "txBehavior": "InnoDB defaults to `REPEATABLE READ`; `FOR UPDATE` acquires next-key/record locks on the clustered index. (Supports Galera synchronous multi-primary clustering).", "opsComplexity": "Low-Medium."}, "sqlite": {"schema": "-- SQLite 3.40+ (WAL Mode: PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;)\n-- Suitable for single-node, embedded, CLI, or tenant-per-file workloads:\nCREATE TABLE accounts (\n    id TEXT PRIMARY KEY,\n    owner_id TEXT NOT NULL,\n    currency CHAR(3) NOT NULL,\n    balance_cents BIGINT NOT NULL CHECK (balance_cents >= 0),\n    version BIGINT NOT NULL DEFAULT 1,\n    updated_at TEXT NOT NULL DEFAULT NOW()\n);\nCREATE TABLE ledger_entries (\n    id TEXT PRIMARY KEY,\n    transfer_id TEXT NOT NULL,\n    account_id TEXT NOT NULL REFERENCES accounts(id),\n    amount_cents BIGINT NOT NULL, -- negative for debit, positive for credit\n    created_at TEXT NOT NULL DEFAULT NOW()\n);\nCREATE INDEX idx_ledger_account_created ON ledger_entries(account_id, created_at DESC);", "query": "-- Deterministic deadlock-free transfer inside ACID Transaction:\nBEGIN;\nSELECT id, balance_cents FROM accounts\nWHERE id IN (?1, ?2) ORDER BY id ASC FOR UPDATE;\n\nUPDATE accounts SET balance_cents = balance_cents - ?3, version = version + 1\nWHERE id = ?1 AND balance_cents >= ?3;\n\nUPDATE accounts SET balance_cents = balance_cents + ?3, version = version + 1\nWHERE id = ?2;\n\nINSERT INTO ledger_entries (id, transfer_id, account_id, amount_cents)\nVALUES ($4, $5, ?1, -?3), ($6, $5, ?2, ?3);\nCOMMIT;", "indexStrategy": "B-Tree indexes (`CREATE INDEX`) + FTS5 virtual tables where full-text search is needed.", "txBehavior": "`BEGIN IMMEDIATE` serializes writes safely with `PRAGMA busy_timeout = 5000`; unlimited concurrent WAL readers.", "opsComplexity": "Lowest (in-process library, zero network hop; avoid only when multi-node concurrent network writes are required)."}, "mongodb": {"schema": "Requires multi-document replica-set transactions (`session.WithTransaction`) across `accounts` and `ledger_entries` collections.", "query": "Higher lock contention and abort rate under concurrent hot-account updates compared to PostgreSQL/MySQL.", "indexStrategy": "Compound index `{ account_id: 1, created_at: -1 }`.", "txBehavior": "Multi-document snapshot transaction; aborts with `WriteConflict` if concurrent tx modifies same account.", "opsComplexity": "Medium-High for transactional ledgers (Not preferred over PostgreSQL)."}, "redis": {"schema": "Used ONLY for atomic `SET idempotency:{key} IN_PROGRESS NX EX 86400` lock before hitting PostgreSQL.", "query": "`SET idemp:tx_99182 \"LOCKED\" NX EX 3600`", "indexStrategy": "O(1) Hash table key lookup.", "txBehavior": "Single-threaded atomic command or Lua script, but NOT durable enough as sole primary financial ledger.", "opsComplexity": "Low (as companion idempotency cache)."}, "scylladb": {"schema": "-- ScyllaDB / Apache Cassandra CQL (Wide-Column LSM-Tree for 1. Double-Entry Financial Transactions & Wallet Ledger):\nCREATE KEYSPACE IF NOT EXISTS app_ks WITH replication = {''class'': ''NetworkTopologyStrategy'', ''replication_factor'': 3};\n-- Modeled strictly around Partition Key + Clustering Key access pattern:\nCREATE TABLE app_ks.records_by_partition (\n    partition_id uuid,\n    bucket_day text,\n    event_id timeuuid,\n    payload text,\n    PRIMARY KEY ((partition_id, bucket_day), event_id)\n) WITH CLUSTERING ORDER BY (event_id DESC);", "query": "SELECT partition_id, event_id, payload\nFROM app_ks.records_by_partition\nWHERE partition_id = ? AND bucket_day = ''2026-11-07''\nLIMIT 50;\n-- Executed with Consistency Level LOCAL_QUORUM (R + W > RF)", "indexStrategy": "Consistent-hash Partition Key `(partition_id, bucket_day)` routes directly to the owning replica shard in 1 hop; sorted on disk by Clustering Key `event_id DESC`.", "txBehavior": "Lock-free append-only CommitLog + Memtable -> SSTable compaction; no multi-partition ACID joins (Lightweight Transactions `IF NOT EXISTS` use Paxos/Raft at 4-RTT cost).", "opsComplexity": "Medium-High (Excels at massive multi-terabyte write streams & chat/audit logs; avoid for complex relational joins or multi-account ACID balance transfers)."}}') ON CONFLICT (id) DO UPDATE SET scenario_number = EXCLUDED.scenario_number, title = EXCLUDED.title, recommended_stack = EXCLUDED.recommended_stack, rationale = EXCLUDED.rationale, engines_comparison_json = EXCLUDED.engines_comparison_json;
INSERT INTO database_scenarios (id, scenario_number, title, recommended_stack, rationale, engines_comparison_json) VALUES ('scen-ecommerce-catalog', 2, '2. E-Commerce Product Catalog with Dynamic Polymorphic Attributes', 'PostgreSQL (Relational Core + JSONB + GIN Index) or MongoDB', 'Products share core transactional columns (`sku`, `price_cents`, `stock_count`) that participate in checkout joins, while category-specific attributes (shirt size/fabric vs laptop RAM/CPU) vary wildly. PostgreSQL with a `JSONB` column + `GIN` index handles both ACID inventory and dynamic attribute filtering in a single engine.', '{"postgresql": {"schema": "CREATE TABLE products (\n    id UUID PRIMARY KEY,\n    sku VARCHAR(64) NOT NULL UNIQUE,\n    name TEXT NOT NULL,\n    category VARCHAR(64) NOT NULL,\n    price_cents BIGINT NOT NULL CHECK (price_cents >= 0),\n    attributes JSONB NOT NULL DEFAULT ''{}''::jsonb,\n    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()\n);\nCREATE INDEX idx_products_cat_price ON products(category, price_cents);\nCREATE INDEX idx_products_attrs_gin ON products USING GIN (attributes jsonb_path_ops);", "query": "SELECT id, sku, name, price_cents, attributes\nFROM products\nWHERE category = ''laptops''\n  AND price_cents BETWEEN 50000 AND 200000\n  AND attributes @> ''{\"ram_gb\": 32, \"cpu\": \"M3\"}''::jsonb\nORDER BY price_cents ASC\nLIMIT 24;", "indexStrategy": "B-Tree on `(category, price_cents)` combined with `GIN (attributes jsonb_path_ops)` for containment (`@>`) queries.", "txBehavior": "ACID reads/writes; inventory decrements join cleanly in the same database.", "opsComplexity": "Low (single database engine)."}, "mysql": {"schema": "MySQL `JSON` column with virtual/stored generated columns indexed via B-Tree, or Multi-Valued Indexes.", "query": "Requires `JSON_CONTAINS` or indexing specific generated virtual columns (`ALTER TABLE ADD ram_gb INT GENERATED ALWAYS AS (attributes->>''$.ram_gb'')`).", "indexStrategy": "Functional B-Tree indexes on known JSON paths (less flexible than Postgres GIN for arbitrary keys).", "txBehavior": "ACID via InnoDB.", "opsComplexity": "Medium."}, "mariadb": {"schema": "-- MariaDB 11.4 (InnoDB + System-Versioned Temporal Audit Option)\nMySQL `JSON` column with virtual/stored generated columns indexed via B-Tree, or Multi-Valued Indexes.", "query": "Requires `JSON_CONTAINS` or indexing specific generated virtual columns (`ALTER TABLE ADD ram_gb INT GENERATED ALWAYS AS (attributes->>''$.ram_gb'')`).\n-- Optional MariaDB temporal query: SELECT * FROM tbl FOR SYSTEM_TIME AS OF TIMESTAMP ''2026-11-07 00:00:00'';", "indexStrategy": "Functional B-Tree indexes on known JSON paths (less flexible than Postgres GIN for arbitrary keys). + MariaDB built-in thread pool for high connection counts.", "txBehavior": "ACID via InnoDB. (Supports Galera synchronous multi-primary clustering).", "opsComplexity": "Medium."}, "sqlite": {"schema": "-- SQLite 3.40+ (WAL Mode: PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;)\n-- Suitable for single-node, embedded, CLI, or tenant-per-file workloads:\nCREATE TABLE products (\n    id TEXT PRIMARY KEY,\n    sku VARCHAR(64) NOT NULL UNIQUE,\n    name TEXT NOT NULL,\n    category VARCHAR(64) NOT NULL,\n    price_cents BIGINT NOT NULL CHECK (price_cents >= 0),\n    attributes TEXT NOT NULL DEFAULT ''{}''::jsonb,\n    created_at TEXT NOT NULL DEFAULT NOW()\n);\nCREATE INDEX idx_products_cat_price ON products(category, price_cents);\nCREATE INDEX idx_products_attrs_gin ON products USING GIN (attributes jsonb_path_ops);", "query": "SELECT id, sku, name, price_cents, attributes\nFROM products\nWHERE category = ''laptops''\n  AND price_cents BETWEEN 50000 AND 200000\n  AND attributes @> ''{\"ram_gb\": 32, \"cpu\": \"M3\"}''::jsonb\nORDER BY price_cents ASC\nLIMIT 24;", "indexStrategy": "B-Tree indexes (`CREATE INDEX`) + FTS5 virtual tables where full-text search is needed.", "txBehavior": "`BEGIN IMMEDIATE` serializes writes safely with `PRAGMA busy_timeout = 5000`; unlimited concurrent WAL readers.", "opsComplexity": "Lowest (in-process library, zero network hop; avoid only when multi-node concurrent network writes are required)."}, "mongodb": {"schema": "Collection `products` storing native BSON documents with embedded `attributes` sub-document and wildcard index `attributes.$**`.", "query": "`db.products.find({ category: ''laptops'', price_cents: { $gte: 50000, $lte: 200000 }, ''attributes.ram_gb'': 32 })`", "indexStrategy": "Compound index `{ category: 1, price_cents: 1 }` + Wildcard index `{ ''attributes.$**'': 1 }`.", "txBehavior": "Single-document atomic updates.", "opsComplexity": "Low-Medium (strong choice if catalog is decoupled from financial ledger)."}, "redis": {"schema": "Cache-aside JSON payload keyed by `product:sku:{sku}` with 5-minute jittered TTL + `singleflight` in Go.", "query": "`GET product:sku:LAP-992`", "indexStrategy": "Primary key cache lookup.", "txBehavior": "Read-through / cache-aside invalidation on product update.", "opsComplexity": "Low."}, "scylladb": {"schema": "-- ScyllaDB / Apache Cassandra CQL (Wide-Column LSM-Tree for 2. E-Commerce Product Catalog with Dynamic Polymorphic Attributes):\nCREATE KEYSPACE IF NOT EXISTS app_ks WITH replication = {''class'': ''NetworkTopologyStrategy'', ''replication_factor'': 3};\n-- Modeled strictly around Partition Key + Clustering Key access pattern:\nCREATE TABLE app_ks.records_by_partition (\n    partition_id uuid,\n    bucket_day text,\n    event_id timeuuid,\n    payload text,\n    PRIMARY KEY ((partition_id, bucket_day), event_id)\n) WITH CLUSTERING ORDER BY (event_id DESC);", "query": "SELECT partition_id, event_id, payload\nFROM app_ks.records_by_partition\nWHERE partition_id = ? AND bucket_day = ''2026-11-07''\nLIMIT 50;\n-- Executed with Consistency Level LOCAL_QUORUM (R + W > RF)", "indexStrategy": "Consistent-hash Partition Key `(partition_id, bucket_day)` routes directly to the owning replica shard in 1 hop; sorted on disk by Clustering Key `event_id DESC`.", "txBehavior": "Lock-free append-only CommitLog + Memtable -> SSTable compaction; no multi-partition ACID joins (Lightweight Transactions `IF NOT EXISTS` use Paxos/Raft at 4-RTT cost).", "opsComplexity": "Medium-High (Excels at massive multi-terabyte write streams & chat/audit logs; avoid for complex relational joins or multi-account ACID balance transfers)."}}') ON CONFLICT (id) DO UPDATE SET scenario_number = EXCLUDED.scenario_number, title = EXCLUDED.title, recommended_stack = EXCLUDED.recommended_stack, rationale = EXCLUDED.rationale, engines_comparison_json = EXCLUDED.engines_comparison_json;
INSERT INTO database_scenarios (id, scenario_number, title, recommended_stack, rationale, engines_comparison_json) VALUES ('scen-realtime-sessions-ratelimit', 3, '3. Real-Time User Sessions & Distributed Sliding-Window Rate Limiting', 'Redis 7.4 (Primary for Ephemeral State & Atomic Lua Rate Limiter)', 'Every authenticated API request checks rate limits and session revocation. Writing to disk-backed SQL on every request adds unnecessary I/O wear and latency; Redis executes atomic sliding-window or token-bucket Lua scripts in <0.15ms with automatic key expiration (`TTL`).', '{"postgresql": {"schema": "Unlogged table `CREATE UNLOGGED TABLE sessions (...)` skips WAL disk sync, but still incurs MVCC tuple churn and vacuum overhead on every request.", "query": "`SELECT user_id FROM sessions WHERE token_hash = $1 AND expires_at > NOW()`", "indexStrategy": "Hash or B-Tree index on `token_hash`.", "txBehavior": "High MVCC churn if updating `last_seen_at` on every API hit.", "opsComplexity": "Acceptable at <500 RPS; bottleneck at >10,000 RPS."}, "mysql": {"schema": "InnoDB session table; updates on every request cause heavy undo/redo log disk I/O.", "query": "`SELECT user_id FROM sessions WHERE id = ?`", "indexStrategy": "Clustered PK on `session_id`.", "txBehavior": "High write amplification for per-request rate-limit counters.", "opsComplexity": "Not recommended for high-frequency rate limiting."}, "mariadb": {"schema": "-- MariaDB 11.4 (InnoDB + System-Versioned Temporal Audit Option)\nInnoDB session table; updates on every request cause heavy undo/redo log disk I/O.", "query": "`SELECT user_id FROM sessions WHERE id = ?`\n-- Optional MariaDB temporal query: SELECT * FROM tbl FOR SYSTEM_TIME AS OF TIMESTAMP ''2026-11-07 00:00:00'';", "indexStrategy": "Clustered PK on `session_id`. + MariaDB built-in thread pool for high connection counts.", "txBehavior": "High write amplification for per-request rate-limit counters. (Supports Galera synchronous multi-primary clustering).", "opsComplexity": "Not recommended for high-frequency rate limiting."}, "sqlite": {"schema": "-- SQLite 3.40+ (WAL Mode: PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;)\n-- Suitable for single-node, embedded, CLI, or tenant-per-file workloads:\nUnlogged table `CREATE UNLOGGED TABLE sessions (...)` skips WAL disk sync, but still incurs MVCC tuple churn and vacuum overhead on every request.", "query": "`SELECT user_id FROM sessions WHERE token_hash = ?1 AND expires_at > NOW()`", "indexStrategy": "B-Tree indexes (`CREATE INDEX`) + FTS5 virtual tables where full-text search is needed.", "txBehavior": "`BEGIN IMMEDIATE` serializes writes safely with `PRAGMA busy_timeout = 5000`; unlimited concurrent WAL readers.", "opsComplexity": "Lowest (in-process library, zero network hop; avoid only when multi-node concurrent network writes are required)."}, "mongodb": {"schema": "Collection with TTL index `{ expires_at: 1 }, { expireAfterSeconds: 0 }`.", "query": "`db.sessions.findOne({ _id: tokenHash })`", "indexStrategy": "Background TTL monitor deletes expired documents every 60 seconds.", "txBehavior": "Document-level atomic `$inc` for counters, but slower than in-RAM Redis.", "opsComplexity": "Medium."}, "redis": {"schema": "Key `sess:{token_hash}` -> Hash `{ user_id, role, ip }` with `EX 3600`; Key `rl:{ip}:{window}` -> Atomic counter or Lua token bucket.", "query": "-- Atomic Lua Token Bucket / Sliding Window Rate Limiter in Redis:\nlocal current = redis.call(''INCR'', KEYS[1])\nif current == 1 then\n    redis.call(''PEXPIRE'', KEYS[1], ARGV[1])\nend\nreturn current", "indexStrategy": "In-memory O(1) hash slot lookup + active/lazy TTL expiration.", "txBehavior": "Lua script executes atomically on the single Redis command thread with zero race conditions.", "opsComplexity": "Low (ideal workload for Redis)."}, "scylladb": {"schema": "-- ScyllaDB / Apache Cassandra CQL (Wide-Column LSM-Tree for 3. Real-Time User Sessions & Distributed Sliding-Window Rate Limiting):\nCREATE KEYSPACE IF NOT EXISTS app_ks WITH replication = {''class'': ''NetworkTopologyStrategy'', ''replication_factor'': 3};\n-- Modeled strictly around Partition Key + Clustering Key access pattern:\nCREATE TABLE app_ks.records_by_partition (\n    partition_id uuid,\n    bucket_day text,\n    event_id timeuuid,\n    payload text,\n    PRIMARY KEY ((partition_id, bucket_day), event_id)\n) WITH CLUSTERING ORDER BY (event_id DESC);", "query": "SELECT partition_id, event_id, payload\nFROM app_ks.records_by_partition\nWHERE partition_id = ? AND bucket_day = ''2026-11-07''\nLIMIT 50;\n-- Executed with Consistency Level LOCAL_QUORUM (R + W > RF)", "indexStrategy": "Consistent-hash Partition Key `(partition_id, bucket_day)` routes directly to the owning replica shard in 1 hop; sorted on disk by Clustering Key `event_id DESC`.", "txBehavior": "Lock-free append-only CommitLog + Memtable -> SSTable compaction; no multi-partition ACID joins (Lightweight Transactions `IF NOT EXISTS` use Paxos/Raft at 4-RTT cost).", "opsComplexity": "Medium-High (Excels at massive multi-terabyte write streams & chat/audit logs; avoid for complex relational joins or multi-account ACID balance transfers)."}}') ON CONFLICT (id) DO UPDATE SET scenario_number = EXCLUDED.scenario_number, title = EXCLUDED.title, recommended_stack = EXCLUDED.recommended_stack, rationale = EXCLUDED.rationale, engines_comparison_json = EXCLUDED.engines_comparison_json;
INSERT INTO database_scenarios (id, scenario_number, title, recommended_stack, rationale, engines_comparison_json) VALUES ('scen-offline-edge-local', 4, '4. Offline-First CLI / Edge Appliance / Single-Node High-Read Service', 'SQLite 3.45+ (WAL Mode + modernc.org/sqlite)', 'When running an appliance, edge node, desktop agent, or single-VPS Go binary without multi-node write scaling requirements, embedded SQLite in WAL mode eliminates network latency (queries run in ~10µs) and requires zero external database containers.', '{"postgresql": {"schema": "Requires running and maintaining a separate PostgreSQL server process.", "query": "Standard SQL over TCP/Unix socket (~0.3\u20131.5ms overhead).", "indexStrategy": "Standard B-Tree.", "txBehavior": "Full MVCC.", "opsComplexity": "Higher than embedded SQLite for single-node/edge."}, "mysql": {"schema": "Requires separate mysqld daemon (~400MB+ RAM baseline).", "query": "Standard SQL over TCP.", "indexStrategy": "Clustered InnoDB.", "txBehavior": "Full ACID.", "opsComplexity": "Too heavy for embedded/CLI/edge."}, "mariadb": {"schema": "-- MariaDB 11.4 (InnoDB + System-Versioned Temporal Audit Option)\nRequires separate mysqld daemon (~400MB+ RAM baseline).", "query": "Standard SQL over TCP.\n-- Optional MariaDB temporal query: SELECT * FROM tbl FOR SYSTEM_TIME AS OF TIMESTAMP ''2026-11-07 00:00:00'';", "indexStrategy": "Clustered InnoDB. + MariaDB built-in thread pool for high connection counts.", "txBehavior": "Full ACID. (Supports Galera synchronous multi-primary clustering).", "opsComplexity": "Too heavy for embedded/CLI/edge."}, "sqlite": {"schema": "-- SQLite 3.40+ (WAL Mode: PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;)\n-- Suitable for single-node, embedded, CLI, or tenant-per-file workloads:\nRequires running and maintaining a separate PostgreSQL server process.", "query": "Standard SQL over TCP/Unix socket (~0.3\u20131.5ms overhead).", "indexStrategy": "B-Tree indexes (`CREATE INDEX`) + FTS5 virtual tables where full-text search is needed.", "txBehavior": "`BEGIN IMMEDIATE` serializes writes safely with `PRAGMA busy_timeout = 5000`; unlimited concurrent WAL readers.", "opsComplexity": "Lowest (in-process library, zero network hop; avoid only when multi-node concurrent network writes are required)."}, "mongodb": {"schema": "Requires separate mongod daemon.", "query": "BSON wire protocol.", "indexStrategy": "B-Tree.", "txBehavior": "WiredTiger.", "opsComplexity": "Not suitable for embedded single-binary tools."}, "redis": {"schema": "Requires separate redis-server process; lacks relational SQL joins.", "query": "RESP protocol.", "indexStrategy": "In-memory.", "txBehavior": "In-memory.", "opsComplexity": "Not suitable for standalone embedded relational persistence."}, "scylladb": {"schema": "-- ScyllaDB / Apache Cassandra CQL (Wide-Column LSM-Tree for 4. Offline-First CLI / Edge Appliance / Single-Node High-Read Service):\nCREATE KEYSPACE IF NOT EXISTS app_ks WITH replication = {''class'': ''NetworkTopologyStrategy'', ''replication_factor'': 3};\n-- Modeled strictly around Partition Key + Clustering Key access pattern:\nCREATE TABLE app_ks.records_by_partition (\n    partition_id uuid,\n    bucket_day text,\n    event_id timeuuid,\n    payload text,\n    PRIMARY KEY ((partition_id, bucket_day), event_id)\n) WITH CLUSTERING ORDER BY (event_id DESC);", "query": "SELECT partition_id, event_id, payload\nFROM app_ks.records_by_partition\nWHERE partition_id = ? AND bucket_day = ''2026-11-07''\nLIMIT 50;\n-- Executed with Consistency Level LOCAL_QUORUM (R + W > RF)", "indexStrategy": "Consistent-hash Partition Key `(partition_id, bucket_day)` routes directly to the owning replica shard in 1 hop; sorted on disk by Clustering Key `event_id DESC`.", "txBehavior": "Lock-free append-only CommitLog + Memtable -> SSTable compaction; no multi-partition ACID joins (Lightweight Transactions `IF NOT EXISTS` use Paxos/Raft at 4-RTT cost).", "opsComplexity": "Medium-High (Excels at massive multi-terabyte write streams & chat/audit logs; avoid for complex relational joins or multi-account ACID balance transfers)."}}') ON CONFLICT (id) DO UPDATE SET scenario_number = EXCLUDED.scenario_number, title = EXCLUDED.title, recommended_stack = EXCLUDED.recommended_stack, rationale = EXCLUDED.rationale, engines_comparison_json = EXCLUDED.engines_comparison_json;
INSERT INTO database_scenarios (id, scenario_number, title, recommended_stack, rationale, engines_comparison_json) VALUES ('scen-user-auth', 5, '5. User Authentication, Credentials & Refresh Token Families', 'PostgreSQL 17/18 (Primary Credentials & Token Families) + Redis (Brute-Force Rate Limit)', 'User identity, email uniqueness (case-insensitive `CITEXT` or lower-case functional index), and refresh-token reuse detection require strict ACID guarantees, while login rate-limiting belongs in Redis.', '{"postgresql": {"schema": "CREATE TABLE users (\n    id UUID PRIMARY KEY,\n    email TEXT NOT NULL,\n    password_hash TEXT NOT NULL,\n    mfa_secret BYTEA,\n    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()\n);\nCREATE UNIQUE INDEX idx_users_email_lower ON users (LOWER(email));", "query": "SELECT id, password_hash, mfa_secret FROM users WHERE LOWER(email) = LOWER($1);", "indexStrategy": "Unique expression B-Tree index on `LOWER(email)` prevents case-variant duplicate signups.", "txBehavior": "ACID registration + atomic refresh token family rotation.", "opsComplexity": "Low."}, "mysql": {"schema": "InnoDB table with `VARCHAR(255) COLLATE utf8mb4_0900_ai_ci UNIQUE` (case-insensitive collation by default).", "query": "`SELECT id, password_hash FROM users WHERE email = ?`", "indexStrategy": "Unique B+Tree index on `email`.", "txBehavior": "Full ACID.", "opsComplexity": "Low."}, "mariadb": {"schema": "-- MariaDB 11.4 (InnoDB + System-Versioned Temporal Audit Option)\nInnoDB table with `VARCHAR(255) COLLATE utf8mb4_0900_ai_ci UNIQUE` (case-insensitive collation by default).", "query": "`SELECT id, password_hash FROM users WHERE email = ?`\n-- Optional MariaDB temporal query: SELECT * FROM tbl FOR SYSTEM_TIME AS OF TIMESTAMP ''2026-11-07 00:00:00'';", "indexStrategy": "Unique B+Tree index on `email`. + MariaDB built-in thread pool for high connection counts.", "txBehavior": "Full ACID. (Supports Galera synchronous multi-primary clustering).", "opsComplexity": "Low."}, "sqlite": {"schema": "-- SQLite 3.40+ (WAL Mode: PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;)\n-- Suitable for single-node, embedded, CLI, or tenant-per-file workloads:\nCREATE TABLE users (\n    id TEXT PRIMARY KEY,\n    email TEXT NOT NULL,\n    password_hash TEXT NOT NULL,\n    mfa_secret BLOB,\n    created_at TEXT NOT NULL DEFAULT NOW()\n);\nCREATE UNIQUE INDEX idx_users_email_lower ON users (LOWER(email));", "query": "SELECT id, password_hash, mfa_secret FROM users WHERE LOWER(email) = LOWER(?1);", "indexStrategy": "B-Tree indexes (`CREATE INDEX`) + FTS5 virtual tables where full-text search is needed.", "txBehavior": "`BEGIN IMMEDIATE` serializes writes safely with `PRAGMA busy_timeout = 5000`; unlimited concurrent WAL readers.", "opsComplexity": "Lowest (in-process library, zero network hop; avoid only when multi-node concurrent network writes are required)."}, "mongodb": {"schema": "Collection `users` with unique case-insensitive collation index on `email`.", "query": "`db.users.findOne({ email: inputEmail })`", "indexStrategy": "Unique index with `{ locale: ''en'', strength: 2 }`.", "txBehavior": "Single-document atomic writes.", "opsComplexity": "Low-Medium."}, "redis": {"schema": "Counter `login_fail:{ip}:{email_hash}` with `EX 900` (15-min lockout window).", "query": "`INCR login_fail:203.0.113.5:a9f2...`", "indexStrategy": "O(1) key lookup.", "txBehavior": "Atomic increment + TTL.", "opsComplexity": "Low (companion rate limiter)."}, "scylladb": {"schema": "-- ScyllaDB / Apache Cassandra CQL (Wide-Column LSM-Tree for 5. User Authentication, Credentials & Refresh Token Families):\nCREATE KEYSPACE IF NOT EXISTS app_ks WITH replication = {''class'': ''NetworkTopologyStrategy'', ''replication_factor'': 3};\n-- Modeled strictly around Partition Key + Clustering Key access pattern:\nCREATE TABLE app_ks.records_by_partition (\n    partition_id uuid,\n    bucket_day text,\n    event_id timeuuid,\n    payload text,\n    PRIMARY KEY ((partition_id, bucket_day), event_id)\n) WITH CLUSTERING ORDER BY (event_id DESC);", "query": "SELECT partition_id, event_id, payload\nFROM app_ks.records_by_partition\nWHERE partition_id = ? AND bucket_day = ''2026-11-07''\nLIMIT 50;\n-- Executed with Consistency Level LOCAL_QUORUM (R + W > RF)", "indexStrategy": "Consistent-hash Partition Key `(partition_id, bucket_day)` routes directly to the owning replica shard in 1 hop; sorted on disk by Clustering Key `event_id DESC`.", "txBehavior": "Lock-free append-only CommitLog + Memtable -> SSTable compaction; no multi-partition ACID joins (Lightweight Transactions `IF NOT EXISTS` use Paxos/Raft at 4-RTT cost).", "opsComplexity": "Medium-High (Excels at massive multi-terabyte write streams & chat/audit logs; avoid for complex relational joins or multi-account ACID balance transfers)."}}') ON CONFLICT (id) DO UPDATE SET scenario_number = EXCLUDED.scenario_number, title = EXCLUDED.title, recommended_stack = EXCLUDED.recommended_stack, rationale = EXCLUDED.rationale, engines_comparison_json = EXCLUDED.engines_comparison_json;
INSERT INTO database_scenarios (id, scenario_number, title, recommended_stack, rationale, engines_comparison_json) VALUES ('scen-analytics-olap', 6, '6. Time-Series & Product Analytics Aggregations', 'PostgreSQL (Declarative Range Partitioning + BRIN Index) or ClickHouse/Timescale', 'Append-only event streams sorted by timestamp benefit enormously from monthly/daily table partitioning and Block Range Indexes (`BRIN`), which are 1000x smaller than B-Tree indexes on monotonically increasing timestamps.', '{"postgresql": {"schema": "CREATE TABLE api_events (\n    event_time TIMESTAMPTZ NOT NULL,\n    tenant_id UUID NOT NULL,\n    endpoint TEXT NOT NULL,\n    status_code SMALLINT NOT NULL,\n    duration_ms INTEGER NOT NULL\n) PARTITION BY RANGE (event_time);\n\nCREATE INDEX idx_api_events_brin ON api_events USING BRIN (event_time);", "query": "SELECT endpoint,\n       COUNT(*) AS req_count,\n       PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY duration_ms) AS p99_ms\nFROM api_events\nWHERE event_time >= NOW() - INTERVAL ''24 hours'' AND tenant_id = $1\nGROUP BY endpoint;", "indexStrategy": "BRIN index on `event_time` (stores min/max per 128-page block range, <1MB size) + Partition pruning.", "txBehavior": "Batched append via `pgx.CopyFrom` (100k rows/sec).", "opsComplexity": "Low-Medium (`pg_partman` drops expired partitions instantly via `DROP TABLE` rather than slow `DELETE` + `VACUUM`)."}, "mysql": {"schema": "InnoDB range-partitioned table by `TO_DAYS(event_time)`.", "query": "Standard `GROUP BY` (lacks native BRIN index and `PERCENTILE_CONT` aggregate without window workarounds).", "indexStrategy": "Clustered composite PK `(event_time, id)`.", "txBehavior": "Batched multi-row `INSERT`.", "opsComplexity": "Medium."}, "mariadb": {"schema": "-- MariaDB 11.4 (InnoDB + System-Versioned Temporal Audit Option)\nInnoDB range-partitioned table by `TO_DAYS(event_time)`.", "query": "Standard `GROUP BY` (lacks native BRIN index and `PERCENTILE_CONT` aggregate without window workarounds).\n-- Optional MariaDB temporal query: SELECT * FROM tbl FOR SYSTEM_TIME AS OF TIMESTAMP ''2026-11-07 00:00:00'';", "indexStrategy": "Clustered composite PK `(event_time, id)`. + MariaDB built-in thread pool for high connection counts.", "txBehavior": "Batched multi-row `INSERT`. (Supports Galera synchronous multi-primary clustering).", "opsComplexity": "Medium."}, "sqlite": {"schema": "-- SQLite 3.40+ (WAL Mode: PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;)\n-- Suitable for single-node, embedded, CLI, or tenant-per-file workloads:\nCREATE TABLE api_events (\n    event_time TEXT NOT NULL,\n    tenant_id TEXT NOT NULL,\n    endpoint TEXT NOT NULL,\n    status_code SMALLINT NOT NULL,\n    duration_ms INTEGER NOT NULL\n) PARTITION BY RANGE (event_time);\n\nCREATE INDEX idx_api_events_brin ON api_events USING BRIN (event_time);", "query": "SELECT endpoint,\n       COUNT(*) AS req_count,\n       PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY duration_ms) AS p99_ms\nFROM api_events\nWHERE event_time >= NOW() - INTERVAL ''24 hours'' AND tenant_id = ?1\nGROUP BY endpoint;", "indexStrategy": "B-Tree indexes (`CREATE INDEX`) + FTS5 virtual tables where full-text search is needed.", "txBehavior": "`BEGIN IMMEDIATE` serializes writes safely with `PRAGMA busy_timeout = 5000`; unlimited concurrent WAL readers.", "opsComplexity": "Lowest (in-process library, zero network hop; avoid only when multi-node concurrent network writes are required)."}, "mongodb": {"schema": "MongoDB Time-Series Collection (`timeseries: { timeField: ''event_time'', metaField: ''tenant_id'' }`).", "query": "Aggregation pipeline `$match` -> `$group`.", "indexStrategy": "Columnar bucket compression under the hood.", "txBehavior": "Batched `insertMany({ ordered: false })`.", "opsComplexity": "Medium."}, "redis": {"schema": "HyperLogLog (`PFADD`/`PFCOUNT`) for unique daily active user cardinality in 12KB RAM.", "query": "`PFADD dau:2026-11-07 user_8821` / `PFCOUNT dau:2026-11-07`", "indexStrategy": "Probabilistic HyperLogLog register (0.81% standard error).", "txBehavior": "Real-time counter approximation.", "opsComplexity": "Low."}, "scylladb": {"schema": "-- ScyllaDB / Apache Cassandra CQL (Wide-Column LSM-Tree for 6. Time-Series & Product Analytics Aggregations):\nCREATE KEYSPACE IF NOT EXISTS app_ks WITH replication = {''class'': ''NetworkTopologyStrategy'', ''replication_factor'': 3};\n-- Modeled strictly around Partition Key + Clustering Key access pattern:\nCREATE TABLE app_ks.records_by_partition (\n    partition_id uuid,\n    bucket_day text,\n    event_id timeuuid,\n    payload text,\n    PRIMARY KEY ((partition_id, bucket_day), event_id)\n) WITH CLUSTERING ORDER BY (event_id DESC);", "query": "SELECT partition_id, event_id, payload\nFROM app_ks.records_by_partition\nWHERE partition_id = ? AND bucket_day = ''2026-11-07''\nLIMIT 50;\n-- Executed with Consistency Level LOCAL_QUORUM (R + W > RF)", "indexStrategy": "Consistent-hash Partition Key `(partition_id, bucket_day)` routes directly to the owning replica shard in 1 hop; sorted on disk by Clustering Key `event_id DESC`.", "txBehavior": "Lock-free append-only CommitLog + Memtable -> SSTable compaction; no multi-partition ACID joins (Lightweight Transactions `IF NOT EXISTS` use Paxos/Raft at 4-RTT cost).", "opsComplexity": "Medium-High (Excels at massive multi-terabyte write streams & chat/audit logs; avoid for complex relational joins or multi-account ACID balance transfers)."}}') ON CONFLICT (id) DO UPDATE SET scenario_number = EXCLUDED.scenario_number, title = EXCLUDED.title, recommended_stack = EXCLUDED.recommended_stack, rationale = EXCLUDED.rationale, engines_comparison_json = EXCLUDED.engines_comparison_json;
INSERT INTO database_scenarios (id, scenario_number, title, recommended_stack, rationale, engines_comparison_json) VALUES ('scen-caching-layer', 7, '7. High-Throughput Read-Through & Cache-Aside Layer', 'Redis 7.4 + Go `singleflight` (In-Process Stampede Protection)', 'Sub-millisecond key-value lookups, TTL eviction (`allkeys-lru` / `volatile-lfu`), and pipeline batching (`MGET`) make Redis the industry standard L2 cache.', '{"postgresql": {"schema": "Acts as durable L3 backing store when Redis misses.", "query": "`SELECT payload FROM catalog WHERE id = $1`", "indexStrategy": "Primary Key B-Tree.", "txBehavior": "Read Committed.", "opsComplexity": "Protected from stampedes by Go `singleflight`."}, "mysql": {"schema": "Durable L3 backing store.", "query": "`SELECT payload FROM catalog WHERE id = ?`", "indexStrategy": "Clustered PK.", "txBehavior": "Read Committed / Repeatable Read.", "opsComplexity": "Standard."}, "mariadb": {"schema": "-- MariaDB 11.4 (InnoDB + System-Versioned Temporal Audit Option)\nDurable L3 backing store.", "query": "`SELECT payload FROM catalog WHERE id = ?`\n-- Optional MariaDB temporal query: SELECT * FROM tbl FOR SYSTEM_TIME AS OF TIMESTAMP ''2026-11-07 00:00:00'';", "indexStrategy": "Clustered PK. + MariaDB built-in thread pool for high connection counts.", "txBehavior": "Read Committed / Repeatable Read. (Supports Galera synchronous multi-primary clustering).", "opsComplexity": "Standard."}, "sqlite": {"schema": "-- SQLite 3.40+ (WAL Mode: PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;)\n-- Suitable for single-node, embedded, CLI, or tenant-per-file workloads:\nActs as durable L3 backing store when Redis misses.", "query": "`SELECT payload FROM catalog WHERE id = ?1`", "indexStrategy": "B-Tree indexes (`CREATE INDEX`) + FTS5 virtual tables where full-text search is needed.", "txBehavior": "`BEGIN IMMEDIATE` serializes writes safely with `PRAGMA busy_timeout = 5000`; unlimited concurrent WAL readers.", "opsComplexity": "Lowest (in-process library, zero network hop; avoid only when multi-node concurrent network writes are required)."}, "mongodb": {"schema": "WiredTiger in-memory cache serves hot documents, but network/BSON overhead exceeds Redis.", "query": "`db.catalog.findOne({ _id: id })`", "indexStrategy": "`_id` B-Tree.", "txBehavior": "Read local.", "opsComplexity": "Medium."}, "redis": {"schema": "String/Hash keys with jittered TTL: `SET cache:item:{id} {bytes} EX (300 + rand(30))`.", "query": "`MGET cache:item:1 cache:item:2 cache:item:3`", "indexStrategy": "In-memory hash table.", "txBehavior": "Paired with Go `singleflight.Group` to prevent cache stampede on hot key expiration.", "opsComplexity": "Low."}, "scylladb": {"schema": "-- ScyllaDB / Apache Cassandra CQL (Wide-Column LSM-Tree for 7. High-Throughput Read-Through & Cache-Aside Layer):\nCREATE KEYSPACE IF NOT EXISTS app_ks WITH replication = {''class'': ''NetworkTopologyStrategy'', ''replication_factor'': 3};\n-- Modeled strictly around Partition Key + Clustering Key access pattern:\nCREATE TABLE app_ks.records_by_partition (\n    partition_id uuid,\n    bucket_day text,\n    event_id timeuuid,\n    payload text,\n    PRIMARY KEY ((partition_id, bucket_day), event_id)\n) WITH CLUSTERING ORDER BY (event_id DESC);", "query": "SELECT partition_id, event_id, payload\nFROM app_ks.records_by_partition\nWHERE partition_id = ? AND bucket_day = ''2026-11-07''\nLIMIT 50;\n-- Executed with Consistency Level LOCAL_QUORUM (R + W > RF)", "indexStrategy": "Consistent-hash Partition Key `(partition_id, bucket_day)` routes directly to the owning replica shard in 1 hop; sorted on disk by Clustering Key `event_id DESC`.", "txBehavior": "Lock-free append-only CommitLog + Memtable -> SSTable compaction; no multi-partition ACID joins (Lightweight Transactions `IF NOT EXISTS` use Paxos/Raft at 4-RTT cost).", "opsComplexity": "Medium-High (Excels at massive multi-terabyte write streams & chat/audit logs; avoid for complex relational joins or multi-account ACID balance transfers)."}}') ON CONFLICT (id) DO UPDATE SET scenario_number = EXCLUDED.scenario_number, title = EXCLUDED.title, recommended_stack = EXCLUDED.recommended_stack, rationale = EXCLUDED.rationale, engines_comparison_json = EXCLUDED.engines_comparison_json;
INSERT INTO database_scenarios (id, scenario_number, title, recommended_stack, rationale, engines_comparison_json) VALUES ('scen-inventory-management', 8, '8. High-Contention Inventory Reservation & Stock Ledger', 'PostgreSQL / MySQL (Atomic Conditional `UPDATE` + Reservation Holds) + Redis (Flash Gate)', 'Inventory requires strict non-negative invariants (`available_qty >= 0`) and time-bounded cart reservation rows so abandoned carts automatically return stock.', '{"postgresql": {"schema": "CREATE TABLE sku_stock (\n    sku VARCHAR(64) PRIMARY KEY,\n    available INTEGER NOT NULL CHECK (available >= 0),\n    reserved INTEGER NOT NULL CHECK (reserved >= 0)\n);", "query": "UPDATE sku_stock SET available = available - $1, reserved = reserved + $1\nWHERE sku = $2 AND available >= $1 RETURNING available;", "indexStrategy": "Primary Key on `sku`.", "txBehavior": "Row-level exclusive lock on the updated SKU tuple; atomic predicate prevents negative stock.", "opsComplexity": "Low."}, "mysql": {"schema": "InnoDB table with `UNSIGNED INT` (`available INT UNSIGNED NOT NULL`).", "query": "`UPDATE sku_stock SET available = available - ?, reserved = reserved + ? WHERE sku = ? AND available >= ?`", "indexStrategy": "Clustered PK on `sku`.", "txBehavior": "InnoDB row lock + `RowsAffected() == 1` check.", "opsComplexity": "Low."}, "mariadb": {"schema": "-- MariaDB 11.4 (InnoDB + System-Versioned Temporal Audit Option)\nInnoDB table with `UNSIGNED INT` (`available INT UNSIGNED NOT NULL`).", "query": "`UPDATE sku_stock SET available = available - ?, reserved = reserved + ? WHERE sku = ? AND available >= ?`\n-- Optional MariaDB temporal query: SELECT * FROM tbl FOR SYSTEM_TIME AS OF TIMESTAMP ''2026-11-07 00:00:00'';", "indexStrategy": "Clustered PK on `sku`. + MariaDB built-in thread pool for high connection counts.", "txBehavior": "InnoDB row lock + `RowsAffected() == 1` check. (Supports Galera synchronous multi-primary clustering).", "opsComplexity": "Low."}, "sqlite": {"schema": "-- SQLite 3.40+ (WAL Mode: PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;)\n-- Suitable for single-node, embedded, CLI, or tenant-per-file workloads:\nCREATE TABLE sku_stock (\n    sku VARCHAR(64) PRIMARY KEY,\n    available INTEGER NOT NULL CHECK (available >= 0),\n    reserved INTEGER NOT NULL CHECK (reserved >= 0)\n);", "query": "UPDATE sku_stock SET available = available - ?1, reserved = reserved + ?1\nWHERE sku = ?2 AND available >= ?1 RETURNING available;", "indexStrategy": "B-Tree indexes (`CREATE INDEX`) + FTS5 virtual tables where full-text search is needed.", "txBehavior": "`BEGIN IMMEDIATE` serializes writes safely with `PRAGMA busy_timeout = 5000`; unlimited concurrent WAL readers.", "opsComplexity": "Lowest (in-process library, zero network hop; avoid only when multi-node concurrent network writes are required)."}, "mongodb": {"schema": "Single document per SKU using `$inc` with filter predicate.", "query": "`db.sku_stock.updateOne({ _id: sku, available: { $gte: qty } }, { $inc: { available: -qty, reserved: qty } })`", "indexStrategy": "`_id` index.", "txBehavior": "Atomic single-document conditional update.", "opsComplexity": "Low-Medium."}, "redis": {"schema": "Lua script pre-decrementing `stock:{sku}` before forwarding winning requests to SQL.", "query": "`if tonumber(redis.call(''GET'', KEYS[1])) >= tonumber(ARGV[1]) then return redis.call(''DECRBY'', KEYS[1], ARGV[1]) else return -1 end`", "indexStrategy": "In-RAM key.", "txBehavior": "Absorbs 99% of rejected ''sold out'' traffic during flash sales.", "opsComplexity": "Low."}, "scylladb": {"schema": "-- ScyllaDB / Apache Cassandra CQL (Wide-Column LSM-Tree for 8. High-Contention Inventory Reservation & Stock Ledger):\nCREATE KEYSPACE IF NOT EXISTS app_ks WITH replication = {''class'': ''NetworkTopologyStrategy'', ''replication_factor'': 3};\n-- Modeled strictly around Partition Key + Clustering Key access pattern:\nCREATE TABLE app_ks.records_by_partition (\n    partition_id uuid,\n    bucket_day text,\n    event_id timeuuid,\n    payload text,\n    PRIMARY KEY ((partition_id, bucket_day), event_id)\n) WITH CLUSTERING ORDER BY (event_id DESC);", "query": "SELECT partition_id, event_id, payload\nFROM app_ks.records_by_partition\nWHERE partition_id = ? AND bucket_day = ''2026-11-07''\nLIMIT 50;\n-- Executed with Consistency Level LOCAL_QUORUM (R + W > RF)", "indexStrategy": "Consistent-hash Partition Key `(partition_id, bucket_day)` routes directly to the owning replica shard in 1 hop; sorted on disk by Clustering Key `event_id DESC`.", "txBehavior": "Lock-free append-only CommitLog + Memtable -> SSTable compaction; no multi-partition ACID joins (Lightweight Transactions `IF NOT EXISTS` use Paxos/Raft at 4-RTT cost).", "opsComplexity": "Medium-High (Excels at massive multi-terabyte write streams & chat/audit logs; avoid for complex relational joins or multi-account ACID balance transfers)."}}') ON CONFLICT (id) DO UPDATE SET scenario_number = EXCLUDED.scenario_number, title = EXCLUDED.title, recommended_stack = EXCLUDED.recommended_stack, rationale = EXCLUDED.rationale, engines_comparison_json = EXCLUDED.engines_comparison_json;
INSERT INTO database_scenarios (id, scenario_number, title, recommended_stack, rationale, engines_comparison_json) VALUES ('scen-event-storage', 9, '9. Immutable Audit Log, Transactional Outbox & Event Sourcing Store', 'PostgreSQL (Transactional Outbox + Partitioned Event Log) or ScyllaDB (Multi-TB Scale)', 'Outbox events MUST live in the same transactional database as the domain aggregate so they commit atomically. For multi-terabyte long-term event retention, stream outbox events to Kafka -> ScyllaDB.', '{"postgresql": {"schema": "CREATE TABLE outbox_events (\n    id UUID PRIMARY KEY,\n    aggregate_type VARCHAR(64) NOT NULL,\n    aggregate_id UUID NOT NULL,\n    event_type VARCHAR(64) NOT NULL,\n    payload JSONB NOT NULL,\n    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),\n    published_at TIMESTAMPTZ\n);\nCREATE INDEX idx_outbox_unpublished ON outbox_events (created_at ASC) WHERE published_at IS NULL;", "query": "SELECT id, event_type, payload FROM outbox_events\nWHERE published_at IS NULL\nORDER BY created_at ASC LIMIT 100\nFOR UPDATE SKIP LOCKED;", "indexStrategy": "Partial B-Tree Index (`WHERE published_at IS NULL`) keeps the index tiny even when the table has 50M historical rows!", "txBehavior": "`FOR UPDATE SKIP LOCKED` lets 10 concurrent Go relay workers poll the outbox with zero lock waiting.", "opsComplexity": "Low."}, "mysql": {"schema": "InnoDB `outbox_events` table indexed on `(published_at, created_at)` (MySQL lacks partial `WHERE` indexes).", "query": "`SELECT id, payload FROM outbox_events WHERE published_at IS NULL ORDER BY created_at LIMIT 100 FOR UPDATE SKIP LOCKED` (supported in MySQL 8.0+).", "indexStrategy": "Composite B+Tree on `(published_at, created_at)`.", "txBehavior": "`FOR UPDATE SKIP LOCKED` supported in InnoDB 8.0+.", "opsComplexity": "Low-Medium."}, "mariadb": {"schema": "-- MariaDB 11.4 (InnoDB + System-Versioned Temporal Audit Option)\nInnoDB `outbox_events` table indexed on `(published_at, created_at)` (MySQL lacks partial `WHERE` indexes).", "query": "`SELECT id, payload FROM outbox_events WHERE published_at IS NULL ORDER BY created_at LIMIT 100 FOR UPDATE SKIP LOCKED` (supported in MySQL 8.0+).\n-- Optional MariaDB temporal query: SELECT * FROM tbl FOR SYSTEM_TIME AS OF TIMESTAMP ''2026-11-07 00:00:00'';", "indexStrategy": "Composite B+Tree on `(published_at, created_at)`. + MariaDB built-in thread pool for high connection counts.", "txBehavior": "`FOR UPDATE SKIP LOCKED` supported in InnoDB 8.0+. (Supports Galera synchronous multi-primary clustering).", "opsComplexity": "Low-Medium."}, "sqlite": {"schema": "-- SQLite 3.40+ (WAL Mode: PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;)\n-- Suitable for single-node, embedded, CLI, or tenant-per-file workloads:\nCREATE TABLE outbox_events (\n    id TEXT PRIMARY KEY,\n    aggregate_type VARCHAR(64) NOT NULL,\n    aggregate_id TEXT NOT NULL,\n    event_type VARCHAR(64) NOT NULL,\n    payload TEXT NOT NULL,\n    created_at TEXT NOT NULL DEFAULT NOW(),\n    published_at TEXT\n);\nCREATE INDEX idx_outbox_unpublished ON outbox_events (created_at ASC) WHERE published_at IS NULL;", "query": "SELECT id, event_type, payload FROM outbox_events\nWHERE published_at IS NULL\nORDER BY created_at ASC LIMIT 100\nFOR UPDATE SKIP LOCKED;", "indexStrategy": "B-Tree indexes (`CREATE INDEX`) + FTS5 virtual tables where full-text search is needed.", "txBehavior": "`BEGIN IMMEDIATE` serializes writes safely with `PRAGMA busy_timeout = 5000`; unlimited concurrent WAL readers.", "opsComplexity": "Lowest (in-process library, zero network hop; avoid only when multi-node concurrent network writes are required)."}, "mongodb": {"schema": "Change Streams (`collection.Watch(ctx, pipeline)`) tailing the replica set oplog.", "query": "Go driver `watchCursor.Next(ctx)`.", "indexStrategy": "Backed by replica set oplog.", "txBehavior": "At-least-once resume tokens via Change Streams.", "opsComplexity": "Medium."}, "redis": {"schema": "Redis Streams (`XADD` / `XREADGROUP` / `XACK`) for lightweight consumer groups.", "query": "`XADD orders_stream MAXLEN ~ 100000 * event OrderCreated payload {...}`", "indexStrategy": "Radix-tree macro-nodes in RAM.", "txBehavior": "Fast consumer groups, but cannot share an ACID transaction with PostgreSQL.", "opsComplexity": "Low."}, "scylladb": {"schema": "-- ScyllaDB / Apache Cassandra CQL (Wide-Column LSM-Tree for 9. Immutable Audit Log, Transactional Outbox & Event Sourcing Store):\nCREATE KEYSPACE IF NOT EXISTS app_ks WITH replication = {''class'': ''NetworkTopologyStrategy'', ''replication_factor'': 3};\n-- Modeled strictly around Partition Key + Clustering Key access pattern:\nCREATE TABLE app_ks.records_by_partition (\n    partition_id uuid,\n    bucket_day text,\n    event_id timeuuid,\n    payload text,\n    PRIMARY KEY ((partition_id, bucket_day), event_id)\n) WITH CLUSTERING ORDER BY (event_id DESC);", "query": "SELECT partition_id, event_id, payload\nFROM app_ks.records_by_partition\nWHERE partition_id = ? AND bucket_day = ''2026-11-07''\nLIMIT 50;\n-- Executed with Consistency Level LOCAL_QUORUM (R + W > RF)", "indexStrategy": "Consistent-hash Partition Key `(partition_id, bucket_day)` routes directly to the owning replica shard in 1 hop; sorted on disk by Clustering Key `event_id DESC`.", "txBehavior": "Lock-free append-only CommitLog + Memtable -> SSTable compaction; no multi-partition ACID joins (Lightweight Transactions `IF NOT EXISTS` use Paxos/Raft at 4-RTT cost).", "opsComplexity": "Medium-High (Excels at massive multi-terabyte write streams & chat/audit logs; avoid for complex relational joins or multi-account ACID balance transfers)."}}') ON CONFLICT (id) DO UPDATE SET scenario_number = EXCLUDED.scenario_number, title = EXCLUDED.title, recommended_stack = EXCLUDED.recommended_stack, rationale = EXCLUDED.rationale, engines_comparison_json = EXCLUDED.engines_comparison_json;
INSERT INTO database_scenarios (id, scenario_number, title, recommended_stack, rationale, engines_comparison_json) VALUES ('scen-audit-logs', 10, '10. Tamper-Evident Security & Compliance Audit Logs (SOC2 / HIPAA)', 'PostgreSQL (Append-Only Partitioned Table + Hash Chain + REVOKE UPDATE/DELETE) or ScyllaDB', 'Compliance audit logs (`who did what to which resource when`) must be immutable, time-partitioned for retention policies (e.g. keep 7 years, drop old partitions without VACUUM bloat), and cryptographically hash-chained (`prev_hash || row_data`) to detect tampering.', '{"postgresql": {"schema": "CREATE TABLE security_audit_logs (\n    id UUID NOT NULL,\n    occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),\n    actor_id UUID NOT NULL,\n    tenant_id UUID NOT NULL,\n    action VARCHAR(80) NOT NULL,\n    target_resource TEXT NOT NULL,\n    prev_hash BYTEA NOT NULL,\n    entry_hash BYTEA NOT NULL,\n    PRIMARY KEY (occurred_at, id)\n) PARTITION BY RANGE (occurred_at);\n\n-- App role can ONLY INSERT and SELECT (never UPDATE or DELETE audit history!)\nREVOKE UPDATE, DELETE, TRUNCATE ON security_audit_logs FROM app_service_user;", "query": "SELECT occurred_at, actor_id, action, target_resource, encode(entry_hash, ''hex'')\nFROM security_audit_logs\nWHERE tenant_id = $1 AND occurred_at >= NOW() - INTERVAL ''30 days''\nORDER BY occurred_at DESC LIMIT 100;", "indexStrategy": "Range partitioning by month + BRIN index on `occurred_at` + B-Tree on `(tenant_id, occurred_at DESC)`.", "txBehavior": "Append-only `INSERT` privilege enforced at PostgreSQL role level (`REVOKE UPDATE, DELETE`).", "opsComplexity": "Low (monthly partitions archived to cold S3 Parquet before `DETACH PARTITION`)."}, "mysql": {"schema": "InnoDB range-partitioned table with `REVOKE UPDATE, DELETE` on application DB user.", "query": "`SELECT * FROM security_audit_logs WHERE tenant_id = ? AND occurred_at >= ? ORDER BY occurred_at DESC LIMIT 100`", "indexStrategy": "Clustered composite PK `(occurred_at, id)` + secondary `(tenant_id, occurred_at)`.", "txBehavior": "Append-only.", "opsComplexity": "Low-Medium."}, "mariadb": {"schema": "-- MariaDB 11.4 (InnoDB + System-Versioned Temporal Audit Option)\nInnoDB range-partitioned table with `REVOKE UPDATE, DELETE` on application DB user.", "query": "`SELECT * FROM security_audit_logs WHERE tenant_id = ? AND occurred_at >= ? ORDER BY occurred_at DESC LIMIT 100`\n-- Optional MariaDB temporal query: SELECT * FROM tbl FOR SYSTEM_TIME AS OF TIMESTAMP ''2026-11-07 00:00:00'';", "indexStrategy": "Clustered composite PK `(occurred_at, id)` + secondary `(tenant_id, occurred_at)`. + MariaDB built-in thread pool for high connection counts.", "txBehavior": "Append-only. (Supports Galera synchronous multi-primary clustering).", "opsComplexity": "Low-Medium."}, "sqlite": {"schema": "-- SQLite 3.40+ (WAL Mode: PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;)\n-- Suitable for single-node, embedded, CLI, or tenant-per-file workloads:\nCREATE TABLE security_audit_logs (\n    id TEXT NOT NULL,\n    occurred_at TEXT NOT NULL DEFAULT NOW(),\n    actor_id TEXT NOT NULL,\n    tenant_id TEXT NOT NULL,\n    action VARCHAR(80) NOT NULL,\n    target_resource TEXT NOT NULL,\n    prev_hash BLOB NOT NULL,\n    entry_hash BLOB NOT NULL,\n    PRIMARY KEY (occurred_at, id)\n) PARTITION BY RANGE (occurred_at);\n\n-- App role can ONLY INSERT and SELECT (never UPDATE or DELETE audit history!)\nREVOKE UPDATE, DELETE, TRUNCATE ON security_audit_logs FROM app_service_user;", "query": "SELECT occurred_at, actor_id, action, target_resource, encode(entry_hash, ''hex'')\nFROM security_audit_logs\nWHERE tenant_id = ?1 AND occurred_at >= NOW() - INTERVAL ''30 days''\nORDER BY occurred_at DESC LIMIT 100;", "indexStrategy": "B-Tree indexes (`CREATE INDEX`) + FTS5 virtual tables where full-text search is needed.", "txBehavior": "`BEGIN IMMEDIATE` serializes writes safely with `PRAGMA busy_timeout = 5000`; unlimited concurrent WAL readers.", "opsComplexity": "Lowest (in-process library, zero network hop; avoid only when multi-node concurrent network writes are required)."}, "mongodb": {"schema": "Time-series or capped/append-only collection with RBAC role restricting `remove`/`update` actions.", "query": "`db.security_audit_logs.find({ tenant_id: tid }).sort({ occurred_at: -1 }).limit(100)`", "indexStrategy": "Compound `{ tenant_id: 1, occurred_at: -1 }`.", "txBehavior": "Batched append.", "opsComplexity": "Medium."}, "redis": {"schema": "Not suitable for multi-year compliance storage; used only as a short-lived `XADD` ingestion buffer if needed.", "query": "`XADD audit_buffer MAXLEN ~ 50000 * actor usr_1 action LOGIN`", "indexStrategy": "Stream ID.", "txBehavior": "Ephemeral buffer only.", "opsComplexity": "Unsuitable as primary compliance archive."}, "scylladb": {"schema": "-- ScyllaDB / Apache Cassandra CQL (Wide-Column LSM-Tree for 10. Tamper-Evident Security & Compliance Audit Logs (SOC2 / HIPAA)):\nCREATE KEYSPACE IF NOT EXISTS app_ks WITH replication = {''class'': ''NetworkTopologyStrategy'', ''replication_factor'': 3};\n-- Modeled strictly around Partition Key + Clustering Key access pattern:\nCREATE TABLE app_ks.records_by_partition (\n    partition_id uuid,\n    bucket_day text,\n    event_id timeuuid,\n    payload text,\n    PRIMARY KEY ((partition_id, bucket_day), event_id)\n) WITH CLUSTERING ORDER BY (event_id DESC);", "query": "SELECT partition_id, event_id, payload\nFROM app_ks.records_by_partition\nWHERE partition_id = ? AND bucket_day = ''2026-11-07''\nLIMIT 50;\n-- Executed with Consistency Level LOCAL_QUORUM (R + W > RF)", "indexStrategy": "Consistent-hash Partition Key `(partition_id, bucket_day)` routes directly to the owning replica shard in 1 hop; sorted on disk by Clustering Key `event_id DESC`.", "txBehavior": "Lock-free append-only CommitLog + Memtable -> SSTable compaction; no multi-partition ACID joins (Lightweight Transactions `IF NOT EXISTS` use Paxos/Raft at 4-RTT cost).", "opsComplexity": "Medium-High (Excels at massive multi-terabyte write streams & chat/audit logs; avoid for complex relational joins or multi-account ACID balance transfers)."}}') ON CONFLICT (id) DO UPDATE SET scenario_number = EXCLUDED.scenario_number, title = EXCLUDED.title, recommended_stack = EXCLUDED.recommended_stack, rationale = EXCLUDED.rationale, engines_comparison_json = EXCLUDED.engines_comparison_json;
INSERT INTO diagnostic_rules (rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url) VALUES ('GO-SEC-001', 'security', 'potential_issue', 'critical', 'Dynamic SQL String Concatenation / Interpolation', 'Detected fmt.Sprintf or string concatenation constructing a SQL SELECT/INSERT/UPDATE/DELETE statement.', 'Interpolating untrusted input directly into SQL text allows attackers to alter the SQL AST and exfiltrate or destroy database records (SQL Injection / OWASP A03 / API10).', 'Pass SQL parameters strictly via driver placeholders: db.QueryContext(ctx, "SELECT id FROM users WHERE email = $1", email).', 'l6-security-auth-owasp', 'https://go.dev/doc/database/sql-injection') ON CONFLICT (rule_id) DO UPDATE SET category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url;
INSERT INTO diagnostic_rules (rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url) VALUES ('GO-SEC-002', 'security', 'potential_issue', 'high', 'Unbounded HTTP Request Body Read (Missing http.MaxBytesReader)', 'Detected io.ReadAll(r.Body) or json.NewDecoder(r.Body) without prior http.MaxBytesReader limit.', 'A malicious client can stream a multi-gigabyte request body to trigger Out-Of-Memory (OOM) termination (OWASP API4:2023 Unrestricted Resource Consumption).', 'Wrap r.Body before reading: r.Body = http.MaxBytesReader(w, r.Body, 1<<20) // 1 MiB limit.', 'l0-backend-http-lifecycle', 'https://pkg.go.dev/net/http#MaxBytesReader') ON CONFLICT (rule_id) DO UPDATE SET category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url;
INSERT INTO diagnostic_rules (rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url) VALUES ('GO-SEC-003', 'security', 'potential_issue', 'high', 'Default HTTP Server / Client Without Explicit Timeouts', 'Detected http.ListenAndServe or http.Get / &http.Client{} without ReadHeaderTimeout, ReadTimeout, or Timeout.', 'Zero timeouts allow Slowloris clients or stalled upstream servers to hang sockets and leak goroutines indefinitely.', 'Use &http.Server{ReadHeaderTimeout: 5*time.Second, ReadTimeout: 10*time.Second, WriteTimeout: 15*time.Second} and &http.Client{Timeout: 10*time.Second}.', 'l3-net-http-routers', 'https://pkg.go.dev/net/http#Server') ON CONFLICT (rule_id) DO UPDATE SET category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url;
INSERT INTO diagnostic_rules (rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url) VALUES ('GO-SEC-004', 'security', 'educational_heuristic', 'high', 'Public Exposure of net/http/pprof on DefaultServeMux', 'Detected blank import _ "net/http/pprof", which registers diagnostic heap/CPU profiles on http.DefaultServeMux.', 'If DefaultServeMux is exposed publicly, attackers can download heap dumps and sensitive memory arguments (OWASP API8:2023 Security Misconfiguration).', 'Bind pprof handlers explicitly to an internal loopback ServeMux on 127.0.0.1:6060.', 'l2-profiling-pprof-benchmarks', 'https://pkg.go.dev/net/http/pprof') ON CONFLICT (rule_id) DO UPDATE SET category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url;
INSERT INTO diagnostic_rules (rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url) VALUES ('GO-DB-001', 'database', 'potential_issue', 'high', 'sql.Rows Cursor Opened Without defer rows.Close()', 'Detected db.Query / db.QueryContext without a corresponding defer rows.Close() cleanup call.', 'If the loop exits early due to an error or return, the underlying database connection remains checked out forever, exhausting MaxOpenConns.', 'Add defer rows.Close() immediately after checking if err != nil on QueryContext, and check rows.Err() after iteration.', 'l5-db-ecosystem-comparison', 'https://go.dev/doc/database/querying') ON CONFLICT (rule_id) DO UPDATE SET category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url;
INSERT INTO diagnostic_rules (rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url) VALUES ('GO-DB-002', 'database', 'educational_heuristic', 'medium', 'sql.Open Initialized Without Connection Pool Bounds', 'Detected sql.Open() without SetMaxOpenConns, SetMaxIdleConns, and SetConnMaxLifetime.', 'Default MaxOpenConns is unlimited (0), allowing traffic spikes to overwhelm PostgreSQL max_connections.', 'Configure db.SetMaxOpenConns(25), db.SetMaxIdleConns(10), and db.SetConnMaxLifetime(30*time.Minute).', 'l5-db-ecosystem-comparison', 'https://go.dev/doc/database/manage-connections') ON CONFLICT (rule_id) DO UPDATE SET category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url;
INSERT INTO diagnostic_rules (rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url) VALUES ('GO-CONC-001', 'concurrency', 'potential_issue', 'high', 'Unbounded Goroutine Spawn Without Context or WaitGroup Lifecycle', 'Detected go func() spawned without context.Context cancellation or sync.WaitGroup tracking.', 'Fire-and-forget goroutines can block forever on network/channel I/O (leaking heap memory) or get terminated mid-execution on SIGTERM.', 'Pass context.Context into worker goroutines, bound concurrency with a worker pool or errgroup.Group, and await completion on shutdown.', 'l2-gmp-channels-context-workers', 'https://go.dev/blog/pipelines') ON CONFLICT (rule_id) DO UPDATE SET category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url;
INSERT INTO diagnostic_rules (rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url) VALUES ('GO-ERR-001', 'reliability', 'educational_heuristic', 'medium', 'Explicit panic() Used for Normal Error Handling', 'Detected panic(...) call in application code.', 'In Go, panic unwinds the goroutine stack and terminates the process unless recovered. Errors are values and should be returned explicitly.', 'Return wrapped errors using fmt.Errorf("operation failed: %w", err) and inspect with errors.Is / errors.As.', 'l1-interfaces-errors-generics', 'https://go.dev/blog/go1.13-errors') ON CONFLICT (rule_id) DO UPDATE SET category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url;
INSERT INTO diagnostic_rules (rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url) VALUES ('GO-PERF-001', 'performance', 'educational_heuristic', 'medium', 'regexp.MustCompile / Compile Inside Function Body', 'Detected regular expression compilation inside a function rather than at package initialization.', 'Compiling a finite automaton on every request allocates dozens of heap objects and increases CPU latency by >100x.', 'Hoist var pattern = regexp.MustCompile(...) to package scope so it compiles once at startup.', 'l2-profiling-pprof-benchmarks', 'https://pkg.go.dev/regexp') ON CONFLICT (rule_id) DO UPDATE SET category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url;
INSERT INTO diagnostic_rules (rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url) VALUES ('GO-CONC-002', 'concurrency', 'potential_issue', 'critical', 'Unsynchronized Shared Variable Mutation Inside Goroutine (Data Race)', 'Detected goroutine mutating shared state (++, --, +=) without sync.Mutex or sync/atomic synchronization.', 'WaitGroup only coordinates goroutine completion and does not synchronize memory writes; concurrent unsynchronized mutations cause data races.', 'Protect shared state with sync.Mutex (mu.Lock()/defer mu.Unlock()) or use sync/atomic (atomic.Int64).', 'l2-gmp-channels-context-workers', 'https://go.dev/doc/articles/race_detector') ON CONFLICT (rule_id) DO UPDATE SET category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url;
INSERT INTO diagnostic_rules (rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url) VALUES ('GO-ERR-002', 'reliability', 'potential_issue', 'high', 'Error Return Value Explicitly Discarded With Blank Identifier (_)', 'Detected fallible I/O, OS, SQL, or parsing call assigning its error return value to _.', 'Proceeding after a failed os.Open, db.Exec, or json.Unmarshal causes nil-pointer dereferences or silent data corruption.', 'Capture and check if err != nil before using the returned value.', 'l1-interfaces-errors-generics', 'https://go.dev/doc/effective_go#errors') ON CONFLICT (rule_id) DO UPDATE SET category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url;

