# Arquitetura

O frontend é uma SPA Vite, mobile-first, com React estrito e TypeScript. O Supabase é a única fonte de verdade: Auth emite a identidade e PostgreSQL protege cada linha via RLS.

`src/lib` concentra integrações; `src/components` contém componentes reutilizáveis; `src/types` mantém contratos. As telas da Fase 1 usam queries diretas, deliberadamente pequenas, para `workspaces`, `tasks` e `workspace_metrics`. A próxima fase deve extrair repositories e hooks por domínio antes de expandir módulos.

O banco cria `profiles` no evento de usuário e o owner do workspace em trigger transacional. Roles são `owner`, `admin`, `member` e `viewer`. Não há chave privilegiada no navegador.

O Quick Add grava tarefas em `tasks`; os demais registros entram em `inbox_entries` para preservarem a ação sem antecipar schemas de módulos que ainda não existem.

## Fase 2

`features/phase2` contém o shell mobile e os módulos de visão, roadmap, metas, tarefas e Home. O motor puro em `features/goals/progress.ts` calcula progresso por método e o progresso V20 usa somente metas-raiz vinculadas a pilares, evitando dupla contagem.

## Fase 3

O domínio financeiro em `features/finance` mantém cálculos puros e testáveis. A UI consulta o Supabase como fonte de verdade; componentes não derivam saldos de forma independente. Dívidas, reserva, patrimônio, resultado mensal, lucro empresarial, conversões e liberdade usam funções centrais em `calculations.ts`.
