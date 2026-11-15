-- =====================================================================
-- Sunrise online database setup
-- =====================================================================
-- Run this in your Supabase project:
--   Supabase dashboard -> SQL Editor -> New query -> paste all of this -> Run
-- (Running it again is safe: it starts by removing the old Sunrise tables.
--  WARNING: that also deletes every drawing, friend and message in them.
--  Accounts (logins) are kept, but their usernames are lost, so after
--  running it again, delete the old accounts in Authentication -> Users.)
--
-- How the safety works:
--   * Logins (passwords) are handled by Supabase Auth. Passwords are stored
--     scrambled (bcrypt) on Supabase's side.
--   * Every table has "Row Level Security" (RLS) turned on. That means the
--     database itself checks every read and write against the rules
--     ("policies") below, using the logged-in person's id (auth.uid()).
--     Even someone who changes Sunrise's code in their browser can only do
--     what these rules allow.
--   * Things that touch more than one person (making a chat, adding a friend,
--     sharing a drawing) go through functions below that check the rules first.
--   * Chat photos and videos are kept in a private storage "bucket". Only the
--     people in a chat can see its files.
--   * Live drawing together uses private channels: only people the drawing is
--     shared with can join.
-- =====================================================================

-- ----- Start fresh -----
drop trigger if exists on_auth_user_created on auth.users;
drop policy if exists "chat members see chat files" on storage.objects;
drop policy if exists "chat members add chat files" on storage.objects;
drop policy if exists "delete chat files" on storage.objects;
drop policy if exists "drawing editors can listen" on realtime.messages;
drop policy if exists "drawing editors can send" on realtime.messages;
drop table if exists file_receipts cascade;
drop table if exists messages cascade;
drop table if exists chat_members cascade;
drop table if exists chats cascade;
drop table if exists friendships cascade;
drop table if exists blocks cascade;
drop table if exists nicknames cascade;
drop table if exists drawing_members cascade;
drop table if exists drawings cascade;
drop table if exists profiles cascade;
drop function if exists handle_new_user cascade;
drop function if exists username_available cascade;
drop function if exists are_friends cascade;
drop function if exists is_blocked_between cascade;
drop function if exists is_chat_member cascade;
drop function if exists can_post cascade;
drop function if exists can_clear_chat cascade;
drop function if exists chat_of_file cascade;
drop function if exists send_friend_request cascade;
drop function if exists my_friends cascade;
drop function if exists block_user cascade;
drop function if exists my_blocked cascade;
drop function if exists start_direct_chat cascade;
drop function if exists create_group_chat cascade;
drop function if exists add_to_group cascade;
drop function if exists leave_group cascade;
drop function if exists delete_chat cascade;
drop function if exists my_chats cascade;
drop function if exists mark_read cascade;
drop function if exists can_edit_drawing cascade;
drop function if exists drawing_of_topic cascade;
drop function if exists share_drawing cascade;
drop function if exists answer_share cascade;
drop function if exists my_inbox cascade;
drop function if exists delete_my_account cascade;
drop function if exists set_updated_at cascade;
drop function if exists slow_down_messages cascade;
drop function if exists file_delivered cascade;
drop function if exists file_received cascade;
drop function if exists pending_uploads cascade;
drop function if exists limit_drawings cascade;
drop function if exists mark_delivered cascade;
drop function if exists set_muted cascade;
drop function if exists edit_message cascade;
drop function if exists chat_of_topic cascade;
drop function if exists i_am_online cascade;
drop function if exists i_am_offline cascade;
drop function if exists friend_online cascade;
drop function if exists limit_chats cascade;
drop policy if exists "live channel listeners" on realtime.messages;
drop policy if exists "live channel senders" on realtime.messages;

-- =====================================================================
-- Profiles: the public part of an account (username, name and picture).
-- Emails stay private inside Supabase Auth and are NOT in here.
-- =====================================================================
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  -- lowercase, so "Sam" and "sam" are the same account
  username text not null unique check (username ~ '^[a-z0-9_-]{3,20}$'),
  -- how it was typed, like "Sam_W"
  display_name text not null check (char_length(display_name) between 1 and 30),
  -- profile picture: a small picture written as text ("data:image/...")
  avatar text check (
    avatar is null or (avatar like 'data:image/%' and octet_length(avatar) < 100000)
  ),
  created_at timestamptz not null default now()
);
alter table profiles enable row level security;

