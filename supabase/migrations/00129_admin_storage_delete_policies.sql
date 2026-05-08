-- ============================================================
-- Migration 00129: Allow admin users to delete Storage files
-- ============================================================
-- The test data cleanup process needs to empty Storage buckets
-- after purging database records. Existing DELETE policies only
-- allow file owners to delete their own files.
--
-- This migration adds admin-level DELETE policies so that
-- is_admin_user() can delete files in all UGC buckets.
-- ============================================================

-- listing-images: product photos uploaded by sellers
CREATE POLICY "Admin can delete listing images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'listing-images' AND is_admin_user());

-- order-files: chat images + delivery/return evidence photos
CREATE POLICY "Admin can delete order files"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'order-files' AND is_admin_user());

-- avatars: user profile pictures
CREATE POLICY "Admin can delete avatars"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND is_admin_user());
