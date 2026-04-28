-- ============================================================
-- Smivo — Push Notification User Preferences
-- ============================================================

ALTER TABLE public.user_profiles 
  ADD COLUMN IF NOT EXISTS onesignal_player_id text,
  ADD COLUMN IF NOT EXISTS push_notifications_enabled boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS push_messages boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS push_order_updates boolean NOT NULL DEFAULT true;

-- Index for fast lookup when sending push
CREATE INDEX IF NOT EXISTS idx_user_profiles_onesignal 
  ON public.user_profiles(onesignal_player_id) 
  WHERE onesignal_player_id IS NOT NULL;
