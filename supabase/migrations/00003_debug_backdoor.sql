-- ============================================================
-- Smivo — Debug Backdoor Migration (Updated with Auto-Confirm)
-- ============================================================
-- ⚠️  TEMPORARY — DEVELOPMENT USE ONLY
-- This migration modifies handle_new_user() to:
-- 1. Allow whitelisted test emails that do NOT end in .edu.
-- 2. Automatically confirm these test accounts so they bypass
--    the verification screen.
--
-- Run this only on local / staging environments.
-- NEVER run on production.
--
-- To revert: run 00004_remove_debug_backdoor.sql
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  -- HACK: Whitelisted test emails for development.
  v_debug_allowed text[] := array[
    'test1@smivo.dev',
    'test2@smivo.dev',
    'test3@smivo.dev'
  ];
  v_is_debug_email boolean;
begin
  v_is_debug_email := (lower(new.email) = any(v_debug_allowed));

  -- Allow whitelisted dev emails to bypass the .edu requirement.
  if not v_is_debug_email then
    if not (lower(new.email) like '%.edu') then
      raise exception 'Registration requires a valid .edu email address'
        using errcode = 'P0001';
    end if;
  end if;

  -- Insert into user_profiles
  insert into public.user_profiles (id, email, school, is_verified)
  values (
    new.id,
    new.email,
    case
      when v_is_debug_email then 'Smivo Dev'
      else 'Smith College'
    end,
    -- Auto-verify debug accounts in our profile table
    v_is_debug_email
  );

  -- Auto-confirm debug accounts in Supabase Auth table
  -- This allows test accounts to proceed without a real email link.
  if v_is_debug_email then
    update auth.users
    set email_confirmed_at = now(),
        confirmed_at = now()
    where id = new.id;
  end if;

  return new;
end;
$$;
