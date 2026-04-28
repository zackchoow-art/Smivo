-- Add new boolean columns for granular notification preferences
ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS email_messages BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS email_order_updates BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS push_campus_announcements BOOLEAN DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS email_campus_announcements BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS push_announcements BOOLEAN DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS email_announcements BOOLEAN DEFAULT FALSE;

-- Update the default value of the master email notification toggle to FALSE for new users
ALTER TABLE public.user_profiles
  ALTER COLUMN email_notifications_enabled SET DEFAULT FALSE;

-- (Optional) We are not updating existing rows because they will naturally default to the 
-- schema defaults when queried if they are null, or we can explicitly backfill:
UPDATE public.user_profiles 
SET 
  email_messages = FALSE, 
  email_order_updates = FALSE, 
  push_campus_announcements = TRUE,
  email_campus_announcements = FALSE,
  push_announcements = TRUE, 
  email_announcements = FALSE
WHERE email_messages IS NULL;
