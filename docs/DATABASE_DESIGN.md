# Go Backend Academy — Relational Database Design (`DATABASE_DESIGN.md`)

## 1. Dual-Engine Strategy: PostgreSQL Primary + SQLite Local Mode

* **Production Primary (`DB_DRIVER=postgres`)**: Targets [PostgreSQL 17/18](https://www.postgresql.org/docs/current/) using `TIMESTAMPTZ`, `JSONB`, strict `FOREIGN KEY` constraints, and `ON CONFLICT` upserts.
* **Zero-Setup Local Mode (`DB_DRIVER=sqlite`)**: Targets [SQLite 3.40+](https://www.sqlite.org/docs.html) with `PRAGMA journal_mode = WAL`, `PRAGMA busy_timeout = 5000`, and `PRAGMA foreign_keys = ON`.
* **Dialect Isolation**: PostgreSQL migrations live in `migrations/postgres/` and SQLite migrations live in `migrations/sqlite/`. No SQLite-only syntax (`INSERT OR IGNORE`) ever appears in PostgreSQL SQL files.

## 2. Normalized Relational Schema (20 Tables)

1. `schema_migrations (version PRIMARY KEY, applied_at)`: Tracks applied migration versions.
2. `users (id PRIMARY KEY, handle UNIQUE, display_name, created_at)`: Supports single-user local mode (`usr_local_default`) and multi-user persistence without fake authentication.
3. `curriculum_levels (id PRIMARY KEY, level_number UNIQUE, slug UNIQUE, title, subtitle, estimated_hours)`: Levels 0 through 10.
4. `modules (id PRIMARY KEY, level_id FK, order_index, slug UNIQUE, title, summary)`: Logical groupings inside each level.
5. `lessons (id PRIMARY KEY, module_id FK, level_id FK, order_index, slug UNIQUE, title, summary, difficulty, last_verified)`: Individual lessons.
6. `lesson_sections (id PRIMARY KEY, lesson_id FK, section_type, title, body_markdown, diagram_text, code_incorrect, code_corrected, reasoning)`: Stores the structured lesson hierarchy (`introduction`, `explanation`, `internals`, `code_examples`, `real_world_case`, `comparison`, `twelve_pillars`).
7. `lesson_references (id PRIMARY KEY, lesson_id FK, title, url, doc_version, ref_type, last_verified)`: Official documentation citations.
8. `exercises (id PRIMARY KEY, lesson_id FK, title, task_description, starter_code, solution_code, solution_explanation, additional_challenge)`: Coding exercises.
9. `exercise_test_cases (id PRIMARY KEY, exercise_id FK, order_index, description, required_pattern, forbidden_pattern)`: Deterministic test assertions.
10. `exercise_attempts (id PRIMARY KEY, user_id FK, exercise_id FK, submitted_code, passed, diagnostics_output, execution_ms, created_at)`: Audit history of user code submissions.
11. `quizzes (id PRIMARY KEY, lesson_id FK, title)`: Lesson and level assessments.
12. `quiz_questions (id PRIMARY KEY, quiz_id FK, order_index, question_text, options_json, correct_index, explanation)`: Diagnostic multiple-choice questions.
13. `quiz_attempts (id PRIMARY KEY, user_id FK, quiz_id FK, score, total_questions, created_at)`: Recorded quiz results used by the Recommendation Engine.
14. `user_progress (user_id FK, lesson_id FK, status, completed_at, updated_at, PRIMARY KEY (user_id, lesson_id))`: Lesson completion state.
15. `user_bookmarks (user_id FK, item_type, item_id, note, created_at, PRIMARY KEY (user_id, item_type, item_id))`: Saved bookmarks.
16. `user_notes (id PRIMARY KEY, user_id FK, lesson_id FK, content, updated_at)`: Personal engineering notes.
17. `case_studies (id PRIMARY KEY, study_number UNIQUE, slug UNIQUE, title, difficulty, architecture_style, recommended_db, summary)`: 14 real-world production projects.
18. `case_study_steps (id PRIMARY KEY, case_study_id FK, step_number, section_key, title, content_text, code_snippet)`: Stores the 15 required engineering sections per case study.
19. `database_scenarios (id PRIMARY KEY, scenario_number UNIQUE, slug UNIQUE, title, recommended_stack, rationale, engines_comparison_json)`: 10 cross-database scenarios.
20. `diagnostic_rules (rule_id PRIMARY KEY, category, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url)` & `diagnostic_results`: Offline Code Review & Diagnostics Lab catalog and run logs.

## 3. Backup, Point-in-Time Recovery (PITR) & Rollback Strategy

* **PostgreSQL Production Backups**: Combine daily base backups (`pg_basebackup` or `pgBackRest`) with continuous WAL archiving (`archive_command`) to object storage for Point-in-Time Recovery (PITR). Verify backups weekly via automated restore into an ephemeral staging container.
* **SQLite Local Backups**: Use `sqlite3 academy.db "VACUUM INTO 'academy_backup.db';"` or continuous WAL shipping via Litestream—never copy an active `.db` file with `cp` while a write transaction may be modifying the `.db-wal` file.
* **Migration Rollbacks**: Every `.up.sql` file in `migrations/postgres/` and `migrations/sqlite/` is paired with an explicit `.down.sql` rollback script tested in CI.
