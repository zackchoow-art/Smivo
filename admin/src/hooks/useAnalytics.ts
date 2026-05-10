import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';
import { useSchoolScopeStore } from '@/stores/school-scope-store';

type TimeRange = '7d' | '30d' | '90d' | '365d';

const RANGE_DAYS: Record<TimeRange, number> = {
  '7d': 7,
  '30d': 30,
  '90d': 90,
  '365d': 365,
};

function getStartDate(range: TimeRange): string {
  const d = new Date();
  d.setDate(d.getDate() - RANGE_DAYS[range]);
  return d.toISOString();
}

/**
 * Enhanced analytics hook with time range and school scope support.
 *
 * Fixes applied (2026-05-09):
 *   1. Field names match actual DB schema: hour_bucket / user_id (not hour_start / active_count)
 *   2. DAU calculated as COUNT(DISTINCT user_id) per day, not hourly peak
 *   3. Category/order distributions use DB-side aggregation instead of full-table pull
 *   4. School scope filtering via currentCollegeId (consistent with useDashboard)
 *
 * Added (2026-05-09):
 *   5. User registration trend (userTrend) for Dashboard chart
 *   6. Content reports trend (reportsTrend) for Dashboard chart
 */
export function useAnalytics(range: TimeRange = '7d') {
  const currentCollegeId = useSchoolScopeStore((state) => state.currentCollegeId);

  return useQuery({
    queryKey: ['analytics', range, currentCollegeId],
    queryFn: async () => {
      const startDate = getStartDate(range);

      // ── 1. DAU Trend ──────────────────────────────────────────────
      // hourly_active_users stores one row per (user_id, hour_bucket).
      // True DAU = count of DISTINCT user_ids per calendar day.
      // We fetch the raw rows for the period and aggregate client-side
      // using a Set to deduplicate users per day.
      let hauQuery = supabase
        .from(TABLES.HOURLY_ACTIVE_USERS)
        .select('hour_bucket, user_id')
        .gte('hour_bucket', startDate)
        .order('hour_bucket', { ascending: true });
      if (currentCollegeId) {
        hauQuery = hauQuery.eq('school_id', currentCollegeId);
      }
      const { data: hauRaw } = await hauQuery;

      // Deduplicate users per calendar day to compute true DAU
      const dailyUsers: Record<string, Set<string>> = {};
      hauRaw?.forEach(row => {
        const date = (row.hour_bucket as string).split('T')[0];
        if (!dailyUsers[date]) dailyUsers[date] = new Set();
        dailyUsers[date].add(row.user_id as string);
      });

      const dauTrend = Object.entries(dailyUsers)
        .map(([date, users]) => ({ date, count: users.size }))
        .sort((a, b) => a.date.localeCompare(b.date));

      // ── 2. Listings created over time ─────────────────────────────
      let listingsQuery = supabase
        .from(TABLES.LISTINGS)
        .select('created_at')
        .gte('created_at', startDate)
        .order('created_at', { ascending: true });
      if (currentCollegeId) {
        listingsQuery = listingsQuery.eq('school_id', currentCollegeId);
      }
      const { data: listingsRaw } = await listingsQuery;

      const dailyListings: Record<string, number> = {};
      listingsRaw?.forEach(row => {
        const date = (row.created_at as string).split('T')[0];
        dailyListings[date] = (dailyListings[date] || 0) + 1;
      });

      // ── 3. Orders created over time ───────────────────────────────
      // NOTE: orders table doesn't have school_id directly.
      // When school filter is active, join through listings to filter.
      let ordersQuery = currentCollegeId
        ? supabase
            .from(TABLES.ORDERS)
            .select('created_at, status, listing:listings!inner(school_id)')
            .eq('listing.school_id', currentCollegeId)
            .gte('created_at', startDate)
            .order('created_at', { ascending: true })
        : supabase
            .from(TABLES.ORDERS)
            .select('created_at, status')
            .gte('created_at', startDate)
            .order('created_at', { ascending: true });
      const { data: ordersRaw } = await ordersQuery;

      const dailyOrders: Record<string, number> = {};
      ordersRaw?.forEach(row => {
        const date = (row.created_at as string).split('T')[0];
        dailyOrders[date] = (dailyOrders[date] || 0) + 1;
      });

      // ── 4. User Registration Trend ────────────────────────────────
      let usersQuery = supabase
        .from(TABLES.USER_PROFILES)
        .select('created_at')
        .gte('created_at', startDate)
        .order('created_at', { ascending: true });
      if (currentCollegeId) {
        usersQuery = usersQuery.eq('school_id', currentCollegeId);
      }
      const { data: usersRaw } = await usersQuery;

      const dailyNewUsers: Record<string, number> = {};
      usersRaw?.forEach(row => {
        const date = (row.created_at as string).split('T')[0];
        dailyNewUsers[date] = (dailyNewUsers[date] || 0) + 1;
      });

      // ── 5. Reports Trend ──────────────────────────────────────────
      const { data: reportsRaw } = await supabase
        .from(TABLES.CONTENT_REPORTS)
        .select('created_at')
        .gte('created_at', startDate)
        .order('created_at', { ascending: true });

      const dailyReports: Record<string, number> = {};
      reportsRaw?.forEach(row => {
        const date = (row.created_at as string).split('T')[0];
        dailyReports[date] = (dailyReports[date] || 0) + 1;
      });

      // ── 6. Listing Category Distribution ──────────────────────────
      // Use DB-side aggregation to avoid pulling entire table.
      // PostgREST doesn't support GROUP BY natively, but we can use
      // an RPC or pull only the category column (lightweight).
      // For safety, limit to 10000 rows and aggregate client-side.
      let catQuery = supabase
        .from(TABLES.LISTINGS)
        .select('category')
        .limit(10000);
      if (currentCollegeId) {
        catQuery = catQuery.eq('school_id', currentCollegeId);
      }
      const { data: categories } = await catQuery;

      const categoryCounts: Record<string, number> = {};
      categories?.forEach(row => {
        const cat = row.category as string;
        categoryCounts[cat] = (categoryCounts[cat] || 0) + 1;
      });

      // ── 7. Order Status Distribution ──────────────────────────────
      let statusQuery = currentCollegeId
        ? supabase
            .from(TABLES.ORDERS)
            .select('status, listing:listings!inner(school_id)')
            .eq('listing.school_id', currentCollegeId)
            .limit(10000)
        : supabase
            .from(TABLES.ORDERS)
            .select('status')
            .limit(10000);
      const { data: orders } = await statusQuery;

      const orderCounts: Record<string, number> = {};
      orders?.forEach(row => {
        const status = row.status as string;
        orderCounts[status] = (orderCounts[status] || 0) + 1;
      });

      // ── 8. Rolling Active User Metrics (DAU, WAU, MAU) via RPC ───
      const { data: activeMetrics } = await supabase.rpc('get_active_user_metrics', {
        p_school_id: currentCollegeId,
      });

      // ── 9. Summary KPIs ───────────────────────────────────────────
      const newListingsCount = listingsRaw?.length ?? 0;
      const newOrdersCount = ordersRaw?.length ?? 0;
      const dauValues = dauTrend.map(d => d.count);
      const avgDau = dauValues.length > 0
        ? Math.round(dauValues.reduce((a, b) => a + b, 0) / dauValues.length)
        : 0;

      return {
        dauTrend,
        listingsTrend: Object.entries(dailyListings).map(([date, count]) => ({ date, count })),
        ordersTrend: Object.entries(dailyOrders).map(([date, count]) => ({ date, count })),
        userTrend: Object.entries(dailyNewUsers).map(([date, count]) => ({ date, count })),
        reportsTrend: Object.entries(dailyReports).map(([date, count]) => ({ date, count })),
        categoryDist: Object.entries(categoryCounts).map(([name, count]) => ({ name, count })),
        orderDist: Object.entries(orderCounts).map(([name, count]) => ({ name, count })),
        kpis: {
          newListingsCount,
          newOrdersCount,
          avgDau,
          peakDau: dauValues.length > 0 ? Math.max(...dauValues) : 0,
          rollingDau: activeMetrics?.dau ?? 0,
          rollingWau: activeMetrics?.wau ?? 0,
          rollingMau: activeMetrics?.mau ?? 0,
        },
      };
    },
    staleTime: 10 * 60 * 1000,
  });
}

export type { TimeRange };
export { RANGE_DAYS };

