-- ============================================================
-- Smivo — Rental Security Deposit
-- ============================================================
-- Rental listings must specify a security deposit. The 
-- amount is snapshotted onto the order at purchase time 
-- so it's preserved even if the listing is later edited.
-- ============================================================

-- ─── listings.deposit_amount ────────────────────────────────

alter table public.listings
  add column deposit_amount numeric(10, 2) not null default 0;

-- For rental listings, deposit must be > 0 at app level.
-- Sale listings ignore deposit (stays 0).

-- ─── orders.deposit_amount ──────────────────────────────────

alter table public.orders
  add column deposit_amount numeric(10, 2) not null default 0;

-- Backfill existing rental orders with 0 (no way to recover 
-- historical data). New rental orders will set this from 
-- the listing at creation time.
