-- ============================================================
-- Update Admin RPC: Robust User Deletion (Ignore missing tables)
-- Migration 00080
-- ============================================================

CREATE OR REPLACE FUNCTION public.admin_delete_user(p_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_caller_id uuid := auth.uid();
  v_table text;
BEGIN
  -- ── 1. Verify caller is a platform sysadmin using new RBAC ──
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Unauthorized: caller is not a platform sysadmin';
  END IF;

  -- ── 2. Delete data with safety checks (avoiding missing tables) ──
  -- We use dynamic SQL to check if a table exists before deleting.

  -- rental_extensions
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'rental_extensions') THEN
    EXECUTE 'DELETE FROM public.rental_extensions WHERE order_id IN (SELECT id FROM public.orders WHERE buyer_id = $1 OR seller_id = $1)' USING p_user_id;
    EXECUTE 'DELETE FROM public.rental_extensions WHERE requested_by = $1' USING p_user_id;
  END IF;

  -- order_evidence
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'order_evidence') THEN
    EXECUTE 'DELETE FROM public.order_evidence WHERE order_id IN (SELECT id FROM public.orders WHERE buyer_id = $1 OR seller_id = $1)' USING p_user_id;
  END IF;

  -- orders
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'orders') THEN
    EXECUTE 'DELETE FROM public.orders WHERE buyer_id = $1 OR seller_id = $1' USING p_user_id;
  END IF;

  -- notifications
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'notifications') THEN
    EXECUTE 'DELETE FROM public.notifications WHERE user_id = $1' USING p_user_id;
  END IF;

  -- messages
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'messages') THEN
    EXECUTE 'DELETE FROM public.messages WHERE sender_id = $1' USING p_user_id;
  END IF;

  -- chat_rooms
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'chat_rooms') THEN
    EXECUTE 'DELETE FROM public.chat_rooms WHERE buyer_id = $1 OR seller_id = $1' USING p_user_id;
  END IF;

  -- saved_listings
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'saved_listings') THEN
    EXECUTE 'DELETE FROM public.saved_listings WHERE user_id = $1' USING p_user_id;
  END IF;

  -- listings
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'listings') THEN
    EXECUTE 'DELETE FROM public.listings WHERE seller_id = $1' USING p_user_id;
  END IF;

  -- content_reports
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'content_reports') THEN
    EXECUTE 'DELETE FROM public.content_reports WHERE reporter_id = $1 OR reported_user_id = $1' USING p_user_id;
  END IF;

  -- moderation_queue
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'moderation_queue') THEN
    EXECUTE 'DELETE FROM public.moderation_queue WHERE user_id = $1' USING p_user_id;
  END IF;

  -- user_feedbacks
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_feedbacks') THEN
    EXECUTE 'DELETE FROM public.user_feedbacks WHERE user_id = $1' USING p_user_id;
  END IF;

  -- user_active_sessions
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_active_sessions') THEN
    EXECUTE 'DELETE FROM public.user_active_sessions WHERE user_id = $1' USING p_user_id;
  END IF;

  -- admin_roles
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'admin_roles') THEN
    EXECUTE 'DELETE FROM public.admin_roles WHERE user_id = $1' USING p_user_id;
  END IF;

  -- school_admins
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'school_admins') THEN
    EXECUTE 'DELETE FROM public.school_admins WHERE user_id = $1' USING p_user_id;
  END IF;

  -- admin_audit_logs (allow test admins to be deleted)
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'admin_audit_logs') THEN
    EXECUTE 'DELETE FROM public.admin_audit_logs WHERE admin_id = $1' USING p_user_id;
  END IF;

  -- user_bans
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_bans') THEN
    EXECUTE 'DELETE FROM public.user_bans WHERE user_id = $1' USING p_user_id;
  END IF;

  -- user_reviews
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_reviews') THEN
    EXECUTE 'DELETE FROM public.user_reviews WHERE reviewer_id = $1 OR target_user_id = $1' USING p_user_id;
  END IF;

  -- ── 3. Delete user_profile and auth ─────────────────────────
  DELETE FROM public.user_profiles WHERE id = p_user_id;
  DELETE FROM auth.users WHERE id = p_user_id;

  -- ── 4. Write audit log ─────────────────────────────────────
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'admin_audit_logs') THEN
    INSERT INTO public.admin_audit_logs (
      admin_id, action, target_type, target_id, payload
    ) VALUES (
      v_caller_id,
      'admin_delete_user',
      'user',
      p_user_id,
      jsonb_build_object('deleted_by', v_caller_id, 'deleted_at', now())
    );
  END IF;

  RETURN jsonb_build_object('success', true, 'deleted_user_id', p_user_id);

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Failed to delete user %: %', p_user_id, SQLERRM;
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_delete_user(uuid) TO authenticated;
