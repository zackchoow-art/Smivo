-- ============================================================
-- Migration 00109: Fix duplicate missed-order push notifications
-- ============================================================
-- Root cause: accept_order_and_reject_others RPC manually INSERTs
-- a notification row when marking orders as 'missed'. But the
-- notify_order_status_change trigger ALSO fires on the same status
-- update (pending → missed), inserting a second notification row.
-- Both rows hit the push-notification webhook, causing 2 pushes.
--
-- Fix: remove the manual INSERT from the RPC. The trigger in
-- 00105 already handles 'missed' notifications with the better
-- message format (includes listing title).
-- ============================================================

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

  -- Accept the chosen order (pending → confirmed).
  -- The notify_order_status_change trigger will fire and send
  -- an 'Order accepted' notification to the winning buyer.
  UPDATE public.orders
    SET status = 'confirmed', updated_at = now()
    WHERE id = p_order_id AND status = 'pending';

  -- Mark other pending orders for the same listing AND same cycle as missed.
  -- NOTE: The notify_order_status_change trigger fires AFTER each row update
  -- and handles the 'Offer Missed' notification automatically — no manual
  -- INSERT needed here. Adding one here was the cause of the duplicate push.
  UPDATE public.orders
    SET status = 'missed', updated_at = now()
    WHERE listing_id = p_listing_id
      AND listing_cycle = v_cycle
      AND id != p_order_id
      AND status = 'pending';

  -- NOTE: Intentionally no INSERT into notifications here.
  -- The trigger on orders (notify_order_status_change) already handles
  -- 'missed' status transitions and produces the user-friendly message:
  -- "Another buyer was selected for "<listing>". Keep browsing for more great deals!"
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
