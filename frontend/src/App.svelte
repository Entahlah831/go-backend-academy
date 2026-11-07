<script lang="ts">
  import { onMount } from 'svelte';
  import WorkspaceLayout from './layouts/WorkspaceLayout.svelte';
  import Navbar from './components/Navbar.svelte';
  import Sidebar from './components/Sidebar.svelte';
  import DiagnosticsLab from './pages/DiagnosticsLab.svelte';
  import {
    fetchReadyStatus,
    fetchCurriculum,
    fetchLessonDetail,
    verifyExercise,
    executeSQLPlayground,
    fetchCaseStudies,
    fetchDBScenarios,
    fetchQuizzes,
    analyzeGoCode,
    fetchUserProgress,
    syncLessonProgress,
    saveUserNote
  } from './services/api';
  import { loadState, saveState } from './stores/progressStore';

  let activeView = 'dashboard';
  let searchQuery = '';
  let dbStatusLabel = 'Checking backend...';

  let levels: any[] = [];
  let lessons: any[] = [];
  let currentLessonId = 'l0-stage-a-what-is-backend';
  let currentLessonDetail: any = null;
  let exerciseCode = '';
  let exerciseOutput = '';

  let caseStudies: any[] = [];
  let dbScenarios: any[] = [];
  let quizzes: any[] = [];

  let sqlQuery =
    "SELECT c.full_name, COUNT(o.id) AS paid_orders, SUM(o.total_cents) AS total_cents FROM customers c JOIN orders o ON o.customer_id = c.id WHERE o.status = 'paid' GROUP BY c.id ORDER BY total_cents DESC";
  let sqlResult: any = null;
  let sqlError = '';

  let completedLessons: Record<string, boolean> = loadState('completedLessons', {});
  let personalNotes: string = loadState('personalNotes', '');

  let sampleCode = 'package main\n\nfunc main() {}';
  let sampleReport = {
    offline_mode: true,
    toolchain_executed: false,
    summary_status: 'no_finding_detected',
    findings: [],
    static_analysis_limitations: 'Static analysis inspects syntax and local code patterns in isolation.',
    optional_ai_status: 'AI_PROVIDER=none',
    analyzed_at: new Date().toISOString()
  };

  $: progressPct =
    lessons.length > 0
      ? Math.round((Object.keys(completedLessons).filter((k) => completedLessons[k]).length / lessons.length) * 100)
      : 0;

  async function selectLesson(id: string) {
    currentLessonId = id;
    try {
      currentLessonDetail = await fetchLessonDetail(id);
      exerciseCode = currentLessonDetail?.exercise?.starter_code || '';
      exerciseOutput = '';
    } catch {
      currentLessonDetail = null;
    }
  }

  async function handleRunExercise() {
    if (!currentLessonDetail?.exercise) return;
    const reqTokens = (currentLessonDetail.exercise.test_cases || [])
      .map((tc: any) => tc.required_pattern)
      .filter(Boolean);
    try {
      const res = await verifyExercise(currentLessonDetail.exercise.id, exerciseCode, reqTokens);
      exerciseOutput = `${res.passed ? 'PASS' : 'FAIL'} (${res.attempt_id}): ${res.diagnostics}`;
      if (res.passed) {
        completedLessons[currentLessonId] = true;
        saveState('completedLessons', completedLessons);
        await syncLessonProgress(currentLessonId, 'completed');
      }
    } catch (e: any) {
      exerciseOutput = e?.message || 'Verification error';
    }
  }

  async function handleRunSQL() {
    sqlError = '';
    try {
      sqlResult = await executeSQLPlayground(sqlQuery, true);
    } catch (e: any) {
      sqlError = e?.message || 'SQL execution failed';
    }
  }

  async function handleRunDiagnostics() {
    sampleReport = await analyzeGoCode(sampleCode, () => sampleReport);
  }

  async function handleToggleComplete() {
    completedLessons[currentLessonId] = !completedLessons[currentLessonId];
    saveState('completedLessons', completedLessons);
    await syncLessonProgress(currentLessonId, completedLessons[currentLessonId] ? 'completed' : 'in_progress');
  }

  async function handleSaveNote() {
    saveState('personalNotes', personalNotes);
    await saveUserNote(currentLessonId, personalNotes);
  }

  function toggleTheme() {
    const html = document.documentElement;
    const isDark = html.classList.toggle('dark');
    html.setAttribute('data-mode', isDark ? 'dark' : 'light');
  }

  onMount(async () => {
    const ready = await fetchReadyStatus();
    if (ready) {
      dbStatusLabel = `Connected (${ready.db_driver}, persistent=${ready.db_persistent})`;
    } else {
      dbStatusLabel = 'Offline Local Mode';
    }

    try {
      const cur = await fetchCurriculum();
      levels = cur.levels || [];
      lessons = cur.lessons || [];
      if (lessons.length > 0) {
        await selectLesson(lessons[0].id);
      }
      const serverProg = await fetchUserProgress();
      Object.keys(serverProg).forEach((lid) => {
        if (serverProg[lid] === 'completed') completedLessons[lid] = true;
      });
      saveState('completedLessons', completedLessons);

      [caseStudies, dbScenarios, quizzes] = await Promise.all([
        fetchCaseStudies(),
        fetchDBScenarios(),
        fetchQuizzes()
      ]);
      await handleRunSQL();
    } catch {
      // Offline standalone mode
    }
  });
