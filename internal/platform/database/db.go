package database

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	// Real database/sql drivers. modernc.org/sqlite is pure Go (no CGO) and
	// registers the driver name "sqlite"; pgx/v5/stdlib registers "pgx".
	_ "github.com/jackc/pgx/v5/stdlib"
	_ "modernc.org/sqlite"

	"github.com/gobackendacademy/platform/internal/config"
	"github.com/gobackendacademy/platform/internal/shared"
)

// ErrNotFound is returned by repository lookups when no row matches.
var ErrNotFound = errors.New("not found")

// Store is the single persistence gateway. Every mode, including DB_DRIVER=memory,
// goes through real SQL against a real engine; there is no silent map-based fallback.
type Store struct {
	db         *sql.DB
	driverName string // configured driver: sqlite | postgres | memory
	dialect    string // SQL dialect used for migrations/seed: sqlite | postgres
	persistent bool
	target     string
}

type ExerciseAttemptRecord struct {
	ID          string    `json:"id"`
	UserID      string    `json:"user_id"`
	ExerciseID  string    `json:"exercise_id"`
	Code        string    `json:"submitted_code"`
	Passed      bool      `json:"passed"`
	Diagnostics string    `json:"diagnostics_output"`
	ExecutionMs int       `json:"execution_ms"`
	CreatedAt   time.Time `json:"created_at"`
}

// Open connects to the configured database, verifies it with a ping, and (when
// enabled) applies pending migrations and seed data. Any failure is returned so
// the caller can stop startup: a server configured for SQLite or PostgreSQL
// never pretends to be ready without a working connection.
func Open(ctx context.Context, cfg *config.Config) (*Store, error) {
	s := &Store{driverName: cfg.DBDriver, target: cfg.DBTarget()}

	var (
		sqlDriver string
		dsn       string
	)
	switch cfg.DBDriver {
	case "sqlite":
		sqlDriver, dsn, s.dialect, s.persistent = "sqlite", cfg.SQLiteDSN, "sqlite", true
		if err := ensureSQLiteDir(cfg.SQLiteDSN); err != nil {
			return nil, err
		}
	case "postgres":
		sqlDriver, dsn, s.dialect, s.persistent = "pgx", cfg.PostgresDSN, "postgres", true
	case "memory":
		// A private in-memory SQLite database. It lives only as long as its single
		// connection, so the pool is pinned to exactly one never-expiring connection.
		sqlDriver, dsn, s.dialect, s.persistent = "sqlite", "file::memory:?_pragma=foreign_keys(ON)", "sqlite", false
	default:
		return nil, fmt.Errorf("unsupported DB_DRIVER %q", cfg.DBDriver)
	}

	db, err := sql.Open(sqlDriver, dsn)
	if err != nil {
		return nil, fmt.Errorf("opening %s database: %w", cfg.DBDriver, err)
	}
	if cfg.DBDriver == "memory" {
		db.SetMaxOpenConns(1)
		db.SetMaxIdleConns(1)
		db.SetConnMaxLifetime(0)
		db.SetConnMaxIdleTime(0)
	} else {
		db.SetMaxOpenConns(cfg.DBMaxOpenConns)
		db.SetMaxIdleConns(cfg.DBMaxIdleConns)
		db.SetConnMaxLifetime(cfg.DBConnMaxLifetime)
		db.SetConnMaxIdleTime(5 * time.Minute)
	}

	pingCtx, cancel := context.WithTimeout(ctx, cfg.DBConnectTimeout)
	defer cancel()
	if err := db.PingContext(pingCtx); err != nil {
		_ = db.Close()
		return nil, fmt.Errorf("connecting to %s database at %s: %w", cfg.DBDriver, s.target, err)
	}
	s.db = db

	// The in-memory database starts empty every time, so it is always migrated and seeded.
	autoMigrate := cfg.DBAutoMigrate || cfg.DBDriver == "memory"
	autoSeed := cfg.DBAutoSeed || cfg.DBDriver == "memory"
	if autoMigrate {
		if _, err := s.MigrateUp(ctx); err != nil {
			_ = db.Close()
			return nil, err
		}
		if autoSeed {
			if _, err := s.Seed(ctx); err != nil {
				_ = db.Close()
				return nil, err
			}
		}
	}
	return s, nil
}

