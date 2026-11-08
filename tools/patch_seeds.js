const fs = require('fs');
const path = require('path');

const mapping = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'lesson_order_map.json'), 'utf8'));
const mapById = {};
for (const m of mapping) {
  mapById[m.id] = m;
}

const upsertRules = [
  {
    table: 'curriculum_levels',
    pk: 'id',
    set: 'level_number = EXCLUDED.level_number, slug = EXCLUDED.slug, title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, estimated_hours = EXCLUDED.estimated_hours'
  },
  {
    table: 'modules',
    pk: 'id',
    set: 'level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary'
  },
  {
    table: 'lessons',
    pk: 'id',
    set: 'module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified'
  },
  {
    table: 'lesson_sections',
    pk: 'id',
    set: 'lesson_id = EXCLUDED.lesson_id, section_type = EXCLUDED.section_type, title = EXCLUDED.title, body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning'
  },
  {
    table: 'lesson_references',
    pk: 'id',
    set: 'lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, url = EXCLUDED.url, doc_version = EXCLUDED.doc_version, ref_type = EXCLUDED.ref_type, last_verified = EXCLUDED.last_verified'
  },
  {
    table: 'exercises',
    pk: 'id',
    set: 'lesson_id = EXCLUDED.lesson_id, title = EXCLUDED.title, task_description = EXCLUDED.task_description, starter_code = EXCLUDED.starter_code, expected_output = EXCLUDED.expected_output, solution_code = EXCLUDED.solution_code, solution_explanation = EXCLUDED.solution_explanation, additional_challenge = EXCLUDED.additional_challenge'
  },
  {
    table: 'exercise_test_cases',
    pk: 'id',
    set: 'exercise_id = EXCLUDED.exercise_id, order_index = EXCLUDED.order_index, description = EXCLUDED.description, required_pattern = EXCLUDED.required_pattern'
  },
  {
    table: 'exercise_rules',
    pk: 'id',
    set: 'exercise_id = EXCLUDED.exercise_id, rule_type = EXCLUDED.rule_type, target = EXCLUDED.target, message = EXCLUDED.message'
  },
  {
    table: 'exercise_tests',
    pk: 'exercise_id',
    set: 'package_name = EXCLUDED.package_name, test_filename = EXCLUDED.test_filename, test_code = EXCLUDED.test_code'
  },
  {
    table: 'quizzes',
    pk: 'id',
    set: 'level_id = EXCLUDED.level_id, title = EXCLUDED.title'
  },
  {
    table: 'quiz_questions',
    pk: 'id',
    set: 'quiz_id = EXCLUDED.quiz_id, order_index = EXCLUDED.order_index, question_text = EXCLUDED.question_text, options_json = EXCLUDED.options_json, correct_index = EXCLUDED.correct_index, explanation = EXCLUDED.explanation'
  },
  {
    table: 'case_studies',
    pk: 'id',
    set: 'study_number = EXCLUDED.study_number, slug = EXCLUDED.slug, title = EXCLUDED.title, difficulty = EXCLUDED.difficulty, architecture_style = EXCLUDED.architecture_style, recommended_db = EXCLUDED.recommended_db, rationale = EXCLUDED.rationale'
  },
  {
    table: 'case_study_steps',
    pk: 'id',
    set: 'case_study_id = EXCLUDED.case_study_id, step_number = EXCLUDED.step_number, section_key = EXCLUDED.section_key, title = EXCLUDED.title, content_text = EXCLUDED.content_text'
  },
  {
    table: 'database_scenarios',
    pk: 'id',
    set: 'scenario_number = EXCLUDED.scenario_number, title = EXCLUDED.title, recommended_stack = EXCLUDED.recommended_stack, rationale = EXCLUDED.rationale, engines_comparison_json = EXCLUDED.engines_comparison_json'
  },
  {
    table: 'diagnostic_rules',
    pk: 'rule_id',
    set: 'category = EXCLUDED.category, classification = EXCLUDED.classification, severity = EXCLUDED.severity, title = EXCLUDED.title, description = EXCLUDED.description, why_it_matters = EXCLUDED.why_it_matters, suggested_fix = EXCLUDED.suggested_fix, related_lesson_id = EXCLUDED.related_lesson_id, doc_url = EXCLUDED.doc_url'
  }
];

function convertSeeds(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');
  const outLines = [];

  for (let rawLine of lines) {
    let line = rawLine.trimEnd();
    if (line.startsWith('INSERT INTO lessons ')) {
      const prefixMatch = line.match(/^INSERT INTO lessons \(([^)]+)\) VALUES \('([^']+)',\s*'([^']+)',\s*(\d+),\s*(\d+),\s*(.*)$/);
      if (prefixMatch) {
        const cols = prefixMatch[1];
        const id = prefixMatch[2];
        const modId = prefixMatch[3];
        const rest = prefixMatch[6];
        const info = mapById[id];
        if (info) {
          let restWithoutDisp = rest;
          if (cols.includes('display_no')) {
            restWithoutDisp = rest.replace(/^'[^']*',\s*/, '');
          }
          const restClean = restWithoutDisp.replace(/\s*ON CONFLICT.*$/, '');
          line = "INSERT INTO lessons (id, module_id, level_id, order_index, display_no, slug, title, summary, difficulty, last_verified) VALUES ('" +
            id + "', '" + modId + "', " + info.level + ", " + info.order + ", '" + info.disp + "', " +
            restClean + " ON CONFLICT (id) DO UPDATE SET module_id = EXCLUDED.module_id, level_id = EXCLUDED.level_id, order_index = EXCLUDED.order_index, display_no = EXCLUDED.display_no, slug = EXCLUDED.slug, title = EXCLUDED.title, summary = EXCLUDED.summary, difficulty = EXCLUDED.difficulty, last_verified = EXCLUDED.last_verified;";
        }
      }
    } else {
      for (const r of upsertRules) {
        if (r.table === 'lessons') continue;
        if (line.startsWith('INSERT INTO ' + r.table + ' ')) {
          if (line.includes('ON CONFLICT DO NOTHING;')) {
            line = line.replace('ON CONFLICT DO NOTHING;', 'ON CONFLICT (' + r.pk + ') DO UPDATE SET ' + r.set + ';');
          }
          break;
        }
      }
    }
    outLines.push(line);
  }

  fs.writeFileSync(filePath, outLines.join('\n') + '\n', 'utf8');
  console.log('Converted:', filePath);
}

convertSeeds(path.join(__dirname, '..', 'seed', 'sqlite', '001_seed_data.sql'));
convertSeeds(path.join(__dirname, '..', 'seed', 'sqlite', '002_beginner_stages_seed.sql'));
convertSeeds(path.join(__dirname, '..', 'seed', 'postgres', '001_seed_data.sql'));
convertSeeds(path.join(__dirname, '..', 'seed', 'postgres', '002_beginner_stages_seed.sql'));
