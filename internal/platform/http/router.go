package httpplatform

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"sync/atomic"
	"time"

	"github.com/google/uuid"

	"github.com/gobackendacademy/platform/internal/config"
	"github.com/gobackendacademy/platform/internal/modules/assessments"
	casestudies "github.com/gobackendacademy/platform/internal/modules/case_studies"
	"github.com/gobackendacademy/platform/internal/modules/curriculum"
	"github.com/gobackendacademy/platform/internal/modules/diagnostics"
	"github.com/gobackendacademy/platform/internal/modules/exercises"
	"github.com/gobackendacademy/platform/internal/modules/lessons"
	"github.com/gobackendacademy/platform/internal/modules/recommendations"
	sqlplayground "github.com/gobackendacademy/platform/internal/modules/sql_playground"
	"github.com/gobackendacademy/platform/internal/platform/database"
	"github.com/gobackendacademy/platform/internal/shared"
)

const sessionCookieName = "gba_sid"

type contextKey string

const userContextKey contextKey = "gba_user_id"

// userIDPattern matches the users.id VARCHAR(64) column and keeps IDs URL/log safe.
var userIDPattern = regexp.MustCompile(`^[A-Za-z0-9_.\-]{1,64}$`)

// legacyClaimExpiry defines the cutoff date for migrating legacy browser IDs.
var legacyClaimExpiry = time.Date(2027, 2, 15, 0, 0, 0, 0, time.UTC)

type Server struct {
	cfg            *config.Config
	logger         *slog.Logger
	store          *database.Store
	curriculumSvc  *curriculum.Service
	lessonsSvc     *lessons.Service
	exercisesSvc   *exercises.Service
	assessmentsSvc *assessments.Service
	caseStudiesSvc *casestudies.Service
	analyzer       *diagnostics.Analyzer
	sqlSandbox     *sqlplayground.Sandbox
	recEngine      *recommendations.Engine
	claimLimiter   *RateLimiter
	shuttingDown   atomic.Bool
	mux            *http.ServeMux
}

func NewServer(cfg *config.Config, logger *slog.Logger, store *database.Store) *Server {
	s := &Server{
		cfg:            cfg,
		logger:         logger,
		store:          store,
		curriculumSvc:  curriculum.NewService(store),
		lessonsSvc:     lessons.NewService(store),
		exercisesSvc:   exercises.NewService(store),
		assessmentsSvc: assessments.NewService(store, database.ErrNotFound),
		caseStudiesSvc: casestudies.NewService(store),
		analyzer:       diagnostics.NewAnalyzer(cfg.EnableLocalToolchain, cfg.SandboxTimeout, cfg.AIProvider, cfg.AIBaseURL, cfg.AIModel),
		sqlSandbox:     sqlplayground.NewSandbox(cfg.SandboxTimeout),
		recEngine:      recommendations.NewEngine(),
		claimLimiter:   NewRateLimiterWithTrusted(5.0/3600.0, 5, cfg.TrustedProxyCIDRs),
		mux:            http.NewServeMux(),
	}
	s.registerRoutes()
	return s
}

func (s *Server) Store() *database.Store {
	return s.store
}

func (s *Server) SetShuttingDown(val bool) {
	s.shuttingDown.Store(val)
}

func (s *Server) Analyzer() *diagnostics.Analyzer {
	return s.analyzer
}

func (s *Server) Handler() http.Handler {
	limiter := NewRateLimiterWithTrusted(s.cfg.RateLimitRPS, s.cfg.RateLimitBurst, s.cfg.TrustedProxyCIDRs)
	var h http.Handler = s.mux
	h = s.sessionMiddleware(h)
	h = limiter.Middleware(h)
	h = CORSMiddleware(s.cfg.CORSAllowedOrigins)(h)
	h = SecurityHeadersMiddleware(h)
	h = LoggingMiddleware(s.logger)(h)
	h = RecoveryMiddleware(s.logger)(h)
	h = RequestIDMiddleware(h)
	return h
}