// ensureSQLiteDir creates the parent directory of a file-based SQLite DSN so a
// fresh checkout can start without manual setup.
func ensureSQLiteDir(dsn string) error {
	path := strings.TrimPrefix(dsn, "file:")
	if i := strings.Index(path, "?"); i >= 0 {
		path = path[:i]
	}
	if path == "" || strings.Contains(path, ":memory:") {
		return nil
	}
	dir := filepath.Dir(path)
	if dir == "." || dir == "" {
		return nil
	}
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return fmt.Errorf("creating SQLite directory %s: %w", dir, err)
	}
	return nil
}

// DriverName reports the configured driver (sqlite, postgres, memory).
func (s *Store) DriverName() string { return s.driverName }

// Persistent reports whether data survives a process restart.
func (s *Store) Persistent() bool { return s.persistent }

// Target is a secret-free description of the connected database.
func (s *Store) Target() string { return s.target }

// DB exposes the underlying pool for integration tests and tooling.
func (s *Store) DB() *sql.DB { return s.db }

// Ping performs a real round-trip to the database engine.
func (s *Store) Ping(ctx context.Context) error {
	if s == nil || s.db == nil {
		return errors.New("database is not connected")
	}
	return s.db.PingContext(ctx)
}

func (s *Store) Close() error {
	if s != nil && s.db != nil {
		return s.db.Close()
	}
	return nil
}

// ensureUser guarantees that userID exists in the users table before inserting
// child rows, because foreign keys are enforced on both engines.
func (s *Store) ensureUser(ctx context.Context, userID string) error {
	if userID == "" {
		return errors.New("user_id must not be empty")
	}
	const q = `
		INSERT INTO users (id, handle, display_name)
		VALUES ($1, $2, $3)
		ON CONFLICT (id) DO NOTHING
	`
	if _, err := s.db.ExecContext(ctx, q, userID, userID, userID); err != nil {
		return fmt.Errorf("ensuring user %s exists: %w", userID, err)
	}
	return nil
}

// IsValidProgressStatus validates against the schema CHECK constraint: status IN ('in_progress', 'completed').
func IsValidProgressStatus(status string) bool {
	return status == "in_progress" || status == "completed"
}

// IsValidBookmarkType validates against the schema CHECK constraint: item_type IN ('lesson', 'case_study', 'db_scenario').
func IsValidBookmarkType(itemType string) bool {
	return itemType == "lesson" || itemType == "case_study" || itemType == "db_scenario"
}

// SetLessonProgress UPSERTs a row in user_progress.
func (s *Store) SetLessonProgress(ctx context.Context, userID, lessonID, status string) error {
	if !IsValidProgressStatus(status) {
		return fmt.Errorf("invalid progress status %q: must be 'in_progress' or 'completed'", status)
	}
	if err := s.ensureUser(ctx, userID); err != nil {
		return err
	}
	const q = `
		INSERT INTO user_progress (user_id, lesson_id, status, updated_at)
		VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
		ON CONFLICT (user_id, lesson_id)
		DO UPDATE SET status = EXCLUDED.status, updated_at = CURRENT_TIMESTAMP
	`
	if _, err := s.db.ExecContext(ctx, q, userID, lessonID, status); err != nil {
		return fmt.Errorf("upserting user_progress: %w", err)
	}
	return nil
}

