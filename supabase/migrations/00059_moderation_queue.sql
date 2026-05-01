-- Migration 00051: Moderation queue for backend content review.
-- Stores flagged content for admin review with full audit trail.
-- Used by moderate-content Edge Function and Admin Dashboard.

CREATE TABLE IF NOT EXISTS public.moderation_queue (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    -- What type of content is being reviewed
    target_type text NOT NULL CHECK (target_type IN ('listing', 'message', 'review')),
    target_id uuid NOT NULL,

    -- Who created the content
    user_id uuid NOT NULL REFERENCES auth.users(id),

    -- How this review was triggered
    trigger_source text NOT NULL DEFAULT 'auto'
        CHECK (trigger_source IN ('auto', 'user_report', 'admin')),

    -- What method detected the issue
    review_method text NOT NULL DEFAULT 'sensitive_words'
        CHECK (review_method IN ('sensitive_words', 'ai', 'both')),

    -- Detection details
    matched_words text[] DEFAULT '{}',
    ai_flags jsonb DEFAULT '{}',
    content_snapshot text,

    -- Review status and outcome
    status text NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'approved', 'rejected', 'escalated')),
    reviewed_by uuid REFERENCES auth.users(id),
    reviewed_at timestamptz,
    review_note text,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Indexes for admin dashboard queries
CREATE INDEX IF NOT EXISTS idx_moderation_queue_status
    ON public.moderation_queue (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_moderation_queue_target
    ON public.moderation_queue (target_type, target_id);

-- RLS: Only service_role (Edge Function + Admin) can access
ALTER TABLE public.moderation_queue ENABLE ROW LEVEL SECURITY;
-- No policies = only service_role key can read/write

-- RPC for admin dashboard to fetch pending queue with pagination
CREATE OR REPLACE FUNCTION get_moderation_queue(
  p_status text DEFAULT 'pending',
  p_limit int DEFAULT 20,
  p_offset int DEFAULT 0
)
RETURNS TABLE (
  id uuid, target_type text, target_id uuid, user_id uuid,
  review_method text, matched_words text[], status text,
  content_snapshot text, created_at timestamptz
)
LANGUAGE sql SECURITY DEFINER
AS $$
  SELECT id, target_type, target_id, user_id,
         review_method, matched_words, status,
         content_snapshot, created_at
  FROM public.moderation_queue
  WHERE status = p_status
  ORDER BY created_at DESC
  LIMIT p_limit OFFSET p_offset;
$$;
