-- Go Backend Academy v2.5.0 — Complete 17 Stage A–J Foundation & Bridge Lessons Seed (PostgreSQL)
-- Expands curriculum from 24 base lessons to 41 complete lessons across Levels 0–10

INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l2-stage-c-concurrency-basics', 3, 0, 'mod-l2-stage-c-concurrency-basics', 'Stage C — Concurrency 101: Goroutines, Channels & WaitGroup', 'Bridges Level 1 sequential Go into Level 2 concurrency: how to launch background work safely, wait for completion with sync.WaitGroup, and collect results without data races.') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l2-stage-c-goroutines-channels-waitgroup', 'mod-l2-stage-c-concurrency-basics', 3, 0, 'l2-stage-c-goroutines-channels-waitgroup', '2.0 Concurrency 101: Your First Goroutine, Buffered Channels & sync.WaitGroup', 'Bridges Level 1 sequential Go into Level 2 concurrency: how to launch background work safely, wait for completion with sync.WaitGroup, and collect results without data races.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l2-stage-c-goroutines-channels-waitgroup-sec-main', 'l2-stage-c-goroutines-channels-waitgroup', 'core', '2.0 Concurrency 101: Your First Goroutine, Buffered Channels & sync.WaitGroup', '[Beginner Overview]
Imagine cooking breakfast: doing it **sequentially** means toasting bread (2 mins), waiting until it finishes, and only then boiling water (3 mins) = 5 mins total. **Concurrency** means starting the toaster (`go toastBread()`), immediately starting the kettle (`go boilWater()`), and waiting at the counter (`wg.Wait()`) until both are ready!

**Line-by-Line Syntax Walkthrough:**
1. `var wg sync.WaitGroup` — Creates a counter to track running goroutines.
2. `wg.Add(1)` — Increments the counter *before* launching the goroutine.
3. `go func(val int) { defer wg.Done(); ... }(n)` — Starts a concurrent goroutine that guarantees `wg.Done()` runs when finished.
4. `for _, n := range nums { sum += n * n }` — Iterates through each number `n` in `nums` and adds its square (`n * n`) to `sum`.

[Intermediate Technical]
Never call `wg.Add(1)` *inside* the `go func()` body—if `wg.Wait()` executes before the child goroutine starts, `Wait()` returns prematurely! Always call `wg.Add(1)` in the parent goroutine before `go func()`, and pass loop variables as arguments (or rely on Go 1.22+ per-iteration loop variable semantics).

[Advanced Internals]
Under the hood, `sync.WaitGroup` packs the 32-bit waiter count and 32-bit task counter into a single 64-bit `atomic.Uint64` word, using `runtime_Semacquire` and `runtime_Semrelease` only when the counter transitions to zero with active waiters.

[12 Engineering Decision Pillars]
1. What Is It: Your step-by-step introduction to Go concurrency (`go` keyword, `sync.WaitGroup`, and channels) before tackling the advanced GMP scheduler and bounded worker pools in Lesson 2.1.
2. Internal Mechanics: Prefixing a function call with `go` schedules a lightweight ~2KB goroutine onto the Go runtime. `sync.WaitGroup` maintains an atomic counter (`Add`, `Done`, `Wait`), and a channel (`chan T`) provides a synchronized queue for passing values between goroutines.
3. Why Needed: Sequential backends wait idly during network I/O (fetching user profile + permissions + billing one by one takes 30ms + 30ms + 30ms = 90ms; running them concurrently takes ~30ms).
4. Why Preferred: Learning `sync.WaitGroup` and simple result collection first prevents the classic beginner mistake of spawning fire-and-forget goroutines that silently vanish or race on shared variables.
5. When To Use: Whenever a handler needs to fan out independent I/O calls or batch-process independent items and wait for all results.
6. When To Avoid: Do not use goroutines for tiny CPU loops (like summing 5 integers in production)—the scheduling overhead exceeds a simple `for` loop! Use concurrency when tasks block on I/O or heavy independent work.
7. Advantages: Simple syntax (`go fn()`), built-in race detector (`go test -race`), and deterministic synchronization via `sync.WaitGroup`.
8. Disadvantages: Forgetting `defer wg.Done()` causes a permanent deadlock; reading/writing the same variable from multiple goroutines without synchronization causes a data race.
9. Alternatives: Sequential `for` loops (simpler and faster for small in-memory slices) or `errgroup.Group` (for concurrent tasks that can return errors).
10. Incorrect Consequences: Modifying a shared `total += n * n` variable from multiple goroutines without a mutex or channel corrupts the sum under concurrent execution (`DATA RACE`).
11. Real-World Usage: Parallelizing independent downstream API calls (e.g., fetching product details and inventory counts simultaneously) while waiting via `sync.WaitGroup`.
12. Perf/Sec/Maint/Scale: Always bound concurrency in production and run `go test -race ./...` in CI to catch unsynchronized shared memory writes.', '[main goroutine] --(wg.Add(1) + go worker())--> [Worker Goroutines] --(ch <- n*n)--> [Buffered Channel] --> [wg.Wait() + Sum]', 'package conc

import "sync"

func SumSquaresRacy(nums []int) int {
	var wg sync.WaitGroup
	sum := 0
	for _, n := range nums {
		wg.Add(1)
		go func(v int) {
			defer wg.Done()
			sum += v * v // BUG: DATA RACE on shared variable sum!
		}(n)
	}
	wg.Wait()
	return sum
}', 'package conc

func SumSquaresSafe(nums []int) int {
	sum := 0
	for _, n := range nums {
		sum += n * n
	}
	return sum
}', 'For pure in-memory integer math, a sequential `for _, n := range nums` loop is 100% race-free and zero-allocation; when goroutines are used for I/O, collect results over a buffered channel or protect shared state.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l2-stage-c-goroutines-channels-waitgroup-ref-1', 'l2-stage-c-goroutines-channels-waitgroup', 'A Tour of Go: Goroutines & Channels', 'https://go.dev/tour/concurrency/1', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l2-stage-c-goroutines-channels-waitgroup', 'l2-stage-c-goroutines-channels-waitgroup', 'Compute Deterministic Sum of Squares Before Scaling to Worker Pools', 'Implement SumSquaresSafe(nums []int) int by iterating over nums with a range loop, adding n * n to sum, and returning sum.', 'package conc

func SumSquaresSafe(nums []int) int {
	sum := 0
	// STEP: Loop over nums with range, accumulate n * n into sum, and return sum
	return 0
}', 'Invarian: Sum Squares Safe Empty
Invarian: Sum Squares Safe Values', 'package conc

func SumSquaresSafe(nums []int) int {
	sum := 0
	for _, n := range nums {
		sum += n * n
	}
	return sum
}', 'Mastering deterministic loop reduction and race-free state ownership prepares you for Lesson 2.1 (Bounded Worker Pools & GMP Scheduler).', 'Open the Concurrency Lab to simulate how buffered vs unbuffered channels behave when worker count changes!') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l2-stage-c-goroutines-channels-waitgroup-tc-1', 'ex-l2-stage-c-goroutines-channels-waitgroup', 1, 'Verify empty slice returns 0; Verify [2, 3, 4] returns 4 + 9 + 16 = 29', 'for _, n := range nums|sum += n * n|return sum') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l6-stage-f-auth-basics', 7, 0, 'mod-l6-stage-f-auth-basics', 'Stage F — Security 101: Password Hashing & Bearer Auth Middleware', 'Introduces authentication fundamentals before diving into Argon2id memory parameters, OAuth2 PKCE, and SSRF IP filtering in Lessons 6.1 and 6.2.') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l6-stage-f-password-hashing-bearer-auth', 'mod-l6-stage-f-auth-basics', 7, 0, 'l6-stage-f-password-hashing-bearer-auth', '6.0 Security 101: Password Hashing, Bearer Tokens & HTTP Auth Middleware', 'Introduces authentication fundamentals before diving into Argon2id memory parameters, OAuth2 PKCE, and SSRF IP filtering in Lessons 6.1 and 6.2.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l6-stage-f-password-hashing-bearer-auth-sec-main', 'l6-stage-f-password-hashing-bearer-auth', 'core', '6.0 Security 101: Password Hashing, Bearer Tokens & HTTP Auth Middleware', '[Beginner Overview]
When you log into an app, the server gives your browser a digital badge called a **Bearer Token**. Every time your browser asks for private data, it shows that badge in an HTTP header: `Authorization: Bearer abc123xyz`.

**Line-by-Line Syntax Walkthrough:**
1. `const prefix = "Bearer "` — Defines the exact 7-character prefix required by RFC 6750.
2. `if !strings.HasPrefix(authHeader, prefix) { return "", false }` — Safely rejects any header that does not start with `"Bearer "` (no slice index panics!).
3. `tok := strings.TrimSpace(strings.TrimPrefix(authHeader, prefix))` — Removes `"Bearer "` and any extra spaces.
4. `return tok, tok != ""` — Returns the token and `true` only if the remaining token is non-empty.

[Intermediate Technical]
Why does `strings.Split(h, " ")[1]` crash production servers? Because an attacker sending `Authorization: Basic` (no space) causes `strings.Split` to return a 1-element slice, triggering a runtime panic! `strings.HasPrefix` + `strings.TrimPrefix` is 100% panic-proof.

[Advanced Internals]
After extracting the bearer token string without allocations, pass it to your JWT verifier (enforcing `alg`, `iss`, `aud`, `exp`) or hash it with SHA-256 to look up the server-side session row.

[12 Engineering Decision Pillars]
1. What Is It: The foundational gateway to backend security: how passwords are stored safely as salted one-way hashes and how HTTP APIs authenticate requests using `Authorization: Bearer <token>` headers.
2. Internal Mechanics: When a user logs in, the server verifies their password against an Argon2id/bcrypt hash and issues a signed token or session ID. On subsequent API calls, the client sends `Authorization: Bearer <token>`, and middleware extracts the token string after the `"Bearer "` prefix.
3. Why Needed: HTTP is stateless; without a clean, strict token extraction boundary, protected endpoints cannot reliably identify the caller or reject malformed credentials.
4. Why Preferred: Validating the exact `"Bearer "` prefix and rejecting blank or whitespace-only tokens fails closed before any database or cryptographic verification runs.
5. When To Use: On every authenticated REST API middleware chain before parsing JWT claims or looking up session rows.
6. When To Avoid: Do not accept tokens in URL query parameters (`?token=xyz`) for normal API calls because URLs are logged in plaintext by proxies, browsers, and access logs.
7. Advantages: Standard RFC 6750 header format, zero allocation string prefix trimming, and clear `401 Unauthorized` failure semantics.
8. Disadvantages: Bearer tokens grant access to anyone possessing them, so TLS (`HTTPS`) and short expiration times are mandatory.
9. Alternatives: `HttpOnly; Secure; SameSite=Lax` session cookies (often preferred for browser-only web apps).
10. Incorrect Consequences: Using `strings.Split(authHeader, " ")[1]` without checking length panics with `index out of range [1] with length 1` whenever a client sends a malformed `Authorization: Bearer` header!
11. Real-World Usage: Used in the authentication middleware of virtually every production Go REST and gRPC gateway.
12. Perf/Sec/Maint/Scale: `strings.HasPrefix` + `strings.TrimPrefix` runs in `O(1)` time with zero heap allocations, preventing panic DoS vectors on malformed headers.', '[Client Request] --(Authorization: Bearer <token>)--> [ExtractBearerToken()] --(Valid?)--> [Protected Handler] / [401 Unauthorized]', 'package auth

import "strings"

func ExtractBearerUnsafe(authHeader string) string {
	// BUG: Panics with index out of range if authHeader has no space!
	parts := strings.Split(authHeader, " ")
	return parts[1]
}', 'package auth

import "strings"

func ExtractBearerToken(authHeader string) (string, bool) {
	const prefix = "Bearer "
	if !strings.HasPrefix(authHeader, prefix) {
		return "", false
	}
	tok := strings.TrimSpace(strings.TrimPrefix(authHeader, prefix))
	if tok == "" {
		return "", false
	}
	return tok, true
}', '`HasPrefix` and `TrimPrefix` never panic on short or malformed inputs and allocate zero intermediate slices.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l6-stage-f-password-hashing-bearer-auth-ref-1', 'l6-stage-f-password-hashing-bearer-auth', 'RFC 6750: OAuth 2.0 Bearer Token Usage', 'https://datatracker.ietf.org/doc/html/rfc6750', 'RFC 6750', 'specification', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l6-stage-f-password-hashing-bearer-auth', 'l6-stage-f-password-hashing-bearer-auth', 'Extract Bearer Token Safely Without Slice Bounds Panics', 'Implement ExtractBearerToken(authHeader string) (string, bool) using strings.HasPrefix(authHeader, prefix) and strings.TrimSpace(strings.TrimPrefix(authHeader, prefix)).', 'package auth

import "strings"

func ExtractBearerToken(authHeader string) (string, bool) {
	const prefix = "Bearer "
	// STEP: Check strings.HasPrefix(authHeader, prefix), trim prefix and spaces, and reject empty tokens
	return "", false
}', 'Invarian: Extract Bearer Token Valid
Invarian: Extract Bearer Token Rejects Malformed', 'package auth

import "strings"

func ExtractBearerToken(authHeader string) (string, bool) {
	const prefix = "Bearer "
	if !strings.HasPrefix(authHeader, prefix) {
		return "", false
	}
	tok := strings.TrimSpace(strings.TrimPrefix(authHeader, prefix))
	if tok == "" {
		return "", false
	}
	return tok, true
}', 'Safe header parsing is the first line of defense in every authentication middleware before cryptographic verification in Lesson 6.1.', 'Next, proceed to Lesson 6.1 to see how API keys are compared in constant time using subtle.ConstantTimeCompare!') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l6-stage-f-password-hashing-bearer-auth-tc-1', 'ex-l6-stage-f-password-hashing-bearer-auth', 1, 'Verify "Bearer secret123" returns ("secret123", true); Verify "Basic xyz" or "Bearer   " returns ("", false)', 'strings.HasPrefix(authHeader, prefix)|strings.TrimSpace(strings.TrimPrefix(authHeader, prefix))') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l7-stage-g-testing-basics', 8, 0, 'mod-l7-stage-g-testing-basics', 'Stage G — Testing 101: Table-Driven Unit Tests & Deterministic Functions', 'Teaches how to write clean, deterministic functions and verify every edge case (empty input, extra whitespace, uppercase) with Go table-driven tests before fuzzing in Lesson 7.1.') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l7-stage-g-table-driven-tests-httptest', 'mod-l7-stage-g-testing-basics', 8, 0, 'l7-stage-g-table-driven-tests-httptest', '7.0 Testing 101: Writing Table-Driven Unit Tests & Testable Pure Functions', 'Teaches how to write clean, deterministic functions and verify every edge case (empty input, extra whitespace, uppercase) with Go table-driven tests before fuzzing in Lesson 7.1.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l7-stage-g-table-driven-tests-httptest-sec-main', 'l7-stage-g-table-driven-tests-httptest', 'core', '7.0 Testing 101: Writing Table-Driven Unit Tests & Testable Pure Functions', '[Beginner Overview]
How do you make sure a function works on normal inputs, messy inputs, and empty inputs? You write a **Table-Driven Test**—a checklist of `(input -> expected output)` rows!

