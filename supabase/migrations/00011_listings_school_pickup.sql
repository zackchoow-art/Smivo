-- ============================================================
-- Smivo — Listings School & Pickup Links
-- ============================================================
-- Links every listing to a school and an optional pickup 
-- location. Smith College is the default for existing rows.
-- ============================================================

-- ─── Step 1: Add columns (nullable first so existing rows 
-- don't fail) ──────────────────────────────────────────────

alter table public.listings
  add column school_id uuid references public.schools(id) on delete restrict,
  add column pickup_location_id uuid references public.pickup_locations(id) on delete set null,
  add column allow_buyer_suggest_pickup boolean not null default false;

-- ─── Step 2: Backfill existing rows with Smith College ─────

update public.listings
  set school_id = (select id from public.schools where slug = 'smith')
  where school_id is null;

-- ─── Step 3: Now enforce NOT NULL on school_id ─────────────

alter table public.listings
  alter column school_id set not null;

-- ─── Indexes ───────────────────────────────────────────────

create index idx_listings_school on public.listings(school_id);
create index idx_listings_school_status on public.listings(school_id, status)
  where status = 'active';