func (s *Server) isRemoteAddrTrusted(r *http.Request) bool {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		host = r.RemoteAddr
	}
	ip := net.ParseIP(host)
	if ip == nil {
		return false
	}
	for _, n := range s.cfg.TrustedProxyCIDRs {
		if n.Contains(ip) {
			return true
		}
	}
	return false
}

func (s *Server) isSecureRequest(r *http.Request) bool {
	if r.TLS != nil {
		return true
	}
	if s.isRemoteAddrTrusted(r) && strings.EqualFold(r.Header.Get("X-Forwarded-Proto"), "https") {
		return true
	}
	return false
}

func (s *Server) issueUserSession(w http.ResponseWriter, r *http.Request) (string, error) {
	raw := make([]byte, 32)
	if _, err := rand.Read(raw); err != nil {
		return "", fmt.Errorf("generating session token: %w", err)
	}
	tokenStr := base64.RawURLEncoding.EncodeToString(raw)
	tokenHash := fmt.Sprintf("%x", sha256.Sum256([]byte(tokenStr)))

	sessionUID := "usr_" + strings.ReplaceAll(uuid.NewString(), "-", "")[:24]
	expiresAt := time.Now().Add(30 * 24 * time.Hour)
	if err := s.store.CreateSession(r.Context(), tokenHash, sessionUID, expiresAt); err != nil {
		return "", fmt.Errorf("persisting session: %w", err)
	}

	if w != nil {
		http.SetCookie(w, &http.Cookie{
			Name:     sessionCookieName,
			Value:    tokenStr,
			Path:     "/",
			HttpOnly: true,
			Secure:   s.isSecureRequest(r),
			SameSite: http.SameSiteLaxMode,
			MaxAge:   30 * 86400,
		})
	}
	return sessionUID, nil
}

func isPublicNoSessionRoute(path string) bool {
	if path == "/healthz" || path == "/readyz" {
		return true
	}
	if path == "/" || strings.HasPrefix(path, "/static/") || strings.HasSuffix(path, ".html") ||
		strings.HasSuffix(path, ".css") || strings.HasSuffix(path, ".js") || strings.HasSuffix(path, ".woff2") ||
		strings.HasSuffix(path, ".ico") || strings.HasSuffix(path, ".svg") || strings.HasSuffix(path, ".png") ||
		strings.HasSuffix(path, ".jpg") {
		return true
	}
	return false
}

func (s *Server) sessionMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		var sessionUID string

		cookie, err := r.Cookie(sessionCookieName)
		if err == nil && cookie.Value != "" {
			tokenHash := fmt.Sprintf("%x", sha256.Sum256([]byte(cookie.Value)))
			if uid, err := s.store.GetSessionUser(ctx, tokenHash); err == nil && uid != "" {
				sessionUID = uid
			}
		}

		if sessionUID == "" && !isPublicNoSessionRoute(r.URL.Path) {
			if uid, err := s.issueUserSession(w, r); err == nil && uid != "" {
				sessionUID = uid
			}
		}

		if sessionUID != "" {
			ctx = context.WithValue(ctx, userContextKey, sessionUID)
		}
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// resolveUser returns the authenticated user ID from context (injected by sessionMiddleware)
// or lazily issues a new secure session cookie if the request requires user state.
// User identity is NEVER derived from client query parameters or request body fields.
func (s *Server) resolveUser(w http.ResponseWriter, r *http.Request) (string, error) {
	if uid, ok := r.Context().Value(userContextKey).(string); ok && uid != "" {
		return uid, nil
	}
	return s.issueUserSession(w, r)
}

func (s *Server) StartBackgroundWorkers(ctx context.Context) {
	go func() {
		ticker := time.NewTicker(1 * time.Hour)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				if s.store != nil {
					n, err := s.store.PurgeExpiredSessions(context.Background())
					if err != nil {
						s.logger.Error("failed to purge expired sessions", slog.String("error", err.Error()))
					} else if n > 0 {
						s.logger.Info("purged expired sessions", slog.Int64("count", n))
					}
				}
			}
		}
	}()
}

