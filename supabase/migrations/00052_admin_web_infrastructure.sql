-- ============================================================
-- Migration 00052: Admin Web Infrastructure
-- ============================================================
-- Bridges existing DB (schools, admin_roles, content_reports,
-- user_feedbacks, sensitive_words) to the Admin Web dashboard.
--
-- IMPORTANT: This migration is ADDITIVE ONLY — no existing
-- tables or columns are dropped or renamed. The Admin Web
-- frontend maps "college" to the existing `schools` table.
--
-- What this adds:
--   1. Admin Web auth table (admin_users) — thin wrapper over admin_roles
--   2. Admin audit log
--   3. System settings (Feature Flags)
--   4. Moderation workflow tables (drafts, notices)
--   5. User bans table
--   6. Push notifications tables
--   7. Hourly active users (time bucket)
--   8. Listing moderation fields
--   9. User profile admin fields
--  10. Missing RLS policies for admin access
--  11. Key RPC functions
-- ============================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- 1. admin_users — Admin Web login authorization
-- ═══════════════════════════════════════════════════════════════
-- NOTE: This is a SEPARATE table from admin_roles (00039).
-- admin_roles handles granular RBAC; admin_users controls who
-- can log into the Admin Web dashboard with a simplified role.
-- The mapping is:
--   admin_roles.sysadmin → admin_users.platform_super_admin
--   admin_roles.admin    → admin_users.school_admin
--   admin_roles.operator → admin_users.platform_moderator

CREATE TABLE IF NOT EXISTS public.admin_users (
  user_id       uuid PRIMARY KEY REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  role          text NOT NULL CHECK (role IN (
    'platform_super_admin', 'platform_moderator', 'school_admin'
  )),
  display_name  text,
  email         text NOT NULL,
  avatar_url    text,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER admin_users_updated_at
  BEFORE UPDATE ON public.admin_users
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- Admin users can read their own record
CREATE POLICY "Admin users can read own record"
  ON public.admin_users FOR SELECT
  USING (user_id = auth.uid());

-- Platform super admins can manage all admin_users
CREATE POLICY "Super admins manage admin_users"
  ON public.admin_users FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid()
        AND au.role = 'platform_super_admin'
        AND au.is_active = true
    )
  );

-- ── Admin school scopes (which schools each admin can access) ──
CREATE TABLE IF NOT EXISTS public.admin_school_scopes (
  admin_user_id uuid NOT NULL REFERENCES public.admin_users(user_id) ON DELETE CASCADE,
  college_id    uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  granted_by    uuid REFERENCES public.user_profiles(id),
  granted_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (admin_user_id, college_id)
);

CREATE INDEX idx_admin_scopes_college ON public.admin_school_scopes(college_id);

ALTER TABLE public.admin_school_scopes ENABLE ROW LEVEL SECURITY;

-- Same policies as admin_users
CREATE POLICY "Admin users read own scopes"
  ON public.admin_school_scopes FOR SELECT
  USING (admin_user_id = auth.uid());

CREATE POLICY "Super admins manage scopes"
  ON public.admin_school_scopes FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid()
        AND au.role = 'platform_super_admin'
        AND au.is_active = true
    )
  );

-- ── Seed existing sysadmins into admin_users ──
INSERT INTO public.admin_users (user_id, role, display_name, email)
SELECT
  up.id,
  'platform_super_admin',
  up.display_name,
  up.email
FROM public.user_profiles up
WHERE up.is_admin = true
ON CONFLICT (user_id) DO NOTHING;

-- Give platform super admins access to all active schools
INSERT INTO public.admin_school_scopes (admin_user_id, college_id)
SELECT au.user_id, s.id
FROM public.admin_users au
CROSS JOIN public.schools s
WHERE au.role = 'platform_super_admin'
  AND s.is_active = true
ON CONFLICT (admin_user_id, college_id) DO NOTHING;


-- ═══════════════════════════════════════════════════════════════
-- 2. admin_audit_logs — Operation audit trail
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.admin_audit_logs (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id      uuid NOT NULL REFERENCES public.admin_users(user_id),
  action        text NOT NULL,
  target_type   text NOT NULL,
  target_id     uuid,
  college_id    uuid REFERENCES public.schools(id),
  payload       jsonb,
  status_before text,
  status_after  text,
  ip_address    inet,
  user_agent    text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_admin ON public.admin_audit_logs(admin_id, created_at DESC);
CREATE INDEX idx_audit_target ON public.admin_audit_logs(target_type, target_id);
CREATE INDEX idx_audit_time ON public.admin_audit_logs(created_at DESC);

ALTER TABLE public.admin_audit_logs ENABLE ROW LEVEL SECURITY;

-- All admin users can read audit logs
CREATE POLICY "Admin users can read audit logs"
  ON public.admin_audit_logs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- All admin users can write audit logs
CREATE POLICY "Admin users can write audit logs"
  ON public.admin_audit_logs FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );


