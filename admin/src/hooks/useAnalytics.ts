import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';

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
 * Enhanced analytics hook with time range support.
 * Aggregates DAU, listings over time, and distributions.
 */
export function useAnalytics(range: TimeRange = '7d') {
  return useQuery({
    queryKey: ['analytics', range],
    queryFn: async () => {
      const startDate = getStartDate(range);

      // 1. DAU Trend — aggregate hourly to daily
      const { data: dauRaw } = await supabase
        .from(TABLES.HOURLY_ACTIVE_USERS)
        .select('hour_start, active_count')
        .gte('hour_start', startDate)
        .order('hour_start', { ascending: true });

      const dailyDau: Record<string, number> = {};
      dauRaw?.forEach(row => {
        const date = row.hour_start.split('T')[0];
        dailyDau[date] = Math.max(dailyDau[date] || 0, row.active_count);
      });

      // 2. Listings created over time
      const { data: listingsRaw } = await supabase
        .from(TABLES.LISTINGS)
        .select('created_at')
        .gte('created_at', startDate)
        .order('created_at', { ascending: true });

      const dailyListings: Record<string, number> = {};
      listingsRaw?.forEach(row => {
        const date = row.created_at.split('T')[0];
        dailyListings[date] = (dailyListings[date] || 0) + 1;
      });

      // 3. Orders created over time
      const { data: ordersRaw } = await supabase
        .from(TABLES.ORDERS)
        .select('created_at, status')
        .gte('created_at', startDate)
        .order('created_at', { ascending: true });

      const dailyOrders: Record<string, number> = {};
      ordersRaw?.forEach(row => {
        const date = row.created_at.split('T')[0];
        dailyOrders[date] = (dailyOrders[date] || 0) + 1;
      });

      // 4. Listing Category Distribution (all time)
      const { data: categories } = await supabase
        .from(TABLES.LISTINGS)
        .select('category');

      const categoryCounts: Record<string, number> = {};
      categories?.forEach(row => {
        categoryCounts[row.category] = (categoryCounts[row.category] || 0) + 1;
      });

      // 5. Order Status Distribution (all time)
      const { data: orders } = await supabase
        .from(TABLES.ORDERS)
        .select('status');

      const orderCounts: Record<string, number> = {};
      orders?.forEach(row => {
        orderCounts[row.status] = (orderCounts[row.status] || 0) + 1;
      });

      // 6. Summary KPIs for the selected period
      const newListingsCount = listingsRaw?.length ?? 0;
      const newOrdersCount = ordersRaw?.length ?? 0;
      const avgDau = Object.values(dailyDau).length > 0
        ? Math.round(Object.values(dailyDau).reduce((a, b) => a + b, 0) / Object.values(dailyDau).length)
        : 0;

      return {
        dauTrend: Object.entries(dailyDau).map(([date, count]) => ({ date, count })),
        listingsTrend: Object.entries(dailyListings).map(([date, count]) => ({ date, count })),
        ordersTrend: Object.entries(dailyOrders).map(([date, count]) => ({ date, count })),
        categoryDist: Object.entries(categoryCounts).map(([name, count]) => ({ name, count })),
        orderDist: Object.entries(orderCounts).map(([name, count]) => ({ name, count })),
        kpis: {
          newListingsCount,
          newOrdersCount,
          avgDau,
          peakDau: Object.values(dailyDau).length > 0 ? Math.max(...Object.values(dailyDau)) : 0,
        },
      };
    },
    staleTime: 10 * 60 * 1000,
  });
}

export type { TimeRange };
export { RANGE_DAYS };
