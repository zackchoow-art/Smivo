-- ============================================================
-- Migration 00176: Admin listing edit — RLS policies
-- ============================================================
-- Enables admin users (is_admin_user) to INSERT and DELETE rows
-- in the listing_images table, and to upload files to the
-- listing-images storage bucket without folder restrictions.
-- This is needed for admin-side image management when repairing
-- listing data.
-- ============================================================

-- ── listing_images table: admin INSERT ──
CREATE POLICY "Admin users can insert listing images"
  ON public.listing_images FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin_user());

-- ── listing_images table: admin DELETE ──
CREATE POLICY "Admin users can delete listing images"
  ON public.listing_images FOR DELETE
  TO authenticated
  USING (public.is_admin_user());

-- ── listing-images storage bucket: admin upload (no path restriction) ──
-- NOTE: Migration 00093 only allows admin uploads to the 'moderation-test/'
-- prefix. This new policy allows admins to upload to ANY path so they can
-- add replacement images under the original {userId}/{listingId}/ path.
CREATE POLICY "Admin can upload to listing-images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'listing-images'
    AND public.is_admin_user()
  );

-- Notify PostgREST to reload schema cache
NOTIFY pgrst, 'reload schema';
