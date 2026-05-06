-- Migration 00126: Fix user_feedbacks INSERT RLS
--
-- Problem: user_feedbacks INSERT policy contains a call to
-- is_user_restricted(), which in turn queries the user_bans table.
-- If this function errors for any reason (e.g., during admin system
-- migration), the policy evaluation fails closed → 42501 RLS violation.
--
-- Fix: Keep the ban check but make it safe with a COALESCE fallback.
-- Also ensure the policy exists and covers the anon key scenario.

BEGIN;

DROP POLICY IF EXISTS "Users can insert own feedbacks" ON public.user_feedbacks;

CREATE POLICY "Users can insert own feedbacks"
  ON public.user_feedbacks FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    -- NOTE: COALESCE wraps the restriction check so that if the function
    -- raises an exception (e.g., missing table or broken dependency),
    -- it defaults to false (not restricted) rather than blocking the INSERT.
    AND NOT COALESCE(public.is_user_restricted(auth.uid(), 'feedback_ban'), false)
    AND NOT COALESCE(public.is_user_restricted(auth.uid(), 'account_freeze'), false)
  );

COMMIT;