-- Anyone logged in can see usernames and pictures (needed to add friends)
create policy "logged in people can see profiles" on profiles
  for select to authenticated using (true);
-- You can only change your own name and picture. Usernames can't change.
create policy "change your own profile" on profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
revoke update on profiles from authenticated, anon;
grant update (display_name, avatar) on profiles to authenticated;

-- When someone signs up, make their profile from the username they picked
create function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, username, display_name)
  values (
    new.id,
    lower(new.raw_user_meta_data ->> 'username'),
    left(coalesce(new.raw_user_meta_data ->> 'username', 'user'), 30)
  );
  return new;
end $$;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- Is a username free? (Asked before signing up, so we can say "taken")
create function username_available(name text) returns boolean
language sql stable security definer set search_path = public as $$
  select not exists (select 1 from profiles where username = lower(name));
$$;
grant execute on function username_available(text) to anon, authenticated;

-- =====================================================================
-- Drawings: the owner, and anyone they've shared it with (who said yes),
-- can see and change it. Only the owner can delete it.
-- =====================================================================
create table drawings (
  id uuid primary key,
  owner uuid not null default auth.uid() references profiles (id) on delete cascade,
  title text not null default 'Untitled drawing' check (char_length(title) between 1 and 60),
  state jsonb not null,               -- the drawing and its items (like an Undo snapshot)
  pictures jsonb not null default '{}', -- its photos and stickers
  thumbnail text,                     -- the small picture for the home page
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- about 30 MB at most per drawing, so one drawing can't fill the database
  check (pg_column_size(state) + pg_column_size(pictures) < 30000000)
);
create index drawings_owner on drawings (owner, updated_at desc);
alter table drawings enable row level security;

-- Who a drawing is shared with. "pending" until they say yes in their inbox
create table drawing_members (
  drawing_id uuid not null references drawings (id) on delete cascade,
  user_id uuid not null references profiles (id) on delete cascade,
  invited_by uuid references profiles (id) on delete set null,
  status text not null default 'pending' check (status in ('pending', 'accepted')),
  created_at timestamptz not null default now(),
  primary key (drawing_id, user_id)
);
create index drawing_members_user on drawing_members (user_id);
alter table drawing_members enable row level security;

-- Can you see and change this drawing? (You own it, or said yes to sharing)
create function can_edit_drawing(drawing uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from drawings where id = drawing and owner = auth.uid())
    or exists (
      select 1 from drawing_members
      where drawing_id = drawing and user_id = auth.uid() and status = 'accepted'
    );
$$;

create policy "see drawings you can edit" on drawings
  for select to authenticated using (can_edit_drawing(id));
create policy "add your own drawings" on drawings
  for insert to authenticated with check (owner = auth.uid());
create policy "change drawings you can edit" on drawings
  for update to authenticated using (can_edit_drawing(id)) with check (can_edit_drawing(id));
-- Only these parts can be changed (not the owner or the id)
revoke update on drawings from authenticated, anon;
grant update (title, state, pictures, thumbnail) on drawings to authenticated;
create policy "only the owner deletes" on drawings
  for delete to authenticated using (owner = auth.uid());

-- Sharing: you see your own invites, and who else is in drawings you can edit
create policy "see sharing" on drawing_members
  for select to authenticated using (user_id = auth.uid() or can_edit_drawing(drawing_id));
-- Leave a shared drawing, or (owner) stop sharing with someone
create policy "leave or remove" on drawing_members
  for delete to authenticated using (
    user_id = auth.uid()
    or exists (select 1 from drawings where id = drawing_id and owner = auth.uid())
  );
-- (Inviting and answering go through share_drawing and answer_share below)

-- The server's clock sets "updated_at", not the device's
create function set_updated_at() returns trigger
language plpgsql set search_path = public as $$
begin
  new.updated_at = now();
  new.created_at = old.created_at;
  return new;
end $$;
create trigger drawings_updated
  before update on drawings
  for each row execute function set_updated_at();

