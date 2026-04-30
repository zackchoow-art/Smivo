import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';
import type { Listing } from '@/types';
import type { AuditLog } from '@/types/audit-log';

const QUERY_KEY = ['dashboard-stats'] as const;

export function useDashboard() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: async () => {
      // 1. KPI - Total Users
      const { count: userCount } = await supabase
        .from(TABLES.USER_PROFILES)
        .select('*', { count: 'exact', head: true });

      // 2. KPI - Total Listings
      const { count: listingCount } = await supabase
        .from(TABLES.LISTINGS)
        .select('*', { count: 'exact', head: true });

      // 3. KPI - Active Orders (not completed/cancelled)
      const { count: activeOrderCount } = await supabase
        .from(TABLES.ORDERS)
        .select('*', { count: 'exact', head: true })
        .not('status', 'in', '("completed","cancelled","missed")');

      // 4. KPI - Today DAU (distinct_users from hourly_active_users)
      const today = new Date().toISOString().split('T')[0];
      // NOTE: DB columns are 'hour_start' and 'active_count', not 'hour_bucket'/'distinct_users'
      const { data: dauData } = await supabase
        .from(TABLES.HOURLY_ACTIVE_USERS)
        .select('active_count')
        .gte('hour_start', today)
        .order('hour_start', { ascending: false })
        .limit(1);
      
      const todayDau = dauData?.[0]?.active_count ?? 0;

      // 5. Recent Audit Logs (top 10)
      const { data: recentLogs } = await supabase
        .from(TABLES.ADMIN_AUDIT_LOGS)
        .select('*')
        .order('created_at', { ascending: false })
        .limit(10);

      // 6. Pending Review Listings (top 5)
      const { data: pendingListings } = await supabase
        .from(TABLES.LISTINGS)
        .select('*')
        .eq('moderation_status', 'pending_review')
        .order('created_at', { ascending: false })
        .limit(5);

      return {
        stats: {
          userCount: userCount ?? 0,
          listingCount: listingCount ?? 0,
          activeOrderCount: activeOrderCount ?? 0,
          todayDau,
        },
        recentLogs: (recentLogs ?? []) as AuditLog[],
        pendingListings: (pendingListings ?? []) as Listing[],
      };
    },
    // Refresh every 5 minutes for dashboard freshness
    staleTime: 5 * 60 * 1000,
  });
}
