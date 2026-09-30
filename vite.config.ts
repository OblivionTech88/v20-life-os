import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg'],
      manifest: {
        name: 'V20 — Life OS', short_name: 'V20', description: 'Seu sistema operacional de vida.',
        theme_color: '#171012', background_color: '#171012', display: 'standalone', lang: 'pt-BR',
        icons: [{ src: 'pwa-192.svg', sizes: '192x192', type: 'image/svg+xml' }, { src: 'pwa-512.svg', sizes: '512x512', type: 'image/svg+xml' }]
      },
      workbox: { navigateFallback: '/index.html', globPatterns: ['**/*.{js,css,html,svg,png,ico}'] }
    })
  ]
})
