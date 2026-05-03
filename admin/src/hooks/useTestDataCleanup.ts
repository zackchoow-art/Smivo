/**
 * Hook for pre-launch test data cleanup operations.
 * Calls SECURITY DEFINER RPCs; permission enforcement is on the DB side.
 * canPurgePlatformData / canPurgeSchoolData are checked on the UI side too
 * to prevent unnecessary RPC calls.
 */
import { useMutation } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';

export interface PurgeResult {
  status: string;
  scope: string;
  purged_at: string;
  school_id?: string;
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

/** Delete all user-generated content for a specific school. */
export function usePurgeSchoolData() {
  return useMutation({
    mutationFn: async (schoolId: string): Promise<PurgeResult> => {
      await ensureValidSession();
      console.log('[Cleanup] Calling clear_school_test_data with:', schoolId);
      const { data, error } = await supabase.rpc('clear_school_test_data', {
        p_school_id: schoolId,
      });
      if (error) {
        console.error('[Cleanup] School purge error:', JSON.stringify(error));
        throw error;
      }
      return data as PurgeResult;
    },
  });
}
