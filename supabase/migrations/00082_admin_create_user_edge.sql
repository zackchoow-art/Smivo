-- ============================================================
-- Migration 00082: Edge Function approach for Admin Create User
-- ============================================================

-- 1. Remove the old RPC which causes GoTrue "Database error querying schema"
DROP FUNCTION IF EXISTS public.admin_create_user(text, text, text, uuid);

-- 2. Modify handle_new_user to use raw_user_meta_data for bypassing
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
  declare
  v_email_domain text;
  v_school_id uuid;
  v_default_school_id text;
  v_display_name text;
begin
  -- Check for bypass flag in metadata (set by auth.admin.createUser)
  if new.raw_user_meta_data->>'bypass_edu' = 'true' then
    v_default_school_id := new.raw_user_meta_data->>'school_id';
    if v_default_school_id is not null and v_default_school_id != '' then
      v_school_id := v_default_school_id::uuid;
    else
      -- Fallback to the first active school if none provided
      select id into v_school_id from public.schools where is_active = true limit 1;
    end if;
    
    v_display_name := new.raw_user_meta_data->>'display_name';

    -- Insert into user_profiles
    insert into public.user_profiles (id, email, school_id, is_verified, display_name)
    values (new.id, new.email, v_school_id, true, v_display_name);

    -- If role is provided, insert into admin_users
    if new.raw_user_meta_data->>'role' is not null then
      insert into public.admin_users (user_id, role, email, is_active)
      values (new.id, new.raw_user_meta_data->>'role', new.email, true);
    end if;

    return new;
  end if;

  -- Standard user signup flow
  v_email_domain := split_part(new.email, '@', 2);
  select id into v_school_id
    from public.schools
    where email_domain = v_email_domain
      and is_active = true;
      
  -- Reject if no matching active school
  if v_school_id is null then
    raise exception 'Registration not allowed for email domain: %. Smivo is currently only open to students at supported universities.', v_email_domain
      using errcode = 'P0001';
  end if;

  -- Create user_profiles row with school_id
  insert into public.user_profiles (id, email, school_id)
  values (new.id, new.email, v_school_id);

  return new;
end;
$$;
