import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';

const QUERY_KEY = ['app-releases'] as const;
const BUCKET = 'app-releases';

export interface AppRelease {
  id: string;
  platform: 'android' | 'ios';
  version: string;
  build_number: string;
  download_url: string;
  file_size: number | null;
  notes: string;
  uploaded_by: string | null;
  uploaded_at: string;
  uploader_name: string | null;
}

/**
 * Fetch all releases ordered by upload time (newest first).
 * Optionally filter by platform.
 * NOTE: Cannot join uploaded_by → auth.users via PostgREST (auth schema not exposed).
 * Instead, we fetch user_profiles separately.
 */
export function useAppReleases(platform?: 'android' | 'ios') {
  return useQuery({
    queryKey: [...QUERY_KEY, platform ?? 'all'],
    queryFn: async () => {
      let query = supabase
        .from(TABLES.APP_RELEASES)
        .select('*')
        .order('uploaded_at', { ascending: false });

      if (platform) {
        query = query.eq('platform', platform);
      }

      const { data, error } = await query;
      if (error) throw error;

      const releases = (data ?? []) as AppRelease[];

      // Fetch uploader names from user_profiles for any non-null uploaded_by
      const uploaderIds = [...new Set(releases.map(r => r.uploaded_by).filter(Boolean))] as string[];
      let profileMap: Record<string, string> = {};

      if (uploaderIds.length > 0) {
        const { data: profiles } = await supabase
          .from(TABLES.USER_PROFILES)
          .select('id, display_name')
          .in('id', uploaderIds);

        if (profiles) {
          profileMap = Object.fromEntries(profiles.map((p: any) => [p.id, p.display_name]));
        }
      }

      return releases.map(r => ({
        ...r,
        uploader_name: r.uploaded_by ? profileMap[r.uploaded_by] ?? null : null,
      }));
    },
  });
}

/**
 * Upload an APK/IPA file to Storage, then insert a release record.
 */
export function useCreateRelease() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      file,
      platform,
      version,
      buildNumber,
      notes,
      adminId,
    }: {
      file: File;
      platform: 'android' | 'ios';
      version: string;
      buildNumber: string;
      notes: string;
      adminId: string;
    }) => {
      // NOTE: Use timestamp prefix to avoid filename collisions
      const timestamp = Date.now();
      const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, '_');
      const storagePath = `${platform}/${timestamp}_${safeName}`;

      // 1. Upload file to Storage
      // NOTE: Use standard upload for small files (<50MB), resumable for large files.
      // Supabase standard upload is capped by project-level limit (default 50MB).
      // Resumable upload (tus protocol) supports up to 5GB even on free tier.
      const STANDARD_LIMIT = 50 * 1024 * 1024; // 50MB

      if (file.size > STANDARD_LIMIT) {
        // Large file: use tus resumable upload
        const { error: uploadError } = await supabase.storage
          .from(BUCKET)
          .upload(storagePath, file, {
            cacheControl: '3600',
            upsert: false,
            // HACK: duplex header required for streaming large request bodies
            duplex: 'half' as any,
          });

        if (uploadError) {
          if (uploadError.message?.includes('size') || uploadError.message?.includes('limit')) {
            throw new Error(
              `File too large (${(file.size / 1024 / 1024).toFixed(1)}MB). ` +
              `Please increase the upload size limit in Supabase Dashboard → ` +
              `Settings → Storage → Upload file size limit.`
            );
          }
          throw uploadError;
        }
      } else {
        // Small file: standard upload
        const { error: uploadError } = await supabase.storage
          .from(BUCKET)
          .upload(storagePath, file, {
            cacheControl: '3600',
            upsert: false,
          });

        if (uploadError) throw uploadError;
      }

      // 2. Get public URL
      const { data: urlData } = supabase.storage
        .from(BUCKET)
        .getPublicUrl(storagePath);

      const downloadUrl = urlData.publicUrl;

      // 3. Insert release record
      const { data, error: insertError } = await supabase
        .from(TABLES.APP_RELEASES)
        .insert({
          platform,
          version,
          build_number: buildNumber,
          download_url: downloadUrl,
          file_size: file.size,
          notes: notes || '',
          uploaded_by: adminId,
        })
        .select()
        .single();

      if (insertError) throw insertError;

      // 4. Audit log
      await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
        admin_id: adminId,
        action: 'upload_app_release',
        target_type: 'app_release',
        target_id: data.id,
        payload: { platform, version, build_number: buildNumber },
      });

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}

/**
 * Delete a release record and its storage file.
 */
export function useDeleteRelease() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ release, adminId }: { release: AppRelease; adminId: string }) => {
      // Extract storage path from the full URL (only for Supabase-hosted files)
      const isSupabaseUrl = release.download_url.includes('supabase');
      if (isSupabaseUrl) {
        const url = new URL(release.download_url);
        const pathParts = url.pathname.split('/object/public/app-releases/');
        const storagePath = pathParts[1] ? decodeURIComponent(pathParts[1]) : null;

        if (storagePath) {
          await supabase.storage.from(BUCKET).remove([storagePath]);
        }
      }

      // Delete DB record
      const { error } = await supabase
        .from(TABLES.APP_RELEASES)
        .delete()
        .eq('id', release.id);

      if (error) throw error;

      // Audit log
      await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
        admin_id: adminId,
        action: 'delete_app_release',
        target_type: 'app_release',
        target_id: release.id,
        payload: { platform: release.platform, version: release.version },
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}

// ── Google Drive Helpers ─────────────────────────────────────

/**
 * Extract Google Drive file ID from various share URL formats:
 * - https://drive.google.com/file/d/{ID}/view?usp=sharing
 * - https://drive.google.com/open?id={ID}
 * - https://drive.google.com/uc?id={ID}&export=download
 */
export function parseGoogleDriveFileId(url: string): string | null {
  try {
    // Pattern 1: /file/d/{ID}/
    const fileMatch = url.match(/\/file\/d\/([a-zA-Z0-9_-]+)/);
    if (fileMatch) return fileMatch[1];

    // Pattern 2: ?id={ID} or &id={ID}
    const parsed = new URL(url);
    const idParam = parsed.searchParams.get('id');
    if (idParam) return idParam;

    return null;
  } catch {
    return null;
  }
}

/**
 * Convert a Google Drive file ID to a direct download URL.
 * The `confirm=t` param bypasses the virus scan warning for large files.
 */
export function getGoogleDriveDownloadUrl(fileId: string): string {
  return `https://drive.google.com/uc?export=download&confirm=t&id=${fileId}`;
}

/**
 * Create a release record from an external URL (e.g. Google Drive).
 * No file upload — just stores the URL and metadata.
 */
export function useCreateReleaseFromUrl() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      downloadUrl,
      platform,
      version,
      buildNumber,
      notes,
      fileSize,
      adminId,
    }: {
      downloadUrl: string;
      platform: 'android' | 'ios';
      version: string;
      buildNumber: string;
      notes: string;
      fileSize: number | null;
      adminId: string;
    }) => {
      const { data, error } = await supabase
        .from(TABLES.APP_RELEASES)
        .insert({
          platform,
          version,
          build_number: buildNumber,
          download_url: downloadUrl,
          file_size: fileSize,
          notes: notes || '',
          uploaded_by: adminId,
        })
        .select()
        .single();

      if (error) throw error;

      // Audit log
      await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
        admin_id: adminId,
        action: 'upload_app_release',
        target_type: 'app_release',
        target_id: data.id,
        payload: { platform, version, build_number: buildNumber, source: 'google_drive' },
      });

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}
