package database

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/gobackendacademy/platform/internal/shared"
)

// Content repository: read-only queries over the seeded curriculum tables.
// last_verified is CAST to TEXT so both engines return a plain 'YYYY-MM-DD' string.

func (s *Store) ListLevels(ctx context.Context) ([]shared.LevelSummary, error) {
	const q = `SELECT id, level_number, slug, title, subtitle, estimated_hours FROM curriculum_levels ORDER BY level_number`
	rows, err := s.db.QueryContext(ctx, q)
	if err != nil {
		return nil, fmt.Errorf("querying curriculum_levels: %w", err)
	}
	defer rows.Close()
	out := []shared.LevelSummary{}
	for rows.Next() {
		var l shared.LevelSummary
		if err := rows.Scan(&l.ID, &l.LevelNumber, &l.Slug, &l.Title, &l.Subtitle, &l.EstimatedHours); err != nil {
			return nil, fmt.Errorf("scanning curriculum_levels: %w", err)
		}
		out = append(out, l)
	}
	return out, rows.Err()
}

func (s *Store) ListModules(ctx context.Context) ([]shared.ModuleSummary, error) {
	const q = `
		SELECT m.id, m.level_id, m.order_index, m.slug, m.title, m.summary
		FROM modules m JOIN curriculum_levels l ON l.id = m.level_id
		ORDER BY l.level_number, m.order_index, m.id`
	rows, err := s.db.QueryContext(ctx, q)
	if err != nil {
		return nil, fmt.Errorf("querying modules: %w", err)
	}
	defer rows.Close()
	out := []shared.ModuleSummary{}
	for rows.Next() {
		var m shared.ModuleSummary
		if err := rows.Scan(&m.ID, &m.LevelID, &m.OrderIndex, &m.Slug, &m.Title, &m.Summary); err != nil {
			return nil, fmt.Errorf("scanning modules: %w", err)
		}
		out = append(out, m)
	}
	return out, rows.Err()
}

const lessonSummaryCols = `id, module_id, level_id, order_index, slug, title, summary, difficulty, CAST(last_verified AS TEXT)`

func scanLessonSummary(sc interface{ Scan(...any) error }, l *shared.LessonSummary) error {
	return sc.Scan(&l.ID, &l.ModuleID, &l.LevelID, &l.OrderIndex, &l.Slug, &l.Title, &l.Summary, &l.Difficulty, &l.LastVerified)
}

