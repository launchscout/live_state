import { defineConfig } from 'vite'

// https://vitejs.dev/config/
export default defineConfig({
  mode: 'development',
  build: {
    lib: {
      fileName: 'app.js',
      entry: 'js/index.ts',
      formats: ['es']
    },
    outDir: '../priv/static/assets/js'
  }
})