**Line-by-Line Syntax Walkthrough:**
1. `words := strings.Fields(strings.ToLower(title))` — Converts `title` to lowercase and splits it into clean words, automatically ignoring extra spaces or tabs!
2. `return strings.Join(words, "-")` — Joins the clean words with a single `"-"` hyphen between each word (returning `""` if `words` is empty).

[Intermediate Technical]
Compare `strings.Split(s, " ")` vs `strings.Fields(s)`: `strings.Split("  go  backend ", " ")` produces empty strings `["", "", "go", "", "backend", ""]`, whereas `strings.Fields` returns `["go", "backend"]` cleanly.

[Advanced Internals]
Combine table-driven unit tests (`TestSlugifyTitle`) in Lesson 7.0 with `testing.F` fuzzing in Lesson 7.1 to prove that arbitrary Unicode strings never panic or produce leading/trailing hyphens.

[12 Engineering Decision Pillars]
1. What Is It: The foundational guide to Go unit testing: designing pure functions and testing multiple inputs and edge cases systematically using a table of test cases.
2. Internal Mechanics: Go''s `testing` package runs any `func TestXxx(t *testing.T)` in `*_test.go` files. By defining a slice of test cases and iterating with `t.Run(tc.name, ...)`, you test 10 edge cases with a single 5-line assertion loop.
3. Why Needed: Untested backend code breaks silently when edge cases (like extra spaces or mixed case in article titles) hit production.
4. Why Preferred: Adding a new bug regression test to a table-driven test takes 1 line (`{name: "tabs and spaces", in: "  Go   101 ", want: "go-101"}`) instead of copying a 15-line test function.
5. When To Use: For every pure business helper, validator, slug generator, parser, and HTTP handler in your service.
6. When To Avoid: Do not put complex `if/else` branching logic inside the test loop itself—keep test expectations explicit and literal.
7. Advantages: Zero external test framework dependencies (`assert` libraries are optional in Go), fast execution, and isolated subtest filtering.
8. Disadvantages: Requires discipline to keep functions deterministic (passing time or random seeds as arguments).
9. Alternatives: Repetitive copy-pasted `TestCase1`, `TestCase2` functions.
10. Incorrect Consequences: Using `strings.ReplaceAll(strings.ToLower(title), " ", "-")` turns `"  Hello   Go "` into `"--hello---go-"` with ugly leading/consecutive hyphens!
11. Real-World Usage: Used across the Go standard library (`strings_test.go`, `net/http/serve_test.go`) and Go Backend Academy''s own `server_integration_test.go`.
12. Perf/Sec/Maint/Scale: `strings.Fields` splits on any run of whitespace characters and trims leading/trailing spaces in a single pass.', '[Test Table []struct{name, input, want}] --> [t.Run(tc.name)] --> [SlugifyTitle(tc.input)] --> [got != tc.want -> t.Errorf]', 'package slug

import "strings"

func SlugifyNaive(title string) string {
	// BUG: "  Go   Backend  " becomes "--go---backend--"
	return strings.ReplaceAll(strings.ToLower(title), " ", "-")
}', 'package slug

import "strings"

func SlugifyTitle(title string) string {
	words := strings.Fields(strings.ToLower(title))
	return strings.Join(words, "-")
}', '`strings.Fields` collapses arbitrary runs of spaces, tabs, and newlines into clean tokens before `strings.Join` links them with `"-"`.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l7-stage-g-table-driven-tests-httptest-ref-1', 'l7-stage-g-table-driven-tests-httptest', 'Go Wiki: TableDrivenTests', 'https://go.dev/wiki/TableDrivenTests', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l7-stage-g-table-driven-tests-httptest', 'l7-stage-g-table-driven-tests-httptest', 'Implement Deterministic URL Slug Generator for Table-Driven Testing', 'Implement SlugifyTitle(title string) string using strings.Fields(strings.ToLower(title)) and strings.Join(words, "-").', 'package slug

import "strings"

func SlugifyTitle(title string) string {
	// STEP: Tokenize lowercase title with strings.Fields(strings.ToLower(title)) and join with "-"
	return ""
}', 'PASS: TestSlugifyTitleTableDriven/normal_title (0.00s)
PASS: TestSlugifyTitleTableDriven/extra_whitespace (0.00s)', 'package slug

import "strings"

func SlugifyTitle(title string) string {
	words := strings.Fields(strings.ToLower(title))
	return strings.Join(words, "-")
}', 'Clean, deterministic string normalization makes table-driven unit tests in Level 7 effortless to write and maintain.', 'Write a 4-row table-driven test in your local editor covering empty string, single word, multiple spaces, and mixed case!') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l7-stage-g-table-driven-tests-httptest-tc-1', 'ex-l7-stage-g-table-driven-tests-httptest', 1, 'Verify "  Go   Backend Academy " returns "go-backend-academy"; Verify "   " returns ""', 'strings.Fields(strings.ToLower(title))|strings.Join(words, "-")') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l8-stage-h-architecture-basics', 9, 0, 'mod-l8-stage-h-architecture-basics', 'Stage H — Architecture 101: Handler, Service & Repository Separation', 'Answers the #1 architecture question for Go learners: how to separate HTTP transport, domain business rules, and SQL queries cleanly before exploring Hexagonal/DDD in Lesson 8.1.') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l8-stage-h-handler-service-repo-layers', 'mod-l8-stage-h-architecture-basics', 9, 0, 'l8-stage-h-handler-service-repo-layers', '8.0 Architecture 101: Separating Handler, Service & Repository Without Boilerplate', 'Answers the #1 architecture question for Go learners: how to separate HTTP transport, domain business rules, and SQL queries cleanly before exploring Hexagonal/DDD in Lesson 8.1.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l8-stage-h-handler-service-repo-layers-sec-main', 'l8-stage-h-handler-service-repo-layers', 'core', '8.0 Architecture 101: Separating Handler, Service & Repository Without Boilerplate', '[Beginner Overview]
When organizing a Go backend project, give each layer **one job**:
- **Handler**: Speaks HTTP (reads JSON request, writes `200 OK` or `400 Bad Request`).
- **Service / Domain**: Enforces business rules (e.g., *"You cannot add USD and EUR together without conversion!"*).
- **Repository**: Speaks SQL (`SELECT` / `INSERT`).

**Line-by-Line Syntax Walkthrough:**
1. `if a == nil || b == nil { return Money{}, errors.New("money operand is nil") }` — Prevents nil-pointer crashes.
2. `if a.Currency != b.Currency { return Money{}, errors.New("currency mismatch") }` — Enforces the domain rule that currencies must match.
3. `return Money{Cents: a.Cents + b.Cents, Currency: a.Currency}, nil` — Returns the combined `Money` struct safely.

[Intermediate Technical]
Notice that `AddMoney(a, b *Money) (Money, error)` does not import `net/http` or `database/sql`. That means you can call it from an HTTP handler, a CLI command, or a background worker without changing a single line!

[Advanced Internals]
This pure domain boundary is the exact foundation of Hexagonal (Ports & Adapters) Architecture in Lesson 8.1: the domain sits at the center with zero outbound infrastructure imports.

[12 Engineering Decision Pillars]
1. What Is It: A practical, jargon-free introduction to structuring a Go backend service into three focused responsibilities: **Handler** (HTTP), **Service** (Business Logic), and **Repository** (Database).
2. Internal Mechanics: The HTTP handler decodes JSON and calls the Service. The Service checks business rules (like verifying two `Money` values share the same currency before adding them) and calls the Repository. The Repository runs SQL queries.
3. Why Needed: Putting SQL queries, JSON decoding, and financial math inside a single 300-line `http.HandlerFunc` makes it impossible to test business rules without spinning up an HTTP server and database.
4. Why Preferred: Starting with clean pure domain structs (`Money`) and functions lets you test 100% of your business rules in 0.1ms before adding interfaces or adapters.
5. When To Use: As the default starting structure for any Go REST API or microservice.
6. When To Avoid: Do not create 5 layers of empty pass-through interfaces for a 2-endpoint tool—only introduce interfaces where you actually need to swap or fake an external dependency.
7. Advantages: Crystal-clear file organization, instant unit testing of domain rules, and zero circular imports.
8. Disadvantages: Requires mapping between HTTP DTOs and domain structs when API contracts diverge from storage tables.
9. Alternatives: Fat HTTP handlers (hard to test) or heavy enterprise Java-style boilerplate (hard to read).
10. Incorrect Consequences: Adding `1000 USD` + `1000 IDR` without checking `a.Currency != b.Currency` silently corrupts financial balances across currencies!
11. Real-World Usage: Look at Go Backend Academy''s own `internal/modules/` directory: each module cleanly separates domain logic (`service.go`) from HTTP routing (`router.go`) and SQL (`database/`).
12. Perf/Sec/Maint/Scale: Pure value/pointer domain methods allocate zero heap memory and execute in nanoseconds.', '[HTTP Handler (JSON/Status)] --> [Domain Service (Pure Business Rules)] --> [Repository (Parameterized SQL)]', 'package money

type Money struct {
	Cents    int64
	Currency string
}

func AddMoneyUnsafe(a, b *Money) Money {
	// BUG: Panics if a or b is nil, and silently adds USD + JPY!
	return Money{Cents: a.Cents + b.Cents, Currency: a.Currency}
}', 'package money

import "errors"

type Money struct {
	Cents    int64
	Currency string
}

func AddMoney(a, b *Money) (Money, error) {
	if a == nil || b == nil {
		return Money{}, errors.New("money operand cannot be nil")
	}
	if a.Currency != b.Currency {
		return Money{}, errors.New("currency mismatch")
	}
	return Money{Cents: a.Cents + b.Cents, Currency: a.Currency}, nil
}', 'Validating `a == nil || b == nil` and `a.Currency != b.Currency` inside the domain layer guarantees no caller can violate financial invariants.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l8-stage-h-handler-service-repo-layers-ref-1', 'l8-stage-h-handler-service-repo-layers', 'Go Blog: Organizing a Go Module', 'https://go.dev/doc/modules/layout', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l8-stage-h-handler-service-repo-layers', 'l8-stage-h-handler-service-repo-layers', 'Enforce Domain Currency & Nil Invariants in Pure Service Function', 'Implement AddMoney(a, b *Money) (Money, error) checking if a == nil || b == nil, checking if a.Currency != b.Currency, and returning Money{Cents: a.Cents + b.Cents, Currency: a.Currency}, nil.', 'package money

import "errors"

type Money struct {
	Cents    int64
	Currency string
}

func AddMoney(a, b *Money) (Money, error) {
	// STEP: Guard a == nil || b == nil and a.Currency != b.Currency, then return combined Money
	return Money{}, nil
}', 'Invarian: Add Money Same Currency
Invarian: Add Money Rejects Mismatch And Nil', 'package money

import "errors"

type Money struct {
	Cents    int64
	Currency string
}

func AddMoney(a, b *Money) (Money, error) {
	if a == nil || b == nil {
		return Money{}, errors.New("money operand cannot be nil")
	}
	if a.Currency != b.Currency {
		return Money{}, errors.New("currency mismatch")
	}
	return Money{Cents: a.Cents + b.Cents, Currency: a.Currency}, nil
}', 'Keeping domain invariants in pure functions makes your service architecture clean and prepares you for Lesson 8.1 (Hexagonal Ports & Adapters).', 'Open the Architecture Lab to compare how Layered, Clean, Hexagonal, and Modular Monolith organize these files!') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l8-stage-h-handler-service-repo-layers-tc-1', 'ex-l8-stage-h-handler-service-repo-layers', 1, 'Verify 500 USD + 300 USD returns 800 USD; Verify USD + EUR or nil operand returns non-nil error', 'if a == nil || b == nil|if a.Currency != b.Currency|Cents: a.Cents + b.Cents') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l9-stage-i-distributed-basics', 10, 0, 'mod-l9-stage-i-distributed-basics', 'Stage I — Distributed Systems 101: Cache-Aside & Exponential Backoff', 'Introduces caching and safe retry backoff mechanics for distributed calls before tackling Singleflight stampede protection, Outbox, and Circuit Breakers in Lesson 9.1.') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l9-stage-i-redis-cache-aside-backoff', 'mod-l9-stage-i-distributed-basics', 10, 0, 'l9-stage-i-redis-cache-aside-backoff', '9.0 Distributed 101: Redis Cache-Aside Mental Model & Exponential Backoff Retries', 'Introduces caching and safe retry backoff mechanics for distributed calls before tackling Singleflight stampede protection, Outbox, and Circuit Breakers in Lesson 9.1.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l9-stage-i-redis-cache-aside-backoff-sec-main', 'l9-stage-i-redis-cache-aside-backoff', 'core', '9.0 Distributed 101: Redis Cache-Aside Mental Model & Exponential Backoff Retries', '[Beginner Overview]
If a website or database is temporarily busy, clicking refresh 100 times per second only makes it crash harder! Instead, smart backends wait **100ms**, then **200ms**, then **400ms**, then **800ms** (doubling each time up to a maximum cap like **5,000ms**). This is called **Exponential Backoff**.

**Line-by-Line Syntax Walkthrough:**
1. `if attempt < 1 { attempt = 1 }` — Ensures attempt number starts at 1 or higher.
2. `if attempt > 30 { return maxMs }` — Prevents bit-shift overflow on large attempt numbers.
3. `delay := baseMs << (attempt - 1)` — Doubles `baseMs` for each attempt (`100 << 0 = 100`, `100 << 1 = 200`, `100 << 2 = 400`).
4. `if delay > maxMs || delay <= 0 { return maxMs }` — Caps the wait time so it never exceeds `maxMs`.

[Intermediate Technical]
Why does `baseMs << (attempt - 1)` double the number? Because shifting binary bits left by 1 position multiplies by `2^1 = 2`, shifting by 2 multiplies by `2^2 = 4`, and shifting by 3 multiplies by `2^3 = 8`!

[Advanced Internals]
In production (Lesson 9.1), combine this capped exponential backoff with **Full Jitter** (`rand.Int63n(delay)`) and a **Circuit Breaker** so 500 concurrent pods do not wake up on the exact same millisecond.

