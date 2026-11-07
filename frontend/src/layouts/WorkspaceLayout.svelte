<script lang="ts">
  export let activeView: string = 'dashboard';
  export let onNavigate: (view: string) => void;
</script>

<div class="app-root">
  <slot name="header" />
  <div class="workspace-shell">
    <slot name="sidebar" {activeView} {onNavigate} />
    <main class="main-pane">
      <slot />
    </main>
    <slot name="rightpanel" />
  </div>
</div>
