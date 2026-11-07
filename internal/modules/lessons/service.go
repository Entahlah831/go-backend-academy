// Package lessons exposes lesson summaries and full lesson detail (sections,
// references, exercise, and test cases) from the lessons-related tables.
package lessons

import (
	"context"

	"github.com/gobackendacademy/platform/internal/shared"
)

type Repository interface {
	ListLessons(ctx context.Context) ([]shared.LessonSummary, error)
	LessonExists(ctx context.Context, id string) (bool, error)
	GetLessonDetail(ctx context.Context, id string) (shared.LessonDetail, error)
}

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) ListLessons(ctx context.Context) ([]shared.LessonSummary, error) {
	return s.repo.ListLessons(ctx)
}

func (s *Service) HasLesson(ctx context.Context, id string) (bool, error) {
	if id == "" {
		return false, nil
	}
	return s.repo.LessonExists(ctx, id)
}

func (s *Service) GetLesson(ctx context.Context, id string) (shared.LessonDetail, error) {
	return s.repo.GetLessonDetail(ctx, id)
}
