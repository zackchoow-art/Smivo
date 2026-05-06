-- Migration 00119: Update Smith College pickup locations
--
-- Replaces existing pickup locations for Smith College with the four
-- canonical locations requested for v1.1.

DO $$
DECLARE
  v_school_id uuid;
BEGIN
  -- Resolve Smith College school ID by slug
  SELECT id INTO v_school_id
  FROM public.schools
  WHERE slug = 'smith'
  LIMIT 1;

  IF v_school_id IS NULL THEN
    RAISE EXCEPTION 'Smith College school not found (slug=smith)';
  END IF;

  -- Remove all existing pickup locations for Smith
  DELETE FROM public.pickup_locations
  WHERE school_id = v_school_id;

  -- Insert the four canonical locations
  INSERT INTO public.pickup_locations
    (school_id, name, display_order, is_active, created_at, updated_at)
  VALUES
    (v_school_id, 'Other (Specify in Chat)', 0, true, now(), now()),
    (v_school_id, 'Neilson Library',         1, true, now(), now()),
    (v_school_id, 'Chapin Lawn',             2, true, now(), now()),
    (v_school_id, 'Cutter & Ziskind Dining Hall', 3, true, now(), now());

  RAISE NOTICE 'Smith pickup locations updated (school_id=%)', v_school_id;
END;
$$;
