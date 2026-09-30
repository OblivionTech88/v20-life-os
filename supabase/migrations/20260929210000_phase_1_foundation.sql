-- V20 Life OS / Phase 1. Run with `supabase db push` after linking a project.
create extension if not exists "pgcrypto";

create type public.workspace_role as enum ('owner', 'admin', 'member', 'viewer');
create type public.visibility_scope as enum ('private', 'workspace');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '', avatar_url text, timezone text not null default 'America/Sao_Paulo',
  locale text not null default 'pt-BR', created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.workspaces (
  id uuid primary key default gen_random_uuid(), name text not null check (char_length(name) between 1 and 100),
  slug text not null unique check (slug ~ '^[a-z0-9-]+$'), created_by uuid not null references public.profiles(id),
  target_date date not null default date '2042-09-04', monthly_income_goal numeric(14,2) not null default 70000 check (monthly_income_goal >= 0),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.workspace_members (
  workspace_id uuid not null references public.workspaces(id) on delete cascade, user_id uuid not null references public.profiles(id) on delete cascade,
  role public.workspace_role not null default 'member', joined_at timestamptz not null default now(), primary key (workspace_id, user_id)
);
create table public.categories (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 80), emoji text not null default '📁', color text not null default '#FF6B57' check (color ~ '^#[0-9A-Fa-f]{6}$'),
  description text, parent_id uuid references public.categories(id) on delete restrict, scope text[] not null default array['global']::text[], position integer not null default 0,
  is_system boolean not null default false, is_active boolean not null default true, created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), archived_at timestamptz,
  unique (workspace_id, parent_id, name)
);
create table public.user_preferences (
  user_id uuid primary key references public.profiles(id) on delete cascade, workspace_id uuid references public.workspaces(id) on delete set null,
  dashboard_quote text not null default 'O que eu fizer hoje precisa aproximar minha família da vida que queremos viver.', onboarding_completed boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.emoji_favorites (
  user_id uuid not null references public.profiles(id) on delete cascade, emoji text not null, created_at timestamptz not null default now(), primary key(user_id, emoji)
);
create table public.tasks (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade, category_id uuid references public.categories(id) on delete set null,
  title text not null check (char_length(title) between 1 and 300), emoji text not null default '✅', color text not null default '#FF6B57', status text not null default 'open' check(status in ('open','done','archived')),
  due_at timestamptz, visibility public.visibility_scope not null default 'private', completed_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.inbox_entries (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade, kind text not null check(kind in ('goal','note','transaction','achievement','family_moment','workout','reflection','event','habit')),
  title text not null check (char_length(title) between 1 and 300), emoji text not null, payload jsonb not null default '{}'::jsonb, visibility public.visibility_scope not null default 'private',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.workspace_metrics (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  key text not null check(key in ('debt','emergency_fund','oblivion_revenue','mrr','net_worth')), label text not null, emoji text not null, current_value numeric(14,2) not null default 0,
  target_value numeric(14,2), currency text not null default 'BRL', updated_at timestamptz not null default now(), unique(workspace_id, key)
);

create or replace function public.set_updated_at() returns trigger language plpgsql security invoker set search_path = public as $$ begin new.updated_at = now(); return new; end; $$;
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$ begin insert into public.profiles(id, full_name) values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name','')); insert into public.user_preferences(user_id) values (new.id); return new; end; $$;
create or replace function public.add_workspace_owner() returns trigger language plpgsql security definer set search_path = public as $$ begin insert into public.workspace_members(workspace_id, user_id, role) values(new.id, new.created_by, 'owner'); return new; end; $$;
revoke execute on function public.handle_new_user() from public;
revoke execute on function public.add_workspace_owner() from public;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
create trigger on_workspace_created after insert on public.workspaces for each row execute procedure public.add_workspace_owner();
create trigger profiles_updated before update on public.profiles for each row execute procedure public.set_updated_at();
create trigger workspaces_updated before update on public.workspaces for each row execute procedure public.set_updated_at();
create trigger categories_updated before update on public.categories for each row execute procedure public.set_updated_at();
create trigger preferences_updated before update on public.user_preferences for each row execute procedure public.set_updated_at();
create trigger tasks_updated before update on public.tasks for each row execute procedure public.set_updated_at();
create trigger inbox_updated before update on public.inbox_entries for each row execute procedure public.set_updated_at();

alter table public.profiles enable row level security; alter table public.workspaces enable row level security; alter table public.workspace_members enable row level security; alter table public.categories enable row level security; alter table public.user_preferences enable row level security; alter table public.emoji_favorites enable row level security; alter table public.tasks enable row level security; alter table public.inbox_entries enable row level security; alter table public.workspace_metrics enable row level security;
grant select, insert, update, delete on public.profiles, public.workspaces, public.workspace_members, public.categories, public.user_preferences, public.emoji_favorites, public.tasks, public.inbox_entries, public.workspace_metrics to authenticated;
create policy "profile_self" on public.profiles for all to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create policy "workspace_member_read" on public.workspaces for select to authenticated using (exists (select 1 from public.workspace_members m where m.workspace_id=id and m.user_id=(select auth.uid())));
create policy "workspace_create" on public.workspaces for insert to authenticated with check ((select auth.uid())=created_by);
create policy "workspace_owner_update" on public.workspaces for update to authenticated using (exists(select 1 from public.workspace_members m where m.workspace_id=id and m.user_id=(select auth.uid()) and m.role='owner')) with check (exists(select 1 from public.workspace_members m where m.workspace_id=id and m.user_id=(select auth.uid()) and m.role='owner'));
create policy "membership_self_read" on public.workspace_members for select to authenticated using (user_id=(select auth.uid()));
create policy "membership_owner_manage" on public.workspace_members for all to authenticated using (exists(select 1 from public.workspace_members self where self.workspace_id=workspace_id and self.user_id=(select auth.uid()) and self.role='owner')) with check (exists(select 1 from public.workspace_members self where self.workspace_id=workspace_id and self.user_id=(select auth.uid()) and self.role='owner'));
create policy "preferences_self" on public.user_preferences for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
create policy "emoji_self" on public.emoji_favorites for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
create policy "category_read" on public.categories for select to authenticated using (exists(select 1 from public.workspace_members m where m.workspace_id=workspace_id and m.user_id=(select auth.uid())));
create policy "category_write" on public.categories for all to authenticated using (exists(select 1 from public.workspace_members m where m.workspace_id=workspace_id and m.user_id=(select auth.uid()) and m.role in ('owner','admin','member'))) with check (created_by=(select auth.uid()) and exists(select 1 from public.workspace_members m where m.workspace_id=workspace_id and m.user_id=(select auth.uid()) and m.role in ('owner','admin','member')));
create policy "tasks_read" on public.tasks for select to authenticated using (user_id=(select auth.uid()) or (visibility='workspace' and exists(select 1 from public.workspace_members m where m.workspace_id=workspace_id and m.user_id=(select auth.uid()))));
create policy "tasks_write" on public.tasks for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()) and exists(select 1 from public.workspace_members m where m.workspace_id=workspace_id and m.user_id=(select auth.uid())));
create policy "inbox_read" on public.inbox_entries for select to authenticated using (user_id=(select auth.uid()) or (visibility='workspace' and exists(select 1 from public.workspace_members m where m.workspace_id=workspace_id and m.user_id=(select auth.uid()))));
create policy "inbox_write" on public.inbox_entries for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()) and exists(select 1 from public.workspace_members m where m.workspace_id=workspace_id and m.user_id=(select auth.uid())));
create policy "metric_read" on public.workspace_metrics for select to authenticated using (exists(select 1 from public.workspace_members m where m.workspace_id=workspace_id and m.user_id=(select auth.uid())));
create policy "metric_write" on public.workspace_metrics for all to authenticated using (exists(select 1 from public.workspace_members m where m.workspace_id=workspace_id and m.user_id=(select auth.uid()) and m.role in ('owner','admin'))) with check (exists(select 1 from public.workspace_members m where m.workspace_id=workspace_id and m.user_id=(select auth.uid()) and m.role in ('owner','admin')));
