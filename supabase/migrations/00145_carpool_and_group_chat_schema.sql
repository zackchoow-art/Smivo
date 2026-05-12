-- ============================================================
-- Migration 00145: Carpool & Group Chat Core Tables
-- ============================================================
-- Creates the full schema for campus shared rides:
--   carpool_trips, carpool_members, carpool_proposals, carpool_votes,
--   group_chat_rooms, group_chat_members, group_messages.
-- Also adds ios_default_map_provider to schools and map API key
-- entries to system_configs.
-- ============================================================


-- ═══════════════════════════════════════════════════════════════
-- 1. carpool_trips — ride-share trip postings
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE public.carpool_trips (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id              uuid        NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  school_id               uuid        NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  -- 'driver' = creator drives their own car; 'organizer' = creator looking to split ride cost
  role                    text        NOT NULL CHECK (role IN ('driver', 'organizer')),
  departure_address       text        NOT NULL,
  departure_lat           double precision,
  departure_lng           double precision,
  departure_place_id      text,
  destination_address     text        NOT NULL,
  destination_lat         double precision,
  destination_lng         double precision,
  destination_place_id    text,
  departure_time          timestamptz NOT NULL,
  estimated_arrival_time  timestamptz,
  total_seats             integer     NOT NULL CHECK (total_seats BETWEEN 1 AND 4),
  available_seats         integer     NOT NULL CHECK (available_seats >= 0),
  luggage_limit           text        CHECK (luggage_limit IN ('none', 'small', 'medium', 'large')),
  -- 'auto' = anyone can join instantly; 'manual' = creator approves each request
  approval_mode           text        NOT NULL DEFAULT 'manual' CHECK (approval_mode IN ('auto', 'manual')),
  status                  text        NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'departed', 'completed', 'cancelled')),
  closing_time            timestamptz,
  note                    text,
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER carpool_trips_updated_at
  BEFORE UPDATE ON public.carpool_trips
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_carpool_trips_creator  ON public.carpool_trips(creator_id);
CREATE INDEX idx_carpool_trips_school   ON public.carpool_trips(school_id, departure_time DESC)
  WHERE status = 'active';
CREATE INDEX idx_carpool_trips_time     ON public.carpool_trips(departure_time DESC);

ALTER TABLE public.carpool_trips ENABLE ROW LEVEL SECURITY;

-- Active trips are publicly readable (like listings); creator can always see own trips
CREATE POLICY "Active carpool trips are publicly readable"
  ON public.carpool_trips FOR SELECT
  USING (status = 'active' OR auth.uid() = creator_id);

CREATE POLICY "Authenticated users can create carpool trips"
  ON public.carpool_trips FOR INSERT
  WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Creators can update their own trips"
  ON public.carpool_trips FOR UPDATE
  USING (auth.uid() = creator_id);

-- Allow approved members to read trip details regardless of status
-- (they need to see departed/completed trips they participated in)
CREATE POLICY "Members can read their trips"
  ON public.carpool_trips FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.carpool_members
      WHERE trip_id = id AND user_id = auth.uid() AND status = 'approved'
    )
  );


-- ═══════════════════════════════════════════════════════════════
-- 2. carpool_members — participants in each trip
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE public.carpool_members (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id    uuid        NOT NULL REFERENCES public.carpool_trips(id) ON DELETE CASCADE,
  user_id    uuid        NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  -- 'creator' is auto-inserted when trip is created; 'member' requests to join
  role       text        NOT NULL DEFAULT 'member' CHECK (role IN ('creator', 'member')),
  status     text        NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected', 'left', 'kicked')),
  joined_at  timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (trip_id, user_id)
);

CREATE INDEX idx_carpool_members_trip ON public.carpool_members(trip_id);
CREATE INDEX idx_carpool_members_user ON public.carpool_members(user_id);

ALTER TABLE public.carpool_members ENABLE ROW LEVEL SECURITY;

-- Helper function to avoid RLS recursion when checking membership
CREATE OR REPLACE FUNCTION public.is_carpool_member(p_trip_id uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.carpool_members
    WHERE trip_id = p_trip_id AND user_id = auth.uid() AND status = 'approved'
  );
$$;

-- Trip creator can see all members; approved members can see fellow members
CREATE POLICY "Trip participants can read members"
  ON public.carpool_members FOR SELECT
  USING (
    auth.uid() = (SELECT creator_id FROM public.carpool_trips WHERE id = trip_id)
    OR public.is_carpool_member(trip_id)
    OR auth.uid() = user_id  -- users can always see their own membership
  );

