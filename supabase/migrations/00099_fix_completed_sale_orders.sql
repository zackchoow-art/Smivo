-- Fix existing completed sale orders to have delivery_confirmed_by_buyer = true
UPDATE public.orders
SET delivery_confirmed_by_buyer = true
WHERE status = 'completed' AND order_type = 'sale' AND delivery_confirmed_by_buyer = false;
