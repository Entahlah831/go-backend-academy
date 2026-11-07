<script lang="ts">
  export let activeView: string = 'dashboard';
  export let onSelectView: (view: string) => void;

  const navGroups = [
    {
      label: 'Home',
      items: [{ id: 'dashboard', label: '1. Dashboard', meta: 'Overview' }]
    },
    {
      label: 'Learn',
      items: [
        { id: 'roadmap', label: '2. Learning Roadmap', meta: 'L0 to L10' },
        { id: 'curriculum', label: '3. Curriculum Lessons', meta: '24 Lessons' }
      ]
    },
    {
      label: 'Interactive Labs',
      items: [
        { id: 'dblab', label: '4. Database & SQL Lab', meta: '7 DBs, 10 Labs' },
        { id: 'apilab', label: '5. API & HTTP Lab', meta: 'REST Sim' },
        { id: 'playground', label: '6. Go Code Playground', meta: 'Sandbox' },
        { id: 'concurrencylab', label: '7. Concurrency Lab', meta: 'GMP & Locks' },
        { id: 'archlab', label: '8. Architecture Lab', meta: '5 Patterns' }
      ]
    },
    {
      label: 'Engineering Practice',
      items: [
        { id: 'diagnostics', label: '9. Code Review & Diagnostics', meta: 'Offline' },
        { id: 'projects', label: '10. Real-World Projects', meta: '14 Specs' },
        { id: 'practice', label: '11. Practice Center', meta: 'Quiz & Cards' }
      ]
    }
  ];
</script>

<aside class="sidebar-pane" aria-label="Academy Workspace Navigation">
  <nav class="sidebar-inner" aria-label="Primary Navigation">
    {#each navGroups as group}
      <div class="nav-group">
        <div class="nav-group-label">{group.label}</div>
        <div class="nav-list">
          {#each group.items as item}
            <button
              type="button"
              on:click={() => onSelectView(item.id)}
              class="nav-btn {activeView === item.id ? 'is-active' : ''}"
            >
              <span>{item.label}</span>
              <span class="nav-meta">{item.meta}</span>
            </button>
          {/each}
        </div>
      </div>
    {/each}
  </nav>
</aside>