func (s *Server) registerRoutes() {
	s.mux.HandleFunc("GET /healthz", s.handleHealthz)
	s.mux.HandleFunc("GET /readyz", s.handleReadyz)

	// Curriculum, Lessons, Exercises, Quizzes & Case Studies Endpoints
	s.mux.HandleFunc("GET /api/v1/curriculum", s.handleListCurriculum)
	s.mux.HandleFunc("GET /api/v1/modules", s.handleListModules)
	s.mux.HandleFunc("GET /api/v1/lessons", s.handleListLessons)
	s.mux.HandleFunc("GET /api/v1/lessons/{id}", s.handleGetLesson)
	s.mux.HandleFunc("POST /api/v1/exercises/verify", s.handleVerifyExercise)
	s.mux.HandleFunc("GET /api/v1/exercises/attempts", s.handleListExerciseAttempts)
	s.mux.HandleFunc("GET /api/v1/exercises/{id}/package", s.handleGetExercisePackage)
	s.mux.HandleFunc("GET /api/v1/exercises/{id}/tests", s.handleGetExercisePackage)
	s.mux.HandleFunc("GET /api/v1/quizzes", s.handleListQuizzes)
	s.mux.HandleFunc("GET /api/v1/quizzes/{id}", s.handleGetQuiz)
	s.mux.HandleFunc("POST /api/v1/quizzes/{id}/attempts", s.handleGradeQuiz)
	s.mux.HandleFunc("GET /api/v1/quiz-attempts", s.handleListQuizAttempts)
	s.mux.HandleFunc("GET /api/v1/case-studies", s.handleListCaseStudies)
	s.mux.HandleFunc("GET /api/v1/case-studies/{id}", s.handleGetCaseStudy)
	s.mux.HandleFunc("GET /api/v1/db-scenarios", s.handleListDBScenarios)
	s.mux.HandleFunc("POST /api/v1/sql-playground/execute", s.handleSQLPlaygroundExecute)

	// Offline Go Code Review & Diagnostics Lab Endpoints
	s.mux.HandleFunc("POST /api/v1/diagnostics/analyze", s.handleDiagnosticsAnalyze)
	s.mux.HandleFunc("GET /api/v1/diagnostics/rules", s.handleListDiagnosticRules)

	// Real-Data Recommendation Engine Endpoint
	s.mux.HandleFunc("POST /api/v1/recommendations", s.handleRecommendations)
	s.mux.HandleFunc("POST /api/v1/session/claim-legacy", s.handleClaimLegacySession)

	// Progress, Bookmarks & Notes Persistence Endpoints
	s.mux.HandleFunc("GET /api/v1/progress", s.handleGetProgress)
	s.mux.HandleFunc("POST /api/v1/progress", s.handleSaveProgress)
	s.mux.HandleFunc("GET /api/v1/bookmarks", s.handleGetBookmarks)
	s.mux.HandleFunc("POST /api/v1/bookmarks", s.handleSaveBookmark)
	s.mux.HandleFunc("GET /api/v1/notes", s.handleGetNotes)
	s.mux.HandleFunc("POST /api/v1/notes", s.handleSaveNote)

	// Serve Frontend Web App
	s.mux.HandleFunc("GET /", s.handleStaticFrontend)
}

// ---------- shared helpers ----------

var errTrailingData = errors.New("request body must contain exactly one JSON object")

// decodeJSON enforces a body size limit, rejects unknown fields, and rejects
// trailing data after the first JSON value (e.g. `{"a":1}{"b":2}`).
func (s *Server) decodeJSON(w http.ResponseWriter, r *http.Request, dst any) error {
	r.Body = http.MaxBytesReader(w, r.Body, s.cfg.MaxRequestBodyBytes)
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		return err
	}
	if err := dec.Decode(&struct{}{}); !errors.Is(err, io.EOF) {
		return errTrailingData
	}
	return nil
}

