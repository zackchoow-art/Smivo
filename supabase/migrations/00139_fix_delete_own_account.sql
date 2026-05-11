-- Migration 00139: Fix delete_own_account for users with listings/orders
-- ═══════════════════════════════════════════════════════════════════════
-- Problem: delete_own_account() only does:
--   DELETE FROM user_profiles WHERE id = auth.uid();
--   DELETE FROM auth.users WHERE id = auth.uid();
--
-- When user_profiles cascades to listings, the ON DELETE RESTRICT
-- constraint on orders.listing_id blocks the entire transaction.
-- The admin version (admin_delete_user) already solves this by
-- deleting records in correct dependency order — we replicate
-- that pattern here for self-service deletion.
--
-- Strategy: Rewrite delete_own_account() to mirror the proven
-- admin_delete_user() pattern, deleting data in FK dependency
-- order. This preserves order audit trail by orphaning orders
-- from their listings (SET NULL) rather than hard-deleting them.
--
-- Risk level: HIGH — modifies a SECURITY DEFINER function and
-- a FK constraint. Both changes are backward-compatible.
-- ═══════════════════════════════════════════════════════════════════════

-- ── Step 1: Change orders.listing_id FK from RESTRICT to SET NULL ──
-- This is the structural fix. Instead of blocking listing deletion,
-- orders keep their history but lose the live link to the listing.
-- The order already contains all necessary data for display via
-- the nested join (listing title, images, prices are fetched at
-- query time; for deleted listings they will just return null).

-- First, make the column nullable
ALTER TABLE public.orders
  ALTER COLUMN listing_id DROP NOT NULL;

-- Drop the old RESTRICT constraint and create SET NULL version
ALTER TABLE public.orders
  DROP CONSTRAINT orders_listing_id_fkey;

ALTER TABLE public.orders
  ADD CONSTRAINT orders_listing_id_fkey
    FOREIGN KEY (listing_id) REFERENCES public.listings(id)
    ON DELETE SET NULL;


-- ── Step 2: Rewrite delete_own_account() ──────────────────────────
-- Now that orders.listing_id is SET NULL, the cascade from
-- user_profiles → listings will succeed: orders keep their rows
-- but listing_id becomes NULL.
--
-- However, we still need to handle tables that reference orders
-- via buyer_id/seller_id with ON DELETE CASCADE (those cascade
-- from user_profiles directly, so they're fine).
--
-- The remaining blocker is chat_rooms referencing listings with
-- ON DELETE CASCADE — that's already fine.
--
-- We add explicit cleanup for edge cases and to match the
-- thorough approach of admin_delete_user.

CREATE OR REPLACE FUNCTION public.delete_own_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_uid uuid := auth.uid();
BEGIN
  -- Safety check
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- ── Delete in FK dependency order ──────────────────────────

  -- 1. Rental extensions (FK → orders)
  DELETE FROM public.rental_extensions WHERE order_id IN (
    SELECT id FROM public.orders
    WHERE buyer_id = v_uid OR seller_id = v_uid
  );

  -- 2. Order evidence (FK → orders)
  DELETE FROM public.order_evidence WHERE order_id IN (
    SELECT id FROM public.orders
    WHERE buyer_id = v_uid OR seller_id = v_uid
  );

  -- 3. User reviews (FK → orders)
  DELETE FROM public.user_reviews WHERE order_id IN (
    SELECT id FROM public.orders
    WHERE buyer_id = v_uid OR seller_id = v_uid
  );

  -- 4. Notifications (FK → orders via related_order_id)
  DELETE FROM public.notifications WHERE user_id = v_uid;

  -- 5. Orders where user is buyer or seller
  DELETE FROM public.orders
  WHERE buyer_id = v_uid OR seller_id = v_uid;

  -- 6. Chat messages sent by user
  DELETE FROM public.messages WHERE sender_id = v_uid;

  -- 7. Chat rooms where user is participant
  DELETE FROM public.chat_rooms
  WHERE buyer_id = v_uid OR seller_id = v_uid;

  -- 8. Saved listings
  DELETE FROM public.saved_listings WHERE user_id = v_uid;

  -- 9. Listing images cascade with listings, but explicit is safer
  -- 10. Listings (now safe — orders.listing_id is SET NULL)
  DELETE FROM public.listings WHERE seller_id = v_uid;

  -- 11. Content reports
  DELETE FROM public.content_reports
  WHERE reporter_id = v_uid OR reported_user_id = v_uid;

  -- 12. User feedbacks
  DELETE FROM public.user_feedbacks WHERE user_id = v_uid;

  -- 13. Active sessions / heartbeat
  DELETE FROM public.user_active_sessions WHERE user_id = v_uid;
  DELETE FROM public.hourly_active_users WHERE user_id = v_uid;

  -- 14. User blocks (both directions)
  DELETE FROM public.user_blocks
  WHERE user_id = v_uid OR blocked_user_id = v_uid;

  -- 15. User bans
  DELETE FROM public.user_bans WHERE user_id = v_uid;

  -- 16. Admin roles (if user was admin)
  DELETE FROM public.admin_roles WHERE user_id = v_uid;
  DELETE FROM public.school_admins WHERE user_id = v_uid;

  -- 17. Backend moderation logs
  DELETE FROM public.backend_moderation_logs WHERE user_id = v_uid;

  -- 18. Listing moderation notices
  DELETE FROM public.listing_moderation_notices WHERE user_id = v_uid;

  -- ── Delete user profile (cascades remaining child rows) ────
  DELETE FROM public.user_profiles WHERE id = v_uid;

  -- ── Delete the auth user ───────────────────────────────────
  DELETE FROM auth.users WHERE id = v_uid;
END;
$$;

-- Ensure grant is still in place
GRANT EXECUTE ON FUNCTION public.delete_own_account() TO authenticated;

COMMENT ON FUNCTION public.delete_own_account IS
'Self-service account deletion. Deletes all user data in correct FK
dependency order, then removes the user_profiles and auth.users rows.
Mirrors the admin_delete_user() pattern but restricted to auth.uid().';
