-- Migration 00075: Float Duration Days
-- Allows duration_days to accept fractional values (e.g. 0.000694444 for 1 minute)
-- instead of rejecting them or rounding to 0.

ALTER TABLE public.user_bans
  ALTER COLUMN duration_days TYPE numeric;
