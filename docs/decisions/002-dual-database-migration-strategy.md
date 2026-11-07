# ADR 002: Engine-Specific Versioned Migrations for PostgreSQL and SQLite

* **Status**: Accepted (2026-11-07)
* **Context**: Sharing a single SQL seed file containing `INSERT OR IGNORE` broke PostgreSQL initialization in Docker Compose because `INSERT OR IGNORE` is SQLite-specific syntax.
* **Decision**: Maintain separate, verified migration and seed directories (`migrations/postgres/` + `seed/postgres/` using PostgreSQL 17+ `ON CONFLICT DO NOTHING` and `TIMESTAMPTZ`, and `migrations/sqlite/` + `seed/sqlite/` using SQLite 3.40+ `INSERT OR IGNORE` and `PRAGMA foreign_keys = ON`).
