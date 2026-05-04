-- Migration 00101: Allow Admins to trigger moderation tasks
-- This enables manual AI re-scans from the admin dashboard

-- Policy for moderation_tasks
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'moderation_tasks' AND policyname = 'Admins can insert moderation tasks'
    ) THEN
        CREATE POLICY "Admins can insert moderation tasks"
            ON public.moderation_tasks FOR INSERT
            WITH CHECK (public.is_admin_user());
    END IF;
END $$;

-- Also allow admins to select them to check status if needed
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'moderation_tasks' AND policyname = 'Admins can read moderation tasks'
    ) THEN
        CREATE POLICY "Admins can read moderation tasks"
            ON public.moderation_tasks FOR SELECT
            USING (public.is_admin_user());
    END IF;
END $$;
