-- =====================================================================
-- Sunrise update 3: each person can own up to 20 drawings
-- =====================================================================
-- Run this ONCE in Supabase: SQL Editor -> New query -> paste -> Run.
-- It does NOT delete anything. (It's already part of supabase-setup.sql,
-- so new projects don't need it.) Running it twice is safe.
-- Drawings friends shared with you don't count. People who already have
-- more than 20 keep them, but can't make new ones until they're under 20.
-- =====================================================================

create or replace function limit_drawings() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from drawings where owner = new.owner) >= 20 then
    raise exception 'You can have up to 20 drawings. Delete one to make a new one.';
  end if;
  return new;
end $$;
revoke execute on function limit_drawings() from public, anon, authenticated;

drop trigger if exists drawings_limit on drawings;
create trigger drawings_limit
  before insert on drawings
  for each row execute function limit_drawings();
