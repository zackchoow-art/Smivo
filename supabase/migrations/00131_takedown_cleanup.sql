-- Migration 00131: Cleanup side effects when a listing is taken down
--
-- Modifies notify_listing_taken_down() to also:
--   1. Cancel all pending orders for the listing
--   2. Delete all saved_listings records for the listing
--
-- NOTE: The trigger monitors both moderation_status = 'taken_down' (AI/admin
-- auto-takedown) and status = 'delisted' (manual delist). The client-side
-- cancel_pending_orders_on_delist RPC handles the manual delist case already,
-- but adding it here as a database-level safety net ensures cleanup happens
-- even if the client RPC call fails or is bypassed.
--
-- The cancelled_by = NEW.seller_id attribution lets the existing
-- notify_order_status_change trigger generate the correct buyer notification
-- ("seller cancelled").

CREATE OR REPLACE FUNCTION public.notify_listing_taken_down()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_new_status   TEXT;
  v_new_mod      TEXT;
  v_old_status   TEXT;
  v_old_mod      TEXT;
  v_is_takedown  BOOLEAN;
  v_is_delist    BOOLEAN;
BEGIN
  v_new_status := NEW.status;
  v_new_mod    := NEW.moderation_status;
  v_old_status := OLD.status;
  v_old_mod    := OLD.moderation_status;

  -- Determine whether this update represents a takedown or delist event
  v_is_takedown := (v_new_mod = 'taken_down' AND v_old_mod IS DISTINCT FROM 'taken_down');
  v_is_delist   := (v_new_status = 'delisted'  AND v_old_status IS DISTINCT FROM 'delisted');

  IF v_is_takedown OR v_is_delist THEN

    -- 1. Send in-app notification to seller
    INSERT INTO public.notifications (
      user_id,
      type,
      title,
      body,
      metadata
    ) VALUES (
      NEW.seller_id,
      'listing_taken_down',
      'Your listing has been removed',
      'Your listing "' || NEW.title || '" has been removed from the marketplace.',
      jsonb_build_object('listing_id', NEW.id)
    );

    -- 2. Cancel all pending orders for this listing
    -- NOTE: cancelled_by = NEW.seller_id so the order notification trigger
    -- sends the buyer the correct "seller cancelled" message.
    UPDATE public.orders
    SET
      status       = 'cancelled',
      cancelled_by = NEW.seller_id,
      updated_at   = now()
    WHERE listing_id = NEW.id
      AND status     = 'pending';

    -- 3. Remove all saved_listings records for this listing
    DELETE FROM public.saved_listings
    WHERE listing_id = NEW.id;

  END IF;

  RETURN NEW;
END;
$$;

-- Ensure the trigger exists and fires on the correct columns.
-- DROP + CREATE handles the case where the trigger already existed with
-- different column conditions.
DROP TRIGGER IF EXISTS listing_taken_down_trigger ON public.listings;

CREATE TRIGGER listing_taken_down_trigger
  AFTER UPDATE OF moderation_status, status ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_listing_taken_down();