-- =====================================================================
-- Friends: a request from one person to another. "pending" until the
-- other person accepts it.
-- =====================================================================
create table friendships (
  requester uuid not null references profiles (id) on delete cascade,
  addressee uuid not null references profiles (id) on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'accepted')),
  created_at timestamptz not null default now(),
  primary key (requester, addressee),
  check (requester <> addressee)
);
-- Only one friendship between two people, whoever asked first
create unique index friendships_pair on friendships
  (least(requester, addressee), greatest(requester, addressee));
alter table friendships enable row level security;

-- You can only see friendships you're part of
create policy "see your friendships" on friendships
  for select to authenticated using (auth.uid() in (requester, addressee));
-- Only the person who was asked can accept
create policy "accept requests sent to you" on friendships
  for update to authenticated
  using (addressee = auth.uid())
  with check (addressee = auth.uid() and status = 'accepted');
revoke update on friendships from authenticated, anon;
grant update (status) on friendships to authenticated;
-- Either person can end it (decline, cancel or unfriend)
create policy "end your friendships" on friendships
  for delete to authenticated using (auth.uid() in (requester, addressee));
-- (No insert rule: requests are sent with send_friend_request below)

-- Blocking: the blocked person can't send you friend requests, and
-- blocking ends your friendship (so they can't message you either).
-- Nobody is told they were blocked.
create table blocks (
  blocker uuid not null references profiles (id) on delete cascade,
  blocked uuid not null references profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker, blocked),
  check (blocker <> blocked)
);
alter table blocks enable row level security;
create policy "see who you blocked" on blocks
  for select to authenticated using (blocker = auth.uid());
create policy "unblock" on blocks
  for delete to authenticated using (blocker = auth.uid());

-- Nicknames: your own private name for someone. Only you see it.
create table nicknames (
  owner uuid not null default auth.uid() references profiles (id) on delete cascade,
  target uuid not null references profiles (id) on delete cascade,
  nickname text not null check (char_length(nickname) between 1 and 30),
  primary key (owner, target)
);
alter table nicknames enable row level security;
create policy "your own nicknames" on nicknames
  for all to authenticated using (owner = auth.uid()) with check (owner = auth.uid());

create function are_friends(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from friendships
    where status = 'accepted'
      and ((requester = a and addressee = b) or (requester = b and addressee = a))
  );
$$;

create function is_blocked_between(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from blocks
    where (blocker = a and blocked = b) or (blocker = b and blocked = a)
  );
$$;

-- Send a friend request by username. Gives back what happened:
--   'sent', 'accepted' (they had already asked you), 'already',
--   'not-found', 'yourself', 'blocked' (you blocked them) or 'too-many'
create function send_friend_request(name text) returns text
language plpgsql security definer set search_path = public as $$
declare
  me uuid := auth.uid();
  them uuid;
  existing friendships;
begin
  if me is null then raise exception 'Not logged in'; end if;
  select id into them from profiles where username = lower(trim(name));
  if them is null then return 'not-found'; end if;
  if them = me then return 'yourself'; end if;
  if exists (select 1 from blocks where blocker = me and blocked = them) then
    return 'blocked';
  end if;
  -- They blocked you: look the same as a username that doesn't exist
  if exists (select 1 from blocks where blocker = them and blocked = me) then
    return 'not-found';
  end if;

  select * into existing from friendships
  where (requester = me and addressee = them) or (requester = them and addressee = me);
  if found then
    if existing.status = 'pending' and existing.requester = them then
      update friendships set status = 'accepted'
      where requester = them and addressee = me;
      return 'accepted';
    end if;
    return 'already';
  end if;

  -- Stop spamming: at most 30 requests an hour
  if (select count(*) from friendships
      where requester = me and created_at > now() - interval '1 hour') >= 30 then
    return 'too-many';
  end if;

  insert into friendships (requester, addressee) values (me, them);
  return 'sent';
end $$;

-- Your friends and requests:
--   state = 'friends', 'incoming' (they asked you) or 'outgoing' (you asked them)
create function my_friends()
returns table (id uuid, username text, display_name text, state text)
language sql stable security definer set search_path = public as $$
  select p.id, p.username, p.display_name,
    case
      when f.status = 'accepted' then 'friends'
      when f.addressee = auth.uid() then 'incoming'
      else 'outgoing'
    end
  from friendships f
  join profiles p
    on p.id = case when f.requester = auth.uid() then f.addressee else f.requester end
  where auth.uid() in (f.requester, f.addressee)
  order by p.username;
