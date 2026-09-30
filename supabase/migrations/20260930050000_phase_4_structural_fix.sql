alter table public.family_profiles
  add column if not exists created_by_user_id uuid references public.profiles(id),
  add column if not exists is_archived boolean not null default false,
  add column if not exists archived_at timestamptz,
  add column if not exists updated_at timestamptz not null default now();

update public.family_profiles p
set created_by_user_id = (
  select wm.user_id from public.workspace_members wm
  where wm.workspace_id = p.workspace_id and wm.role = 'owner'
  order by wm.joined_at limit 1
)
where p.created_by_user_id is null;

create table if not exists public.family_entry_members (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  family_entry_id uuid not null references public.family_entries(id) on delete cascade,
  family_profile_id uuid not null references public.family_profiles(id) on delete cascade,
  created_at timestamptz not null default now(), unique(family_entry_id, family_profile_id)
);
create table if not exists public.experience_members (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  experience_id uuid not null references public.experiences(id) on delete cascade,
  family_profile_id uuid not null references public.family_profiles(id) on delete cascade,
  created_at timestamptz not null default now(), unique(experience_id, family_profile_id)
);
alter table public.v20_meetings add column if not exists current_step integer not null default 1 check(current_step between 1 and 6), add column if not exists started_at timestamptz, add column if not exists completed_at timestamptz, add column if not exists last_saved_at timestamptz, add column if not exists draft_payload jsonb not null default '{}'::jsonb, add column if not exists version integer not null default 1;
create table if not exists public.v20_meeting_steps (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  meeting_id uuid not null references public.v20_meetings(id) on delete cascade, step_key text not null check(step_key in ('relationship','family','finance','health','v20','next_month')),
  step_number integer not null check(step_number between 1 and 6), payload jsonb not null default '{}'::jsonb, is_completed boolean not null default false,
  saved_at timestamptz not null default now(), created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(meeting_id,step_key)
);
create table if not exists public.v20_meeting_decisions (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  meeting_id uuid not null references public.v20_meetings(id) on delete cascade, title text not null, description text, decision_type text,
  status text not null default 'open', created_entity_type text check(created_entity_type in ('goal','task','experience')), created_entity_id uuid,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
alter table public.experiences add column if not exists completed_at timestamptz, add column if not exists completed_date date, add column if not exists rating numeric check(rating is null or rating between 1 and 5), add column if not exists completion_notes text, add column if not exists special_memory text, add column if not exists is_favorite boolean not null default false, add column if not exists archived_at timestamptz;
create index if not exists family_entry_members_workspace_idx on public.family_entry_members(workspace_id);
create index if not exists family_entry_members_entry_idx on public.family_entry_members(family_entry_id);
create index if not exists family_entry_members_profile_idx on public.family_entry_members(family_profile_id);
create index if not exists experience_members_experience_idx on public.experience_members(experience_id);
create index if not exists v20_meeting_steps_meeting_idx on public.v20_meeting_steps(meeting_id);
create index if not exists v20_meeting_decisions_meeting_idx on public.v20_meeting_decisions(meeting_id);
alter table public.family_entry_members enable row level security; alter table public.experience_members enable row level security; alter table public.v20_meeting_steps enable row level security; alter table public.v20_meeting_decisions enable row level security;
grant select,insert,update,delete on public.family_entry_members,public.experience_members,public.v20_meeting_steps,public.v20_meeting_decisions to authenticated;
create policy "family_entry_members_member" on public.family_entry_members for all to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=family_entry_members.workspace_id and wm.user_id=(select auth.uid()))) with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=family_entry_members.workspace_id and wm.user_id=(select auth.uid()) and wm.role in ('owner','admin','member')));
create policy "experience_members_member" on public.experience_members for all to authenticated using(exists(select 1 from public.workspace_members wm where wm.workspace_id=experience_members.workspace_id and wm.user_id=(select auth.uid()))) with check(exists(select 1 from public.workspace_members wm where wm.workspace_id=experience_members.workspace_id and wm.user_id=(select auth.uid()) and wm.role in ('owner','admin','member')));
create policy "meeting_steps_owner" on public.v20_meeting_steps for all to authenticated using(exists(select 1 from public.v20_meetings m where m.id=meeting_id and m.user_id=(select auth.uid()))) with check(exists(select 1 from public.v20_meetings m where m.id=meeting_id and m.user_id=(select auth.uid())));
create policy "meeting_decisions_owner" on public.v20_meeting_decisions for all to authenticated using(exists(select 1 from public.v20_meetings m where m.id=meeting_id and m.user_id=(select auth.uid()))) with check(exists(select 1 from public.v20_meetings m where m.id=meeting_id and m.user_id=(select auth.uid())));
create trigger family_profiles_updated before update on public.family_profiles for each row execute procedure public.set_updated_at();
create trigger meeting_steps_updated before update on public.v20_meeting_steps for each row execute procedure public.set_updated_at();
create trigger meeting_decisions_updated before update on public.v20_meeting_decisions for each row execute procedure public.set_updated_at();