CREATE POLICY "Authenticated users can request to join"
  ON public.carpool_members FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Creator can approve/reject; member can set status to 'left'
CREATE POLICY "Creator or self can update membership"
  ON public.carpool_members FOR UPDATE
  USING (
    auth.uid() = user_id
    OR auth.uid() = (SELECT creator_id FROM public.carpool_trips WHERE id = trip_id)
  );


-- ═══════════════════════════════════════════════════════════════
-- 3. carpool_proposals — trip change / kick proposals
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE public.carpool_proposals (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id         uuid        NOT NULL REFERENCES public.carpool_trips(id) ON DELETE CASCADE,
  proposer_id     uuid        NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  proposal_type   text        NOT NULL
    CHECK (proposal_type IN ('change_time', 'change_departure', 'change_destination', 'kick_member')),
  old_value       text,
  new_value       text,
  -- Only set for kick_member proposals
  target_user_id  uuid        REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  status          text        NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected', 'expired')),
  -- Number of votes needed for approval (all approved members except proposer)
  required_votes  integer     NOT NULL,
  current_votes   integer     NOT NULL DEFAULT 0,
  expires_at      timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER carpool_proposals_updated_at
  BEFORE UPDATE ON public.carpool_proposals
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_carpool_proposals_trip ON public.carpool_proposals(trip_id);

ALTER TABLE public.carpool_proposals ENABLE ROW LEVEL SECURITY;

-- Trip members can read proposals
CREATE POLICY "Trip members can read proposals"
  ON public.carpool_proposals FOR SELECT
  USING (public.is_carpool_member(trip_id));

-- Approved members can create proposals
CREATE POLICY "Approved members can create proposals"
  ON public.carpool_proposals FOR INSERT
  WITH CHECK (
    auth.uid() = proposer_id
    AND public.is_carpool_member(trip_id)
  );

-- System updates proposal status via RPC (SECURITY DEFINER)
CREATE POLICY "System can update proposals"
  ON public.carpool_proposals FOR UPDATE
  USING (public.is_carpool_member(trip_id));


-- ═══════════════════════════════════════════════════════════════
-- 4. carpool_votes — individual votes on proposals
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE public.carpool_votes (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id uuid        NOT NULL REFERENCES public.carpool_proposals(id) ON DELETE CASCADE,
  voter_id    uuid        NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  vote        text        NOT NULL CHECK (vote IN ('approve', 'reject')),
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (proposal_id, voter_id)
);

CREATE INDEX idx_carpool_votes_proposal ON public.carpool_votes(proposal_id);

ALTER TABLE public.carpool_votes ENABLE ROW LEVEL SECURITY;

-- Members can read votes for proposals in their trips
CREATE POLICY "Trip members can read votes"
  ON public.carpool_votes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.carpool_proposals p
      WHERE p.id = proposal_id AND public.is_carpool_member(p.trip_id)
    )
  );

-- Approved members can cast votes (actual logic enforced in RPC)
CREATE POLICY "Members can cast votes"
  ON public.carpool_votes FOR INSERT
  WITH CHECK (auth.uid() = voter_id);


-- ═══════════════════════════════════════════════════════════════
-- 5. group_chat_rooms — one per carpool trip
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE public.group_chat_rooms (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id    uuid        NOT NULL REFERENCES public.carpool_trips(id) ON DELETE CASCADE,
  name       text        NOT NULL,
  created_by uuid        NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (trip_id)
);

CREATE TRIGGER group_chat_rooms_updated_at
  BEFORE UPDATE ON public.group_chat_rooms
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.group_chat_rooms ENABLE ROW LEVEL SECURITY;

-- Helper to check group chat membership
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

CREATE POLICY "Group members can read their chat rooms"
  ON public.group_chat_rooms FOR SELECT
  USING (public.is_group_chat_member(id));

-- System creates group chat rooms via RPC
CREATE POLICY "Authenticated users can create group chat rooms"
  ON public.group_chat_rooms FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Creator can update group chat room"
  ON public.group_chat_rooms FOR UPDATE
  USING (auth.uid() = created_by);


-- ═══════════════════════════════════════════════════════════════
-- 6. group_chat_members
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE public.group_chat_members (
  id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id   uuid        NOT NULL REFERENCES public.group_chat_rooms(id) ON DELETE CASCADE,
  user_id   uuid        NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  joined_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (room_id, user_id)
);

