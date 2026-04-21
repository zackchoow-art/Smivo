-- ============================================================
-- Smivo — Remove Debug Backdoor (Pre-Production Cleanup)
-- ============================================================
-- Run this migration BEFORE deploying to production.
--
-- This restores handle_new_user() to the strict .edu-only
-- version, removing all development test account whitelists
-- and auto-confirmation logic.
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Enforce .edu email domain at the database level.
  if not (lower(new.email) like '%.edu') then
    raise exception 'Registration requires a valid .edu email address'
      using errcode = 'P0001';
  end if;

  -- Strictly no auto-verification here.
  insert into public.user_profiles (id, email, school, is_verified)
  values (
    new.id,
    new.email,
    'Smith College',
    false
  );
  return new;
end;
$$;
