-- ============================================================
-- Smivo — Listing Item Condition
-- ============================================================
-- Adds a condition rating for listings so sellers can indicate 
-- the state of the item (new, like new, good, fair, poor).
-- Buyers rely on this for pricing expectations.
-- ============================================================

alter table public.listings
  add column condition text
  check (condition in ('new', 'like_new', 'good', 'fair', 'poor'));

-- Make it NOT NULL after backfilling existing rows with a 
-- sensible default. We use 'good' as a neutral middle-ground.
update public.listings set condition = 'good' where condition is null;

alter table public.listings
  alter column condition set not null;
