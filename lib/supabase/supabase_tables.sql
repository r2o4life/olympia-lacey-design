-- Parallel Paradigm OS / initial Supabase schema
-- Apply via Dreamflow's Supabase module.

create extension if not exists "uuid-ossp";

-- Captures anonymous inbound inquiries from the public site.
create table if not exists public.inquiry_leads (
  id uuid primary key default uuid_generate_v4(),
  email text not null,
  focus_areas text[] not null default '{}'::text[],
  -- Mutually-exclusive primary build surface (e.g., Website, Mobile App, etc.)
  surface text not null default '',
  -- Multi-select module/preset tags (e.g., Payments, Analytics, etc.)
  modules text[] not null default '{}'::text[],
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Keep updated_at correct.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_inquiry_leads_set_updated_at on public.inquiry_leads;
create trigger trg_inquiry_leads_set_updated_at
before update on public.inquiry_leads
for each row execute procedure public.set_updated_at();

-- RLS: allow anonymous inserts (lead capture) but deny reads.
alter table public.inquiry_leads enable row level security;

drop policy if exists "Allow anonymous lead inserts" on public.inquiry_leads;
create policy "Allow anonymous lead inserts"
on public.inquiry_leads
for insert
to anon
with check (true);