func (s *Store) GetUserProgress(ctx context.Context, userID string) (map[string]string, error) {
	out := make(map[string]string)
	const q = `SELECT lesson_id, status FROM user_progress WHERE user_id = $1`
	rows, err := s.db.QueryContext(ctx, q, userID)
	if err != nil {
		return nil, fmt.Errorf("querying user_progress: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var lid, st string
		if err := rows.Scan(&lid, &st); err != nil {
			return nil, fmt.Errorf("scanning user_progress: %w", err)
		}
		out[lid] = st
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterating user_progress: %w", err)
	}
	return out, nil
}

func (s *Store) SaveNote(ctx context.Context, noteID, userID, lessonID, content string) error {
	if err := s.ensureUser(ctx, userID); err != nil {
		return err
	}
	const q = `
		INSERT INTO user_notes (id, user_id, lesson_id, content, updated_at)
		VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
		ON CONFLICT (user_id, lesson_id)
		DO UPDATE SET content = EXCLUDED.content, updated_at = CURRENT_TIMESTAMP
	`
	if _, err := s.db.ExecContext(ctx, q, noteID, userID, lessonID, content); err != nil {
		return fmt.Errorf("upserting user_notes: %w", err)
	}
	return nil
}

func (s *Store) CountUserNotes(ctx context.Context, userID string) (int, error) {
	var count int
	err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM user_notes WHERE user_id = $1`, userID).Scan(&count)
	return count, err
}

func (s *Store) CountUserBookmarks(ctx context.Context, userID string) (int, error) {
	var count int
	err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM user_bookmarks WHERE user_id = $1`, userID).Scan(&count)
	return count, err
}

func (s *Store) CreateSession(ctx context.Context, sessionHash, userID string, expiresAt time.Time) error {
	if strings.TrimSpace(sessionHash) == "" {
		return errors.New("sessionHash cannot be empty")
	}
	if err := s.ensureUser(ctx, userID); err != nil {
		return err
	}
	const q = `
		INSERT INTO sessions (id, user_id, expires_at)
		VALUES ($1, $2, $3)
		ON CONFLICT (id) DO UPDATE SET expires_at = EXCLUDED.expires_at
	`
	if _, err := s.db.ExecContext(ctx, q, sessionHash, userID, expiresAt.UTC()); err != nil {
		return fmt.Errorf("creating session: %w", err)
	}
	return nil
}

func (s *Store) PurgeExpiredSessions(ctx context.Context) (int64, error) {
	res, err := s.db.ExecContext(ctx, `DELETE FROM sessions WHERE expires_at < $1`, time.Now().UTC())
	if err != nil {
		return 0, fmt.Errorf("purging expired sessions: %w", err)
	}
	return res.RowsAffected()
}

