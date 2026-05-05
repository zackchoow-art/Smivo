BEGIN;

CREATE OR REPLACE FUNCTION public.update_listing_inquiry_count()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  UPDATE public.listings l
  SET inquiry_count = (
    SELECT count(*) FROM public.orders o
    WHERE o.listing_id = l.id
      AND o.listing_cycle = l.listing_cycle
  )
  WHERE id = COALESCE(NEW.listing_id, OLD.listing_id);
  RETURN NEW;
END;
$$;

-- Also update all existing listings' inquiry_count to reflect current cycle
UPDATE public.listings l
SET inquiry_count = (
  SELECT count(*) FROM public.orders o
  WHERE o.listing_id = l.id
    AND o.listing_cycle = l.listing_cycle
);

COMMIT;
