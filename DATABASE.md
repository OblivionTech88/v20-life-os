# Banco de dados — Fase 1

| Entidade | Responsabilidade |
| --- | --- |
| `profiles` | Perfil derivado de `auth.users` |
| `workspaces` / `workspace_members` | Família, membro e papel |
| `categories` | Taxonomia hierárquica, emoji, cor e escopos |
| `user_preferences` / `emoji_favorites` | Preferências pessoais e emojis |
| `tasks` / `inbox_entries` | Execução diária e captura rápida |
| `workspace_metrics` | Placar inicial V20 |

Todas as tabelas públicas têm RLS habilitado. O usuário só lê o próprio perfil/preferências, seus itens privados e itens do workspace compartilhados. Dados de workspace só são expostos quando existe membership. Alterações de métricas requerem `owner` ou `admin`; não existe policy baseada em metadados editáveis do usuário.

A migration em `supabase/migrations/20260929210000_phase_1_foundation.sql` é a fonte de verdade. O seed é feito pelo onboarding uma única vez ao criar o workspace, por isso não duplica dados em reaberturas do app.

## Fase 2

`vision_items` armazena pilares; `roadmap_milestones` marcos; `goals` metas hierárquicas; `roadmap_milestone_goals` é o relacionamento N:N; e `daily_priorities` reserva as prioridades por data. Tarefas agora podem apontar para `goals`, ter agenda, duração e regra de recorrência. A migration `20260930010000_phase_2_v20_goals.sql` aplica RLS e grants específicos para todos esses dados.

## Fase 3

`income_entries` e `expense_entries` registram fluxo financeiro. A fonte de verdade das dívidas é `initial_amount - sum(debt_payments)`; a reserva é a soma de depósitos, saques e ajustes em `reserve_entries`. `investments`, `assets` e dívida calculada formam o patrimônio líquido. `business_monthly_metrics` preserva faturamento, custos, lucro, MRR e funil da Oblivion. `freedom_criteria` permite armazenar critérios verificáveis, sem recomendar saída de emprego.