// writeDecodeError maps decoding failures to 413 (too large) or 400 (malformed).
func writeDecodeError(w http.ResponseWriter, r *http.Request, err error, hint string) {
	var tooLarge *http.MaxBytesError
	if errors.As(err, &tooLarge) {
		WriteProblem(w, r, http.StatusRequestEntityTooLarge, "PAYLOAD_TOO_LARGE", "Payload Too Large", "Request body exceeds the configured MAX_REQUEST_BODY_BYTES limit.")
		return
	}
	WriteProblem(w, r, http.StatusBadRequest, "INVALID_JSON", "Bad Request", hint+" ("+err.Error()+")")
}

func (s *Server) writeDBError(w http.ResponseWriter, r *http.Request, err error) {
	s.logger.Error("database operation failed", slog.String("path", r.URL.Path), slog.String("error", err.Error()))
	WriteProblem(w, r, http.StatusInternalServerError, "DB_ERROR", "Database Error", "The database operation failed. Check server logs for details.")
}

// ---------- health ----------

func (s *Server) handleHealthz(w http.ResponseWriter, r *http.Request) {
	WriteJSON(w, http.StatusOK, map[string]any{
		"status":    "alive",
		"service":   "go-backend-academy",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
	})
}

// handleReadyz performs a real database round-trip. It never reports ready
// when the configured database is unreachable.
func (s *Server) handleReadyz(w http.ResponseWriter, r *http.Request) {
	if s.shuttingDown.Load() {
		WriteProblem(w, r, http.StatusServiceUnavailable, "SHUTTING_DOWN", "Service Shutting Down", "Server is draining in-flight connections.")
		return
	}
	ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
	defer cancel()
	if err := s.store.Ping(ctx); err != nil {
		s.logger.Warn("readiness ping failed", slog.String("error", err.Error()))
		WriteProblem(w, r, http.StatusServiceUnavailable, "DB_NOT_READY", "Database Not Ready", "The configured database did not answer a ping.")
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{
		"status":        "ready",
		"db_driver":     s.store.DriverName(),
		"db_persistent": s.store.Persistent(),
		"ai_provider":   s.cfg.AIProvider,
	})
}

// ---------- curriculum & lessons ----------

func (s *Server) handleListCurriculum(w http.ResponseWriter, r *http.Request) {
	levels, err := s.curriculumSvc.ListLevels(r.Context())
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	modules, err := s.curriculumSvc.ListModules(r.Context())
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	lessonList, err := s.lessonsSvc.ListLessons(r.Context())
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"levels": levels, "modules": modules, "lessons": lessonList})
}

func (s *Server) handleListModules(w http.ResponseWriter, r *http.Request) {
	modules, err := s.curriculumSvc.ListModules(r.Context())
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"modules": modules})
}

func (s *Server) handleListLessons(w http.ResponseWriter, r *http.Request) {
	lessonList, err := s.lessonsSvc.ListLessons(r.Context())
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"lessons": lessonList})
}

func (s *Server) handleGetLesson(w http.ResponseWriter, r *http.Request) {
	lesson, err := s.lessonsSvc.GetLesson(r.Context(), r.PathValue("id"))
	if errors.Is(err, database.ErrNotFound) {
		WriteProblem(w, r, http.StatusNotFound, "UNKNOWN_LESSON", "Lesson Not Found", "No lesson matches this id or slug.")
		return
	}
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, lesson)
}

// ---------- exercises ----------

func (s *Server) handleVerifyExercise(w http.ResponseWriter, r *http.Request) {
	var payload struct {
		ExerciseID     string   `json:"exercise_id"`
		Code           string   `json:"code"`
		RequiredTokens []string `json:"required_tokens"`
	}
	if err := s.decodeJSON(w, r, &payload); err != nil {
		writeDecodeError(w, r, err, "Body must be a JSON object with exercise_id and code.")
		return
	}
	if payload.ExerciseID == "" {
		WriteProblem(w, r, http.StatusBadRequest, "INVALID_PAYLOAD", "Bad Request", "exercise_id and code are required.")
		return
	}
	uid, err := s.resolveUser(w, r)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	req := exercises.SubmissionRequest{
		UserID:         uid,
		ExerciseID:     payload.ExerciseID,
		Code:           payload.Code,
		RequiredTokens: payload.RequiredTokens,
	}
	res, err := s.exercisesSvc.VerifySubmission(r.Context(), req)
	if err != nil {
		if errors.Is(err, exercises.ErrUnknownExercise) {
			WriteProblem(w, r, http.StatusBadRequest, "UNKNOWN_EXERCISE", "Bad Request", err.Error())
			return
		}
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, res)
}

