-- ============================================================
-- Smivo — Schools & Pickup Locations
-- ============================================================
-- Multi-school architecture foundation. Each school has:
--   - Its own email domain (for registration matching)
--   - Its own set of pickup locations
--   - Branding (logo, primary color) for future white-labeling
-- ============================================================

-- ─── schools table ────────────────────────────────────────

create table public.schools (
  id             uuid primary key default gen_random_uuid(),
  slug           text unique not null,
  name           text not null,
  email_domain   text unique not null,
  primary_color  text,
  logo_url       text,
  is_active      boolean not null default false,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create trigger schools_updated_at
  before update on public.schools
  for each row execute function public.handle_updated_at();

alter table public.schools enable row level security;

-- Everyone can read active schools (needed during registration 
-- and for displaying school info)
create policy "Active schools are publicly readable"
  on public.schools for select
  using (is_active = true);

-- ─── pickup_locations table ───────────────────────────────

create table public.pickup_locations (
  id             uuid primary key default gen_random_uuid(),
  school_id      uuid not null references public.schools(id) on delete cascade,
  name           text not null,
  display_order  int not null default 0,
  is_active      boolean not null default true,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create trigger pickup_locations_updated_at
  before update on public.pickup_locations
  for each row execute function public.handle_updated_at();

create index idx_pickup_locations_school 
  on public.pickup_locations(school_id, display_order)
  where is_active = true;

alter table public.pickup_locations enable row level security;

-- Authenticated users can read active pickup locations
create policy "Authenticated users read active pickup locations"
  on public.pickup_locations for select
  using (auth.role() = 'authenticated' and is_active = true);

-- ─── Seed data: Smith College ──────────────────────────────

insert into public.schools (slug, name, email_domain, is_active)
values ('smith', 'Smith College', 'smith.edu', true);

-- Common pickup locations at Smith College
-- (references the school we just created)
insert into public.pickup_locations (school_id, name, display_order)
select schools.id, locs.name, locs.display_order from (values
  ('Neilson Library', 1),
  ('Campus Center', 2),
  ('Chapin Lawn', 3),
  ('Northrop Hall Lobby', 4),
  ('Davis Center', 5),
  ('Wright Hall', 6),
  ('Ford Hall', 7),
  ('Other (specify in chat)', 99)
) as locs(name, display_order)
cross join public.schools
where schools.slug = 'smith';