$$;

-- Block someone (this also ends your friendship)
create function block_user(person uuid) returns void
language plpgsql security definer set search_path = public as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'Not logged in'; end if;
  if person = me then raise exception 'You can''t block yourself.'; end if;
  insert into blocks (blocker, blocked) values (me, person) on conflict do nothing;
  delete from friendships
  where (requester = me and addressee = person) or (requester = person and addressee = me);
end $$;

-- The people you blocked
create function my_blocked()
returns table (id uuid, username text, display_name text)
language sql stable security definer set search_path = public as $$
  select p.id, p.username, p.display_name
  from blocks b join profiles p on p.id = b.blocked
  where b.blocker = auth.uid()
  order by p.username;
$$;

-- =====================================================================
-- Chats: a 1-to-1 chat or a group. Only members can see a chat and its
-- messages. Only friends can be put in a chat.
-- =====================================================================
create table chats (
  id uuid primary key default gen_random_uuid(),
  is_group boolean not null default false,
  name text check (char_length(name) <= 40),
  -- set null: a group carries on if the person who made it deletes their account
  created_by uuid references profiles (id) on delete set null,
  created_at timestamptz not null default now()
);
alter table chats enable row level security;

create table chat_members (
  chat_id uuid not null references chats (id) on delete cascade,
  user_id uuid not null references profiles (id) on delete cascade,
  joined_at timestamptz not null default now(),
  last_read_at timestamptz not null default now(), -- for "unread" dots
  primary key (chat_id, user_id)
);
create index chat_members_user on chat_members (user_id);
alter table chat_members enable row level security;

-- Deleting a chat deletes all its messages too ("on delete cascade")
create table messages (
  id bigint generated always as identity primary key,
  chat_id uuid not null references chats (id) on delete cascade,
  sender uuid not null default auth.uid() references profiles (id) on delete cascade,
  body text not null default '' check (char_length(body) <= 2000),
  -- a photo or video: where it is in the "chat-files" storage
  file_path text,
  file_kind text check (file_kind in ('image', 'video')),
  created_at timestamptz not null default now(),
  -- a message needs words, or a file (or both)
  check (body <> '' or file_path is not null),
  -- a file needs to say what kind it is
  check ((file_path is null) = (file_kind is null)),
  -- a chat's files must be in that chat's own folder
  check (file_path is null or (
    file_path like chat_id::text || '/%' and file_path !~ '\.\.'
  ))
);
create index messages_chat on messages (chat_id, id desc);
alter table messages enable row level security;

-- "security definer" lets these look at chat_members without the rules
-- on chat_members asking the same question again (which would loop forever)
create function is_chat_member(chat uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from chat_members where chat_id = chat and user_id = auth.uid()
  );
$$;

-- Can you post in this chat? You must be in it. In a 1-to-1 chat you must
-- also still be friends (so unfriending or blocking stops messages).
create function can_post(chat uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select is_chat_member(chat) and (
    (select is_group from chats where id = chat)
    or exists (
      select 1 from chat_members m
      where m.chat_id = chat and m.user_id <> auth.uid()
        and are_friends(auth.uid(), m.user_id)
    )
  );
$$;

-- Can you delete ALL of this chat's files? (Before deleting the whole chat:
-- either person in a 1-to-1 chat, the person who made a group, or the last
-- person left in a group)
create function can_clear_chat(chat uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select is_chat_member(chat) and (
    not (select is_group from chats where id = chat)
    or (select created_by from chats where id = chat) = auth.uid()
    or (select count(*) from chat_members where chat_id = chat) = 1
  );
$$;

create policy "members see their chats" on chats
  for select to authenticated using (is_chat_member(id));
create policy "members see who's in their chats" on chat_members
  for select to authenticated using (is_chat_member(chat_id));
-- (Leaving and marking as read go through leave_group and mark_read below)
revoke update, delete on chat_members from authenticated, anon;

-- Messages are deleted after 7 days. This hides them the moment they're 7 days
-- old (the hourly job at the bottom deletes them for good)
create policy "members read messages" on messages
  for select to authenticated
  using (is_chat_member(chat_id) and created_at > now() - interval '7 days');
create policy "members send messages as themselves" on messages
  for insert to authenticated with check (sender = auth.uid() and can_post(chat_id));
-- Unsend: delete your own messages (for everyone)
create policy "unsend your own messages" on messages
  for delete to authenticated using (sender = auth.uid());
-- Messages can't be changed (no rule for that = not allowed)
revoke update on messages from authenticated, anon;

-- Stop spamming: at most 10 messages in 10 seconds
create function slow_down_messages() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from messages
      where sender = new.sender and created_at > now() - interval '10 seconds') >= 10 then
    raise exception 'Too many messages. Wait a few seconds.';
  end if;
  new.created_at = now(); -- the server's clock, not the device's
  return new;
