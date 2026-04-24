-- ════════════════════════════════════════════════════════════
-- 00029: Email Notification System (DB-level)
--
-- 1. Add email_notifications_enabled to user_profiles
-- 2. Add email_queued field to notifications table
-- 3. Update all notification trigger functions to set email_queued
-- ════════════════════════════════════════════════════════════

-- ─── 1. User preference: email notifications toggle ───

ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS email_notifications_enabled boolean NOT NULL DEFAULT true;

-- ─── 2. Notification table: email_queued flag ───

ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS email_queued boolean NOT NULL DEFAULT false;

-- ─── 3. Update the main order status notification trigger ───
--    Now checks user's email preference and sets email_queued accordingly.

CREATE OR REPLACE FUNCTION public.notify_order_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
  v_buyer_name text;
  v_seller_name text;
  v_notify_user_id uuid;
  v_title text;
  v_body text;
  v_type text;
  v_email_enabled boolean;
BEGIN
  -- Only fire on status changes
  IF OLD.status = NEW.status THEN
    RETURN NEW;
  END IF;

  -- Fetch context
  SELECT l.title INTO v_listing_title
  FROM public.listings l WHERE l.id = NEW.listing_id;
  v_listing_title := coalesce(v_listing_title, 'an item');

  SELECT u.display_name INTO v_buyer_name
  FROM public.user_profiles u WHERE u.id = NEW.buyer_id;
  v_buyer_name := coalesce(v_buyer_name, 'A buyer');

  SELECT u.display_name INTO v_seller_name
  FROM public.user_profiles u WHERE u.id = NEW.seller_id;
  v_seller_name := coalesce(v_seller_name, 'The seller');

  -- Determine notification target and content
  CASE NEW.status
    WHEN 'confirmed' THEN
      v_notify_user_id := NEW.buyer_id;
      v_type := 'order_accepted';
      v_title := 'Offer Accepted!';
      v_body := v_seller_name || ' accepted your offer on "' || v_listing_title || '"';

      -- Also notify other buyers whose orders were cancelled (missed)
      INSERT INTO public.notifications
        (user_id, type, title, body, related_order_id, action_type, email_queued)
      SELECT
        o.buyer_id, 'order_cancelled', 'Offer Missed',
        'Another buyer''s offer was accepted for "' || v_listing_title || '"',
        o.id, 'order',
        (SELECT coalesce(up.email_notifications_enabled, true)
         FROM public.user_profiles up WHERE up.id = o.buyer_id)
      FROM public.orders o
      WHERE o.listing_id = NEW.listing_id
        AND o.id != NEW.id
        AND o.status = 'cancelled'
        AND o.updated_at >= (now() - interval '5 seconds');

    WHEN 'cancelled' THEN
      -- Notify the other party
      IF NEW.buyer_id = coalesce(auth.uid(), NEW.buyer_id) THEN
        v_notify_user_id := NEW.seller_id;
        v_body := v_buyer_name || ' cancelled their order on "' || v_listing_title || '"';
      ELSE
        v_notify_user_id := NEW.buyer_id;
        v_body := v_seller_name || ' cancelled the order on "' || v_listing_title || '"';
      END IF;
      v_type := 'order_cancelled';
      v_title := 'Order Cancelled';

    WHEN 'completed' THEN
      v_notify_user_id := NEW.buyer_id;
      v_type := 'order_completed';
      v_title := 'Order Complete!';
      v_body := 'Your order for "' || v_listing_title || '" is now complete';

      -- Also notify seller
      SELECT coalesce(up.email_notifications_enabled, true)
      INTO v_email_enabled
      FROM public.user_profiles up WHERE up.id = NEW.seller_id;

      INSERT INTO public.notifications
        (user_id, type, title, body, related_order_id, action_type, email_queued)
      VALUES (
        NEW.seller_id, 'order_completed', 'Sale Complete!',
        '"' || v_listing_title || '" order is now complete',
        NEW.id, 'order', coalesce(v_email_enabled, true)
      );

    ELSE
      RETURN NEW;
  END CASE;

  -- Check user's email preference
  SELECT coalesce(up.email_notifications_enabled, true)
  INTO v_email_enabled
  FROM public.user_profiles up WHERE up.id = v_notify_user_id;

  -- Insert notification with email_queued flag
  INSERT INTO public.notifications
    (user_id, type, title, body, related_order_id, action_type, email_queued)
  VALUES (
    v_notify_user_id, v_type, v_title, v_body, NEW.id, 'order',
    coalesce(v_email_enabled, true)
  );

  RETURN NEW;
