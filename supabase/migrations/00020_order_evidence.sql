-- ════════════════════════════════════════════════════════════
-- 00020: Order Evidence Photos
--
-- Storage for delivery evidence photos that buyers/sellers
-- can upload before confirming delivery.
-- ════════════════════════════════════════════════════════════

-- Evidence photos table
CREATE TABLE public.order_evidence (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id    uuid        NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  uploader_id uuid        NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  image_url   text        NOT NULL,
  caption     text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER order_evidence_updated_at
  BEFORE UPDATE ON public.order_evidence
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE INDEX idx_order_evidence_order ON public.order_evidence(order_id);

ALTER TABLE public.order_evidence ENABLE ROW LEVEL SECURITY;

-- Participants can view evidence for their orders
CREATE POLICY "Order participants can view evidence"
  ON public.order_evidence FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_evidence.order_id
      AND (orders.buyer_id = auth.uid() OR orders.seller_id = auth.uid())
    )
  );

-- Authenticated users can upload evidence for their orders
CREATE POLICY "Order participants can upload evidence"
  ON public.order_evidence FOR INSERT
  WITH CHECK (
    auth.uid() = uploader_id
    AND EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_evidence.order_id
      AND (orders.buyer_id = auth.uid() OR orders.seller_id = auth.uid())
    )
  );

-- Create storage bucket for evidence photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('order-evidence', 'order-evidence', true)
ON CONFLICT (id) DO NOTHING;

-- Public read for evidence photos
CREATE POLICY "Public read for order evidence"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'order-evidence');

-- Authenticated upload to order-evidence
CREATE POLICY "Authenticated upload to order-evidence"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'order-evidence'
    AND auth.role() = 'authenticated'
  );