end $$;
create trigger messages_slow_down
  before insert on messages
  for each row execute function slow_down_messages();

-- Open the 1-to-1 chat with a friend (makes it the first time)
create function start_direct_chat(friend uuid) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  me uuid := auth.uid();
  chat uuid;
begin
  if me is null then raise exception 'Not logged in'; end if;
  if not are_friends(me, friend) then
    raise exception 'You can only chat with friends.';
  end if;
  select c.id into chat from chats c
  where not c.is_group
    and exists (select 1 from chat_members where chat_id = c.id and user_id = me)
    and exists (select 1 from chat_members where chat_id = c.id and user_id = friend)
  limit 1;
  if chat is null then
    insert into chats (is_group, created_by) values (false, me) returning id into chat;
    insert into chat_members (chat_id, user_id) values (chat, me), (chat, friend);
  end if;
  return chat;
end $$;

-- Make a group chat with some of your friends
create function create_group_chat(chat_name text, friend_ids uuid[]) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  me uuid := auth.uid();
  chat uuid;
  friend uuid;
begin
  if me is null then raise exception 'Not logged in'; end if;
  if char_length(trim(chat_name)) not between 1 and 40 then
    raise exception 'Group names are 1 to 40 characters.';
  end if;
  if coalesce(array_length(friend_ids, 1), 0) not between 1 and 49 then
    raise exception 'Pick 1 to 49 friends.';
  end if;
  foreach friend in array friend_ids loop
    if not are_friends(me, friend) then
      raise exception 'You can only add your friends.';
    end if;
  end loop;
  insert into chats (is_group, name, created_by)
  values (true, trim(chat_name), me) returning id into chat;
  insert into chat_members (chat_id, user_id)
  select chat, x from (select me as x union select unnest(friend_ids)) people;
  return chat;
end $$;

