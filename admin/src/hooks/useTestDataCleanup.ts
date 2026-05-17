/**
 * Hook for school-scoped test data cleanup with backup & restore.
 *
 * Flow (purge):
 *   1. Delete any previous unrestored backup for this school (DB + storage)
 *   2. Call clear_school_test_data RPC → snapshots data into cleanup_backups,
 *      deletes DB records, returns backup_id + user_ids + order_ids
 *   3. Copy affected storage files to cleanup-backups bucket
 *   4. ONLY delete originals if ALL copies succeeded
 *
 * Flow (restore):
 *   1. Call restore_school_backup RPC → re-inserts DB records
 *   2. Copy files from cleanup-backups bucket back to original buckets
 *   3. Keep backup files intact (they are purged on next cleanup, not here)
 *
 * Platform-wide purge is deliberately NOT provided here. All cleanup
 * is scoped to a single school.
 */
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';

// ── Types ───────────────────────────────────────────────────────────────────

export interface PurgeResult {
  status: string;
  scope: string;
  school_id: string;
  backup_id: string;
  user_ids: string[];
  order_ids: string[];
  purged_at: string;
  storage_files_backed_up?: number;
  storage_files_deleted?: number;
  storage_errors?: number;
}

export interface BackupInfo {
  id: string;
  school_id: string;
  created_at: string;
  restored_at: string | null;
  purged_at: string | null;
  meta: {
    school_id: string;
    rpc_version: string;
    cleaned_at: string;
    listing_count: number;
    user_count: number;
    order_count: number;
  };
  storage_manifest: string[];
}

export interface RestoreResult {
  status: string;
  backup_id: string;
  school_id: string;
  listings_restored: number;
  restored_at: string;
  storage_files_restored?: number;
  storage_errors?: number;
}

// ── Session helper ──────────────────────────────────────────────────────────

async function ensureValidSession() {
  const { data: { session }, error } = await supabase.auth.getSession();
  if (error || !session) {
    throw new Error('Session expired. Please log out and log back in.');
  }
  return session;
}

// ── Scoped storage helpers ──────────────────────────────────────────────────

const BACKUP_BUCKET = 'cleanup-backups';

/**
 * Recursively lists all file paths under a given prefix in a bucket.
 * Returns full paths (e.g. "userId/listingId/photo.jpg").
 */
async function listFilesRecursive(
  bucketId: string,
  prefix: string,
): Promise<string[]> {
  const paths: string[] = [];

  const { data: items, error } = await supabase.storage
    .from(bucketId)
    .list(prefix, { limit: 1000 });

  if (error) {
    console.error(`[Storage] list(${bucketId}/${prefix}) error:`, error.message);
    return paths;
  }
  if (!items || items.length === 0) return paths;

  for (const item of items) {
    const fullPath = prefix ? `${prefix}/${item.name}` : item.name;
    if (item.id === null) {
      // Supabase marks folders with id=null — recurse
      const subPaths = await listFilesRecursive(bucketId, fullPath);
      paths.push(...subPaths);
    } else {
      paths.push(fullPath);
    }
  }
  return paths;
}

/**
 * Copies files from a source bucket to the backup bucket under a backupId prefix.
 * Returns { succeeded, failed } counts and the list of backed-up paths.
 */
async function copyFilesToBackup(
  sourceBucket: string,
  filePaths: string[],
  backupId: string,
): Promise<{ backedUp: string[]; failCount: number }> {
  const backedUp: string[] = [];
  let failCount = 0;

  for (const path of filePaths) {
    const destPath = `${backupId}/${sourceBucket}/${path}`;
    const { error } = await supabase.storage
      .from(sourceBucket)
      .copy(path, destPath, { destinationBucket: BACKUP_BUCKET });

    if (error) {
      console.error(`[Backup] FAILED copy ${sourceBucket}/${path} → ${BACKUP_BUCKET}/${destPath}:`, error.message);
      failCount++;
    } else {
      backedUp.push(destPath);
    }
  }
  return { backedUp, failCount };
}

/**
 * Copies files from the backup bucket back to their original buckets.
 * Each manifest entry has format: "{backupId}/{bucketName}/{originalPath}"
 */
async function copyFilesFromBackup(
  manifest: string[],
  backupId: string,
): Promise<{ restored: number; failCount: number }> {
  let restored = 0;
  let failCount = 0;

  for (const backupPath of manifest) {
    // Parse: "{backupId}/{bucketName}/{originalPath}"
    const withoutPrefix = backupPath.substring(backupId.length + 1);
    const slashIdx = withoutPrefix.indexOf('/');
    if (slashIdx === -1) {
      console.warn(`[Restore] Skipping malformed path: ${backupPath}`);
      failCount++;
      continue;
    }

    const originalBucket = withoutPrefix.substring(0, slashIdx);
    const originalPath = withoutPrefix.substring(slashIdx + 1);

    const { error } = await supabase.storage
      .from(BACKUP_BUCKET)
      .copy(backupPath, originalPath, { destinationBucket: originalBucket });

    if (error) {
      console.error(`[Restore] FAILED copy ${BACKUP_BUCKET}/${backupPath} → ${originalBucket}/${originalPath}:`, error.message);
      failCount++;
    } else {
      restored++;
    }
  }
  return { restored, failCount };
}

