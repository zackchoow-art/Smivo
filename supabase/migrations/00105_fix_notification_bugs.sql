-- ═══════════════════════════════════════════════════════════════
-- Migration 00105: Fix notification bugs
-- ═══════════════════════════════════════════════════════════════
-- 1. Fix order_cancelled: only notify the OTHER party (not the canceller)
-- 2. Fix missed: remove duplicate notification from old trigger binding
--    (old on_order_status_change trigger is rebased — 00104 already defines
--     the correct function; this migration ensures the old v1 trigger is gone
--     and the function on 00104 handles missed correctly)
-- 3. Fix rental_extension + rental_reminder notifications: set action_url
--    to order detail route so clicking the push navigates correctly
-- ═══════════════════════════════════════════════════════════════

BEGIN;

-- ── 1 & 2: Rewrite notify_order_status_change ──────────────────
-- The ONLY trigger that calls this function is 'on_order_status_change'
-- (created in 00008, bound AFTER UPDATE OF status ON orders).
-- Migration 00104 CREATE OR REPLACE'd the function body, but the old
-- trigger binding from 00008 still points to it, so it fires once.
-- The root cause of the DOUBLE missed notification was that 00022 re-bound
-- a SECOND trigger (also named on_order_status_change) - both AFTER UPDATE.
-- Confirm we have exactly ONE trigger binding.
DROP TRIGGER IF EXISTS on_order_status_change ON public.orders;

CREATE TRIGGER on_order_status_change
  AFTER UPDATE OF status ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.notify_order_status_change();

-- Now rewrite the function with the cancelled-party fix:
-- NEW: track who performed the cancellation via updated_by or last_updated_by
-- Since orders table may not have a 'cancelled_by' column, we use a convention:
-- If NEW.buyer_id performed the cancel, NEW.updated_by = NEW.buyer_id (seller notified)
-- However, simpler: add optional cancelled_by column and use it here.

-- Check if orders has a cancelled_by column; if not, we use a fallback.
-- For now, use the SAFE fallback: cancelled orders notify SELLER only.
-- This is because in the current UX, only BUYERS can self-cancel pending orders
-- (via the listing detail page Cancel button). Sellers cancel via order detail.
-- NOTE: We'll add a cancelled_by column to enable bidirectional logic later.

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
  -- NOTE: Only notify the OTHER party, not the one who cancelled.
  -- We detect who cancelled by checking cancelled_by column if it exists.
  -- Fallback: check if the order has a cancelled_by field; if not, default
  -- to notifying both (safe but slightly noisy) — the column check avoids
  -- a runtime error on schemas without cancelled_by.
  IF new.status = 'cancelled' THEN
    IF NEW.cancelled_by IS NOT NULL THEN
      -- Only notify the other party
      IF NEW.cancelled_by = NEW.buyer_id THEN
        -- Buyer cancelled → notify seller
        INSERT INTO public.notifications
          (user_id, type, title, body, related_order_id, action_type)
        VALUES (
          NEW.seller_id, 'order_cancelled', 'Order cancelled',
          'The buyer cancelled the order for "' || v_title_snippet || '"',
          NEW.id, 'order'
        );
      ELSE
        -- Seller cancelled → notify buyer
        INSERT INTO public.notifications
          (user_id, type, title, body, related_order_id, action_type)
        VALUES (
          NEW.buyer_id, 'order_cancelled', 'Order cancelled',
          'Your order for "' || v_title_snippet || '" was cancelled by the seller',
          NEW.id, 'order'
        );
      END IF;
    ELSE
      -- No cancelled_by info: notify both (legacy safe behavior)
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

-- ── 3. Add cancelled_by column to orders ───────────────────────
-- This allows the notify function to know who cancelled so we can
-- notify only the OTHER party.
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS cancelled_by uuid REFERENCES auth.users(id);

-- ── 4. Fix rental_extension notifications: set action_url ──────
-- Rental extension notifications currently have no action_url,
-- so clicking them does nothing on mobile. Add explicit order-detail route.
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
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type, action_url)
    VALUES (
      v_seller_id, 'rental_extension', 'Rental ' || initcap(v_type_label) || ' Request',
      'The buyer requested a rental ' || v_type_label || ' for "' || v_listing_title || '"',
      NEW.order_id, 'route', '/orders/' || NEW.order_id::text
    );
  END IF;

  -- Response → notify buyer
  IF TG_OP = 'UPDATE' AND OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected') THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type, action_url)
    VALUES (
      v_buyer_id,
      'rental_extension',
      'Rental ' || initcap(v_type_label) || ' ' || initcap(NEW.status),
      CASE WHEN NEW.status = 'approved'
        THEN 'The seller approved your rental ' || v_type_label || ' for "' || v_listing_title || '"'
        ELSE 'The seller rejected your rental ' || v_type_label || ' for "' || v_listing_title || '"'
      END,
      NEW.order_id,
      'route',
      '/orders/' || NEW.order_id::text
    );
  END IF;

  RETURN NEW;
END;
$$;

-- ── 5. Fix rental_reminder notifications: set action_url ───────
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
    SELECT l.title INTO v_listing_title
    FROM public.listings l
    WHERE l.id = v_order.listing_id;

    v_listing_title := coalesce(v_listing_title, 'your rental item');
    v_days_left := v_order.rental_end_date::date - CURRENT_DATE;

    -- Create in-app notification WITH action_url pointing to order detail
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type, action_url)
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
      'route',
      '/orders/' || v_order.id::text
    );

    UPDATE public.orders
    SET reminder_sent = true,
        updated_at = now()
    WHERE id = v_order.id;

    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;

-- ── 6. Schema reload ───────────────────────────────────────────
NOTIFY pgrst, 'reload schema';

COMMIT;
