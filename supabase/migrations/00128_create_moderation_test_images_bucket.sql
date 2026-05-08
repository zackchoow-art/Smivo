-- ============================================================
-- Migration 00128: Create moderation-test-images storage bucket
-- ============================================================
-- The admin dashboard Image Moderation test panel needs to upload
-- images to a public bucket so that OpenAI/Google Vision APIs
-- can read them. The listing-images bucket's RLS requires
-- foldername[1] = auth.uid(), which blocks admin test uploads.
--
-- This migration:
--   1. Creates the moderation-test-images bucket (public read)
--   2. Adds a public SELECT policy so AI APIs can fetch the URL
-- ============================================================

-- 1. Create the bucket (public = true allows unauthenticated reads)
INSERT INTO storage.buckets (id, name, public)
VALUES ('moderation-test-images', 'moderation-test-images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Public read policy (so OpenAI/Google can fetch the image URL)
CREATE POLICY "Public read for moderation test images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'moderation-test-images');

-- NOTE: INSERT/UPDATE/DELETE policies already exist for admin users
-- (created in an earlier migration), gated by is_admin_user().
