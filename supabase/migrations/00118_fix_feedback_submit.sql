-- Migration 00118: Fix feedback submission failures
--
-- Problem 1: user_feedbacks INSERT may fail silently due to missing updated_at column
--   (the model is built on a table created before the updated_at convention).
-- Problem 2: order-files storage bucket RLS may block upload to feedbacks/ subfolder.
-- Problem 3: Ensure status default is 'submitted' not 'pending'.

-- ── 1. Ensure updated_at column exists on user_feedbacks ────────────────────
ALTER TABLE public.user_feedbacks
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- Keep updated_at in sync on every row update
CREATE OR REPLACE FUNCTION public.touch_user_feedbacks_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_feedbacks_updated_at ON public.user_feedbacks;
CREATE TRIGGER trg_user_feedbacks_updated_at
  BEFORE UPDATE ON public.user_feedbacks
  FOR EACH ROW EXECUTE FUNCTION public.touch_user_feedbacks_updated_at();

-- ── 2. Ensure INSERT RLS policy exists (idempotent re-creation) ─────────────
DROP POLICY IF EXISTS "Users can insert own feedbacks" ON public.user_feedbacks;
CREATE POLICY "Users can insert own feedbacks"
  ON public.user_feedbacks FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- ── 3. Ensure order-files storage bucket allows feedbacks/ uploads ──────────
-- Storage bucket RLS is managed in the Supabase dashboard for the 'order-files'
-- bucket. This comment documents the required policy that must exist:
--
--   Policy name: "Authenticated users can upload to order-files"
--   Operation: INSERT
--   Target roles: authenticated
--   WITH CHECK: bucket_id = 'order-files' AND auth.uid()::text IS NOT NULL
--
-- If uploads still fail, verify the above policy exists in:
-- Supabase Dashboard → Storage → order-files → Policies
--
-- The following query can be used to check storage policies:
-- SELECT * FROM storage.policies WHERE bucket_id = 'order-files';
