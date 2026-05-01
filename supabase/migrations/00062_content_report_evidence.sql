-- Migration 00062: Add evidence fields to content_reports
-- Allows storing selected chat messages and surrounding context as frozen evidence.

ALTER TABLE public.content_reports
  ADD COLUMN IF NOT EXISTS selected_message_ids uuid[],
  ADD COLUMN IF NOT EXISTS evidence jsonb;

COMMENT ON COLUMN public.content_reports.selected_message_ids IS 'The IDs of the specific messages the user selected to report.';
COMMENT ON COLUMN public.content_reports.evidence IS 'A snapshot of the chat history surrounding the reported messages (e.g., ±20 days).';
