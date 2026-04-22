-- ============================================================
-- Smivo — Listing 'reserved' status for active orders
-- ============================================================
-- When a seller accepts an order (pending → confirmed), the 
-- listing should disappear from the home feed but not be 
-- marked sold yet. The new 'reserved' status represents 
-- "has an active order in progress, awaiting pickup".
-- 
-- State transitions:
--   Order pending → confirmed  : listing active → reserved
--   Order cancelled (from confirmed): listing reserved → active
--   Sale order completed       : listing reserved → sold
--   Rental order completed     : listing reserved → active
-- ============================================================

-- ─── Step 1: Update listings.status CHECK constraint ───────

alter table public.listings
  drop constraint if exists listings_status_check;

alter table public.listings
  add constraint listings_status_check
  check (status in ('active', 'inactive', 'reserved', 'sold', 'rented'));

-- ─── Step 2: Replace existing sync trigger ─────────────────

create or replace function public.sync_listing_on_order_status_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- pending → confirmed: reserve the listing
  if old.status = 'pending' and new.status = 'confirmed' then
    update public.listings
      set status = 'reserved',
          updated_at = now()
      where id = new.listing_id
        and status = 'active';
  end if;

  -- confirmed/pending → cancelled: release the listing back to active
  if new.status = 'cancelled' 
     and old.status in ('pending', 'confirmed') then
    update public.listings
      set status = 'active',
          updated_at = now()
      where id = new.listing_id
        and status = 'reserved';
  end if;

  -- confirmed → completed: finalize based on order type
  if old.status = 'confirmed' and new.status = 'completed' then
    if new.order_type = 'sale' then
      update public.listings
        set status = 'sold',
            updated_at = now()
        where id = new.listing_id;
    elsif new.order_type = 'rental' then
      update public.listings
        set status = 'active',
            updated_at = now()
        where id = new.listing_id
          and status = 'reserved';
    end if;
  end if;

  return new;
end;
$$;

-- Remove old trigger and function from 00006
drop trigger if exists on_order_completed on public.orders;

create trigger on_order_status_change_sync_listing
  after update of status on public.orders
  for each row execute function public.sync_listing_on_order_status_change();

-- Clean up old function (no longer referenced by any trigger)
drop function if exists public.sync_listing_on_order_complete() cascade;
