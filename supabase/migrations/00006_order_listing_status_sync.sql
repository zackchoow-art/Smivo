-- ============================================================
-- Smivo — Order → Listing Status Sync
-- ============================================================
-- When an order transitions to 'completed':
--   - Sale orders: set the listing to 'sold' (one-time transfer)
--   - Rental orders: keep the listing 'active' (reusable item)
--
-- Uses an AFTER UPDATE trigger on orders. Only fires when the
-- status column actually changes to avoid unnecessary writes.
-- ============================================================

create or replace function public.sync_listing_on_order_complete()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Only act on transition INTO 'completed' status
  if new.status = 'completed' and old.status is distinct from 'completed' then
    if new.order_type = 'sale' then
      -- Sale: mark listing as sold
      update public.listings
        set status = 'sold',
            updated_at = now()
        where id = new.listing_id;
    end if;
    -- Rental: no status change — item returns to active pool
    -- (listing.status stays 'active' for the next renter)
  end if;
  
  return new;
end;
$$;

drop trigger if exists on_order_completed on public.orders;

create trigger on_order_completed
  after update of status on public.orders
  for each row execute function public.sync_listing_on_order_complete();
