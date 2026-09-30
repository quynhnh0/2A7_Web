import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [react(), tailwindcss()],
  optimizeDeps: {
    // PGlite (Postgres chạy trong trình duyệt) chỉ dùng cho chế độ Demo; Vite không được pre-bundle file WASM của nó.
    exclude: ['@electric-sql/pglite'],
  },
  build: {
    chunkSizeWarningLimit: 1200,
  },
});