/**
 * Deletes files from a bucket in batches of 500.
 */
async function deleteFiles(bucketId: string, paths: string[]): Promise<number> {
  let deleted = 0;
  for (let i = 0; i < paths.length; i += 500) {
    const batch = paths.slice(i, i + 500);
    const { error } = await supabase.storage.from(bucketId).remove(batch);
    if (!error) deleted += batch.length;
    else console.warn(`[Cleanup] Failed to delete ${batch.length} files from ${bucketId}:`, error.message);
  }
  return deleted;
}

/**
 * Collects all storage file paths belonging to specific users and orders.
 * Only targets files under the provided user/order folders.
 */
async function collectScopedFiles(
  userIds: string[],
  orderIds: string[],
): Promise<{ listingImagePaths: string[]; orderFilePaths: string[] }> {
  const listingImagePaths: string[] = [];
  const orderFilePaths: string[] = [];

  // listing-images: path format is {userId}/{listingId}/{filename}
  for (const uid of userIds) {
    const files = await listFilesRecursive('listing-images', uid);
    console.log(`[Cleanup] listing-images/${uid}/ → ${files.length} files`);
    listingImagePaths.push(...files);
  }

  // order-files: path format is {orderId}/...
  for (const oid of orderIds) {
    const files = await listFilesRecursive('order-files', oid);
    if (files.length > 0) {
      console.log(`[Cleanup] order-files/${oid}/ → ${files.length} files`);
    }
    orderFilePaths.push(...files);
  }

  return { listingImagePaths, orderFilePaths };
}

/**
 * Saves the storage manifest to the backup record.
 */
async function updateStorageManifest(
  backupId: string,
  manifest: string[],
): Promise<void> {
  const { error } = await supabase
    .from('cleanup_backups')
    .update({ storage_manifest: manifest })
    .eq('id', backupId);

  if (error) {
    console.error('[Cleanup] Failed to save storage manifest:', error.message);
  }
}

// ── Delete previous backup storage files ────────────────────────────────────

async function purgeOldBackupFiles(backupId: string): Promise<void> {
  const files = await listFilesRecursive(BACKUP_BUCKET, backupId);
  if (files.length > 0) {
    console.log(`[Cleanup] Deleting ${files.length} old backup files for ${backupId}`);
    await deleteFiles(BACKUP_BUCKET, files);
  }
}

// ── Query: list existing backups ────────────────────────────────────────────

export function useSchoolBackups(schoolId: string | undefined) {
  return useQuery({
    queryKey: ['school-backups', schoolId],
    enabled: !!schoolId,
    queryFn: async (): Promise<BackupInfo[]> => {
      if (!schoolId) return [];
      const { data, error } = await supabase.rpc('get_school_backups', {
        p_school_id: schoolId,
      });
      if (error) throw new Error(error.message);
      return (data as BackupInfo[]) ?? [];
    },
  });
}

// ── Mutation: school-scoped purge with backup ───────────────────────────────

