package exercises

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"go/parser"
	"go/token"
	"strings"
	"sync/atomic"
	"time"

	"github.com/gobackendacademy/platform/internal/platform/database"
)

var ErrUnknownExercise = errors.New("unknown exercise_id")

type SubmissionRequest struct {
	UserID         string   `json:"user_id"`
	ExerciseID     string   `json:"exercise_id"`
	Code           string   `json:"code"`
	RequiredTokens []string `json:"required_tokens"`
}

type SubmissionResult struct {
	AttemptID   string   `json:"attempt_id"`
	ExerciseID  string   `json:"exercise_id"`
	Passed      bool     `json:"passed"`
	Missing     []string `json:"missing,omitempty"`
	Diagnostics string   `json:"diagnostics"`
}

type ExercisePackage struct {
	ExerciseID  string            `json:"exercise_id"`
	Title       string            `json:"title"`
	Description string            `json:"description"`
	Files       map[string]string `json:"files"`
}

type Service struct {
	store *database.Store
	seq   atomic.Uint64
}

func NewService(store *database.Store) *Service {
	return &Service{store: store}
}

// NormalizeExerciseID resolves either "ex-<lesson_id>" or "<lesson_id>" to the canonical
// exercise ID ("ex-<lesson_id>") and confirms that the row exists in the exercises table.
func (s *Service) NormalizeExerciseID(ctx context.Context, id string) (string, bool, error) {
	trimmed := strings.TrimSpace(id)
	if trimmed == "" {
		return "", false, nil
	}
	canonical := "ex-" + strings.TrimPrefix(trimmed, "ex-")
	ok, err := s.store.ExerciseExists(ctx, canonical)
	if err != nil {
		return "", false, err
	}
	return canonical, ok, nil
}

// ListAttempts returns persisted attempts (newest first) for a user and optional exercise.
func (s *Service) ListAttempts(ctx context.Context, userID, exerciseID string) ([]database.ExerciseAttemptRecord, error) {
	if exerciseID != "" {
		exerciseID = "ex-" + strings.TrimPrefix(strings.TrimSpace(exerciseID), "ex-")
	}
	return s.store.ListExerciseAttempts(ctx, userID, exerciseID, 50)
}

// FetchPackage bundles starter code, verification test, go.mod and instructions for local offline practice.
func (s *Service) FetchPackage(ctx context.Context, exerciseID string) (*ExercisePackage, error) {
	canonicalExID, ok, err := s.NormalizeExerciseID(ctx, exerciseID)
	if err != nil {
		return nil, err
	}
	if !ok {
		return nil, fmt.Errorf("%w: %s", ErrUnknownExercise, exerciseID)
	}

	ex, err := s.store.GetExercise(ctx, canonicalExID)
	if err != nil {
		return nil, err
	}
	if ex == nil {
		return nil, fmt.Errorf("%w: %s", ErrUnknownExercise, canonicalExID)
	}

	testRec, err := s.store.GetExerciseTest(ctx, canonicalExID)
	if err != nil {
		return nil, err
	}

	pkgName := extractPackageName(ex.StarterCode)
	if pkgName == "" {
		pkgName = "main"
	}

	testFilename := "main_test.go"
	testCode := ""
	if testRec != nil && strings.TrimSpace(testRec.TestCode) != "" {
		if testRec.Filename != "" {
			testFilename = testRec.Filename
		}
		testCode = testRec.TestCode
	} else {
		testCode = fmt.Sprintf("package %s\n\nimport \"testing\"\n\nfunc TestVerification(t *testing.T) {\n\tt.Skip(\"Belum ada tes unit lokal resmi untuk latihan: %s\")\n}\n", pkgName, ex.Title)
	}

	moduleName := "exercise"
	if pkgName != "main" && pkgName != "" {
		moduleName = pkgName
	}
	goMod := fmt.Sprintf("module %s\n\ngo 1.23\n", moduleName)

	readme := fmt.Sprintf("# %s (%s)\n\n## Deskripsi Tugas\n%s\n\n## Petunjuk Menjalankan Tes\nLatihan ini dapat diuji secara lokal menggunakan Go toolchain resmi Anda:\n```bash\ngo test -v ./...\n```\n\nJika semua tes PASS, Anda siap untuk menyalin kode Anda kembali ke Go Backend Academy atau menyimpannya di portofolio lokal Anda.\n", ex.Title, ex.ID, ex.TaskDescription)

	files := map[string]string{
		"main.go":    ex.StarterCode,
		testFilename: testCode,
		"go.mod":     goMod,
		"README.md":  readme,
	}

	return &ExercisePackage{
		ExerciseID:  canonicalExID,
		Title:       ex.Title,
		Description: ex.TaskDescription,
		Files:       files,
	}, nil
}