-- ═══════════════════════════════════════════════════════════════
-- 3. system_settings — Feature Flags
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.system_settings (
  key           text PRIMARY KEY,
  value         jsonb NOT NULL DEFAULT 'true'::jsonb,
  description   text,
  updated_by    uuid REFERENCES public.admin_users(user_id),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read settings (needed for feature flags in app)
CREATE POLICY "Authenticated users can read settings"
  ON public.system_settings FOR SELECT
  TO authenticated
  USING (true);

-- Super admins can manage settings
CREATE POLICY "Super admins manage settings"
  ON public.system_settings FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid()
        AND au.role = 'platform_super_admin'
        AND au.is_active = true
    )
  );

-- Seed initial feature flags
INSERT INTO public.system_settings (key, value, description) VALUES
  ('presence.enabled',          'true'::jsonb,  'Enable user online status tracking'),
  ('presence.show_online_dot',  'true'::jsonb,  'Show green dot for online users'),
  ('moderation.strict_mode',    'false'::jsonb, 'Require all listings to pass review before going live'),
  ('registration.enabled',      'true'::jsonb,  'Allow new user registration'),
  ('wishlist.enabled',          'false'::jsonb, 'Enable wishlist / bottle drift feature'),
  ('wishlist.cross_school',     'false'::jsonb, 'Allow cross-school wishlist viewing'),
  ('plaza.enabled',             'false'::jsonb, 'Enable community plaza feature'),
  ('feedback.enabled',          'true'::jsonb,  'Enable user feedback submission')
ON CONFLICT (key) DO NOTHING;


-- ═══════════════════════════════════════════════════════════════
-- 4. Moderation workflow tables
-- ═══════════════════════════════════════════════════════════════

-- 4a. moderation_drafts — shopping cart workflow for batch reviews
CREATE TABLE IF NOT EXISTS public.moderation_drafts (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id      uuid NOT NULL REFERENCES public.admin_users(user_id),
  target_type   text NOT NULL CHECK (target_type IN ('listing', 'chat_report', 'user_report', 'feedback')),
  target_id     uuid NOT NULL,
  college_id    uuid NOT NULL REFERENCES public.schools(id),
  decision      text NOT NULL CHECK (decision IN ('approve', 'reject', 'takedown', 'warn', 'ban')),
  rule_violated text,
  reason_detail text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (admin_id, target_type, target_id)
);

CREATE INDEX idx_drafts_admin ON public.moderation_drafts(admin_id);
CREATE INDEX idx_drafts_target ON public.moderation_drafts(target_type, target_id);

CREATE TRIGGER moderation_drafts_updated_at
  BEFORE UPDATE ON public.moderation_drafts
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.moderation_drafts ENABLE ROW LEVEL SECURITY;

-- Admin users can manage their own drafts
CREATE POLICY "Admin users manage own drafts"
  ON public.moderation_drafts FOR ALL
  USING (
    admin_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid()
        AND au.role = 'platform_super_admin'
        AND au.is_active = true
    )
  );

-- 4b. listing_moderation_notices — sent to user when listing is reviewed
CREATE TABLE IF NOT EXISTS public.listing_moderation_notices (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id    uuid NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  user_id       uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  action        text NOT NULL CHECK (action IN ('approved', 'rejected', 'taken_down')),
  reason        text,
  rule_violated text,
  is_read       boolean NOT NULL DEFAULT false,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_mod_notices_user ON public.listing_moderation_notices(user_id, is_read);
CREATE INDEX idx_mod_notices_listing ON public.listing_moderation_notices(listing_id);

ALTER TABLE public.listing_moderation_notices ENABLE ROW LEVEL SECURITY;

-- Users can read their own notices
CREATE POLICY "Users can read own moderation notices"
  ON public.listing_moderation_notices FOR SELECT
  USING (user_id = auth.uid());

-- Users can mark their own notices as read
CREATE POLICY "Users can update own notices"
  ON public.listing_moderation_notices FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Admin users can insert notices
CREATE POLICY "Admin users can insert notices"
  ON public.listing_moderation_notices FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );


-- ═══════════════════════════════════════════════════════════════
-- 5. user_bans — Ban management
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.user_bans (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  college_id    uuid NOT NULL REFERENCES public.schools(id),
  ban_type      text NOT NULL CHECK (ban_type IN ('temporary', 'permanent')),
  reason_code   text NOT NULL,
  reason_detail text,
  duration_days int,
  expires_at    timestamptz,
  banned_by     uuid NOT NULL REFERENCES public.admin_users(user_id),
  banned_at     timestamptz NOT NULL DEFAULT now(),
  lifted_by     uuid REFERENCES public.admin_users(user_id),
  lifted_at     timestamptz,
  lift_reason   text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_bans_user ON public.user_bans(user_id, banned_at DESC);
CREATE INDEX idx_bans_college ON public.user_bans(college_id);
-- NOTE: Cannot use now() in index predicate (must be IMMUTABLE).
-- Active ban lookup uses a simple query-time filter instead.
CREATE INDEX idx_bans_active ON public.user_bans(user_id)
  WHERE lifted_at IS NULL;

ALTER TABLE public.user_bans ENABLE ROW LEVEL SECURITY;

-- Users can check if they are banned
CREATE POLICY "Users can read own ban status"
  ON public.user_bans FOR SELECT
  USING (user_id = auth.uid());

-- Admin users can manage bans
CREATE POLICY "Admin users manage bans"
  ON public.user_bans FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );


-- ═══════════════════════════════════════════════════════════════
-- 6. Push notification tables
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.push_templates (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name              text NOT NULL,
  title_template    text NOT NULL,
  body_template     text NOT NULL,
  default_deep_link text,
  created_by        uuid REFERENCES public.admin_users(user_id),
  created_at        timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.push_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin users manage push templates"
  ON public.push_templates FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

CREATE TABLE IF NOT EXISTS public.push_jobs (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title             text NOT NULL,
  body              text NOT NULL,
  deep_link         text,
  channels          text[] NOT NULL DEFAULT ARRAY['push'],

  -- Audience
  audience_type     text NOT NULL CHECK (audience_type IN ('all', 'filter', 'csv', 'platform_wide')),
  audience_filter   jsonb,
  audience_user_ids uuid[],
  college_id        uuid REFERENCES public.schools(id),

  -- Timing
  scheduled_at      timestamptz,

  -- Status
  status            text NOT NULL DEFAULT 'draft' CHECK (status IN (
    'draft', 'scheduled', 'sending', 'sent', 'failed', 'cancelled'
  )),

  -- Stats
  recipients_count  int,
  delivered_count   int NOT NULL DEFAULT 0,
  opened_count      int NOT NULL DEFAULT 0,
  clicked_count     int NOT NULL DEFAULT 0,
  failure_breakdown jsonb,

  -- Metadata
  onesignal_id      text,
  created_by        uuid REFERENCES public.admin_users(user_id),
  created_at        timestamptz NOT NULL DEFAULT now(),
  sent_at           timestamptz
);

CREATE INDEX idx_push_status ON public.push_jobs(status, created_at DESC);

ALTER TABLE public.push_jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin users manage push jobs"
  ON public.push_jobs FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );


-- ═══════════════════════════════════════════════════════════════
-- 7. hourly_active_users — Time bucket for analytics
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.hourly_active_users (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  school_id   uuid NOT NULL REFERENCES public.schools(id),
  hour_bucket timestamptz NOT NULL,
  platform    text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, hour_bucket)
);

CREATE INDEX idx_hau_bucket ON public.hourly_active_users(hour_bucket, school_id);
CREATE INDEX idx_hau_school ON public.hourly_active_users(school_id, hour_bucket);

ALTER TABLE public.hourly_active_users ENABLE ROW LEVEL SECURITY;

-- Admin users can read analytics
CREATE POLICY "Admin users can read hourly activity"
  ON public.hourly_active_users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );


-- ═══════════════════════════════════════════════════════════════
-- 8. Listing moderation fields
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS moderation_status text DEFAULT 'auto_approved'
    CHECK (moderation_status IN ('auto_approved', 'pending_review', 'approved', 'rejected', 'taken_down')),
  ADD COLUMN IF NOT EXISTS moderation_priority text DEFAULT 'normal'
    CHECK (moderation_priority IN ('urgent', 'normal', 'low')),
  ADD COLUMN IF NOT EXISTS moderation_due_at timestamptz,
  ADD COLUMN IF NOT EXISTS moderation_trigger text,
  ADD COLUMN IF NOT EXISTS moderation_note text,
  ADD COLUMN IF NOT EXISTS moderated_by uuid REFERENCES public.admin_users(user_id),
  ADD COLUMN IF NOT EXISTS moderated_at timestamptz;

CREATE INDEX IF NOT EXISTS idx_listings_moderation
  ON public.listings(moderation_status, moderation_priority)
  WHERE moderation_status = 'pending_review';


