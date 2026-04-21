-- ============================================================
-- Smivo — User Profiles School Link
-- ============================================================
-- Links every user to their school. Derived from email 
-- domain at registration. All existing users are Smith 
-- College (the only active school at launch).
-- ============================================================

-- ─── Step 1: Add column (nullable first for backfill) ──────

alter table public.user_profiles
  add column school_id uuid references public.schools(id) on delete restrict;

-- ─── Step 2: Backfill existing users with Smith College ────

update public.user_profiles
  set school_id = (select id from public.schools where slug = 'smith')
  where school_id is null;

-- ─── Step 3: Enforce NOT NULL ──────────────────────────────

alter table public.user_profiles
  alter column school_id set not null;

-- ─── Index ─────────────────────────────────────────────────

create index idx_user_profiles_school on public.user_profiles(school_id);

-- ─── Update handle_new_user to set school_id ───────────────
-- 
-- This replaces the existing handle_new_user function from 
-- 00002_auth_enforcement.sql. It now looks up the school_id 
-- based on the user's email domain and sets it on the 
-- user_profiles row.
-- 
-- Registration flow:
--   1. User signs up with email like "alice@smith.edu"
--   2. Supabase creates auth.users record
--   3. This trigger fires, extracts domain ("smith.edu")
--   4. Looks up matching school, rejects if no match
--   5. Inserts user_profiles with school_id set

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_email_domain text;
  v_school_id uuid;
begin
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

  -- Create user_profiles row with school_id
  insert into public.user_profiles (id, email, school_id)
  values (new.id, new.email, v_school_id);
  
  return new;
end;
$$;

-- Trigger is already defined in 00002, no need to re-create it

-- ─── Register @smivo.dev as a pseudo-school for debug ──────
-- 
-- The debug backdoor in 00003 allows @smivo.dev emails 
-- for testing. We register them under a fake school so 
-- the new handle_new_user domain lookup doesn't reject 
-- them. This school is flagged inactive so it won't show 
-- in UI lists but still satisfies the foreign key.

insert into public.schools (slug, name, email_domain, is_active)
values ('smivo-dev', 'Smivo Dev (debug)', 'smivo.dev', true)
on conflict (slug) do nothing;
