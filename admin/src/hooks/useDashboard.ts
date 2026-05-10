import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';
import { useSchoolScopeStore } from '@/stores/school-scope-store';

const QUERY_KEY = ['dashboard-stats'] as const;

/**
 * Safely run a Supabase query and return fallback on failure.
 * Prevents a single broken query from blocking the entire dashboard.
 */
async function safeCount(table: string, filter?: (q: any) => any, selectStr = '*'): Promise<number> {
  try {
    let q = supabase.from(table).select(selectStr, { count: 'exact', head: true });
    if (filter) q = filter(q);
    const { count, error } = await q;
    if (error) {
      console.warn(`[Dashboard] count query failed for ${table}:`, error.message);
      return 0;
    }
    return count ?? 0;
  } catch {
    return 0;
  }
}

export function useDashboard() {
  const currentCollegeId = useSchoolScopeStore((state) => state.currentCollegeId);

  return useQuery({
    queryKey: [...QUERY_KEY, currentCollegeId],
    queryFn: async () => {
      // Run all KPI queries in parallel for speed
      const [
        userCount,
        listingCount,
        activeOrderCount,
        activeUsers,
        pendingReportCount,
        pendingModerationCount,
        pendingFeedbackCount,
        autoApprovedCount,
        aiRejectedCount,
        newUserCount,
      ] = await Promise.all([
        // 1. Total Users
        safeCount(TABLES.USER_PROFILES, currentCollegeId ? (q: any) => q.eq('school_id', currentCollegeId) : undefined),

        // 2. Total Listings
        safeCount(TABLES.LISTINGS, currentCollegeId ? (q: any) => q.eq('school_id', currentCollegeId) : undefined),

        // 3. Active Orders (not completed/cancelled/missed)
        safeCount(TABLES.ORDERS, (q: any) => {
          let query = q.not('status', 'in', '("completed","cancelled","missed")');
          if (currentCollegeId) {
             query = query.eq('listing.school_id', currentCollegeId);
          }
          return query;
        }, currentCollegeId ? '*, listing:listings!inner(school_id)' : '*'),

        // 4. Active User Metrics (DAU, WAU, MAU) via RPC
        (async () => {
          try {
            const { data, error } = await supabase.rpc('get_active_user_metrics', {
              p_school_id: currentCollegeId
            });
            if (error) {
              console.warn('[Dashboard] get_active_user_metrics RPC failed:', error.message);
              return { dau: 0, wau: 0, mau: 0 };
            }
            return data as { dau: number; wau: number; mau: number };
          } catch {
            return { dau: 0, wau: 0, mau: 0 };
          }
        })(),

        // 5. Pending chat reports
        safeCount(TABLES.CONTENT_REPORTS, (q: any) => q.eq('status', 'pending')),

        // 6. Pending listing moderations
        safeCount(TABLES.LISTINGS, (q: any) => {
          let query = q.eq('moderation_status', 'pending_review');
          if (currentCollegeId) query = query.eq('school_id', currentCollegeId);
          return query;
        }),

        // 7. Pending feedbacks
        safeCount(TABLES.USER_FEEDBACKS, (q: any) => q.eq('status', 'submitted')),

        // 8. AI auto-approved listings count
        safeCount(TABLES.LISTINGS, (q: any) => {
          let query = q.eq('moderation_status', 'auto_approved');
          if (currentCollegeId) query = query.eq('school_id', currentCollegeId);
          return query;
        }),

        // 9. AI rejected listings (rejected + no human moderator = automated)
        safeCount(TABLES.LISTINGS, (q: any) => {
          let query = q.eq('moderation_status', 'rejected').is('moderated_by', null);
          if (currentCollegeId) query = query.eq('school_id', currentCollegeId);
          return query;
        }),

        // 10. New users (registered in last 7 days)
        safeCount(TABLES.USER_PROFILES, (q: any) => {
          const sevenDaysAgo = new Date();
          sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
          let query = q.gte('created_at', sevenDaysAgo.toISOString());
          if (currentCollegeId) query = query.eq('school_id', currentCollegeId);
          return query;
        }),
      ]);

      return {
        stats: {
          userCount,
          listingCount,
          activeOrderCount,
          activeUsers,
          pendingReportCount,
          pendingModerationCount,
          pendingFeedbackCount,
          autoApprovedCount,
          aiRejectedCount,
          newUserCount,
        },
      };
    },
    // NOTE: Retry once max — don't make user wait 30s on repeated failures
    retry: 1,
    staleTime: 5 * 60 * 1000,
  });
}
