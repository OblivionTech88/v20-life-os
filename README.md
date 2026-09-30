# V20 — Life OS

Base funcional da Fase 1: React, TypeScript, Vite, Tailwind, convenção shadcn/ui, Supabase Auth, workspace/família, categorias, Emoji Mart, PWA, navegação mobile e Quick Add.

## Rodar localmente

1. Copie `.env.example` para `.env.local` e informe a URL e a chave anônima/publicável do Supabase.
2. Aplique `supabase/migrations/20260929210000_phase_1_foundation.sql` usando o CLI ou SQL Editor do projeto.
3. Execute `npm install` e `npm run dev`.

O primeiro login cria o workspace e insere, de forma idempotente para aquele workspace, o banco inicial de categorias e indicadores V20. Nunca use uma chave `service_role` no frontend.

## Comandos

`npm run lint` · `npm run typecheck` · `npm test` · `npm run build`

## PWA

O manifesto e o service worker são gerados por `vite-plugin-pwa`. O cache de assets permite abertura offline; a persistência/sincronização offline de mutations é uma entrega posterior, pois exige uma fila local com resolução de conflitos.
