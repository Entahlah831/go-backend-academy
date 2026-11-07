package recommendations

type LearningSnapshot struct {
	CompletedLessons  map[string]bool `json:"completed_lessons"`
	FailedExercises   map[string]int  `json:"failed_exercises"`
	QuizScores        map[string]int  `json:"quiz_scores"`
	TriggeredRuleIDs  []string        `json:"triggered_rule_ids"`
	CurrentLessonID   string          `json:"current_lesson_id"`
}

type RecommendationItem struct {
	ID                      string   `json:"id"`
	WhatToLearn             string   `json:"what_to_learn"`
	WhyItMatters            string   `json:"why_it_matters"`
	Prerequisites           []string `json:"prerequisites"`
	ExpectedLearningOutcome string   `json:"expected_learning_outcome"`
	SuggestedExercise       string   `json:"suggested_exercise"`
	TargetLessonID          string   `json:"target_lesson_id"`
	TriggerReason           string   `json:"trigger_reason"`
}

type Engine struct{}

func NewEngine() *Engine {
	return &Engine{}
}

func (e *Engine) Compute(snap LearningSnapshot) []RecommendationItem {
	var out []RecommendationItem
	hasRule := func(ruleID string) bool {
		for _, r := range snap.TriggeredRuleIDs {
			if r == ruleID {
				return true
			}
		}
		return false
	}

	// 1. Triggered SQLi diagnostic or failed security exercise -> Parameterized SQL & SSRF/BOLA practice
	if hasRule("GO-SEC-001") || snap.FailedExercises["l6-security-auth-owasp"] > 0 {
		out = append(out, RecommendationItem{
			ID:                      "rec-sqli-parameterization",
			WhatToLearn:             "Parameterized SQL Queries, SSRF Socket Guards & BOLA Prevention (Level 6.1)",
			WhyItMatters:            "Dynamic SQL string formatting (GO-SEC-001) or unvalidated outbound IPs expose your database and internal cloud metadata to immediate compromise.",
			Prerequisites:           []string{"Level 0.1 HTTP Lifecycle", "Level 5.1 database/sql & pgx"},
			ExpectedLearningOutcome: "Write 100% parameterized SQL queries and block private/link-local IPs in net.Dialer.Control.",
			SuggestedExercise:       "Implement ValidateWebhookIP and ConstantTimeCompare API Key Verifier",
			TargetLessonID:          "l6-security-auth-owasp",
			TriggerReason:           "Triggered by SQL/Security diagnostic or failed Level 6 exercise",
		})
	}

	// 2. Failed transaction/isolation exercise or low Level 4 quiz score -> MVCC & Isolation Levels
	if snap.FailedExercises["l4-acid-isolation-mvcc"] > 0 || (snap.QuizScores["qz-3"] == 0 && len(snap.QuizScores) > 0) {
		out = append(out, RecommendationItem{
			ID:                      "rec-mvcc-isolation",
			WhatToLearn:             "MVCC Snapshot Isolation, Lost Updates & Composite B-Tree Indexing (Level 4.1)",
			WhyItMatters:            "Application-side Read-Modify-Write under default READ COMMITTED causes double-spending unless guarded by atomic conditional UPDATE or SELECT ... FOR UPDATE.",
			Prerequisites:           []string{"Level 0.2 Stateless vs Stateful Systems"},
			ExpectedLearningOutcome: "Eliminate Lost Updates and AB/BA deadlocks in concurrent financial transfers.",
			SuggestedExercise:       "Deterministic Lexicographical Lock Ordering for Multi-Account Transfers",
			TargetLessonID:          "l4-acid-isolation-mvcc",
			TriggerReason:           "Triggered by transaction/indexing assessment gap",
		})
	}

	// 3. Understands interfaces (Level 1.2 completed) but has not practiced Hexagonal DI (Level 8.1)
	if snap.CompletedLessons["l1-interfaces-errors-generics"] && !snap.CompletedLessons["l8-clean-hexagonal-ddd"] {
		out = append(out, RecommendationItem{
			ID:                      "rec-interfaces-to-di",
			WhatToLearn:             "Consumer-Defined Port Interfaces & Constructor Dependency Injection (Level 8.1)",
			WhyItMatters:            "You have completed Go Interfaces (Level 1.2), which unlocks decoupling domain business rules from HTTP and SQL adapters without reflection DI frameworks.",
			Prerequisites:           []string{"Level 1.2 Implicit Interfaces & Error Wrapping"},
			ExpectedLearningOutcome: "Structure services with inward-pointing dependencies and test domain rules in <1ms.",
			SuggestedExercise:       "Refactor Coupled Checkout Handler & Implement Exact Integer Basis-Point Math",
			TargetLessonID:          "l8-clean-hexagonal-ddd",
			TriggerReason:           "Unlocked by completing Level 1.2 Interfaces",
		})
	}

	// 4. Understands REST/HTTP (Level 0.1 completed) but hasn't practiced Middleware/Rate Limiting (Level 3)
	if snap.CompletedLessons["l0-backend-http-lifecycle"] && !snap.CompletedLessons["l3-net-http-routers"] {
		out = append(out, RecommendationItem{
			ID:                      "rec-http-to-middleware",
			WhatToLearn:             "Composable HTTP Middleware, Keyset Pagination & Graceful Shutdown (Level 3.1)",
			WhyItMatters:            "Moving from basic HTTP handlers to production services requires panic recovery, X-Request-ID correlation, and zero-downtime SIGTERM draining.",
			Prerequisites:           []string{"Level 0.1 Client-Server & HTTP Lifecycle"},
			ExpectedLearningOutcome: "Build composable func(http.Handler) http.Handler middleware chains and drain active connections safely.",
			SuggestedExercise:       "Build Request-ID & Panic-Recovery Middleware Chain",
			TargetLessonID:          "l3-net-http-routers",
			TriggerReason:           "Unlocked by completing Level 0.1 HTTP Fundamentals",
		})
	}

	// 5. Default progressive starting path if user is brand new
	if len(out) < 2 && !snap.CompletedLessons["l1-memory-slices-maps-escape"] {
		out = append(out, RecommendationItem{
			ID:                      "rec-slice-memory-model",
			WhatToLearn:             "Slice Backing Arrays, Sub-Slice Memory Retention & Escape Analysis (Level 1.1)",
			WhyItMatters:            "Understanding the 24-byte slice header and compiler escape analysis prevents multi-megabyte backing-array memory leaks.",
			Prerequisites:           []string{"Level 0.1 HTTP Lifecycle"},
			ExpectedLearningOutcome: "Detach sub-slices safely with copy()/bytes.Clone() and inspect heap escapes via -gcflags='-m'.",
			SuggestedExercise:       "Fix Sub-Slice Memory Retention & Side-Effect Mutation",
			TargetLessonID:          "l1-memory-slices-maps-escape",
			TriggerReason:           "Core Go Foundation Path",
		})
	}

	if len(out) < 3 && !snap.CompletedLessons["l2-gmp-channels-context-workers"] {
		out = append(out, RecommendationItem{
			ID:                      "rec-concurrency-workers",
			WhatToLearn:             "GMP Scheduler, Buffered Channel Leak Prevention & Context Worker Pools (Level 2.1)",
			WhyItMatters:            "Sending to an unbuffered channel inside a child goroutine leaks memory forever if the parent HTTP handler exits early on context timeout.",
			Prerequisites:           []string{"Level 1.1 Memory & Slices", "Level 1.2 Interfaces & Errors"},
			ExpectedLearningOutcome: "Build context-cancelable bounded worker pools with zero goroutine leaks.",
			SuggestedExercise:       "Implement a Context-Cancelable Bounded Worker Pool",
			TargetLessonID:          "l2-gmp-channels-context-workers",
			TriggerReason:           "Core Concurrency Path",
		})
	}

	return out
}
