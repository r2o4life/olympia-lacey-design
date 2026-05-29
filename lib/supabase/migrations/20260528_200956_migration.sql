-- Parallel Paradigm OS / incremental migration
-- Generated for Dreamflow Supabase module.
-- Safe to apply multiple times (uses IF NOT EXISTS / drops where appropriate).

create extension if not exists "uuid-ossp";

create table if not exists public.inquiry_leads (
  id uuid primary key default uuid_generate_v4(),
  email text not null,
  focus_areas text[] not null default '{}'::text[],
  surface text not null default '',
  modules text[] not null default '{}'::text[],
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.inquiry_leads enable row level security;

drop policy if exists "Allow anonymous lead inserts" on public.inquiry_leads;
create policy "Allow anonymous lead inserts"
on public.inquiry_leads
for insert
to anon
with check (true);

drop policy if exists "inquiry_leads_insert_anyone" on public.inquiry_leads;
create policy "inquiry_leads_insert_anyone" on public.inquiry_leads
for insert
to public
with check (true);

drop policy if exists "inquiry_leads_select_authenticated" on public.inquiry_leads;
create policy "inquiry_leads_select_authenticated" on public.inquiry_leads
for select
to authenticated
using (true);

drop policy if exists "inquiry_leads_update_authenticated" on public.inquiry_leads;
create policy "inquiry_leads_update_authenticated" on public.inquiry_leads
for update
to authenticated
using (true)
with check (true);

drop policy if exists "inquiry_leads_delete_authenticated" on public.inquiry_leads;
create policy "inquiry_leads_delete_authenticated" on public.inquiry_leads
for delete
to authenticated
using (true);
