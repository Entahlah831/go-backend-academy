// Go Backend Academy v2.5.0 — Authoritative Frontend-Backend Integration, Hallmark 4-Step Focus & Pedagogy Bridge
// Connects all views to the Go backend API on whatever PORT is configured in .env,
// merges all 41 Stage A–J lessons, enforces Honest Mastery states, isolates per-browser user_id,
// and wires live read-only SQLite execution (with live index toggle) into the SQL Playground.
(function () {
  function isHttpOrigin() {
    return Boolean(window.location && /^https?:$/i.test(window.location.protocol));
  }

  function apiUrl(path) {
    return window.location.origin + path;
  }

  // Per-Browser Isolated Learner Identity (P0-AUTH-001)
  function getActiveUserId() {
    if (typeof SafeStore !== 'undefined') {
      let uid = SafeStore.get('userId', '');
      if (!uid || typeof uid !== 'string' || uid === 'usr_local_default' || !uid.startsWith('usr_')) {
        const randHex = Math.random().toString(16).slice(2, 10) + Date.now().toString(16).slice(-6);
        uid = 'usr_' + randHex;
        SafeStore.set('userId', uid);
      }
      return uid;
    }
    return 'usr_local_default';
  }
  window.getActiveUserId = getActiveUserId;

  // 1. Merge the 17 Stage A–J foundation & bridge lessons into PLATFORM_DATA.curriculum (41 Total Lessons)
  function integrateStageCurriculum() {
    if (typeof PLATFORM_DATA === 'undefined' || !Array.isArray(window.GBA_FOUNDATION_LESSONS)) return;
    const existingById = {};
    PLATFORM_DATA.curriculum.forEach(function (l) { existingById[l.id] = l; });
    window.GBA_FOUNDATION_LESSONS.forEach(function (fl) {
      if (!existingById[fl.id]) {
        PLATFORM_DATA.curriculum.push(fl);
      } else {
        Object.assign(existingById[fl.id], fl);
      }
    });

    const orderRank = {
      'l0-stage-a-what-is-backend': 1,
      'l0-stage-a-git-go-workspace': 2,
      'l0-backend-http-lifecycle': 3,
      'l0-stateless-vs-stateful-arch': 4,
      'l0-rest-json-api-contracts': 5,
      'l1-stage-b-variables-types-zerovalues': 10,
      'l1-stage-b-control-flow-loops-functions': 11,
      'l1-stage-b-slices-maps-iteration': 12,
      'l1-stage-b-structs-methods-pointers': 13,
      'l1-stage-b-interfaces-errors-fundamentals': 14,
      'l1-stage-b-json-files-unit-testing': 15,
      'l1-toolchain-modules-packages': 16,
      'l1-memory-slices-maps-escape': 17,
      'l1-interfaces-errors-generics': 18,
      'l2-stage-c-goroutines-channels-waitgroup': 20,
      'l2-gmp-channels-context-workers': 21,
      'l2-profiling-pprof-benchmarks': 22,
      'l3-stage-d-first-http-server-crud': 30,
      'l3-net-http-routers': 31,
      'l3-validation-openapi-ratelimit': 32,
      'l4-stage-e-sql-relational-fundamentals': 40,
      'l4-acid-isolation-mvcc': 41,
      'l4-partitioning-replication-sharding': 42,
      'l5-stage-e-database-sql-crud-basics': 50,
      'l5-db-ecosystem-comparison': 51,
      'l5-migrations-transactions-prepared': 52,
      'l6-stage-f-password-hashing-bearer-auth': 60,
      'l6-security-auth-owasp': 61,
      'l6-oauth2-oidc-rbac-abac': 62,
      'l7-stage-g-table-driven-tests-httptest': 70,
      'l7-testing-fuzzing-benchmarks': 71,
      'l7-integration-testcontainers-ci': 72,
      'l8-stage-h-handler-service-repo-layers': 80,
      'l8-clean-hexagonal-ddd': 81,
      'l8-modular-monolith-cqrs-boundaries': 82,
      'l9-stage-i-redis-cache-aside-backoff': 90,
      'l9-caching-queues-outbox-sagas': 91,
      'l9-grpc-websockets-otel-tracing': 92,
      'l10-devops-docker-k8s-production': 100,
      'l10-reverse-proxy-cicd-rollback-dr': 101,
      'l10-stage-j-capstone-production-blueprint': 102
    };

    PLATFORM_DATA.curriculum.sort(function (a, b) {
      return (orderRank[a.id] || 999) - (orderRank[b.id] || 999);
    });
  }

  // 2. Honest Mastery State calculation: Unlocked -> Read -> Practiced -> Verified -> Mastered
  function computeMasteryState(lessonId) {
    const isRead = Boolean(AppState.completedLessons && AppState.completedLessons[lessonId]);
    const isExVerified = Boolean(AppState.passedExercises && AppState.passedExercises[lessonId]);
    const lessonChecks = SafeStore.get('lessonKnowledgeChecks', {});
    const isQuizPassed = Boolean(lessonChecks[lessonId]);
    const hadAttempt = Boolean(AppState.failedExercises && AppState.failedExercises[lessonId]);

    if (isRead && isExVerified && isQuizPassed) {
      return { code: 'mastered', label: 'Mastered (Read + Exercise + Check)', cls: 'ok' };
    }
    if (isExVerified) {
      return { code: 'verified', label: 'Verified (Exercise Passed)', cls: 'ok' };
    }
    if (hadAttempt || isQuizPassed) {
      return { code: 'practiced', label: 'Practiced (In Progress)', cls: 'cool' };
    }
    if (isRead) {
      return { code: 'read', label: 'Read (Lab Pending)', cls: 'cool' };
    }
    return { code: 'unlocked', label: 'Unlocked', cls: '' };
  }

  function getLessonPedagogyMeta(lesson) {
    const meta = (window.GBA_STAGE_META && window.GBA_STAGE_META[lesson.id]) || { stage: 'F', prereqs: [] };
    const stageCode = meta.stage || 'F';
    const stageTitle = (window.GBA_STAGE_LABELS && window.GBA_STAGE_LABELS[stageCode]) || ('Stage ' + stageCode);
    const objectives = meta.objectives || [
      'Understand the core mental model and internal mechanism of ' + lesson.title + '.',
      'Contrast the anti-pattern failure mode against the production-grade Go implementation.',
      'Pass the hands-on verification suite for ' + lesson.exercise.title + '.'
    ];
    const vocab = meta.vocab || (lesson.pillars && lesson.pillars.whatIsIt) || lesson.summary;
    const guided = meta.guided || (lesson.exercise && lesson.exercise.hints ? lesson.exercise.hints.join(' -> ') : '');
    const quiz = meta.quiz || {
      q: 'Which engineering trade-off justifies the production pattern in "' + lesson.title + '"?',
      opts: [
        'It eliminates all CPU and memory usage automatically without configuration',
        lesson.codeComparison.engineeringReasoning,
        'It bypasses compile-time type checking for faster prototyping'
      ],
      ans: 1,
      exp: lesson.codeComparison.engineeringReasoning
    };
    return { stageCode: stageCode, stageTitle: stageTitle, prereqs: meta.prereqs || [], objectives: objectives, vocab: vocab, guided: guided, quiz: quiz };
  }

  // 3. Hallmark 4-Step Focus Mode & Pedagogy Panel inside #view-curriculum
  function setLessonFocusStep(stepName) {
    AppState.currentLessonStep = stepName || 'step1';
    const step1 = document.getElementById('lesson-step-1-container');
    const step2 = document.getElementById('lesson-step-2-container');
    const step3 = document.getElementById('lesson-step-3-container');
    const step4 = document.getElementById('lesson-step-4-container');
    const isAll = (AppState.currentLessonStep === 'all');

    if (step1) step1.classList.toggle('hidden', !isAll && AppState.currentLessonStep !== 'step1');
    if (step2) step2.classList.toggle('hidden', !isAll && AppState.currentLessonStep !== 'step2');
    if (step3) step3.classList.toggle('hidden', !isAll && AppState.currentLessonStep !== 'step3');
    if (step4) step4.classList.toggle('hidden', !isAll && AppState.currentLessonStep !== 'step4');

    document.querySelectorAll('[data-lesson-step-btn]').forEach(function (btn) {
      btn.classList.toggle('is-active', btn.getAttribute('data-lesson-step-btn') === AppState.currentLessonStep);
    });
  }
  window.setLessonFocusStep = setLessonFocusStep;

  function renderPedagogyPanel() {
    const lesson = PLATFORM_DATA.curriculum.find(function (l) { return l.id === AppState.currentLessonId; }) || PLATFORM_DATA.curriculum[0];
    if (!lesson) return;
    const meta = getLessonPedagogyMeta(lesson);
    const mastery = computeMasteryState(lesson.id);

    const modBadge = document.getElementById('lesson-module-badge');
    if (modBadge) {
      modBadge.textContent = meta.stageTitle + ' • ' + mastery.label;
    }

    // Render compact prerequisite bar inside the lesson header card
    const prereqBar = document.getElementById('lesson-prereq-compact-bar');
    if (prereqBar) {
      const prereqHtml = meta.prereqs.length === 0
        ? '<span class="tag-pill ok">Entry-Level Starting Lesson (No Prerequisites)</span>'
        : meta.prereqs.map(function (pid) {
            const pl = PLATFORM_DATA.curriculum.find(function (x) { return x.id === pid; });
            const done = Boolean((AppState.completedLessons && AppState.completedLessons[pid]) || (AppState.passedExercises && AppState.passedExercises[pid]));
            const title = pl ? pl.title : pid;
            return '<button type="button" data-prereq-jump="' + escapeHtml(pid) + '" class="btn-ghost" style="padding:2px 8px;font-size:12px;">' +
              (done ? '✓ ' : 'Prerequisite: ') + escapeHtml(title) + '</button>';
          }).join(' ');
      prereqBar.innerHTML = '<div class="pill-row" style="align-items:center;"><span class="telemetry-label">Prerequisites:</span> ' + prereqHtml + '</div>';
      prereqBar.querySelectorAll('[data-prereq-jump]').forEach(function (btn) {
        btn.addEventListener('click', function () {
          AppState.currentLessonId = btn.getAttribute('data-prereq-jump');
          renderCurrentLesson();
        });
      });
    }

    // Render Guided Hints & Vocabulary banner inside Step 3 (Exercise)
    const guidedBanner = document.getElementById('exercise-guided-walkthrough-box');
    if (guidedBanner) {
      guidedBanner.innerHTML =
        '<div><strong>Key Concepts:</strong> ' + escapeHtml(meta.vocab) + '</div>' +
        '<div style="margin-top:4px;"><strong>Step-by-Step Guide:</strong> ' + escapeHtml(meta.guided) + '</div>';
    }

    // Render Step 4 Mastery Check & Learning Objectives panel inside #lesson-step-4-container
    const panel = document.getElementById('gba-pedagogy-blueprint-panel');
    if (!panel) return;

    const lessonChecks = SafeStore.get('lessonKnowledgeChecks', {});
    const checkPassed = Boolean(lessonChecks[lesson.id]);

    panel.innerHTML =
      '<div class="view-stack">' +
        '<div class="control-group" style="justify-content: space-between;">' +
          '<h3>Step 4: Mastery Verification & Learning Objectives</h3>' +
          '<span class="tag-pill ' + mastery.cls + '">Status: ' + escapeHtml(mastery.label) + '</span>' +
        '</div>' +
        '<div class="surface-recessed">' +
          '<strong>Learning Objectives Checklist:</strong>' +
          '<ul style="margin:6px 0 0 18px;">' +
            meta.objectives.map(function (o) { return '<li>' + escapeHtml(o) + '</li>'; }).join('') +
          '</ul>' +
        '</div>' +
        '<div class="surface-recessed">' +
          '<strong>Active Recall Knowledge Check ' + (checkPassed ? '(Verified ✓)' : '(Required for Mastered Badge)') + ':</strong>' +
          '<p style="margin:6px 0;">' + escapeHtml(meta.quiz.q) + '</p>' +
          '<div class="view-stack">' +
            meta.quiz.opts.map(function (opt, idx) {
              return '<button type="button" data-lesson-kc-idx="' + idx + '" class="quiz-opt-btn">' +
                '<span>' + escapeHtml(opt) + '</span></button>';
            }).join('') +
          '</div>' +
          '<div id="lesson-kc-feedback" class="' + (checkPassed ? 'console-pass' : 'hidden') + '" style="margin-top:8px;">' +
            (checkPassed ? ('Verified: ' + escapeHtml(meta.quiz.exp)) : '') +
          '</div>' +
        '</div>' +
      '</div>';

    panel.querySelectorAll('[data-lesson-kc-idx]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        const picked = parseInt(btn.getAttribute('data-lesson-kc-idx'), 10);
        const fb = document.getElementById('lesson-kc-feedback');
        fb.classList.remove('hidden');
        if (picked === meta.quiz.ans) {
          const checks = SafeStore.get('lessonKnowledgeChecks', {});
          checks[lesson.id] = true;
          SafeStore.set('lessonKnowledgeChecks', checks);
          fb.className = 'console-pass';
          fb.textContent = 'Correct! ' + meta.quiz.exp;
          renderPedagogyPanel();
        } else {
          fb.className = 'console-warn';
          fb.textContent = 'Not quite — review Step 1 (Concept) and Step 2 (Code Comparison) and try again.';
        }
      });
    });
  }

  // 4. Extend Exercise Verification to support all 41 lessons + Backend API verification
  function wrapExerciseRunner() {
    const origRun = window.runCurrentExerciseTests;
    if (typeof origRun !== 'function') return;

    window.runCurrentExerciseTests = function () {
      const lesson = PLATFORM_DATA.curriculum.find(function (l) { return l.id === AppState.currentLessonId; }) || PLATFORM_DATA.curriculum[0];
      const rawCode = document.getElementById('exercise-code-editor').value;
      const code = stripGoCommentsJS(rawCode);
      const outEl = document.getElementById('exercise-console-output');
      const uid = getActiveUserId();

      if (lesson && lesson.exercise && Array.isArray(lesson.exercise.requiredTokens)) {
        const hasUnfinishedStep = rawCode.includes('// STEP:');
        const checks = lesson.exercise.requiredTokens.map(function (tok) {
          return ['Contains required pattern: ' + tok, code.includes(tok)];
        });
        if (hasUnfinishedStep) {
          checks.unshift(['Remove // STEP: placeholder and implement solution', false]);
        }
        const failed = checks.filter(function (c) { return !c[1]; });
        const lines = [
          '=== Cek pola kode (bukan go test) ===',
          'Pemeriksaan pola struktural & invarian kode.',
          ''
        ];
        checks.forEach(function (c) {
          lines.push((c[1] ? '  [PASS] ' : '  [FAIL] ') + 'Kode harus memuat: ' + c[0]);
        });

        if (failed.length === 0) {
          lines.push('\n[LULUS] Seluruh pola kode yang diwajibkan terpenuhi!');
          lines.push('Catatan: Ini pengecekan pola struktural, bukan eksekusi binary.');
          lines.push('Untuk verifikasi penuh dengan Go compiler, jalankan di terminal laptop Anda:');
          lines.push('  go test -v -race ./...');
          outEl.className = 'console-pass';
          outEl.textContent = lines.join('\n');
          AppState.passedExercises[lesson.id] = true;
          SafeStore.set('passedExercises', AppState.passedExercises);
          updateProgressMetrics();
          showToast('Pola latihan terverifikasi!');
        } else {
          lines.push('\n[BELUM LENGKAP] Beberapa pola kode yang diwajibkan belum ditemukan.');
          lines.push('Periksa kembali petunjuk dan pastikan kode mengimplementasikan seluruh invarian.');
          outEl.className = 'console-fail';
          outEl.textContent = lines.join('\n');
          AppState.failedExercises[lesson.id] = (AppState.failedExercises[lesson.id] || 0) + 1;
          SafeStore.set('failedExercises', AppState.failedExercises);
        }
      } else {
        origRun();
      }

      renderPedagogyPanel();

      if (isHttpOrigin() && lesson) {
        const exId = (lesson.exercise && lesson.exercise.id) || ('ex-' + lesson.id);
        window.fetch(apiUrl('/api/v1/exercises/verify'), {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            user_id: uid,
            exercise_id: exId,
            code: rawCode,
            required_tokens: (lesson.exercise && lesson.exercise.requiredTokens) || []
          })
        })
          .then(function (r) { return r.ok ? r.json() : null; })
          .then(function (data) {
            if (data && data.attempt_id) {
              const execTimeStr = (data.execution_ms && data.execution_ms > 0) ? ' (' + data.execution_ms + 'ms)' : '';
              outEl.textContent += '\n[Server Verification Recorded: attempt=' + data.attempt_id + ', passed=' + data.passed + execTimeStr + ']';
            }
          })
          .catch(function () {});
      }
    };
  }

  // 5. Wire Live SQLite Sandbox Execution (/api/v1/sql-playground/execute) with use_index toggle
  function wrapSqlPlayground() {
    const origSqlRun = window.runSqlPlaygroundQuery;
    if (typeof origSqlRun !== 'function') return;

    window.runSqlPlaygroundQuery = function () {
      origSqlRun();
      if (!isHttpOrigin()) return;
      const editor = document.getElementById('sql-pg-editor');
      if (!editor) return;
      const q = editor.value.trim();
      if (!q || !/^(SELECT|WITH|EXPLAIN)\b/i.test(q)) return;
      const indexToggle = document.getElementById('sql-pg-index-toggle');
      const useIdx = indexToggle ? Boolean(indexToggle.checked) : true;

      window.fetch(apiUrl('/api/v1/sql-playground/execute'), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: q, explain: true, use_index: useIdx })
      })
        .then(function (res) { return res.ok ? res.json() : null; })
        .then(function (data) {
          if (!data || !Array.isArray(data.columns)) return;
          const tbl = document.getElementById('sql-pg-results-table');
          if (tbl) {
            tbl.innerHTML =
              '<div class="telemetry-label" style="margin-bottom:6px;">Live Sandbox Execution (' + escapeHtml(data.engine) + ' — ' + data.row_count + ' rows in ' + data.execution_ms + 'ms, composite_index=' + (useIdx ? 'ON' : 'OFF') + ')</div>' +
              '<table class="data-table"><thead><tr>' +
              data.columns.map(function (c) { return '<th>' + escapeHtml(c) + '</th>'; }).join('') +
              '</tr></thead><tbody>' +
              data.rows.map(function (r) {
                return '<tr>' + r.map(function (cell) { return '<td>' + escapeHtml(cell) + '</td>'; }).join('') + '</tr>';
              }).join('') +
              '</tbody></table>';
          }
          if (Array.isArray(data.query_plan) && data.query_plan.length > 0) {
            const expBox = document.getElementById('sql-pg-explain-box');
            if (expBox) {
              expBox.textContent += '\n\n--- LIVE SQLITE SANDBOX EXPLAIN QUERY PLAN (index=' + (useIdx ? 'ON' : 'OFF') + ') ---\n' + data.query_plan.join('\n');
            }
          }
        })
        .catch(function () {});
    };
  }

  // 6. Bidirectional hydration & sync with all Go Backend API endpoints using per-browser user_id
  async function hydrateFromBackendAPI() {
    if (!isHttpOrigin()) return;
    const uid = getActiveUserId();
    try {
      const readyRes = await window.fetch(apiUrl('/readyz'));
      if (readyRes.ok) {
        const info = await readyRes.json();
        const progPill = document.getElementById('top-progress-pill');
        if (progPill && info.db_driver) {
          progPill.title = 'Connected to Go Backend (' + info.db_driver + ', learner=' + uid + ')';
        }
      }

      const [progRes, bmRes, notesRes] = await Promise.all([
        window.fetch(apiUrl('/api/v1/progress?user_id=' + encodeURIComponent(uid))),
        window.fetch(apiUrl('/api/v1/bookmarks?user_id=' + encodeURIComponent(uid))),
        window.fetch(apiUrl('/api/v1/notes?user_id=' + encodeURIComponent(uid)))
      ]);

      if (progRes.ok) {
        const pData = await progRes.json();
        if (pData && pData.progress && Object.keys(pData.progress).length > 0) {
          Object.keys(pData.progress).forEach(function (lid) {
            if (pData.progress[lid] === 'completed') {
              AppState.completedLessons[lid] = true;
            }
          });
          SafeStore.set('completedLessons', AppState.completedLessons);
          if (AppState.currentView === 'dashboard') renderDashboard();
        }
      }

      if (bmRes.ok) {
        const bData = await bmRes.json();
        if (bData && Array.isArray(bData.bookmarks)) {
          bData.bookmarks.forEach(function (b) {
            if (b.item_id) AppState.bookmarks[b.item_id] = true;
          });
          SafeStore.set('bookmarks', AppState.bookmarks);
        }
      }

      if (notesRes.ok) {
        const nData = await notesRes.json();
        if (nData && nData.notes && nData.notes[AppState.currentLessonId] && !AppState.personalNotes) {
          AppState.personalNotes = nData.notes[AppState.currentLessonId];
          SafeStore.set('personalNotes', AppState.personalNotes);
        }
      }

      updateProgressMetrics();
      if (AppState.currentView === 'curriculum') renderCurrentLesson();
    } catch (e) {
      // Offline standalone mode: continues with SafeStore local fallback
    }
  }

  integrateStageCurriculum();
  if (typeof AppState !== 'undefined' && typeof PLATFORM_DATA !== 'undefined' && PLATFORM_DATA.curriculum.length > 0) {
    AppState.currentLessonId = PLATFORM_DATA.curriculum[0].id;
    AppState.currentPillarGroup = 'core';
    AppState.currentLessonStep = 'step1';
  }

  window.addEventListener('DOMContentLoaded', function () {
    const origRenderLesson = window.renderCurrentLesson;
    if (typeof origRenderLesson === 'function') {
      window.renderCurrentLesson = function () {
        if (!AppState.currentPillarGroup || AppState.currentPillarGroup === 'all') {
          AppState.currentPillarGroup = 'core';
        }
        origRenderLesson();
        renderPedagogyPanel();
        setLessonFocusStep(AppState.currentLessonStep || 'step1');
      };
    }

    wrapExerciseRunner();
    wrapSqlPlayground();

    // Wire 4-Step Focus Stepper buttons & Next-Step progression buttons
    document.querySelectorAll('[data-lesson-step-btn]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        setLessonFocusStep(btn.getAttribute('data-lesson-step-btn'));
      });
    });
    document.querySelectorAll('[data-goto-lesson-step]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        setLessonFocusStep(btn.getAttribute('data-goto-lesson-step'));
        const headerCard = document.getElementById('lesson-focus-stepper');
        if (headerCard && headerCard.scrollIntoView) {
          headerCard.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
      });
    });

    const compBtn = document.getElementById('btn-mark-lesson-complete');
    if (compBtn) {
      compBtn.addEventListener('click', function () {
        if (!isHttpOrigin()) return;
        const id = AppState.currentLessonId;
        window.fetch(apiUrl('/api/v1/progress'), {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            user_id: getActiveUserId(),
            lesson_id: id,
            status: AppState.completedLessons[id] ? 'completed' : 'in_progress'
          })
        }).catch(function () {});
        renderPedagogyPanel();
      });
    }

    const bmBtn = document.getElementById('btn-bookmark-lesson');
    if (bmBtn) {
      bmBtn.addEventListener('click', function () {
        if (!isHttpOrigin()) return;
        const id = AppState.currentLessonId;
        window.fetch(apiUrl('/api/v1/bookmarks'), {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            user_id: getActiveUserId(),
            item_type: 'lesson',
            item_id: id,
            note: AppState.bookmarks[id] ? 'Bookmarked' : ''
          })
        }).catch(function () {});
      });
    }

    const noteBtn = document.getElementById('btn-save-note');
    if (noteBtn) {
      noteBtn.addEventListener('click', function () {
        if (!isHttpOrigin()) return;
        window.fetch(apiUrl('/api/v1/notes'), {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            user_id: getActiveUserId(),
            lesson_id: AppState.currentLessonId,
            content: AppState.personalNotes || ''
          })
        }).catch(function () {});
      });
    }

    renderCurrentLesson();
    hydrateFromBackendAPI();
  });
})();