func extractPackageName(src string) string {
	fset := token.NewFileSet()
	f, err := parser.ParseFile(fset, "temp.go", src, parser.PackageClauseOnly)
	if err == nil && f.Name != nil {
		return f.Name.Name
	}
	lines := strings.Split(src, "\n")
	for _, l := range lines {
		trimmed := strings.TrimSpace(l)
		if strings.HasPrefix(trimmed, "package ") {
			parts := strings.Fields(trimmed)
			if len(parts) >= 2 {
				return parts[1]
			}
		}
	}
	return "main"
}

func (s *Service) nextAttemptID(exerciseID string) string {
	var b [6]byte
	_, _ = rand.Read(b[:])
	n := s.seq.Add(1)
	return fmt.Sprintf("att_%s_%s_%d", exerciseID, hex.EncodeToString(b[:]), n)
}

// StripGoComments removes Go line comments (//...) and block comments (/*...*/) while preserving
// string/rune/raw-string literals so token checks cannot be bypassed via comment stuffing.
func StripGoComments(src string) string {
	var out strings.Builder
	out.Grow(len(src))
	n := len(src)
	i := 0
	for i < n {
		ch := src[i]
		// Line comment
		if ch == '/' && i+1 < n && src[i+1] == '/' {
			i += 2
			for i < n && src[i] != '\n' {
				i++
			}
			continue
		}
		// Block comment
		if ch == '/' && i+1 < n && src[i+1] == '*' {
			i += 2
			for i+1 < n && !(src[i] == '*' && src[i+1] == '/') {
				if src[i] == '\n' {
					out.WriteByte('\n')
				}
				i++
			}
			if i+1 < n {
				i += 2
			} else {
				i = n
			}
			out.WriteByte(' ')
			continue
		}
		// Raw string literal
		if ch == '`' {
			out.WriteByte(ch)
			i++
			for i < n && src[i] != '`' {
				out.WriteByte(src[i])
				i++
			}
			if i < n {
				out.WriteByte(src[i])
				i++
			}
			continue
		}
		// Double-quoted or single-quoted literal
		if ch == '"' || ch == '\'' {
			quote := ch
			out.WriteByte(ch)
			i++
			for i < n && src[i] != quote {
				if src[i] == '\\' && i+1 < n {
					out.WriteByte(src[i])
					out.WriteByte(src[i+1])
					i += 2
					continue
				}
				out.WriteByte(src[i])
				i++
			}
			if i < n {
				out.WriteByte(src[i])
				i++
			}
			continue
		}
		out.WriteByte(ch)
		i++
	}
	return out.String()
}

