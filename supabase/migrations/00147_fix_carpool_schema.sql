-- ============================================================
-- Migration 00147: Fix carpool schema ordering issues
-- ============================================================
-- Fixes:
-- 1. Re-create is_group_chat_member helper (table now exists)
-- 2. Add missing RLS policies that depended on functions/tables
--    not yet created in 00145
-- 3. Fix system_configs empty string → valid value
-- 4. Re-create carpool_trips member-read policy
-- ============================================================


-- ─── 1. Re-create is_group_chat_member (table now exists) ────

CREATE OR REPLACE FUNCTION public.is_group_chat_member(p_room_id uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.group_chat_members
    WHERE room_id = p_room_id AND user_id = auth.uid()
  );
$$;


-- ─── 2. group_chat_rooms: add member-read policy ─────────────

-- Drop the placeholder policy if it was created
DROP POLICY IF EXISTS "Group members can read their chat rooms" ON public.group_chat_rooms;
CREATE POLICY "Group members can read their chat rooms"
  ON public.group_chat_rooms FOR SELECT
  USING (public.is_group_chat_member(id));


-- ─── 3. group_chat_members: add member-read policy ──────────

DROP POLICY IF EXISTS "Members can read their group memberships" ON public.group_chat_members;
CREATE POLICY "Members can read their group memberships"
  ON public.group_chat_members FOR SELECT
  USING (public.is_group_chat_member(room_id) OR auth.uid() = user_id);


-- ─── 4. group_messages: add member policies ─────────────────

DROP POLICY IF EXISTS "Group members can read messages" ON public.group_messages;
CREATE POLICY "Group members can read messages"
  ON public.group_messages FOR SELECT
  USING (public.is_group_chat_member(room_id));

DROP POLICY IF EXISTS "Group members can send messages" ON public.group_messages;
CREATE POLICY "Group members can send messages"
  ON public.group_messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND public.is_group_chat_member(room_id)
  );


-- ─── 5. carpool_trips: re-create member read policy ─────────

DROP POLICY IF EXISTS "Members can read their trips" ON public.carpool_trips;
CREATE POLICY "Members can read their trips"
  ON public.carpool_trips FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.carpool_members
      WHERE trip_id = id AND user_id = auth.uid() AND status = 'approved'
    )
  );


-- ─── 6. Fix system_configs — use placeholder text, not empty ─

DELETE FROM public.system_configs
WHERE config_key IN ('apple_maps_token', 'google_maps_places_api_key', 'google_maps_directions_api_key');

INSERT INTO public.system_configs (config_key, config_value, description)
VALUES
  ('apple_maps_token', 'PLACEHOLDER', 'Apple MapKit JS token (for web fallback if needed)'),
  ('google_maps_places_api_key', 'PLACEHOLDER', 'Google Places API key (future use)'),
  ('google_maps_directions_api_key', 'PLACEHOLDER', 'Google Directions API key (future use)')
ON CONFLICT (config_key) DO NOTHING;
