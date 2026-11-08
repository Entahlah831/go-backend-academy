package diagnostics

import (
	"context"
	"go/ast"
	"go/parser"
	"go/token"
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
	EngineSource              string              `json:"engine_source"` // "Server (Go AST)"
	SummaryStatus             string              `json:"summary_status"`
	Findings                  []DiagnosticFinding `json:"findings"`
	StaticAnalysisLimitations string              `json:"static_analysis_limitations"`
	OptionalAIStatus          string              `json:"optional_ai_status"`
	AnalyzedAt                time.Time           `json:"analyzed_at"`
}

// AllRuleIDs returns all rule IDs supported by the diagnostics engine.
func AllRuleIDs() []string {
	return []string{
		"GO-SEC-001",
		"GO-SEC-002",
		"GO-SEC-003",
		"GO-SEC-004",
		"GO-SEC-007",
		"GO-DB-001",
		"GO-DB-002",
		"GO-DB-004",
		"GO-CONC-001",
		"GO-CONC-002",
		"GO-ERR-001",
		"GO-ERR-002",
		"GO-PERF-001",
		"GO-HTTP-001",
		"GO-VET-001",
		"GO-INFO-000",
	}
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
	reSQLVerb         = regexp.MustCompile(`(?i)\b(SELECT|INSERT|UPDATE|DELETE)\b`)
	reSecretIdent     = regexp.MustCompile(`(?i)(password|passwd|secret|api_?key|auth_?token|jwt_?secret|private_?key)`)
	reEnvNameSuffix   = regexp.MustCompile(`(?i)(env|envvar|name|keyname|path|file)$`)
	reEnvValue        = regexp.MustCompile(`^[A-Z0-9_]+$`)
	rePortIdent       = regexp.MustCompile(`(?i)\b[A-Za-z0-9_]*(?:Port|ServerPort|ListenPort)\b`)
	reSQLSprintf      = regexp.MustCompile(`(?i)fmt\.Sprintf\s*\(\s*["` + "`" + `][^"` + "`" + `]*\b(SELECT|INSERT|UPDATE|DELETE)\b`)
	reSQLConcat       = regexp.MustCompile(`(?i)["` + "`" + `]\s*\b(SELECT|INSERT|UPDATE|DELETE)\b[^"` + "`" + `]*["` + "`" + `]\s*\+`)
	reEmptyClient     = regexp.MustCompile(`&?\bhttp\.Client\s*\{\s*\}`)
	reClientLiteral   = regexp.MustCompile(`&?\bhttp\.Client\s*\{([^}]*)\}`)
	reIgnoredErrCall  = regexp.MustCompile(`[A-Za-z0-9_]+\s*,\s*_\s*:?=\s*(?:os|io|json|strconv|http|exec|net|sql)\.[A-Za-z0-9_]+\s*\(`)
	reGoFuncBody      = regexp.MustCompile(`go\s+func\s*\([^)]*\)\s*\{([\s\S]*?)\}\s*\(`)
	reUnsyncMutate    = regexp.MustCompile(`\b[A-Za-z_][A-Za-z0-9_]*\s*(\+\+|--|\+=|-=)`)
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

var vetSem = make(chan struct{}, 2) // max 2 concurrent go vet processes

func (a *Analyzer) AnalyzeCode(ctx context.Context, code string) AnalysisReport {
	findings, astOk := a.analyzeAST(code)
	if !astOk {
		// Fallback to pattern-based analysis for incomplete or unparseable code snippets
		findings = a.analyzePatternFallback(code)
	}

	// Optionally run real local gofmt / go vet if Go toolchain is installed on host
	var toolExecuted bool
	var toolOut string
	if a.enableLocalToolchain {
		if goPath, err := exec.LookPath("go"); err == nil && goPath != "" {
			toolExecuted, toolOut = a.runIsolatedGoVet(ctx, goPath, code)
			if toolExecuted && toolOut != "" {
				classification := ClassificationConfirmedDiagnostic
				severity := "high"
				title := "Go Compiler / go vet Diagnostic Output"
				whyItMatters := "Confirmed syntax, type-checking, or go vet analyzer diagnostic reported directly by the Go toolchain."

				lowerOut := strings.ToLower(toolOut)
				if strings.Contains(lowerOut, "undefined:") || strings.Contains(lowerOut, "undeclared") ||
					strings.Contains(lowerOut, "could not import") || strings.Contains(lowerOut, "imported and not used") {
					classification = ClassificationPotentialIssue
					severity = "medium"
					title = "Snippet Tidak Lengkap / Kesalahan Sintaks"
					whyItMatters = "Kode tidak dapat dikompilasi lengkap karena ada impor atau variabel yang belum terdefinisi dalam potongan kode independen ini."
				}

				findings = append(findings, DiagnosticFinding{
					RuleID:              "GO-VET-001",
					Classification:      classification,
					Severity:            severity,
					Title:               title,
					Description:         toolOut,
					WhyItMatters:        whyItMatters,
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
		EngineSource:              "Server (Go AST)",
		SummaryStatus:             summaryStatus,
		Findings:                  findings,
		StaticAnalysisLimitations: "Static analysis inspects syntax and known code patterns in isolation. It cannot prove business-logic authorization (BOLA), runtime lock ordering across services, or database index selectivity. Never treat '0 static findings' as a substitute for 'go test -race', fuzzing, and integration tests.",
		OptionalAIStatus:          "AI_PROVIDER=" + a.aiProvider.Name() + " (100% offline deterministic analysis active)",
		AnalyzedAt:                time.Now().UTC(),
	}
}

// analyzeAST performs structural AST inspection using Go standard library go/parser.
func (a *Analyzer) analyzeAST(code string) ([]DiagnosticFinding, bool) {
	fset := token.NewFileSet()
	f, lineOffset, ok := parseSnippetAST(fset, code)
	if !ok {
		return nil, false
	}
	prependedPackage := (lineOffset > 0)

	var findings []DiagnosticFinding
	seenRules := map[string]bool{}

	posToLine := func(pos token.Pos) int {
		p := fset.Position(pos)
		l := p.Line
		if prependedPackage && l > lineOffset {
			l -= lineOffset
		}
		if l < 1 {
			l = 1
		}
		return l
	}

	addFinding := func(finding DiagnosticFinding) {
		if !seenRules[finding.RuleID] {
			seenRules[finding.RuleID] = true
			findings = append(findings, finding)
		}
	}

	// Pass 1: Identify dynamic SQL variables
	dynamicSQLVars := map[string]bool{}
	ast.Inspect(f, func(n ast.Node) bool {
		as, ok := n.(*ast.AssignStmt)
		if !ok || len(as.Lhs) != len(as.Rhs) {
			return true
		}
		for i, l := range as.Lhs {
			if id, ok := l.(*ast.Ident); ok {
				if isDynamicSQLExpr(as.Rhs[i], dynamicSQLVars) {
					dynamicSQLVars[id.Name] = true
				}
			}
		}
		return true
	})

	// Pass 2: Imports inspection
	for _, imp := range f.Imports {
		path := strings.Trim(imp.Path.Value, `"`)
		if path == "net/http/pprof" {
			addFinding(DiagnosticFinding{
				RuleID:              "GO-SEC-004",
				Classification:      ClassificationEducationalHeuristic,
				Severity:            "high",
				Line:                posToLine(imp.Pos()),
				Title:               "Blank Import of net/http/pprof Registers Handlers on DefaultServeMux",
				Description:         "Importing net/http/pprof automatically mounts /debug/pprof/* on http.DefaultServeMux.",
				WhyItMatters:        "If DefaultServeMux is exposed publicly, attackers can download heap dumps and goroutine stacks (OWASP API8:2023 Security Misconfiguration).",
				SuggestedCorrection: "Use an explicit http.NewServeMux() for public traffic and bind pprof only to 127.0.0.1:6060.",
				CorrectedExample:    `adminMux := http.NewServeMux(); _ = http.ListenAndServe("127.0.0.1:6060", adminMux)`,
				RelatedLessonID:     "l2-profiling-pprof-benchmarks",
				ReferenceURL:        "https://pkg.go.dev/net/http/pprof",
			})
		}
	}

	// Pass 3: Declarations inspection (constants, secrets, ports)
	ast.Inspect(f, func(n ast.Node) bool {
		gen, ok := n.(*ast.GenDecl)
		if !ok {
			return true
		}
		for _, spec := range gen.Specs {
			valSpec, ok := spec.(*ast.ValueSpec)
			if !ok {
				continue
			}
			for i, name := range valSpec.Names {
				identLower := strings.ToLower(name.Name)

				// Check SEC-007 (Hardcoded Secret)
				if reSecretIdent.MatchString(identLower) && !reEnvNameSuffix.MatchString(identLower) {
					if i < len(valSpec.Values) {
						if lit, ok := valSpec.Values[i].(*ast.BasicLit); ok && lit.Kind == token.STRING {
							val := strings.Trim(lit.Value, "`\"")
							// If the value is not an uppercase env var name (e.g. "APP_SECRET"), trigger
							if val != "" && !reEnvValue.MatchString(val) {
								addFinding(DiagnosticFinding{
									RuleID:              "GO-SEC-007",
									Classification:      ClassificationPotentialIssue,
									Severity:            "high",
									Line:                posToLine(lit.Pos()),
									Title:               "Hardcoded Secret or Credential Detected",
									Description:         "A password, API key, JWT secret, or private token appears hardcoded as a string literal in source code.",
									WhyItMatters:        "Committing secrets to source control or container images risks credential exposure and prevents rotation without recompilation.",
									SuggestedCorrection: "Read credentials from environment variables (e.g. os.Getenv) or a secure secrets manager.",
									CorrectedExample:    `password := os.Getenv("DATABASE_PASSWORD")`,
									RelatedLessonID:     "l0-backend-http-lifecycle",
									ReferenceURL:        "https://owasp.org/www-community/Source_Code_Analysis_Tools",
								})
							}
						}
					}
				}

				// Check HTTP-001 (Hardcoded Port)
				if rePortIdent.MatchString(name.Name) {
					if i < len(valSpec.Values) {
						valNode := valSpec.Values[i]
						if lit, ok := valNode.(*ast.BasicLit); ok && (lit.Kind == token.STRING || lit.Kind == token.INT) {
							addFinding(DiagnosticFinding{
								RuleID:              "GO-HTTP-001",
								Classification:      ClassificationPotentialIssue,
								Severity:            "medium",
								Line:                posToLine(lit.Pos()),
								Title:               "Hardcoded Network Port or Address Constant",
								Description:         "Network port or bind address is defined as a fixed constant or literal without environment variable fallback.",
								WhyItMatters:        "Prevents dynamic port assignment in containerized, multi-tenant, or PaaS environments (e.g. PORT in Cloud Run, Docker, Kubernetes).",
								SuggestedCorrection: "Use an environment variable helper like envOr(\"PORT\", \"8080\") to allow dynamic runtime configuration.",
								CorrectedExample:    `port := os.Getenv("PORT"); if port == "" { port = "8080" }`,
								RelatedLessonID:     "l0-backend-http-lifecycle",
								ReferenceURL:        "https://12factor.net/config",
							})
						}
					}
				}
			}
		}
		return true
	})

	// Pass 4: Statements & Calls inspection
	hasMaxBytesReader := false
	hasSqlOpen := false
	hasSetMaxOpenConns := false
	var rowsVarNames []string

	ast.Inspect(f, func(n ast.Node) bool {
		call, ok := n.(*ast.CallExpr)
		if !ok {
			return true
		}

		sel, isSel := call.Fun.(*ast.SelectorExpr)
		if isSel {
			selName := sel.Sel.Name
			if id, ok := sel.X.(*ast.Ident); ok {
				if id.Name == "http" && selName == "MaxBytesReader" {
					hasMaxBytesReader = true
				}
				if id.Name == "sql" && selName == "Open" {
					hasSqlOpen = true
				}
			}
			if selName == "SetMaxOpenConns" {
				hasSetMaxOpenConns = true
			}
		}
		return true
	})

	// Detect sql.Rows cursor assignment
	ast.Inspect(f, func(n ast.Node) bool {
		as, ok := n.(*ast.AssignStmt)
		if !ok {
			return true
		}
		for i, rhs := range as.Rhs {
			call, ok := rhs.(*ast.CallExpr)
			if !ok {
				continue
			}
			if sel, ok := call.Fun.(*ast.SelectorExpr); ok {
				if sel.Sel.Name == "Query" || sel.Sel.Name == "QueryContext" {
					if i < len(as.Lhs) {
						if id, ok := as.Lhs[i].(*ast.Ident); ok && id.Name != "_" {
							rowsVarNames = append(rowsVarNames, id.Name)
						}
					}
				}
			}
		}
		return true
	})

	// Walk calls and statements
	ast.Inspect(f, func(n ast.Node) bool {
		switch node := n.(type) {
		case *ast.CallExpr:
			// Ident call: panic(...)
			if id, ok := node.Fun.(*ast.Ident); ok && id.Name == "panic" {
				addFinding(DiagnosticFinding{
					RuleID:              "GO-ERR-001",
					Classification:      ClassificationEducationalHeuristic,
					Severity:            "medium",
					Line:                posToLine(node.Pos()),
					Title:               "Explicit panic() Used for Error Handling",
					Description:         "Detected panic() call. In Go, normal operational failures (I/O, database, validation) should return explicit error values.",
					WhyItMatters:        "Uncaught panics crash the process or abort the active request goroutine abruptly.",
					SuggestedCorrection: `Return a wrapped error with fmt.Errorf("...: %w", err) so callers can inspect it with errors.Is / errors.As.`,
					CorrectedExample:    `if err != nil { return fmt.Errorf("executing query: %w", err) }`,
					RelatedLessonID:     "l1-interfaces-errors-generics",
					ReferenceURL:        "https://go.dev/blog/go1.13-errors",
				})
			}

			// Selector calls
			if sel, ok := node.Fun.(*ast.SelectorExpr); ok {
				methodName := sel.Sel.Name

				// Database query calls
				switch methodName {
				case "Query", "QueryRow", "Exec":
					if funcHasContextParam(node.Pos(), f) {
						addFinding(DiagnosticFinding{
							RuleID:              "GO-DB-004",
							Classification:      ClassificationPotentialIssue,
							Severity:            "medium",
							Line:                posToLine(node.Pos()),
							Title:               "Database Query Executed Without Context Cancellation",
							Description:         "Query, QueryRow, or Exec called without a context.Context parameter.",
							WhyItMatters:        "Queries without context cannot be cancelled when an HTTP client disconnects or request times out, leading to query exhaustion.",
							SuggestedCorrection: "Use the *Context variant (db.QueryContext, db.QueryRowContext, db.ExecContext) with r.Context().",
							CorrectedExample:    `row := db.QueryRowContext(ctx, "SELECT email FROM users WHERE id = $1", userID)`,
							RelatedLessonID:     "l5-db-ecosystem-comparison",
							ReferenceURL:        "https://go.dev/doc/database/cancel-operations",
						})
					}
					if len(node.Args) > 0 && isDynamicSQLExpr(node.Args[0], dynamicSQLVars) {
						addFinding(DiagnosticFinding{
							RuleID:              "GO-SEC-001",
							Classification:      ClassificationPotentialIssue,
							Severity:            "critical",
							Line:                posToLine(node.Pos()),
							Title:               "Dynamic SQL String Interpolation or Concatenation Detected",
							Description:         "Constructing a SQL query string using fmt.Sprintf or '+' string concatenation risks SQL Injection if any input originates from an external caller.",
							WhyItMatters:        "SQL Injection allows attackers to alter query predicates, bypass authentication, or exfiltrate entire tables.",
							SuggestedCorrection: "Pass parameters separately from the SQL statement using driver placeholders ($1, $2 in PostgreSQL or ? in SQLite/MySQL).",
							CorrectedExample:    `row := db.QueryRowContext(ctx, "SELECT id, email FROM users WHERE email = $1", userInput)`,
							RelatedLessonID:     "l6-security-auth-owasp",
							ReferenceURL:        "https://go.dev/doc/database/sql-injection",
						})
					}

				case "QueryContext", "QueryRowContext", "ExecContext":
					if len(node.Args) > 1 && isDynamicSQLExpr(node.Args[1], dynamicSQLVars) {
						addFinding(DiagnosticFinding{
							RuleID:              "GO-SEC-001",
							Classification:      ClassificationPotentialIssue,
							Severity:            "critical",
							Line:                posToLine(node.Pos()),
							Title:               "Dynamic SQL String Interpolation or Concatenation Detected",
							Description:         "Constructing a SQL query string using fmt.Sprintf or '+' string concatenation risks SQL Injection if any input originates from an external caller.",
							WhyItMatters:        "SQL Injection allows attackers to alter query predicates, bypass authentication, or exfiltrate entire tables.",
							SuggestedCorrection: "Pass parameters separately from the SQL statement using driver placeholders ($1, $2 in PostgreSQL or ? in SQLite/MySQL).",
							CorrectedExample:    `row := db.QueryRowContext(ctx, "SELECT id, email FROM users WHERE email = $1", userInput)`,
							RelatedLessonID:     "l6-security-auth-owasp",
							ReferenceURL:        "https://go.dev/doc/database/sql-injection",
						})
					}

				case "Get":
					if id, ok := sel.X.(*ast.Ident); ok && id.Name == "http" {
						addFinding(DiagnosticFinding{
							RuleID:              "GO-SEC-003",
							Classification:      ClassificationPotentialIssue,
							Severity:            "high",
							Line:                posToLine(node.Pos()),
							Title:               "Unbounded HTTP Timeout (http.ListenAndServe, http.Get, or http.Client{} Without Timeout)",
							Description:         "http.ListenAndServe, http.DefaultClient, and &http.Client{} without an explicit Timeout field have zero timeouts by default.",
							WhyItMatters:        "Leaves servers vulnerable to Slowloris socket exhaustion and clients vulnerable to hanging forever on stalled peers.",
							SuggestedCorrection: "Configure explicit timeouts on &http.Server{ReadHeaderTimeout: 5*time.Second, ReadTimeout: 10*time.Second} and &http.Client{Timeout: 10*time.Second}.",
							CorrectedExample:    `client := &http.Client{Timeout: 10 * time.Second}`,
							RelatedLessonID:     "l3-net-http-routers",
							ReferenceURL:        "https://pkg.go.dev/net/http#Client",
						})
					}

				case "MustCompile", "Compile":
					if id, ok := sel.X.(*ast.Ident); ok && id.Name == "regexp" {
						if isPosInsideFunc(node.Pos(), f) {
							addFinding(DiagnosticFinding{
								RuleID:              "GO-PERF-001",
								Classification:      ClassificationEducationalHeuristic,
								Severity:            "medium",
								Line:                posToLine(node.Pos()),
								Title:               "regexp.MustCompile Called Inside Function Scope",
								Description:         "Compiling a static regular expression inside a function or HTTP handler rebuilds the NFA automaton on every invocation.",
								WhyItMatters:        "Increases CPU and heap allocations dramatically on hot paths compared to package-level initialization.",
								SuggestedCorrection: "Hoist var pattern = regexp.MustCompile(...) to package-level scope.",
								CorrectedExample:    "var idRe = regexp.MustCompile(`^[a-z0-9]+$`)",
								RelatedLessonID:     "l2-profiling-pprof-benchmarks",
								ReferenceURL:        "https://pkg.go.dev/regexp",
							})
						}
					}

				case "ReadAll":
					if id, ok := sel.X.(*ast.Ident); ok && id.Name == "io" {
						if len(node.Args) > 0 && isBodyReader(node.Args[0]) && !hasMaxBytesReader {
							addFinding(DiagnosticFinding{
								RuleID:              "GO-SEC-002",
								Classification:      ClassificationPotentialIssue,
								Severity:            "high",
								Line:                posToLine(node.Pos()),
								Title:               "Request Body Read Without http.MaxBytesReader",
								Description:         "Reading r.Body without wrapping it in http.MaxBytesReader allows unbounded payload sizes.",
								WhyItMatters:        "Enables memory exhaustion Denial-of-Service (OWASP API4:2023 Unrestricted Resource Consumption).",
								SuggestedCorrection: "Wrap r.Body = http.MaxBytesReader(w, r.Body, 1<<20) before decoding.",
								CorrectedExample:    `r.Body = http.MaxBytesReader(w, r.Body, 1<<20)`,
								RelatedLessonID:     "l0-backend-http-lifecycle",
								ReferenceURL:        "https://pkg.go.dev/net/http#MaxBytesReader",
							})
						}
					}

				case "NewDecoder":
					if id, ok := sel.X.(*ast.Ident); ok && id.Name == "json" {
						if len(node.Args) > 0 && isBodyReader(node.Args[0]) && !hasMaxBytesReader {
							addFinding(DiagnosticFinding{
								RuleID:              "GO-SEC-002",
								Classification:      ClassificationPotentialIssue,
								Severity:            "high",
								Line:                posToLine(node.Pos()),
								Title:               "Request Body Read Without http.MaxBytesReader",
								Description:         "Reading r.Body without wrapping it in http.MaxBytesReader allows unbounded payload sizes.",
								WhyItMatters:        "Enables memory exhaustion Denial-of-Service (OWASP API4:2023 Unrestricted Resource Consumption).",
								SuggestedCorrection: "Wrap r.Body = http.MaxBytesReader(w, r.Body, 1<<20) before decoding.",
								CorrectedExample:    `r.Body = http.MaxBytesReader(w, r.Body, 1<<20)`,
								RelatedLessonID:     "l0-backend-http-lifecycle",
								ReferenceURL:        "https://pkg.go.dev/net/http#MaxBytesReader",
							})
						}
					}
				}
			}

		case *ast.AssignStmt:
			// Rule GO-ERR-002: Discarded error return with blank identifier '_'
			if len(node.Lhs) >= 2 {
				for idx, lhs := range node.Lhs {
					if id, ok := lhs.(*ast.Ident); ok && id.Name == "_" && idx == len(node.Lhs)-1 {
						var rhsCall ast.Expr
						if len(node.Rhs) == 1 {
							rhsCall = node.Rhs[0]
						} else if idx < len(node.Rhs) {
							rhsCall = node.Rhs[idx]
						}
						if rhsCall != nil && isFallibleCall(rhsCall) {
							addFinding(DiagnosticFinding{
								RuleID:              "GO-ERR-002",
								Classification:      ClassificationPotentialIssue,
								Severity:            "high",
								Line:                posToLine(node.Pos()),
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
				}
			}

		case *ast.GoStmt:
			// Goroutines inspection
			if lit, ok := node.Call.Fun.(*ast.FuncLit); ok {
				// Rule GO-CONC-001: Unbounded goroutine without context or WaitGroup
				hasLifecycle := false
				ast.Inspect(lit.Body, func(bn ast.Node) bool {
					if bid, ok := bn.(*ast.Ident); ok {
						if strings.Contains(strings.ToLower(bid.Name), "ctx") || strings.Contains(bid.Name, "Context") || strings.Contains(bid.Name, "WaitGroup") || strings.Contains(bid.Name, "wg") {
							hasLifecycle = true
						}
					}
					return true
				})
				if !hasLifecycle {
					addFinding(DiagnosticFinding{
						RuleID:              "GO-CONC-001",
						Classification:      ClassificationPotentialIssue,
						Severity:            "high",
						Line:                posToLine(node.Pos()),
						Title:               "Goroutine Spawned Without Context Cancellation or WaitGroup Lifecycle",
						Description:         "Spawning an anonymous goroutine without a termination signal or WaitGroup makes its lifetime unbounded.",
						WhyItMatters:        "Blocked background goroutines (such as unbuffered channel sends with no receiver) never get garbage collected, leaking memory forever.",
						SuggestedCorrection: "Pass context.Context into the goroutine, select on <-ctx.Done(), and track completion via sync.WaitGroup or errgroup.Group.",
						CorrectedExample:    `wg.Add(1); go func() { defer wg.Done(); _ = doWork(ctx) }()`,
						RelatedLessonID:     "l2-gmp-channels-context-workers",
						ReferenceURL:        "https://go.dev/blog/pipelines",
					})
				}

				// Rule GO-CONC-002: Unsynchronized shared variable mutation
				localVars := map[string]bool{}
				ast.Inspect(lit.Body, func(bn ast.Node) bool {
					switch bstmt := bn.(type) {
					case *ast.DeclStmt:
						if gd, ok := bstmt.Decl.(*ast.GenDecl); ok {
							for _, sp := range gd.Specs {
								if vs, ok := sp.(*ast.ValueSpec); ok {
									for _, id := range vs.Names {
										localVars[id.Name] = true
									}
								}
							}
						}
					case *ast.AssignStmt:
						if bstmt.Tok == token.DEFINE {
							for _, bl := range bstmt.Lhs {
								if bid, ok := bl.(*ast.Ident); ok {
									localVars[bid.Name] = true
								}
							}
						}
					case *ast.ForStmt:
						if initAs, ok := bstmt.Init.(*ast.AssignStmt); ok {
							for _, bl := range initAs.Lhs {
								if bid, ok := bl.(*ast.Ident); ok {
									localVars[bid.Name] = true
								}
							}
						}
					case *ast.RangeStmt:
						if kid, ok := bstmt.Key.(*ast.Ident); ok {
							localVars[kid.Name] = true
						}
						if vid, ok := bstmt.Value.(*ast.Ident); ok {
							localVars[vid.Name] = true
						}
					}
					return true
				})

				hasUnsyncedMutation := false
				var mutationPos token.Pos
				ast.Inspect(lit.Body, func(bn ast.Node) bool {
					switch mn := bn.(type) {
					case *ast.IncDecStmt:
						if mid, ok := mn.X.(*ast.Ident); ok {
							if !localVars[mid.Name] {
								hasUnsyncedMutation = true
								mutationPos = mn.Pos()
							}
						}
					case *ast.AssignStmt:
						if mn.Tok == token.ADD_ASSIGN || mn.Tok == token.SUB_ASSIGN || mn.Tok == token.MUL_ASSIGN {
							for _, al := range mn.Lhs {
								if mid, ok := al.(*ast.Ident); ok && !localVars[mid.Name] {
									hasUnsyncedMutation = true
									mutationPos = mn.Pos()
								}
							}
						}
					}
					return true
				})

				if hasUnsyncedMutation {
					addFinding(DiagnosticFinding{
						RuleID:              "GO-CONC-002",
						Classification:      ClassificationPotentialIssue,
						Severity:            "medium",
						Line:                posToLine(mutationPos),
						Title:               "Unsynchronized Shared Variable Mutation Inside Goroutine (Data Race)",
						Description:         "A goroutine mutates external shared state without synchronization.",
						WhyItMatters:        "Concurrent unsynchronized read-modify-write operations corrupt memory and trigger undefined behavior under the Go Memory Model.",
						SuggestedCorrection: "Use atomic.Int64 / atomic.AddInt64 or guard the shared variable with a sync.Mutex (mu.Lock() / defer mu.Unlock()).",
						CorrectedExample:    `var n atomic.Int64; go func() { defer wg.Done(); n.Add(1) }()`,
						RelatedLessonID:     "l2-gmp-channels-context-workers",
						ReferenceURL:        "https://go.dev/doc/articles/race_detector",
					})
				}
			}

		case *ast.CompositeLit:
			// Rule GO-SEC-003: &http.Client{} without Timeout
			if sel, ok := node.Type.(*ast.SelectorExpr); ok {
				if id, ok := sel.X.(*ast.Ident); ok && id.Name == "http" && sel.Sel.Name == "Client" {
					hasTimeout := false
					for _, elt := range node.Elts {
						if kv, ok := elt.(*ast.KeyValueExpr); ok {
							if kid, ok := kv.Key.(*ast.Ident); ok && kid.Name == "Timeout" {
								hasTimeout = true
							}
						}
					}
					if !hasTimeout {
						addFinding(DiagnosticFinding{
							RuleID:              "GO-SEC-003",
							Classification:      ClassificationPotentialIssue,
							Severity:            "high",
							Line:                posToLine(node.Pos()),
							Title:               "Unbounded HTTP Timeout (http.ListenAndServe, http.Get, or http.Client{} Without Timeout)",
							Description:         "http.ListenAndServe, http.DefaultClient, and &http.Client{} without an explicit Timeout field have zero timeouts by default.",
							WhyItMatters:        "Leaves servers vulnerable to Slowloris socket exhaustion and clients vulnerable to hanging forever on stalled peers.",
							SuggestedCorrection: "Configure explicit timeouts on &http.Server{ReadHeaderTimeout: 5*time.Second, ReadTimeout: 10*time.Second} and &http.Client{Timeout: 10*time.Second}.",
							CorrectedExample:    `client := &http.Client{Timeout: 10 * time.Second}`,
							RelatedLessonID:     "l3-net-http-routers",
							ReferenceURL:        "https://pkg.go.dev/net/http#Client",
						})
					}
				}
			}
		}
		return true
	})

	// Rule GO-DB-001: Check if any opened rows cursors lack defer rows.Close()
	if len(rowsVarNames) > 0 {
		unclosed := false
		for _, varName := range rowsVarNames {
			hasClose := false
			ast.Inspect(f, func(n ast.Node) bool {
				if defStmt, ok := n.(*ast.DeferStmt); ok {
					if call, ok := defStmt.Call.Fun.(*ast.SelectorExpr); ok {
						if id, ok := call.X.(*ast.Ident); ok && id.Name == varName && call.Sel.Name == "Close" {
							hasClose = true
						}
					}
				}
				return true
			})
			if !hasClose {
				unclosed = true
				break
			}
		}
		if unclosed {
			addFinding(DiagnosticFinding{
				RuleID:              "GO-DB-001",
				Classification:      ClassificationPotentialIssue,
				Severity:            "high",
				Line:                1,
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

	// Rule GO-DB-002: sql.Open without pool bounds
	if hasSqlOpen && !hasSetMaxOpenConns {
		addFinding(DiagnosticFinding{
			RuleID:              "GO-DB-002",
			Classification:      ClassificationEducationalHeuristic,
			Severity:            "medium",
			Line:                1,
			Title:               "sql.Open Initialized Without Connection Pool Bounds",
			Description:         "sql.Open defaults to MaxOpenConns = 0 (unlimited), allowing traffic spikes to exhaust database max_connections.",
			WhyItMatters:        "Unbounded connection opening under load triggers 'too many clients' errors on PostgreSQL/MySQL.",
			SuggestedCorrection: "Configure db.SetMaxOpenConns(25), db.SetMaxIdleConns(10), and db.SetConnMaxLifetime(30*time.Minute).",
			CorrectedExample:    `db.SetMaxOpenConns(25); db.SetMaxIdleConns(10); db.SetConnMaxLifetime(30 * time.Minute)`,
			RelatedLessonID:     "l5-db-ecosystem-comparison",
			ReferenceURL:        "https://go.dev/doc/database/manage-connections",
		})
	}

	return findings, true
}

func isDynamicSQLExpr(e ast.Expr, dyn map[string]bool) bool {
	switch v := e.(type) {
	case *ast.Ident:
		return dyn[v.Name]
	case *ast.BinaryExpr:
		if v.Op == token.ADD {
			return hasSQLVerbOrDyn(v.X, dyn) || hasSQLVerbOrDyn(v.Y, dyn)
		}
	case *ast.CallExpr:
		if sel, ok := v.Fun.(*ast.SelectorExpr); ok {
			if id, ok := sel.X.(*ast.Ident); ok && id.Name == "fmt" && strings.HasPrefix(sel.Sel.Name, "Sprint") {
				for _, arg := range v.Args {
					if lit, ok := arg.(*ast.BasicLit); ok && lit.Kind == token.STRING {
						if reSQLVerb.MatchString(lit.Value) {
							return true
						}
					}
				}
			}
		}
	}
	return false
}

func hasSQLVerbOrDyn(e ast.Expr, dyn map[string]bool) bool {
	switch v := e.(type) {
	case *ast.Ident:
		return dyn[v.Name]
	case *ast.BasicLit:
		if v.Kind == token.STRING {
			return reSQLVerb.MatchString(v.Value)
		}
	case *ast.BinaryExpr:
		return hasSQLVerbOrDyn(v.X, dyn) || hasSQLVerbOrDyn(v.Y, dyn)
	case *ast.CallExpr:
		return isDynamicSQLExpr(v, dyn)
	}
	return false
}

func isBodyReader(e ast.Expr) bool {
	if sel, ok := e.(*ast.SelectorExpr); ok && sel.Sel.Name == "Body" {
		return true
	}
	return false
}

func isFallibleCall(e ast.Expr) bool {
	call, ok := e.(*ast.CallExpr)
	if !ok {
		return false
	}
	if sel, ok := call.Fun.(*ast.SelectorExpr); ok {
		if id, ok := sel.X.(*ast.Ident); ok {
			switch id.Name {
			case "os", "io", "json", "strconv", "http", "exec", "net", "sql":
				return true
			}
		}
	}
	return false
}

func parseSnippetAST(fset *token.FileSet, code string) (*ast.File, int, bool) {
	if strings.Contains(code, "package ") {
		f, err := parser.ParseFile(fset, "snippet.go", code, parser.ParseComments)
		return f, 0, err == nil
	}
	// Try wrapping in func main()
	wrappedInFunc := "package main\n\nfunc main() {\n" + code + "\n}\n"
	f, err := parser.ParseFile(fset, "snippet.go", wrappedInFunc, parser.ParseComments)
	if err == nil {
		return f, 3, true
	}
	// Try wrapping in package main
	wrappedInPkg := "package main\n\n" + code
	f, err = parser.ParseFile(fset, "snippet.go", wrappedInPkg, parser.ParseComments)
	if err == nil {
		return f, 2, true
	}
	return nil, 0, false
}

func funcHasContextParam(pos token.Pos, file *ast.File) bool {
	hasCtx := false
	ast.Inspect(file, func(n ast.Node) bool {
		switch fn := n.(type) {
		case *ast.FuncDecl:
			if pos >= fn.Body.Pos() && pos <= fn.Body.End() {
				if fn.Type != nil && fn.Type.Params != nil {
					for _, field := range fn.Type.Params.List {
						if isContextType(field.Type) {
							hasCtx = true
						}
					}
				}
			}
		case *ast.FuncLit:
			if pos >= fn.Body.Pos() && pos <= fn.Body.End() {
				if fn.Type != nil && fn.Type.Params != nil {
					for _, field := range fn.Type.Params.List {
						if isContextType(field.Type) {
							hasCtx = true
						}
					}
				}
			}
		}
		return true
	})
	return hasCtx
}

func isContextType(expr ast.Expr) bool {
	if sel, ok := expr.(*ast.SelectorExpr); ok {
		if id, ok := sel.X.(*ast.Ident); ok && id.Name == "context" && sel.Sel.Name == "Context" {
			return true
		}
	}
	if id, ok := expr.(*ast.Ident); ok && strings.Contains(strings.ToLower(id.Name), "context") {
		return true
	}
	return false
}

func isPosInsideFunc(pos token.Pos, file *ast.File) bool {
	inside := false
	ast.Inspect(file, func(n ast.Node) bool {
		if fn, ok := n.(*ast.FuncDecl); ok {
			if pos >= fn.Body.Pos() && pos <= fn.Body.End() {
				inside = true
			}
		}
		if lit, ok := n.(*ast.FuncLit); ok {
			if pos >= lit.Body.Pos() && pos <= lit.Body.End() {
				inside = true
			}
		}
		return true
	})
	return inside
}

// analyzePatternFallback provides regex-based heuristics when the snippet has invalid syntax.
func (a *Analyzer) analyzePatternFallback(code string) []DiagnosticFinding {
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

	if reSQLSprintf.MatchString(uncommented) || reSQLConcat.MatchString(uncommented) {
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-SEC-001",
			Classification:      ClassificationPotentialIssue,
			Severity:            "critical",
			Line:                findRegexLine(reSQLSprintf),
			Title:               "Dynamic SQL String Interpolation or Concatenation Detected",
			Description:         "Constructing a SQL query string using fmt.Sprintf or '+' string concatenation risks SQL Injection if any input originates from an external caller.",
			WhyItMatters:        "SQL Injection allows attackers to alter query predicates, bypass authentication, or exfiltrate entire tables.",
			SuggestedCorrection: "Pass parameters separately from the SQL statement using driver placeholders ($1, $2 in PostgreSQL or ? in SQLite/MySQL).",
			CorrectedExample:    `row := db.QueryRowContext(ctx, "SELECT id, email FROM users WHERE email = $1", userInput)`,
			RelatedLessonID:     "l6-security-auth-owasp",
			ReferenceURL:        "https://go.dev/doc/database/sql-injection",
		})
	}

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

	if reHardcodedSecret.MatchString(uncommented) {
		findings = append(findings, DiagnosticFinding{
			RuleID:              "GO-SEC-007",
			Classification:      ClassificationPotentialIssue,
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

	if reIgnoredErrCall.MatchString(uncommented) {
		line := findRegexLine(reIgnoredErrCall)
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

	return findings
}

func (a *Analyzer) runIsolatedGoVet(ctx context.Context, goBinary, code string) (bool, string) {
	select {
	case vetSem <- struct{}{}:
		defer func() { <-vetSem }()
	default:
		return false, "Server sedang sibuk, verifikasi go vet dilewati."
	}

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

	cleanEnv := []string{
		"CGO_ENABLED=0",
		"GOPROXY=off",
		"GOFLAGS=-mod=mod",
		"GOTOOLCHAIN=local",
		"GOCACHE=" + filepath.Join(tmpDir, ".gocache"),
	}
	if p := os.Getenv("PATH"); p != "" {
		cleanEnv = append(cleanEnv, "PATH="+p)
	}
	if h := os.Getenv("HOME"); h != "" {
		cleanEnv = append(cleanEnv, "HOME="+h)
	}
	if up := os.Getenv("USERPROFILE"); up != "" {
		cleanEnv = append(cleanEnv, "USERPROFILE="+up)
	}
	if sd := os.Getenv("SYSTEMDRIVE"); sd != "" {
		cleanEnv = append(cleanEnv, "SYSTEMDRIVE="+sd)
	}
	if sr := os.Getenv("SYSTEMROOT"); sr != "" {
		cleanEnv = append(cleanEnv, "SYSTEMROOT="+sr)
	}
	if wd := os.Getenv("WINDIR"); wd != "" {
		cleanEnv = append(cleanEnv, "WINDIR="+wd)
	}
	cmd.Env = cleanEnv

	out, err := cmd.CombinedOutput()
	if vetCtx.Err() != nil {
		return false, "go vet dihentikan (melebihi batas waktu)"
	}
	if err != nil {
		return true, strings.TrimSpace(string(out))
	}
	return true, ""
}
