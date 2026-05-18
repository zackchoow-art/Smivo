-- ============================================================
-- Migration 00183: Fix notifications_type_check constraint
-- ============================================================
-- ROOT CAUSE (original):
--   Migration 00177 (notify_listing_updated_rpc) added 'listing_updated'
--   to the notifications.type CHECK constraint but reconstructed it from
--   scratch using only the 00155 canonical set, omitting all carpool types.
--
-- ROOT CAUSE (this file's previous version):
--   The first version of this migration (already executed) fixed the
--   carpool types but itself omitted several important types that were
--   added by migrations 00132 (moderation, feedback, listing_taken_down)
--   and 00155 (group_message, listing_updated, etc.).
--
-- This replacement rebuilds the constraint with the COMPLETE canonical set
-- merged from ALL migrations that have ever added types:
--   00008 → order lifecycle
--   00024/00032 → order_missed
--   00027/00028 → rental extension/reminder
--   00043 → new_message
--   00046 → system, system_broadcast
--   00071/00132 → report_resolved, report_dismissed, moderation_warned,
--                 moderation_restricted, feedback_responded
--   00111/00131 → listing_taken_down
--   00155 → group_message, listing_updated
--   00146 → all 7 carpool_* types
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
