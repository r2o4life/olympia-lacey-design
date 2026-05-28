-- Parallel Paradigm OS / initial RLS policies
-- Apply via Dreamflow's Supabase module.

alter table public.inquiry_leads enable row level security;

-- Public can submit leads (anonymous insert).
create policy "inquiry_leads_insert_anyone" on public.inquiry_leads
for insert
to public
with check (true);

-- Only authenticated users can read leads.
create policy "inquiry_leads_select_authenticated" on public.inquiry_leads
for select
to authenticated
using (true);

-- Only authenticated users can manage leads.
create policy "inquiry_leads_update_authenticated" on public.inquiry_leads
for update
to authenticated
using (true)
with check (true);

create policy "inquiry_leads_delete_authenticated" on public.inquiry_leads
for delete
to authenticated
using (true);
