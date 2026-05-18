-- ============================================================
-- Migration 00184: Complete notifications_type_check constraint
-- ============================================================
-- Migration 00183 was already executed but it omitted several
-- notification types that were added by prior migrations:
--   - 'order_missed'          (00024/00032)
--   - 'system_broadcast'      (00046)
--   - 'listing_taken_down'    (00111/00131)
--   - 'report_resolved'       (00071/00132)
--   - 'report_dismissed'      (00071/00132)
--   - 'moderation_warned'     (00071/00132)
--   - 'moderation_restricted' (00071/00132)
--   - 'feedback_responded'    (00071/00132)
--
-- Impact: send_moderation_notification() RPC was failing with a
-- CHECK violation when admins resolved listing reports (it inserts
-- type = 'moderation_warned' or 'report_resolved'), causing the
-- entire Confirm Resolution flow to throw an error.
--
-- This migration rebuilds the constraint with the complete set.
-- ============================================================

ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check CHECK (type IN (
    -- ── Order lifecycle ─────────────────────────────────────────
    'order_placed',
    'order_accepted',
    'order_cancelled',
    'order_delivered',
    'order_completed',
    'order_missed',
    -- ── Rental ──────────────────────────────────────────────────
    'rental_reminder',
    'rental_extension',
    -- ── Chat ────────────────────────────────────────────────────
    'new_message',
    'group_message',
    -- ── System / broadcast ───────────────────────────────────────
    'system',
    'system_broadcast',
    -- ── Marketplace listing ──────────────────────────────────────
    'listing_updated',
    'listing_taken_down',
    -- ── Moderation & reports ─────────────────────────────────────
    'report_resolved',
    'report_dismissed',
    'moderation_warned',
    'moderation_restricted',
    -- ── User feedback ────────────────────────────────────────────
    'feedback_responded',
    -- ── Carpool ──────────────────────────────────────────────────
    'carpool_join_request',
    'carpool_join_approved',
    'carpool_join_rejected',
    'carpool_trip_cancelled',
    'carpool_proposal_created',
    'carpool_vote_result',
    'carpool_trip_departed'
  ));

NOTIFY pgrst, 'reload schema';
