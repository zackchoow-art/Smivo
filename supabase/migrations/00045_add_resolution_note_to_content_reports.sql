-- Migration 00045: Add resolution note to content reports
-- This provides a field for administrators to leave a message explaining how a user's report was handled.

ALTER TABLE public.content_reports
ADD COLUMN IF NOT EXISTS resolution_note text;
