-- =====================================================================
-- Sunrise update 1: chat messages are deleted after 7 days
-- =====================================================================
-- Run this ONCE in Supabase: SQL Editor -> New query -> paste -> Run.
-- It does NOT delete your drawings, friends or accounts. (It's already
-- part of supabase-setup.sql, so new projects don't need it.)
--
-- How it works:
--   1. A rule hides messages as soon as they're 7 days old.
--   2. A job runs every hour and deletes them for good.
--   (Their photos and videos are deleted by Sunrise itself, when people
--    log in, because the database isn't allowed to delete stored files.)
-- =====================================================================

-- 1. Only show messages from the last 7 days
drop policy if exists "members read messages" on messages;
create policy "members read messages" on messages
  for select to authenticated
  using (is_chat_member(chat_id) and created_at > now() - interval '7 days');

-- 2. Every hour, delete messages older than 7 days.
--    pg_cron is Supabase's built-in timer for jobs like this.
create extension if not exists pg_cron;
select cron.unschedule(jobid) from cron.job where jobname = 'drawlab-delete-old-messages';
select cron.schedule(
  'drawlab-delete-old-messages',
  '0 * * * *', -- at the start of every hour
  $$ delete from public.messages where created_at < now() - interval '7 days' $$
);