func (s *Server) handleListExerciseAttempts(w http.ResponseWriter, r *http.Request) {
	uid, err := s.resolveUser(w, r)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	list, err := s.exercisesSvc.ListAttempts(r.Context(), uid, r.URL.Query().Get("exercise_id"))
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"user_id": uid, "attempts": list})
}

func (s *Server) handleGetExercisePackage(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	pkg, err := s.exercisesSvc.FetchPackage(r.Context(), id)
	if err != nil {
		if errors.Is(err, exercises.ErrUnknownExercise) {
			WriteProblem(w, r, http.StatusNotFound, "NOT_FOUND", "Exercise Not Found", err.Error())
			return
		}
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, pkg)
}

// ---------- quizzes ----------

func (s *Server) handleListQuizzes(w http.ResponseWriter, r *http.Request) {
	list, err := s.assessmentsSvc.ListQuizzes(r.Context())
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"quizzes": list})
}

func (s *Server) handleGetQuiz(w http.ResponseWriter, r *http.Request) {
	quiz, err := s.assessmentsSvc.GetQuiz(r.Context(), r.PathValue("id"))
	if errors.Is(err, assessments.ErrUnknownQuiz) {
		WriteProblem(w, r, http.StatusNotFound, "UNKNOWN_QUIZ", "Quiz Not Found", err.Error())
		return
	}
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, quiz)
}

func (s *Server) handleGradeQuiz(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Answers []int `json:"answers"`
	}
	if err := s.decodeJSON(w, r, &req); err != nil {
		writeDecodeError(w, r, err, `Body must be {"answers": [<option index per question>]}.`)
		return
	}
	uid, err := s.resolveUser(w, r)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	res, err := s.assessmentsSvc.Grade(r.Context(), uid, r.PathValue("id"), req.Answers)
	switch {
	case errors.Is(err, assessments.ErrUnknownQuiz):
		WriteProblem(w, r, http.StatusNotFound, "UNKNOWN_QUIZ", "Quiz Not Found", err.Error())
	case errors.Is(err, assessments.ErrAnswerCount), errors.Is(err, assessments.ErrAnswerOutside):
		WriteProblem(w, r, http.StatusBadRequest, "INVALID_ANSWERS", "Bad Request", err.Error())
	case err != nil:
		s.writeDBError(w, r, err)
	default:
		WriteJSON(w, http.StatusOK, res)
	}
}

func (s *Server) handleListQuizAttempts(w http.ResponseWriter, r *http.Request) {
	uid, err := s.resolveUser(w, r)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	list, err := s.assessmentsSvc.ListAttempts(r.Context(), uid, r.URL.Query().Get("quiz_id"))
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"user_id": uid, "attempts": list})
}

// ---------- case studies, scenarios, diagnostics ----------

func (s *Server) handleListCaseStudies(w http.ResponseWriter, r *http.Request) {
	list, err := s.caseStudiesSvc.ListCaseStudies(r.Context())
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"case_studies": list})
}

func (s *Server) handleGetCaseStudy(w http.ResponseWriter, r *http.Request) {
	cs, err := s.caseStudiesSvc.GetCaseStudy(r.Context(), r.PathValue("id"))
	if errors.Is(err, database.ErrNotFound) {
		WriteProblem(w, r, http.StatusNotFound, "UNKNOWN_CASE_STUDY", "Case Study Not Found", "No case study matches this id or slug.")
		return
	}
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, cs)
}

func (s *Server) handleListDBScenarios(w http.ResponseWriter, r *http.Request) {
	list, err := s.store.ListDBScenarios(r.Context())
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"db_scenarios": list})
}

