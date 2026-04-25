-- ════════════════════════════════════════════════════════════
-- 00030: Unify notification titles
--
-- Standardize "Order accepted" → "Offer Accepted!" across
-- all existing notifications to match the current trigger.
-- ════════════════════════════════════════════════════════════

UPDATE public.notifications
SET title = 'Offer Accepted!'
WHERE type = 'order_accepted'
  AND title != 'Offer Accepted!';

-- Also standardize "Order completed" → "Order Complete!"
UPDATE public.notifications
SET title = 'Order Complete!'
WHERE type = 'order_completed'
  AND user_id IN (
    SELECT buyer_id FROM public.orders WHERE id = related_order_id
  )
  AND title != 'Order Complete!';

UPDATE public.notifications
SET title = 'Sale Complete!'
WHERE type = 'order_completed'
  AND user_id IN (
    SELECT seller_id FROM public.orders WHERE id = related_order_id
  )
  AND title != 'Sale Complete!';
