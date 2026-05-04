-- Fix existing completed sale orders to have both delivery_confirmed_by_buyer and delivery_confirmed_by_seller = true
UPDATE public.orders
SET delivery_confirmed_by_buyer = true,
    delivery_confirmed_by_seller = true
WHERE status = 'completed' AND order_type = 'sale' AND (delivery_confirmed_by_buyer = false OR delivery_confirmed_by_seller = false);
