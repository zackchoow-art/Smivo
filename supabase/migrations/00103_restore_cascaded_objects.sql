-- ============================================================
-- Migration 00103: Restore cascaded objects from 00102
-- ============================================================
-- Migration 00102 dropped admin_users CASCADE, which removed FK
-- constraints and RLS policies on tables that referenced
-- admin_users.user_id. This migration restores them, now
-- pointing to user_profiles.id instead (since admin_users is gone).
-- ============================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- 1. Restore FK constraints (now referencing user_profiles.id)
-- ═══════════════════════════════════════════════════════════════

-- admin_audit_logs.admin_id → user_profiles (was → admin_users)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'admin_audit_logs_admin_id_fkey' AND table_name = 'admin_audit_logs'
  ) THEN
    ALTER TABLE public.admin_audit_logs
      ADD CONSTRAINT admin_audit_logs_admin_id_fkey
      FOREIGN KEY (admin_id) REFERENCES public.user_profiles(id) ON DELETE SET NULL;
  END IF;
END $$;

-- system_settings.updated_by → user_profiles (was → admin_users)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'system_settings_updated_by_fkey' AND table_name = 'system_settings'
  ) THEN
    ALTER TABLE public.system_settings
      ADD CONSTRAINT system_settings_updated_by_fkey
      FOREIGN KEY (updated_by) REFERENCES public.user_profiles(id) ON DELETE SET NULL;
  END IF;
END $$;

-- moderation_drafts.admin_id → user_profiles
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'moderation_drafts_admin_id_fkey' AND table_name = 'moderation_drafts'
  ) THEN
    ALTER TABLE public.moderation_drafts
      ADD CONSTRAINT moderation_drafts_admin_id_fkey
      FOREIGN KEY (admin_id) REFERENCES public.user_profiles(id) ON DELETE SET NULL;
  END IF;
END $$;

-- user_bans.banned_by → user_profiles
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'user_bans_banned_by_fkey' AND table_name = 'user_bans'
  ) THEN
    ALTER TABLE public.user_bans
      ADD CONSTRAINT user_bans_banned_by_fkey
      FOREIGN KEY (banned_by) REFERENCES public.user_profiles(id) ON DELETE SET NULL;
  END IF;
END $$;

-- user_bans.lifted_by → user_profiles
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'user_bans_lifted_by_fkey' AND table_name = 'user_bans'
  ) THEN
    ALTER TABLE public.user_bans
      ADD CONSTRAINT user_bans_lifted_by_fkey
      FOREIGN KEY (lifted_by) REFERENCES public.user_profiles(id) ON DELETE SET NULL;
  END IF;
END $$;

-- push_templates.created_by → user_profiles
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'push_templates_created_by_fkey' AND table_name = 'push_templates'
  ) THEN
    ALTER TABLE public.push_templates
      ADD CONSTRAINT push_templates_created_by_fkey
      FOREIGN KEY (created_by) REFERENCES public.user_profiles(id) ON DELETE SET NULL;
  END IF;
END $$;

-- push_jobs.created_by → user_profiles
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'push_jobs_created_by_fkey' AND table_name = 'push_jobs'
  ) THEN
    ALTER TABLE public.push_jobs
      ADD CONSTRAINT push_jobs_created_by_fkey
      FOREIGN KEY (created_by) REFERENCES public.user_profiles(id) ON DELETE SET NULL;
  END IF;
END $$;

-- listings.moderated_by → user_profiles
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'listings_moderated_by_fkey' AND table_name = 'listings'
  ) THEN
    ALTER TABLE public.listings
      ADD CONSTRAINT listings_moderated_by_fkey
      FOREIGN KEY (moderated_by) REFERENCES public.user_profiles(id) ON DELETE SET NULL;
  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════
-- 2. Restore RLS policies (using is_admin_user() instead of
--    old admin_users FK check)
-- ═══════════════════════════════════════════════════════════════

-- admin_audit_logs: admins can write
DROP POLICY IF EXISTS "Admin users can write audit logs" ON public.admin_audit_logs;
CREATE POLICY "Admin users can write audit logs"
  ON public.admin_audit_logs FOR INSERT
  WITH CHECK (public.is_admin_user());

-- listing_moderation_notices: admins can insert
DROP POLICY IF EXISTS "Admin users can insert notices" ON public.listing_moderation_notices;
CREATE POLICY "Admin users can insert notices"
  ON public.listing_moderation_notices FOR INSERT
  WITH CHECK (public.is_admin_user());

-- hourly_active_users: admins can read
DROP POLICY IF EXISTS "Admin users can read hourly activity" ON public.hourly_active_users;
CREATE POLICY "Admin users can read hourly activity"
  ON public.hourly_active_users FOR SELECT
  USING (public.is_admin_user());

-- contribution_ledger: admins can read + insert
DROP POLICY IF EXISTS "Admin users can read contribution ledger" ON public.contribution_ledger;
CREATE POLICY "Admin users can read contribution ledger"
  ON public.contribution_ledger FOR SELECT
  USING (public.is_admin_user());

DROP POLICY IF EXISTS "Admin users can insert contributions" ON public.contribution_ledger;
CREATE POLICY "Admin users can insert contributions"
  ON public.contribution_ledger FOR INSERT
  WITH CHECK (public.is_admin_user());

-- review_tags: admin full access (was on old admin_roles table)
DROP POLICY IF EXISTS "Admin full access to review_tags" ON public.review_tags;
CREATE POLICY "Admin full access to review_tags"
  ON public.review_tags FOR ALL
  USING (public.is_admin_user())
  WITH CHECK (public.is_admin_user());

-- storage.objects: moderation test images bucket
DROP POLICY IF EXISTS "Admin users can upload moderation test images" ON storage.objects;
CREATE POLICY "Admin users can upload moderation test images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'moderation-test-images' AND public.is_admin_user());

DROP POLICY IF EXISTS "Admin users can manage moderation test images" ON storage.objects;
CREATE POLICY "Admin users can manage moderation test images"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'moderation-test-images' AND public.is_admin_user());

DROP POLICY IF EXISTS "Admin users can delete moderation test images" ON storage.objects;
CREATE POLICY "Admin users can delete moderation test images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'moderation-test-images' AND public.is_admin_user());

-- ═══════════════════════════════════════════════════════════════
-- 3. Notify PostgREST to reload schema
-- ═══════════════════════════════════════════════════════════════

NOTIFY pgrst, 'reload schema';

COMMIT;
