-- ============================================================
-- Migration 00094: Backend Moderation Infrastructure
-- ============================================================
-- Implements the Post-Write Flagging architecture:
--   1. backend_moderation_logs — detailed AI review records
--   2. moderation_tasks — lightweight task queue
--   3. PG triggers on listings/messages that respect config
--   4. Updated RLS to hide rejected/pending_review from others
-- ============================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- 1. backend_moderation_logs — Detailed AI review audit trail
-- ═══════════════════════════════════════════════════════════════
-- Stores every automated review result with full detail:
-- which engine, pass/fail, per-image breakdown, action taken.

CREATE TABLE IF NOT EXISTS public.backend_moderation_logs (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- What was reviewed
  target_type     text NOT NULL CHECK (target_type IN ('listing', 'message', 'profile')),
  target_id       uuid NOT NULL,
  user_id         uuid NOT NULL REFERENCES auth.users(id),

  -- How it was reviewed
  engine          text NOT NULL CHECK (engine IN ('openai', 'google_vision', 'sensitive_words')),
  review_mode     text NOT NULL CHECK (review_mode IN ('sensitive_words', 'ai', 'both')),

  -- Overall result
  result          text NOT NULL CHECK (result IN ('pass', 'fail')),
  action_taken    text NOT NULL CHECK (action_taken IN ('approve', 'reject', 'flag', 'blur')),

  -- Text analysis details (matched sensitive words, AI text categories)
  text_details    jsonb DEFAULT '{}'::jsonb,

  -- Per-image analysis details
  -- Array of objects: [{ index: 0, url: "...", flagged: true, reasons: ["adult", "violence"], scores: {...} }]
  image_details   jsonb DEFAULT '[]'::jsonb,

  -- Snapshot of content at time of review
  content_snapshot text,

  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Indexes for admin dashboard queries
CREATE INDEX IF NOT EXISTS idx_bml_target
  ON public.backend_moderation_logs (target_type, target_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bml_result
  ON public.backend_moderation_logs (result, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bml_user
  ON public.backend_moderation_logs (user_id, created_at DESC);

-- RLS: admin-only access (service_role for Edge Function writes)
ALTER TABLE public.backend_moderation_logs ENABLE ROW LEVEL SECURITY;

-- Admin users can read logs
CREATE POLICY "Admin users can read moderation logs"
  ON public.backend_moderation_logs FOR SELECT
  USING (
    public.is_admin_user()
  );

-- Service role inserts (no user-facing INSERT policy needed)


-- ═══════════════════════════════════════════════════════════════
-- 2. moderation_tasks — Lightweight task queue
-- ═══════════════════════════════════════════════════════════════
-- When a trigger fires and review is enabled, it inserts a row here.
-- A Supabase Database Webhook on this table calls moderate-content.

CREATE TABLE IF NOT EXISTS public.moderation_tasks (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  target_type     text NOT NULL CHECK (target_type IN ('listing', 'message', 'profile')),
  target_id       uuid NOT NULL,
  status          text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'processing', 'done', 'error')),
  error_message   text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  processed_at    timestamptz
);

CREATE INDEX IF NOT EXISTS idx_mod_tasks_status
  ON public.moderation_tasks (status, created_at);

ALTER TABLE public.moderation_tasks ENABLE ROW LEVEL SECURITY;
-- No user-facing policies — only service_role (Edge Function) accesses this


-- ═══════════════════════════════════════════════════════════════
-- 3. PG Triggers — conditionally enqueue moderation tasks
-- ═══════════════════════════════════════════════════════════════

-- Helper: check if backend review is enabled via system_configs
CREATE OR REPLACE FUNCTION public.is_backend_review_enabled()
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT COALESCE(
    (SELECT config_value::text IN ('true', '"true"')
     FROM public.system_configs
     WHERE config_key = 'backend_review.enabled'),
    false
  );
$$;

-- Trigger function for listings
CREATE OR REPLACE FUNCTION public.trigger_moderation_on_listing()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Only proceed if backend review is enabled
  IF NOT public.is_backend_review_enabled() THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.moderation_tasks (target_type, target_id)
  VALUES ('listing', NEW.id);

  RETURN NEW;
END;
$$;

-- Trigger function for messages (only when message has image content)
CREATE OR REPLACE FUNCTION public.trigger_moderation_on_message()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Only proceed if backend review is enabled
  IF NOT public.is_backend_review_enabled() THEN
    RETURN NEW;
  END IF;

  -- Only moderate messages with image content
  -- message_type = 'image' indicates an image message
  IF NEW.message_type = 'image' THEN
    INSERT INTO public.moderation_tasks (target_type, target_id)
    VALUES ('message', NEW.id);
  END IF;

  RETURN NEW;
END;
$$;

-- Attach triggers
DROP TRIGGER IF EXISTS on_listing_insert_moderate ON public.listings;
CREATE TRIGGER on_listing_insert_moderate
  AFTER INSERT ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_moderation_on_listing();

DROP TRIGGER IF EXISTS on_message_insert_moderate ON public.messages;
CREATE TRIGGER on_message_insert_moderate
  AFTER INSERT ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_moderation_on_message();


-- ═══════════════════════════════════════════════════════════════
-- 4. Update listings RLS — hide rejected/pending_review from others
-- ═══════════════════════════════════════════════════════════════
-- The current policy allows anyone to read 'active' listings or
-- their own listings. We need to also block rejected/pending_review
-- listings from being visible to OTHER users browsing the feed.

DROP POLICY IF EXISTS "Listings readable by public or order participants" ON public.listings;

CREATE POLICY "Listings readable by public or order participants"
  ON public.listings FOR SELECT
  USING (
    -- Owner always sees their own listings (including rejected ones)
    auth.uid() = seller_id
    -- Other users: only see active listings with approved moderation
    OR (
      status = 'active'
      AND moderation_status IN ('auto_approved', 'approved')
    )
    -- Order participants can always see the listing
    OR EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.listing_id = listings.id
        AND (o.buyer_id = auth.uid() OR o.seller_id = auth.uid())
    )
    -- Admin users can see everything (handled by separate policy)
  );


-- ═══════════════════════════════════════════════════════════════
-- 5. Add moderation_status 'flagged' to listings CHECK constraint
-- ═══════════════════════════════════════════════════════════════
-- The moderate-content function in its old version set 'flagged',
-- but the CHECK constraint only allows specific values. Let's ensure
-- it's consistent. We already have the right values:
-- auto_approved, pending_review, approved, rejected, taken_down.
-- No change needed — the Edge Function will use these existing values.

COMMIT;
