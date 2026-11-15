-- =====================================================================
-- Sunrise update 4: chat extras
--   * "Delivered" and "Read" under your last message
--   * a red number of unread messages, and Mute
--   * editing your messages ("Edited")
--   * "Alex is typing…" (a private live channel for each chat)
-- =====================================================================
-- Run this ONCE in Supabase: SQL Editor -> New query -> paste -> Run.
-- It does NOT delete anything. (It's already part of supabase-setup.sql,
-- so new projects don't need it.) Running it twice is safe.
-- =====================================================================

-- When each person last received the chat's messages (for "Delivered"),
-- and whether they muted it
alter table chat_members add column if not exists last_delivered_at timestamptz not null default now();
alter table chat_members add column if not exists muted boolean not null default false;
-- When a message was last edited (null = never)
alter table messages add column if not exists edited_at timestamptz;

-- "My device has got this chat's messages"
create or replace function mark_delivered(chat uuid) returns void
language sql security definer set search_path = public as $$
  update chat_members set last_delivered_at = now()
  where chat_id = chat and user_id = auth.uid();
$$;

-- Mute or unmute a chat (only for you)
create or replace function set_muted(chat uuid, mute boolean) returns void
language sql security definer set search_path = public as $$
  update chat_members set muted = mute
  where chat_id = chat and user_id = auth.uid();
$$;

-- Edit one of your own messages (only its words, and only while you can
-- still post in that chat)
create or replace function edit_message(message bigint, new_body text) returns void
language plpgsql security definer set search_path = public as $$
declare
  m messages;
begin
  select * into m from messages where id = message;
  if not found or m.sender is distinct from auth.uid() then
    raise exception 'You can only edit your own messages.';
  end if;
  if m.body = '' then raise exception 'You can only edit messages with words.'; end if;
  if char_length(trim(new_body)) not between 1 and 2000 then
    raise exception 'Messages are 1 to 2000 characters.';
  end if;
  if not can_post(m.chat_id) then raise exception 'You can''t send messages in this chat.'; end if;
  update messages set body = trim(new_body), edited_at = now() where id = message;
end $$;

-- Your chats, newest first, now with: how many unread messages, whether
-- you muted it, and when each person last got and read it
drop function if exists my_chats();
create function my_chats()
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
        'last_read_at', m2.last_read_at, 'last_delivered_at', m2.last_delivered_at)
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

-- "Alex is typing…": each chat gets a private live channel, "chat:<id>".
-- Only people in the chat can listen or send.
create or replace function chat_of_topic(topic text) returns uuid
language sql immutable set search_path = public as $$
  select case
    when topic ~ '^chat:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    then substring(topic from 6)::uuid
  end;
$$;
drop policy if exists "drawing editors can listen" on realtime.messages;
drop policy if exists "drawing editors can send" on realtime.messages;
drop policy if exists "live channel listeners" on realtime.messages;
drop policy if exists "live channel senders" on realtime.messages;
create policy "live channel listeners" on realtime.messages
  for select to authenticated
  using (
    can_edit_drawing(drawing_of_topic(realtime.topic()))
    or is_chat_member(chat_of_topic(realtime.topic()))
  );
create policy "live channel senders" on realtime.messages
  for insert to authenticated
  with check (
    can_edit_drawing(drawing_of_topic(realtime.topic()))
    or is_chat_member(chat_of_topic(realtime.topic()))
  );

revoke execute on function mark_delivered(uuid), set_muted(uuid, boolean),
  edit_message(bigint, text), my_chats() from public, anon;
grant execute on function mark_delivered(uuid), set_muted(uuid, boolean),
  edit_message(bigint, text), my_chats() to authenticated;