CREATE INDEX idx_group_chat_members_room ON public.group_chat_members(room_id);
CREATE INDEX idx_group_chat_members_user ON public.group_chat_members(user_id);

ALTER TABLE public.group_chat_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can read their group memberships"
  ON public.group_chat_members FOR SELECT
  USING (public.is_group_chat_member(room_id) OR auth.uid() = user_id);

-- Managed by RPC (join/leave carpool triggers add/remove members)
CREATE POLICY "System can manage group membership"
  ON public.group_chat_members FOR ALL
  USING (
    auth.uid() = user_id
    OR auth.uid() = (
      SELECT created_by FROM public.group_chat_rooms WHERE id = room_id
    )
  );


-- ═══════════════════════════════════════════════════════════════
-- 7. group_messages
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE public.group_messages (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id      uuid        NOT NULL REFERENCES public.group_chat_rooms(id) ON DELETE CASCADE,
  sender_id    uuid        NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  content      text        NOT NULL,
  message_type text        NOT NULL DEFAULT 'text'
    CHECK (message_type IN ('text', 'image', 'system')),
  image_url    text,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER group_messages_updated_at
  BEFORE UPDATE ON public.group_messages
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_group_messages_room ON public.group_messages(room_id, created_at);

ALTER TABLE public.group_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Group members can read messages"
  ON public.group_messages FOR SELECT
  USING (public.is_group_chat_member(room_id));

CREATE POLICY "Group members can send messages"
  ON public.group_messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND public.is_group_chat_member(room_id)
  );

-- Enable Realtime for group messages
ALTER PUBLICATION supabase_realtime ADD TABLE public.group_messages;


-- ═══════════════════════════════════════════════════════════════
-- 8. Schools table — add map provider preference
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE public.schools
  ADD COLUMN IF NOT EXISTS ios_default_map_provider text
    DEFAULT 'apple' CHECK (ios_default_map_provider IN ('apple', 'google'));


-- ═══════════════════════════════════════════════════════════════
-- 9. System configs — map API keys
-- ═══════════════════════════════════════════════════════════════

INSERT INTO public.system_configs (config_key, config_value, description)
VALUES
  ('apple_maps_token', '', 'Apple MapKit JS token (for web fallback if needed)'),
  ('google_maps_places_api_key', '', 'Google Places API key (future use)'),
  ('google_maps_directions_api_key', '', 'Google Directions API key (future use)')
ON CONFLICT (config_key) DO NOTHING;


-- ═══════════════════════════════════════════════════════════════
-- 10. Carpool system dictionaries
-- ═══════════════════════════════════════════════════════════════

INSERT INTO public.system_dictionaries (dict_type, dict_key, dict_value, description, extra, display_order)
VALUES
  ('carpool_status', 'active',    'Active',    'Trip is open for joining',              '{"icon": "directions_car", "color": "#059669"}', 1),
  ('carpool_status', 'inactive',  'Full',      'All seats taken',                       '{"icon": "event_seat",     "color": "#D97706"}', 2),
  ('carpool_status', 'departed',  'Departed',  'Trip has departed',                     '{"icon": "flight_takeoff", "color": "#0891B2"}', 3),
  ('carpool_status', 'completed', 'Completed', 'Trip finished',                         '{"icon": "check_circle",   "color": "#7C3AED"}', 4),
  ('carpool_status', 'cancelled', 'Cancelled', 'Trip was cancelled',                    '{"icon": "cancel",         "color": "#DC2626"}', 5),
  ('carpool_role',   'driver',    'Driver',    'Creator drives their own car',           '{"icon": "drive_eta"}',     1),
  ('carpool_role',   'organizer', 'Organizer', 'Creator is looking to split ride cost',  '{"icon": "groups"}',        2),
  ('carpool_luggage', 'none',    'No Luggage',    'No luggage allowed',          NULL, 1),
  ('carpool_luggage', 'small',   'Small Only',    'Backpacks and small bags',    NULL, 2),
  ('carpool_luggage', 'medium',  'Medium',        'Suitcases up to 24 inches',   NULL, 3),
  ('carpool_luggage', 'large',   'Large OK',      'Any size luggage accepted',   NULL, 4)
ON CONFLICT (dict_type, dict_key) DO NOTHING;
