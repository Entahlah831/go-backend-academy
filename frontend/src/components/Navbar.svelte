<script lang="ts">
  export let progressPct: number = 0;
  export let searchQuery: string = '';
  export let onToggleTheme: () => void;
</script>

<header class="app-header">
  <div class="brand-row">
    <div class="brand-mark" aria-hidden="true">Go</div>
    <div class="brand-title-wrap">
      <div class="brand-head-line">
        <h1>Go Backend Academy</h1>
        <span class="tag-pill ok">100% Offline, Go 1.23+</span>
      </div>
      <p class="brand-sub">Understand, Experiment, Implement, Debug, Compare, Optimize, Apply</p>
    </div>
  </div>
  <div class="search-wrap">
    <input
      type="search"
      bind:value={searchQuery}
      aria-label="Search lessons, case studies, and database scenarios"
      placeholder="Search 24 lessons, 14 case studies, MVCC, SSRF, Outbox..."
    />
  </div>
  <div class="header-controls">
    <div class="progress-pill">
      <span>Progress:</span>
      <span class="num">{progressPct}%</span>
    </div>
    <button type="button" on:click={onToggleTheme} class="btn-ghost" aria-label="Toggle Theme">Theme</button>
  </div>
</header>
