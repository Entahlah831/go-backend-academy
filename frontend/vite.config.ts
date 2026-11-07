import { defineConfig, loadEnv } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, '..', '');
  const apiPort = env.PORT || process.env.PORT || '8080';
  const apiTarget = `http://127.0.0.1:${apiPort}`;

  return {
    plugins: [svelte()],
    build: {
      // Output into a dedicated subdirectory so `vite build` never overwrites web/index.html
      outDir: '../web/svelte-dist',
      emptyOutDir: true
    },
    server: {
      port: 5173,
      proxy: {
        '/api': apiTarget,
        '/healthz': apiTarget,
        '/readyz': apiTarget
      }
    }
  };
});