[12 Engineering Decision Pillars]
1. What Is It: Your foundational guide to two everyday distributed backend patterns: **Cache-Aside** (speeding up reads with Redis) and **Exponential Backoff** (retrying temporary network glitches safely).
2. Internal Mechanics: When a downstream service or cache node hiccups, instead of hammering it 1,000 times per second in a tight loop, exponential backoff doubles the wait duration after each failed attempt (`baseMs * 2^(attempt-1)`), capped at `maxMs`.
3. Why Needed: In distributed systems, networks and databases occasionally drop packets or restart. Naive instant retries turn a 1-second blip into a cascading outage (a **Retry Storm**).
4. Why Preferred: Bit-shifting `baseMs << (attempt - 1)` with an explicit `attempt < 1` floor and `delay > maxMs` cap computes retry delays in nanoseconds without `math.Pow` float conversions.
5. When To Use: On every outbound background job worker, webhook delivery client, and idempotent RPC retry loop.
6. When To Avoid: Never retry non-idempotent mutations (like charging a credit card without an `Idempotency-Key`) blindly on timeout.
7. Advantages: Gives recovering databases and downstream APIs breathing room to finish restarting.
8. Disadvantages: Increases tail latency for the caller during retries (which is why retries must also respect `ctx.Done()`).
9. Alternatives: Fixed sleep intervals (too aggressive during outages) or immediate fail-fast circuit breaking (Lesson 9.1).
10. Incorrect Consequences: Retrying with zero delay (`for { err := sendWebhook(); if err == nil { break } }`) saturates CPU and DDOSes your own database or partner API.
11. Real-World Usage: Used in AWS SDK for Go, gRPC retry interceptors, and background outbox relay workers.
12. Perf/Sec/Maint/Scale: Capping `attempt` and clamping `delay` to `maxMs` prevents 64-bit integer shift overflow and bounds maximum retry wait time.', '[Attempt 1: 100ms] -> [Attempt 2: 200ms] -> [Attempt 3: 400ms] -> [Attempt 4: 800ms] -> [Capped at maxMs (5000ms)]', 'package retry

func ComputeBackoffUnsafe(baseMs int64, attempt int) int64 {
	// BUG: Panics if attempt < 1 (negative shift) and overflows int64 on large attempts!
	return baseMs << (attempt - 1)
}', 'package retry

func ComputeBackoffMs(baseMs int64, maxMs int64, attempt int) int64 {
	if attempt < 1 {
		attempt = 1
	}
	if attempt > 30 {
		return maxMs
	}
	delay := baseMs << (attempt - 1)
	if delay > maxMs || delay <= 0 {
		return maxMs
	}
	return delay
}', 'Clamping `attempt >= 1`, guarding `attempt > 30`, and capping at `maxMs` guarantees safe, bounded backoff durations for any input.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l9-stage-i-redis-cache-aside-backoff-ref-1', 'l9-stage-i-redis-cache-aside-backoff', 'AWS Architecture Blog: Exponential Backoff And Jitter', 'https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/', 'Production Guide', 'reference', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l9-stage-i-redis-cache-aside-backoff', 'l9-stage-i-redis-cache-aside-backoff', 'Calculate Capped Exponential Backoff Delay Safely', 'Implement ComputeBackoffMs(baseMs int64, maxMs int64, attempt int) int64 by clamping attempt < 1 to 1, computing delay := baseMs << (attempt - 1), and capping at maxMs.', 'package retry

func ComputeBackoffMs(baseMs int64, maxMs int64, attempt int) int64 {
	// STEP: Clamp attempt < 1 to 1, compute delay := baseMs << (attempt - 1), and cap delay > maxMs at maxMs
	return 0
}', 'Invarian: Compute Backoff Ms Progression
Invarian: Compute Backoff Ms Capped At Max', 'package retry

func ComputeBackoffMs(baseMs int64, maxMs int64, attempt int) int64 {
	if attempt < 1 {
		attempt = 1
	}
	if attempt > 30 {
		return maxMs
	}
	delay := baseMs << (attempt - 1)
	if delay > maxMs || delay <= 0 {
		return maxMs
	}
	return delay
}', 'Understanding bounded exponential backoff prepares you for Circuit Breakers, Singleflight, and Outbox relays in Lesson 9.1.', 'Think about why 100 clients retrying at the exact same 200ms mark still creates spikes, and how adding random jitter smooths the load!') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l9-stage-i-redis-cache-aside-backoff-tc-1', 'ex-l9-stage-i-redis-cache-aside-backoff', 1, 'Verify attempt 1..3 with base 100ms returns 100, 200, 400; Verify attempt 10 with max 1000ms returns 1000', 'if attempt < 1|delay := baseMs << (attempt - 1)|if delay > maxMs') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l0-stage-a-orientation', 1, 1, 'mod-l0-stage-a-orientation', 'Stage A — Orientation, Terminal, Git & Computing Foundations', 'Absolute beginner starting point: what a backend server actually does, how an OS process listens on a network port, how environment variables (.env) configure programs, and why clients never talk directly to databases.') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l0-stage-a-what-is-backend', 'mod-l0-stage-a-orientation', 1, 1, 'l0-stage-a-what-is-backend', '0.0A What is a Backend? Servers, Terminal, Files, Processes & Ports', 'Absolute beginner starting point: what a backend server actually does, how an OS process listens on a network port, how environment variables (.env) configure programs, and why clients never talk directly to databases.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l0-stage-a-what-is-backend-sec-main', 'l0-stage-a-what-is-backend', 'core', '0.0A What is a Backend? Servers, Terminal, Files, Processes & Ports', '[Beginner Overview]
Think of a restaurant: the dining room menu is the Frontend (what the customer sees), the kitchen is the Backend (where orders are checked and cooked), and the locked vault/pantry is the Database. Customers never walk into the vault—they give their order to the kitchen via a numbered counter window (a Port like 8080).

[Intermediate Technical]
At the OS level, a backend is a long-running user-space process. It reads runtime settings from environment variables via os.Getenv, opens a listening TCP socket on HOST:PORT, and multiplexes incoming client connections across lightweight goroutines.

[Advanced Internals]
Under Linux/Windows, listening on a TCP port allocates a socket file descriptor in the kernel table. Twelve-Factor App architecture mandates strict separation of config from code via environment variables so immutable container images can be promoted from staging to prod.

[12 Engineering Decision Pillars]
1. What Is It: A backend is a program running on a computer (server) that waits for network requests on a specific Port, enforces security and business rules, reads or writes a database, and sends back a structured response.
2. Internal Mechanics: When you start a compiled Go binary, the Operating System creates a Process with a Process ID (PID), virtual memory space, file descriptors, and an environment variable table (os.Getenv). When the process binds to a TCP port (e.g. :8080), the OS kernel routes packets arriving for that port to your process.
3. Why Needed: If a web page or mobile app connected directly to your database, any user could inspect the app, extract the database password, and delete or steal every customer record.
4. Why Preferred: Centralizing rules in a compiled Go server gives you one authoritative boundary for validation, authentication, rate limiting, and database transactions.
5. When To Use: Every web app, mobile app, payment webhook, or multi-user system where data must be shared, validated, and protected.
6. When To Avoid: Purely offline client-side calculators or static brochure pages with no shared state or secrets.
7. Advantages: Protects database credentials; enforces business invariants; compiles to a single fast native binary in Go.
8. Disadvantages: Requires running and monitoring a server process and managing network/database configuration.
9. Alternatives: Static files on a CDN (no dynamic state) or Serverless functions (FaaS, higher cold-start latency).
10. Incorrect Consequences: Hardcoding ports or database passwords inside source code makes the binary impossible to reconfigure across environments and leaks secrets into Git.
11. Real-World Usage: Go Backend Academy itself reads PORT, DB_DRIVER, POSTGRES_PORT, and SQLITE_PATH from .env / environment variables at startup.
12. Perf/Sec/Maint/Scale: Security: Secrets stay in environment variables, never in Git. Maintainability: One binary runs anywhere by changing .env.', '[Browser / Mobile App] ---> (IP Address + Port :8080) ---> [Go Server Process (PID)] ---> [Database File / PostgreSQL]', 'package main

// BUG: Changing port requires recompiling; password is leaked in Git!
const ServerPort = "8080"
const DatabasePassword = "prod-secret-password"', 'package main

import "os"

func ResolvePort(defaultPort string) string {
	if v := os.Getenv("PORT"); v != "" {
		return v
	}
	return defaultPort
}', 'os.Getenv("PORT") allows .env, systemd, Docker, or Kubernetes to inject any port at runtime while falling back to defaultPort in local dev.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l0-stage-a-what-is-backend-ref-1', 'l0-stage-a-what-is-backend', 'Go Standard Library: os', 'https://pkg.go.dev/os', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l0-stage-a-what-is-backend', 'l0-stage-a-what-is-backend', 'Konfigurasi Alamat Listen Port Default Server HTTP', 'Implementasikan fungsi DefaultPort() string yang mengembalikan alamat port default ":8080" untuk server HTTP.', 'package main

// DefaultPort mengembalikan alamat listen port default untuk server HTTP
func DefaultPort() string {
	// STEP: Kembalikan string ":8080"
	return ""
}', 'Invarian: DefaultPort mengembalikan '':8080'' sebagai alamat listen port server.', 'package main

// DefaultPort mengembalikan alamat listen port default untuk server HTTP
func DefaultPort() string {
	return ":8080"
}', 'Fungsi DefaultPort mengembalikan port default tanpa memerlukan pembacaan environment atau branching yang rumit di hari pertama.', 'Di pelajaran berikutnya (Level 1.0B), kita akan meningkatkan fungsi ini dengan ResolvePort(envVal string) menggunakan os.Getenv dan percabangan if/else!') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l0-stage-a-what-is-backend-tc-1', 'ex-l0-stage-a-what-is-backend', 1, 'Verify DefaultPort returns ":8080"', 'func DefaultPort() string|return ":8080"') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l0-stage-a-git-go-workspace', 'mod-l0-stage-a-orientation', 1, 2, 'l0-stage-a-git-go-workspace', '0.0B Installing Go, Terminal Commands, Git Basics & Your First main.go', 'Navigating directories in the terminal, tracking code changes with Git (init, status, add, commit), initializing a Go module (go mod init), and running your first main.go file.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l0-stage-a-git-go-workspace-sec-main', 'l0-stage-a-git-go-workspace', 'core', '0.0B Installing Go, Terminal Commands, Git Basics & Your First main.go', '[Beginner Overview]
The Terminal is a text-based way to talk to your computer: `pwd` shows your current folder, `cd` changes folders, and `mkdir` creates a new folder. `git init` starts a time-machine history for your code. `go mod init` creates a `go.mod` ID card for your Go project, and `func main()` inside `package main` is the front door where your program starts running.

[Intermediate Technical]
A Go workspace is anchored by `go.mod`. Executable commands declare `package main` and `func main()`, while reusable libraries declare package names matching their directory names. Separating pure functions from `main()` enables unit testing via `go test`.

[Advanced Internals]
Go compiles directly to native ELF/PE/Mach-O machine code without a virtual machine. `CGO_ENABLED=0 go build -ldflags="-s -w"` produces a statically linked binary that can run inside a 2MB distroless container.

[12 Engineering Decision Pillars]
1. What Is It: The essential developer workflow combining the command-line terminal, Git version control, and the Go toolchain (go mod init, go run, go build, go test).
2. Internal Mechanics: When you run "go run .", the Go toolchain parses go.mod to resolve your module root, compiles all .go files in package main into a temporary native machine-code binary, and executes func main().
3. Why Needed: Backend engineers build, test, and deploy services through the CLI and automated CI pipelines rather than GUI buttons.
4. Why Preferred: Go includes a complete, zero-configuration toolchain (compiler, formatter gofmt, linter go vet, and test runner go test) out of the box.
5. When To Use: At the start of every new Go repository or microservice.
6. When To Avoid: Never write Go code outside a Go module (always initialize go.mod first).
7. Advantages: Fast compilation; reproducible dependency tracking in go.mod/go.sum; safe version history with Git.
8. Disadvantages: Requires familiarity with basic shell commands (cd, ls, mkdir).
9. Alternatives: Makefile or task runners wrapping the underlying go commands.
10. Incorrect Consequences: Using a package name other than "package main" for your entry file causes "go run" to fail because there is no executable entry point.
11. Real-World Usage: Every production Go repository contains a go.mod at its root and entry points under cmd/<service>/main.go.
12. Perf/Sec/Maint/Scale: Maintainability: Keeping main() thin and moving logic into testable functions lets you verify behavior with go test.', '[Terminal: pwd / cd / mkdir] -> [git init & git commit] -> [go mod init example.com/app] -> [main.go] -> [go run .]', 'package app // BUG: Cannot build executable binary from package app

func main() {
	println("Hello Backend")
}', 'package main

import "fmt"

func Greeting(name string) string {
	if name == "" {
		name = "Backend Engineer"
	}
	return fmt.Sprintf("Hello, %s!", name)
}

func main() {
	fmt.Println(Greeting("Go Learner"))
}', 'Declaring `package main` provides the executable entry point while `Greeting(name string) string` can be asserted directly in `main_test.go`.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l0-stage-a-git-go-workspace-ref-1', 'l0-stage-a-git-go-workspace', 'Go Tutorial: Getting Started', 'https://go.dev/doc/tutorial/getting-started', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l0-stage-a-git-go-workspace', 'l0-stage-a-git-go-workspace', 'Write Your First Testable Greeting Function in package main', 'Implement Greeting(name string) string using fmt.Sprintf so that an empty name defaults to "Backend Engineer" and returns "Hello, <name>!".', 'package main

import "fmt"

func Greeting(name string) string {
	// STEP: Default empty name to "Backend Engineer" and format with fmt.Sprintf("Hello, %s!", name)
	return ""
}', 'Invarian: Greeting Default
Invarian: Greeting Custom Name', 'package main

import "fmt"

func Greeting(name string) string {
	if name == "" {
		name = "Backend Engineer"
	}
	return fmt.Sprintf("Hello, %s!", name)
}', 'fmt.Sprintf formats and returns a string without printing to stdout, making it deterministic to test.', 'Create a Git commit (`git add . && git commit -m "feat: add greeting"`) in your local practice repo.') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l0-stage-a-git-go-workspace-tc-1', 'ex-l0-stage-a-git-go-workspace', 1, 'Verify Greeting("") == "Hello, Backend Engineer!"; Verify Greeting("Nadia") == "Hello, Nadia!"', 'if name == ""|name = "Backend Engineer"|fmt.Sprintf("Hello, %s!", name)') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l1-stage-b-syntax-basics', 2, 1, 'mod-l1-stage-b-syntax-basics', 'Stage B — Go Programming Fundamentals (From Zero)', 'Declaring variables with var and :=, understanding static typing (int, int64, float64, bool, string, byte, rune), constants, and why every Go type has a safe default zero value.') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l1-stage-b-variables-types-zerovalues', 'mod-l1-stage-b-syntax-basics', 2, 1, 'l1-stage-b-variables-types-zerovalues', '1.0A Go Variables, Primitive Types, Zero Values & Formatting (fmt)', 'Declaring variables with var and :=, understanding static typing (int, int64, float64, bool, string, byte, rune), constants, and why every Go type has a safe default zero value.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l1-stage-b-variables-types-zerovalues-sec-main', 'l1-stage-b-variables-types-zerovalues', 'core', '1.0A Go Variables, Primitive Types, Zero Values & Formatting (fmt)', '[Beginner Overview]
A variable is a labeled box in memory that holds a specific kind of data (its Type): whole numbers (`int`, `int64`), decimals (`float64`), true/false (`bool`), or text (`string`). Inside a function, `count := 10` creates and fills the box in one step. If you create an empty box with `var count int`, Go automatically puts `0` inside—never random garbage.

