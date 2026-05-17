-- ============================================================
-- Migration 00170: Admin RLS & Status Update RPC for Carpool
-- ============================================================
-- 1. Adds RLS policies so admin users can SELECT all carpool_trips
--    and carpool_members (bypasses the participant-only policies).
-- 2. Creates admin_update_carpool_status() RPC that allows
--    school_admin and above to change a trip's status, with
--    audit logging.
-- ============================================================


-- ═══════════════════════════════════════════════════════════════
-- 1. Admin read policies for carpool_trips
-- ═══════════════════════════════════════════════════════════════

-- NOTE: is_admin_user() is a SECURITY DEFINER function from migration 00102
-- that returns TRUE for any user with an active row in admin_roles.

CREATE POLICY "Admin users can read all carpool trips"
  ON public.carpool_trips FOR SELECT
  USING (public.is_admin_user());


-- ═══════════════════════════════════════════════════════════════
-- 2. Admin read policies for carpool_members
-- ═══════════════════════════════════════════════════════════════

CREATE POLICY "Admin users can read all carpool members"
  ON public.carpool_members FOR SELECT
  USING (public.is_admin_user());


-- ═══════════════════════════════════════════════════════════════
-- 3. Admin status update RPC
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.admin_update_carpool_status(
  p_trip_id   uuid,
  p_new_status text,
  p_reason     text DEFAULT ''
)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_caller_id     uuid;
  v_caller_role   text;
  v_trip_school_id uuid;
  v_old_status    text;
  v_scope_id      uuid;
BEGIN
  v_caller_id := auth.uid();

  -- 1. Verify caller has at least school_admin role
  SELECT role, scope_id INTO v_caller_role, v_scope_id
  FROM public.admin_roles
  WHERE user_id = v_caller_id
    AND is_active = true
    AND role IN ('sysadmin', 'platform_admin', 'school_admin')
  ORDER BY
    CASE role
      WHEN 'sysadmin' THEN 1
      WHEN 'platform_admin' THEN 2
      WHEN 'school_admin' THEN 3
    END
  LIMIT 1;

  IF v_caller_role IS NULL THEN
    RAISE EXCEPTION 'Permission denied: requires school_admin or above';
  END IF;

  -- 2. Fetch trip info
  SELECT school_id, status INTO v_trip_school_id, v_old_status
  FROM public.carpool_trips
  WHERE id = p_trip_id;

  IF v_trip_school_id IS NULL THEN
    RAISE EXCEPTION 'Trip not found: %', p_trip_id;
  END IF;

  -- 3. School-scoped admins can only modify trips from their school
  IF v_caller_role = 'school_admin' AND v_scope_id != v_trip_school_id THEN
    RAISE EXCEPTION 'Permission denied: trip belongs to a different school';
  END IF;

  -- 4. Validate new status
  IF p_new_status NOT IN ('active', 'inactive', 'confirmed', 'departed', 'arrived', 'completed', 'cancelled') THEN
    RAISE EXCEPTION 'Invalid status: %', p_new_status;
  END IF;

  -- 5. Prevent no-op updates
  IF v_old_status = p_new_status THEN
    RAISE EXCEPTION 'Trip is already in status: %', p_new_status;
  END IF;

  -- 6. Update the trip status
  UPDATE public.carpool_trips
  SET status = p_new_status, updated_at = now()
  WHERE id = p_trip_id;

  -- 7. Audit log
  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (
    v_caller_id,
    'update_carpool_status',
    'carpool_trip',
    p_trip_id,
    jsonb_build_object(
      'old_status', v_old_status,
      'new_status', p_new_status,
      'reason', p_reason
    )
  );
END;
$$;
