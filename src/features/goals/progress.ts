export type ProgressGoal = { progress_method: 'manual'|'value'|'tasks'|'subgoals'; manual_progress: number; initial_value: number|null; current_value: number|null; target_value: number|null; direction: 'increase'|'decrease'; task_total?: number; task_done?: number; child_progress?: number[] }
export const clamp = (n: number) => Math.min(100, Math.max(0, n))
export function calculateGoalProgress(goal: ProgressGoal): number {
 if (goal.progress_method === 'manual') return clamp(goal.manual_progress)
 if (goal.progress_method === 'tasks') return goal.task_total ? clamp((goal.task_done ?? 0) / goal.task_total * 100) : 0
 if (goal.progress_method === 'subgoals') return goal.child_progress?.length ? clamp(goal.child_progress.reduce((a,b)=>a+b,0)/goal.child_progress.length) : 0
 const initial=goal.initial_value ?? 0, current=goal.current_value ?? initial, target=goal.target_value
 if (target === null || target === initial) return 0
 return clamp(goal.direction === 'decrease' ? (initial-current)/(initial-target)*100 : (current-initial)/(target-initial)*100)
}
export function calculateV20Progress(goals: Array<ProgressGoal & { parent_id?: string|null; vision_item_id?: string|null }>) { const roots=goals.filter(g=>!g.parent_id && Boolean(g.vision_item_id)); return roots.length ? roots.reduce((sum,g)=>sum+calculateGoalProgress(g),0)/roots.length : 0 }
export function isGoalAtRisk(progress:number,targetDate:string|undefined) { if(!targetDate) return false; const start=new Date(new Date().getFullYear(),0,1).getTime(), end=new Date(targetDate).getTime(); if(end<=start)return progress<100; return progress < ((Date.now()-start)/(end-start))*100 }
