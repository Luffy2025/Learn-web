-- =====================================================================
-- Sunrise update 5: green (online) and grey (offline) dots
-- =====================================================================
-- Run this ONCE in Supabase: SQL Editor -> New query -> paste -> Run.
-- It does NOT delete anything. (It's already part of supabase-setup.sql,
-- so new projects don't need it.) Running it twice is safe.
--
-- While Sunrise is open, it tells the server "I'm here" every minute.
-- Someone counts as online if they did that in the last 2 minutes.
-- Only your FRIENDS can see if you're online.
-- =====================================================================

alter table profiles add column if not exists last_seen timestamptz;

-- Keep last_seen private: logged-in people can read every part of a
-- profile EXCEPT last_seen. (Friends find out through the functions below)
revoke select on profiles from authenticated, anon;
grant select (id, username, display_name, avatar, created_at) on profiles to authenticated;

-- "I'm here" (every minute while Sunrise is open)
create or replace function i_am_online() returns void
language sql security definer set search_path = public as $$
  update profiles set last_seen = now() where id = auth.uid();
$$;
-- "I'm leaving" (when you log out or close Sunrise)
create or replace function i_am_offline() returns void
language sql security definer set search_path = public as $$
  update profiles set last_seen = null where id = auth.uid();
$$;

-- Is this person online? Only answers for your friends (otherwise null)
create or replace function friend_online(person uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select case
    when person = auth.uid() then true
    when are_friends(auth.uid(), person) then
      coalesce((select last_seen > now() - interval '2 minutes' from profiles where id = person), false)
  end;
$$;

-- Your friends and requests, now with "online" (only for friends)
drop function if exists my_friends();
create function my_friends()
returns table (id uuid, username text, display_name text, state text, online boolean)
language sql stable security definer set search_path = public as $$
  select p.id, p.username, p.display_name,
    case
      when f.status = 'accepted' then 'friends'
      when f.addressee = auth.uid() then 'incoming'
      else 'outgoing'
    end,
    case
      when f.status = 'accepted' then coalesce(p.last_seen > now() - interval '2 minutes', false)
    end
  from friendships f
  join profiles p
    on p.id = case when f.requester = auth.uid() then f.addressee else f.requester end
  where auth.uid() in (f.requester, f.addressee)
  order by p.username;
$$;

-- Your chats: each person now also has "online" (only for your friends)
create or replace function my_chats()
returns table (
  id uuid, is_group boolean, name text, created_by uuid, members jsonb,
  last_body text, last_kind text, last_sender uuid, last_at timestamptz,
  last_read_at timestamptz, last_delivered_at timestamptz,
  unread_count bigint, muted boolean
)
language sql stable security invoker set search_path = public as $$
  select c.id, c.is_group, c.name, c.created_by,
    (select jsonb_agg(jsonb_build_object(
        'id', p.id, 'username', p.username, 'display_name', p.display_name,
        'last_read_at', m2.last_read_at, 'last_delivered_at', m2.last_delivered_at,
        'online', friend_online(p.id))
        order by p.username)
     from chat_members m2 join profiles p on p.id = m2.user_id
     where m2.chat_id = c.id),
    last.body, last.file_kind, last.sender, last.created_at,
    me.last_read_at, me.last_delivered_at,
    (select count(*) from messages x
     where x.chat_id = c.id and x.sender <> auth.uid() and x.created_at > me.last_read_at),
    me.muted
  from chat_members me
  join chats c on c.id = me.chat_id
  left join lateral (
    select body, file_kind, sender, created_at from messages
    where chat_id = c.id order by id desc limit 1
  ) last on true
  where me.user_id = auth.uid()
  order by coalesce(last.created_at, c.created_at) desc;
$$;

revoke execute on function i_am_online(), i_am_offline(), friend_online(uuid), my_friends(), my_chats()
  from public, anon;
grant execute on function i_am_online(), i_am_offline(), friend_online(uuid), my_friends(), my_chats()
  to authenticated;
