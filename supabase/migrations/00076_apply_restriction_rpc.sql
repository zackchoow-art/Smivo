-- Migration 00076: apply_restriction RPC — Stacking Strategy (Accumulation)
--
-- Centralises all restriction creation through one SECURITY DEFINER function.
-- Implements "accumulation" strategy:
--   • If the user already has an active restriction of the same scope,
--     the new duration is ADDED onto the current expires_at (stacked).
--   • If no active restriction exists, a fresh record is inserted.
--
-- Returns jsonb: { "action": "created"|"extended"|"superseded",
--                  "ban_id": uuid,
--                  "new_expires_at": timestamptz|null,
--                  "prev_expires_at": timestamptz|null }
--
-- NOTE: "superseded" is returned when a permanent ban already exists —
-- the new temporary restriction is recorded but the permanent ban stays.

CREATE OR REPLACE FUNCTION public.apply_restriction(
  p_user_id       uuid,
  p_college_id    uuid,
  p_admin_id      uuid,
  p_scope         text,
  p_ban_type      text,           -- 'temporary' | 'permanent'
  p_duration_days numeric,        -- NULL for permanent
  p_reason_code   text,
  p_reason_detail text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_existing_id      uuid;
  v_existing_expires timestamptz;
  v_existing_type    text;
  v_new_expires      timestamptz;
  v_new_ban_id       uuid;
  v_action           text;
  v_now              timestamptz := now();
  v_combined_detail  text;
BEGIN
  -- ── 1. Find current active restriction of the same scope ─────────────────
  SELECT id, expires_at, ban_type
  INTO v_existing_id, v_existing_expires, v_existing_type
  FROM public.user_bans
  WHERE user_id   = p_user_id
    AND scope     = p_scope
    AND lifted_at IS NULL
    AND (expires_at IS NULL OR expires_at > v_now)
  ORDER BY expires_at DESC NULLS FIRST
  LIMIT 1;

  -- ── 2. Branch: existing permanent ban → record but treat as superseded ────
  IF v_existing_id IS NOT NULL AND v_existing_type = 'permanent' THEN
    -- NOTE: A permanent ban already covers any shorter punishment.
    -- We still insert the new record for audit trail, but it won't
    -- change the user's effective restriction state.
    v_combined_detail := coalesce(p_reason_detail, '') ||
                         ' [Stacked — permanent restriction already active]';

    IF p_ban_type = 'temporary' AND p_duration_days IS NOT NULL THEN
      v_new_expires := v_now + (p_duration_days * interval '1 day');
    ELSE
      v_new_expires := NULL;
    END IF;

    INSERT INTO public.user_bans (
      user_id, college_id, ban_type, scope,
      reason_code, reason_detail, duration_days,
      expires_at, banned_by, banned_at
    ) VALUES (
      p_user_id, p_college_id, p_ban_type, p_scope,
      p_reason_code, v_combined_detail, p_duration_days,
      v_new_expires, p_admin_id, v_now
    ) RETURNING id INTO v_new_ban_id;

    v_action := 'superseded';

  -- ── 3. Branch: existing temporary restriction → ACCUMULATE ───────────────
  ELSIF v_existing_id IS NOT NULL THEN
    -- Stack: new duration starts from max(now, existing_expires_at)
    -- This ensures duration is never lost even if admin acts early.
    DECLARE
      v_base timestamptz := GREATEST(v_existing_expires, v_now);
    BEGIN
      IF p_ban_type = 'permanent' THEN
        -- Escalation to permanent overrides everything
        v_new_expires := NULL;
      ELSE
        v_new_expires := v_base + (p_duration_days * interval '1 day');
      END IF;

      -- Append reason to the existing record for full audit trail
      v_combined_detail := (
        SELECT COALESCE(ub.reason_detail, '') ||
               E'\n[+' || to_char(p_duration_days, 'FM999990.999') || 'd stacked on ' ||
               to_char(v_now, 'YYYY-MM-DD') || '] ' || coalesce(p_reason_detail, '')
        FROM public.user_bans ub WHERE ub.id = v_existing_id
      );

      UPDATE public.user_bans
      SET expires_at    = v_new_expires,
          ban_type      = CASE WHEN p_ban_type = 'permanent' THEN 'permanent'
                               ELSE ban_type END,
          reason_detail = v_combined_detail,
          duration_days = coalesce(duration_days, 0) + coalesce(p_duration_days, 0)
      WHERE id = v_existing_id;

      v_new_ban_id := v_existing_id;
      v_action     := 'extended';
    END;

  -- ── 4. Branch: no active restriction → fresh INSERT ──────────────────────
  ELSE
    IF p_ban_type = 'permanent' THEN
      v_new_expires := NULL;
    ELSIF p_duration_days IS NOT NULL THEN
      -- Add 60s padding to prevent instant expiration due to clock drift
      v_new_expires := v_now + (p_duration_days * interval '1 day') + interval '60 seconds';
    ELSE
      v_new_expires := NULL;
    END IF;

    INSERT INTO public.user_bans (
      user_id, college_id, ban_type, scope,
      reason_code, reason_detail, duration_days,
      expires_at, banned_by, banned_at
    ) VALUES (
      p_user_id, p_college_id, p_ban_type, p_scope,
      p_reason_code, p_reason_detail, p_duration_days,
      v_new_expires, p_admin_id, v_now
    ) RETURNING id INTO v_new_ban_id;

    v_action := 'created';
  END IF;

  -- ── 5. Audit log ──────────────────────────────────────────────────────────
  INSERT INTO public.admin_audit_logs (
    admin_id, action, target_type, target_id, payload
  ) VALUES (
    p_admin_id,
    'apply_restriction',
    'user',
    p_user_id,
    jsonb_build_object(
      'action',        v_action,
      'scope',         p_scope,
      'ban_type',      p_ban_type,
      'duration_days', p_duration_days,
      'reason_code',   p_reason_code,
      'ban_id',        v_new_ban_id,
      'new_expires_at', v_new_expires
    )
  );

  -- ── 6. Return result ──────────────────────────────────────────────────────
  RETURN jsonb_build_object(
    'action',         v_action,
    'ban_id',         v_new_ban_id,
    'new_expires_at', v_new_expires,
    'prev_expires_at', v_existing_expires
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.apply_restriction TO authenticated;

COMMENT ON FUNCTION public.apply_restriction IS
  'Centralised restriction enforcement using the accumulation (stacking) strategy.
   If an active restriction of the same scope already exists, the new duration
   is appended to the current expiry (stacked). Otherwise a fresh record is created.
   Returns jsonb: { action, ban_id, new_expires_at, prev_expires_at }.
   action values: "created" | "extended" | "superseded"';
