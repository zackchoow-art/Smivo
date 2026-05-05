-- ============================================================
-- Migration 00110: relist_listing RPC
-- ============================================================
-- Provides a seller-initiated relist action for cancelled listings.
--
-- Design:
--   When a confirmed order is cancelled the listing ends up in
--   'sold' or 'rented' (set by the Flutter app layer, not the DB
--   trigger) and never automatically returns to 'active'.
--
--   Instead of auto-relisting, we give the seller an explicit
--   "Relist" button in Seller Center > History. Pressing it calls
--   this RPC which atomically:
--     1. Resets listing.status → 'active' (regardless of current
--        status: reserved, sold, or rented)
--     2. Increments listing_cycle so that offers from the previous
--        failed transaction are isolated from the new round.
--        Existing cancelled/missed orders stay in History for audit;
--        only the cycle counter advances so new orders won't mix
--        with old-cycle offer counts.
--
-- Security:
--   SECURITY DEFINER bypasses RLS for the UPDATE so an admin cannot
--   accidentally be blocked. The WHERE clause restricts the update
--   to listings owned by auth.uid() — the seller can only relist
--   their own items.
-- ============================================================

BEGIN;

CREATE OR REPLACE FUNCTION public.relist_listing(p_listing_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- NOTE: Allow relisting from any non-active status so the function
  -- works whether the listing is: reserved (pending acceptance),
  -- sold (sale order cancelled after App set it sold), or
  -- rented (rental order cancelled after delivery was confirmed).
  UPDATE public.listings
    SET status       = 'active',
        listing_cycle = listing_cycle + 1,
        updated_at   = now()
  WHERE id        = p_listing_id
    AND seller_id = auth.uid()
    AND status   != 'inactive'; -- Do not resurrect intentionally delisted items

  -- Raise if no row was updated (listing not found or already inactive)
  IF NOT FOUND THEN
    RAISE EXCEPTION 'relist_listing: listing % not found or not eligible for relisting', p_listing_id
      USING ERRCODE = 'P0002';
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.relist_listing(uuid) TO authenticated;

COMMIT;
