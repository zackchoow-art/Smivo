-- ============================================================
-- Smivo — Relax Email Restrictions
-- ============================================================
-- Modifies handle_new_user to allow any email to register.
-- Frontend will enforce .edu domain checks.
-- Any email domain starting with 'smivo.' (like smivo.io, smivo.app)
-- or any unmatched domain will be assigned to 'smivo-dev' school.
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_email_domain text;
  v_school_id uuid;
  v_smivo_dev_id uuid;
begin
  -- Extract domain from email (everything after '@')
  v_email_domain := split_part(new.email, '@', 2);

  -- Look up the school by exact email domain match
  select id into v_school_id
    from public.schools
    where email_domain = v_email_domain
      and is_active = true;

  -- Get the smivo-dev school ID for fallback
  select id into v_smivo_dev_id from public.schools where slug = 'smivo-dev';

  -- If no exact match, check if it's a smivo domain (smivo.io, smivo.app, smivo.dev)
  if v_school_id is null and v_email_domain like 'smivo.%' then
    v_school_id := v_smivo_dev_id;
  end if;

  -- If still no match (e.g., arbitrary email in debug mode), fallback to smivo-dev
  -- This fulfills the requirement that "in debug mode any email suffix can be registered"
  -- since we must provide a non-null school_id for the user profile.
  if v_school_id is null then
    v_school_id := v_smivo_dev_id;
  end if;

  -- Create user_profiles row with school_id
  insert into public.user_profiles (id, email, school_id)
  values (new.id, new.email, v_school_id);
  
  return new;
end;
$$;
