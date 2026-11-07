<script lang="ts">
  export let scenarios: Array<Record<string, any>> = [];
  export let selectedEngine: string = 'postgresql';
  const engines = ['postgresql', 'mysql', 'mariadb', 'sqlite', 'mongodb', 'redis', 'scylladb'];
</script>

<section class="space-y-4">
  <div class="flex flex-wrap gap-2">
    {#each engines as eng}
      <button
        type="button"
        on:click={() => (selectedEngine = eng)}
        class="px-3 py-1.5 rounded-lg text-xs font-semibold border {selectedEngine === eng ? 'bg-emerald-600 text-white' : ''}"
      >
        {eng.toUpperCase()}
      </button>
    {/each}
  </div>
</section>