[Intermediate Technical]
Go enforces strict nominal and structural typing with zero implicit numeric coercion: adding an `int` and an `int64` is a compile error unless converted (`int64(a) + b`). Strings are immutable UTF-8 byte views; indexing `s[i]` yields a `byte` (`uint8`), while iterating with `range` decodes `rune` (`int32`) Unicode code points.

[Advanced Internals]
The Go Language Specification ("The zero value") guarantees zero-initialization for all allocated storage. The compiler optimizes stack allocations using CPU register assignments (SSA form) and zeroes heap blocks in bulk via `runtime.mallocgc`.

[12 Engineering Decision Pillars]
1. What Is It: Go static type system and variable initialization rules that guarantee every variable in memory starts with a known, deterministic value.
2. Internal Mechanics: When memory is allocated on the stack or heap in Go, it is zeroed before your code sees it: numeric types are 0, booleans are false, strings are "" (len 0), and pointers/slices/maps/interfaces are nil.
3. Why Needed: Uninitialized variables in C/C++ contain random leftover bytes that cause unpredictable bugs and security leaks. Go eliminates uninitialized memory by language specification.
4. Why Preferred: Explicit integer widths (`int64`, `uint32`) and zero-value guarantees make financial, network protocol, and database code predictable.
5. When To Use: Use `var x T` when starting from the zero value, and `x := expr` when initializing from an expression inside a function.
6. When To Avoid: Never use `float64` to store or calculate currency/money—use `int64` minor units (cents/rupiah) to prevent binary rounding errors.
7. Advantages: Compile-time type safety; zero uninitialized memory bugs; clear distinction between `byte` (uint8) and `rune` (int32 Unicode code point).
8. Disadvantages: Go forbids implicit numeric conversions (you must write `int64(x)` explicitly).
9. Alternatives: Arbitrary-precision decimal libraries (`shopspring/decimal`) for multi-currency FX rates.
10. Incorrect Consequences: Using `float64` for money causes `0.1 + 0.2` to equal `0.30000000000000004`, breaking ledger reconciliation.
11. Real-World Usage: All order totals in Go Backend Academy (`orders.total_cents`) use `int64` cents.
12. Perf/Sec/Maint/Scale: Performance: `int64` arithmetic executes in a single CPU clock cycle with zero heap allocation.', 'var n int -> 0 | var ok bool -> false | var s string -> "" | Short init: total := priceCents * qty', 'package billing

// BUG: float64 binary rounding drift corrupts financial balances
func ComputeTotalBad(price float64, qty int) float64 {
	return price * float64(qty)
}', 'package billing

func ComputeInvoiceCents(unitPriceCents int64, quantity int64, discountCents int64) int64 {
	if unitPriceCents <= 0 || quantity <= 0 {
		return 0
	}
	subtotal := unitPriceCents * quantity
	if discountCents > subtotal {
		return 0
	}
	return subtotal - discountCents
}', 'Storing and multiplying integer cents in `int64` is exact up to 92 quadrillion dollars and prevents negative totals via explicit guards.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-stage-b-variables-types-zerovalues-ref-1', 'l1-stage-b-variables-types-zerovalues', 'Go Spec: The Zero Value', 'https://go.dev/ref/spec#The_zero_value', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l1-stage-b-variables-types-zerovalues', 'l1-stage-b-variables-types-zerovalues', 'Exact Invoice Calculation in Integer Cents', 'Implement ComputeInvoiceCents(unitPriceCents int64, quantity int64, discountCents int64) int64. Return 0 if unitPriceCents <= 0 or quantity <= 0, and clamp to 0 if discountCents > subtotal.', 'package billing

func ComputeInvoiceCents(unitPriceCents int64, quantity int64, discountCents int64) int64 {
	// STEP: Guard <= 0 inputs, compute subtotal := unitPriceCents * quantity, and subtract discountCents safely
	return 0
}', 'Invarian: Compute Invoice Cents
Invarian: Compute Invoice Zero And Clamp', 'package billing

func ComputeInvoiceCents(unitPriceCents int64, quantity int64, discountCents int64) int64 {
	if unitPriceCents <= 0 || quantity <= 0 {
		return 0
	}
	subtotal := unitPriceCents * quantity
	if discountCents > subtotal {
		return 0
	}
	return subtotal - discountCents
}', 'Integer arithmetic in int64 cents is deterministic and exact.', 'Format the integer cents as a display string like "$40.00" using fmt.Sprintf("$%d.%02d", cents/100, cents%100).') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-stage-b-variables-types-zerovalues-tc-1', 'ex-l1-stage-b-variables-types-zerovalues', 1, 'Verify ComputeInvoiceCents(1500, 3, 500) == 4000; Verify ComputeInvoiceCents(-10, 2, 0) == 0 and discount > subtotal returns 0', 'unitPriceCents <= 0|discountCents > subtotal|subtotal - discountCents') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l1-stage-b-control-flow-loops-functions', 'mod-l1-stage-b-syntax-basics', 2, 2, 'l1-stage-b-control-flow-loops-functions', '1.0B Conditionals (if/switch), For Loops, Functions & Multiple Return Values', 'Writing clear decision logic with if/else and switch, iterating with Go single loop keyword (for), and designing clean functions that return a result and an error.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l1-stage-b-control-flow-loops-functions-sec-main', 'l1-stage-b-control-flow-loops-functions', 'core', '1.0B Conditionals (if/switch), For Loops, Functions & Multiple Return Values', '[Beginner Overview]
In Go, `if` makes decisions, `switch` picks between multiple options (and stops automatically without needing `break`), and `for` is the only loop word you ever need. Best of all, a Go function can return two things at once: the answer AND an `error` (which is `nil` when everything succeeded).

[Intermediate Technical]
Go `if` statements support a scoped initialization statement (`if v, err := parse(x); err != nil { return err }`) so temporary variables do not leak into the rest of the function body. Guard clauses validate preconditions first, leaving the main business logic unindented.

[Advanced Internals]
Under Go register-based calling convention (Go 1.17+), multiple return values `(bool, error)` are passed back in CPU registers rather than spilling to the stack, making explicit error returns zero-allocation and faster than stack-unwinding exceptions.

[12 Engineering Decision Pillars]
1. What Is It: Go control structures (`if`, `switch`, `for`) and multi-value function signatures (`(T, error)`).
2. Internal Mechanics: Go has no `while` or `do-while` keywords—`for` handles counter loops (`for i := 0; i < n; i++`), condition loops (`for cond`), and infinite loops (`for {}`). Functions return multiple values directly on the call stack or CPU registers.
3. Why Needed: Every backend handler must validate inputs, branch on business rules, loop over records, and report errors clearly to its caller.
4. Why Preferred: Returning `(result, error)` forces callers to acknowledge failure paths at the call site instead of letting hidden exceptions crash the process.
5. When To Use: Use early-return guard clauses at the top of functions and `(T, error)` for any operation that can fail.
6. When To Avoid: Avoid deeply nested `if/else` pyramids; return early on invalid conditions.
7. Advantages: No accidental switch fallthrough; no hidden control-flow jumps from exceptions; crystal-clear error paths.
8. Disadvantages: Requires explicit `if err != nil` checks.
9. Alternatives: Table-driven lookup maps when branching across dozens of static keys.
10. Incorrect Consequences: Ignoring a returned error or conflating invalid input with a normal `false` result hides bugs.
11. Real-World Usage: Every repository and validator function in Go Backend Academy returns `(T, error)` and uses guard clauses.
12. Perf/Sec/Maint/Scale: Maintainability: Guard clauses keep cyclomatic complexity low and make security checks obvious during code review.', 'func ValidateAccountAge(age int) (bool, error) -> [Guard: age < 0 || age > 130] -> [Check: age < 18] -> return true, nil', 'package auth

func CheckAgeBad(age int) bool {
	if age >= 0 {
		if age <= 130 {
			if age >= 18 {
				return true
			}
		}
	}
	return false // BUG: Caller cannot tell if age was 16 or corrupt (-999)
}', 'package auth

import "errors"

func ValidateAccountAge(age int) (bool, error) {
	if age < 0 || age > 130 {
		return false, errors.New("age out of realistic bounds")
	}
	if age < 18 {
		return false, nil
	}
	return true, nil
}', 'The first guard clause rejects impossible inputs with an explicit error; the second handles valid under-18 users; the final line returns adult approval.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-stage-b-control-flow-loops-functions-ref-1', 'l1-stage-b-control-flow-loops-functions', 'Effective Go: Control Structures', 'https://go.dev/doc/effective_go#control-structures', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l1-stage-b-control-flow-loops-functions', 'l1-stage-b-control-flow-loops-functions', 'Guard Clauses & Multiple Return Values', 'Implement ValidateAccountAge(age int) (bool, error) returning an error when age < 0 || age > 130, (false, nil) when age < 18, and (true, nil) otherwise.', 'package auth

import "errors"

func ValidateAccountAge(age int) (bool, error) {
	// STEP: Return error if age < 0 || age > 130, (false, nil) if age < 18, else (true, nil)
	return false, nil
}', 'Invarian: Validate Account Age Bounds
Invarian: Validate Account Age Adult', 'package auth

import "errors"

func ValidateAccountAge(age int) (bool, error) {
	if age < 0 || age > 130 {
		return false, errors.New("age out of realistic bounds")
	}
	if age < 18 {
		return false, nil
	}
	return true, nil
}', 'Multiple return values cleanly separate domain outcomes from validation errors.', 'Write a loop that validates a slice of ages and stops on the first error.') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-stage-b-control-flow-loops-functions-tc-1', 'ex-l1-stage-b-control-flow-loops-functions', 1, 'Verify ValidateAccountAge(-1) returns non-nil error; Verify ValidateAccountAge(16) returns (false, nil) and ValidateAccountAge(21) returns (true, nil)', 'age < 0 || age > 130|errors.New(|return true, nil') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l1-stage-b-slices-maps-iteration', 'mod-l1-stage-b-syntax-basics', 2, 3, 'l1-stage-b-slices-maps-iteration', '1.0C Working with Collections: Arrays, Slices, Maps & Range Loops', 'Storing ordered lists in dynamic slices ([]T), looking up key-value pairs in maps (map[K]V) using the comma-ok idiom, and iterating safely with for...range.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l1-stage-b-slices-maps-iteration-sec-main', 'l1-stage-b-slices-maps-iteration', 'core', '1.0C Working with Collections: Arrays, Slices, Maps & Range Loops', '[Beginner Overview]
A **Slice** (`[]string{"paid", "pending"}`) is a numbered list that can grow with `append()`. A **Map** (`map[string]int`) is a dictionary that connects a Key (like `"paid"`) to a Value (like `3`). Important rule: before putting items into a map, you must create it with `make(map[string]int)` or `map[string]int{}`!

[Intermediate Technical]
When iterating a slice or map with `for k, v := range col`, `v` is a copy of the element. For maps, reading a missing key returns the value type zero value without panicking; use `v, ok := m[k]` when you need to know whether the key was actually present.

[Advanced Internals]
Pre-allocating `make(map[string]int, hint)` computes the required bucket logarithm `B` up front in `runtime.makemap`, eliminating incremental evacuation pauses during bulk inserts.

[12 Engineering Decision Pillars]
1. What Is It: Go two primary collection types: Slices (`[]T`) for ordered sequences and Maps (`map[K]V`) for key-value lookups.
2. Internal Mechanics: A slice is a 24-byte header (`ptr`, `len`, `cap`) pointing to a contiguous backing array. A map is a pointer to a runtime hash table (`runtime.hmap`) organized into buckets of 8 key/value slots.
3. Why Needed: Almost every API endpoint returns a list of items (a slice) or aggregates/looks up records by ID or status (a map).
4. Why Preferred: Slices offer cache-friendly contiguous memory, while built-in maps provide O(1) average lookup with randomized hash seeds to prevent hash-flooding DoS.
5. When To Use: Use `[]T` for ordered collections and JSON arrays; use `map[K]V` for deduplication, frequency counting, and O(1) key lookups.
6. When To Avoid: Never write to an uninitialized (`nil`) map, and never share a map across concurrent goroutines without a `sync.RWMutex`.
7. Advantages: Ergonomic `append()`, `len()`, `for i, v := range`, and `val, ok := m[key]` syntax.
8. Disadvantages: Map iteration order is intentionally randomized by the Go runtime.
9. Alternatives: Sorted slices with `slices.BinarySearch` for small read-heavy lookup tables.
10. Incorrect Consequences: Declaring `var m map[string]int` and writing `m["k"] = 1` crashes the goroutine with `panic: assignment to entry in nil map`.
11. Real-World Usage: Used in `config.Load()` for `CORSAllowedOrigins map[string]bool` and in `Store.GetUserProgress` for lesson status maps.
12. Perf/Sec/Maint/Scale: Performance: Pre-sizing with `make([]T, 0, n)` or `make(map[K]V, n)` avoids repeated reallocations.', 'Slice ([]string) -> ordered list | Map (make(map[string]int)) -> key/value lookup with v, ok := m[k]', 'package stats

func CountStatusesBad(items []string) map[string]int {
	var counts map[string]int // BUG: nil map!
	for _, s := range items {
		counts[s]++ // PANIC: assignment to entry in nil map
	}
	return counts
}', 'package stats

func CountStatuses(items []string) map[string]int {
	counts := make(map[string]int, len(items))
	for _, s := range items {
		if s == "" {
			continue
		}
		counts[s]++
	}
	return counts
}', '`make(map[string]int, len(items))` initializes the hash table so `counts[s]++` safely reads the zero value (0) and stores 1.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-stage-b-slices-maps-iteration-ref-1', 'l1-stage-b-slices-maps-iteration', 'Go Blog: Go Maps in Action', 'https://go.dev/blog/maps', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l1-stage-b-slices-maps-iteration', 'l1-stage-b-slices-maps-iteration', 'Initialize a Map with make() and Count Non-Empty Statuses', 'Implement CountStatuses(items []string) map[string]int that allocates a map using make(map[string]int), skips empty strings "", and increments counts[s]++.', 'package stats

func CountStatuses(items []string) map[string]int {
	// STEP: Initialize map with make(map[string]int), loop with range, skip "", increment counts[s]++
	return nil
}', 'Invarian: Count Statuses Non Nil Map
Invarian: Count Statuses Skips Empty', 'package stats