</script>

<WorkspaceLayout {activeView} onNavigate={(v) => (activeView = v)}>
  <Navbar slot="header" {progressPct} bind:searchQuery onToggleTheme={toggleTheme} />
  <Sidebar slot="sidebar" {activeView} onSelectView={(v) => (activeView = v)} />

  {#if activeView === 'diagnostics'}
    <DiagnosticsLab bind:code={sampleCode} report={sampleReport} onRunAnalysis={handleRunDiagnostics} />
  {:else if activeView === 'curriculum'}
    <section class="surface-card">
      <div class="surface-header">
        <div>
          <h2>Curriculum Engine ({lessons.length} Lessons — Stages A–J)</h2>
          <p class="telemetry-label">{dbStatusLabel}</p>
        </div>
        <select value={currentLessonId} on:change={(e) => selectLesson(e.currentTarget.value)}>
          {#each lessons as l}
            <option value={l.id}>{l.title}</option>
          {/each}
        </select>
      </div>
      {#if currentLessonDetail}
        <h3>{currentLessonDetail.title}</h3>
        <p>{currentLessonDetail.summary}</p>
        {#each currentLessonDetail.sections || [] as sec}
          <pre>{sec.diagram}</pre>
          <p>{sec.body}</p>
        {/each}
        {#if currentLessonDetail.exercise}
          <div class="surface-recessed">
            <h4>Hands-On Exercise: {currentLessonDetail.exercise.title}</h4>
            <p>{currentLessonDetail.exercise.task_description}</p>
            <textarea rows="10" class="code-editor" bind:value={exerciseCode}></textarea>
            <div class="control-group">
              <button type="button" class="btn-primary" on:click={handleRunExercise}>Run Verification Suite</button>
              <button type="button" class="btn-cool" on:click={handleToggleComplete}>
                {completedLessons[currentLessonId] ? 'Completed' : 'Mark Completed'}
              </button>
            </div>
            {#if exerciseOutput}
              <pre>{exerciseOutput}</pre>
            {/if}
          </div>
        {/if}
      {/if}
    </section>
  {:else if activeView === 'dblab'}
    <section class="surface-card">
      <h2>Isolated Read-Only SQL Playground & {dbScenarios.length} Production Scenarios</h2>
      <textarea rows="4" class="code-editor" bind:value={sqlQuery}></textarea>
      <button type="button" class="btn-primary" on:click={handleRunSQL}>Execute SQL & EXPLAIN QUERY PLAN</button>
      {#if sqlError}
        <pre>{sqlError}</pre>
      {/if}
      {#if sqlResult}
        <p>{sqlResult.engine} — {sqlResult.row_count} rows ({sqlResult.execution_ms}ms)</p>
        {#if sqlResult.query_plan?.length}
          <pre>{sqlResult.query_plan.join('\n')}</pre>
        {/if}
      {/if}
    </section>
  {:else if activeView === 'projects'}
    <section class="surface-card">
      <h2>{caseStudies.length} Production Case Studies & 8 Capstone Milestones</h2>
      <ul>
        {#each caseStudies as cs}
          <li><strong>#{cs.number} {cs.title}</strong> — {cs.architecture} ({cs.database})</li>
        {/each}
      </ul>
    </section>
  {:else if activeView === 'practice'}
    <section class="surface-card">
      <h2>Practice Center, {quizzes.length} Diagnostic Quizzes & Persistent Notes</h2>
      <textarea rows="5" class="code-editor" bind:value={personalNotes}></textarea>
      <button type="button" class="btn-primary" on:click={handleSaveNote}>Save Note to Database</button>
    </section>
  {:else}
    <section class="surface-card">
      <h2>Go Backend Academy — Zero to Production Engineering ({dbStatusLabel})</h2>
      <p>
        Loaded <strong>{levels.length}</strong> curriculum levels, <strong>{lessons.length}</strong> progressive lessons
        (Stages A–J), <strong>{caseStudies.length}</strong> production case studies, and
        <strong>{dbScenarios.length}</strong> database scenarios from the live SQL database.
      </p>
      <div class="control-group">
        <button type="button" class="btn-primary" on:click={() => (activeView = 'curriculum')}>
          Start Stage A–J Curriculum
        </button>
        <button type="button" class="btn-cool" on:click={() => (activeView = 'dblab')}>
          Open SQL Playground
        </button>
      </div>
    </section>
  {/if}
</WorkspaceLayout>
