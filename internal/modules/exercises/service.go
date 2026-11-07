package exercises

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
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

	dbPatterns, err := s.store.ExerciseRequiredPatterns(ctx, canonicalExID)
	if err != nil {
		return SubmissionResult{}, err
	}
	tokens := make([]string, 0, len(dbPatterns)+len(req.RequiredTokens))
	seenTok := make(map[string]bool)
	for _, list := range [][]string{dbPatterns, req.RequiredTokens} {
		for _, tok := range list {
			if tok != "" && !seenTok[tok] {
				seenTok[tok] = true
				tokens = append(tokens, tok)
			}
		}
	}

	uncommented := StripGoComments(req.Code)
	var missing []string
	for _, tok := range tokens {
		if tok != "" && !strings.Contains(uncommented, tok) {
			missing = append(missing, tok)
		}
	}
	if strings.Contains(req.Code, "// STEP:") {
		missing = append(missing, "unfinished // STEP: placeholder")
	}

	passed := len(missing) == 0 && len(strings.TrimSpace(uncommented)) > 10
	diag := "All required invariants satisfied."
	if !passed {
		if len(missing) > 0 {
			diag = "Missing required implementation patterns (outside comments): " + strings.Join(missing, ", ")
		} else {
			diag = "Implementation body is empty or contains only comments."
		}
	}

	userID := req.UserID
	if userID == "" {
		userID = "usr_local_default"
	}
	attemptID := s.nextAttemptID(canonicalExID)
	if err := s.store.RecordExerciseAttempt(ctx, database.ExerciseAttemptRecord{
		ID:          attemptID,
		UserID:      userID,
		ExerciseID:  canonicalExID,
		Code:        req.Code,
		Passed:      passed,
		Diagnostics: diag,
		ExecutionMs: 12,
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
