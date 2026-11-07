<script lang="ts">
  import type { AnalysisReport } from '../types/domain';
  export let report: AnalysisReport;
  export let code: string;
  export let onRunAnalysis: () => void;
</script>

<section class="view-stack">
  <div class="surface-card">
    <div class="surface-header">
      <div class="title-stack">
        <h2>Go Code Review &amp; Diagnostics Lab</h2>
        <p>
          Deterministic code review powered by Go toolchain rules (gofmt, go vet, staticcheck) and transparent educational pattern analyzers (<code>AI_PROVIDER=none</code>). Requires zero cloud AI or API keys.
        </p>
      </div>
      <div class="control-group">
        <button type="button" on:click={onRunAnalysis} class="btn-ok">
          Run Offline Diagnostics
        </button>
      </div>
    </div>

    <div class="grid-2">
      <div class="title-stack">
        <label for="diag-svelte-editor">Go Source Snippet to Analyze:</label>
        <textarea id="diag-svelte-editor" bind:value={code} rows="16" class="code-editor" spellcheck="false"></textarea>
      </div>
      <div class="view-stack">
        {#each report.findings as f}
          <div class="surface-recessed">
            <div class="control-group" style="justify-content: space-between;">
              <span class="mono">{f.rule_id} ({f.classification})</span>
              <span class="tag-pill">{f.severity}</span>
            </div>
            <h3>{f.title}</h3>
            <p>{f.description}</p>
            <p><strong>Why it matters:</strong> {f.why_it_matters}</p>
            <p><strong>Suggested Fix:</strong> {f.suggested_correction}</p>
          </div>
        {/each}
      </div>
    </div>
  </div>
</section>
