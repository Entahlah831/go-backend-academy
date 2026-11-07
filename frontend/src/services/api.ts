import type { AnalysisReport, RecommendationItem } from '../types/domain';

export interface ReadyStatus {
  status: string;
  db_driver: string;
  db_persistent: boolean;
  ai_provider: string;
}

export async function fetchReadyStatus(): Promise<ReadyStatus | null> {
  try {
    const res = await fetch('/readyz');
    if (res.ok) return await res.json();
  } catch {
    // Offline fallback
  }
  return null;
}

export async function fetchCurriculum(): Promise<{ levels: any[]; modules: any[]; lessons: any[] }> {
  const res = await fetch('/api/v1/curriculum');
  if (!res.ok) throw new Error('Failed to load curriculum');
  return await res.json();
}

export async function fetchLessonDetail(id: string): Promise<any> {
  const res = await fetch(`/api/v1/lessons/${encodeURIComponent(id)}`);
  if (!res.ok) throw new Error(`Failed to load lesson ${id}`);
  return await res.json();
}

export async function verifyExercise(
  exerciseId: string,
  code: string,
  requiredTokens: string[] = []
): Promise<{ attempt_id: string; passed: boolean; diagnostics: string; missing?: string[] }> {
  const res = await fetch('/api/v1/exercises/verify', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      user_id: 'usr_local_default',
      exercise_id: exerciseId,
      code,
      required_tokens: requiredTokens
    })
  });
  if (!res.ok) throw new Error('Exercise verification request failed');
  return await res.json();
}

export async function executeSQLPlayground(
  query: string,
  explain = true
): Promise<{ columns: string[]; rows: string[][]; row_count: number; query_plan?: string[]; execution_ms: number; engine: string }> {
  const res = await fetch('/api/v1/sql-playground/execute', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, explain })
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.detail || 'SQL execution failed');
  return data;
}

export async function fetchCaseStudies(): Promise<any[]> {
  const res = await fetch('/api/v1/case-studies');
  if (!res.ok) return [];
  const data = await res.json();
  return data.case_studies || [];
}

export async function fetchDBScenarios(): Promise<any[]> {
  const res = await fetch('/api/v1/db-scenarios');
  if (!res.ok) return [];
  const data = await res.json();
  return data.db_scenarios || [];
}

export async function fetchQuizzes(): Promise<any[]> {
  const res = await fetch('/api/v1/quizzes');
  if (!res.ok) return [];
  const data = await res.json();
  return data.quizzes || [];
}

export async function analyzeGoCode(code: string, fallbackFn: (c: string) => AnalysisReport): Promise<AnalysisReport> {
  try {
    const res = await fetch('/api/v1/diagnostics/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ code })
    });
    if (res.ok) {
      return await res.json();
    }
  } catch {
    // Offline / standalone browser mode: execute deterministic local analyzer
  }
  return fallbackFn(code);
}

export async function fetchUserProgress(userId = 'usr_local_default'): Promise<Record<string, string>> {
  try {
    const res = await fetch(`/api/v1/progress?user_id=${encodeURIComponent(userId)}`);
    if (res.ok) {
      const data = await res.json();
      return data.progress || {};
    }
  } catch {
    // Offline fallback
  }
  return {};
}

export async function syncLessonProgress(lessonId: string, status: string): Promise<void> {
  try {
    await fetch('/api/v1/progress', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user_id: 'usr_local_default', lesson_id: lessonId, status })
    });
  } catch {
    // Persisted locally in SafeStore
  }
}

export async function saveUserNote(lessonId: string, content: string): Promise<void> {
  try {
    await fetch('/api/v1/notes', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user_id: 'usr_local_default', lesson_id: lessonId, content })
    });
  } catch {
    // Persisted locally in SafeStore
  }
}

export async function fetchRecommendations(
  snapshot: Record<string, unknown>,
  fallbackFn: () => RecommendationItem[]
): Promise<RecommendationItem[]> {
  try {
    const res = await fetch('/api/v1/recommendations', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(snapshot)
    });
    if (res.ok) {
      const data = await res.json();
      return data.recommendations || [];
    }
  } catch {
    // Offline fallback
  }
  return fallbackFn();
}
