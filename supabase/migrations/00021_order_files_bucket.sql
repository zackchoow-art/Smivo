-- ════════════════════════════════════════════════════════════
-- 00021: Unified Order Files Storage Bucket
--
-- Merges chat-images and order-evidence into a single
-- 'order-files' bucket organized by order ID.
-- Structure: {orderId}/chat/{fileName}
--            {orderId}/evidence/{uploaderId}/{fileName}
-- ════════════════════════════════════════════════════════════

-- Create unified bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('order-files', 'order-files', true)
ON CONFLICT (id) DO NOTHING;

-- Public read
CREATE POLICY "Public read for order files"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'order-files');

-- Authenticated upload
CREATE POLICY "Authenticated upload to order-files"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'order-files'
    AND auth.role() = 'authenticated'
  );
