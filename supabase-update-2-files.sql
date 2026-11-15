-- =====================================================================
-- Sunrise update 2: chat photos and videos
--   * are deleted from the server once everyone in the chat has them
--   * photos up to 1 MB, videos up to 5 MB
--   * each person can send up to 50 MB of them a week
-- =====================================================================
-- Run this ONCE in Supabase: SQL Editor -> New query -> paste -> Run.
-- It does NOT delete your drawings, friends, chats or accounts. (It's
-- already part of supabase-setup.sql, so new projects don't need it.)
-- Running it twice is safe.
-- =====================================================================

-- 1. No file can be bigger than 5 MB (Supabase Storage refuses it)
update storage.buckets set file_size_limit = 5242880 where id = 'chat-files';

-- 2. Remember how big each message's file was (for the weekly limit).
--    The server fills this in itself, from the real uploaded file.
alter table messages add column if not exists file_size bigint;

-- 3. "Receipts": who has received each photo or video
create table if not exists file_receipts (
  message_id bigint not null references messages (id) on delete cascade,
  user_id uuid not null references profiles (id) on delete cascade,
  primary key (message_id, user_id)
);
alter table file_receipts enable row level security;
drop policy if exists "chat members see receipts" on file_receipts;
create policy "chat members see receipts" on file_receipts
  for select to authenticated
  using (exists (select 1 from messages m where m.id = message_id));
-- (Receipts are added with file_received below)

-- Has everyone in the chat (except the sender) received this file?
create or replace function file_delivered(path text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from messages m
    where m.file_path = path
      and not exists (
        select 1 from chat_members cm
        where cm.chat_id = m.chat_id and cm.user_id <> m.sender
          and not exists (
            select 1 from file_receipts r
            where r.message_id = m.id and r.user_id = cm.user_id
          )
      )
  );
$$;

-- "I've got this photo or video now." Gives back true when everyone has
-- it, so the file can be deleted from the server.
create or replace function file_received(message bigint) returns boolean
language plpgsql security definer set search_path = public as $$
declare
  m messages;
begin
  select * into m from messages where id = message;
  if not found or m.file_path is null or m.sender = auth.uid()
     or not is_chat_member(m.chat_id) then
    return false;
  end if;
  insert into file_receipts (message_id, user_id) values (message, auth.uid())
  on conflict do nothing;
  return file_delivered(m.file_path);
end $$;

-- How many files you've uploaded that aren't in a message yet.
-- (Stops anyone uploading lots of files without sending them)
create or replace function pending_uploads() returns bigint
language sql stable security definer set search_path = public as $$
  select count(*) from storage.objects o
  where o.bucket_id = 'chat-files' and o.owner_id = auth.uid()::text
    and not exists (select 1 from messages m where m.file_path = o.name);
$$;

-- 4. Checks when a message is sent (this replaces the old spam check,
--    and keeps it)
create or replace function slow_down_messages() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  size bigint;
  owner text;
begin
  -- Stop spamming: at most 10 messages in 10 seconds
  if (select count(*) from messages
      where sender = new.sender and created_at > now() - interval '10 seconds') >= 10 then
    raise exception 'Too many messages. Wait a few seconds.';
  end if;
  new.created_at = now(); -- the server's clock, not the device's

  if new.file_path is not null then
    -- The real size of the uploaded file (not what the device says)
    select (o.metadata ->> 'size')::bigint, o.owner_id into size, owner
    from storage.objects o
    where o.bucket_id = 'chat-files' and o.name = new.file_path;
    if size is null or owner is distinct from new.sender::text then
      raise exception 'Upload the photo or video first.';
    end if;
    if new.file_kind = 'image' and size > 1048576 then
      raise exception 'Photos can be up to 1 MB.';
    end if;
    if size > 5242880 then
      raise exception 'Videos can be up to 5 MB.';
    end if;
    -- At most 50 MB of photos and videos in any 7 days
    if (select coalesce(sum(file_size), 0) from messages
        where sender = new.sender and created_at > now() - interval '7 days') + size
       > 52428800 then
      raise exception 'You can send up to 50 MB of photos and videos a week. Try again in a few days.';
    end if;
    new.file_size = size;
  end if;
  return new;
end $$;
revoke execute on function slow_down_messages() from public, anon, authenticated;

-- 5. Storage rules
drop policy if exists "chat members add chat files" on storage.objects;
create policy "chat members add chat files" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'chat-files'
    and can_post(chat_of_file(name))
    and pending_uploads() < 5
  );
-- Delete: your own files, every file when you could delete the whole
-- chat, or any file in your chat that everyone has received
drop policy if exists "delete chat files" on storage.objects;
create policy "delete chat files" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'chat-files' and (
      (owner_id = auth.uid()::text and is_chat_member(chat_of_file(name)))
      or can_clear_chat(chat_of_file(name))
      or (is_chat_member(chat_of_file(name)) and file_delivered(name))
    )
  );

revoke execute on function file_delivered(text), file_received(bigint), pending_uploads()
  from public, anon;
grant execute on function file_delivered(text), file_received(bigint), pending_uploads()
  to authenticated;
