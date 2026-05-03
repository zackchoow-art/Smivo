-- ============================================================
-- Update Admin RPC: Use correct RBAC check
-- Migration 00079
-- ============================================================

CREATE OR REPLACE FUNCTION public.admin_delete_user(p_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_caller_id uuid := auth.uid();
BEGIN
  -- ── 1. Verify caller is a platform sysadmin using new RBAC ──
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Unauthorized: caller is not a platform sysadmin';
  END IF;

  -- ── 2. Delete in dependency order ─────────────────────────

  -- Rental extensions reference orders
  DELETE FROM public.rental_extensions WHERE order_id IN (
    SELECT id FROM public.orders
    WHERE buyer_id = p_user_id OR seller_id = p_user_id
  );

  -- Order evidence references orders
  DELETE FROM public.order_evidence WHERE order_id IN (
    SELECT id FROM public.orders
    WHERE buyer_id = p_user_id OR seller_id = p_user_id
  );

  -- Notifications linked to orders
  DELETE FROM public.notifications WHERE user_id = p_user_id;

  -- Orders (must be deleted before listings due to RESTRICT FK)
  DELETE FROM public.orders
  WHERE buyer_id = p_user_id OR seller_id = p_user_id;

  -- Chat messages sent by this user
  DELETE FROM public.messages WHERE sender_id = p_user_id;

  -- Chat rooms where user is buyer or seller
  DELETE FROM public.chat_rooms
  WHERE buyer_id = p_user_id OR seller_id = p_user_id;

  -- Saved listings
  DELETE FROM public.saved_listings WHERE user_id = p_user_id;

  -- Listing images are cascade-deleted with listings
  -- Listings (can now be deleted safely)
  DELETE FROM public.listings WHERE seller_id = p_user_id;

  -- Content reports filed by or against the user
  DELETE FROM public.content_reports
  WHERE reporter_id = p_user_id OR reported_user_id = p_user_id;

  -- Moderation queue items
  DELETE FROM public.moderation_queue WHERE user_id = p_user_id;

  -- User feedbacks
  DELETE FROM public.user_feedbacks WHERE user_id = p_user_id;

  -- User active sessions / heartbeat
  DELETE FROM public.user_active_sessions WHERE user_id = p_user_id;

  -- Admin roles (if this user was an admin)
  DELETE FROM public.admin_roles WHERE user_id = p_user_id;
  DELETE FROM public.school_admins WHERE user_id = p_user_id;

  -- Reviews (Table not created yet in current phase)
  -- DELETE FROM public.reviews
  -- WHERE reviewer_id = p_user_id OR reviewee_id = p_user_id;

  -- User restrictions
  DELETE FROM public.user_restrictions WHERE user_id = p_user_id;

  -- Audit logs authored by this admin (optional: keep for record)
  -- We intentionally keep admin_audit_logs for compliance.

  -- ── 3. Delete user_profile (cascades remaining child rows) ─
  DELETE FROM public.user_profiles WHERE id = p_user_id;

  -- ── 4. Delete the auth user ────────────────────────────────
  DELETE FROM auth.users WHERE id = p_user_id;

  -- ── 5. Write audit log ─────────────────────────────────────
  INSERT INTO public.admin_audit_logs (
    admin_id, action, target_type, target_id, payload
  ) VALUES (
    v_caller_id,
    'admin_delete_user',
    'user',
    p_user_id,
    jsonb_build_object('deleted_by', v_caller_id, 'deleted_at', now())
  );

  RETURN jsonb_build_object('success', true, 'deleted_user_id', p_user_id);

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Failed to delete user %: %', p_user_id, SQLERRM;
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_delete_user(uuid) TO authenticated;
