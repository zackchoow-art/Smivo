BEGIN;

CREATE OR REPLACE FUNCTION public.relist_listing(p_listing_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- NOTE: Allow relisting from any status. If a user explicitly clicks 
  -- Relist on an order detail page, we should respect their intent
  -- even if the item was previously intentionally delisted (inactive).
  UPDATE public.listings
    SET status       = 'active',
        listing_cycle = listing_cycle + 1,
        updated_at   = now()
  WHERE id        = p_listing_id
    AND seller_id = auth.uid();

  -- Raise if no row was updated (listing not found or not owned by user)
  IF NOT FOUND THEN
    RAISE EXCEPTION 'relist_listing: listing % not found or not owned by caller', p_listing_id
      USING ERRCODE = 'P0002';
  END IF;
END;
$$;

COMMIT;
