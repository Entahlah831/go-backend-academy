-- ============================================================================
-- Go Backend Academy — SQLite 3 Normalized Schema (001_initial_schema.up.sql)
-- Strict SQLite dialect with foreign keys, UNIQUE, and CHECK constraints.
-- ============================================================================

CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(64) PRIMARY KEY,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(64) PRIMARY KEY,
    handle VARCHAR(64) NOT NULL UNIQUE,
    display_name VARCHAR(120) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS curriculum_levels (
    id INTEGER PRIMARY KEY,
    level_number INTEGER NOT NULL UNIQUE CHECK (level_number >= 0),
    slug VARCHAR(64) NOT NULL UNIQUE,
    title VARCHAR(160) NOT NULL,
    subtitle VARCHAR(255) NOT NULL,
    estimated_hours INTEGER NOT NULL DEFAULT 8 CHECK (estimated_hours > 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS modules (
    id VARCHAR(64) PRIMARY KEY,
    level_id INTEGER NOT NULL REFERENCES curriculum_levels(id) ON DELETE CASCADE,
    order_index INTEGER NOT NULL,
    slug VARCHAR(80) NOT NULL UNIQUE,
    title VARCHAR(180) NOT NULL,
    summary TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_modules_level ON modules(level_id, order_index);

CREATE TABLE IF NOT EXISTS lessons (
    id VARCHAR(64) PRIMARY KEY,
    module_id VARCHAR(64) NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    level_id INTEGER NOT NULL REFERENCES curriculum_levels(id) ON DELETE CASCADE,
    order_index INTEGER NOT NULL,
    slug VARCHAR(80) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    summary TEXT NOT NULL,
    difficulty VARCHAR(32) NOT NULL DEFAULT 'intermediate',
    last_verified DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_lessons_level_order ON lessons(level_id, order_index);
CREATE INDEX IF NOT EXISTS idx_lessons_module ON lessons(module_id, order_index);

CREATE TABLE IF NOT EXISTS lesson_sections (
    id VARCHAR(80) PRIMARY KEY,
    lesson_id VARCHAR(64) NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    section_type VARCHAR(40) NOT NULL,
    title VARCHAR(200) NOT NULL,
    body_text TEXT NOT NULL,
    diagram_text TEXT NOT NULL DEFAULT '',
    code_incorrect TEXT NOT NULL DEFAULT '',
    code_corrected TEXT NOT NULL DEFAULT '',
    reasoning TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_lesson_sections_lesson ON lesson_sections(lesson_id, section_type);

CREATE TABLE IF NOT EXISTS lesson_references (
    id VARCHAR(80) PRIMARY KEY,
    lesson_id VARCHAR(64) NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    url TEXT NOT NULL,
    doc_version VARCHAR(40) NOT NULL,
    ref_type VARCHAR(40) NOT NULL DEFAULT 'official',
    last_verified VARCHAR(20) NOT NULL DEFAULT '2026-11-07'
);

CREATE INDEX IF NOT EXISTS idx_lesson_refs_lesson ON lesson_references(lesson_id);

CREATE TABLE IF NOT EXISTS exercises (
    id VARCHAR(80) PRIMARY KEY,
    lesson_id VARCHAR(64) NOT NULL UNIQUE REFERENCES lessons(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    task_description TEXT NOT NULL,
    starter_code TEXT NOT NULL,
    expected_output TEXT NOT NULL,
    solution_code TEXT NOT NULL,
    solution_explanation TEXT NOT NULL,
    additional_challenge TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS exercise_test_cases (
    id VARCHAR(80) PRIMARY KEY,
    exercise_id VARCHAR(80) NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    order_index INTEGER NOT NULL,
    description TEXT NOT NULL,
    required_pattern TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_exercise_tests_ex ON exercise_test_cases(exercise_id, order_index);

CREATE TABLE IF NOT EXISTS exercise_rules (
    id VARCHAR(80) PRIMARY KEY,
    exercise_id VARCHAR(80) NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    target_func VARCHAR(100) NOT NULL DEFAULT '',
    must_call TEXT NOT NULL DEFAULT '[]',
    no_call TEXT NOT NULL DEFAULT '[]',
    must_import TEXT NOT NULL DEFAULT '[]',
    must_contain TEXT NOT NULL DEFAULT '[]',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_exercise_rules_ex ON exercise_rules(exercise_id);

CREATE TABLE IF NOT EXISTS exercise_attempts (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    exercise_id VARCHAR(80) NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    submitted_code TEXT NOT NULL,
    passed BOOLEAN NOT NULL,
    diagnostics_output TEXT NOT NULL,
    execution_ms INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_exercise_attempts_user ON exercise_attempts(user_id, exercise_id, created_at DESC);

CREATE TABLE IF NOT EXISTS quizzes (
    id VARCHAR(64) PRIMARY KEY,
    level_id INTEGER NOT NULL REFERENCES curriculum_levels(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL
);

CREATE TABLE IF NOT EXISTS quiz_questions (
    id VARCHAR(64) PRIMARY KEY,
    quiz_id VARCHAR(64) NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    order_index INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    options_json TEXT NOT NULL,
    correct_index INTEGER NOT NULL CHECK (correct_index >= 0),
    explanation TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS quiz_attempts (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quiz_id VARCHAR(64) NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    score INTEGER NOT NULL CHECK (score >= 0),
    total_questions INTEGER NOT NULL CHECK (total_questions > 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_progress (
    user_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id VARCHAR(64) NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    status VARCHAR(32) NOT NULL DEFAULT 'completed' CHECK (status IN ('in_progress', 'completed')),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, lesson_id)
);

CREATE TABLE IF NOT EXISTS user_bookmarks (
    user_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_type VARCHAR(32) NOT NULL CHECK (item_type IN ('lesson', 'case_study', 'db_scenario')),
    item_id VARCHAR(64) NOT NULL,
    note TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, item_type, item_id)
);

CREATE TABLE IF NOT EXISTS user_notes (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id VARCHAR(64) NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, lesson_id)
);

CREATE TABLE IF NOT EXISTS case_studies (
    id VARCHAR(64) PRIMARY KEY,
    study_number INTEGER NOT NULL UNIQUE,
    slug VARCHAR(80) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    difficulty VARCHAR(64) NOT NULL,
    architecture_style VARCHAR(160) NOT NULL,
    recommended_db VARCHAR(160) NOT NULL,
    rationale TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS case_study_steps (
    id VARCHAR(80) PRIMARY KEY,
    case_study_id VARCHAR(64) NOT NULL REFERENCES case_studies(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    section_key VARCHAR(64) NOT NULL,
    title VARCHAR(160) NOT NULL,
    content_text TEXT NOT NULL,
    UNIQUE (case_study_id, section_key)
);

CREATE TABLE IF NOT EXISTS database_scenarios (
    id VARCHAR(64) PRIMARY KEY,
    scenario_number INTEGER NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    recommended_stack VARCHAR(200) NOT NULL,
    rationale TEXT NOT NULL,
    engines_comparison_json TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS diagnostic_rules (
    rule_id VARCHAR(32) PRIMARY KEY,
    category VARCHAR(40) NOT NULL,
    classification VARCHAR(40) NOT NULL CHECK (classification IN ('confirmed_diagnostic', 'potential_issue', 'educational_heuristic')),
    severity VARCHAR(24) NOT NULL CHECK (severity IN ('critical', 'high', 'medium', 'info')),
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    why_it_matters TEXT NOT NULL,
    suggested_fix TEXT NOT NULL,
    related_lesson_id VARCHAR(64) NOT NULL,
    doc_url TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS diagnostic_results (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    submitted_code TEXT NOT NULL,
    findings_json TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
