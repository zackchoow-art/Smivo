-- Migration 00063: Granular User Restrictions
-- Upgrades the binary ban system to support multiple restriction scopes.
-- A single user can have multiple concurrent active restrictions.

-- 1. Add scope column to user_bans
-- Default is 'account_freeze' for backwards compatibility with existing bans.
ALTER TABLE public.user_bans
  ADD COLUMN IF NOT EXISTS scope text NOT NULL DEFAULT 'account_freeze'
  CHECK (scope IN ('chat_mute', 'listing_ban', 'feedback_ban', 'account_freeze'));

-- 2. Add composite index for efficient per-user scope lookups
CREATE INDEX IF NOT EXISTS idx_bans_user_scope
  ON public.user_bans(user_id, scope)
  WHERE lifted_at IS NULL;

-- 3. RPC for Flutter app to check active restrictions for a given user.
-- Returns a set of rows with scope and expires_at for each active restriction.
-- Usage: SELECT * FROM get_active_restrictions('some-user-uuid');
CREATE OR REPLACE FUNCTION public.get_active_restrictions(target_user_id uuid)
RETURNS TABLE(scope text, expires_at timestamptz)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT ub.scope, ub.expires_at
  FROM public.user_bans ub
  WHERE ub.user_id = target_user_id
    AND ub.lifted_at IS NULL
    AND (ub.expires_at IS NULL OR ub.expires_at > now())
  ORDER BY ub.scope;
$$;

-- 4. RPC for Flutter app to check if a specific user has a specific restriction.
-- Usage: SELECT is_user_restricted('some-user-uuid', 'chat_mute');
CREATE OR REPLACE FUNCTION public.is_user_restricted(target_user_id uuid, restriction_scope text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_bans ub
    WHERE ub.user_id = target_user_id
      AND ub.scope = restriction_scope
      AND ub.lifted_at IS NULL
      AND (ub.expires_at IS NULL OR ub.expires_at > now())
  );
$$;

-- 5. RPC to get restriction detail (for showing "muted until XX" messages).
-- Returns the restriction row with the latest expiry for a given scope.
CREATE OR REPLACE FUNCTION public.get_restriction_detail(target_user_id uuid, restriction_scope text)
RETURNS TABLE(scope text, expires_at timestamptz, reason_detail text)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT ub.scope, ub.expires_at, ub.reason_detail
  FROM public.user_bans ub
  WHERE ub.user_id = target_user_id
    AND ub.scope = restriction_scope
    AND ub.lifted_at IS NULL
    AND (ub.expires_at IS NULL OR ub.expires_at > now())
  ORDER BY ub.expires_at DESC NULLS FIRST
  LIMIT 1;
$$;
