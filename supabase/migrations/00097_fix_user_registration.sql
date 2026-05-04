-- ============================================================
-- Smivo — Fix User Registration & Sync School Names
-- ============================================================
-- 1. Restores the comprehensive handle_new_user logic (Avatar, Display Name, Bypass).
-- 2. Fixes the missing 'school' (text) field insertion bug.
-- 3. Backfills existing user_profiles and orders with correct school names.
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
declare
  v_email_domain text;
  v_school_id uuid;
  v_school_name text;
  v_smivo_dev_id uuid;
  v_display_name text;
  v_avatar_url text;
begin
  -- 1. Generate random avatar seed using Open Peeps (from 00089)
  v_avatar_url := 'https://api.dicebear.com/9.x/open-peeps/png?seed=' || new.id || '&backgroundColor=transparent';

  -- 2. HIGHEST PRIORITY: Manual/Admin assignment via metadata (from 00089)
  -- This allows creating users via Admin dashboard with specific schools.
  if new.raw_user_meta_data->>'bypass_edu' = 'true' then
    v_school_id := (new.raw_user_meta_data->>'school_id')::uuid;
    
    -- Fallback to first active school if metadata school_id is missing
    if v_school_id is null then
      select id into v_school_id from public.schools where is_active = true limit 1;
    end if;
    
    v_display_name := coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1));

    -- Get school name for the redundancy field
    select name into v_school_name from public.schools where id = v_school_id;

    -- Insert into user_profiles
    insert into public.user_profiles (id, email, school_id, school, is_verified, display_name, avatar_url)
    values (new.id, new.email, v_school_id, v_school_name, true, v_display_name, v_avatar_url);

    -- If role is provided, insert into admin_users
    if new.raw_user_meta_data->>'role' is not null then
      insert into public.admin_users (user_id, role, email, is_active)
      values (new.id, new.raw_user_meta_data->>'role', new.email, true);
    end if;

    return new;
  end if;

  -- 3. STANDARD USER SIGNUP FLOW
  v_email_domain := split_part(new.email, '@', 2);
  v_display_name := split_part(new.email, '@', 1);

  -- 3a. Look up the school by exact email domain match
  select id, name into v_school_id, v_school_name
    from public.schools
    where email_domain = v_email_domain
      and is_active = true;

  -- 3b. Fallback logic for relaxed restrictions (from 00096)
  if v_school_id is null then
    -- Get the smivo-dev school info
    select id, name into v_smivo_dev_id, v_school_name from public.schools where slug = 'smivo-dev';
    
    -- If no exact match, assign to smivo-dev
    v_school_id := v_smivo_dev_id;
  end if;

  -- 4. FINAL INSERTION
  -- Ensure both school_id (FK) and school (text) are populated.
  insert into public.user_profiles (id, email, school_id, school, display_name, avatar_url)
  values (new.id, new.email, v_school_id, v_school_name, v_display_name, v_avatar_url);

  return new;
end;
$$;

-- ─── Data Backfill ───────────────────────────────────────────

-- Sync user_profiles.school with schools.name
update public.user_profiles up
set school = s.name
from public.schools s
where up.school_id = s.id
  and (up.school != s.name or up.school is null);

-- Sync orders.school with seller's school name for consistency
update public.orders o
set school = up.school
from public.user_profiles up
where o.seller_id = up.id
  and (o.school != up.school or o.school is null);
