-- ════════════════════════════════════════════════════════════
-- 00024: Differentiate "missed" vs "cancelled" notifications
--
-- When an order is cancelled because the seller chose another buyer,
-- send a friendlier "offer missed" notification instead of
-- "order cancelled".
-- ════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.notify_order_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
  v_title_snippet text;
  v_has_confirmed_order boolean;
BEGIN
  IF old.status IS NOT DISTINCT FROM new.status THEN
    RETURN NEW;
  END IF;

  SELECT title INTO v_listing_title
  FROM public.listings
  WHERE id = NEW.listing_id;
  v_title_snippet := coalesce(v_listing_title, 'your order');

  -- pending → confirmed (seller accepted this buyer)
  IF old.status = 'pending' AND new.status = 'confirmed' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      NEW.buyer_id, 'order_accepted', 'Order accepted',
      'The seller accepted your order for "' || v_title_snippet || '"',
      NEW.id, 'order'
    );
  END IF;

  -- → cancelled
  IF new.status = 'cancelled' THEN
    -- Check if another order for the same listing was just confirmed
    -- (meaning this cancellation is due to seller choosing another buyer)
    SELECT EXISTS(
      SELECT 1 FROM public.orders
      WHERE listing_id = NEW.listing_id
        AND id != NEW.id
        AND status = 'confirmed'
    ) INTO v_has_confirmed_order;

    IF v_has_confirmed_order THEN
      -- This buyer was "outbid" — send a friendlier missed notification
      INSERT INTO public.notifications
        (user_id, type, title, body, related_order_id, action_type)
      VALUES (
        NEW.buyer_id, 'order_cancelled', 'Offer Missed',
        'Another buyer was selected for "' || v_title_snippet || '". Keep browsing for more great deals!',
        NEW.id, 'order'
      );
      -- Seller does NOT need a notification for auto-cancelled orders
    ELSE
      -- Normal cancellation (buyer or seller manually cancelled)
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

  -- → completed
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
