BEGIN;

CREATE OR REPLACE FUNCTION public.relist_listing(p_listing_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Verify ownership
  IF NOT EXISTS (
    SELECT 1 FROM public.listings
    WHERE id = p_listing_id AND seller_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Not authorized to relist this listing';
  END IF;

  -- Ensure listing is currently inactive
  IF EXISTS (
    SELECT 1 FROM public.listings
    WHERE id = p_listing_id AND status = 'active'
  ) THEN
    RAISE EXCEPTION 'Listing is already active';
  END IF;

  -- Relist the item and increment listing cycle
  UPDATE public.listings
  SET status = 'active',
      listing_cycle = listing_cycle + 1,
      inquiry_count = 0,
      updated_at = NOW()
  WHERE id = p_listing_id;
END;
$$;

COMMIT;