func (s *Store) ListLessons(ctx context.Context) ([]shared.LessonSummary, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT `+lessonSummaryCols+` FROM lessons ORDER BY order_index, id`)
	if err != nil {
		return nil, fmt.Errorf("querying lessons: %w", err)
	}
	defer rows.Close()
	out := []shared.LessonSummary{}
	for rows.Next() {
		var l shared.LessonSummary
		if err := scanLessonSummary(rows, &l); err != nil {
			return nil, fmt.Errorf("scanning lessons: %w", err)
		}
		out = append(out, l)
	}
	return out, rows.Err()
}

func (s *Store) LessonExists(ctx context.Context, id string) (bool, error) {
	return s.exists(ctx, `SELECT 1 FROM lessons WHERE id = $1`, id)
}


func (s *Store) ExerciseRequiredPatterns(ctx context.Context, exerciseID string) ([]string, error) {
	rows, err := s.db.QueryContext(ctx, `
		SELECT required_pattern FROM exercise_test_cases
		WHERE exercise_id = $1 AND required_pattern != ''
		ORDER BY order_index`, exerciseID)
	if err != nil {
		return nil, fmt.Errorf("querying exercise required patterns: %w", err)
	}
	defer rows.Close()
	var out []string
	for rows.Next() {
		var p string
		if err := rows.Scan(&p); err != nil {
			return nil, err
		}
		for _, part := range strings.Split(p, "|") {
			part = strings.TrimSpace(part)
			if part != "" {
				out = append(out, part)
			}
		}
	}
	return out, rows.Err()
}

type ExerciseRuleRecord struct {
	ID          string   `json:"id"`
	ExerciseID  string   `json:"exercise_id"`
	TargetFunc  string   `json:"target_func"`
	MustCall    []string `json:"must_call"`
	NoCall      []string `json:"no_call"`
	MustImport  []string `json:"must_import"`
	MustContain []string `json:"must_contain"`
}

func (s *Store) GetExerciseRule(ctx context.Context, exerciseID string) (*ExerciseRuleRecord, error) {
	var r ExerciseRuleRecord
	var mustCallJSON, noCallJSON, mustImportJSON, mustContainJSON string
	err := s.db.QueryRowContext(ctx, `
		SELECT id, exercise_id, target_func, must_call, no_call, must_import, must_contain
		FROM exercise_rules WHERE exercise_id = $1`, exerciseID).Scan(
		&r.ID, &r.ExerciseID, &r.TargetFunc, &mustCallJSON, &noCallJSON, &mustImportJSON, &mustContainJSON,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("querying exercise_rules for %s: %w", exerciseID, err)
	}
	_ = json.Unmarshal([]byte(mustCallJSON), &r.MustCall)
	_ = json.Unmarshal([]byte(noCallJSON), &r.NoCall)
	_ = json.Unmarshal([]byte(mustImportJSON), &r.MustImport)
	_ = json.Unmarshal([]byte(mustContainJSON), &r.MustContain)
	return &r, nil
}

type ExerciseTestRecord struct {
	ID         string `json:"id"`
	ExerciseID string `json:"exercise_id"`
	Filename   string `json:"filename"`
	TestCode   string `json:"test_code"`
}

func (s *Store) GetExerciseTest(ctx context.Context, exerciseID string) (*ExerciseTestRecord, error) {
	var r ExerciseTestRecord
	err := s.db.QueryRowContext(ctx, `
		SELECT id, exercise_id, filename, test_code
		FROM exercise_tests WHERE exercise_id = $1 LIMIT 1`, exerciseID).Scan(
		&r.ID, &r.ExerciseID, &r.Filename, &r.TestCode,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("querying exercise_tests for %s: %w", exerciseID, err)
	}
	return &r, nil
}

func (s *Store) GetExercise(ctx context.Context, id string) (*shared.ExerciseDetail, error) {
	var ex shared.ExerciseDetail
	err := s.db.QueryRowContext(ctx, `
		SELECT id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge
		FROM exercises WHERE id = $1 OR lesson_id = $1`, id).
		Scan(&ex.ID, &ex.LessonID, &ex.Title, &ex.TaskDescription, &ex.StarterCode, &ex.ExpectedOutput, &ex.SolutionCode, &ex.SolutionExplanation, &ex.AdditionalChallenge)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("querying exercise %s: %w", id, err)
	}
	return &ex, nil
}

func (s *Store) ExerciseExists(ctx context.Context, id string) (bool, error) {
	return s.exists(ctx, `SELECT 1 FROM exercises WHERE id = $1`, id)
}

func (s *Store) exists(ctx context.Context, q string, arg any) (bool, error) {
	var one int
	err := s.db.QueryRowContext(ctx, q, arg).Scan(&one)
	if errors.Is(err, sql.ErrNoRows) {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	return true, nil
}

// GetLessonDetail returns one lesson with its sections, references, and exercise (including test cases).
func (s *Store) GetLessonDetail(ctx context.Context, id string) (shared.LessonDetail, error) {
	var d shared.LessonDetail
	row := s.db.QueryRowContext(ctx, `SELECT `+lessonSummaryCols+` FROM lessons WHERE id = $1 OR slug = $1`, id)
	if err := scanLessonSummary(row, &d.LessonSummary); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return d, ErrNotFound
		}
		return d, fmt.Errorf("querying lesson %s: %w", id, err)
	}

	d.Sections = []shared.LessonSection{}
	rows, err := s.db.QueryContext(ctx, `
		SELECT id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning
		FROM lesson_sections WHERE lesson_id = $1 ORDER BY id`, d.ID)
	if err != nil {
		return d, fmt.Errorf("querying lesson_sections: %w", err)
	}
	for rows.Next() {
		var sec shared.LessonSection
		if err := rows.Scan(&sec.ID, &sec.SectionType, &sec.Title, &sec.Body, &sec.Diagram, &sec.CodeIncorrect, &sec.CodeCorrected, &sec.Reasoning); err != nil {
			rows.Close()
			return d, fmt.Errorf("scanning lesson_sections: %w", err)
		}
		d.Sections = append(d.Sections, sec)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return d, err
	}

	d.References = []shared.LessonReference{}
	rows, err = s.db.QueryContext(ctx, `
		SELECT id, title, url, doc_version, ref_type, last_verified
		FROM lesson_references WHERE lesson_id = $1 ORDER BY id`, d.ID)
	if err != nil {
		return d, fmt.Errorf("querying lesson_references: %w", err)
	}
	for rows.Next() {
		var r shared.LessonReference
		if err := rows.Scan(&r.ID, &r.Title, &r.URL, &r.DocVersion, &r.RefType, &r.LastVerified); err != nil {
			rows.Close()
			return d, fmt.Errorf("scanning lesson_references: %w", err)
		}
		d.References = append(d.References, r)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return d, err
	}

	var ex shared.ExerciseDetail
	err = s.db.QueryRowContext(ctx, `
		SELECT id, lesson_id, title, task_description, starter_code, expected_output, solution_code, solution_explanation, additional_challenge
		FROM exercises WHERE lesson_id = $1`, d.ID).
		Scan(&ex.ID, &ex.LessonID, &ex.Title, &ex.TaskDescription, &ex.StarterCode, &ex.ExpectedOutput, &ex.SolutionCode, &ex.SolutionExplanation, &ex.AdditionalChallenge)
	switch {
	case errors.Is(err, sql.ErrNoRows):
		return d, nil
	case err != nil:
		return d, fmt.Errorf("querying exercise for lesson %s: %w", d.ID, err)
	}
	ex.TestCases = []shared.ExerciseTestCase{}
	rows, err = s.db.QueryContext(ctx, `
		SELECT id, order_index, description, required_pattern
		FROM exercise_test_cases WHERE exercise_id = $1 ORDER BY order_index`, ex.ID)
	if err != nil {
		return d, fmt.Errorf("querying exercise_test_cases: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var tc shared.ExerciseTestCase
		if err := rows.Scan(&tc.ID, &tc.OrderIndex, &tc.Description, &tc.RequiredPattern); err != nil {
			return d, fmt.Errorf("scanning exercise_test_cases: %w", err)
		}
		ex.TestCases = append(ex.TestCases, tc)
	}
	if err := rows.Err(); err != nil {
		return d, err
	}
	d.Exercise = &ex
	return d, nil
}

func (s *Store) ListQuizzes(ctx context.Context) ([]shared.QuizSummary, error) {
	const q = `
		SELECT z.id, l.level_number, z.title, COUNT(qq.id)
		FROM quizzes z
		JOIN curriculum_levels l ON l.id = z.level_id
		LEFT JOIN quiz_questions qq ON qq.quiz_id = z.id
		GROUP BY z.id, l.level_number, z.title
		ORDER BY l.level_number, z.id`
	rows, err := s.db.QueryContext(ctx, q)
	if err != nil {
		return nil, fmt.Errorf("querying quizzes: %w", err)
	}
	defer rows.Close()
	out := []shared.QuizSummary{}
	for rows.Next() {
		var z shared.QuizSummary
		if err := rows.Scan(&z.ID, &z.Level, &z.Title, &z.QuestionCount); err != nil {
			return nil, fmt.Errorf("scanning quizzes: %w", err)
		}
		out = append(out, z)
	}
	return out, rows.Err()
}

// GetQuiz returns the learner-facing quiz (no answers).
func (s *Store) GetQuiz(ctx context.Context, id string) (shared.QuizDetail, error) {
	var d shared.QuizDetail
	err := s.db.QueryRowContext(ctx, `
		SELECT z.id, l.level_number, z.title
		FROM quizzes z JOIN curriculum_levels l ON l.id = z.level_id
		WHERE z.id = $1`, id).Scan(&d.ID, &d.Level, &d.Title)
	if errors.Is(err, sql.ErrNoRows) {
		return d, ErrNotFound
	}
	if err != nil {
		return d, fmt.Errorf("querying quiz %s: %w", id, err)
	}
	rows, err := s.db.QueryContext(ctx, `
		SELECT id, order_index, question_text, options_json
		FROM quiz_questions WHERE quiz_id = $1 ORDER BY order_index`, id)
	if err != nil {
		return d, fmt.Errorf("querying quiz_questions: %w", err)
	}
	defer rows.Close()
	d.Questions = []shared.QuizQuestion{}
	for rows.Next() {
		var qq shared.QuizQuestion
		var opts string
		if err := rows.Scan(&qq.ID, &qq.OrderIndex, &qq.Text, &opts); err != nil {
			return d, fmt.Errorf("scanning quiz_questions: %w", err)
		}
		qq.Options = rawJSON(opts)
		d.Questions = append(d.Questions, qq)
	}
	d.QuestionCount = len(d.Questions)
	return d, rows.Err()
}

// QuizAnswerKeys returns the grading key for a quiz in question order.
func (s *Store) QuizAnswerKeys(ctx context.Context, quizID string) ([]shared.QuizAnswerKey, error) {
	rows, err := s.db.QueryContext(ctx, `
		SELECT id, options_json, correct_index, explanation
		FROM quiz_questions WHERE quiz_id = $1 ORDER BY order_index`, quizID)
	if err != nil {
		return nil, fmt.Errorf("querying quiz answer keys: %w", err)
	}
	defer rows.Close()
	var out []shared.QuizAnswerKey
	for rows.Next() {
		var k shared.QuizAnswerKey
		var opts string
		if err := rows.Scan(&k.QuestionID, &opts, &k.CorrectIndex, &k.Explanation); err != nil {
			return nil, fmt.Errorf("scanning quiz answer keys: %w", err)
		}
		var list []json.RawMessage
		if json.Unmarshal([]byte(opts), &list) == nil {
			k.OptionCount = len(list)
		}
		out = append(out, k)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	if len(out) == 0 {
		return nil, ErrNotFound
	}
	return out, nil
}

func (s *Store) RecordQuizAttempt(ctx context.Context, rec shared.QuizAttemptRecord) error {
	if err := s.ensureUser(ctx, rec.UserID); err != nil {
		return err
	}
	const q = `
		INSERT INTO quiz_attempts (id, user_id, quiz_id, score, total_questions, created_at)
		VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)`
	if _, err := s.db.ExecContext(ctx, q, rec.ID, rec.UserID, rec.QuizID, rec.Score, rec.TotalQuestions); err != nil {
		return fmt.Errorf("inserting quiz_attempt: %w", err)
	}
	return nil
}

func (s *Store) ListQuizAttempts(ctx context.Context, userID, quizID string) ([]shared.QuizAttemptRecord, error) {
	const q = `
		SELECT id, user_id, quiz_id, score, total_questions, created_at
		FROM quiz_attempts
		WHERE user_id = $1 AND ($2 = '' OR quiz_id = $2)
		ORDER BY created_at DESC, id DESC
		LIMIT 100`
	rows, err := s.db.QueryContext(ctx, q, userID, quizID)
	if err != nil {
		return nil, fmt.Errorf("querying quiz_attempts: %w", err)
	}
	defer rows.Close()
	out := []shared.QuizAttemptRecord{}
	for rows.Next() {
		var a shared.QuizAttemptRecord
		if err := rows.Scan(&a.ID, &a.UserID, &a.QuizID, &a.Score, &a.TotalQuestions, &a.CreatedAt); err != nil {
			return nil, fmt.Errorf("scanning quiz_attempts: %w", err)
		}
		out = append(out, a)
	}
	return out, rows.Err()
}

func (s *Store) ListCaseStudies(ctx context.Context) ([]shared.CaseStudySummary, error) {
	rows, err := s.db.QueryContext(ctx, `
		SELECT id, study_number, slug, title, difficulty, architecture_style, recommended_db
		FROM case_studies ORDER BY study_number`)
	if err != nil {
		return nil, fmt.Errorf("querying case_studies: %w", err)
	}
	defer rows.Close()
	out := []shared.CaseStudySummary{}
	for rows.Next() {
		var c shared.CaseStudySummary
		if err := rows.Scan(&c.ID, &c.Number, &c.Slug, &c.Title, &c.Difficulty, &c.Architecture, &c.Database); err != nil {
			return nil, fmt.Errorf("scanning case_studies: %w", err)
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

func (s *Store) GetCaseStudy(ctx context.Context, id string) (shared.CaseStudyDetail, error) {
	var d shared.CaseStudyDetail
	err := s.db.QueryRowContext(ctx, `
		SELECT id, study_number, slug, title, difficulty, architecture_style, recommended_db, rationale
		FROM case_studies WHERE id = $1 OR slug = $1`, id).
		Scan(&d.ID, &d.Number, &d.Slug, &d.Title, &d.Difficulty, &d.Architecture, &d.Database, &d.Rationale)
	if errors.Is(err, sql.ErrNoRows) {
		return d, ErrNotFound
	}
	if err != nil {
		return d, fmt.Errorf("querying case study %s: %w", id, err)
	}
	rows, err := s.db.QueryContext(ctx, `
		SELECT step_number, section_key, title, content_text
		FROM case_study_steps WHERE case_study_id = $1 ORDER BY step_number`, d.ID)
	if err != nil {
		return d, fmt.Errorf("querying case_study_steps: %w", err)
	}
	defer rows.Close()
	d.Steps = []shared.CaseStudyStep{}
	for rows.Next() {
		var st shared.CaseStudyStep
		if err := rows.Scan(&st.StepNumber, &st.SectionKey, &st.Title, &st.Content); err != nil {
			return d, fmt.Errorf("scanning case_study_steps: %w", err)
		}
		d.Steps = append(d.Steps, st)
	}
	return d, rows.Err()
}

func (s *Store) ListDBScenarios(ctx context.Context) ([]shared.DBScenario, error) {
	rows, err := s.db.QueryContext(ctx, `
		SELECT id, scenario_number, title, recommended_stack, rationale, engines_comparison_json
		FROM database_scenarios ORDER BY scenario_number`)
	if err != nil {
		return nil, fmt.Errorf("querying database_scenarios: %w", err)
	}
	defer rows.Close()
	out := []shared.DBScenario{}
	for rows.Next() {
		var sc shared.DBScenario
		var cmp string
		if err := rows.Scan(&sc.ID, &sc.Number, &sc.Title, &sc.RecommendedStack, &sc.Rationale, &cmp); err != nil {
			return nil, fmt.Errorf("scanning database_scenarios: %w", err)
		}
		sc.EnginesComparison = rawJSON(cmp)
		out = append(out, sc)
	}
	return out, rows.Err()
}

func (s *Store) ListDiagnosticRules(ctx context.Context) ([]shared.DiagnosticRule, error) {
	rows, err := s.db.QueryContext(ctx, `
		SELECT rule_id, category, classification, severity, title, description, why_it_matters, suggested_fix, related_lesson_id, doc_url
		FROM diagnostic_rules ORDER BY rule_id`)
	if err != nil {
		return nil, fmt.Errorf("querying diagnostic_rules: %w", err)
	}
	defer rows.Close()
	out := []shared.DiagnosticRule{}
	for rows.Next() {
		var r shared.DiagnosticRule
		if err := rows.Scan(&r.RuleID, &r.Category, &r.Classification, &r.Severity, &r.Title, &r.Description, &r.WhyItMatters, &r.SuggestedFix, &r.RelatedLessonID, &r.DocURL); err != nil {
			return nil, fmt.Errorf("scanning diagnostic_rules: %w", err)
		}
		out = append(out, r)
	}
	return out, rows.Err()
}

// rawJSON returns stored JSON text as-is when valid, otherwise encodes it as a JSON string
// so a malformed seed row can never break the whole response.
func rawJSON(text string) json.RawMessage {
	if json.Valid([]byte(text)) {
		return json.RawMessage(text)
	}
	b, _ := json.Marshal(text)
	return b
}
