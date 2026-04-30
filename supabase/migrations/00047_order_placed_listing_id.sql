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
    (user_id, type, title, body, related_order_id, action_type, action_url)
  VALUES (
    NEW.seller_id,
    'order_placed',
    'New order received',
    'Someone placed an order for "' || coalesce(v_listing_title, 'your listing') || '"',
    NEW.id,
    'route',
    '/listing/' || NEW.listing_id::text || '/transactions?tab=2'
  );
  RETURN NEW;
END;
$$;
