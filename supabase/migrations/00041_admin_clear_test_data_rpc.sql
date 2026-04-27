-- =============================================================
-- Migration 00041: Admin clear test data RPC
-- =============================================================
-- Server-side function that bypasses RLS to delete all
-- user-generated data. Only callable by platform sysadmins.
-- Uses TRUNCATE CASCADE (same as the proven reset_test_data.sql).
-- =============================================================

CREATE OR REPLACE FUNCTION public.admin_clear_test_data()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_counts jsonb := '{}'::jsonb;
  v_count integer;
BEGIN
  -- Guard: only platform sysadmins can execute
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: requires platform sysadmin role'
      USING ERRCODE = 'P0001';
  END IF;

  -- Collect counts before truncation
  SELECT count(*) INTO v_count FROM public.order_evidence;
  v_counts := v_counts || jsonb_build_object('order_evidence', v_count);

  SELECT count(*) INTO v_count FROM public.rental_extensions;
  v_counts := v_counts || jsonb_build_object('rental_extensions', v_count);

  SELECT count(*) INTO v_count FROM public.notifications;
  v_counts := v_counts || jsonb_build_object('notifications', v_count);

  SELECT count(*) INTO v_count FROM public.orders;
  v_counts := v_counts || jsonb_build_object('orders', v_count);

  SELECT count(*) INTO v_count FROM public.messages;
  v_counts := v_counts || jsonb_build_object('messages', v_count);

  SELECT count(*) INTO v_count FROM public.chat_rooms;
  v_counts := v_counts || jsonb_build_object('chat_rooms', v_count);

  SELECT count(*) INTO v_count FROM public.saved_listings;
  v_counts := v_counts || jsonb_build_object('saved_listings', v_count);

  SELECT count(*) INTO v_count FROM public.listing_views;
  v_counts := v_counts || jsonb_build_object('listing_views', v_count);

  SELECT count(*) INTO v_count FROM public.listing_images;
  v_counts := v_counts || jsonb_build_object('listing_images', v_count);

  SELECT count(*) INTO v_count FROM public.listings;
  v_counts := v_counts || jsonb_build_object('listings', v_count);

  -- Truncate in FK-safe order (same as reset_test_data.sql)
  TRUNCATE public.order_evidence CASCADE;
  TRUNCATE public.rental_extensions CASCADE;
  TRUNCATE public.notifications CASCADE;
  TRUNCATE public.orders CASCADE;
  TRUNCATE public.messages CASCADE;
  TRUNCATE public.chat_rooms CASCADE;
  TRUNCATE public.saved_listings CASCADE;
  TRUNCATE public.listing_views CASCADE;
  TRUNCATE public.listing_images CASCADE;
  TRUNCATE public.listings CASCADE;

  RETURN v_counts;
END;
$$;
