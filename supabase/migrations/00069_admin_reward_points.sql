-- Migration 00069: Admin reward points RPC
-- Adds an RPC to safely award contribution points and log it to the ledger.

ALTER TABLE public.contribution_ledger 
DROP CONSTRAINT IF EXISTS contribution_ledger_source_type_check;

ALTER TABLE public.contribution_ledger 
ADD CONSTRAINT contribution_ledger_source_type_check 
CHECK (source_type IN (
    'feedback_resolved',
    'feedback_bonus',
    'admin_adjustment',
    'plaza_activity',
    'report_resolved'
));

CREATE OR REPLACE FUNCTION admin_reward_user_points(
    p_user_id uuid,
    p_points integer,
    p_source_type text,
    p_source_id uuid,
    p_description text
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Check permissions (must be admin)
    IF NOT public.is_active_admin() THEN
        RAISE EXCEPTION 'Access denied';
    END IF;

    -- Update user profile
    UPDATE public.user_profiles
    SET contribution_score = contribution_score + p_points
    WHERE id = p_user_id;

    -- Insert ledger record
    INSERT INTO public.contribution_ledger (
        user_id,
        points,
        source_type,
        source_id,
        description
    ) VALUES (
        p_user_id,
        p_points,
        p_source_type,
        p_source_id,
        p_description
    );
END;
$$;