func CountStatuses(items []string) map[string]int {
	counts := make(map[string]int, len(items))
	for _, s := range items {
		if s == "" {
			continue
		}
		counts[s]++
	}
	return counts
}', 'make() allocates the underlying hash buckets so writes never panic.', 'Return both the frequency map and a slice of unique statuses in the order they first appeared.') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-stage-b-slices-maps-iteration-tc-1', 'ex-l1-stage-b-slices-maps-iteration', 1, 'Verify CountStatuses([]string{"paid", "", "paid"})["paid"] == 2; Verify CountStatuses(nil) returns a non-nil empty map', 'make(map[string]int|for _, s := range items|counts[s]++') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l1-stage-b-structs-methods-pointers', 'mod-l1-stage-b-syntax-basics', 2, 4, 'l1-stage-b-structs-methods-pointers', '1.0D Structs, Methods, Value vs Pointer Receivers & Safe Nil Checks', 'Modeling real-world domain entities (User, Order, Wallet) with structs, attaching methods, understanding what a pointer (*T and &x) actually is, and preventing nil pointer panics.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l1-stage-b-structs-methods-pointers-sec-main', 'l1-stage-b-structs-methods-pointers', 'core', '1.0D Structs, Methods, Value vs Pointer Receivers & Safe Nil Checks', '[Beginner Overview]
A **Struct** is a custom blueprint that groups fields together (like a `Wallet` having a `BalanceCents` field). By default, Go hands functions a *photocopy* of a struct. If you want a method to update the *original* `Wallet` instead of a photocopy, you use a **Pointer** (`*Wallet`), which points to the original box in memory.

[Intermediate Technical]
The `&` operator takes the address of a variable (`w := &Wallet{}`), producing a `*Wallet` pointer. For struct pointers, Go automatically dereferences field access (`w.BalanceCents` is shorthand for `(*w).BalanceCents`). Keep receiver types consistent across all methods of a type.

[Advanced Internals]
Calling a method on a `nil` struct pointer does not panic at the call site—it enters the method with receiver `w == nil`, allowing the method itself to check `if w == nil` and return a graceful error (exactly how `(*Store).Ping` works).

[12 Engineering Decision Pillars]
1. What Is It: Composite data modeling with `struct` types, methods, and explicit memory pointers (`*T` and `&x`).
2. Internal Mechanics: Go passes every function argument and method receiver by value (copying it). When a method declares a pointer receiver `(w *Wallet)`, Go copies the 8-byte memory address so `w.BalanceCents += amt` updates the original struct in place.
3. Why Needed: Backend services model domain entities (`Server`, `Store`, `Order`, `Config`) as structs with methods that encapsulate state transitions.
4. Why Preferred: Explicit pointers (`*T`) vs values (`T`) let you see at the type signature whether a function can mutate your struct or be `nil`.
5. When To Use: Use pointer receivers (`*T`) when a method mutates the receiver or when the struct is large or contains a `sync.Mutex`.
6. When To Avoid: Do not use pointers for small immutable value types like `time.Time` or 2-field coordinate structs.
7. Advantages: Zero hidden boxing; contiguous struct field memory layout; explicit mutability.
8. Disadvantages: Dereferencing a `nil` pointer causes a runtime panic if not guarded.
9. Alternatives: Returning a new updated struct value `(Wallet, error)` in purely functional domain models.
10. Incorrect Consequences: Using a value receiver `(w Wallet)` on a mutating method modifies a temporary copy that is immediately discarded when the method returns.
11. Real-World Usage: `*database.Store` and `*httpplatform.Server` use pointer receivers across all methods.
12. Perf/Sec/Maint/Scale: Reliability: Guarding `if w == nil` at API boundaries prevents nil-dereference crashes.', 'type Wallet struct { BalanceCents int64 } ---> func (w *Wallet) Deposit(amt int64) error (mutates original via pointer)', 'package wallet

type Wallet struct{ BalanceCents int64 }

// BUG: Mutates a temporary copy; caller Wallet balance stays 0!
func (w Wallet) Deposit(amountCents int64) {
	w.BalanceCents += amountCents
}', 'package wallet

import "errors"

type Wallet struct {
	BalanceCents int64
}

func (w *Wallet) Deposit(amountCents int64) error {
	if w == nil {
		return errors.New("wallet pointer is nil")
	}
	if amountCents <= 0 {
		return errors.New("deposit amount must be positive")
	}
	w.BalanceCents += amountCents
	return nil
}', 'The pointer receiver `*Wallet` updates the caller struct in place, while `w == nil` and `amountCents <= 0` enforce domain invariants.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-stage-b-structs-methods-pointers-ref-1', 'l1-stage-b-structs-methods-pointers', 'Go Tour: Pointer Receivers', 'https://go.dev/tour/methods/4', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l1-stage-b-structs-methods-pointers', 'l1-stage-b-structs-methods-pointers', 'Pointer Receiver Mutation with Nil & Positive Amount Guards', 'Implement (w *Wallet) Deposit(amountCents int64) error so that it checks w == nil and amountCents <= 0 before adding amountCents to w.BalanceCents.', 'package wallet

import "errors"

type Wallet struct {
	BalanceCents int64
}

func (w *Wallet) Deposit(amountCents int64) error {
	// STEP: Guard w == nil and amountCents <= 0, then add to w.BalanceCents
	return nil
}', 'Invarian: Wallet Deposit Mutates Balance
Invarian: Wallet Deposit Nil And Negative Guards', 'package wallet

import "errors"

type Wallet struct {
	BalanceCents int64
}

func (w *Wallet) Deposit(amountCents int64) error {
	if w == nil {
		return errors.New("wallet pointer is nil")
	}
	if amountCents <= 0 {
		return errors.New("deposit amount must be positive")
	}
	w.BalanceCents += amountCents
	return nil
}', 'Pointer receivers mutate the underlying struct and can safely check for a nil receiver.', 'Implement `(w *Wallet) Withdraw(amountCents int64) error` that rejects overdrafts (`amountCents > w.BalanceCents`).') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-stage-b-structs-methods-pointers-tc-1', 'ex-l1-stage-b-structs-methods-pointers', 1, 'Verify w.Deposit(500) updates w.BalanceCents to 500; Verify nil receiver and amountCents <= 0 return non-nil errors', 'if w == nil|amountCents <= 0|w.BalanceCents += amountCents') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l1-stage-b-interfaces-errors-fundamentals', 'mod-l1-stage-b-syntax-basics', 2, 5, 'l1-stage-b-interfaces-errors-fundamentals', '1.0E Interfaces, Explicit Error Handling, Custom Errors & Defer', 'Understanding how Go interfaces describe behavior without implements keywords, handling errors explicitly at every step, and guaranteeing cleanup with defer.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l1-stage-b-interfaces-errors-fundamentals-sec-main', 'l1-stage-b-interfaces-errors-fundamentals', 'core', '1.0E Interfaces, Explicit Error Handling, Custom Errors & Defer', '[Beginner Overview]
An **Interface** is a job description: "anything with a `Read(p []byte) (int, error)` method is an `io.Reader`." You do not have to write `implements`—if your struct has the method, it gets the job! The most famous interface in Go is `error`. When an error happens, wrap it with `fmt.Errorf("context: %w", err)` so callers can still check the original cause with `errors.Is`.

[Intermediate Technical]
Sentinel errors (`var ErrNotFound = errors.New("not found")`) represent expected domain conditions. Wrapping them with `%w` constructs an error chain that `errors.Is(err, ErrNotFound)` traverses automatically. Use `defer f.Close()` right after checking `f, err := os.Open(...)` so the file descriptor never leaks.

[Advanced Internals]
In Go 1.20+, `errors.Join(errs...)` combines multiple validation errors into a single error whose `Unwrap() []error` method works seamlessly with `errors.Is` and `errors.As` (used in `config.Load()`).

[12 Engineering Decision Pillars]
1. What Is It: Implicit behavioral contracts (`interface`), structured error chains (`error`, `%w`, `errors.Is`), and scoped resource cleanup (`defer`).
2. Internal Mechanics: Any type that defines the methods listed in an interface satisfies it automatically at compile time. `error` is a built-in interface with one method: `Error() string`. `defer` pushes a cleanup call onto the current goroutine frame so it runs even if the function returns early.
3. Why Needed: Interfaces let your HTTP handlers and services depend on small contracts (like `curriculum.Repository`) instead of hard-wiring a concrete database driver, and `%w` error wrapping preserves root causes across layers.
4. Why Preferred: Consumer-defined interfaces keep packages decoupled without heavyweight Java/C# inheritance hierarchies.
5. When To Use: Define small 1-to-4 method interfaces in the consumer package, wrap lower-level errors with `fmt.Errorf("doing X: %w", err)`, and `defer rows.Close()` immediately after opening a resource.
6. When To Avoid: Do not create huge 20-method interfaces before you have a real consumer or test fake.
7. Advantages: Effortless unit testing with in-memory fakes; preserved error chains; leak-free resource cleanup with `defer`.
8. Disadvantages: Returning a typed `nil` pointer as an `error` interface creates a non-nil interface value (covered in depth in Lesson 1.2).
9. Alternatives: Concrete struct dependencies for purely internal helper utilities.
10. Incorrect Consequences: Formatting errors with `%v` or `%s` instead of `%w` breaks `errors.Is(err, sql.ErrNoRows)`, turning 404 Not Found responses into 500 Internal Server Errors.
11. Real-World Usage: `internal/modules/curriculum/service.go`, `lessons/service.go`, and `assessments/service.go` all define small consumer `Repository` interfaces satisfied by `*database.Store`.
12. Perf/Sec/Maint/Scale: Maintainability: Adding context at each boundary (`"querying user %s: %w"`) produces self-explanatory logs without noisy stack traces.', 'Repository Interface <-- (satisfied implicitly by *database.Store & * FakeRepo) | fmt.Errorf("...: %w", err) -> errors.Is', 'package service

import "fmt"

func WrapBad(orderID string, cause error) error {
	// BUG: %v converts cause to plain text; errors.Is(err, cause) is now false!
	return fmt.Errorf("order %s failed: %v", orderID, cause)
}', 'package service

import (
	"errors"
	"fmt"
)

var ErrEmptyOrderID = errors.New("empty order id")

func ValidateAndWrapOrder(orderID string, cause error) error {
	if orderID == "" {
		return ErrEmptyOrderID
	}
	if cause != nil {
		return fmt.Errorf("processing order %s: %w", orderID, cause)
	}
	return nil
}', 'Returning `ErrEmptyOrderID` for missing IDs and wrapping `cause` with `%w` preserves full `errors.Is` inspectability.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-stage-b-interfaces-errors-fundamentals-ref-1', 'l1-stage-b-interfaces-errors-fundamentals', 'Go Blog: Working with Errors in Go 1.13', 'https://go.dev/blog/go1.13-errors', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l1-stage-b-interfaces-errors-fundamentals', 'l1-stage-b-interfaces-errors-fundamentals', 'Sentinel Error Checking & Error Chain Wrapping with %w', 'Implement ValidateAndWrapOrder(orderID string, cause error) error returning ErrEmptyOrderID when orderID == "" and wrapping non-nil cause with fmt.Errorf("...: %w", cause).', 'package service

import (
	"errors"
	"fmt"
)

var ErrEmptyOrderID = errors.New("empty order id")

func ValidateAndWrapOrder(orderID string, cause error) error {
	// STEP: Return ErrEmptyOrderID if orderID == "", and wrap non-nil cause with %w
	return nil
}', 'Invarian: Validate And Wrap Order Sentinel
Invarian: Validate And Wrap Order Unwrap', 'package service

import (
	"errors"
	"fmt"
)

var ErrEmptyOrderID = errors.New("empty order id")

func ValidateAndWrapOrder(orderID string, cause error) error {
	if orderID == "" {
		return ErrEmptyOrderID
	}
	if cause != nil {
		return fmt.Errorf("processing order %s: %w", orderID, cause)
	}
	return nil
}', '%w wraps the underlying error so errors.Is and errors.As can inspect it.', 'Define a custom struct error `type ValidationError struct { Field string }` implementing `Error() string` and match it with `errors.As`.') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-stage-b-interfaces-errors-fundamentals-tc-1', 'ex-l1-stage-b-interfaces-errors-fundamentals', 1, 'Verify empty orderID returns ErrEmptyOrderID; Verify non-nil cause is wrapped with %w so errors.Is matches', 'fmt.Errorf(|return ErrEmptyOrderID|cause != nil') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l1-stage-b-json-files-unit-testing', 'mod-l1-stage-b-syntax-basics', 2, 6, 'l1-stage-b-json-files-unit-testing', '1.0F JSON Struct Tags, File I/O, Environment Variables & Your First Go Test', 'Encoding and decoding JSON with encoding/json struct tags, reading files and environment variables with os, and writing your first automated test in _test.go.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l1-stage-b-json-files-unit-testing-sec-main', 'l1-stage-b-json-files-unit-testing', 'core', '1.0F JSON Struct Tags, File I/O, Environment Variables & Your First Go Test', '[Beginner Overview]
When a browser sends JSON like `{"title":"Learn Go","done":false}`, Go uses `json.Unmarshal` to fill a struct. Two golden rules: (1) Field names inside the struct MUST start with a Capital letter (`Title`, `Done`) so `encoding/json` is allowed to see them, and (2) always pass a pointer (`&in`) to `json.Unmarshal` so it can fill your struct!

[Intermediate Technical]
Struct tags like `` `json:"title"` `` map snake_case or lowercase JSON keys to PascalCase Go fields, and `` `json:"missing,omitempty"` `` omits empty fields from responses. Unit tests live alongside code in `*_test.go` and fail via `t.Errorf` or `t.Fatalf`.

[Advanced Internals]
To prevent silent contract drift on incoming HTTP requests, wrap the stream in `http.MaxBytesReader` and use `dec := json.NewDecoder(r.Body); dec.DisallowUnknownFields()` followed by a second EOF check (`internal/platform/http/router.go:decodeJSON`).

[12 Engineering Decision Pillars]
1. What Is It: Translating between JSON payloads and Go structs using `encoding/json`, reading configuration/files via `os`, and verifying code with `testing.T`.
2. Internal Mechanics: `encoding/json` uses reflection to map JSON object keys to exported (Capitalized) struct fields decorated with `` `json:"field_name"` `` tags. `go test` compiles files ending in `_test.go` and runs every `func TestXxx(t *testing.T)`.
3. Why Needed: REST APIs communicate in JSON, and no backend function is trustworthy until an automated unit test proves both its happy path and error cases.
4. Why Preferred: Go standard `encoding/json` and `testing` packages require zero third-party assertion or serialization dependencies.
5. When To Use: On every API request/response DTO and every package in your repository.
6. When To Avoid: Never use lowercase (unexported) struct fields on JSON DTOs—`encoding/json` will silently ignore them.
7. Advantages: Zero external dependencies; built-in `go test -v -race` execution; clear struct tag mapping.
8. Disadvantages: Reflection-based JSON decoding is slower than streaming decoders if huge payloads are not bounded.
9. Alternatives: Streaming `json.NewDecoder(r.Body)` with `DisallowUnknownFields()` for HTTP request bodies.
10. Incorrect Consequences: Lowercase struct fields result in empty/zero values after `json.Unmarshal` with no error returned, causing silent data loss.
11. Real-World Usage: Used in `tests/server_integration_test.go` and all DTOs in `internal/shared/`.
12. Perf/Sec/Maint/Scale: Quality: Running `go test -v ./...` catches regressions in sub-second time.', 'JSON Bytes ---> json.Unmarshal(raw, &dto) ---> Exported Fields (`json:"title"`) ---> Validated Domain Struct ---> *_test.go', 'package dto

