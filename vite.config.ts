import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import FullReload from 'vite-plugin-full-reload';
import Vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [
    RubyPlugin(),
    FullReload(["config/routes.rb", "app/views/**/*"], {delay: 200}),
    Vue()
  ],
  server: {
    host: '0.0.0.0',
    port: 5173
  }
})