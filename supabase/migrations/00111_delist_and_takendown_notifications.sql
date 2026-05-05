-- ════════════════════════════════════════════════════════════════
-- Migration 00111: delist and taken_down notification improvements
-- ════════════════════════════════════════════════════════════════
--
-- 1. Replace client-side cancelAllPendingOrders with an atomic RPC
--    that sets cancelled_by = seller_id on every pending order so the
--    notification trigger can differentiate a "listing delisted" cancel
--    from a regular user-initiated cancel.
--
-- 2. Extend notify_order_status_change to detect seller-as-canceller:
--    when cancelled_by == seller_id AND order was still pending, send
--    buyer a "listing taken down" style message instead of the generic
--    "Order was cancelled". The seller does NOT receive a notification
--    for orders they themselves cancelled via delist.
--
-- 3. Add a trigger on listings that fires when moderation_status
--    transitions to 'taken_down', notifying the seller.
-- ════════════════════════════════════════════════════════════════

BEGIN;

-- ── 1. Atomic delist cancel RPC ──────────────────────────────────
-- Cancels all pending orders for a listing, setting cancelled_by to the
-- authenticated seller so the notification trigger knows the seller
-- initiated this (and can suppress the self-notification).
CREATE OR REPLACE FUNCTION public.cancel_pending_orders_on_delist(p_listing_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- NOTE: Only the listing owner can delist; auth.uid() guards this.
  -- We set cancelled_by to the seller_id column value so the
  -- notify_order_status_change trigger has it available as NEW.cancelled_by.
  UPDATE public.orders
    SET status       = 'cancelled',
        cancelled_by = seller_id,   -- seller is the one delisting
        updated_at   = now()
  WHERE listing_id = p_listing_id
    AND status     = 'pending'
    AND seller_id  = auth.uid(); -- RLS safety: only own listings
END;
$$;

GRANT EXECUTE ON FUNCTION public.cancel_pending_orders_on_delist(uuid) TO authenticated;

-- ── 2. Extend notify_order_status_change ─────────────────────────
-- When cancelled_by == seller_id AND prior status was 'pending',
-- the cancel was caused by a delist, not a voluntary order cancel.
-- Send buyers a clear "item delisted" message.
-- When cancelled_by == buyer_id, nothing changes (buyer cancelled).
-- When cancelled_by == seller_id AND prior status was 'confirmed',
-- it is a seller-voluntary cancel of an accepted order — existing text.
CREATE OR REPLACE FUNCTION public.notify_order_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
  v_title_snippet text;
BEGIN
  IF old.status IS NOT DISTINCT FROM new.status THEN
    RETURN NEW;
  END IF;

  SELECT title INTO v_listing_title
  FROM public.listings
  WHERE id = NEW.listing_id;
  v_title_snippet := coalesce(v_listing_title, 'your order');

  -- Case A: pending → confirmed (seller accepted this buyer)
  IF old.status = 'pending' AND new.status = 'confirmed' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      NEW.buyer_id, 'order_accepted', 'Order accepted',
      'The seller accepted your order for "' || v_title_snippet || '"',
      NEW.id, 'order'
    );
  END IF;

  -- Case B: → cancelled
  IF new.status = 'cancelled' THEN
    IF NEW.cancelled_by IS NOT NULL THEN
      IF NEW.cancelled_by = NEW.buyer_id THEN
        -- Buyer cancelled → notify seller only
        INSERT INTO public.notifications
          (user_id, type, title, body, related_order_id, action_type)
        VALUES (
          NEW.seller_id, 'order_cancelled', 'Order cancelled',
          'The buyer cancelled the order for "' || v_title_snippet || '"',
          NEW.id, 'order'
        );
      ELSIF NEW.cancelled_by = NEW.seller_id AND old.status = 'pending' THEN
        -- NOTE: Seller cancelled a PENDING order — this means the listing was
        -- delisted. Send buyer a "listing delisted" message, NOT the generic
        -- cancel text. Seller does NOT receive a notification for their own
        -- delist action.
        INSERT INTO public.notifications
          (user_id, type, title, body, related_order_id, action_type)
        VALUES (
          NEW.buyer_id, 'order_cancelled', 'Listing removed',
          '"' || v_title_snippet || '" has been removed by the seller. Your offer has been withdrawn.',
          NEW.id, 'order'
        );
      ELSE
        -- Seller cancelled an already-confirmed order → notify buyer
        INSERT INTO public.notifications
          (user_id, type, title, body, related_order_id, action_type)
        VALUES (
          NEW.buyer_id, 'order_cancelled', 'Order cancelled',
          'Your order for "' || v_title_snippet || '" was cancelled by the seller',
          NEW.id, 'order'
        );
      END IF;
    ELSE
      -- No cancelled_by info (legacy): notify both
      INSERT INTO public.notifications
        (user_id, type, title, body, related_order_id, action_type)
      VALUES
        (NEW.buyer_id, 'order_cancelled', 'Order cancelled',
         'Your order for "' || v_title_snippet || '" was cancelled',
         NEW.id, 'order'),
        (NEW.seller_id, 'order_cancelled', 'Order cancelled',
         'The order for "' || v_title_snippet || '" was cancelled',
         NEW.id, 'order');
    END IF;
  END IF;

  -- Case C: → missed (auto-rejected — seller chose another buyer)
  IF new.status = 'missed' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      NEW.buyer_id, 'order_cancelled', 'Offer Missed',
      'Another buyer was selected for "' || v_title_snippet || '". Keep browsing for more great deals!',
      NEW.id, 'order'
    );
    -- Seller does NOT receive a notification for auto-cancelled offers
  END IF;

  -- Case D: → completed
  IF new.status = 'completed' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES
      (NEW.buyer_id, 'order_completed', 'Order completed',
       'Your order for "' || v_title_snippet || '" is complete',
       NEW.id, 'order'),
      (NEW.seller_id, 'order_completed', 'Order completed',
       'The order for "' || v_title_snippet || '" is complete',
       NEW.id, 'order');
  END IF;

  RETURN NEW;
END;
$$;

-- ── 3. Taken-down listing notification ───────────────────────────
-- Notify the seller when their listing's moderation_status changes
-- to 'taken_down' by a platform admin.
CREATE OR REPLACE FUNCTION public.notify_listing_taken_down()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Only fire on moderation_status transitions into 'taken_down'
  IF NEW.moderation_status = 'taken_down' AND
     (OLD.moderation_status IS DISTINCT FROM 'taken_down') THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, action_type)
    VALUES (
      NEW.seller_id,
      'order_cancelled',   -- reuse existing type; no dedicated 'listing' type yet
      'Listing removed',
      '"' || NEW.title || '" has been removed from the marketplace for violating platform guidelines.',
      'none'
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_listing_taken_down ON public.listings;

CREATE TRIGGER on_listing_taken_down
  AFTER UPDATE OF moderation_status ON public.listings
  FOR EACH ROW EXECUTE FUNCTION public.notify_listing_taken_down();

-- ── 4. Schema reload ─────────────────────────────────────────────
NOTIFY pgrst, 'reload schema';

COMMIT;
