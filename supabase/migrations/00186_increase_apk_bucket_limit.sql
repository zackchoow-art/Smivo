-- ============================================================
-- Migration 00186: Increase app-releases bucket file size limit
-- Default Supabase limit is 50MB; APK files can exceed this.
-- ============================================================

UPDATE storage.buckets
SET file_size_limit = 209715200  -- 200MB in bytes
WHERE id = 'app-releases';