-- ═══════════════════════════════════════════════════════════════
-- 9. User profile admin fields
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS admin_note text,
  ADD COLUMN IF NOT EXISTS custom_tags text[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS warning_count int NOT NULL DEFAULT 0;


-- ═══════════════════════════════════════════════════════════════
-- 10. Admin RLS policies for existing tables
-- ═══════════════════════════════════════════════════════════════

-- Admins can read all content reports
CREATE POLICY "Admin users can read all reports"
  ON public.content_reports FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can update content reports (resolve/dismiss)
CREATE POLICY "Admin users can update reports"
  ON public.content_reports FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can read all user feedbacks
CREATE POLICY "Admin users can read all feedbacks"
  ON public.user_feedbacks FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can update feedbacks (resolve, award points)
CREATE POLICY "Admin users can update feedbacks"
  ON public.user_feedbacks FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can manage sensitive words
CREATE POLICY "Admin users can manage sensitive words"
  ON public.sensitive_words FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can read all user profiles
CREATE POLICY "Admin users can read all profiles"
  ON public.user_profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can update user profiles (admin_note, custom_tags, warning_count)
CREATE POLICY "Admin users can update profiles"
  ON public.user_profiles FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can read all listings (including moderation fields)
CREATE POLICY "Admin users can read all listings"
  ON public.listings FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can update listings (moderation actions)
CREATE POLICY "Admin users can update listings"
  ON public.listings FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can read all orders
CREATE POLICY "Admin users can read all orders"
  ON public.orders FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can read all heartbeats
CREATE POLICY "Admin users can read all heartbeats"
  ON public.user_heartbeats FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can read/manage schools
CREATE POLICY "Admin users can manage schools"
  ON public.schools FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid()
        AND au.role = 'platform_super_admin'
        AND au.is_active = true
    )
  );

-- Admins can read contribution ledger
CREATE POLICY "Admin users can read contribution ledger"
  ON public.contribution_ledger FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );

-- Admins can insert contribution entries (when awarding points)
CREATE POLICY "Admin users can insert contributions"
  ON public.contribution_ledger FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid() AND au.is_active = true
    )
  );


-- ═══════════════════════════════════════════════════════════════
-- 11. Key RPC functions
-- ═══════════════════════════════════════════════════════════════

-- 11a. Check if current user is an active admin
CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE user_id = auth.uid() AND is_active = true
  );
$$;

-- 11b. Check if admin has access to a specific school
CREATE OR REPLACE FUNCTION public.admin_has_college_access(p_college_id uuid)
RETURNS boolean
LANGUAGE plpgsql
STABLE SECURITY DEFINER
AS $$
DECLARE
  v_admin public.admin_users;
BEGIN
  SELECT * INTO v_admin
  FROM public.admin_users
  WHERE user_id = auth.uid() AND is_active = true;

  IF v_admin IS NULL THEN
    RETURN false;
  END IF;

  -- Platform super admins have unrestricted access
  IF v_admin.role = 'platform_super_admin' THEN
    RETURN true;
  END IF;

  -- Others: check scope table
  RETURN EXISTS (
    SELECT 1 FROM public.admin_school_scopes
    WHERE admin_user_id = auth.uid() AND college_id = p_college_id
  );
END;
$$;

-- 11c. Enhanced presence RPC — also writes time bucket
CREATE OR REPLACE FUNCTION public.ping_user_presence(
  p_app_version text DEFAULT NULL,
  p_platform text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_now timestamptz := now();
  v_bucket timestamptz := date_trunc('hour', v_now);
  v_school_id uuid;
BEGIN
  -- Upsert heartbeat
  INSERT INTO public.user_heartbeats (user_id, last_seen_at, app_version, platform, updated_at)
  VALUES (auth.uid(), v_now, p_app_version, p_platform, v_now)
  ON CONFLICT (user_id) DO UPDATE SET
    last_seen_at = v_now,
    app_version = COALESCE(p_app_version, user_heartbeats.app_version),
    platform = COALESCE(p_platform, user_heartbeats.platform),
    updated_at = v_now;

  -- Update profile last_active_at
  UPDATE public.user_profiles
  SET last_active_at = v_now, updated_at = v_now
  WHERE id = auth.uid();

  -- Write time bucket for analytics
  SELECT school_id INTO v_school_id
  FROM public.user_profiles WHERE id = auth.uid();

  IF v_school_id IS NOT NULL THEN
    INSERT INTO public.hourly_active_users (user_id, school_id, hour_bucket, platform)
    VALUES (auth.uid(), v_school_id, v_bucket, p_platform)
    ON CONFLICT (user_id, hour_bucket) DO NOTHING;
  END IF;
END;
$$;

COMMIT;
