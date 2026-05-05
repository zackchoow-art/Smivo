-- ============================================================
-- Migration 00107: Blocked-By RPC + Listing Cycle
-- ============================================================
-- Part A: get_blocked_by_user_ids()
--   A SECURITY DEFINER RPC that returns IDs of users who have
--   blocked the calling user. Required because user_blocks RLS
--   only exposes rows where user_id = auth.uid() — users cannot
--   query who blocked them under normal RLS.
--
-- Part B: listing_cycle
--   Tracks how many times a listing has been re-listed after a
--   cancelled order. Each order stores the cycle it belongs to.
--   This lets Transaction Management / notifications scope to the
--   current listing cycle without deleting historical order records.
-- ============================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- Part A: get_blocked_by_user_ids RPC
-- ═══════════════════════════════════════════════════════════════

-- Returns the IDs of users who have blocked the authenticated user.
-- SECURITY DEFINER bypasses RLS so the function can read all rows
-- in user_blocks, not just those owned by the calling user.
-- The result is intentionally scoped to auth.uid() so it is safe.
CREATE OR REPLACE FUNCTION public.get_blocked_by_user_ids()
RETURNS uuid[]
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT COALESCE(
    ARRAY(
      SELECT user_id
      FROM public.user_blocks
      WHERE blocked_user_id = auth.uid()
    ),
    ARRAY[]::uuid[]
  );
$$;

GRANT EXECUTE ON FUNCTION public.get_blocked_by_user_ids() TO authenticated;


-- ═══════════════════════════════════════════════════════════════
-- Part B: listing_cycle column on listings
-- ═══════════════════════════════════════════════════════════════

-- Tracks how many times a listing has been recycled via a cancelled
-- confirmed order. Starts at 1, increments on each relist event.
-- All existing listings default to cycle 1.
ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS listing_cycle smallint NOT NULL DEFAULT 1;

-- ═══════════════════════════════════════════════════════════════
-- Part B: listing_cycle column on orders
-- ═══════════════════════════════════════════════════════════════

-- Each order records which listing cycle it belongs to at creation
-- time. This preserves historical records while letting the app
-- scope "current offers" to the active cycle only.
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS listing_cycle smallint NOT NULL DEFAULT 1;


-- ═══════════════════════════════════════════════════════════════
-- Part B: Auto-set orders.listing_cycle on INSERT
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.set_order_listing_cycle()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Copy the current cycle from the listing so this order is
  -- correctly associated with the active listing cycle.
  SELECT listing_cycle INTO NEW.listing_cycle
  FROM public.listings
  WHERE id = NEW.listing_id;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_order_insert_set_cycle ON public.orders;
CREATE TRIGGER on_order_insert_set_cycle
  BEFORE INSERT ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.set_order_listing_cycle();


-- ═══════════════════════════════════════════════════════════════
-- Part B: Update sync_listing trigger to increment cycle on relist
-- ═══════════════════════════════════════════════════════════════
-- When a confirmed order is cancelled the listing is released back
-- to 'active'. At that point we increment listing_cycle so that
-- subsequent orders are in a new cycle, isolating them from
-- previous cycle notifications and offer counts.

CREATE OR REPLACE FUNCTION public.sync_listing_on_order_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- pending → confirmed: reserve the listing
  IF OLD.status = 'pending' AND NEW.status = 'confirmed' THEN
    UPDATE public.listings
      SET status = 'reserved',
          updated_at = now()
      WHERE id = NEW.listing_id
        AND status = 'active';
  END IF;

  -- confirmed → cancelled: release back to active AND increment cycle.
  -- NOTE: Only increment cycle when a *confirmed* (i.e. accepted) order
  -- is cancelled. A plain pending cancellation is a normal buyer
  -- withdrawal and does not constitute a new listing lifecycle.
  IF NEW.status = 'cancelled' AND OLD.status = 'confirmed' THEN
    UPDATE public.listings
      SET status = 'active',
          listing_cycle = listing_cycle + 1,
          updated_at = now()
      WHERE id = NEW.listing_id
        AND status = 'reserved';
  END IF;

  -- pending → cancelled: release back to active WITHOUT incrementing
  -- the cycle. The listing was never "taken off market" so this is
  -- just a buyer changing their mind.
  IF NEW.status = 'cancelled' AND OLD.status = 'pending' THEN
    UPDATE public.listings
      SET status = 'active',
          updated_at = now()
      WHERE id = NEW.listing_id
        AND status = 'reserved';
  END IF;

  -- confirmed → completed: finalize based on order type
  IF OLD.status = 'confirmed' AND NEW.status = 'completed' THEN
    IF NEW.order_type = 'sale' THEN
      UPDATE public.listings
        SET status = 'sold',
            updated_at = now()
        WHERE id = NEW.listing_id;
    ELSIF NEW.order_type = 'rental' THEN
      -- Rental completion relists the item; treat as a new cycle.
      UPDATE public.listings
        SET status = 'active',
            listing_cycle = listing_cycle + 1,
            updated_at = now()
        WHERE id = NEW.listing_id
          AND status = 'reserved';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Trigger is already attached from migration 00014; the function
-- replacement above is sufficient to update behaviour.


-- ═══════════════════════════════════════════════════════════════
-- Part B: Update accept_order_and_reject_others to use cycle
-- ═══════════════════════════════════════════════════════════════
-- Scope the "reject others" logic to the current listing cycle so
-- buyers from previous cycles are not notified or affected.

CREATE OR REPLACE FUNCTION public.accept_order_and_reject_others(
  p_order_id UUID,
  p_listing_id UUID
) RETURNS VOID AS $$
DECLARE
  v_cycle smallint;
BEGIN
  -- Fetch the current cycle of the listing so we only touch same-cycle orders.
  SELECT listing_cycle INTO v_cycle
  FROM public.listings
  WHERE id = p_listing_id;

  -- Accept the chosen order
  UPDATE public.orders
    SET status = 'confirmed', updated_at = now()
    WHERE id = p_order_id AND status = 'pending';

  -- Mark other pending orders for the same listing AND same cycle as missed.
  -- NOTE: Orders from previous cycles are deliberately excluded to preserve
  -- historical data without triggering spurious missed-order notifications.
  UPDATE public.orders
    SET status = 'missed', updated_at = now()
    WHERE listing_id = p_listing_id
      AND listing_cycle = v_cycle
      AND id != p_order_id
      AND status = 'pending';

  -- Notify only current-cycle buyers whose offers were missed.
  INSERT INTO public.notifications (user_id, type, title, body, action_type, related_order_id)
  SELECT buyer_id,
         'order_cancelled',
         'Offer Missed',
         'Another buyer was selected for this item.',
         'order',
         id
  FROM public.orders
  WHERE listing_id = p_listing_id
    AND listing_cycle = v_cycle
    AND id != p_order_id
    AND status = 'missed';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMIT;
