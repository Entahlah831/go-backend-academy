package exercises

import (
	"context"
	"testing"

	"github.com/gobackendacademy/platform/internal/config"
	"github.com/gobackendacademy/platform/internal/platform/database"
)

func TestVerifySubmissionRecordsZeroExecutionMs(t *testing.T) {
	ctx := context.Background()
	t.Setenv("DB_DRIVER", "memory")
	t.Setenv("DB_AUTO_MIGRATE", "true")
	t.Setenv("DB_AUTO_SEED", "true")

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("failed to load config: %v", err)
	}

	store, err := database.Open(ctx, cfg)
	if err != nil {
		t.Fatalf("failed to open database: %v", err)
	}
	defer store.Close()

	svc := NewService(store)
	_, err = svc.VerifySubmission(ctx, SubmissionRequest{
		ExerciseID: "l0-backend-http-lifecycle",
		Code:       "package main\nimport \"net/http\"\n// dummy implementation",
		UserID:     "usr_test",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	attempts, err := svc.ListAttempts(ctx, "usr_test", "l0-backend-http-lifecycle")
	if err != nil {
		t.Fatalf("failed to list attempts: %v", err)
	}
	if len(attempts) == 0 {
		t.Fatalf("expected recorded attempt, got 0")
	}

	if attempts[0].ExecutionMs != 0 {
		t.Errorf("ExecutionMs should be 0 (no fake execution duration), got %d", attempts[0].ExecutionMs)
	}
}
