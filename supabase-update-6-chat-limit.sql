-- =====================================================================
-- Sunrise update 6: each person can be in up to 10 chats
--   (1-to-1 chats and groups together)
-- =====================================================================
-- Run this ONCE in Supabase: SQL Editor -> New query -> paste -> Run.
-- It does NOT delete anything. (It's already part of supabase-setup.sql,
-- so new projects don't need it.) Running it twice is safe.
-- People who are already in more than 10 keep them, but can't join new
-- ones until they're under 10.
-- =====================================================================

-- Checked every time someone is put in a chat (a new 1-to-1 chat, a new
-- group, or being added to a group)
create or replace function limit_chats() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from chat_members where user_id = new.user_id) >= 10 then
    if new.user_id = auth.uid() then
      raise exception 'You can have up to 10 chats. Delete or leave one first.';
    else
      raise exception '% already has 10 chats.',
        (select display_name from profiles where id = new.user_id);
    end if;
  end if;
  return new;
end $$;
revoke execute on function limit_chats() from public, anon, authenticated;

drop trigger if exists chat_members_limit on chat_members;
create trigger chat_members_limit
  before insert on chat_members
  for each row execute function limit_chats();