func (s *Server) handleSQLPlaygroundExecute(w http.ResponseWriter, r *http.Request) {
	var req sqlplayground.QueryRequest
	if err := s.decodeJSON(w, r, &req); err != nil {
		writeDecodeError(w, r, err, "Body must be {\"query\": \"SELECT ...\", \"explain\": optional bool}.")
		return
	}
	res, err := s.sqlSandbox.Execute(r.Context(), req)
	switch {
	case errors.Is(err, sqlplayground.ErrEmptyQuery), errors.Is(err, sqlplayground.ErrForbiddenQuery):
		WriteProblem(w, r, http.StatusBadRequest, "INVALID_SQL_QUERY", "Bad Request", err.Error())
	case err != nil:
		WriteProblem(w, r, http.StatusBadRequest, "SQL_EXECUTION_ERROR", "SQL Execution Error", err.Error())
	default:
		WriteJSON(w, http.StatusOK, res)
	}
}

// ---------- static frontend ----------

func (s *Server) handleClaimLegacySession(w http.ResponseWriter, r *http.Request) {
	if time.Now().UTC().After(legacyClaimExpiry) {
		WriteProblem(w, r, http.StatusGone, "FEATURE_EXPIRED", "Feature Expired", "Legacy session migration window has expired.")
		return
	}
	clientIP := ClientIP(r, s.cfg.TrustedProxyCIDRs)
	if !s.claimLimiter.Allow(clientIP) {
		WriteProblem(w, r, http.StatusTooManyRequests, "RATE_LIMIT_EXCEEDED", "Too Many Requests", "Too many claim attempts from this IP address. Please try again later.")
		return
	}
	var payload struct {
		LegacyUserID string `json:"legacy_user_id"`
	}
	if err := s.decodeJSON(w, r, &payload); err != nil {
		writeDecodeError(w, r, err, "Body must contain legacy_user_id.")
		return
	}
	if payload.LegacyUserID == "usr_local_default" {
		WriteProblem(w, r, http.StatusBadRequest, "INVALID_LEGACY_USER_ID", "Invalid Legacy User ID", "Default local guest user cannot be claimed.")
		return
	}
	if !userIDPattern.MatchString(payload.LegacyUserID) {
		WriteProblem(w, r, http.StatusBadRequest, "INVALID_LEGACY_USER_ID", "Invalid Legacy User ID", "The provided legacy_user_id format is invalid.")
		return
	}
	currentUID, err := s.resolveUser(w, r)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	if currentUID == payload.LegacyUserID {
		WriteJSON(w, http.StatusOK, map[string]any{"claimed": true, "user_id": currentUID})
		return
	}
	if err := s.store.ClaimLegacyUser(r.Context(), payload.LegacyUserID, currentUID); err != nil {
		if errors.Is(err, database.ErrNotFound) {
			WriteProblem(w, r, http.StatusNotFound, "LEGACY_USER_NOT_FOUND", "Legacy User Not Found", "No data exists for the provided legacy_user_id, or it has already been claimed.")
			return
		}
		if strings.Contains(err.Error(), "cannot claim default") {
			WriteProblem(w, r, http.StatusBadRequest, "INVALID_LEGACY_USER_ID", "Invalid Legacy User ID", "Default local guest user cannot be claimed.")
			return
		}
		if strings.Contains(err.Error(), "already contains learning progress") {
			WriteProblem(w, r, http.StatusConflict, "CLAIM_CONFLICT", "Claim Conflict", "Current session already has learning progress; cannot claim legacy data.")
			return
		}
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"claimed": true, "user_id": currentUID})
}

