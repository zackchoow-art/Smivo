import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';
import type { Listing } from '@/types';
import type { AuditLog } from '@/types/audit-log';

const QUERY_KEY = ['dashboard-stats'] as const;

/**
 * Safely run a Supabase query and return fallback on failure.
 * Prevents a single broken query from blocking the entire dashboard.
 */
async function safeCount(table: string, filter?: (q: any) => any): Promise<number> {
  try {
    let q = supabase.from(table).select('*', { count: 'exact', head: true });
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
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: async () => {
      // Run all KPI queries in parallel for speed
      const [userCount, listingCount, activeOrderCount, todayDau] = await Promise.all([
        // 1. Total Users
        safeCount(TABLES.USER_PROFILES),

        // 2. Total Listings
        safeCount(TABLES.LISTINGS),

        // 3. Active Orders (not completed/cancelled/missed)
        safeCount(TABLES.ORDERS, (q: any) =>
          q.not('status', 'in', '("completed","cancelled","missed")')
        ),

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
      ]);

      // 5. Recent Audit Logs (top 10)
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

      // 6. Pending Review Listings (top 5)
      let pendingListings: Listing[] = [];
      try {
        const { data, error } = await supabase
          .from(TABLES.LISTINGS)
          .select('*')
          .eq('moderation_status', 'pending_review')
          .order('created_at', { ascending: false })
          .limit(5);
        if (!error && data) pendingListings = data as Listing[];
      } catch {
        // NOTE: Non-critical — show empty list
      }

      return {
        stats: { userCount, listingCount, activeOrderCount, todayDau },
        recentLogs,
        pendingListings,
      };
    },
    // NOTE: Retry once max — don't make user wait 30s on repeated failures
    retry: 1,
    staleTime: 5 * 60 * 1000,
  });
}
