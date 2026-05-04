DELETE FROM public.orders
WHERE id IN (
  SELECT id
  FROM (
    SELECT id,
           ROW_NUMBER() OVER (PARTITION BY buyer_id, listing_id ORDER BY created_at ASC) as rnum
    FROM public.orders
    WHERE status = 'pending'
  ) t
  WHERE t.rnum > 1
);
