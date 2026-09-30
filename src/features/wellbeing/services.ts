import { supabase } from '../../lib/supabase'

type Id = string
type Payload = Record<string, unknown>

function client() { if (!supabase) throw new Error('Supabase não configurado') ; return supabase }
async function requireData<T>(request: PromiseLike<{ data: T; error: { message: string } | null }>) { const { data, error } = await request; if (error) throw new Error(error.message); return data }

export const habitService = {
  list: (workspaceId: Id) => requireData(client().from('habits').select('*').eq('workspace_id', workspaceId).eq('is_archived', false).order('created_at')),
  create: (input: Payload) => requireData(client().from('habits').insert(input).select().single()),
  archive: (id: Id) => requireData(client().from('habits').update({ is_archived: true, deleted_at: new Date().toISOString() }).eq('id', id).select().single()),
}
export const habitEntryService = {
  upsert: (input: Payload) => requireData(client().from('habit_entries').upsert(input, { onConflict: 'habit_id,entry_date' }).select().single()),
  today: (workspaceId: Id) => requireData(client().from('habit_entries').select('*').eq('workspace_id', workspaceId).eq('entry_date', new Date().toISOString().slice(0, 10))),
}
export const healthService = {
  list: (workspaceId: Id) => requireData(client().from('health_entries').select('*').eq('workspace_id', workspaceId).is('deleted_at', null).order('entry_date', { ascending: false })),
  create: (input: Payload) => requireData(client().from('health_entries').insert(input).select().single()),
}
export const workoutService = {
  list: (workspaceId: Id) => requireData(client().from('workouts').select('*').eq('workspace_id', workspaceId).is('deleted_at', null).order('date', { ascending: false })),
  create: (input: Payload) => requireData(client().from('workouts').insert(input).select().single()),
}
export const familyProfileService = {
  list: (workspaceId: Id) => requireData(client().from('family_profiles').select('*').eq('workspace_id', workspaceId).eq('is_archived', false).order('name')),
  create: (input: Payload) => requireData(client().from('family_profiles').insert(input).select().single()),
  archive: (id: Id) => requireData(client().from('family_profiles').update({ is_archived: true, archived_at: new Date().toISOString() }).eq('id', id).select().single()),
}
export const familyEntryService = {
  list: (workspaceId: Id) => requireData(client().from('family_entries').select('*, family_entry_members(*)').eq('workspace_id', workspaceId).is('deleted_at', null).order('date', { ascending: false })),
  create: async (input: Payload, memberIds: Id[]) => { const entry = await requireData(client().from('family_entries').insert(input).select().single()); if (memberIds.length) await requireData(client().from('family_entry_members').insert(memberIds.map(family_profile_id => ({ workspace_id: input.workspace_id, family_entry_id: entry.id, family_profile_id })))); return entry },
}
export const experienceService = {
  list: (workspaceId: Id) => requireData(client().from('experiences').select('*, experience_members(*)').eq('workspace_id', workspaceId).is('deleted_at', null).order('target_date')),
  create: (input: Payload) => requireData(client().from('experiences').insert(input).select().single()),
  complete: (id: Id, input: Payload) => requireData(client().from('experiences').update({ ...input, status: 'completed', completed_at: new Date().toISOString(), completed_date: new Date().toISOString().slice(0, 10) }).eq('id', id).select().single()),
  favorite: (id: Id, is_favorite: boolean) => requireData(client().from('experiences').update({ is_favorite }).eq('id', id).select().single()),
}
export const v20MeetingService = {
  create: (input: Payload) => requireData(client().from('v20_meetings').insert({ ...input, status: 'in_progress', started_at: new Date().toISOString() }).select().single()),
  get: (id: Id) => requireData(client().from('v20_meetings').select('*, v20_meeting_steps(*), v20_meeting_decisions(*)').eq('id', id).single()),
  saveStep: async (meetingId: Id, workspaceId: Id, stepKey: string, stepNumber: number, payload: Payload) => { const step = await requireData(client().from('v20_meeting_steps').upsert({ meeting_id: meetingId, workspace_id: workspaceId, step_key: stepKey, step_number: stepNumber, payload, saved_at: new Date().toISOString() }, { onConflict: 'meeting_id,step_key' }).select().single()); await requireData(client().from('v20_meetings').update({ current_step: stepNumber, last_saved_at: new Date().toISOString() }).eq('id', meetingId).select().single()); return step },
  complete: (id: Id) => requireData(client().from('v20_meetings').update({ status: 'completed', completed_at: new Date().toISOString(), current_step: 6 }).eq('id', id).select().single()),
  decision: (input: Payload) => requireData(client().from('v20_meeting_decisions').insert(input).select().single()),
}
export const specialDateService = { list: (workspaceId: Id) => requireData(client().from('special_dates').select('*').eq('workspace_id', workspaceId).order('date')), create: (input: Payload) => requireData(client().from('special_dates').insert(input).select().single()) }
