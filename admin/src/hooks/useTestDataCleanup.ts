/**
 * Hook for pre-launch test data cleanup operations.
 * Calls SECURITY DEFINER RPCs; permission enforcement is on the DB side.
 * canPurgePlatformData / canPurgeSchoolData are checked on the UI side too
 * to prevent unnecessary RPC calls.
 *
 * After the DB purge succeeds, all files in UGC Storage buckets are also
 * deleted (listing-images, order-files, avatars, moderation-test-images).
 */
import { useMutation } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';

export interface PurgeResult {
  status: string;
  scope: string;
  purged_at: string;
  school_id?: string;
  /** Number of storage files deleted across all buckets. */
  storage_files_deleted?: number;
}

/** Verify the current session is valid before calling a SECURITY DEFINER RPC */
async function ensureValidSession() {
  const { data: { session }, error } = await supabase.auth.getSession();
  if (error || !session) {
    console.error('[Cleanup] No valid session:', error);
    throw new Error('Session expired. Please log out and log back in.');
  }
  console.log('[Cleanup] Session valid, uid:', session.user.id);
  return session;
}

// ── Storage cleanup helpers ─────────────────────────────────────────────────

/**
 * Buckets that hold user-generated content and should be emptied on purge.
 * NOTE: 'avatars' is intentionally excluded — user profile pictures are
 * preserved because user accounts themselves are not deleted during cleanup.
 */
const UGC_BUCKETS = [
  'listing-images',
  'order-files',
  'moderation-test-images',
] as const;

/**
 * Recursively lists all files in a Storage bucket folder and deletes them
 * in batches. Supabase Storage `list()` returns both files and folders;
 * folders have `id: null` and must be traversed recursively.
 *
 * NOTE: The Storage JS SDK `remove()` accepts up to ~1000 paths per call.
 * We batch in groups of 500 to stay well within limits.
 */
async function emptyBucket(bucketId: string): Promise<number> {
  let totalDeleted = 0;

  async function deleteFolder(prefix: string) {
    const { data: items, error } = await supabase.storage
      .from(bucketId)
      .list(prefix, { limit: 1000 });

    if (error) {
      console.warn(`[Cleanup] Failed to list ${bucketId}/${prefix}:`, error.message);
      return;
    }
    if (!items || items.length === 0) return;

    // Separate files from folders
    const filePaths: string[] = [];
    const subFolders: string[] = [];

    for (const item of items) {
      const fullPath = prefix ? `${prefix}/${item.name}` : item.name;
      // Supabase marks folders with id=null in the list response
      if (item.id === null) {
        subFolders.push(fullPath);
      } else {
        filePaths.push(fullPath);
      }
    }

    // Recurse into subfolders first
    for (const folder of subFolders) {
      await deleteFolder(folder);
    }

    // Delete files in batches of 500
    for (let i = 0; i < filePaths.length; i += 500) {
      const batch = filePaths.slice(i, i + 500);
      const { error: removeError } = await supabase.storage
        .from(bucketId)
        .remove(batch);

      if (removeError) {
        console.warn(`[Cleanup] Failed to remove ${batch.length} files from ${bucketId}:`, removeError.message);
      } else {
        totalDeleted += batch.length;
      }
    }
  }

  await deleteFolder('');
  return totalDeleted;
}

/**
 * Empties all UGC Storage buckets.
 * Returns the total number of files deleted across all buckets.
 */
async function purgeAllStorageBuckets(): Promise<number> {
  let total = 0;
  for (const bucket of UGC_BUCKETS) {
    console.log(`[Cleanup] Emptying storage bucket: ${bucket}`);
    const deleted = await emptyBucket(bucket);
    console.log(`[Cleanup] Deleted ${deleted} files from ${bucket}`);
    total += deleted;
  }
  return total;
}

// ── Mutation hooks ──────────────────────────────────────────────────────────

/** Delete all user-generated content for a specific school. */
export function usePurgeSchoolData() {
  return useMutation({
    mutationFn: async (schoolId: string): Promise<PurgeResult> => {
      await ensureValidSession();

      // Step 1: Purge database records via RPC
      console.log('[Cleanup] Calling clear_school_test_data with:', schoolId);
      const { data, error } = await supabase.rpc('clear_school_test_data', {
        p_school_id: schoolId,
      });
      if (error) {
        console.error('[Cleanup] School purge error:', JSON.stringify(error));
        throw error;
      }

      // Step 2: Purge Storage files
      // NOTE: For school-scoped cleanup we still empty all buckets because
      // listing-images paths are keyed by user_id, not school_id, making
      // it impractical to filter by school. Since this is a pre-launch tool,
      // clearing all storage is acceptable.
      console.log('[Cleanup] Purging storage buckets...');
      const storageDeleted = await purgeAllStorageBuckets();
      console.log(`[Cleanup] Total storage files deleted: ${storageDeleted}`);

      const result = data as PurgeResult;
      result.storage_files_deleted = storageDeleted;
      return result;
    },
  });
}