export function usePurgeSchoolData() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationKey: ['purge-school-data'],
    mutationFn: async (schoolId: string): Promise<PurgeResult> => {
      await ensureValidSession();

      // Step 1: Clean up any previous unrestored backup for this school
      console.log('[Cleanup] Checking for previous backups...');
      const { data: existingBackups } = await supabase.rpc('get_school_backups', {
        p_school_id: schoolId,
      });
      if (existingBackups && Array.isArray(existingBackups)) {
        for (const backup of existingBackups as BackupInfo[]) {
          console.log(`[Cleanup] Deleting previous backup ${backup.id}...`);
          await purgeOldBackupFiles(backup.id);
          await supabase.rpc('delete_school_backup', { p_backup_id: backup.id });
        }
      }

      // Step 2: Call RPC — snapshots DB data then deletes DB records
      console.log('[Cleanup] Calling clear_school_test_data...');
      const { data, error } = await supabase.rpc('clear_school_test_data', {
        p_school_id: schoolId,
      });
      if (error) {
        console.error('[Cleanup] RPC error:', JSON.stringify(error, null, 2));
        throw new Error(error.message ?? JSON.stringify(error));
      }
      console.log('[Cleanup] RPC returned:', JSON.stringify(data, null, 2));

      const result = data as PurgeResult;
      const backupId = result.backup_id;
      const userIds: string[] = result.user_ids ?? [];
      const orderIds: string[] = result.order_ids ?? [];

      // Step 3: Collect scoped storage files (files still exist — only DB was deleted)
      console.log('[Cleanup] Collecting scoped storage files...');
      const { listingImagePaths, orderFilePaths } = await collectScopedFiles(
        userIds,
        orderIds,
      );
      const totalSourceFiles = listingImagePaths.length + orderFilePaths.length;
      console.log(`[Cleanup] Found ${listingImagePaths.length} listing images, ${orderFilePaths.length} order files`);

      // Step 4: Copy files to backup bucket
      const allBackedUp: string[] = [];
      let totalErrors = 0;

      if (listingImagePaths.length > 0) {
        console.log('[Cleanup] Backing up listing images...');
        const { backedUp, failCount } = await copyFilesToBackup('listing-images', listingImagePaths, backupId);
        allBackedUp.push(...backedUp);
        totalErrors += failCount;
      }
      if (orderFilePaths.length > 0) {
        console.log('[Cleanup] Backing up order files...');
        const { backedUp, failCount } = await copyFilesToBackup('order-files', orderFilePaths, backupId);
        allBackedUp.push(...backedUp);
        totalErrors += failCount;
      }

      result.storage_files_backed_up = allBackedUp.length;
      result.storage_errors = totalErrors;

      // Save manifest BEFORE deleting originals
      await updateStorageManifest(backupId, allBackedUp);

      // Step 5: ONLY delete originals if backup fully succeeded
      // SAFETY: If ANY copy failed, abort deletion to prevent data loss.
      let totalDeleted = 0;
      if (totalErrors > 0) {
        console.error(`[Cleanup] ⚠️ ${totalErrors} backup copies FAILED — skipping deletion of originals to prevent data loss`);
      } else if (totalSourceFiles > 0 && allBackedUp.length === 0) {
        console.error('[Cleanup] ⚠️ Found source files but NONE were backed up — skipping deletion');
      } else {
        if (listingImagePaths.length > 0) {
          console.log('[Cleanup] Deleting listing images from source...');
          totalDeleted += await deleteFiles('listing-images', listingImagePaths);
        }
        if (orderFilePaths.length > 0) {
          console.log('[Cleanup] Deleting order files from source...');
          totalDeleted += await deleteFiles('order-files', orderFilePaths);
        }
      }
      result.storage_files_deleted = totalDeleted;

      console.log(`[Cleanup] Done. Backed up ${allBackedUp.length}, deleted ${totalDeleted}, errors ${totalErrors}`);
      return result;
    },
    onSuccess: (_data, schoolId) => {
      queryClient.invalidateQueries({ queryKey: ['school-backups', schoolId] });
    },
    onError: (err: unknown) => {
      console.error('[Cleanup] Mutation error:', err instanceof Error ? err.message : err);
    },
  });
}

// ── Mutation: restore from backup ───────────────────────────────────────────

export function useRestoreSchoolBackup() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationKey: ['restore-school-backup'],
    mutationFn: async (params: {
      backupId: string;
      schoolId: string;
      storageManifest: string[];
    }): Promise<RestoreResult> => {
      await ensureValidSession();
      const { backupId, schoolId, storageManifest } = params;

      // Step 1: Restore DB records via RPC
      console.log('[Restore] Calling restore_school_backup...');
      const { data, error } = await supabase.rpc('restore_school_backup', {
        p_backup_id: backupId,
      });
      if (error) {
        console.error('[Restore] RPC error:', JSON.stringify(error, null, 2));
        throw new Error(error.message ?? JSON.stringify(error));
      }
      const result = data as RestoreResult;

      // Step 2: Restore storage files using the saved manifest
      // The manifest contains exact paths that were backed up, which is more
      // reliable than scanning the backup bucket (avoids folder listing issues).
      console.log(`[Restore] Restoring ${storageManifest.length} storage files from manifest...`);

      let manifest = storageManifest;

      // Fallback: if manifest is empty, try scanning the backup bucket directly
      if (!manifest || manifest.length === 0) {
        console.log('[Restore] Manifest empty, scanning backup bucket...');
        manifest = await listFilesRecursive(BACKUP_BUCKET, backupId);
        console.log(`[Restore] Found ${manifest.length} files in backup bucket`);
      }

      const { restored, failCount } = await copyFilesFromBackup(manifest, backupId);
      result.storage_files_restored = restored;
      result.storage_errors = failCount;

      // NOTE: We intentionally do NOT delete backup files here.
      // Keeping them allows re-running restore if needed.
      // Backup files are purged on the NEXT cleanup for this school.

      console.log(`[Restore] Done. Restored ${restored} files, ${failCount} failures.`);

      queryClient.invalidateQueries({ queryKey: ['school-backups', schoolId] });
      return result;
    },
    onError: (err: unknown) => {
      console.error('[Restore] Mutation error:', err instanceof Error ? err.message : err);
    },
  });
}
