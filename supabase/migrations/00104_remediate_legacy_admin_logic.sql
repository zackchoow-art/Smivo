-- ═══════════════════════════════════════════════════════════════
-- Migration 00104: Remediate legacy admin references and fix order flow
-- ═══════════════════════════════════════════════════════════════
-- 1. Fix broken helper functions that reference dropped admin_users
-- 2. Clean up legacy RLS policies on school dictionary tables
-- 3. Fix notification trigger to support 'missed' status
-- ═══════════════════════════════════════════════════════════════

BEGIN;

-- ── 1. Fix is_active_admin() ──────────────────────────────────
-- This function is used in many RLS policies (listings, orders, etc.)
CREATE OR REPLACE FUNCTION public.is_active_admin()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT public.is_admin_user();
$$;

-- ── 2. Fix is_platform_super_admin() ──────────────────────────
-- Used in schools and admin_school_scopes policies
CREATE OR REPLACE FUNCTION public.is_platform_super_admin()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT public.is_platform_sysadmin();
$$;

-- ── 3. Fix school dictionary tables policies ──────────────────
-- These were directly querying admin_users in migration 00092

-- school_categories
DROP POLICY IF EXISTS "Categories readable by all authenticated" ON public.school_categories;
CREATE POLICY "Categories readable by all authenticated"
  ON public.school_categories FOR SELECT
  USING (
    is_active = true
    OR public.is_admin_user()
  );

DROP POLICY IF EXISTS "Admins can write school_categories" ON public.school_categories;
CREATE POLICY "Admins can write school_categories"
  ON public.school_categories FOR ALL
  USING (public.is_admin_user())
  WITH CHECK (public.is_admin_user());

-- school_conditions
DROP POLICY IF EXISTS "Conditions readable by all authenticated" ON public.school_conditions;
CREATE POLICY "Conditions readable by all authenticated"
  ON public.school_conditions FOR SELECT
  USING (
    is_active = true
    OR public.is_admin_user()
  );

DROP POLICY IF EXISTS "Admins can write school_conditions" ON public.school_conditions;
CREATE POLICY "Admins can write school_conditions"
  ON public.school_conditions FOR ALL
  USING (public.is_admin_user())
  WITH CHECK (public.is_admin_user());

-- pickup_locations
DROP POLICY IF EXISTS "Pickup locations readable" ON public.pickup_locations;
CREATE POLICY "Pickup locations readable"
  ON public.pickup_locations FOR SELECT
  USING (
    is_active = true
    OR public.is_admin_user()
  );

DROP POLICY IF EXISTS "Admins can write pickup_locations" ON public.pickup_locations;
CREATE POLICY "Admins can write pickup_locations"
  ON public.pickup_locations FOR ALL
  USING (public.is_admin_user())
  WITH CHECK (public.is_admin_user());


-- ── 4. Fix Notification Trigger to handle 'missed' status ──────
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

  -- NOTE: Use qualified name public.listings because of search_path = ''
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

  -- Case B: → cancelled (Manually)
  IF new.status = 'cancelled' THEN
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

  -- Case C: → missed (Auto-rejected because seller chose another buyer)
  IF new.status = 'missed' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      NEW.buyer_id, 'order_cancelled', 'Offer Missed',
      'Another buyer was selected for "' || v_title_snippet || '". Keep browsing for more great deals!',
      NEW.id, 'order'
    );
    -- Seller does NOT need a notification for auto-cancelled orders
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

-- ── 5. Final Schema Reload ────────────────────────────────────
NOTIFY pgrst, 'reload schema';

COMMIT;