// BUG: title and done are lowercase (unexported), so json.Unmarshal ignores them!
type CreateTaskInput struct {
	title string `json:"title"`
	done  bool   `json:"done"`
}', 'package dto

import (
	"encoding/json"
	"errors"
)

type CreateTaskInput struct {
	Title string `json:"title"`
	Done  bool   `json:"done"`
}

func ParseTaskJSON(raw []byte) (CreateTaskInput, error) {
	var in CreateTaskInput
	if err := json.Unmarshal(raw, &in); err != nil {
		return CreateTaskInput{}, err
	}
	if in.Title == "" {
		return CreateTaskInput{}, errors.New("title is required")
	}
	return in, nil
}', 'Exported `Title` and `Done` fields are populated by `json.Unmarshal(raw, &in)`, and `in.Title == ""` rejects blank titles immediately.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l1-stage-b-json-files-unit-testing-ref-1', 'l1-stage-b-json-files-unit-testing', 'Go Standard Library: testing', 'https://pkg.go.dev/testing', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l1-stage-b-json-files-unit-testing', 'l1-stage-b-json-files-unit-testing', 'Unmarshal JSON into Exported Struct Fields & Validate Required Title', 'Implement ParseTaskJSON(raw []byte) (CreateTaskInput, error) using json.Unmarshal(raw, &in) and return an error if in.Title == "".', 'package dto

import (
	"encoding/json"
	"errors"
)

type CreateTaskInput struct {
	Title string `json:"title"`
	Done  bool   `json:"done"`
}

func ParseTaskJSON(raw []byte) (CreateTaskInput, error) {
	// STEP: Unmarshal raw into CreateTaskInput and verify in.Title != ""
	return CreateTaskInput{}, nil
}', 'Invarian: Parse Task J S O N Valid
Invarian: Parse Task J S O N Missing Title', 'package dto

import (
	"encoding/json"
	"errors"
)

type CreateTaskInput struct {
	Title string `json:"title"`
	Done  bool   `json:"done"`
}

func ParseTaskJSON(raw []byte) (CreateTaskInput, error) {
	var in CreateTaskInput
	if err := json.Unmarshal(raw, &in); err != nil {
		return CreateTaskInput{}, err
	}
	if in.Title == "" {
		return CreateTaskInput{}, errors.New("title is required")
	}
	return in, nil
}', 'Passing &in allows json.Unmarshal to mutate the struct and populate its exported fields.', 'Write a unit test using `t.Run` subtests for valid JSON, missing title, and invalid syntax.') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l1-stage-b-json-files-unit-testing-tc-1', 'ex-l1-stage-b-json-files-unit-testing', 1, 'Verify valid JSON returns populated CreateTaskInput; Verify empty title or invalid JSON returns a non-nil error', 'json.Unmarshal(raw, &in)|in.Title == ""|return in, nil') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l3-stage-d-first-server', 4, 0, 'mod-l3-stage-d-first-server', 'Stage D — Building Your First Go HTTP Server', 'Step-by-step construction of your first working HTTP backend in Go: http.HandlerFunc, Go 1.22+ method+path routing, reading path parameters, returning JSON with proper status codes, and protecting in-memory state.') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l3-stage-d-first-http-server-crud', 'mod-l3-stage-d-first-server', 4, 0, 'l3-stage-d-first-http-server-crud', '3.0 Building Your First Go HTTP Server: Handlers, ServeMux, Status Codes & JSON CRUD', 'Step-by-step construction of your first working HTTP backend in Go: http.HandlerFunc, Go 1.22+ method+path routing, reading path parameters, returning JSON with proper status codes, and protecting in-memory state.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l3-stage-d-first-http-server-crud-sec-main', 'l3-stage-d-first-http-server-crud', 'core', '3.0 Building Your First Go HTTP Server: Handlers, ServeMux, Status Codes & JSON CRUD', '[Beginner Overview]
An HTTP Handler in Go is a function with two arguments: `r *http.Request` (the incoming envelope from the user) and `w http.ResponseWriter` (the outgoing reply sheet). Always follow the 3-step reply order on `w`: (1) Set headers (`Content-Type: application/json`), (2) Set the status code (`w.WriteHeader(200)`), and (3) Write the JSON body!

[Intermediate Technical]
In Go 1.22+, `mux := http.NewServeMux()` lets you register `"GET /api/v1/lessons/{id}"` and read `id := r.PathValue("id")`. Standardizing a `WriteJSONResponse(w, status, payload)` helper guarantees every endpoint emits UTF-8 JSON with the right status code.

[Advanced Internals]
Under the hood, `http.ResponseWriter` buffers headers until the first `WriteHeader(code)` or `Write(bytes)` call. If `Write(bytes)` is called first, `net/http` implicitly calls `WriteHeader(http.StatusOK)` and sniffs the first 512 bytes for `Content-Type`, locking the header map.

[12 Engineering Decision Pillars]
1. What Is It: The foundational pattern for building a standard-library HTTP server in Go 1.22+ before comparing external routers or middleware chains.
2. Internal Mechanics: `http.ServeMux` matches the HTTP method and URL path pattern (e.g. `"GET /api/v1/tasks/{id}"`), extracts wildcard segments via `r.PathValue("id")`, and invokes your `http.HandlerFunc(w, r)` on the connection goroutine.
3. Why Needed: Every Go web service is built on the `http.Handler` interface (`ServeHTTP(w http.ResponseWriter, r *http.Request)`). Mastering it first makes every router and middleware library transparent.
4. Why Preferred: Go 1.22+ `http.ServeMux` supports method routing (`GET`, `POST`, `DELETE`) and path wildcards (`{id}`) in the standard library with zero external dependencies.
5. When To Use: For all REST APIs, health checks, and microservice HTTP boundaries.
6. When To Avoid: Never write to `w` before setting response headers and status code.
7. Advantages: Zero external dependencies; 100% stdlib compatibility; simple testing with `net/http/httptest`.
8. Disadvantages: Requires writing a small helper (`WriteJSON`) for consistent headers and status codes.
9. Alternatives: Chi or Echo when specialized sub-router mounting is needed (covered in Lesson 3.1).
10. Incorrect Consequences: Calling `w.Write()` or `json.NewEncoder(w).Encode()` before `w.Header().Set(...)` and `w.WriteHeader(status)` flushes HTTP `200 OK` with `text/plain`, ignoring your intended status code and `Content-Type`.
11. Real-World Usage: `internal/platform/http/response.go` (`WriteJSON` and `WriteProblem`) in this repository implements this exact pattern.
12. Perf/Sec/Maint/Scale: Concurrency note: Because each HTTP request runs in its own goroutine, any in-memory map or slice shared by handlers must be guarded by a `sync.RWMutex` or stored in SQLite/PostgreSQL.', 'Client Request -> http.NewServeMux ("GET /api/v1/tasks/{id}") -> Handler(w, r) -> w.Header().Set -> w.WriteHeader -> json.NewEncoder(w).Encode', 'package api

import (
	"encoding/json"
	"net/http"
)

func WriteBad(w http.ResponseWriter, status int, payload any) {
	// BUG: Encode calls w.Write(), which immediately commits 200 OK!
	_ = json.NewEncoder(w).Encode(payload)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
}', 'package api

import (
	"encoding/json"
	"net/http"
)

func WriteJSONResponse(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}', 'Setting `Content-Type` first, then committing `status` via `w.WriteHeader(status)`, and finally streaming JSON into `w` obeys the HTTP wire protocol order.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l3-stage-d-first-http-server-crud-ref-1', 'l3-stage-d-first-http-server-crud', 'Go Blog: Routing Enhancements for Go 1.22', 'https://go.dev/blog/routing-enhancements', 'Go 1.22+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l3-stage-d-first-http-server-crud', 'l3-stage-d-first-http-server-crud', 'Write a Standard net/http JSON Response Helper in Correct Header Order', 'Implement WriteJSONResponse(w http.ResponseWriter, status int, payload any) so it sets Content-Type to application/json, calls w.WriteHeader(status), and encodes payload with json.NewEncoder(w).Encode(payload).', 'package api

import (
	"encoding/json"
	"net/http"
)

func WriteJSONResponse(w http.ResponseWriter, status int, payload any) {
	// STEP: Set Content-Type header, call w.WriteHeader(status), and encode payload as JSON
}', 'Invarian: Write J S O N Response Header And Status Order', 'package api

import (
	"encoding/json"
	"net/http"
)

func WriteJSONResponse(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}', 'Headers must be populated before WriteHeader flushes the HTTP response header block.', 'Register a `GET /api/v1/items/{id}` route on `http.NewServeMux()` that reads `r.PathValue("id")` and responds with `WriteJSONResponse`.') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l3-stage-d-first-http-server-crud-tc-1', 'ex-l3-stage-d-first-http-server-crud', 1, 'Verify Content-Type header is set before WriteHeader(status); Verify json.NewEncoder(w).Encode(payload) writes the JSON body', 'w.Header().Set("Content-Type"|w.WriteHeader(status)|json.NewEncoder(w).Encode(payload)') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l4-stage-e-sql-basics', 5, 0, 'mod-l4-stage-e-sql-basics', 'Stage E — Relational Databases & SQL from Scratch', 'How relational databases organize data into tables with strict constraints, how to filter and combine rows using SELECT/WHERE/INNER JOIN/LEFT JOIN/GROUP BY, and why 1NF-3NF normalization prevents data corruption.') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l4-stage-e-sql-relational-fundamentals', 'mod-l4-stage-e-sql-basics', 5, 0, 'l4-stage-e-sql-relational-fundamentals', '4.0 SQL from Scratch: Tables, Primary/Foreign Keys, SELECT, WHERE, JOIN, GROUP BY & Normalization', 'How relational databases organize data into tables with strict constraints, how to filter and combine rows using SELECT/WHERE/INNER JOIN/LEFT JOIN/GROUP BY, and why 1NF-3NF normalization prevents data corruption.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l4-stage-e-sql-relational-fundamentals-sec-main', 'l4-stage-e-sql-relational-fundamentals', 'core', '4.0 SQL from Scratch: Tables, Primary/Foreign Keys, SELECT, WHERE, JOIN, GROUP BY & Normalization', '[Beginner Overview]
Think of a Relational Database as a set of connected spreadsheets (Tables) with strict guardrails. `customers` holds one row per person with a unique `id` (**Primary Key**). `orders` holds purchases and points back to `customer_id` (**Foreign Key**). `SELECT` picks columns, `WHERE` filters rows, `JOIN` connects `customers` with their `orders`, and `GROUP BY` sums totals per customer.

[Intermediate Technical]
Normalization (1NF, 2NF, 3NF) eliminates redundant data: instead of repeating `customer_email` on every order row (which goes stale when a customer changes their email), `orders` stores `customer_id REFERENCES customers(id)`. Use `INNER JOIN` when both sides must match, and `LEFT JOIN` with `COALESCE` when you also want customers with zero orders.

[Advanced Internals]
In both PostgreSQL and SQLite, declaring `PRIMARY KEY` or `UNIQUE` automatically creates a B-Tree index, but declaring a `FOREIGN KEY` does NOT automatically index the child column! Always create an explicit index on foreign key columns (like `idx_orders_customer_status_created`) to avoid full-table scans on joins and `ON DELETE CASCADE`.

