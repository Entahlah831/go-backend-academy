package database

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"fmt"
	"io/fs"
	"path"
	"sort"
	"strings"

	"github.com/gobackendacademy/platform/migrations"
	"github.com/gobackendacademy/platform/seed"
)

// seedVersionPrefix distinguishes seed bookkeeping rows from schema versions in schema_migrations.
const seedVersionPrefix = "seed:"

// Migration is one versioned schema change loaded from the embedded migrations FS.
type Migration struct {
	Version string
	Up      string
	Down    string
}

// MigrationState reports whether a known migration has been applied.
type MigrationState struct {
	Version string `json:"version"`
	Applied bool   `json:"applied"`
}

// LoadMigrations reads <dialect>/*.up.sql (and matching .down.sql) from fsys, sorted by version.
func LoadMigrations(fsys fs.FS, dialect string) ([]Migration, error) {
	ups, err := fs.Glob(fsys, dialect+"/*.up.sql")
	if err != nil {
		return nil, fmt.Errorf("listing %s migrations: %w", dialect, err)
	}
	if len(ups) == 0 {
		return nil, fmt.Errorf("no %s migrations found", dialect)
	}
	sort.Strings(ups)
	out := make([]Migration, 0, len(ups))
	for _, upPath := range ups {
		version := strings.TrimSuffix(path.Base(upPath), ".up.sql")
		up, err := fs.ReadFile(fsys, upPath)
		if err != nil {
			return nil, fmt.Errorf("reading %s: %w", upPath, err)
		}
		downPath := strings.TrimSuffix(upPath, ".up.sql") + ".down.sql"
		down, err := fs.ReadFile(fsys, downPath)
		if err != nil {
			return nil, fmt.Errorf("migration %s has no down file %s: %w", version, downPath, err)
		}
		out = append(out, Migration{Version: version, Up: string(up), Down: string(down)})
	}
	return out, nil
}

func (s *Store) ensureMigrationsTable(ctx context.Context) error {
	ddl := `CREATE TABLE IF NOT EXISTS schema_migrations (
		version VARCHAR(64) PRIMARY KEY,
		applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
	)`
	if s.dialect == "postgres" {
		ddl = `CREATE TABLE IF NOT EXISTS schema_migrations (
			version VARCHAR(64) PRIMARY KEY,
			applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`
	}
	if _, err := s.db.ExecContext(ctx, ddl); err != nil {
		return fmt.Errorf("creating schema_migrations: %w", err)
	}
	return nil
}

