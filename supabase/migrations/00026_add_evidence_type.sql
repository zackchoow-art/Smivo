-- ════════════════════════════════════════════════════════════
-- 00026: Add evidence_type to order_evidence
--
-- Distinguishes between delivery evidence and return evidence.
-- ════════════════════════════════════════════════════════════

ALTER TABLE public.order_evidence 
ADD COLUMN evidence_type text NOT NULL DEFAULT 'delivery';

-- Update index to include evidence_type for faster filtering
CREATE INDEX idx_order_evidence_type ON public.order_evidence(order_id, evidence_type);
