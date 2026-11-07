// Package casestudies exposes the production case studies and their ordered steps.
package casestudies

import (
	"context"

	"github.com/gobackendacademy/platform/internal/shared"
)

type Repository interface {
	ListCaseStudies(ctx context.Context) ([]shared.CaseStudySummary, error)
	GetCaseStudy(ctx context.Context, id string) (shared.CaseStudyDetail, error)
}

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) ListCaseStudies(ctx context.Context) ([]shared.CaseStudySummary, error) {
	return s.repo.ListCaseStudies(ctx)
}

func (s *Service) GetCaseStudy(ctx context.Context, id string) (shared.CaseStudyDetail, error) {
	return s.repo.GetCaseStudy(ctx, id)
}
