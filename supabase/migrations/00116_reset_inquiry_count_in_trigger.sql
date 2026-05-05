BEGIN;

CREATE OR REPLACE FUNCTION public.sync_listing_on_order_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- pending → confirmed: reserve the listing
  IF OLD.status = 'pending' AND NEW.status = 'confirmed' THEN
    UPDATE public.listings
      SET status = 'reserved',
          updated_at = now()
      WHERE id = NEW.listing_id
        AND status = 'active';
  END IF;

  -- confirmed → cancelled: release back to active AND increment cycle.
  -- Reset inquiry_count to 0 for the new listing cycle.
  IF NEW.status = 'cancelled' AND OLD.status = 'confirmed' THEN
    UPDATE public.listings
      SET status = 'active',
          listing_cycle = listing_cycle + 1,
          inquiry_count = 0,
          updated_at = now()
      WHERE id = NEW.listing_id
        AND status = 'reserved';
  END IF;

  -- pending → cancelled: release back to active WITHOUT incrementing
  -- the cycle. The listing was never "taken off market" so this is
  -- just a buyer changing their mind.
  IF NEW.status = 'cancelled' AND OLD.status = 'pending' THEN
    UPDATE public.listings
      SET status = 'active',
          updated_at = now()
      WHERE id = NEW.listing_id
        AND status = 'reserved';
  END IF;

  -- confirmed → completed: finalize based on order type
  IF OLD.status = 'confirmed' AND NEW.status = 'completed' THEN
    IF NEW.order_type = 'sale' THEN
      UPDATE public.listings
        SET status = 'sold',
            updated_at = now()
        WHERE id = NEW.listing_id;
    ELSIF NEW.order_type = 'rental' THEN
      -- Rental completion relists the item; treat as a new cycle.
      -- Reset inquiry_count to 0 for the new listing cycle.
      UPDATE public.listings
        SET status = 'active',
            listing_cycle = listing_cycle + 1,
            inquiry_count = 0,
            updated_at = now()
        WHERE id = NEW.listing_id
          AND status = 'reserved';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

COMMIT;
