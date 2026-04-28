-- Migration 00044: UGC Moderation (User Blocks and Reports)
-- Provides the infrastructure to satisfy App Store Safety guidelines.

-- 1. Create user_blocks table
CREATE TABLE IF NOT EXISTS public.user_blocks (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    blocked_user_id uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(user_id, blocked_user_id),
    CONSTRAINT no_self_block CHECK (user_id != blocked_user_id)
);

ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own blocks"
    ON public.user_blocks FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own blocks"
    ON public.user_blocks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own blocks"
    ON public.user_blocks FOR DELETE
    USING (auth.uid() = user_id);

-- 2. Create content_reports table
CREATE TABLE IF NOT EXISTS public.content_reports (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    reporter_id uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    reported_user_id uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    listing_id uuid REFERENCES public.listings(id) ON DELETE SET NULL,
    chat_room_id uuid REFERENCES public.chat_rooms(id) ON DELETE SET NULL,
    reason text NOT NULL,
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT no_self_report CHECK (reporter_id != reported_user_id)
);

ALTER TABLE public.content_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own reports"
    ON public.content_reports FOR INSERT
    WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users can view their own reports"
    ON public.content_reports FOR SELECT
    USING (auth.uid() = reporter_id);

-- Add updated_at trigger for content_reports
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.content_reports
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