func (s *Service) VerifySubmission(ctx context.Context, req SubmissionRequest) (SubmissionResult, error) {
	canonicalExID, ok, err := s.NormalizeExerciseID(ctx, req.ExerciseID)
	if err != nil {
		return SubmissionResult{}, err
	}
	if !ok {
		return SubmissionResult{}, fmt.Errorf("%w: %s", ErrUnknownExercise, req.ExerciseID)
	}

	// Tier B: AST Verification Engine
	// Check syntax first
	astCheck := CheckAST(req.Code, Rule{})
	if !astCheck.ValidSyntax {
		diag := "Kode belum valid secara sintaks Go: " + astCheck.SyntaxError
		attemptID := s.nextAttemptID(canonicalExID)
		_ = s.store.RecordExerciseAttempt(ctx, database.ExerciseAttemptRecord{
			ID:          attemptID,
			UserID:      req.UserID,
			ExerciseID:  canonicalExID,
			Code:        req.Code,
			Passed:      false,
			Diagnostics: diag,
			ExecutionMs: 0,
			CreatedAt:   time.Now().UTC(),
		})
		return SubmissionResult{
			AttemptID:   attemptID,
			ExerciseID:  req.ExerciseID,
			Passed:      false,
			Missing:     []string{"sintaks Go yang valid"},
			Diagnostics: diag,
		}, nil
	}

	// 1. Check if database has explicit AST rule
	dbRule, err := s.store.GetExerciseRule(ctx, canonicalExID)
	if err != nil {
		return SubmissionResult{}, err
	}

	var passed bool
	var missing []string
	var diag string

	if dbRule != nil {
		rule := Rule{
			TargetFunc:  dbRule.TargetFunc,
			MustCall:    dbRule.MustCall,
			NoCall:      dbRule.NoCall,
			MustImport:  dbRule.MustImport,
			MustContain: append(dbRule.MustContain, req.RequiredTokens...),
		}
		res := CheckAST(req.Code, rule)
		passed = res.Passed
		diag = res.Diagnostics
		missing = append(res.Missing, res.Violations...)
	} else {
		// Fallback: Dynamically separate required_pattern into AST calls vs tokens
		dbPatterns, err := s.store.ExerciseRequiredPatterns(ctx, canonicalExID)
		if err != nil {
			return SubmissionResult{}, err
		}

		var mustCall []string
		var mustContain []string
		allToks := append(dbPatterns, req.RequiredTokens...)
		for _, tok := range allToks {
			tok = strings.TrimSpace(tok)
			if tok == "" {
				continue
			}
			if isFunctionCallToken(tok) {
				mustCall = append(mustCall, tok)
			} else {
				mustContain = append(mustContain, tok)
			}
		}

		res := CheckAST(req.Code, Rule{
			MustCall:    mustCall,
			MustContain: mustContain,
		})
		passed = res.Passed
		missing = append(res.Missing, res.Violations...)

		// Verify unfinished STEP placeholder
		if strings.Contains(req.Code, "// STEP:") {
			passed = false
			missing = append(missing, "unfinished // STEP: placeholder")
		}

		uncommented := StripGoComments(req.Code)
		if len(strings.TrimSpace(uncommented)) <= 10 {
			passed = false
			diag = "Implementation body is empty or contains only comments."
		} else if !passed {
			if len(missing) > 0 {
				diag = "Missing required implementation patterns (outside comments): " + strings.Join(missing, ", ")
			} else {
				diag = res.Diagnostics
			}
		} else {
			diag = "All required invariants satisfied."
		}
	}

	userID := req.UserID
	if userID == "" {
		return SubmissionResult{}, errors.New("userID is required")
	}
	attemptID := s.nextAttemptID(canonicalExID)
	if err := s.store.RecordExerciseAttempt(ctx, database.ExerciseAttemptRecord{
		ID:          attemptID,
		UserID:      userID,
		ExerciseID:  canonicalExID,
		Code:        req.Code,
		Passed:      passed,
		Diagnostics: diag,
		ExecutionMs: 0,
		CreatedAt:   time.Now().UTC(),
	}); err != nil {
		return SubmissionResult{}, err
	}

	return SubmissionResult{
		AttemptID:   attemptID,
		ExerciseID:  req.ExerciseID,
		Passed:      passed,
		Missing:     missing,
		Diagnostics: diag,
	}, nil
}

func isFunctionCallToken(tok string) bool {
	tok = strings.TrimSpace(tok)
	if !strings.Contains(tok, "(") {
		return false
	}
	if strings.HasPrefix(tok, "func ") || strings.Contains(tok, ":=") || strings.Contains(tok, " = ") {
		return false
	}
	if strings.Contains(tok, "if ") || strings.Contains(tok, "return ") || strings.Contains(tok, "for ") {
		return false
	}
	if strings.Contains(tok, "*") || strings.Contains(tok, "/") || strings.Contains(tok, "<<") || strings.Contains(tok, ">>") {
		return false
	}
	idx := strings.Index(tok, "(")
	if idx <= 0 {
		return false
	}
	pre := tok[idx-1]
	isIdentChar := (pre >= 'a' && pre <= 'z') || (pre >= 'A' && pre <= 'Z') || (pre >= '0' && pre <= '9') || pre == '_'
	if !isIdentChar {
		return false
	}
	prefix := strings.TrimSpace(tok[:idx])
	for _, r := range prefix {
		if !((r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') || r == '_' || r == '.') {
			return false
		}
	}
	return true
}
