-- ============================================================
-- Migration 00093: Allow Admin Upload to listing-images bucket
-- ============================================================
-- Problem: The admin dashboard uploads test images to the
-- `moderation-test/` folder in the listing-images bucket for
-- AI moderation testing. This fails because the bucket's RLS
-- only allows authenticated app users (owner-path upload).
--
-- Fix: Add a storage policy that allows any active admin_users
-- member to INSERT (upload) into the listing-images bucket.
-- We scope it to the moderation-test/ prefix for safety.
-- ============================================================

-- Allow admin users to upload files to listing-images bucket
-- (scoped to the moderation-test/ prefix used by the admin UI)
CREATE POLICY "Admin users can upload moderation test images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'listing-images'
    AND (storage.foldername(name))[1] = 'moderation-test'
    AND EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

-- Also allow admins to read (SELECT) and delete test images they upload
CREATE POLICY "Admin users can manage moderation test images"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'listing-images'
    AND (storage.foldername(name))[1] = 'moderation-test'
    AND EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY "Admin users can delete moderation test images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'listing-images'
    AND (storage.foldername(name))[1] = 'moderation-test'
    AND EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

-- Notify PostgREST to reload schema cache
NOTIFY pgrst, 'reload schema';
