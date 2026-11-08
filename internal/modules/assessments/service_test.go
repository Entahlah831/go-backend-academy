package assessments_test

import (
	"context"
	"errors"
	"testing"

	"github.com/gobackendacademy/platform/internal/modules/assessments"
	"github.com/gobackendacademy/platform/internal/shared"
)

type mockRepo struct {
	quizzes     map[string]shared.QuizDetail
	keys        map[string][]shared.QuizAnswerKey
	attempts    []shared.QuizAttemptRecord
	notFoundErr error
}

func (m *mockRepo) ListQuizzes(ctx context.Context) ([]shared.QuizSummary, error) {
	out := make([]shared.QuizSummary, 0, len(m.quizzes))
	for _, q := range m.quizzes {
		out = append(out, q.QuizSummary)
	}
	return out, nil
}

func (m *mockRepo) GetQuiz(ctx context.Context, id string) (shared.QuizDetail, error) {
	q, ok := m.quizzes[id]
	if !ok {
		return shared.QuizDetail{}, m.notFoundErr
	}
	return q, nil
}

func (m *mockRepo) QuizAnswerKeys(ctx context.Context, quizID string) ([]shared.QuizAnswerKey, error) {
	k, ok := m.keys[quizID]
	if !ok {
		return nil, m.notFoundErr
	}
	return k, nil
}

func (m *mockRepo) RecordQuizAttempt(ctx context.Context, rec shared.QuizAttemptRecord) error {
	m.attempts = append(m.attempts, rec)
	return nil
}

func (m *mockRepo) ListQuizAttempts(ctx context.Context, userID, quizID string) ([]shared.QuizAttemptRecord, error) {
	var out []shared.QuizAttemptRecord
	for _, a := range m.attempts {
		if a.UserID == userID && (quizID == "" || a.QuizID == quizID) {
			out = append(out, a)
		}
	}
	return out, nil
}

func TestAssessmentsServiceGrade(t *testing.T) {
	ctx := context.Background()
	sentinelNotFound := errors.New("not found")
	repo := &mockRepo{
		notFoundErr: sentinelNotFound,
		quizzes: map[string]shared.QuizDetail{
			"qz-test": {
				QuizSummary: shared.QuizSummary{ID: "qz-test", Level: 0, Title: "Test Quiz", QuestionCount: 2},
				Questions: []shared.QuizQuestion{
					{ID: "q1", OrderIndex: 1, Text: "Question 1"},
					{ID: "q2", OrderIndex: 2, Text: "Question 2"},
				},
			},
		},
		keys: map[string][]shared.QuizAnswerKey{
			"qz-test": {
				{QuestionID: "q1", CorrectIndex: 1, OptionCount: 4, Explanation: "Explanation 1"},
				{QuestionID: "q2", CorrectIndex: 0, OptionCount: 4, Explanation: "Explanation 2"},
			},
		},
	}

	svc := assessments.NewService(repo, sentinelNotFound)

	// Case 1: All correct
	res, err := svc.Grade(ctx, "usr_alice", "qz-test", []int{1, 0})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if res.Score != 2 || res.TotalQuestions != 2 {
		t.Errorf("expected score 2/2, got %d/%d", res.Score, res.TotalQuestions)
	}
	if !res.Results[0].Correct || !res.Results[1].Correct {
		t.Errorf("expected all answers correct, got %+v", res.Results)
	}
	if len(repo.attempts) != 1 {
		t.Fatalf("expected 1 recorded attempt, got %d", len(repo.attempts))
	}

	// Case 2: One wrong
	res2, err := svc.Grade(ctx, "usr_alice", "qz-test", []int{1, 3})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if res2.Score != 1 {
		t.Errorf("expected score 1/2, got %d", res2.Score)
	}
	if res2.Results[1].Correct || res2.Results[1].CorrectIndex != 0 {
		t.Errorf("expected question 2 incorrect with correctIndex=0, got %+v", res2.Results[1])
	}

	// Case 3: Wrong number of answers
	_, err = svc.Grade(ctx, "usr_alice", "qz-test", []int{1})
	if !errors.Is(err, assessments.ErrAnswerCount) {
		t.Errorf("expected ErrAnswerCount, got %v", err)
	}

	// Case 4: Answer out of bounds
	_, err = svc.Grade(ctx, "usr_alice", "qz-test", []int{1, 99})
	if !errors.Is(err, assessments.ErrAnswerOutside) {
		t.Errorf("expected ErrAnswerOutside, got %v", err)
	}

	// Case 5: Unknown quiz
	_, err = svc.Grade(ctx, "usr_alice", "qz-nonexistent", []int{0})
	if !errors.Is(err, assessments.ErrUnknownQuiz) {
		t.Errorf("expected ErrUnknownQuiz, got %v", err)
	}
}
