-- 00032_missed_order_status.sql

-- 1. 更新 check constraint 允许 'missed' 状态
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check
  CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'missed'));

-- 2. 更新 accept_order 函数：将同一 listing 的其他 pending 订单标记为 missed（非 cancelled）
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
$$ LANGUAGE plpgsql;
