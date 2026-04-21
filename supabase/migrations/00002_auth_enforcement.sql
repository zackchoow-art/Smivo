-- ============================================================
-- Smivo — Auth Enforcement Migration
-- ============================================================
-- 1. Enforce .edu email at database level (handle_new_user)
-- 2. Auto-sync is_verified when email_confirmed_at changes
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 1. Replace handle_new_user() to enforce .edu email
-- ────────────────────────────────────────────────────────────
-- When a user signs up via Supabase Auth, this trigger fires.
-- If the email does NOT end with .edu, the INSERT is rejected
-- with a database exception, which causes the auth signup to
-- fail and roll back.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Enforce .edu email domain at the database level.
  -- This is the last line of defense — the client also validates,
  -- but we never trust client-side checks alone.
  if not (lower(new.email) like '%.edu') then
    raise exception 'Registration requires a valid .edu email address'
      using errcode = 'P0001';
  end if;

  insert into public.user_profiles (id, email, school)
  values (
    new.id,
    new.email,
    'Smith College'
  );
  return new;
end;
$$;


-- ────────────────────────────────────────────────────────────
-- 2. Auto-sync is_verified when email is confirmed
-- ────────────────────────────────────────────────────────────
-- Supabase Auth sets email_confirmed_at on auth.users when
-- the user clicks the verification link. This trigger watches
-- for that change and mirrors it to user_profiles.is_verified.
--
-- Why a trigger instead of client-side update?
-- → The verification link is handled entirely by Supabase Auth
--   server-side. The Flutter app has no callback hook for it.
--   A database trigger is the only reliable way to keep the
--   two tables in sync without polling.

create or replace function public.handle_email_verified()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Only fire when email_confirmed_at transitions from NULL to a value
  if old.email_confirmed_at is null and new.email_confirmed_at is not null then
    update public.user_profiles
    set is_verified = true,
        updated_at = now()
    where id = new.id;
  end if;
  return new;
end;
$$;

create trigger on_auth_email_verified
  after update of email_confirmed_at on auth.users
  for each row execute function public.handle_email_verified();