-- Add one of your friends to a group you're in
create function add_to_group(chat uuid, friend uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not is_chat_member(chat) or not (select is_group from chats where id = chat) then
    raise exception 'You are not in that group.';
  end if;
  if not are_friends(auth.uid(), friend) then
    raise exception 'You can only add your friends.';
  end if;
  if (select count(*) from chat_members where chat_id = chat) >= 50 then
    raise exception 'Groups can have at most 50 people.';
  end if;
  insert into chat_members (chat_id, user_id) values (chat, friend)
  on conflict do nothing;
end $$;

-- Leave a group. When the last person leaves, the group and all its
-- messages are deleted.
create function leave_group(chat uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not is_chat_member(chat) or not (select is_group from chats where id = chat) then
    raise exception 'You are not in that group.';
  end if;
  delete from chat_members where chat_id = chat and user_id = auth.uid();
  if not exists (select 1 from chat_members where chat_id = chat) then
    delete from chats where id = chat; -- its messages go too
  end if;
end $$;

-- Delete a chat and all its messages, for everyone in it.
-- 1-to-1 chats: either person. Groups: only the person who made it.
create function delete_chat(chat uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not is_chat_member(chat) then raise exception 'You are not in that chat.'; end if;
  if (select is_group from chats where id = chat)
     and (select created_by from chats where id = chat) is distinct from auth.uid() then
    raise exception 'Only the person who made the group can delete it.';
  end if;
  delete from chats where id = chat; -- its members and messages go too
end $$;

-- Your chats, newest first, with who's in them and the last message.
-- "security invoker" = the rules above still apply
create function my_chats()
returns table (
  id uuid, is_group boolean, name text, created_by uuid, members jsonb,
  last_body text, last_kind text, last_sender uuid, last_at timestamptz,
  last_read_at timestamptz
)
language sql stable security invoker set search_path = public as $$
  select c.id, c.is_group, c.name, c.created_by,
    (select jsonb_agg(jsonb_build_object(
        'id', p.id, 'username', p.username, 'display_name', p.display_name)
        order by p.username)
     from chat_members m2 join profiles p on p.id = m2.user_id
     where m2.chat_id = c.id),
    last.body, last.file_kind, last.sender, last.created_at, me.last_read_at
  from chat_members me
  join chats c on c.id = me.chat_id
  left join lateral (
    select body, file_kind, sender, created_at from messages
    where chat_id = c.id order by id desc limit 1
  ) last on true
  where me.user_id = auth.uid()
  order by coalesce(last.created_at, c.created_at) desc;
$$;

-- You've read a chat up to now (for the "unread" dots)
create function mark_read(chat uuid) returns void
language sql security definer set search_path = public as $$
  update chat_members set last_read_at = now()
  where chat_id = chat and user_id = auth.uid();
$$;

-- =====================================================================
-- Sharing drawings with friends
-- =====================================================================
-- Share a drawing you own with some friends. They get it in their inbox.
create function share_drawing(drawing uuid, friend_ids uuid[]) returns void
language plpgsql security definer set search_path = public as $$
declare
  me uuid := auth.uid();
  friend uuid;
begin
  if not exists (select 1 from drawings where id = drawing and owner = me) then
    raise exception 'Only the owner can share this drawing.';
  end if;
  foreach friend in array coalesce(friend_ids, '{}') loop
    if not are_friends(me, friend) then
      raise exception 'You can only share with your friends.';
    end if;
    insert into drawing_members (drawing_id, user_id, invited_by)
    values (drawing, friend, me) on conflict do nothing;
  end loop;
end $$;

-- Say yes or no to a drawing in your inbox
create function answer_share(drawing uuid, accept boolean) returns void
language plpgsql security definer set search_path = public as $$
begin
  if accept then
    update drawing_members set status = 'accepted'
    where drawing_id = drawing and user_id = auth.uid();
  else
    delete from drawing_members where drawing_id = drawing and user_id = auth.uid();
  end if;
end $$;

-- Your inbox: drawings friends want to share with you
create function my_inbox()
returns table (
  drawing_id uuid, title text, thumbnail text,
  from_id uuid, from_name text, from_username text, sent_at timestamptz
)
language sql stable security definer set search_path = public as $$
  select d.id, d.title, d.thumbnail, p.id, p.display_name, p.username, m.created_at
  from drawing_members m
  join drawings d on d.id = m.drawing_id
  left join profiles p on p.id = m.invited_by
  where m.user_id = auth.uid() and m.status = 'pending'
  order by m.created_at desc;
$$;

-- =====================================================================
-- Chat photos and videos: a private storage "bucket". Each chat has its
-- own folder, named after the chat. At most 5 MB a file.
-- =====================================================================
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'chat-files', 'chat-files', false, 5242880, -- 5 MB
  array['image/jpeg', 'image/png', 'image/gif', 'image/webp',
        'video/mp4', 'video/webm', 'video/quicktime']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Which chat a file belongs to (its folder name), or nothing if odd
create function chat_of_file(path text) returns uuid
language sql immutable set search_path = public as $$
  select case
    when split_part(path, '/', 1) ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    then split_part(path, '/', 1)::uuid
  end;
$$;

create policy "chat members see chat files" on storage.objects
  for select to authenticated
  using (bucket_id = 'chat-files' and is_chat_member(chat_of_file(name)));
create policy "chat members add chat files" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'chat-files' and can_post(chat_of_file(name)));
-- Your own files, or every file when you're allowed to delete the whole chat
create policy "delete chat files" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'chat-files' and (
      (owner_id = auth.uid()::text and is_chat_member(chat_of_file(name)))
      or can_clear_chat(chat_of_file(name))
    )
  );

-- =====================================================================
-- Drawing together, live: private channels called "drawing:<id>".
-- Only people who can edit that drawing can listen or send.
-- =====================================================================
create function drawing_of_topic(topic text) returns uuid
language sql immutable set search_path = public as $$
  select case
    when topic ~ '^drawing:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    then substring(topic from 9)::uuid
  end;
$$;

create policy "drawing editors can listen" on realtime.messages
  for select to authenticated
  using (can_edit_drawing(drawing_of_topic(realtime.topic())));
create policy "drawing editors can send" on realtime.messages
  for insert to authenticated
  with check (can_edit_drawing(drawing_of_topic(realtime.topic())));

-- =====================================================================
-- Delete your account and everything in it (drawings, friends, messages)
-- =====================================================================
create function delete_my_account() returns void
language plpgsql security definer set search_path = public, auth as $$
begin
  if auth.uid() is null then raise exception 'Not logged in'; end if;
  delete from auth.users where id = auth.uid();
end $$;

-- Only logged-in people can use these (not visitors who aren't logged in)
revoke execute on function are_friends(uuid, uuid), is_blocked_between(uuid, uuid),
  is_chat_member(uuid), can_post(uuid), can_clear_chat(uuid),
  send_friend_request(text), my_friends(), block_user(uuid), my_blocked(),
  start_direct_chat(uuid), create_group_chat(text, uuid[]), add_to_group(uuid, uuid),
  leave_group(uuid), delete_chat(uuid), my_chats(), mark_read(uuid),
  can_edit_drawing(uuid), share_drawing(uuid, uuid[]), answer_share(uuid, boolean),
  my_inbox(), delete_my_account()
  from public, anon;
grant execute on function are_friends(uuid, uuid), is_blocked_between(uuid, uuid),
  is_chat_member(uuid), can_post(uuid), can_clear_chat(uuid),
  send_friend_request(text), my_friends(), block_user(uuid), my_blocked(),
  start_direct_chat(uuid), create_group_chat(text, uuid[]), add_to_group(uuid, uuid),
  leave_group(uuid), delete_chat(uuid), my_chats(), mark_read(uuid),
  can_edit_drawing(uuid), share_drawing(uuid, uuid[]), answer_share(uuid, boolean),
  my_inbox(), delete_my_account()
  to authenticated;
revoke execute on function handle_new_user() from public, anon, authenticated;
revoke execute on function slow_down_messages() from public, anon, authenticated;

-- =====================================================================
-- Live updates: new messages, unsent messages, friend requests, chats and
-- inbox shares show up straight away (the rules above still decide who
-- gets told about what)
-- =====================================================================
alter publication supabase_realtime
  add table messages, friendships, chat_members, drawing_members;

-- =====================================================================
-- Every hour, delete chat messages older than 7 days.
-- pg_cron is Supabase's built-in timer for jobs like this.
-- (Their photos and videos are deleted by Sunrise itself, when people log
--  in, because the database isn't allowed to delete stored files.)
-- =====================================================================
create extension if not exists pg_cron;
select cron.unschedule(jobid) from cron.job where jobname = 'drawlab-delete-old-messages';
select cron.schedule(
  'drawlab-delete-old-messages',
  '0 * * * *', -- at the start of every hour
  $$ delete from public.messages where created_at < now() - interval '7 days' $$
);

-- =====================================================================
-- Chat photos and videos: deleted from the server once everyone in the
-- chat has them. Photos up to 1 MB, videos up to 5 MB, 50 MB a week each.
-- (The same as supabase-update-2-files.sql)
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

-- =====================================================================
-- Each person can own up to 20 drawings (shared ones don't count).
-- (The same as supabase-update-3-drawing-limit.sql)
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

-- =====================================================================
-- Chat extras: Delivered/Read, unread numbers, Mute, editing messages,
-- and "typing…". (The same as supabase-update-4-chat-extras.sql)
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

-- =====================================================================
-- Green (online) and grey (offline) dots. Only friends can see them.
-- (The same as supabase-update-5-online.sql)
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

-- =====================================================================
-- Each person can be in up to 10 chats (1-to-1 and groups together).
-- (The same as supabase-update-6-chat-limit.sql)
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
