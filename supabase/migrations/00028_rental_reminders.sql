-- ════════════════════════════════════════════════════════════
-- 00028: Rental Reminder System
--
-- 1. Add reminder preference fields to orders table
-- 2. Add 'rental_reminder' + 'rental_extension' to notification type constraint
-- 3. Create function to check and send rental expiry reminders
-- 4. Optionally set up pg_cron schedule
-- ════════════════════════════════════════════════════════════

-- ─── 1. Add reminder fields to orders ───

ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS reminder_days_before integer DEFAULT 1,
  ADD COLUMN IF NOT EXISTS reminder_email boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS reminder_sent boolean DEFAULT false;

-- ─── 2. Update notification type constraint ───

ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check CHECK (
    type = ANY (ARRAY[
      'order_placed'::text,
      'order_accepted'::text,
      'order_cancelled'::text,
      'order_delivered'::text,
      'order_completed'::text,
      'rental_reminder'::text,
      'rental_extension'::text,
      'system'::text
    ])
  );

-- ─── 3. Reminder check function ───

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
    -- Get listing title for notification body
    SELECT l.title INTO v_listing_title
    FROM public.listings l
    WHERE l.id = v_order.listing_id;

    v_listing_title := coalesce(v_listing_title, 'your rental item');
    v_days_left := v_order.rental_end_date::date - CURRENT_DATE;

    -- Create in-app notification
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      v_order.buyer_id,
      'rental_reminder',
      'Rental Expiring Soon',
      CASE
        WHEN v_days_left = 0 THEN '"' || v_listing_title || '" rental expires today!'
        WHEN v_days_left = 1 THEN '"' || v_listing_title || '" rental expires tomorrow'
        ELSE '"' || v_listing_title || '" rental expires in ' || v_days_left || ' days'
      END,
      v_order.id,
      'order'
    );

    -- Mark reminder as sent
    UPDATE public.orders
    SET reminder_sent = true,
        updated_at = now()
    WHERE id = v_order.id;

    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;

-- ─── 4. Reset reminder_sent when rental_end_date changes ───

CREATE OR REPLACE FUNCTION public.reset_rental_reminder()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF OLD.rental_end_date IS DISTINCT FROM NEW.rental_end_date THEN
    NEW.reminder_sent := false;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_rental_end_date_change ON public.orders;
CREATE TRIGGER on_rental_end_date_change
  BEFORE UPDATE OF rental_end_date ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.reset_rental_reminder();
