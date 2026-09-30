export type Workspace = { id: string; name: string; target_date: string; monthly_income_goal: number; created_by: string }
export type Category = { id: string; name: string; emoji: string; color: string; scope: string[]; is_active: boolean; parent_id: string | null }
export type Task = { id: string; title: string; emoji: string; color: string; status: 'open' | 'done' | 'archived'; due_at: string | null }
export type Metric = { id: string; key: string; label: string; emoji: string; current_value: number; target_value: number | null }
