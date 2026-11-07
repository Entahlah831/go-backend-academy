package diagnostics

import (
	"context"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"github.com/gobackendacademy/platform/internal/modules/exercises"
)

// FindingClassification distinguishes deterministic tool output from educational heuristics.
// Importantly, the absence of findings is NEVER reported as a guarantee that code is vulnerability-free.
type FindingClassification string

const (
	ClassificationConfirmedDiagnostic  FindingClassification = "confirmed_diagnostic"
	ClassificationPotentialIssue       FindingClassification = "potential_issue"
	ClassificationEducationalHeuristic FindingClassification = "educational_heuristic"
	ClassificationNoFindingDetected    FindingClassification = "no_finding_detected"
)

type DiagnosticFinding struct {
	RuleID              string                `json:"rule_id"`
	Classification      FindingClassification `json:"classification"`
	Severity            string                `json:"severity"` // "critical", "high", "medium", "info"
	Line                int                   `json:"line,omitempty"`
	Title               string                `json:"title"`
	Description         string                `json:"description"`
	WhyItMatters        string                `json:"why_it_matters"`
	SuggestedCorrection string                `json:"suggested_correction"`
	CorrectedExample    string                `json:"corrected_example,omitempty"`
	RelatedLessonID     string                `json:"related_lesson_id"`
	ReferenceURL        string                `json:"reference_url"`
}

type AnalysisReport struct {
	OfflineMode               bool                `json:"offline_mode"`
	ToolchainExecuted         bool                `json:"toolchain_executed"`
	ToolchainOutput           string              `json:"toolchain_output,omitempty"`
	SummaryStatus             string              `json:"summary_status"`
	Findings                  []DiagnosticFinding `json:"findings"`
	StaticAnalysisLimitations string              `json:"static_analysis_limitations"`
	OptionalAIStatus          string              `json:"optional_ai_status"`
	AnalyzedAt                time.Time           `json:"analyzed_at"`
}

// OptionalAssistantProvider defines the strictly optional local-only AI interface (default: "none").
// The platform never depends on this provider to operate.
type OptionalAssistantProvider interface {
	Name() string
	CheckConnection(ctx context.Context) error
}

type NoopAssistantProvider struct{}

func (NoopAssistantProvider) Name() string                            { return "none" }
func (NoopAssistantProvider) CheckConnection(_ context.Context) error { return nil }

type OllamaLocalProvider struct {
	BaseURL string
	Model   string
}

func (p OllamaLocalProvider) Name() string { return "ollama" }
func (p OllamaLocalProvider) CheckConnection(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, strings.TrimRight(p.BaseURL, "/")+"/api/tags", nil)
	if err != nil {
		return err
	}
	client := &http.Client{Timeout: 2 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	return nil
}

var (
	reSQLSprintf     = regexp.MustCompile(`(?i)fmt\.Sprintf\s*\(\s*["` + "`" + `][^"` + "`" + `]*\b(SELECT|INSERT|UPDATE|DELETE)\b`)
	reSQLConcat      = regexp.MustCompile(`(?i)["` + "`" + `]\s*\b(SELECT|INSERT|UPDATE|DELETE)\b[^"` + "`" + `]*["` + "`" + `]\s*\+`)
	reQueryAssign    = regexp.MustCompile(`([A-Za-z_][A-Za-z0-9_]*)\s*(?:,\s*[A-Za-z0-9_]+\s*)?:?=\s*[A-Za-z0-9_.]*\.Query(?:Context)?\s*\(`)
	reEmptyClient    = regexp.MustCompile(`&?\bhttp\.Client\s*\{\s*\}`)
	reClientLiteral  = regexp.MustCompile(`&?\bhttp\.Client\s*\{([^}]*)\}`)
	reIgnoredErrCall = regexp.MustCompile(`[A-Za-z0-9_]+\s*,\s*_\s*:?=\s*(?:os|io|json|strconv|http|exec|net|sql)\.[A-Za-z0-9_]+\s*\(`)
	reGoFuncBody     = regexp.MustCompile(`go\s+func\s*\([^)]*\)\s*\{([\s\S]*?)\}\s*\(`)
	reUnsyncMutate   = regexp.MustCompile(`\b[A-Za-z_][A-Za-z0-9_]*\s*(\+\+|--|\+=|-=)`)
	reHardcodedSecret = regexp.MustCompile(`(?i)\b(?:const|var)?\s*[A-Za-z0-9_]*(?:password|passwd|secret|api_?key|auth_?token|jwt_?secret|private_?key)\s*(?::=|=)\s*["` + "`" + `][^"` + "`" + `]+["` + "`" + `]`)
	reHardcodedPort   = regexp.MustCompile(`(?i)\b(?:const|var)\s+[A-Za-z0-9_]*(?:Port|ServerPort|ListenPort)\s*=\s*["` + "`" + `][^"` + "`" + `]+["` + "`" + `]`)
)

