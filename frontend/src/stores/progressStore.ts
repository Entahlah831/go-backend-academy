export interface LearningState {
  completedLessons: Record<string, boolean>;
  passedExercises: Record<string, boolean>;
  failedExercises: Record<string, number>;
  quizScores: Record<string, number>;
  triggeredRules: string[];
  bookmarks: Record<string, boolean>;
  personalNotes: string;
}

const STORAGE_PREFIX = 'gba_v2_';

export function loadState<T>(key: string, fallback: T): T {
  try {
    const raw = localStorage.getItem(STORAGE_PREFIX + key);
    return raw ? JSON.parse(raw) : fallback;
  } catch {
    return fallback;
  }
}

export function saveState<T>(key: string, value: T): void {
  try {
    localStorage.setItem(STORAGE_PREFIX + key, JSON.stringify(value));
  } catch {
    // Ignore storage quota errors in sandboxed frames
  }
}
