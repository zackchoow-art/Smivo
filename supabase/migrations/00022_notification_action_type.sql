-- ════════════════════════════════════════════════════════════
-- 00022: Notification Action Type Extension
--
-- Adds action_type and action_url to support different click
-- behaviors: navigate to order, open URL, or app route.
-- ════════════════════════════════════════════════════════════

ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS action_type text NOT NULL DEFAULT 'none'
    CHECK (action_type IN ('none', 'order', 'url', 'route')),
  ADD COLUMN IF NOT EXISTS action_url text;

-- Backfill existing order notifications with action_type = 'order'
UPDATE public.notifications
SET action_type = 'order'
WHERE type IN (
  'order_placed', 'order_accepted', 'order_cancelled',
  'order_delivered', 'order_completed'
)
AND related_order_id IS NOT NULL;

-- Update existing triggers to set action_type = 'order' on insert.
-- notify_order_placed
CREATE OR REPLACE FUNCTION public.notify_order_placed()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
BEGIN
  SELECT title INTO v_listing_title
  FROM public.listings
  WHERE id = NEW.listing_id;

  INSERT INTO public.notifications
    (user_id, type, title, body, related_order_id, action_type)
  VALUES (
    NEW.seller_id,
    'order_placed',
    'New order received',
    'Someone placed an order for "' || coalesce(v_listing_title, 'your listing') || '"',
    NEW.id,
    'order'
  );
  RETURN NEW;
END;
$$;

-- notify_order_status_change
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

  IF old.status = 'pending' AND new.status = 'confirmed' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      NEW.buyer_id, 'order_accepted', 'Order accepted',
      'The seller accepted your order for "' || v_title_snippet || '"',
      NEW.id, 'order'
    );
  END IF;

  IF new.status = 'cancelled' THEN
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

-- notify_delivery_confirmed
CREATE OR REPLACE FUNCTION public.notify_delivery_confirmed()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
  v_title_snippet text;
BEGIN
  SELECT title INTO v_listing_title
  FROM public.listings
  WHERE id = NEW.listing_id;
  v_title_snippet := coalesce(v_listing_title, 'your order');

  IF old.delivery_confirmed_by_buyer = false
     AND new.delivery_confirmed_by_buyer = true THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      NEW.seller_id, 'order_delivered', 'Buyer confirmed delivery',
      'The buyer confirmed delivery for "' || v_title_snippet || '"',
      NEW.id, 'order'
    );
  END IF;

  IF old.delivery_confirmed_by_seller = false
     AND new.delivery_confirmed_by_seller = true THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      NEW.buyer_id, 'order_delivered', 'Seller confirmed delivery',
      'The seller confirmed delivery for "' || v_title_snippet || '"',
      NEW.id, 'order'
    );
  END IF;

  RETURN NEW;
END;
$$;
