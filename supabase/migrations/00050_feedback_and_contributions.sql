-- Migration 00050: Bug feedback system + contribution value ledger
-- Supports user feedback submission, admin processing, and contribution tracking.

-- ═══════════════════════════════════════════════════════
-- 1. User feedbacks table
-- ═══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.user_feedbacks (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    -- Type: 'bug', 'improvement', 'feature_request', 'other'
    type text NOT NULL DEFAULT 'bug' CHECK (type IN ('bug', 'improvement', 'feature_request', 'other')),
    -- Title: short summary
    title text NOT NULL,
    -- Description: detailed explanation
    description text NOT NULL,
    -- Screenshot URL (stored in Supabase Storage)
    screenshot_url text,
    -- Device info: OS, app version, screen size (auto-collected)
    device_info jsonb,
    -- Status: 'pending', 'in_review', 'resolved', 'rejected', 'duplicate'
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_review', 'resolved', 'rejected', 'duplicate')),
    -- Admin response (optional)
    admin_response text,
    -- Points awarded for this feedback (set by admin when resolving)
    points_awarded int NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Rate limiting: max 5 feedbacks per user per day (enforced by unique partial index)
-- NOTE: This is a soft limit; the hard limit is enforced in the app/Edge Function.
-- We track daily counts via query, not via index.

-- Index for fetching user's own feedbacks
CREATE INDEX IF NOT EXISTS idx_feedbacks_user ON public.user_feedbacks (user_id, created_at DESC);
-- Index for admin processing queue
CREATE INDEX IF NOT EXISTS idx_feedbacks_status ON public.user_feedbacks (status, created_at);

-- RLS
ALTER TABLE public.user_feedbacks ENABLE ROW LEVEL SECURITY;

-- Users can read their own feedbacks
CREATE POLICY "Users can read own feedbacks"
    ON public.user_feedbacks FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- Users can insert their own feedbacks
CREATE POLICY "Users can insert own feedbacks"
    ON public.user_feedbacks FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- ═══════════════════════════════════════════════════════
-- 2. Contribution ledger (流水账)
-- ═══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.contribution_ledger (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    -- Points change: positive = earned, negative = deducted
    points int NOT NULL,
    -- Source type for future extensibility (Plaza, etc.)
    source_type text NOT NULL CHECK (source_type IN (
        'feedback_resolved',    -- Bug feedback was resolved by admin
        'feedback_bonus',       -- Extra bonus from admin
        'admin_adjustment',     -- Manual admin adjustment
        'plaza_activity'        -- Future: Plaza interactions
    )),
    -- Reference to the source record (e.g. feedback ID)
    source_id uuid,
    -- Description of why points were awarded/deducted
    description text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_contribution_user ON public.contribution_ledger (user_id, created_at DESC);

-- RLS
ALTER TABLE public.contribution_ledger ENABLE ROW LEVEL SECURITY;

-- Users can read their own contribution history
CREATE POLICY "Users can read own contributions"
    ON public.contribution_ledger FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- ═══════════════════════════════════════════════════════
-- 3. Add contribution fields to user_profiles
-- ═══════════════════════════════════════════════════════
ALTER TABLE public.user_profiles
    ADD COLUMN IF NOT EXISTS contribution_score int NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS contribution_level int NOT NULL DEFAULT 1,
    ADD COLUMN IF NOT EXISTS last_active_at timestamptz;

-- Contribution level thresholds:
-- Lv.1: 0-49, Lv.2: 50-149, Lv.3: 150-299, Lv.4: 300-499, Lv.5: 500+
-- Level calculation is done in app or via a DB trigger (Phase 2).
