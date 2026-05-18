-- ============================================================
-- Migration 00182: Per-member pin, archive, unread-override for group chats
-- ============================================================
-- DESIGN DECISION: Store pin/archive/unread as per-member preferences
-- on group_chat_members, NOT on group_chat_rooms.
-- Rationale: These are personal UI state (like email flags), not global
-- room properties. Each member should be able to pin or archive
-- independently without affecting other members' chat list views.
-- This mirrors the is_pinned/is_archived/is_unread_override columns
-- already present on chat_rooms for 1-on-1 conversations.
-- ============================================================

-- ── 1. Add preference columns to group_chat_members ────────────
ALTER TABLE public.group_chat_members
  ADD COLUMN IF NOT EXISTS is_pinned          boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_archived        boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_unread_override boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.group_chat_members.is_pinned IS
  'User-specific: pin this group chat to the top of their chat list.';
COMMENT ON COLUMN public.group_chat_members.is_archived IS
  'User-specific: hide this group chat from the active list.';
COMMENT ON COLUMN public.group_chat_members.is_unread_override IS
  'User-specific: force-mark as unread (manual "mark unread" action).';

-- ── 2. Allow each member to update their own membership row ────
-- The existing RLS policy "System can manage group membership" (ALL)
-- already covers auth.uid() = user_id, which allows UPDATE.
-- However to be explicit and not rely on the catch-all policy,
-- add a dedicated UPDATE policy scoped to self-updates only.
DROP POLICY IF EXISTS "Members can update their own group membership prefs"
  ON public.group_chat_members;

CREATE POLICY "Members can update their own group membership prefs"
  ON public.group_chat_members FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

NOTIFY pgrst, 'reload schema';
