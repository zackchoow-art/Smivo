-- Migration 00095: Fix Backend Moderation Logs Foreign Key
-- Ensures PostgREST can join backend_moderation_logs with user_profiles

BEGIN;

-- Add foreign key from backend_moderation_logs.user_id to user_profiles.id
-- This allows the admin dashboard to fetch user info for AI logs.
-- We reference public.user_profiles(id) which itself references auth.users(id).
ALTER TABLE public.backend_moderation_logs
  DROP CONSTRAINT IF EXISTS backend_moderation_logs_user_id_fkey;

ALTER TABLE public.backend_moderation_logs
  ADD CONSTRAINT backend_moderation_logs_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES public.user_profiles(id)
    ON DELETE CASCADE;

COMMIT;
