import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';

const QUERY_KEY = ['analytics'] as const;

export function useAnalytics() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: async () => {
      // 1. DAU Trend (Last 7 days)
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
      // NOTE: DB columns are 'hour_start' and 'active_count', not 'hour_bucket'/'distinct_users'
      const { data: dauTrend } = await supabase
        .from(TABLES.HOURLY_ACTIVE_USERS)
        .select('hour_start, active_count')
        .gte('hour_start', sevenDaysAgo.toISOString())
        .order('hour_start', { ascending: true });

      // Aggregate hourly rows to daily max
      const dailyDau: Record<string, number> = {};
      dauTrend?.forEach(row => {
        const date = row.hour_start.split('T')[0];
        dailyDau[date] = Math.max(dailyDau[date] || 0, row.active_count);
      });

      // 2. Listing Category Distribution
      const { data: categories } = await supabase
        .from(TABLES.LISTINGS)
        .select('category');
      
      const categoryCounts: Record<string, number> = {};
      categories?.forEach(row => {
        categoryCounts[row.category] = (categoryCounts[row.category] || 0) + 1;
      });

      // 3. Order Status Distribution
      const { data: orders } = await supabase
        .from(TABLES.ORDERS)
        .select('status');
      
      const orderCounts: Record<string, number> = {};
      orders?.forEach(row => {
        orderCounts[row.status] = (orderCounts[row.status] || 0) + 1;
      });

      return {
        dauTrend: Object.entries(dailyDau).map(([date, count]) => ({ date, count })),
        categoryDist: Object.entries(categoryCounts).map(([name, count]) => ({ name, count })),
        orderDist: Object.entries(orderCounts).map(([name, count]) => ({ name, count })),
      };
    },
    staleTime: 10 * 60 * 1000, // 10 minutes cache
  });
}
