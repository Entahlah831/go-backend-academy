# ADR 001: Replace Cloud/Fake AI Mentor with Offline Go Code Review & Diagnostics Lab

* **Status**: Accepted (2026-11-07)
* **Context**: The initial prototype included a feature called "AI Mentor" backed by hardcoded `strings.Contains` checks. Pretending static string checks are "AI" is misleading, and requiring a cloud LLM API key breaks self-contained offline learning.
* **Decision**:
  1. Remove the "AI Mentor" branding and `internal/mentor` package.
  2. Replace it with the **Go Code Review & Diagnostics Lab** (`internal/modules/diagnostics`), which runs 100% offline using deterministic rules (`GO-SEC-*`, `GO-CONC-*`, `GO-DB-*`, `GO-ERR-*`, `GO-PERF-*`) and, when the Go toolchain is present on the host, executes `gofmt`, `go vet`, and `staticcheck` in an isolated temporary directory.
  3. Classify every finding transparently (`confirmed_diagnostic`, `potential_issue`, `educational_heuristic`, `no_finding_detected`) and always display the limitations of static analysis so users never mistake the absence of a heuristic match for proof of security.
  4. Provide an optional `AI_PROVIDER=none` interface stub that can connect to a local `Ollama` instance (`http://localhost:11434`) in the future without ever requiring API keys or network access during normal operation.
