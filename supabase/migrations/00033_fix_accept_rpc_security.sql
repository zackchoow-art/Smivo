-- 00033_fix_accept_rpc_security.sql
--
-- Fix: accept_order_and_reject_others RPC was running as INVOKER (default),
-- which caused RLS violation when INSERTing into notifications table.
-- The notifications table only has SELECT/UPDATE policies for authenticated
-- users — INSERT is reserved for SECURITY DEFINER functions (triggers/RPCs).

CREATE OR REPLACE FUNCTION accept_order_and_reject_others(
  p_order_id UUID,
  p_listing_id UUID
) RETURNS VOID AS $$
BEGIN
  -- Accept the chosen order
  UPDATE orders SET status = 'confirmed', updated_at = now()
  WHERE id = p_order_id AND status = 'pending';

  -- Mark other pending orders for the same listing as missed
  UPDATE orders SET status = 'missed', updated_at = now()
  WHERE listing_id = p_listing_id
    AND id != p_order_id
    AND status = 'pending';

  -- Create notifications for missed orders
  INSERT INTO notifications (user_id, title, body, action_type, related_order_id)
  SELECT buyer_id, 'Offer Missed', 'Another buyer was selected for this item.', 'order', id
  FROM orders
  WHERE listing_id = p_listing_id
    AND id != p_order_id
    AND status = 'missed';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