func (s *Server) handleStaticFrontend(w http.ResponseWriter, r *http.Request) {
	if strings.HasPrefix(r.URL.Path, "/api/") {
		WriteProblem(w, r, http.StatusNotFound, "NOT_FOUND", "Resource Not Found", "The requested API endpoint does not exist.")
		return
	}

	rootAbs, err := filepath.Abs(s.cfg.WebStaticDir)
	if err == nil {
		cleanRel := filepath.Clean(strings.TrimPrefix(r.URL.Path, "/"))
		if cleanRel != "." && cleanRel != "" {
			for _, seg := range strings.Split(filepath.ToSlash(cleanRel), "/") {
				if seg != "." && seg != ".." && strings.HasPrefix(seg, ".") {
					WriteProblem(w, r, http.StatusNotFound, "NOT_FOUND", "Resource Not Found", "The requested resource does not exist.")
					return
				}
			}
		}
		if cleanRel != "." && cleanRel != "" && !strings.HasPrefix(cleanRel, "..") {
			candidate := filepath.Join(rootAbs, cleanRel)
			if strings.HasPrefix(candidate, rootAbs+string(filepath.Separator)) {
				if info, statErr := os.Stat(candidate); statErr == nil && !info.IsDir() {
					http.ServeFile(w, r, candidate)
					return
				}
			}
		}
	}

	if r.URL.Path != "/" && r.URL.Path != "/index.html" {
		WriteProblem(w, r, http.StatusNotFound, "NOT_FOUND", "Resource Not Found", "The requested endpoint or resource does not exist.")
		return
	}
	indexPath := filepath.Join(s.cfg.WebStaticDir, "index.html")
	if _, err := os.Stat(indexPath); err == nil {
		http.ServeFile(w, r, indexPath)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]string{
		"service": "Go Backend Academy API",
		"status":  "active",
	})
}

func (s *Server) handleListDiagnosticRules(w http.ResponseWriter, r *http.Request) {
	list, err := s.store.ListDiagnosticRules(r.Context())
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"rules": list})
}

func (s *Server) handleDiagnosticsAnalyze(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Code string `json:"code"`
	}
	if err := s.decodeJSON(w, r, &req); err != nil {
		writeDecodeError(w, r, err, "Request payload must be valid JSON containing a 'code' field.")
		return
	}
	report := s.analyzer.AnalyzeCode(r.Context(), req.Code)
	WriteJSON(w, http.StatusOK, report)
}

func (s *Server) handleRecommendations(w http.ResponseWriter, r *http.Request) {
	var snap recommendations.LearningSnapshot
	if err := s.decodeJSON(w, r, &snap); err != nil {
		writeDecodeError(w, r, err, "Invalid learning snapshot JSON.")
		return
	}
	items := s.recEngine.Compute(snap)
	WriteJSON(w, http.StatusOK, map[string]any{"recommendations": items})
}

// ---------- progress, bookmarks, notes ----------

func (s *Server) handleGetProgress(w http.ResponseWriter, r *http.Request) {
	userID, err := s.resolveUser(w, r)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	prog, err := s.store.GetUserProgress(r.Context(), userID)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"progress": prog})
}

func (s *Server) handleSaveProgress(w http.ResponseWriter, r *http.Request) {
	var payload struct {
		LessonID string `json:"lesson_id"`
		Status   string `json:"status"`
	}
	if err := s.decodeJSON(w, r, &payload); err != nil {
		writeDecodeError(w, r, err, "Body must be a JSON object with lesson_id and optional status.")
		return
	}
	if payload.LessonID == "" {
		WriteProblem(w, r, http.StatusBadRequest, "INVALID_PAYLOAD", "Bad Request", "lesson_id is required.")
		return
	}
	uid, err := s.resolveUser(w, r)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	if payload.Status == "" {
		payload.Status = "completed"
	}
	if !database.IsValidProgressStatus(payload.Status) {
		WriteProblem(w, r, http.StatusBadRequest, "INVALID_STATUS", "Bad Request", "status must be 'in_progress' or 'completed'.")
		return
	}
	exists, err := s.lessonsSvc.HasLesson(r.Context(), payload.LessonID)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	if !exists {
		WriteProblem(w, r, http.StatusBadRequest, "UNKNOWN_LESSON", "Bad Request", "lesson_id does not match any curriculum lesson.")
		return
	}
	if err := s.store.SetLessonProgress(r.Context(), uid, payload.LessonID, payload.Status); err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"status": "saved", "lesson_id": payload.LessonID})
}

