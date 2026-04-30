-- Add a reason_category column for preset reasons
ALTER TABLE public.content_reports
  ADD COLUMN IF NOT EXISTS reason_category text;

-- Add unique constraint to prevent duplicate reports per user per target
-- A user can only report the same listing or user once
ALTER TABLE public.content_reports
  ADD CONSTRAINT unique_report_per_target
  UNIQUE NULLS NOT DISTINCT (reporter_id, reported_user_id, listing_id, chat_room_id);