func (s *Store) ClaimLegacyUser(ctx context.Context, legacyUID, targetUID string) error {
	if legacyUID == "" || targetUID == "" || legacyUID == targetUID {
		return errors.New("invalid legacy or target user ID")
	}
	var existingLegacy string
	if err := s.db.QueryRowContext(ctx, `SELECT id FROM users WHERE id = $1`, legacyUID).Scan(&existingLegacy); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrNotFound
		}
		return fmt.Errorf("checking legacy user: %w", err)
	}
	if err := s.ensureUser(ctx, targetUID); err != nil {
		return err
	}

	var pCount, nCount, bCount int
	_ = s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM user_progress WHERE user_id = $1`, targetUID).Scan(&pCount)
	_ = s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM user_notes WHERE user_id = $1`, targetUID).Scan(&nCount)
	_ = s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM user_bookmarks WHERE user_id = $1`, targetUID).Scan(&bCount)
	if (pCount + nCount + bCount) > 0 {
		return errors.New("target session already contains learning progress")
	}

	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("starting claim transaction: %w", err)
	}
	defer tx.Rollback()

	tables := []string{"user_progress", "user_bookmarks", "user_notes", "exercise_attempts", "quiz_attempts"}
	for _, tbl := range tables {
		q := fmt.Sprintf("UPDATE %s SET user_id = $1 WHERE user_id = $2", tbl)
		if _, err := tx.ExecContext(ctx, q, targetUID, legacyUID); err != nil {
			return fmt.Errorf("migrating %s: %w", tbl, err)
		}
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("committing claim: %w", err)
	}
	return nil
}

func (s *Store) GetSessionUser(ctx context.Context, sessionHash string) (string, error) {
	const q = `SELECT user_id FROM sessions WHERE id = $1 AND expires_at > $2`
	var userID string
	if err := s.db.QueryRowContext(ctx, q, sessionHash, time.Now().UTC()).Scan(&userID); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return "", ErrNotFound
		}
		return "", fmt.Errorf("querying session: %w", err)
	}
	return userID, nil
}

func (s *Store) GetNotes(ctx context.Context, userID string) (map[string]string, error) {
	out := make(map[string]string)
	const q = `SELECT lesson_id, content FROM user_notes WHERE user_id = $1`
	rows, err := s.db.QueryContext(ctx, q, userID)
	if err != nil {
		return nil, fmt.Errorf("querying user_notes: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var lid, c string
		if err := rows.Scan(&lid, &c); err != nil {
			return nil, fmt.Errorf("scanning user_notes: %w", err)
		}
		out[lid] = c
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterating user_notes: %w", err)
	}
	return out, nil
}

func (s *Store) SaveBookmark(ctx context.Context, rec shared.BookmarkRecord) error {
	if !IsValidBookmarkType(rec.ItemType) {
		return fmt.Errorf("invalid bookmark item_type %q: must be 'lesson', 'case_study', or 'db_scenario'", rec.ItemType)
	}
	if err := s.ensureUser(ctx, rec.UserID); err != nil {
		return err
	}
	const q = `
		INSERT INTO user_bookmarks (user_id, item_type, item_id, note, created_at)
		VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
		ON CONFLICT (user_id, item_type, item_id)
		DO UPDATE SET note = EXCLUDED.note
	`
	if _, err := s.db.ExecContext(ctx, q, rec.UserID, rec.ItemType, rec.ItemID, rec.Note); err != nil {
		return fmt.Errorf("upserting user_bookmarks: %w", err)
	}
	return nil
}

func (s *Store) ListBookmarks(ctx context.Context, userID string) ([]shared.BookmarkRecord, error) {
	out := []shared.BookmarkRecord{}
	const q = `SELECT user_id, item_type, item_id, note, created_at FROM user_bookmarks WHERE user_id = $1 ORDER BY created_at DESC, item_id`
	rows, err := s.db.QueryContext(ctx, q, userID)
	if err != nil {
		return nil, fmt.Errorf("querying user_bookmarks: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var r shared.BookmarkRecord
		if err := rows.Scan(&r.UserID, &r.ItemType, &r.ItemID, &r.Note, &r.CreatedAt); err != nil {
			return nil, fmt.Errorf("scanning user_bookmarks: %w", err)
		}
		out = append(out, r)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterating user_bookmarks: %w", err)
	}
	return out, nil
}

func (s *Store) RecordExerciseAttempt(ctx context.Context, rec ExerciseAttemptRecord) error {
	if err := s.ensureUser(ctx, rec.UserID); err != nil {
		return err
	}
	const q = `
		INSERT INTO exercise_attempts (id, user_id, exercise_id, submitted_code, passed, diagnostics_output, execution_ms, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP)
	`
	if _, err := s.db.ExecContext(ctx, q, rec.ID, rec.UserID, rec.ExerciseID, rec.Code, rec.Passed, rec.Diagnostics, rec.ExecutionMs); err != nil {
		return fmt.Errorf("inserting exercise_attempt: %w", err)
	}
	return nil
}

// ListExerciseAttempts returns attempts newest-first. Empty filters match all rows.
func (s *Store) ListExerciseAttempts(ctx context.Context, userID, exerciseID string, limit int) ([]ExerciseAttemptRecord, error) {
	if limit <= 0 || limit > 200 {
		limit = 50
	}
	const q = `
		SELECT id, user_id, exercise_id, submitted_code, passed, diagnostics_output, execution_ms, created_at
		FROM exercise_attempts
		WHERE ($1 = '' OR user_id = $1) AND ($2 = '' OR exercise_id = $2)
		ORDER BY created_at DESC, id DESC
		LIMIT $3
	`
	rows, err := s.db.QueryContext(ctx, q, userID, exerciseID, limit)
	if err != nil {
		return nil, fmt.Errorf("querying exercise_attempts: %w", err)
	}
	defer rows.Close()
	out := []ExerciseAttemptRecord{}
	for rows.Next() {
		var a ExerciseAttemptRecord
		if err := rows.Scan(&a.ID, &a.UserID, &a.ExerciseID, &a.Code, &a.Passed, &a.Diagnostics, &a.ExecutionMs, &a.CreatedAt); err != nil {
			return nil, fmt.Errorf("scanning exercise_attempts: %w", err)
		}
		out = append(out, a)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterating exercise_attempts: %w", err)
	}
	return out, nil
}
