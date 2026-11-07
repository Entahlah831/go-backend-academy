package shared

import (
	"encoding/json"
	"time"
)

// QuizSummary keeps the original /api/v1/quizzes fields (id, level, title) and adds question_count.
type QuizSummary struct {
	ID            string `json:"id"`
	Level         int    `json:"level"`
	Title         string `json:"title"`
	QuestionCount int    `json:"question_count"`
}

// QuizQuestion is the learner-facing question. The correct answer and explanation
// are deliberately omitted; they are only revealed by the grading endpoint.
type QuizQuestion struct {
	ID         string          `json:"id"`
	OrderIndex int             `json:"order_index"`
	Text       string          `json:"question"`
	Options    json.RawMessage `json:"options"`
}

type QuizDetail struct {
	QuizSummary
	Questions []QuizQuestion `json:"questions"`
}

// QuizAnswerKey is used server-side for grading only.
type QuizAnswerKey struct {
	QuestionID   string
	CorrectIndex int
	OptionCount  int
	Explanation  string
}

type QuizQuestionResult struct {
	QuestionID   string `json:"question_id"`
	Selected     int    `json:"selected"`
	CorrectIndex int    `json:"correct_index"`
	Correct      bool   `json:"correct"`
	Explanation  string `json:"explanation"`
}

type QuizAttemptResult struct {
	AttemptID      string               `json:"attempt_id"`
	QuizID         string               `json:"quiz_id"`
	Score          int                  `json:"score"`
	TotalQuestions int                  `json:"total_questions"`
	Results        []QuizQuestionResult `json:"results"`
}

type QuizAttemptRecord struct {
	ID             string    `json:"id"`
	UserID         string    `json:"user_id"`
	QuizID         string    `json:"quiz_id"`
	Score          int       `json:"score"`
	TotalQuestions int       `json:"total_questions"`
	CreatedAt      time.Time `json:"created_at"`
}

// CaseStudySummary keeps the original /api/v1/case-studies fields and adds slug and difficulty.
type CaseStudySummary struct {
	ID           string `json:"id"`
	Number       int    `json:"number"`
	Slug         string `json:"slug"`
	Title        string `json:"title"`
	Difficulty   string `json:"difficulty"`
	Architecture string `json:"architecture"`
	Database     string `json:"database"`
}

type CaseStudyStep struct {
	StepNumber int    `json:"step_number"`
	SectionKey string `json:"section_key"`
	Title      string `json:"title"`
	Content    string `json:"content"`
}

type CaseStudyDetail struct {
	CaseStudySummary
	Rationale string          `json:"rationale"`
	Steps     []CaseStudyStep `json:"steps"`
}

type LessonSection struct {
	ID            string `json:"id"`
	SectionType   string `json:"section_type"`
	Title         string `json:"title"`
	Body          string `json:"body"`
	Diagram       string `json:"diagram"`
	CodeIncorrect string `json:"code_incorrect"`
	CodeCorrected string `json:"code_corrected"`
	Reasoning     string `json:"reasoning"`
}

type LessonReference struct {
	ID           string `json:"id"`
	Title        string `json:"title"`
	URL          string `json:"url"`
	DocVersion   string `json:"doc_version"`
	RefType      string `json:"ref_type"`
	LastVerified string `json:"last_verified"`
}

type ExerciseTestCase struct {
	ID              string `json:"id"`
	OrderIndex      int    `json:"order_index"`
	Description     string `json:"description"`
	RequiredPattern string `json:"required_pattern"`
}

type ExerciseDetail struct {
	ID                  string             `json:"id"`
	LessonID            string             `json:"lesson_id"`
	Title               string             `json:"title"`
	TaskDescription     string             `json:"task_description"`
	StarterCode         string             `json:"starter_code"`
	ExpectedOutput      string             `json:"expected_output"`
	SolutionCode        string             `json:"solution_code"`
	SolutionExplanation string             `json:"solution_explanation"`
	AdditionalChallenge string             `json:"additional_challenge"`
	TestCases           []ExerciseTestCase `json:"test_cases"`
}

type LessonDetail struct {
	LessonSummary
	Sections   []LessonSection   `json:"sections"`
	References []LessonReference `json:"references"`
	Exercise   *ExerciseDetail   `json:"exercise,omitempty"`
}

type DBScenario struct {
	ID               string          `json:"id"`
	Number           int             `json:"number"`
	Title            string          `json:"title"`
	RecommendedStack string          `json:"recommended_stack"`
	Rationale        string          `json:"rationale"`
	EnginesComparison json.RawMessage `json:"engines_comparison"`
}

type DiagnosticRule struct {
	RuleID          string `json:"rule_id"`
	Category        string `json:"category"`
	Classification  string `json:"classification"`
	Severity        string `json:"severity"`
	Title           string `json:"title"`
	Description     string `json:"description"`
	WhyItMatters    string `json:"why_it_matters"`
	SuggestedFix    string `json:"suggested_fix"`
	RelatedLessonID string `json:"related_lesson_id"`
	DocURL          string `json:"doc_url"`
}
