-- Migration 00119b: Update Smith College pickup locations (safe, no-unique upsert)
--
-- Cannot use ON CONFLICT since pickup_locations has no unique constraint on (school_id, name).
-- Strategy:
--   1. Soft-disable all existing Smith locations (preserves FK from orders)
--   2. Check if each canonical location already exists by name; if so re-enable it,
--      otherwise insert it fresh.

DO $$
DECLARE
  v_school_id uuid;
  v_loc_id    uuid;

  -- Canonical locations: (name, display_order)
  v_locs TEXT[][] := ARRAY[
    ARRAY['Other (Specify in Chat)', '0'],
    ARRAY['Neilson Library',         '1'],
    ARRAY['Chapin Lawn',             '2'],
    ARRAY['Cutter & Ziskind Dining Hall', '3']
  ];
  v_entry TEXT[];
BEGIN
  SELECT id INTO v_school_id FROM public.schools WHERE slug = 'smith' LIMIT 1;
  IF v_school_id IS NULL THEN
    RAISE EXCEPTION 'Smith College school not found (slug=smith)';
  END IF;

  -- Step 1: soft-disable all existing Smith locations to keep FKs intact
  UPDATE public.pickup_locations
  SET is_active = false, updated_at = now()
  WHERE school_id = v_school_id;

  -- Step 2: re-enable or insert each canonical location
  FOREACH v_entry SLICE 1 IN ARRAY v_locs LOOP
    -- Check if this name already exists for Smith
    SELECT id INTO v_loc_id
    FROM public.pickup_locations
    WHERE school_id = v_school_id AND name = v_entry[1]
    LIMIT 1;

    IF v_loc_id IS NOT NULL THEN
      -- Re-enable and update order for existing row
      UPDATE public.pickup_locations
      SET is_active     = true,
          display_order = v_entry[2]::int,
          updated_at    = now()
      WHERE id = v_loc_id;
    ELSE
      -- Insert fresh row
      INSERT INTO public.pickup_locations (school_id, name, display_order, is_active, created_at, updated_at)
      VALUES (v_school_id, v_entry[1], v_entry[2]::int, true, now(), now());
    END IF;
  END LOOP;

  RAISE NOTICE 'Smith pickup locations updated successfully (school_id=%)', v_school_id;
END;
$$;
