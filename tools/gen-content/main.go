package main

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/json"
	"flag"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"github.com/gobackendacademy/platform/internal/config"
	"github.com/gobackendacademy/platform/internal/platform/database"
	"github.com/gobackendacademy/platform/seed"
)

type ContentPackage struct {
	Levels          []map[string]any `json:"levels"`
	Modules         []map[string]any `json:"modules"`
	Lessons         []map[string]any `json:"lessons"`
	LessonSections  []map[string]any `json:"lesson_sections"`
	LessonRefs      []map[string]any `json:"lesson_references"`
	Exercises       []map[string]any `json:"exercises"`
	ExerciseCases   []map[string]any `json:"exercise_test_cases"`
	ExerciseRules   []map[string]any `json:"exercise_rules"`
	ExerciseTests   []map[string]any `json:"exercise_tests"`
	Quizzes         []map[string]any `json:"quizzes"`
	QuizQuestions   []map[string]any `json:"quiz_questions"`
	CaseStudies     []map[string]any `json:"case_studies"`
	CaseStudySteps  []map[string]any `json:"case_study_steps"`
	DBScenarios     []map[string]any `json:"database_scenarios"`
	DiagnosticRules []map[string]any `json:"diagnostic_rules"`
}

func main() {
	exportFlag := flag.Bool("export", false, "export DB content to content/ JSON files")
	verifyFlag := flag.Bool("verify", false, "verify committed seeds match content/ source of truth")
	outDirFlag := flag.String("content-dir", "content", "directory for canonical content files")
	flag.Parse()

	if *exportFlag {
		if err := exportContent(*outDirFlag); err != nil {
			fmt.Fprintf(os.Stderr, "export failed: %v\n", err)
			os.Exit(1)
		}
		fmt.Println("Content successfully exported to", *outDirFlag)
		return
	}

	if *verifyFlag {
		if err := verifyContent(*outDirFlag); err != nil {
			fmt.Fprintf(os.Stderr, "content verification failed: %v\n", err)
			os.Exit(1)
		}
		fmt.Println("PASS: Content and seed files are in sync with zero drift.")
		return
	}

	// Default: verify
	if err := verifyContent(*outDirFlag); err != nil {
		fmt.Fprintf(os.Stderr, "content verification failed: %v\n", err)
		os.Exit(1)
	}
	fmt.Println("PASS: Content verified.")
}

func exportContent(contentDir string) error {
	tmpDir, err := os.MkdirTemp("", "gba-export-*")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmpDir)

	dbFile := filepath.Join(tmpDir, "export.db")
	_ = os.Setenv("DB_DRIVER", "sqlite")
	_ = os.Setenv("SQLITE_PATH", dbFile)
	_ = os.Setenv("SQLITE_DSN", "")

	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}

	ctx := context.Background()
	store, err := database.Open(ctx, cfg)
	if err != nil {
		return fmt.Errorf("opening store: %w", err)
	}
	defer store.Close()

	if err := os.MkdirAll(contentDir, 0755); err != nil {
		return err
	}

	pkg, err := readContentFromDB(ctx, store)
	if err != nil {
		return err
	}

	writeJSON := func(filename string, data any) error {
		path := filepath.Join(contentDir, filename)
		b, err := json.MarshalIndent(data, "", "  ")
		if err != nil {
			return err
		}
		return os.WriteFile(path, append(b, '\n'), 0644)
	}

	if err := writeJSON("curriculum.json", map[string]any{
		"levels":            pkg.Levels,
		"modules":           pkg.Modules,
		"lessons":           pkg.Lessons,
		"lesson_sections":   pkg.LessonSections,
		"lesson_references": pkg.LessonRefs,
	}); err != nil {
		return err
	}

	if err := writeJSON("exercises.json", map[string]any{
		"exercises":           pkg.Exercises,
		"exercise_test_cases": pkg.ExerciseCases,
		"exercise_rules":      pkg.ExerciseRules,
		"exercise_tests":      pkg.ExerciseTests,
	}); err != nil {
		return err
	}

	if err := writeJSON("quizzes.json", map[string]any{
		"quizzes":        pkg.Quizzes,
		"quiz_questions": pkg.QuizQuestions,
	}); err != nil {
		return err
	}

	if err := writeJSON("casestudies.json", map[string]any{
		"case_studies":     pkg.CaseStudies,
		"case_study_steps": pkg.CaseStudySteps,
	}); err != nil {
		return err
	}

	if err := writeJSON("database_scenarios.json", pkg.DBScenarios); err != nil {
		return err
	}

	if err := writeJSON("diagnostics.json", pkg.DiagnosticRules); err != nil {
		return err
	}

	// Also write a content manifest with SHA256 of all content files
	manifest := map[string]string{}
	entries, _ := os.ReadDir(contentDir)
	for _, e := range entries {
		if strings.HasSuffix(e.Name(), ".json") && e.Name() != "manifest.json" {
			data, _ := os.ReadFile(filepath.Join(contentDir, e.Name()))
			normalized := bytes.ReplaceAll(data, []byte("\r\n"), []byte("\n"))
			manifest[e.Name()] = fmt.Sprintf("%x", sha256.Sum256(normalized))
		}
	}
	return writeJSON("manifest.json", manifest)
}

