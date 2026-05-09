-- ============================================================
-- Migration 00132: Fix notifications.type CHECK constraint
-- ============================================================
-- Problem: Migration 00131 (takedown_cleanup) inserts notifications
-- with type = 'listing_taken_down', but the CHECK constraint on
-- notifications.type was last updated in migration 00071 and does
-- NOT include 'listing_taken_down'.
--
-- This causes the listing_taken_down_trigger to fail with a CHECK
-- constraint violation whenever a listing's moderation_status is
-- set to 'taken_down', rolling back the entire transaction and
-- preventing admin takedown actions from completing.
--
-- Also adds 'order_missed' which is referenced in system_dictionaries
-- (migration 00038) and triggers but was missing from the constraint.
-- ============================================================

BEGIN;

-- Drop the existing CHECK constraint (added in migration 00071)
ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

-- Recreate with all valid types including 'listing_taken_down'
ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check CHECK (type IN (
    -- Order lifecycle types (migration 00008)
    'order_placed',
    'order_accepted',
    'order_cancelled',
    'order_delivered',
    'order_completed',
    -- Rental & extension types (migrations 00027, 00028)
    'rental_extension',
    'rental_reminder',
    -- Missed order type (migration 00024, 00032)
    'order_missed',
    -- Chat types (migration 00043)
    'new_message',
    -- System/broadcast type (migration 00046)
    'system',
    'system_broadcast',
    -- Moderation action result types (migration 00071)
    'report_resolved',
    'report_dismissed',
    'moderation_warned',
    'moderation_restricted',
    -- Feedback types (migration 00071)
    'feedback_responded',
    -- Listing takedown type (migration 00111, 00131)
    -- NOTE: This was missing — its absence caused takedown to fail
    'listing_taken_down'
  ));

COMMIT;
