-- =====================================================================
-- Drawlab online database setup
-- =====================================================================
-- Run this ONCE in your Supabase project:
--   Supabase dashboard -> SQL Editor -> New query -> paste all of this -> Run
-- (Running it again is safe: it starts by removing the old Drawlab tables.
--  WARNING: that also deletes every drawing, friend and message in them.)
--
-- How the safety works:
--   * Logins (emails and passwords) are handled by Supabase Auth. Passwords
--     are stored scrambled (bcrypt) on Supabase's side; Drawlab never sees
--     them stored anywhere.
--   * Every table has "Row Level Security" (RLS) turned on. That means the
--     database itself checks every read and write against the rules
--     ("policies") below, using the logged-in person's id (auth.uid()).
--     Even someone who changes Drawlab's code in their browser can only do
--     what these rules allow.
--   * Things that touch more than one person (making a chat, adding a friend)
--     go through functions below that check the rules first.
-- =====================================================================

-- ----- Start fresh -----
drop trigger if exists on_auth_user_created on auth.users;
drop table if exists messages cascade;
drop table if exists chat_members cascade;
drop table if exists chats cascade;
drop table if exists friendships cascade;
drop table if exists drawings cascade;
drop table if exists profiles cascade;
drop function if exists handle_new_user cascade;
drop function if exists username_available cascade;
drop function if exists are_friends cascade;
drop function if exists is_chat_member cascade;
drop function if exists can_post cascade;
drop function if exists send_friend_request cascade;
drop function if exists my_friends cascade;
drop function if exists start_direct_chat cascade;
drop function if exists create_group_chat cascade;
drop function if exists add_to_group cascade;
drop function if exists my_chats cascade;
drop function if exists mark_read cascade;
drop function if exists delete_my_account cascade;
drop function if exists set_updated_at cascade;
drop function if exists slow_down_messages cascade;

-- =====================================================================
-- Profiles: the public part of an account (username and display name).
-- Emails stay private inside Supabase Auth and are NOT in here.
-- =====================================================================
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  -- lowercase, so "Sam" and "sam" are the same account
  username text not null unique check (username ~ '^[a-z0-9_-]{3,20}$'),
  -- how it was typed, like "Sam_W"
  display_name text not null check (char_length(display_name) between 1 and 30),
  created_at timestamptz not null default now()
);
alter table profiles enable row level security;

-- Anyone logged in can see usernames (needed to add friends)
create policy "logged in people can see profiles" on profiles
  for select to authenticated using (true);
-- You can only change your own display name. Usernames can't change.
create policy "change your own profile" on profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
revoke update on profiles from authenticated, anon;
grant update (display_name) on profiles to authenticated;

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
-- Drawings: only the owner can see, change or delete them.
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

create policy "see your own drawings" on drawings
  for select to authenticated using (owner = auth.uid());
create policy "add your own drawings" on drawings
  for insert to authenticated with check (owner = auth.uid());
create policy "change your own drawings" on drawings
  for update to authenticated using (owner = auth.uid()) with check (owner = auth.uid());
create policy "delete your own drawings" on drawings
  for delete to authenticated using (owner = auth.uid());

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

create function are_friends(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from friendships
    where status = 'accepted'
      and ((requester = a and addressee = b) or (requester = b and addressee = a))
  );
$$;

-- Send a friend request by username. Gives back what happened:
--   'sent', 'accepted' (they had already asked you), 'already',
--   'not-found', 'yourself' or 'too-many'
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

create table messages (
  id bigint generated always as identity primary key,
  chat_id uuid not null references chats (id) on delete cascade,
  sender uuid not null default auth.uid() references profiles (id) on delete cascade,
  body text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now()
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
-- also still be friends (so unfriending someone stops their messages).
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

create policy "members see their chats" on chats
  for select to authenticated using (is_chat_member(id));
create policy "members see who's in their chats" on chat_members
  for select to authenticated using (is_chat_member(chat_id));
-- (Marking a chat as read is done with mark_read below)
revoke update on chat_members from authenticated, anon;
-- Leave a group (1-to-1 chats can't be left, only unfriended)
create policy "leave groups" on chat_members
  for delete to authenticated
  using (user_id = auth.uid() and (select is_group from chats where id = chat_id));

create policy "members read messages" on messages
  for select to authenticated using (is_chat_member(chat_id));
create policy "members send messages as themselves" on messages
  for insert to authenticated with check (sender = auth.uid() and can_post(chat_id));
-- Messages can't be changed or deleted (no rules for that = not allowed)
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

-- Your chats, newest first, with who's in them and the last message.
-- "security invoker" = the rules above still apply
create function my_chats()
returns table (
  id uuid, is_group boolean, name text, members jsonb,
  last_body text, last_sender uuid, last_at timestamptz, last_read_at timestamptz
)
language sql stable security invoker set search_path = public as $$
  select c.id, c.is_group, c.name,
    (select jsonb_agg(jsonb_build_object(
        'id', p.id, 'username', p.username, 'display_name', p.display_name)
        order by p.username)
     from chat_members m2 join profiles p on p.id = m2.user_id
     where m2.chat_id = c.id),
    last.body, last.sender, last.created_at, me.last_read_at
  from chat_members me
  join chats c on c.id = me.chat_id
  left join lateral (
    select body, sender, created_at from messages
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

-- Delete your account and everything in it (drawings, friends, messages)
create function delete_my_account() returns void
language plpgsql security definer set search_path = public, auth as $$
begin
  if auth.uid() is null then raise exception 'Not logged in'; end if;
  delete from auth.users where id = auth.uid();
end $$;

-- Only logged-in people can use these (not visitors who aren't logged in)
revoke execute on function are_friends(uuid, uuid) from public, anon;
revoke execute on function is_chat_member(uuid) from public, anon;
revoke execute on function can_post(uuid) from public, anon;
revoke execute on function send_friend_request(text) from public, anon;
revoke execute on function my_friends() from public, anon;
revoke execute on function start_direct_chat(uuid) from public, anon;
revoke execute on function create_group_chat(text, uuid[]) from public, anon;
revoke execute on function add_to_group(uuid, uuid) from public, anon;
revoke execute on function my_chats() from public, anon;
revoke execute on function mark_read(uuid) from public, anon;
revoke execute on function delete_my_account() from public, anon;
grant execute on function are_friends(uuid, uuid), is_chat_member(uuid), can_post(uuid),
  send_friend_request(text), my_friends(), start_direct_chat(uuid),
  create_group_chat(text, uuid[]), add_to_group(uuid, uuid), my_chats(), mark_read(uuid),
  delete_my_account() to authenticated;
revoke execute on function handle_new_user() from public, anon, authenticated;
revoke execute on function slow_down_messages() from public, anon, authenticated;

-- =====================================================================
-- Live updates: new messages, friend requests and chats show up straight
-- away (the rules above still decide who gets told about what)
-- =====================================================================
alter publication supabase_realtime add table messages, friendships, chat_members;