type Analyzer struct {
	enableLocalToolchain bool
	sandboxTimeout       time.Duration
	aiProvider           OptionalAssistantProvider
}

func NewAnalyzer(enableLocalToolchain bool, sandboxTimeout time.Duration, aiProviderName, aiBaseURL, aiModel string) *Analyzer {
	var provider OptionalAssistantProvider = NoopAssistantProvider{}
	if aiProviderName == "ollama" {
		provider = OllamaLocalProvider{BaseURL: aiBaseURL, Model: aiModel}
	}
	return &Analyzer{
		enableLocalToolchain: enableLocalToolchain,
		sandboxTimeout:       sandboxTimeout,
		aiProvider:           provider,
	}
}

func hasRegexpCompileInsideFunc(uncommented string) (bool, int) {
	lines := strings.Split(uncommented, "\n")
	inFunc := false
	braceDepth := 0
	for idx, ln := range lines {
		if strings.Contains(ln, "func ") || strings.Contains(ln, "func(") {
			inFunc = true
		}
		if inFunc && braceDepth > 0 && (strings.Contains(ln, "regexp.MustCompile(") || strings.Contains(ln, "regexp.Compile(")) {
			return true, idx + 1
		}
		braceDepth += strings.Count(ln, "{") - strings.Count(ln, "}")
		if braceDepth <= 0 {
			braceDepth = 0
			inFunc = false
		}
		if inFunc && braceDepth > 0 && (strings.Contains(ln, "regexp.MustCompile(") || strings.Contains(ln, "regexp.Compile(")) {
			return true, idx + 1
		}
	}
	return false, 0
}

