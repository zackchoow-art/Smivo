-- ============================================================
-- Migration 00108: check_order_eligibility RPC
-- ============================================================
-- A dedicated RPC to check whether a buyer is allowed to place
-- an order on a listing. Currently only checks one condition:
--   is_blocked_by_seller: the seller has blocked the buyer.
--
-- Deliberately DOES NOT check:
--   - buyer mute status (chat restriction, irrelevant to orders)
--   - seller mute status (chat restriction, irrelevant to orders)
--
-- SECURITY DEFINER is required because user_blocks RLS only
-- exposes rows where user_id = auth.uid(). A buyer cannot
-- normally query the seller's block list.
-- ============================================================

CREATE OR REPLACE FUNCTION public.check_order_eligibility(
  p_buyer_id  uuid,
  p_seller_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_is_blocked boolean;
BEGIN
  -- Check if the SELLER has blocked the BUYER.
  -- Only this condition gates order placement.
  SELECT EXISTS (
    SELECT 1
    FROM public.user_blocks
    WHERE user_id        = p_seller_id
      AND blocked_user_id = p_buyer_id
  ) INTO v_is_blocked;

  RETURN jsonb_build_object(
    'is_blocked_by_seller', v_is_blocked
  );
END;
$$;

REVOKE ALL ON FUNCTION public.check_order_eligibility(uuid, uuid) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.check_order_eligibility(uuid, uuid) TO authenticated;
