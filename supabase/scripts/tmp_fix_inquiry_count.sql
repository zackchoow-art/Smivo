UPDATE public.listings l
SET inquiry_count = (
  SELECT count(*) FROM public.orders o
  WHERE o.listing_id = l.id
    AND o.listing_cycle = l.listing_cycle
);
