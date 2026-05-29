-- Parallel Paradigm OS / add inquiry_leads enrichment fields
-- Adds structured inquiry fields to support the upgraded Direct Inquiry form.

alter table if exists public.inquiry_leads
  add column if not exists surface text not null default '',
  add column if not exists modules text[] not null default '{}'::text[];

-- Optional: encourage PostgREST to refresh schema cache quickly.
-- Safe even if listeners are not present.
do $$
begin
  perform pg_notify('pgrst', 'reload schema');
exception
  when others then
    -- ignore
    null;
end $$;