func (s *Server) handleGetBookmarks(w http.ResponseWriter, r *http.Request) {
	userID, err := s.resolveUser(w, r)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	list, err := s.store.ListBookmarks(r.Context(), userID)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"user_id": userID, "bookmarks": list})
}

func (s *Server) handleSaveBookmark(w http.ResponseWriter, r *http.Request) {
	var payload struct {
		ItemType string `json:"item_type"`
		ItemID   string `json:"item_id"`
		Note     string `json:"note"`
	}
	if err := s.decodeJSON(w, r, &payload); err != nil {
		writeDecodeError(w, r, err, "Body must be a JSON object with item_id, optional item_type, and note.")
		return
	}
	if payload.ItemID == "" || len(payload.ItemID) > 64 {
		WriteProblem(w, r, http.StatusBadRequest, "INVALID_PAYLOAD", "Bad Request", "item_id is required (max 64 characters).")
		return
	}
	uid, err := s.resolveUser(w, r)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	if count, err := s.store.CountUserBookmarks(r.Context(), uid); err == nil && count >= 500 {
		WriteProblem(w, r, http.StatusBadRequest, "BOOKMARK_LIMIT_EXCEEDED", "Bad Request", "Bookmark limit exceeded (max 500 bookmarks per user).")
		return
	}
	if payload.ItemType == "" {
		payload.ItemType = "lesson"
	}
	if !database.IsValidBookmarkType(payload.ItemType) {
		WriteProblem(w, r, http.StatusBadRequest, "INVALID_BOOKMARK_TYPE", "Bad Request", "item_type must be 'lesson', 'case_study', or 'db_scenario'.")
		return
	}
	rec := shared.BookmarkRecord{UserID: uid, ItemType: payload.ItemType, ItemID: payload.ItemID, Note: payload.Note, CreatedAt: time.Now().UTC()}
	if err := s.store.SaveBookmark(r.Context(), rec); err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"status": "saved", "item_id": rec.ItemID})
}

func (s *Server) handleGetNotes(w http.ResponseWriter, r *http.Request) {
	userID, err := s.resolveUser(w, r)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	notes, err := s.store.GetNotes(r.Context(), userID)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"user_id": userID, "notes": notes})
}

func (s *Server) handleSaveNote(w http.ResponseWriter, r *http.Request) {
	var payload struct {
		LessonID string `json:"lesson_id"`
		Content  string `json:"content"`
	}
	if err := s.decodeJSON(w, r, &payload); err != nil {
		writeDecodeError(w, r, err, "Body must be a JSON object with lesson_id and content.")
		return
	}
	if payload.LessonID == "" {
		WriteProblem(w, r, http.StatusBadRequest, "INVALID_PAYLOAD", "Bad Request", "lesson_id is required.")
		return
	}
	if len(payload.Content) > 65536 {
		WriteProblem(w, r, http.StatusBadRequest, "PAYLOAD_TOO_LARGE", "Bad Request", "Note content exceeds maximum allowed size (64 KB).")
		return
	}
	uid, err := s.resolveUser(w, r)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	if count, err := s.store.CountUserNotes(r.Context(), uid); err == nil && count >= 200 {
		WriteProblem(w, r, http.StatusBadRequest, "NOTE_LIMIT_EXCEEDED", "Bad Request", "User note limit exceeded (max 200 notes per user).")
		return
	}
	exists, err := s.lessonsSvc.HasLesson(r.Context(), payload.LessonID)
	if err != nil {
		s.writeDBError(w, r, err)
		return
	}
	if !exists {
		WriteProblem(w, r, http.StatusBadRequest, "UNKNOWN_LESSON", "Bad Request", "lesson_id does not match any curriculum lesson.")
		return
	}
	noteID := "not_" + strings.ReplaceAll(uuid.NewString(), "-", "")[:24]
	if err := s.store.SaveNote(r.Context(), noteID, uid, payload.LessonID, payload.Content); err != nil {
		s.writeDBError(w, r, err)
		return
	}
	WriteJSON(w, http.StatusOK, map[string]any{"status": "saved", "lesson_id": payload.LessonID, "note_id": noteID})
}
