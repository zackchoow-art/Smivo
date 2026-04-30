import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { UserProfile } from '@/types/user-profile';

const QUERY_KEY = ['users'] as const;

export interface UserFilters {
  search?: string;
}

export function useUsers(page: number, filters: UserFilters = {}) {
  return useQuery({
    queryKey: [...QUERY_KEY, page, filters],
    queryFn: async () => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;

      let query = supabase
        .from(TABLES.USER_PROFILES)
        .select('*', { count: 'exact' })
        .range(from, to)
        .order('created_at', { ascending: false });

      if (filters.search) {
        // Search in display_name or email
        query = query.or(`display_name.ilike.%${filters.search}%,email.ilike.%${filters.search}%`);
      }

      const { data, error, count } = await query;

      if (error) throw error;

      return {
        data: (data ?? []) as UserProfile[],
        totalCount: count ?? 0,
      };
    },
    staleTime: 60 * 1000,
  });
}

export function useUserDetail(userId?: string) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'detail', userId],
    queryFn: async () => {
      if (!userId) return null;

      // 1. Fetch user profile
      const { data: user, error: userError } = await supabase
        .from(TABLES.USER_PROFILES)
        .select('*')
        .eq('id', userId)
        .single();

      if (userError) throw userError;

      // 2. Fetch recent 10 listings
      const { data: listings, error: listingsError } = await supabase
        .from(TABLES.LISTINGS)
        .select('id, title, price, moderation_status, created_at')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(10);

      if (listingsError) throw listingsError;

      // 3. Fetch recent 10 orders (as buyer or seller)
      const { data: orders, error: ordersError } = await supabase
        .from(TABLES.ORDERS)
        .select('id, status, total_price, created_at, listing:listings(title)')
        .or(`buyer_id.eq.${userId},seller_id.eq.${userId}`)
        .order('created_at', { ascending: false })
        .limit(10);

      if (ordersError) throw ordersError;

      return {
        user: user as UserProfile,
        listings: listings || [],
        orders: orders || [],
      };
    },
    enabled: !!userId,
  });
}