func (s *Store) appliedVersions(ctx context.Context) (map[string]bool, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT version FROM schema_migrations`)
	if err != nil {
		return nil, fmt.Errorf("reading schema_migrations: %w", err)
	}
	defer rows.Close()
	out := make(map[string]bool)
	for rows.Next() {
		var v string
		if err := rows.Scan(&v); err != nil {
			return nil, fmt.Errorf("scanning schema_migrations: %w", err)
		}
		out[v] = true
	}
	return out, rows.Err()
}

// MigrateUp applies every pending migration in version order. Each migration
// and its bookkeeping row commit in one transaction (both engines support
// transactional DDL), so a failed migration leaves no partial schema behind.
func (s *Store) MigrateUp(ctx context.Context) ([]string, error) {
	all, err := LoadMigrations(migrations.FS, s.dialect)
	if err != nil {
		return nil, err
	}
	if err := s.ensureMigrationsTable(ctx); err != nil {
		return nil, err
	}
	applied, err := s.appliedVersions(ctx)
	if err != nil {
		return nil, err
	}
	var done []string
	for _, m := range all {
		if applied[m.Version] {
			continue
		}
		if err := s.inTx(ctx, func(tx *sql.Tx) error {
			if _, err := tx.ExecContext(ctx, m.Up); err != nil {
				return err
			}
			_, err := tx.ExecContext(ctx, `INSERT INTO schema_migrations (version) VALUES ($1) ON CONFLICT (version) DO NOTHING`, m.Version)
			return err
		}); err != nil {
			return done, fmt.Errorf("applying migration %s: %w", m.Version, err)
		}
		done = append(done, m.Version)
	}
	return done, nil
}

// MigrateDown reverts the most recent `steps` applied migrations (newest first).
// When no schema migration remains, seed bookkeeping is cleared as well because
// the seeded tables no longer exist.
func (s *Store) MigrateDown(ctx context.Context, steps int) ([]string, error) {
	if steps <= 0 {
		steps = 1
	}
	all, err := LoadMigrations(migrations.FS, s.dialect)
	if err != nil {
		return nil, err
	}
	if err := s.ensureMigrationsTable(ctx); err != nil {
		return nil, err
	}
	applied, err := s.appliedVersions(ctx)
	if err != nil {
		return nil, err
	}
	var done []string
	for i := len(all) - 1; i >= 0 && len(done) < steps; i-- {
		m := all[i]
		if !applied[m.Version] {
			continue
		}
		if err := s.inTx(ctx, func(tx *sql.Tx) error {
			if _, err := tx.ExecContext(ctx, m.Down); err != nil {
				return err
			}
			_, err := tx.ExecContext(ctx, `DELETE FROM schema_migrations WHERE version = $1`, m.Version)
			return err
		}); err != nil {
			return done, fmt.Errorf("reverting migration %s: %w", m.Version, err)
		}
		delete(applied, m.Version)
		done = append(done, m.Version)
	}
	remaining := false
	for v := range applied {
		if !strings.HasPrefix(v, seedVersionPrefix) {
			remaining = true
			break
		}
	}
	if !remaining {
		if _, err := s.db.ExecContext(ctx, `DELETE FROM schema_migrations WHERE version LIKE 'seed:%'`); err != nil {
			return done, fmt.Errorf("clearing seed bookkeeping: %w", err)
		}
	}
	return done, nil
}

// MigrationStatus lists every known migration and seed file with its applied flag.
func (s *Store) MigrationStatus(ctx context.Context) ([]MigrationState, error) {
	all, err := LoadMigrations(migrations.FS, s.dialect)
	if err != nil {
		return nil, err
	}
	if err := s.ensureMigrationsTable(ctx); err != nil {
		return nil, err
	}
	applied, err := s.appliedVersions(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]MigrationState, 0, len(all)+1)
	for _, m := range all {
		out = append(out, MigrationState{Version: m.Version, Applied: applied[m.Version]})
	}
	seeds, err := fs.Glob(seed.FS, s.dialect+"/*.sql")
	if err != nil {
		return nil, err
	}
	sort.Strings(seeds)
	for _, p := range seeds {
		base := strings.TrimSuffix(path.Base(p), ".sql")
		raw, _ := fs.ReadFile(seed.FS, p)
		sum := sha256.Sum256(raw)
		v := fmt.Sprintf("%s%s:%x", seedVersionPrefix, base, sum[:8])
		isApplied := applied[v]
		if !isApplied {
			for av := range applied {
				if strings.HasPrefix(av, seedVersionPrefix+base) {
					isApplied = true
					break
				}
			}
		}
		out = append(out, MigrationState{Version: v, Applied: isApplied})
	}
	return out, nil
}

// Seed applies each embedded seed file, tracked as "seed:<name>:<sha256[:16]>"
// in schema_migrations. If curriculum rows already exist without a seed record,
// or if a seed's content hash changed, the seed is re-applied using upsert logic.
func (s *Store) Seed(ctx context.Context) ([]string, error) {
	files, err := fs.Glob(seed.FS, s.dialect+"/*.sql")
	if err != nil {
		return nil, fmt.Errorf("listing %s seed files: %w", s.dialect, err)
	}
	sort.Strings(files)
	applied, err := s.appliedVersions(ctx)
	if err != nil {
		return nil, err
	}
	var done []string
	for _, p := range files {
		raw, err := fs.ReadFile(seed.FS, p)
		if err != nil {
			return done, fmt.Errorf("reading seed %s: %w", p, err)
		}
		base := strings.TrimSuffix(path.Base(p), ".sql")
		sum := sha256.Sum256(raw)
		version := fmt.Sprintf("%s%s:%x", seedVersionPrefix, base, sum[:8])
		if applied[version] {
			continue
		}
		if err := s.inTx(ctx, func(tx *sql.Tx) error {
			if _, err := tx.ExecContext(ctx, string(raw)); err != nil {
				return err
			}
			// Clear any previous or unhashed version record for this seed file
			pattern := seedVersionPrefix + base + "%"
			if _, err := tx.ExecContext(ctx, `DELETE FROM schema_migrations WHERE version LIKE $1`, pattern); err != nil {
				return err
			}
			_, err := tx.ExecContext(ctx, `INSERT INTO schema_migrations (version) VALUES ($1) ON CONFLICT (version) DO NOTHING`, version)
			return err
		}); err != nil {
			return done, fmt.Errorf("applying seed %s (%s): %w", p, version, err)
		}
		done = append(done, version)
	}
	return done, nil
}

// Reseed clears all seed version tracking from schema_migrations and re-executes all seeds.
func (s *Store) Reseed(ctx context.Context) ([]string, error) {
	if err := s.ensureMigrationsTable(ctx); err != nil {
		return nil, err
	}
	if _, err := s.db.ExecContext(ctx, `DELETE FROM schema_migrations WHERE version LIKE 'seed:%'`); err != nil {
		return nil, fmt.Errorf("clearing seed records: %w", err)
	}
	return s.Seed(ctx)
}

func (s *Store) inTx(ctx context.Context, fn func(tx *sql.Tx) error) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("beginning transaction: %w", err)
	}
	if err := fn(tx); err != nil {
		_ = tx.Rollback()
		return err
	}
	return tx.Commit()
}
