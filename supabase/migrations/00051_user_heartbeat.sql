-- Migration 00051: User heartbeat for online status tracking
-- App sends heartbeat every 5 minutes while in foreground.
-- Used to show "X minutes ago" on user profiles.
-- Time bucket aggregation for DAU/WAU/MAU will be Phase 2 (Admin).

-- ═══════════════════════════════════════════════════════
-- 1. Heartbeat table (lightweight, one row per user updated in-place)
-- ═══════════════════════════════════════════════════════
-- NOTE: We use UPSERT (ON CONFLICT UPDATE) pattern instead of INSERT.
-- This keeps the table small (one row per user) rather than growing unbounded.

CREATE TABLE IF NOT EXISTS public.user_heartbeats (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    last_seen_at timestamptz NOT NULL DEFAULT now(),
    -- App version and platform for analytics
    app_version text,
    platform text, -- 'ios', 'android', 'web'
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.user_heartbeats ENABLE ROW LEVEL SECURITY;

-- Any authenticated user can read heartbeats (needed to show "X min ago")
CREATE POLICY "Authenticated users can read heartbeats"
    ON public.user_heartbeats FOR SELECT
    TO authenticated
    USING (true);

-- Users can upsert their own heartbeat
CREATE POLICY "Users can upsert own heartbeat"
    ON public.user_heartbeats FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own heartbeat"
    ON public.user_heartbeats FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- ═══════════════════════════════════════════════════════
-- 2. Also update last_active_at on user_profiles when heartbeat is sent
-- ═══════════════════════════════════════════════════════
-- This is a convenience column for quick lookups without joining heartbeats.
-- NOTE: last_active_at column is added by migration 00050.

CREATE OR REPLACE FUNCTION public.update_last_active()
RETURNS trigger AS $$
BEGIN
    UPDATE public.user_profiles
    SET last_active_at = NEW.last_seen_at,
        updated_at = now()
    WHERE id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_heartbeat_update_profile
    AFTER INSERT OR UPDATE ON public.user_heartbeats
    FOR EACH ROW
    EXECUTE FUNCTION public.update_last_active();
