export type FindingClassification =
  | 'confirmed_diagnostic'
  | 'potential_issue'
  | 'educational_heuristic'
  | 'no_finding_detected';

export interface DiagnosticFinding {
  rule_id: string;
  classification: FindingClassification;
  severity: 'critical' | 'high' | 'medium' | 'info';
  line?: number;
  title: string;
  description: string;
  why_it_matters: string;
  suggested_correction: string;
  corrected_example?: string;
  related_lesson_id: string;
  reference_url: string;
}

export interface AnalysisReport {
  offline_mode: boolean;
  toolchain_executed: boolean;
  toolchain_output?: string;
  summary_status: string;
  findings: DiagnosticFinding[];
  static_analysis_limitations: string;
  optional_ai_status: string;
  analyzed_at: string;
}

export interface RecommendationItem {
  id: string;
  what_to_learn: string;
  why_it_matters: string;
  prerequisites: string[];
  expected_learning_outcome: string;
  suggested_exercise: string;
  target_lesson_id: string;
  trigger_reason: string;
}