END;
$$;

-- ─── 4. Update rental extension notification trigger ───

CREATE OR REPLACE FUNCTION public.notify_rental_extension()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
  v_seller_id uuid;
  v_buyer_id uuid;
  v_type_label text;
  v_target_user_id uuid;
  v_email_enabled boolean;
BEGIN
  SELECT o.seller_id, o.buyer_id, l.title
  INTO v_seller_id, v_buyer_id, v_listing_title
  FROM public.orders o
  JOIN public.listings l ON l.id = o.listing_id
  WHERE o.id = NEW.order_id;

  v_listing_title := coalesce(v_listing_title, 'a rental');
  v_type_label := CASE WHEN NEW.request_type = 'extend' THEN 'extension' ELSE 'early return' END;

  -- New request → notify seller
  IF TG_OP = 'INSERT' THEN
    v_target_user_id := v_seller_id;
    SELECT coalesce(up.email_notifications_enabled, true)
    INTO v_email_enabled
    FROM public.user_profiles up WHERE up.id = v_target_user_id;

    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type, email_queued)
    VALUES (
      v_target_user_id, 'rental_extension',
      'Rental ' || initcap(v_type_label) || ' Request',
      'The buyer requested a rental ' || v_type_label || ' for "' || v_listing_title || '"',
      NEW.order_id, 'order', coalesce(v_email_enabled, true)
    );
  END IF;

  -- Response → notify buyer
  IF TG_OP = 'UPDATE' AND OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected') THEN
    v_target_user_id := v_buyer_id;
    SELECT coalesce(up.email_notifications_enabled, true)
    INTO v_email_enabled
    FROM public.user_profiles up WHERE up.id = v_target_user_id;

    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type, email_queued)
    VALUES (
      v_target_user_id,
      'rental_extension',
      'Rental ' || initcap(v_type_label) || ' ' || initcap(NEW.status),
      CASE WHEN NEW.status = 'approved'
        THEN 'The seller approved your rental ' || v_type_label || ' for "' || v_listing_title || '"'
        ELSE 'The seller rejected your rental ' || v_type_label || ' for "' || v_listing_title || '"'
      END,
      NEW.order_id, 'order', coalesce(v_email_enabled, true)
    );
  END IF;

  RETURN NEW;
END;
$$;

-- ─── 5. Update rental reminder function ───

CREATE OR REPLACE FUNCTION public.check_rental_reminders()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_count integer := 0;
  v_order RECORD;
  v_listing_title text;
  v_days_left integer;
  v_email_enabled boolean;
BEGIN
  FOR v_order IN
    SELECT o.id, o.buyer_id, o.listing_id, o.rental_end_date,
           o.reminder_days_before, o.reminder_email
    FROM public.orders o
    WHERE o.order_type = 'rental'
      AND o.rental_status = 'active'
      AND o.rental_end_date IS NOT NULL
      AND o.reminder_sent = false
      AND o.rental_end_date::date - CURRENT_DATE <= o.reminder_days_before
      AND o.rental_end_date::date >= CURRENT_DATE
  LOOP
    SELECT l.title INTO v_listing_title
    FROM public.listings l WHERE l.id = v_order.listing_id;
    v_listing_title := coalesce(v_listing_title, 'your rental item');
    v_days_left := v_order.rental_end_date::date - CURRENT_DATE;

    -- Check user's global email preference + order-level email preference
    SELECT coalesce(up.email_notifications_enabled, true)
    INTO v_email_enabled
    FROM public.user_profiles up WHERE up.id = v_order.buyer_id;

    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type, email_queued)
    VALUES (
      v_order.buyer_id, 'rental_reminder', 'Rental Expiring Soon',
      CASE
        WHEN v_days_left = 0 THEN '"' || v_listing_title || '" rental expires today!'
        WHEN v_days_left = 1 THEN '"' || v_listing_title || '" rental expires tomorrow'
        ELSE '"' || v_listing_title || '" rental expires in ' || v_days_left || ' days'
      END,
      v_order.id, 'order',
      v_email_enabled AND v_order.reminder_email
    );

    UPDATE public.orders
    SET reminder_sent = true, updated_at = now()
    WHERE id = v_order.id;

    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;
