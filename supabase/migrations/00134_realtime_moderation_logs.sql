-- Migration 00132: Enable Realtime for backend_moderation_logs
--
-- The FlaggedImageUrlsProvider subscribes to INSERT events on this table
-- to blur violating chat images in real-time. Without this, the Realtime
-- channel never receives any events because the table was not added to
-- the supabase_realtime publication.
--
-- REPLICA IDENTITY FULL is required so that Supabase Realtime can apply
-- RLS policies on the WAL events — without it, the newRecord payload
-- may be empty or the event may be silently dropped.

ALTER TABLE public.backend_moderation_logs
  REPLICA IDENTITY FULL;

ALTER PUBLICATION supabase_realtime
  ADD TABLE public.backend_moderation_logs;