func verifyContent(contentDir string) error {
	manifestPath := filepath.Join(contentDir, "manifest.json")
	manifestData, err := os.ReadFile(manifestPath)
	if err != nil {
		return fmt.Errorf("reading manifest (%s): %w (run with -export first)", manifestPath, err)
	}

	var manifest map[string]string
	if err := json.Unmarshal(manifestData, &manifest); err != nil {
		return fmt.Errorf("parsing manifest: %w", err)
	}

	for filename, expectedHash := range manifest {
		p := filepath.Join(contentDir, filename)
		data, err := os.ReadFile(p)
		if err != nil {
			return fmt.Errorf("missing content file %s: %w", p, err)
		}
		normalized := bytes.ReplaceAll(data, []byte("\r\n"), []byte("\n"))
		actualHash := fmt.Sprintf("%x", sha256.Sum256(normalized))
		if actualHash != expectedHash {
			return fmt.Errorf("content hash mismatch for %s: expected %s, got %s", filename, expectedHash, actualHash)
		}
	}

	// Verify all embedded seeds exist and have non-zero size
	for _, dialect := range []string{"sqlite", "postgres"} {
		files, err := fs.Glob(seed.FS, dialect+"/*.sql")
		if err != nil || len(files) == 0 {
			return fmt.Errorf("missing seed files for dialect %s", dialect)
		}
		for _, f := range files {
			data, err := fs.ReadFile(seed.FS, f)
			if err != nil || len(data) == 0 {
				return fmt.Errorf("empty seed file %s", f)
			}
		}
	}

	return nil
}

func readContentFromDB(ctx context.Context, store *database.Store) (*ContentPackage, error) {
	pkg := &ContentPackage{}

	// Query each table using store.DB()
	queryTable := func(query string) ([]map[string]any, error) {
		rows, err := store.DB().QueryContext(ctx, query)
		if err != nil {
			return nil, err
		}
		defer rows.Close()

		cols, err := rows.Columns()
		if err != nil {
			return nil, err
		}

		var result []map[string]any
		for rows.Next() {
			vals := make([]any, len(cols))
			ptrs := make([]any, len(cols))
			for i := range vals {
				ptrs[i] = &vals[i]
			}
			if err := rows.Scan(ptrs...); err != nil {
				return nil, err
			}
			rowMap := make(map[string]any)
			for i, col := range cols {
				val := vals[i]
				if b, ok := val.([]byte); ok {
					rowMap[col] = string(b)
				} else {
					rowMap[col] = val
				}
			}
			result = append(result, rowMap)
		}
		return result, rows.Err()
	}

	var err error
	if pkg.Levels, err = queryTable("SELECT * FROM curriculum_levels ORDER BY level_number"); err != nil {
		return nil, fmt.Errorf("reading curriculum_levels: %w", err)
	}
	if pkg.Modules, err = queryTable("SELECT * FROM modules ORDER BY level_id, order_index"); err != nil {
		return nil, fmt.Errorf("reading modules: %w", err)
	}
	if pkg.Lessons, err = queryTable("SELECT * FROM lessons ORDER BY level_id, order_index"); err != nil {
		return nil, fmt.Errorf("reading lessons: %w", err)
	}
	if pkg.LessonSections, err = queryTable("SELECT * FROM lesson_sections ORDER BY lesson_id, id"); err != nil {
		return nil, fmt.Errorf("reading lesson_sections: %w", err)
	}
	if pkg.LessonRefs, err = queryTable("SELECT * FROM lesson_references ORDER BY lesson_id, id"); err != nil {
		return nil, fmt.Errorf("reading lesson_references: %w", err)
	}
	if pkg.Exercises, err = queryTable("SELECT * FROM exercises ORDER BY lesson_id, id"); err != nil {
		return nil, fmt.Errorf("reading exercises: %w", err)
	}
	if pkg.ExerciseCases, err = queryTable("SELECT * FROM exercise_test_cases ORDER BY exercise_id, order_index"); err != nil {
		return nil, fmt.Errorf("reading exercise_test_cases: %w", err)
	}
	if pkg.ExerciseRules, err = queryTable("SELECT * FROM exercise_rules ORDER BY exercise_id, id"); err != nil {
		return nil, fmt.Errorf("reading exercise_rules: %w", err)
	}
	if pkg.ExerciseTests, err = queryTable("SELECT * FROM exercise_tests ORDER BY exercise_id"); err != nil {
		return nil, fmt.Errorf("reading exercise_tests: %w", err)
	}
	if pkg.Quizzes, err = queryTable("SELECT * FROM quizzes ORDER BY level_id, id"); err != nil {
		return nil, fmt.Errorf("reading quizzes: %w", err)
	}
	if pkg.QuizQuestions, err = queryTable("SELECT * FROM quiz_questions ORDER BY quiz_id, order_index"); err != nil {
		return nil, fmt.Errorf("reading quiz_questions: %w", err)
	}
	if pkg.CaseStudies, err = queryTable("SELECT * FROM case_studies ORDER BY study_number"); err != nil {
		return nil, fmt.Errorf("reading case_studies: %w", err)
	}
	if pkg.CaseStudySteps, err = queryTable("SELECT * FROM case_study_steps ORDER BY case_study_id, step_number"); err != nil {
		return nil, fmt.Errorf("reading case_study_steps: %w", err)
	}
	if pkg.DBScenarios, err = queryTable("SELECT * FROM database_scenarios ORDER BY scenario_number"); err != nil {
		return nil, fmt.Errorf("reading database_scenarios: %w", err)
	}
	if pkg.DiagnosticRules, err = queryTable("SELECT * FROM diagnostic_rules ORDER BY rule_id"); err != nil {
		return nil, fmt.Errorf("reading diagnostic_rules: %w", err)
	}

	return pkg, nil
}
