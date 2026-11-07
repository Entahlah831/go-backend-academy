// Package curriculum exposes curriculum levels and modules. The data lives in the
// curriculum_levels and modules tables (seeded from seed/<dialect>/001_seed_data.sql).
package curriculum

import (
	"context"

	"github.com/gobackendacademy/platform/internal/shared"
)

type Repository interface {
	ListLevels(ctx context.Context) ([]shared.LevelSummary, error)
	ListModules(ctx context.Context) ([]shared.ModuleSummary, error)
}

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) ListLevels(ctx context.Context) ([]shared.LevelSummary, error) {
	return s.repo.ListLevels(ctx)
}

func (s *Service) ListModules(ctx context.Context) ([]shared.ModuleSummary, error) {
	return s.repo.ListModules(ctx)
}
