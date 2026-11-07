// Package assessments serves quizzes and grades attempts on the server, so the
// answer key never has to be shipped to the browser before the learner answers.
package assessments

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"

	"github.com/gobackendacademy/platform/internal/shared"
)

var (
	ErrUnknownQuiz   = errors.New("unknown quiz_id")
	ErrAnswerCount   = errors.New("answer count does not match question count")
	ErrAnswerOutside = errors.New("answer index out of range")
)

type Repository interface {
	ListQuizzes(ctx context.Context) ([]shared.QuizSummary, error)
	GetQuiz(ctx context.Context, id string) (shared.QuizDetail, error)
	QuizAnswerKeys(ctx context.Context, quizID string) ([]shared.QuizAnswerKey, error)
	RecordQuizAttempt(ctx context.Context, rec shared.QuizAttemptRecord) error
	ListQuizAttempts(ctx context.Context, userID, quizID string) ([]shared.QuizAttemptRecord, error)
}

type Service struct {
	repo     Repository
	notFound error
}

// NewService takes the repository and the sentinel error it returns for missing rows.
func NewService(repo Repository, notFound error) *Service {
	return &Service{repo: repo, notFound: notFound}
}

func (s *Service) ListQuizzes(ctx context.Context) ([]shared.QuizSummary, error) {
	return s.repo.ListQuizzes(ctx)
}

func (s *Service) GetQuiz(ctx context.Context, id string) (shared.QuizDetail, error) {
	d, err := s.repo.GetQuiz(ctx, id)
	if err != nil && s.notFound != nil && errors.Is(err, s.notFound) {
		return d, fmt.Errorf("%w: %s", ErrUnknownQuiz, id)
	}
	return d, err
}

func (s *Service) ListAttempts(ctx context.Context, userID, quizID string) ([]shared.QuizAttemptRecord, error) {
	return s.repo.ListQuizAttempts(ctx, userID, quizID)
}

// Grade scores answers (one selected option index per question, in question order),
// persists the attempt in quiz_attempts, and returns per-question feedback.
func (s *Service) Grade(ctx context.Context, userID, quizID string, answers []int) (shared.QuizAttemptResult, error) {
	keys, err := s.repo.QuizAnswerKeys(ctx, quizID)
	if err != nil {
		if s.notFound != nil && errors.Is(err, s.notFound) {
			return shared.QuizAttemptResult{}, fmt.Errorf("%w: %s", ErrUnknownQuiz, quizID)
		}
		return shared.QuizAttemptResult{}, err
	}
	if len(answers) != len(keys) {
		return shared.QuizAttemptResult{}, fmt.Errorf("%w: got %d, want %d", ErrAnswerCount, len(answers), len(keys))
	}
	res := shared.QuizAttemptResult{QuizID: quizID, TotalQuestions: len(keys), Results: make([]shared.QuizQuestionResult, 0, len(keys))}
	for i, k := range keys {
		sel := answers[i]
		if sel < 0 || (k.OptionCount > 0 && sel >= k.OptionCount) {
			return shared.QuizAttemptResult{}, fmt.Errorf("%w: question %d has %d options", ErrAnswerOutside, i+1, k.OptionCount)
		}
		ok := sel == k.CorrectIndex
		if ok {
			res.Score++
		}
		res.Results = append(res.Results, shared.QuizQuestionResult{
			QuestionID: k.QuestionID, Selected: sel, CorrectIndex: k.CorrectIndex, Correct: ok, Explanation: k.Explanation,
		})
	}
	var b [8]byte
	_, _ = rand.Read(b[:])
	res.AttemptID = "qza_" + hex.EncodeToString(b[:])
	if err := s.repo.RecordQuizAttempt(ctx, shared.QuizAttemptRecord{
		ID: res.AttemptID, UserID: userID, QuizID: quizID, Score: res.Score, TotalQuestions: res.TotalQuestions,
	}); err != nil {
		return shared.QuizAttemptResult{}, err
	}
	return res, nil
}
