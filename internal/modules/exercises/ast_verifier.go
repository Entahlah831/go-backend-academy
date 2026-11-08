package exercises

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"strconv"
	"strings"
)

// Rule defines structural AST invariants for verifying an exercise solution.
type Rule struct {
	TargetFunc  string   `json:"target_func,omitempty"`  // Function that must be declared, e.g. "DefaultPort"
	MustCall    []string `json:"must_call,omitempty"`    // Function/method calls required, e.g. "os.Getenv", "db.QueryRowContext"
	NoCall      []string `json:"no_call,omitempty"`      // Prohibited calls, e.g. "fmt.Sprintf" in SQL queries
	MustImport  []string `json:"must_import,omitempty"`  // Required imports, e.g. "net/http", "context"
	MustContain []string `json:"must_contain,omitempty"` // Literals/tokens that must appear in code outside comments
}

// ASTCheckResult contains the findings of the structural AST verification.
type ASTCheckResult struct {
	ValidSyntax bool     `json:"valid_syntax"`
	Passed      bool     `json:"passed"`
	Missing     []string `json:"missing,omitempty"`
	Violations  []string `json:"violations,omitempty"`
	SyntaxError string   `json:"syntax_error,omitempty"`
	Diagnostics string   `json:"diagnostics"`
}

// CheckAST parses the submitted Go source code and verifies it against the AST rule.
func CheckAST(src string, r Rule) ASTCheckResult {
	trimmed := strings.TrimSpace(src)
	if trimmed == "" {
		return ASTCheckResult{
			ValidSyntax: false,
			Passed:      false,
			Diagnostics: "Kode program kosong.",
			Missing:     []string{"kode implementasi"},
		}
	}

	needsSyntheticPackage := !strings.Contains(trimmed, "package ")
	codeToParse := trimmed
	lineOffset := 0
	if needsSyntheticPackage {
		codeToParse = "package main\n" + trimmed
		lineOffset = 1
	}

	fset := token.NewFileSet()
	f, err := parser.ParseFile(fset, "submission.go", codeToParse, parser.AllErrors)
	if err != nil {
		// Provide clean line/column syntax feedback
		cleanMsg := err.Error()
		if lineOffset > 0 {
			cleanMsg = strings.ReplaceAll(cleanMsg, "submission.go:1:", "submission.go: ")
		}
		return ASTCheckResult{
			ValidSyntax: false,
			Passed:      false,
			SyntaxError: cleanMsg,
			Diagnostics: fmt.Sprintf("Kode belum valid secara sintaks Go: %s", cleanMsg),
		}
	}

	seenFuncs := make(map[string]bool)
	seenImports := make(map[string]bool)
	seenCalls := make(map[string]bool)
	seenIdents := make(map[string]bool)

	// Collect imports
	for _, imp := range f.Imports {
		if imp.Path != nil {
			unquoted, err := strconv.Unquote(imp.Path.Value)
			if err == nil {
				seenImports[unquoted] = true
			}
		}
	}

	// Traverse AST to collect declared functions, call expressions, and AST identifiers
	ast.Inspect(f, func(n ast.Node) bool {
		switch node := n.(type) {
		case *ast.FuncDecl:
			if node.Name != nil {
				seenFuncs[node.Name.Name] = true
			}
		case *ast.CallExpr:
			recordCallExpr(node, seenCalls)
		case *ast.Ident:
			seenIdents[node.Name] = true
		}
		return true
	})

	var missing []string
	var violations []string

	// 1. Verify Target Function declaration
	if r.TargetFunc != "" && !seenFuncs[r.TargetFunc] {
		missing = append(missing, fmt.Sprintf("fungsi %s() tidak ditemukan", r.TargetFunc))
	}

	// 2. Verify Required Package Imports
	for _, imp := range r.MustImport {
		if !seenImports[imp] {
			missing = append(missing, fmt.Sprintf("harus mengimpor package %q", imp))
		}
	}

	// 3. Verify Required Calls
	for _, want := range r.MustCall {
		wantClean := strings.TrimSpace(want)
		if wantClean == "" {
			continue
		}
		if !hasMatchingCall(wantClean, seenCalls) {
			missing = append(missing, fmt.Sprintf("harus memanggil %s", wantClean))
		}
	}

	// 4. Verify Prohibited Calls
	for _, bad := range r.NoCall {
		badClean := strings.TrimSpace(bad)
		if badClean == "" {
			continue
		}
		if hasMatchingCall(badClean, seenCalls) {
			violations = append(violations, fmt.Sprintf("jangan menggunakan %s", badClean))
		}
	}

	// 5. Verify MustContain non-comment tokens
	uncommented := StripGoComments(trimmed)
	for _, tok := range r.MustContain {
		tokClean := strings.TrimSpace(tok)
		if tokClean == "" {
			continue
		}
		if !strings.Contains(uncommented, tokClean) {
			missing = append(missing, fmt.Sprintf("harus memuat pola %q", tokClean))
		}
	}

	passed := len(missing) == 0 && len(violations) == 0
	diag := "Semua invarian struktural dan pola kode terpenuhi."
	if !passed {
		var parts []string
		if len(missing) > 0 {
			parts = append(parts, "Kekurangan: "+strings.Join(missing, "; "))
		}
		if len(violations) > 0 {
			parts = append(parts, "Pelanggaran: "+strings.Join(violations, "; "))
		}
		diag = strings.Join(parts, " | ")
	}

	return ASTCheckResult{
		ValidSyntax: true,
		Passed:      passed,
		Missing:     missing,
		Violations:  violations,
		Diagnostics: diag,
	}
}

func recordCallExpr(c *ast.CallExpr, seenCalls map[string]bool) {
	switch fn := c.Fun.(type) {
	case *ast.SelectorExpr:
		sel := fn.Sel.Name
		seenCalls[sel] = true
		seenCalls["."+sel] = true
		seenCalls["."+sel+"()"] = true
		seenCalls[sel+"()"] = true

		if id, ok := fn.X.(*ast.Ident); ok {
			full := id.Name + "." + sel
			seenCalls[full] = true
			seenCalls[full+"()"] = true
		} else if innerSel, ok := fn.X.(*ast.SelectorExpr); ok {
			full := innerSel.Sel.Name + "." + sel
			seenCalls[full] = true
			seenCalls[full+"()"] = true
		}
	case *ast.Ident:
		name := fn.Name
		seenCalls[name] = true
		seenCalls[name+"()"] = true
	}
}

func hasMatchingCall(pattern string, seenCalls map[string]bool) bool {
	clean := strings.TrimSpace(pattern)
	if idx := strings.Index(clean, "("); idx > 0 {
		clean = clean[:idx]
	}
	clean = strings.TrimPrefix(clean, ".")
	if seenCalls[clean] || seenCalls[pattern] || seenCalls["."+clean] {
		return true
	}
	// Check suffix match e.g. "QueryRowContext" matches "db.QueryRowContext"
	if !strings.Contains(clean, ".") {
		for call := range seenCalls {
			if strings.HasSuffix(call, "."+clean) || call == clean {
				return true
			}
		}
	} else {
		parts := strings.Split(clean, ".")
		last := parts[len(parts)-1]
		if seenCalls[last] {
			return true
		}
	}
	return false
}