[12 Engineering Decision Pillars]
1. What Is It: The foundational language (SQL) and relational model used by PostgreSQL, SQLite, MySQL, and MariaDB to store, constrain, join, and aggregate persistent data.
2. Internal Mechanics: Data is organized into relations (tables) with typed columns. Primary Keys enforce row identity via a unique B-Tree index; Foreign Keys enforce referential integrity across tables; `CHECK` and `NOT NULL` reject invalid data inside the database engine.
3. Why Needed: Before you can understand MVCC tuple visibility or B-Tree page splits (Lesson 4.1), you must know how to model tables and write `SELECT`, `JOIN`, `GROUP BY`, and bounded `LIMIT` queries.
4. Why Preferred: Declarative SQL with schema constraints guarantees data integrity even if multiple services or scripts access the database.
5. When To Use: Whenever domain entities have structured relationships (users, orders, order_items, payments, progress).
6. When To Avoid: Never store comma-separated lists in a single column (violates 1NF) or run unbounded `SELECT *` queries without a `LIMIT`.
7. Advantages: Strict schema enforcement (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`); expressive joins and aggregations.
8. Disadvantages: Requires upfront schema design and versioned SQL migrations (`migrations/*.sql`).
9. Alternatives: Document or key-value stores when records are self-contained blobs with no cross-entity joins.
10. Incorrect Consequences: Allowing unbounded `LIMIT` or negative `OFFSET` values from query parameters lets a single client request scan millions of rows and crash the database.
11. Real-World Usage: Go Backend Academy uses 20 normalized tables in `migrations/sqlite/001_initial_schema.up.sql` and `migrations/postgres/001_initial_schema.up.sql`.
12. Perf/Sec/Maint/Scale: Scalability: Always clamp pagination `LIMIT` (e.g. default 20, max 100) and index Foreign Key columns.', '[customers (id PK, email UNIQUE)] 1 <--- * [orders (id PK, customer_id FK, status, total_cents)] ---> SELECT ... LEFT JOIN ... GROUP BY', 'package sqlutil

// BUG: Client passing limit=999999999 or offset=-50 causes DB memory exhaustion or SQL error
func RawPageBounds(limit, offset int) (int, int) {
	return limit, offset
}', 'package sqlutil

func ClampPageLimit(limit, offset int) (int, int) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	if offset < 0 {
		offset = 0
	}
	return limit, offset
}', 'Enforcing a sensible default (20), hard ceiling (100), and non-negative offset bounds the worst-case memory and I/O cost of any list query.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l4-stage-e-sql-relational-fundamentals-ref-1', 'l4-stage-e-sql-relational-fundamentals', 'PostgreSQL 17 Tutorial: SQL Language', 'https://www.postgresql.org/docs/current/tutorial-sql.html', 'PostgreSQL 17', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l4-stage-e-sql-relational-fundamentals', 'l4-stage-e-sql-relational-fundamentals', 'Build a Safe SQL Pagination Clause Builder with Bounded Limit', 'Implement ClampPageLimit(limit, offset int) (int, int) so that limit <= 0 defaults to 20, limit > 100 is capped at 100, and offset < 0 is clamped to 0.', 'package sqlutil

func ClampPageLimit(limit, offset int) (int, int) {
	// STEP: Default non-positive limit to 20, cap limit above 100 at 100, and clamp negative offset to 0
	return 0, 0
}', 'Invarian: Clamp Page Limit Defaults And Bounds', 'package sqlutil

func ClampPageLimit(limit, offset int) (int, int) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	if offset < 0 {
		offset = 0
	}
	return limit, offset
}', 'Clamping pagination parameters protects the database from unbounded result sets.', 'Open the Database Comparison Lab & SQL Playground and execute a live `SELECT ... LEFT JOIN ... GROUP BY` query against the sandbox!') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l4-stage-e-sql-relational-fundamentals-tc-1', 'ex-l4-stage-e-sql-relational-fundamentals', 1, 'Verify ClampPageLimit(0, -5) returns (20, 0); Verify ClampPageLimit(500, 40) returns (100, 40)', 'if limit <= 0|limit = 20|return limit, offset') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l5-stage-e-go-sql-crud', 6, 0, 'mod-l5-stage-e-go-sql-crud', 'Stage E — Practical database/sql & Parameterized Queries in Go', 'Connecting a Go service to SQLite or PostgreSQL, executing parameterized SQL statements ($1) to eliminate SQL injection, scanning rows into structs, handling sql.ErrNoRows, and running atomic transactions.') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l5-stage-e-database-sql-crud-basics', 'mod-l5-stage-e-go-sql-crud', 6, 0, 'l5-stage-e-database-sql-crud-basics', '5.0 Connecting Go to SQL: database/sql, QueryContext, Scan, Parameterized Queries & Transactions', 'Connecting a Go service to SQLite or PostgreSQL, executing parameterized SQL statements ($1) to eliminate SQL injection, scanning rows into structs, handling sql.ErrNoRows, and running atomic transactions.', 'beginner', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l5-stage-e-database-sql-crud-basics-sec-main', 'l5-stage-e-database-sql-crud-basics', 'core', '5.0 Connecting Go to SQL: database/sql, QueryContext, Scan, Parameterized Queries & Transactions', '[Beginner Overview]
To talk to a SQL database from Go, you use `*sql.DB`. There are 3 main methods: (1) `ExecContext` to change data (`INSERT`/`UPDATE`/`DELETE`), (2) `QueryRowContext` to fetch 1 row, and (3) `QueryContext` to fetch many rows. Never glue user strings into SQL—always write `$1` in the SQL and pass the variable as an argument!

[Intermediate Technical]
When fetching a single row with `db.QueryRowContext(ctx, q, arg).Scan(&dest)`, `database/sql` returns `sql.ErrNoRows` if no row matched. Translate `errors.Is(err, sql.ErrNoRows)` into a domain `ErrNotFound` so your HTTP layer can return `404 Not Found` instead of `500`.

[Advanced Internals]
For multi-step writes, call `tx, err := db.BeginTx(ctx, nil)`, immediately schedule `defer func() { _ = tx.Rollback() }()`, run all `tx.ExecContext` statements, and finish with `return tx.Commit()`. Once `Commit()` succeeds, the deferred `Rollback()` is a safe no-op.

[12 Engineering Decision Pillars]
1. What Is It: Practical day-to-day usage of Go standard `database/sql` package for safe CRUD queries and transactions before comparing ORMs or code generators.
2. Internal Mechanics: `sql.Open(driver, dsn)` initializes a lazy, thread-safe connection pool (`*sql.DB`). `db.PingContext(ctx)` verifies connectivity. `QueryRowContext`, `QueryContext`, and `ExecContext` borrow a connection from the pool, bind parameters separately from SQL text, and return the connection when `Scan` or `rows.Close()` finishes.
3. Why Needed: Every persistent Go backend must read and write SQL rows without leaking connections or exposing SQL injection vulnerabilities.
4. Why Preferred: Standard `database/sql` works identically across `modernc.org/sqlite` and `jackc/pgx/v5/stdlib` using `$1` positional placeholders.
5. When To Use: For all SQL queries, repository methods, and multi-statement atomic transactions (`db.BeginTx`).
6. When To Avoid: Never build SQL queries with `fmt.Sprintf` or string concatenation `+` on user input, and never call `db.QueryContext` without `defer rows.Close()`.
7. Advantages: Parameter binding prevents user values from being interpreted as SQL commands. Table/column names and ORDER BY cannot be parameterized (use allowlists); context-aware timeouts; built-in connection pooling.
8. Disadvantages: Manual `rows.Scan(&a, &b)` column order must match the `SELECT` list.
9. Alternatives: `sqlc` (generates type-safe Go from SQL) or `pgx/v5` native interface (compared in Lesson 5.1).
10. Incorrect Consequences: Jika rows tidak ditutup dan iterasi berhenti sebelum Next() mengembalikan false (mis. return lebih awal atau break), koneksi database tetap terpakai sampai rows.Close() dipanggil. Selalu defer rows.Close() dan periksa rows.Err() setelah loop.
11. Real-World Usage: Look at `internal/platform/database/db.go` and `content.go` in this repository—every single query uses `QueryContext`/`QueryRowContext`/`ExecContext` with `$1` parameters and `defer rows.Close()`.
12. Perf/Sec/Maint/Scale: Security: `$1` parameter placeholders prevent SQL injection. Reliability: `defer tx.Rollback()` before `tx.Commit()` guarantees transactions never stay open on error.', '*sql.DB Pool -> db.QueryRowContext(ctx, "SELECT id FROM users WHERE email = $1", email).Scan(&id) -> errors.Is(err, sql.ErrNoRows)', 'package repo

import (
	"context"
	"database/sql"
	"fmt"
)

func FindUserBad(ctx context.Context, db *sql.DB, email string) (string, error) {
	// BUG 1: SQL Injection! BUG 2: rows is never closed -> connection pool exhaustion!
	rows, err := db.QueryContext(ctx, fmt.Sprintf("SELECT id FROM users WHERE email = ''%s''", email))
	if err != nil { return "", err }
	var id string
	if rows.Next() { _ = rows.Scan(&id) }
	return id, nil
}', 'package repo

import (
	"context"
	"database/sql"
	"errors"
)

var ErrUserNotFound = errors.New("user not found")

func FindUserIDByEmail(ctx context.Context, db *sql.DB, email string) (string, error) {
	var id string
	err := db.QueryRowContext(ctx, "SELECT id FROM users WHERE email = $1", email).Scan(&id)
	if errors.Is(err, sql.ErrNoRows) {
		return "", ErrUserNotFound
	}
	if err != nil {
		return "", err
	}
	return id, nil
}', '`QueryRowContext` with `$1` binds `email` safely, releases the pooled connection immediately inside `Scan`, and maps `sql.ErrNoRows` to `ErrUserNotFound`.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l5-stage-e-database-sql-crud-basics-ref-1', 'l5-stage-e-database-sql-crud-basics', 'Go Docs: Accessing a Relational Database', 'https://go.dev/doc/tutorial/database-access', 'Go 1.23+', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l5-stage-e-database-sql-crud-basics', 'l5-stage-e-database-sql-crud-basics', 'Query Single Row with Parameter Placeholder & Handle sql.ErrNoRows', 'Implement FindUserIDByEmail(ctx context.Context, db *sql.DB, email string) (string, error) using db.QueryRowContext with a $1 placeholder and translate sql.ErrNoRows to ErrUserNotFound.', 'package repo

import (
	"context"
	"database/sql"
	"errors"
)

var ErrUserNotFound = errors.New("user not found")

func FindUserIDByEmail(ctx context.Context, db *sql.DB, email string) (string, error) {
	// STEP: Call db.QueryRowContext with $1, Scan(&id), and check errors.Is(err, sql.ErrNoRows)
	return "", nil
}', 'Invarian: Find User I D By Email Parameterized
Invarian: Find User I D By Email No Rows', 'package repo

import (
	"context"
	"database/sql"
	"errors"
)

var ErrUserNotFound = errors.New("user not found")

func FindUserIDByEmail(ctx context.Context, db *sql.DB, email string) (string, error) {
	var id string
	err := db.QueryRowContext(ctx, "SELECT id FROM users WHERE email = $1", email).Scan(&id)
	if errors.Is(err, sql.ErrNoRows) {
		return "", ErrUserNotFound
	}
	if err != nil {
		return "", err
	}
	return id, nil
}', 'Parameterized QueryRowContext prevents SQLi and automatically closes the underlying cursor on Scan.', 'Paste the anti-pattern snippet into the Offline Code Review & Diagnostics Lab to see rules GO-SEC-001 and GO-DB-001 trigger!') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l5-stage-e-database-sql-crud-basics-tc-1', 'ex-l5-stage-e-database-sql-crud-basics', 1, 'Verify QueryRowContext uses $1 placeholder and Scan(&id); Verify sql.ErrNoRows is translated to ErrUserNotFound', 'db.QueryRowContext(ctx|errors.Is(err, sql.ErrNoRows)|return "", ErrUserNotFound') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO modules (id, level_id, order_index, slug, title, summary) VALUES ('mod-l10-stage-j-capstones', 11, 99, 'mod-l10-stage-j-capstones', 'Stage J — Progressive Capstone Synthesis (8 Milestones)', 'Synthesizes all Stages A–I into 8 progressive, verifiable capstone milestones with explicit architecture rubrics, failure drills, and production readiness checklists.') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary;
INSERT INTO lessons (id, module_id, level_id, order_index, slug, title, summary, difficulty, last_verified) VALUES ('l10-stage-j-capstone-production-blueprint', 'mod-l10-stage-j-capstones', 11, 99, 'l10-stage-j-capstone-production-blueprint', '10.3 Progressive Capstone Roadmap: From CLI & CRUD API to Production Distributed Service', 'Synthesizes all Stages A–I into 8 progressive, verifiable capstone milestones with explicit architecture rubrics, failure drills, and production readiness checklists.', 'intermediate', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary, order_index = EXCLUDED.order_index;
INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('l10-stage-j-capstone-production-blueprint-sec-main', 'l10-stage-j-capstone-production-blueprint', 'core', '10.3 Progressive Capstone Roadmap: From CLI & CRUD API to Production Distributed Service', '[Beginner Overview]
Here is how everything you have learned fits together into **8 Progressive Capstone Milestones**:
1. **Stage B Capstone**: CLI Task Tracker with JSON File Persistence & Unit Tests
2. **Stage D Capstone**: Hardened `net/http` REST API with Timeouts & Strict JSON Validation
3. **Stage E Capstone**: SQLite/PostgreSQL Repository with Versioned Up/Down Migrations
4. **Stage G Capstone**: Argon2id Authentication, Session/JWT Middleware & BOLA Ownership Guards
5. **Stage F Capstone**: Bounded Worker Pool & Token-Bucket Rate Limiter with Context Cancellation
6. **Stage H Capstone**: Redis Cache-Aside + Singleflight Stampede Protection
7. **Stage H Capstone**: Double-Entry Ledger & Transactional Outbox Relay
8. **Stage I Capstone**: Distroless Docker + `/healthz` vs `/readyz` + Graceful Shutdown

[Intermediate Technical]
At each capstone milestone, verify three things: (1) Happy-path contract tests, (2) Negative/invalid payload rejection (`400`/`401`/`404`/`413`), and (3) Infrastructure failure behavior (DB down -> `/readyz` returns `503`; process restart -> data persists in SQLite/PostgreSQL).

[Advanced Internals]
During a rolling deployment, Kubernetes sends `SIGTERM` to the old pod while simultaneously polling `/readyz`. Marking `ShuttingDown = true` immediately causes `/readyz` to return `503`, removing the pod from `EndpointSlice` before `httpServer.Shutdown(ctx)` finishes draining active requests.

[12 Engineering Decision Pillars]
1. What Is It: The 8-milestone Capstone Synthesis program that guides you from a simple command-line tool to a production-hardened Go backend service.
2. Internal Mechanics: Each milestone layers one new architectural boundary onto the previous one: CLI -> HTTP -> SQL Persistence & Migrations -> Security -> Concurrency -> Caching -> Distributed Reliability -> Container & Kubernetes Readiness.
3. Why Needed: Reading lessons in isolation is not enough; engineers build confidence by assembling complete services and verifying how they behave under failure.
4. Why Preferred: Incremental milestones prevent overwhelm while ensuring every layer (config, DB, HTTP, auth, observability) is genuinely wired and tested.
5. When To Use: As your portfolio capstone progression after completing each curriculum stage.
6. When To Avoid: Do not jump to Milestone 7 (Outbox/Saga) before completing Milestones 1–3 (CLI, HTTP CRUD, SQL Migrations).
7. Advantages: Clear, verifiable deliverables; aligns directly with the 14 production Case Studies in this platform.
8. Disadvantages: Requires writing real tests (`go test -v -race ./...`) at every milestone.
9. Alternatives: Building a single throwaway toy CRUD app with no migrations, timeouts, or readiness checks.
10. Incorrect Consequences: Reporting `200 OK` on `/readyz` when the database is unreachable or migrations have not run causes load balancers to route live traffic into a broken instance.
11. Real-World Usage: Go Backend Academy itself implements Milestone 8: `.env`-driven config, fail-fast DB startup, embedded versioned migrations, strict JSON decoding, and real `/readyz` pings.
12. Perf/Sec/Maint/Scale: Production Readiness: Fail fast on startup misconfiguration; drain in-flight requests on `SIGTERM` before closing the DB pool.', '[M1: CLI Tool] -> [M2: HTTP CRUD] -> [M3: SQL + Migrations] -> [M4: AuthN/RBAC] -> [M5: Worker Pool] -> [M6: Redis Singleflight] -> [M7: Outbox/Saga] -> [M8: K8s Production]', 'package capstone

func HandleReadyzBad() int {
	// BUG: Always returns 200 OK even when DB is down or server is shutting down!
	return 200
}', 'package capstone

import "errors"

type ReadinessGate struct {
	DBConnected  bool
	MigrationsUp bool
	ShuttingDown bool
}

func EvaluateCapstoneReadiness(g ReadinessGate) (int, error) {
	if g.ShuttingDown {
		return 503, errors.New("server is draining connections")
	}
	if !g.DBConnected || !g.MigrationsUp {
		return 503, errors.New("database or migrations not ready")
	}
	return 200, nil
}', 'Returning `503` whenever `ShuttingDown`, `!DBConnected`, or `!MigrationsUp` ensures only healthy, migrated instances receive traffic.') ON CONFLICT (id) DO UPDATE SET body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;
INSERT INTO lesson_references (id, lesson_id, title, url, doc_version, ref_type, last_verified) VALUES ('l10-stage-j-capstone-production-blueprint-ref-1', 'l10-stage-j-capstone-production-blueprint', 'The Twelve-Factor App', 'https://12factor.net/', 'v1.0', 'official', '2026-11-07') ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, url = EXCLUDED.url;
INSERT INTO exercises (id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge) VALUES ('ex-l10-stage-j-capstone-production-blueprint', 'l10-stage-j-capstone-production-blueprint', 'Evaluate Capstone Readiness Gate (DB, Migrations & Graceful Shutdown)', 'Implement EvaluateCapstoneReadiness(g ReadinessGate) (int, error) returning 503 when g.ShuttingDown || !g.DBConnected || !g.MigrationsUp, and (200, nil) when ready.', 'package capstone

import "errors"

type ReadinessGate struct {
	DBConnected  bool
	MigrationsUp bool
	ShuttingDown bool
}

func EvaluateCapstoneReadiness(g ReadinessGate) (int, error) {
	// STEP: Return 503 if ShuttingDown, !DBConnected, or !MigrationsUp; otherwise return 200, nil
	return 0, nil
}', 'Invarian: Evaluate Capstone Readiness200
Invarian: Evaluate Capstone Readiness503 On Shutdown Or D B Down', 'package capstone

import "errors"

type ReadinessGate struct {
	DBConnected  bool
	MigrationsUp bool
	ShuttingDown bool
}

func EvaluateCapstoneReadiness(g ReadinessGate) (int, error) {
	if g.ShuttingDown {
		return 503, errors.New("server is draining connections")
	}
	if !g.DBConnected || !g.MigrationsUp {
		return 503, errors.New("database or migrations not ready")
	}
	return 200, nil
}', 'Readiness probes protect traffic routing during startup, DB outages, and graceful shutdown.', 'Explore all 14 Production Case Studies in the Projects & Case Studies view to see complete schemas, APIs, and failure drills.') ON CONFLICT (id) DO UPDATE SET starter_code = EXCLUDED.starter_code, solution_code = EXCLUDED.solution_code, task_description = EXCLUDED.task_description;
INSERT INTO exercise_test_cases (id, exercise_id, order_index, description, required_pattern) VALUES ('ex-l10-stage-j-capstone-production-blueprint-tc-1', 'ex-l10-stage-j-capstone-production-blueprint', 1, 'Verify healthy ReadinessGate returns (200, nil); Verify ShuttingDown, !DBConnected, or !MigrationsUp returns 503 and non-nil error', 'if g.ShuttingDown|!g.DBConnected || !g.MigrationsUp|return 200, nil') ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern;

INSERT INTO quizzes (id, level_id, title) VALUES ('qz-0-foundations', 1, 'Stage A & C Orientation & HTTP Foundations Quiz'), ('qz-1-go-basics', 2, 'Stage B Go Programming Fundamentals Quiz'), ('qz-4-sql-basics', 5, 'Stage E Relational SQL & database/sql Fundamentals Quiz') ON CONFLICT (id) DO NOTHING;
INSERT INTO quiz_questions (id, quiz_id, order_index, question_text, options_json, correct_index, explanation) VALUES ('qz-0-foundations-q1', 'qz-0-foundations', 1, 'Why should a backend server read its listening port and database credentials from environment variables (or .env) instead of hardcoding them in Go source files?', '["Because Go refuses to compile constants containing port numbers", "So the exact same compiled binary can run across local, staging, and production environments without modifying code or committing secrets to Git", "Because environment variables automatically encrypt network traffic", "Because os.Getenv makes HTTP handlers run faster"]', 1, 'Externalizing configuration via environment variables decouples the artifact from the deployment environment and keeps secrets out of version control.') ON CONFLICT (id) DO NOTHING;
INSERT INTO quiz_questions (id, quiz_id, order_index, question_text, options_json, correct_index, explanation) VALUES ('qz-1-go-basics-q1', 'qz-1-go-basics', 1, 'What happens if you declare `var counts map[string]int` (without `make` or a map literal) and immediately execute `counts["ok"]++`?', '["Go automatically initializes the map and sets counts[\"ok\"] = 1", "It returns a compile-time syntax error", "Reading from a nil map returns the zero value (0), but writing to a nil map triggers a runtime panic", "It silently ignores the write"]', 2, 'In Go, the zero value of a map is nil. Reading from a nil map returns the value type zero value, but assigning to a nil map panics at runtime. Always initialize writable maps with make(map[K]V) or a literal.') ON CONFLICT (id) DO NOTHING;
INSERT INTO quiz_questions (id, quiz_id, order_index, question_text, options_json, correct_index, explanation) VALUES ('qz-4-sql-basics-q1', 'qz-4-sql-basics', 1, 'In Go `database/sql`, why must you write `db.QueryRowContext(ctx, "SELECT id FROM users WHERE email = $1", email)` instead of `fmt.Sprintf("SELECT id FROM users WHERE email = ''''%s''''", email)`?', '["Because fmt.Sprintf is not part of the Go standard library", "Parameterized placeholders ($1) send the SQL command structure and the user data separately over the database protocol, making SQL injection impossible", "Because database/sql only supports integer columns with fmt.Sprintf", "Because $1 automatically creates a B-Tree index"]', 1, 'Parameter binding ($1) separates the compiled SQL AST from untrusted parameter values at the wire protocol level, preventing attackers from injecting SQL commands.') ON CONFLICT (id) DO NOTHING;
-- Strict multi-token server-side required_pattern rules for all 41 exercises (v2.5.0)
UPDATE exercise_test_cases SET required_pattern = 'http.MaxBytesReader(w, r.Body|dec.DisallowUnknownFields()|ReadHeaderTimeout:' WHERE exercise_id = 'ex-l0-backend-http-lifecycle';
UPDATE exercise_test_cases SET required_pattern = 'MaxIdleConnsPerHost:|IdleConnTimeout:|TLSHandshakeTimeout:' WHERE exercise_id = 'ex-l0-dns-tcp-tls-networking';
UPDATE exercise_test_cases SET required_pattern = '*patchMaxConns|*patchTLS|patchMaxConns != nil' WHERE exercise_id = 'ex-l0-rest-json-api-contracts';
UPDATE exercise_test_cases SET required_pattern = 'if name == ""|name = "Backend Engineer"|fmt.Sprintf("Hello, %s!", name)' WHERE exercise_id = 'ex-l0-stage-a-git-go-workspace';
UPDATE exercise_test_cases SET required_pattern = 'strings.TrimSpace(rawMethod)|statusCode < 100|statusCode > 599' WHERE exercise_id = 'ex-l0-stage-a-http-request-response';
UPDATE exercise_test_cases SET required_pattern = 'func DefaultPort() string|return ":8080"' WHERE exercise_id = 'ex-l0-stage-a-what-is-backend';
UPDATE exercise_test_cases SET required_pattern = 'actorUserID == ""|docOwnerID == ""|actorRole == "admin"' WHERE exercise_id = 'ex-l0-stateless-vs-stateful-arch';
UPDATE exercise_test_cases SET required_pattern = 'errors.Is(err, ErrRecordNotFound)|errors.As(err, &qErr)|return 429' WHERE exercise_id = 'ex-l1-interfaces-errors-generics';
UPDATE exercise_test_cases SET required_pattern = 'make([]int, n)|copy(out, src[:n])|n > len(src)' WHERE exercise_id = 'ex-l1-memory-slices-maps-escape';
UPDATE exercise_test_cases SET required_pattern = 'age < 0 || age > 130|errors.New(|return true, nil' WHERE exercise_id = 'ex-l1-stage-b-control-flow-loops-functions';
UPDATE exercise_test_cases SET required_pattern = 'fmt.Errorf(|return ErrEmptyOrderID|cause != nil' WHERE exercise_id = 'ex-l1-stage-b-interfaces-errors-fundamentals';
UPDATE exercise_test_cases SET required_pattern = 'json.Unmarshal(raw, &in)|in.Title == ""|return in, nil' WHERE exercise_id = 'ex-l1-stage-b-json-files-unit-testing';
UPDATE exercise_test_cases SET required_pattern = 'make(map[string]int|for _, s := range items|counts[s]++' WHERE exercise_id = 'ex-l1-stage-b-slices-maps-iteration';
UPDATE exercise_test_cases SET required_pattern = 'if w == nil|amountCents <= 0|w.BalanceCents += amountCents' WHERE exercise_id = 'ex-l1-stage-b-structs-methods-pointers';
UPDATE exercise_test_cases SET required_pattern = 'unitPriceCents <= 0|discountCents > subtotal|subtotal - discountCents' WHERE exercise_id = 'ex-l1-stage-b-variables-types-zerovalues';
UPDATE exercise_test_cases SET required_pattern = 'utf8.DecodeRuneInString(name)|unicode.IsUpper(r)|if name == ""' WHERE exercise_id = 'ex-l1-toolchain-modules-packages';
UPDATE exercise_test_cases SET required_pattern = '(containerLimitMiB * 85) / 100|isShuttingDown || !dbHealthy|return 503' WHERE exercise_id = 'ex-l10-devops-docker-k8s-production';
UPDATE exercise_test_cases SET required_pattern = 'strings.Split(xff, ",")|parts[len(parts)-1]|!isTrustedPeer' WHERE exercise_id = 'ex-l10-reverse-proxy-cicd-rollback-dr';
UPDATE exercise_test_cases SET required_pattern = 'if g.ShuttingDown|!g.DBConnected || !g.MigrationsUp|return 200, nil' WHERE exercise_id = 'ex-l10-stage-j-capstone-production-blueprint';
UPDATE exercise_test_cases SET required_pattern = 'context.WithCancel(ctx)|wg.Add(1)|wg.Wait()' WHERE exercise_id = 'ex-l2-gmp-channels-context-workers';
UPDATE exercise_test_cases SET required_pattern = 'return bufCap > 0 && bufCap <= maxPooledCap' WHERE exercise_id = 'ex-l2-profiling-pprof-benchmarks';
UPDATE exercise_test_cases SET required_pattern = 'for _, n := range nums|sum += n * n|return sum' WHERE exercise_id = 'ex-l2-stage-c-goroutines-channels-waitgroup';
UPDATE exercise_test_cases SET required_pattern = 'atomic.AddInt64(|atomic.LoadInt64(' WHERE exercise_id = 'ex-l2-sync-primitives-atomic-race';
UPDATE exercise_test_cases SET required_pattern = 'w.Header().Set("X-Request-ID"|recover()|http.StatusInternalServerError' WHERE exercise_id = 'ex-l3-middleware-recovery-logging';
UPDATE exercise_test_cases SET required_pattern = 'w.Header().Set("X-Request-ID"|recover()|http.StatusInternalServerError' WHERE exercise_id = 'ex-l3-net-http-routers';
UPDATE exercise_test_cases SET required_pattern = 'w.Header().Set("Content-Type"|w.WriteHeader(status)|json.NewEncoder(w).Encode(payload)' WHERE exercise_id = 'ex-l3-stage-d-first-http-server-crud';
UPDATE exercise_test_cases SET required_pattern = 'strings.TrimSpace(email)|!strings.Contains(clean, "@")|len(password) < 8' WHERE exercise_id = 'ex-l3-stage-d-json-validation-middleware';
UPDATE exercise_test_cases SET required_pattern = 'currentTokens += elapsedSec * ratePerSec|if currentTokens > burstMax|return burstMax' WHERE exercise_id = 'ex-l3-validation-openapi-ratelimit';
UPDATE exercise_test_cases SET required_pattern = 'if fromAccountID < toAccountID|return fromAccountID, toAccountID|return toAccountID, fromAccountID' WHERE exercise_id = 'ex-l4-acid-isolation-mvcc';
UPDATE exercise_test_cases SET required_pattern = 'msSinceLastUserWrite >= 0|msSinceLastUserWrite <= maxReplicaLagMs|return "replica"' WHERE exercise_id = 'ex-l4-partitioning-replication-sharding';
UPDATE exercise_test_cases SET required_pattern = 'strings.ToLower(strings.TrimSpace(email))|limit <= 0|offset < 0' WHERE exercise_id = 'ex-l4-schema-normalization-indexing';
UPDATE exercise_test_cases SET required_pattern = 'if limit <= 0|limit = 20|return limit, offset' WHERE exercise_id = 'ex-l4-stage-e-sql-relational-fundamentals';
UPDATE exercise_test_cases SET required_pattern = 'avail := pgMaxConns - reservedSuperuserConns|avail / replicaCount|maxOpen / 2' WHERE exercise_id = 'ex-l5-db-ecosystem-comparison';
UPDATE exercise_test_cases SET required_pattern = 'strings.Contains(upper, "CREATE INDEX")|!strings.Contains(upper, "CONCURRENTLY")|!strings.Contains(upper, "LOCK_TIMEOUT")' WHERE exercise_id = 'ex-l5-migrations-transactions-prepared';
UPDATE exercise_test_cases SET required_pattern = 'allowedColumns[sortBy]|strings.EqualFold(sortDir, "DESC")|ORDER BY' WHERE exercise_id = 'ex-l5-sql-injection-pool-tuning';
UPDATE exercise_test_cases SET required_pattern = 'db.QueryRowContext(ctx|errors.Is(err, sql.ErrNoRows)|return "", ErrUserNotFound' WHERE exercise_id = 'ex-l5-stage-e-database-sql-crud-basics';
UPDATE exercise_test_cases SET required_pattern = 'roleMatrix[role]|if p == requiredPerm|return true' WHERE exercise_id = 'ex-l6-oauth2-oidc-rbac-abac';
UPDATE exercise_test_cases SET required_pattern = 'netip.ParseAddr(ip)|addr.IsLoopback()|subtle.ConstantTimeCompare(' WHERE exercise_id = 'ex-l6-security-auth-owasp';
UPDATE exercise_test_cases SET required_pattern = 'strings.HasPrefix(authHeader, prefix)|strings.TrimSpace(strings.TrimPrefix(authHeader, prefix))' WHERE exercise_id = 'ex-l6-stage-f-password-hashing-bearer-auth';
UPDATE exercise_test_cases SET required_pattern = 'items[key] = val|v, ok := items[key]|return v, ok' WHERE exercise_id = 'ex-l7-integration-testcontainers-ci';
UPDATE exercise_test_cases SET required_pattern = 'strings.Fields(strings.ToLower(title))|strings.Join(words, "-")' WHERE exercise_id = 'ex-l7-stage-g-table-driven-tests-httptest';
UPDATE exercise_test_cases SET required_pattern = 'for byteIdx := range s|if count == maxRunes|return s[:byteIdx]' WHERE exercise_id = 'ex-l7-testing-fuzzing-benchmarks';
UPDATE exercise_test_cases SET required_pattern = '(subtotalCents * couponBasisPoints) / 10000|(discounted * taxBasisPoints) / 10000|return discounted + tax, nil' WHERE exercise_id = 'ex-l8-clean-hexagonal-ddd';
UPDATE exercise_test_cases SET required_pattern = '!strings.HasPrefix(referencedTable, moduleName+"_")' WHERE exercise_id = 'ex-l8-modular-monolith-cqrs-boundaries';
UPDATE exercise_test_cases SET required_pattern = 'if a == nil || b == nil|if a.Currency != b.Currency|Cents: a.Cents + b.Cents' WHERE exercise_id = 'ex-l8-stage-h-handler-service-repo-layers';
UPDATE exercise_test_cases SET required_pattern = 'currentState == "HALF_OPEN" && consecutiveFailures >= 1|consecutiveFailures >= threshold|return currentState' WHERE exercise_id = 'ex-l9-caching-queues-outbox-sagas';
UPDATE exercise_test_cases SET required_pattern = 'len(parts) != 4|parts[0] != "00"|0000000000000000' WHERE exercise_id = 'ex-l9-grpc-websockets-otel-tracing';
UPDATE exercise_test_cases SET required_pattern = 'if attempt < 1|delay := baseMs << (attempt - 1)|if delay > maxMs' WHERE exercise_id = 'ex-l9-stage-i-redis-cache-aside-backoff';
