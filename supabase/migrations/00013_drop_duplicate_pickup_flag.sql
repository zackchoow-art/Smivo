-- ============================================================
-- Smivo — Drop duplicate pickup permission column
-- ============================================================
-- Migration 00011 added allow_buyer_suggest_pickup which 
-- duplicated the existing allow_pickup_change column. 
-- The existing allow_pickup_change is the one we keep.
-- ============================================================

alter table public.listings
  drop column if exists allow_buyer_suggest_pickup;
