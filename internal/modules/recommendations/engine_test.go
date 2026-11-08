package recommendations_test

import (
	"testing"

	"github.com/gobackendacademy/platform/internal/modules/recommendations"
)

func TestEngineEmptySnapshotRecommendsStageA(t *testing.T) {
	eng := recommendations.NewEngine()
	snap := recommendations.LearningSnapshot{}

	items := eng.Compute(snap)
	if len(items) == 0 {
		t.Fatalf("expected at least one recommendation for empty snapshot, got 0")
	}

	first := items[0]
	if first.TargetLessonID != "l0-stage-a-what-is-backend" {
		t.Errorf("expected empty snapshot to recommend 'l0-stage-a-what-is-backend', got %q", first.TargetLessonID)
	}
}

func TestEngineProgressiveProgression(t *testing.T) {
	eng := recommendations.NewEngine()
	snap := recommendations.LearningSnapshot{
		CompletedLessons: map[string]bool{
			"l0-stage-a-what-is-backend": true,
		},
	}

	items := eng.Compute(snap)
	if len(items) == 0 {
		t.Fatalf("expected recommendations, got 0")
	}

	first := items[0]
	if first.TargetLessonID != "l0-stage-a-git-go-workspace" {
		t.Errorf("expected next recommendation to be 'l0-stage-a-git-go-workspace', got %q", first.TargetLessonID)
	}
}
