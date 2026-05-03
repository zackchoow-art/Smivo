-- ============================================================
-- Migration 00081: Admin Create User RPC & Trigger Bypass
-- ============================================================

-- 1. Enable pgcrypto for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Modify handle_new_user to respect the bypass flag and fallback school
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
declare
  v_email_domain text;
  v_school_id uuid;
  v_bypass text;
  v_default_school_id text;
begin
  -- Check for bypass flag
  v_bypass := current_setting('smivo.bypass_edu', true);
  
  if v_bypass = 'true' then
    -- Admin is manually creating the user
    -- Get the injected school_id
    v_default_school_id := current_setting('smivo.admin_created_school_id', true);
    if v_default_school_id is not null and v_default_school_id != '' then
      v_school_id := v_default_school_id::uuid;
    else
      -- Fallback to the first active school if none provided
      select id into v_school_id from public.schools where is_active = true limit 1;
    end if;
  else
    -- Standard user signup flow
    -- Extract domain from email (everything after '@')
    v_email_domain := split_part(new.email, '@', 2);
    -- Look up the school by email domain
    select id into v_school_id
      from public.schools
      where email_domain = v_email_domain
        and is_active = true;
    -- Reject if no matching active school
    if v_school_id is null then
      raise exception 'Registration not allowed for email domain: %. Smivo is currently only open to students at supported universities.', v_email_domain
        using errcode = 'P0001';
    end if;
  end if;

  -- Create user_profiles row with school_id
  insert into public.user_profiles (id, email, school_id, is_verified)
  values (new.id, new.email, v_school_id, true); -- Admin created users are auto-verified

  return new;
end;
$$;


-- 3. Create the RPC for admins to create a user securely
CREATE OR REPLACE FUNCTION public.admin_create_user(
  p_email text,
  p_password text,
  p_role text,
  p_school_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
  v_caller_id uuid := auth.uid();
  v_new_user_id uuid;
BEGIN
  -- 1. Check if caller is sysadmin
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Only sysadmins can manually create users' USING ERRCODE = 'INSUF';
  END IF;

  -- Validate role
  IF p_role NOT IN ('sysadmin', 'platform_admin', 'platform_reviewer', 'school_admin', 'school_reviewer') THEN
    RAISE EXCEPTION 'Invalid admin role' USING ERRCODE = 'INVLD';
  END IF;

  -- 2. Bypass .edu check and inject school_id
  PERFORM set_config('smivo.bypass_edu', 'true', true);
  PERFORM set_config('smivo.admin_created_school_id', p_school_id::text, true);

  v_new_user_id := gen_random_uuid();
  
  -- 3. Insert into auth.users using pgcrypto for the password
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    confirmation_token,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    v_new_user_id,
    'authenticated',
    'authenticated',
    p_email,
    crypt(p_password, gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{}'::jsonb,
    false,
    '',
    ''
  );

  -- 4. Insert into auth.identities
  INSERT INTO auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    v_new_user_id::text,
    v_new_user_id,
    format('{"sub": "%s", "email": "%s", "email_verified": true, "phone_verified": false}', v_new_user_id, p_email)::jsonb,
    'email',
    now(),
    now(),
    now()
  );

  -- 5. Insert into admin_users
  INSERT INTO public.admin_users (
    user_id,
    role,
    email,
    is_active
  ) VALUES (
    v_new_user_id,
    p_role,
    p_email,
    true
  );

  -- 6. Insert audit log
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'admin_audit_logs') THEN
    INSERT INTO public.admin_audit_logs (
      admin_id,
      action,
      target_type,
      target_id,
      payload
    ) VALUES (
      v_caller_id,
      'admin_create_user',
      'user',
      v_new_user_id,
      jsonb_build_object('email', p_email, 'role', p_role, 'school_id', p_school_id)
    );
  END IF;

  -- 7. Reset configs just to be clean
  PERFORM set_config('smivo.bypass_edu', '', true);
  PERFORM set_config('smivo.admin_created_school_id', '', true);

  RETURN jsonb_build_object('success', true, 'user_id', v_new_user_id);
END;
$$;
