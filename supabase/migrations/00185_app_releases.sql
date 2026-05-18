-- ============================================================
-- Migration 00185: App Releases table + Storage bucket
-- Tracks APK (and future IPA) uploads with version metadata.
-- ============================================================

-- 1. Create the app_releases table
CREATE TABLE IF NOT EXISTS public.app_releases (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  platform    text NOT NULL DEFAULT 'android'
              CHECK (platform IN ('android', 'ios')),
  version     text NOT NULL,           -- e.g. '1.3.0'
  build_number text NOT NULL,          -- e.g. '10'
  download_url text NOT NULL,          -- public Supabase Storage URL
  file_size   bigint,                  -- bytes
  notes       text DEFAULT '',         -- optional release notes
  uploaded_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  uploaded_at timestamptz NOT NULL DEFAULT now(),
  created_at  timestamptz NOT NULL DEFAULT now()
);

-- Index for quick "latest release per platform" queries
CREATE INDEX IF NOT EXISTS idx_app_releases_platform_uploaded
  ON public.app_releases (platform, uploaded_at DESC);

-- 2. RLS: public read (website needs unauthenticated access), admin write
ALTER TABLE public.app_releases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read app releases"
  ON public.app_releases FOR SELECT
  USING (true);

CREATE POLICY "Admins can insert app releases"
  ON public.app_releases FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admin_roles
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can delete app releases"
  ON public.app_releases FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_roles
      WHERE user_id = auth.uid()
    )
  );

-- 3. Create Storage bucket for APK/IPA files (public read)
INSERT INTO storage.buckets (id, name, public)
VALUES ('app-releases', 'app-releases', true)
ON CONFLICT (id) DO NOTHING;

-- 4. Storage RLS: anyone can download, admins can upload
CREATE POLICY "Public download app releases"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'app-releases');

CREATE POLICY "Admins upload app releases"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'app-releases'
    AND EXISTS (
      SELECT 1 FROM public.admin_roles
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Admins delete app releases"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'app-releases'
    AND EXISTS (
      SELECT 1 FROM public.admin_roles
      WHERE user_id = auth.uid()
    )
  );

-- Notify PostgREST to pick up schema changes
NOTIFY pgrst, 'reload schema';
