<script lang="ts">
  export let lesson: Record<string, any>;
  export let activeTier: 'beginner' | 'intermediate' | 'advanced' = 'beginner';
</script>

<article class="space-y-5">
  <header class="rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-5 space-y-2">
    <div class="text-xs font-mono text-cyan-500">{lesson.levelTitle} • {lesson.moduleTitle}</div>
    <h2 class="text-xl font-bold">{lesson.title}</h2>
    <p class="text-xs text-slate-500">{lesson.summary}</p>
    <pre class="p-3.5 rounded-lg bg-slate-950 text-cyan-300 text-xs font-mono overflow-x-auto">{lesson.diagram}</pre>
  </header>
  <section class="rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-5">
    <p class="text-xs leading-relaxed">{lesson.explanations[activeTier]}</p>
  </section>
</article>