func (a *Analyzer) AnalyzeCode(ctx context.Context, code string) AnalysisReport {
	var findings []DiagnosticFinding
	uncommented := exercises.StripGoComments(code)
	lines := strings.Split(uncommented, "\n")

	findLine := func(substr string) int {
		for idx, ln := range lines {
			if strings.Contains(ln, substr) {
				return idx + 1
			}
		}
		return 1
	}

	findRegexLine := func(re *regexp.Regexp) int {
		for idx, ln := range lines {
			if re.MatchString(ln) {
				return idx + 1
			}
		}
		return 1
	}

	// Rule GO-SEC-001: SQL String Interpolation or Concatenation (only when SQL is inside Sprintf or concatenated with +)
	if reSQLSprintf.MatchString(uncommented) || reSQLConcat.MatchString(uncommented) {
		line := findRegexLine(reSQLSprintf)
		if !reSQLSprintf.MatchString(uncommented) {
			line = findRegexLine(reSQLConcat)
		}
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-SEC-001",
			Classification:      ClassificationPotentialIssue,
			Severity:            "critical",
			Line:                line,
			Title:               "Dynamic SQL String Interpolation or Concatenation Detected",
			Description:         "Constructing a SQL query string using fmt.Sprintf or '+' string concatenation risks SQL Injection if any input originates from an external caller.",
			WhyItMatters:        "SQL Injection allows attackers to alter query predicates, bypass authentication, or exfiltrate entire tables.",
			SuggestedCorrection: "Pass parameters separately from the SQL statement using driver placeholders ($1, $2 in PostgreSQL or ? in SQLite/MySQL).",
			CorrectedExample:    `row := db.QueryRowContext(ctx, "SELECT id, email FROM users WHERE email = $1", userInput)`,
			RelatedLessonID:     "l6-security-auth-owasp",
			ReferenceURL:        "https://go.dev/doc/database/sql-injection",
		})
	}

	// Rule GO-DB-001: Unclosed sql.Rows cursor (tracks specific cursor variable name so unrelated f.Close() cannot mask a leak)
	if strings.Contains(uncommented, ".Query(") || strings.Contains(uncommented, ".QueryContext(") {
		leaked := false
		matches := reQueryAssign.FindAllStringSubmatch(uncommented, -1)
		if len(matches) > 0 {
			for _, m := range matches {
				varName := m[1]
				if varName != "_" && !strings.Contains(uncommented, varName+".Close()") {
					leaked = true
					break
				}
			}
		} else if !strings.Contains(uncommented, ".Close()") {
			leaked = true
		}
		if leaked {
			line := findLine(".QueryContext(")
			if !strings.Contains(uncommented, ".QueryContext(") {
				line = findLine(".Query(")
			}
			findings = append(findings, DiagnosticFinding{
				RuleID:              "GO-DB-001",
				Classification:      ClassificationPotentialIssue,
				Severity:            "high",
				Line:                line,
				Title:               "sql.Rows Cursor Opened Without defer rows.Close()",
				Description:         "Query or QueryContext returns an *sql.Rows cursor that holds a database connection until its own .Close() method is called.",
				WhyItMatters:        "If the function returns early or closes an unrelated resource instead of the rows cursor, the pooled DB connection is permanently leaked until MaxOpenConns freezes.",
				SuggestedCorrection: "Immediately after checking if err != nil, call defer rows.Close(), and check rows.Err() after the loop.",
				CorrectedExample:    `rows, err := db.QueryContext(ctx, query, arg); if err != nil { return err }; defer rows.Close()`,
				RelatedLessonID:     "l5-db-ecosystem-comparison",
				ReferenceURL:        "https://go.dev/doc/database/querying",
			})
		}
	}

	// Rule GO-DB-002: sql.Open without connection pool bounds
	if strings.Contains(uncommented, "sql.Open(") && !strings.Contains(uncommented, "SetMaxOpenConns(") {
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-DB-002",
			Classification:      ClassificationEducationalHeuristic,
			Severity:            "medium",
			Line:                findLine("sql.Open("),
			Title:               "sql.Open Initialized Without Connection Pool Bounds",
			Description:         "sql.Open defaults to MaxOpenConns = 0 (unlimited), allowing traffic spikes to exhaust database max_connections.",
			WhyItMatters:        "Unbounded connection opening under load triggers 'too many clients' errors on PostgreSQL/MySQL.",
			SuggestedCorrection: "Configure db.SetMaxOpenConns(25), db.SetMaxIdleConns(10), and db.SetConnMaxLifetime(30*time.Minute).",
			CorrectedExample:    `db.SetMaxOpenConns(25); db.SetMaxIdleConns(10); db.SetConnMaxLifetime(30 * time.Minute)`,
			RelatedLessonID:     "l5-db-ecosystem-comparison",
			ReferenceURL:        "https://go.dev/doc/database/manage-connections",
		})
	}

	// Rule GO-SEC-004: Public exposure of net/http/pprof on DefaultServeMux
	if strings.Contains(uncommented, `"net/http/pprof"`) {
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-SEC-004",
			Classification:      ClassificationEducationalHeuristic,
			Severity:            "high",
			Line:                findLine(`"net/http/pprof"`),
			Title:               "Blank Import of net/http/pprof Registers Handlers on DefaultServeMux",
			Description:         "Importing net/http/pprof automatically mounts /debug/pprof/* on http.DefaultServeMux.",
			WhyItMatters:        "If DefaultServeMux is exposed publicly, attackers can download heap dumps and goroutine stacks (OWASP API8:2023 Security Misconfiguration).",
			SuggestedCorrection: "Use an explicit http.NewServeMux() for public traffic and bind pprof only to 127.0.0.1:6060.",
			CorrectedExample:    `adminMux := http.NewServeMux(); _ = http.ListenAndServe("127.0.0.1:6060", adminMux)`,
			RelatedLessonID:     "l2-profiling-pprof-benchmarks",
			ReferenceURL:        "https://pkg.go.dev/net/http/pprof",
		})
	}

	// Rule GO-ERR-001: Explicit panic() in application logic
	if strings.Contains(uncommented, "panic(") {
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-ERR-001",
			Classification:      ClassificationEducationalHeuristic,
			Severity:            "medium",
			Line:                findLine("panic("),
			Title:               "Explicit panic() Used for Error Handling",
			Description:         "Detected panic() call. In Go, normal operational failures (I/O, database, validation) should return explicit error values.",
			WhyItMatters:        "Uncaught panics crash the process or abort the active request goroutine abruptly.",
			SuggestedCorrection: `Return a wrapped error with fmt.Errorf("...: %w", err) so callers can inspect it with errors.Is / errors.As.`,
			CorrectedExample:    `if err != nil { return fmt.Errorf("executing query: %w", err) }`,
			RelatedLessonID:     "l1-interfaces-errors-generics",
			ReferenceURL:        "https://go.dev/blog/go1.13-errors",
		})
	}

	// Rule GO-ERR-002: Ignored error via blank identifier '_'
	if reIgnoredErrCall.MatchString(uncommented) {
		// Allow db.Query when rows.Close() is already properly handled in isolated SQL demos unless os/io/json/etc.
		line := findRegexLine(reIgnoredErrCall)
		matchedLine := lines[line-1]
		isClosedDBQuery := (strings.Contains(matchedLine, ".Query(") || strings.Contains(matchedLine, ".QueryContext(")) && strings.Contains(uncommented, "rows.Close()")
		if !isClosedDBQuery {
			findings = append(findings, DiagnosticFinding{
				RuleID:              "GO-ERR-002",
				Classification:      ClassificationPotentialIssue,
				Severity:            "high",
				Line:                line,
				Title:               "Error Return Value Explicitly Discarded With Blank Identifier (_)",
				Description:         "Assigning a fallible I/O, OS, or parsing call's error return value to '_' silently ignores operational failures.",
				WhyItMatters:        "Proceeding after a failed os.Open, db.Exec, or json.Unmarshal leads to nil-pointer dereferences or silent data corruption.",
				SuggestedCorrection: "Capture and check 'if err != nil' before using the returned resource.",
				CorrectedExample:    `f, err := os.Open("config.json"); if err != nil { return err }; defer f.Close()`,
				RelatedLessonID:     "l1-interfaces-errors-generics",
				ReferenceURL:        "https://go.dev/doc/effective_go#errors",
			})
		}
	}

	// Rule GO-CONC-001: Unbounded goroutine without context cancellation or WaitGroup in uncommented code
	if strings.Contains(uncommented, "go func(") && !strings.Contains(uncommented, "ctx") && !strings.Contains(uncommented, "Context") && !strings.Contains(uncommented, "WaitGroup") {
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-CONC-001",
			Classification:      ClassificationPotentialIssue,
			Severity:            "high",
			Line:                findLine("go func("),
			Title:               "Goroutine Spawned Without Context Cancellation or WaitGroup Lifecycle",
			Description:         "Spawning an anonymous goroutine without a termination signal or WaitGroup makes its lifetime unbounded.",
			WhyItMatters:        "Blocked background goroutines (such as unbuffered channel sends with no receiver) never get garbage collected, leaking memory forever.",
			SuggestedCorrection: "Pass context.Context into the goroutine, select on <-ctx.Done(), and track completion via sync.WaitGroup or errgroup.Group.",
			CorrectedExample:    `wg.Add(1); go func() { defer wg.Done(); _ = doWork(ctx) }()`,
			RelatedLessonID:     "l2-gmp-channels-context-workers",
			ReferenceURL:        "https://go.dev/blog/pipelines",
		})
	}

	// Rule GO-CONC-002: Unsynchronized shared variable mutation inside goroutine (Data Race)
	if goBodies := reGoFuncBody.FindAllStringSubmatch(uncommented, -1); len(goBodies) > 0 {
		for _, gb := range goBodies {
			body := gb[1]
			if reUnsyncMutate.MatchString(body) && !strings.Contains(uncommented, ".Lock()") && !strings.Contains(uncommented, "atomic.") {
				findings = append(findings, DiagnosticFinding{
					RuleID:              "GO-CONC-002",
					Classification:      ClassificationPotentialIssue,
					Severity:            "critical",
					Line:                findLine("go func("),
					Title:               "Unsynchronized Shared Variable Mutation Inside Goroutine (Data Race)",
					Description:         "A goroutine mutates state (e.g. ++, --, +=) without a sync.Mutex lock or sync/atomic operation. Note that sync.WaitGroup only waits for completion and does not synchronize memory writes.",
					WhyItMatters:        "Concurrent unsynchronized read-modify-write operations corrupt memory and trigger undefined behavior under the Go Memory Model.",
					SuggestedCorrection: "Use atomic.Int64 / atomic.AddInt64 or guard the shared variable with a sync.Mutex (mu.Lock() / defer mu.Unlock()).",
					CorrectedExample:    `var n atomic.Int64; go func() { defer wg.Done(); n.Add(1) }()`,
					RelatedLessonID:     "l2-gmp-channels-context-workers",
					ReferenceURL:        "https://go.dev/doc/articles/race_detector",
				})
				break
			}
		}
	}

	// Rule GO-SEC-003: Default HTTP server or client without timeouts (including &http.Client{} without Timeout)
	hasUntimedClient := reEmptyClient.MatchString(uncommented)
	if !hasUntimedClient {
		for _, m := range reClientLiteral.FindAllStringSubmatch(uncommented, -1) {
			if !strings.Contains(m[1], "Timeout") {
				hasUntimedClient = true
				break
			}
		}
	}
	if strings.Contains(uncommented, "http.ListenAndServe(") || strings.Contains(uncommented, "http.Get(") || hasUntimedClient {
		line := findLine("http.ListenAndServe(")
		if !strings.Contains(uncommented, "http.ListenAndServe(") {
			if strings.Contains(uncommented, "http.Get(") {
				line = findLine("http.Get(")
			} else {
				line = findLine("http.Client")
			}
		}
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-SEC-003",
			Classification:      ClassificationPotentialIssue,
			Severity:            "high",
			Line:                line,
			Title:               "Unbounded HTTP Timeout (http.ListenAndServe, http.Get, or http.Client{} Without Timeout)",
			Description:         "http.ListenAndServe, http.DefaultClient, and &http.Client{} without an explicit Timeout field have zero timeouts by default.",
			WhyItMatters:        "Leaves servers vulnerable to Slowloris socket exhaustion and clients vulnerable to hanging forever on stalled peers.",
			SuggestedCorrection: "Configure explicit timeouts on &http.Server{ReadHeaderTimeout: 5*time.Second, ReadTimeout: 10*time.Second} and &http.Client{Timeout: 10*time.Second}.",
			CorrectedExample:    `client := &http.Client{Timeout: 10 * time.Second}`,
			RelatedLessonID:     "l3-net-http-routers",
			ReferenceURL:        "https://pkg.go.dev/net/http#Client",
		})
	}

	// Rule GO-SEC-002: Unbounded request body read
	if (strings.Contains(uncommented, "io.ReadAll(r.Body)") || strings.Contains(uncommented, "json.NewDecoder(r.Body)")) && !strings.Contains(uncommented, "MaxBytesReader") {
		line := findLine("io.ReadAll(r.Body)")
		if !strings.Contains(uncommented, "io.ReadAll(r.Body)") {
			line = findLine("json.NewDecoder(r.Body)")
		}
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-SEC-002",
			Classification:      ClassificationPotentialIssue,
			Severity:            "high",
			Line:                line,
			Title:               "Request Body Read Without http.MaxBytesReader",
			Description:         "Reading r.Body without wrapping it in http.MaxBytesReader allows unbounded payload sizes.",
			WhyItMatters:        "Enables memory exhaustion Denial-of-Service (OWASP API4:2023 Unrestricted Resource Consumption).",
			SuggestedCorrection: "Wrap r.Body = http.MaxBytesReader(w, r.Body, 1<<20) before decoding.",
			CorrectedExample:    `r.Body = http.MaxBytesReader(w, r.Body, 1<<20)`,
			RelatedLessonID:     "l0-backend-http-lifecycle",
			ReferenceURL:        "https://pkg.go.dev/net/http#MaxBytesReader",
		})
	}

	// Rule GO-PERF-001: regexp.MustCompile inside function body (ignoring package-level var declarations)
	if inFunc, line := hasRegexpCompileInsideFunc(uncommented); inFunc {
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-PERF-001",
			Classification:      ClassificationEducationalHeuristic,
			Severity:            "medium",
			Line:                line,
			Title:               "regexp.MustCompile Called Inside Function Scope",
			Description:         "Compiling a static regular expression inside a function or HTTP handler rebuilds the NFA automaton on every invocation.",
			WhyItMatters:        "Increases CPU and heap allocations dramatically on hot paths compared to package-level initialization.",
			SuggestedCorrection: "Hoist var pattern = regexp.MustCompile(...) to package-level scope.",
			CorrectedExample:    "var idRe = regexp.MustCompile(`^[a-z0-9]+$`)",
			RelatedLessonID:     "l2-profiling-pprof-benchmarks",
			ReferenceURL:        "https://pkg.go.dev/regexp",
		})
	}

	// Rule GO-SEC-007: Hardcoded Secret / Credential Literal
	if reHardcodedSecret.MatchString(uncommented) {
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-SEC-007",
			Classification:      ClassificationConfirmedDiagnostic,
			Severity:            "high",
			Line:                findRegexLine(reHardcodedSecret),
			Title:               "Hardcoded Secret or Credential Detected",
			Description:         "A password, API key, JWT secret, or private token appears hardcoded as a string literal in source code.",
			WhyItMatters:        "Committing secrets to source control or container images risks credential exposure and prevents rotation without recompilation.",
			SuggestedCorrection: "Read credentials from environment variables (e.g. os.Getenv) or a secure secrets manager.",
			CorrectedExample:    `password := os.Getenv("DATABASE_PASSWORD")`,
			RelatedLessonID:     "l0-backend-http-lifecycle",
			ReferenceURL:        "https://owasp.org/www-community/Source_Code_Analysis_Tools",
		})
	}

	// Rule GO-HTTP-001: Hardcoded Network Port or Address
	if reHardcodedPort.MatchString(uncommented) {
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-HTTP-001",
			Classification:      ClassificationPotentialIssue,
			Severity:            "medium",
			Line:                findRegexLine(reHardcodedPort),
			Title:               "Hardcoded Network Port or Address Constant",
			Description:         "Network port or bind address is defined as a fixed constant or literal without environment variable fallback.",
			WhyItMatters:        "Prevents dynamic port assignment in containerized, multi-tenant, or PaaS environments (e.g. PORT in Cloud Run, Docker, Kubernetes).",
			SuggestedCorrection: "Use an environment variable helper like envOr(\"PORT\", \"8080\") to allow dynamic runtime configuration.",
			CorrectedExample:    `port := os.Getenv("PORT"); if port == "" { port = "8080" }`,
			RelatedLessonID:     "l0-backend-http-lifecycle",
			ReferenceURL:        "https://12factor.net/config",
		})
	}

	// Optionally run real local gofmt / go vet if Go toolchain is installed on host
	var toolExecuted bool
	var toolOut string
	if a.enableLocalToolchain {
		if goPath, err := exec.LookPath("go"); err == nil && goPath != "" {
			toolExecuted, toolOut = a.runIsolatedGoVet(ctx, goPath, code)
			if toolOut != "" {
				findings = append(findings, DiagnosticFinding{
					RuleID:              "GO-VET-001",
					Classification:      ClassificationConfirmedDiagnostic,
					Severity:            "high",
					Title:               "Go Compiler / go vet Diagnostic Output",
					Description:         toolOut,
					WhyItMatters:        "Confirmed syntax, type-checking, or go vet analyzer diagnostic reported directly by the Go toolchain.",
					SuggestedCorrection: "Resolve the compiler or go vet error reported at the line number above.",
					RelatedLessonID:     "l1-toolchain-modules-packages",
					ReferenceURL:        "https://pkg.go.dev/cmd/vet",
				})
			}
		}
	}

	summaryStatus := "findings_detected"
	if len(findings) == 0 {
		summaryStatus = "no_finding_detected"
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-INFO-000",
			Classification:      ClassificationNoFindingDetected,
			Severity:            "info",
			Line:                1,
			Title:               "No Static Rule Triggered in This Snippet",
			Description:         "None of the configured offline static rules or AST checks matched this snippet.",
			WhyItMatters:        "IMPORTANT: Absence of static findings does NOT prove code is secure or bug-free. Business-logic flaws, cross-package race conditions, and runtime query plan bottlenecks require integration tests (go test -race) and database EXPLAIN ANALYZE verification.",
			SuggestedCorrection: "Run 'go test -race ./...' and verify database queries against real constraints.",
			RelatedLessonID:     "l7-testing-fuzzing-benchmarks",
			ReferenceURL:        "https://go.dev/doc/articles/race_detector",
		})
	}

	return AnalysisReport{
		OfflineMode:               true,
		ToolchainExecuted:         toolExecuted,
		ToolchainOutput:           toolOut,
		SummaryStatus:             summaryStatus,
		Findings:                  findings,
		StaticAnalysisLimitations: "Static analysis inspects syntax and known code patterns in isolation. It cannot prove business-logic authorization (BOLA), runtime lock ordering across services, or database index selectivity. Never treat '0 static findings' as a substitute for 'go test -race', fuzzing, and integration tests.",
		OptionalAIStatus:          "AI_PROVIDER=" + a.aiProvider.Name() + " (100% offline deterministic analysis active)",
		AnalyzedAt:                time.Now().UTC(),
	}
}

func (a *Analyzer) runIsolatedGoVet(ctx context.Context, goBinary, code string) (bool, string) {
	tmpDir, err := os.MkdirTemp("", "gba-vet-*")
	if err != nil {
		return false, ""
	}
	defer os.RemoveAll(tmpDir)

	src := code
	if !strings.Contains(src, "package ") {
		src = "package main\n\n" + src
	}
	filePath := filepath.Join(tmpDir, "snippet.go")
	if err := os.WriteFile(filePath, []byte(src), 0600); err != nil {
		return false, ""
	}

	vetCtx, cancel := context.WithTimeout(ctx, a.sandboxTimeout)
	defer cancel()

	cmd := exec.CommandContext(vetCtx, goBinary, "vet", filePath)
	cmd.Dir = tmpDir
	out, err := cmd.CombinedOutput()
	if err != nil {
		return true, strings.TrimSpace(string(out))
	}
	return true, ""
}
