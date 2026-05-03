import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';
import type { Listing } from '@/types';
import type { AuditLog } from '@/types/audit-log';
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
        todayDau,
        pendingReportCount,
        pendingModerationCount,
        pendingFeedbackCount,
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

        // 4. Today DAU via RPC
        (async () => {
          try {
            const { data, error } = await supabase.rpc('get_today_dau');
            if (error) {
              console.warn('[Dashboard] get_today_dau RPC failed:', error.message);
              return 0;
            }
            return typeof data === 'number' ? data : 0;
          } catch {
            return 0;
          }
        })(),

        // 5. Pending chat reports
        safeCount(TABLES.CONTENT_REPORTS, (q: any) => {
          let query = q.eq('status', 'pending');
          // No direct way to filter reports by school unless we join
          return query;
        }),

        // 6. Pending listing moderations
        safeCount(TABLES.LISTINGS, (q: any) => {
          let query = q.eq('moderation_status', 'pending_review');
          if (currentCollegeId) query = query.eq('school_id', currentCollegeId);
          return query;
        }),

        // 7. Pending feedbacks
        safeCount(TABLES.USER_FEEDBACKS, (q: any) => q.eq('status', 'submitted')),
      ]);

      // 8. Recent Audit Logs (top 10)
      let recentLogs: AuditLog[] = [];
      try {
        const { data, error } = await supabase
          .from(TABLES.ADMIN_AUDIT_LOGS)
          .select('*')
          .order('created_at', { ascending: false })
          .limit(10);
        if (!error && data) recentLogs = data as AuditLog[];
      } catch {
        // NOTE: Non-critical — show empty logs
      }

      // 9. Urgent Pending Listings (oldest 5, potentially near SLA timeout)
      let urgentListings: Listing[] = [];
      try {
        let q = supabase
          .from(TABLES.LISTINGS)
          .select('*')
          .eq('moderation_status', 'pending_review')
          .order('created_at', { ascending: true })  // Oldest first = most urgent
          .limit(5);
        if (currentCollegeId) {
          q = q.eq('school_id', currentCollegeId);
        }
        const { data, error } = await q;
        if (!error && data) urgentListings = data as Listing[];
      } catch {
        // NOTE: Non-critical
      }

      // 10. Urgent Chat Reports (oldest pending reports)
      let urgentReports: any[] = [];
      try {
        const { data, error } = await supabase
          .from(TABLES.CONTENT_REPORTS)
          .select(`
            *,
            reporter:reporter_id(display_name, email),
            reported:reported_user_id(display_name, email)
          `)
          .eq('status', 'pending')
          .order('created_at', { ascending: true })
          .limit(5);
        if (!error && data) urgentReports = data;
      } catch {
        // NOTE: Non-critical
      }

      return {
        stats: {
          userCount,
          listingCount,
          activeOrderCount,
          todayDau,
          pendingReportCount,
          pendingModerationCount,
          pendingFeedbackCount,
        },
        recentLogs,
        urgentListings,
        urgentReports,
      };
    },
    // NOTE: Retry once max — don't make user wait 30s on repeated failures
    retry: 1,
    staleTime: 5 * 60 * 1000,
  });
}
