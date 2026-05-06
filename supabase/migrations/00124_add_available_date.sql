-- Migration 00124: Add available_date to listings
--
-- Allows sellers to specify the earliest date their item is available
-- for pickup/rental. Displayed in the listing detail and used as a
-- signal for future delivery-reminder notifications (Phase 2).
--
-- NOTE: Nullable — most sellers won't set this initially.
-- The column is added with no default so existing listings remain unaffected.

ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS available_date DATE;
