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
        .select(`*, school:schools(name)`, { count: 'exact' })
        .range(from, to)
        .order('created_at', { ascending: false });

      if (filters.search) {
        // Search in display_name or email
        query = query.or(`display_name.ilike.%${filters.search}%,email.ilike.%${filters.search}%`);
      }

      const { data, error, count } = await query;

      if (error) throw error;

      // Fetch active restrictions for all users in this page
      const userIds = (data ?? []).map((u: any) => u.id);
      let restrictionMap: Record<string, string[]> = {};

      if (userIds.length > 0) {
        const now = new Date().toISOString();
        const { data: bans } = await supabase
          .from(TABLES.USER_BANS)
          .select('user_id, scope')
          .in('user_id', userIds)
          .is('lifted_at', null)
          .or(`expires_at.is.null,expires_at.gt.${now}`);

        if (bans) {
          for (const ban of bans) {
            if (!restrictionMap[ban.user_id]) {
              restrictionMap[ban.user_id] = [];
            }
            if (!restrictionMap[ban.user_id].includes(ban.scope)) {
              restrictionMap[ban.user_id].push(ban.scope);
            }
          }
        }
      }

      return {
        data: (data ?? []).map((u: any) => ({
          ...u,
          school: u.school?.name,
          active_restrictions: restrictionMap[u.id] || [],
        })) as UserProfile[],
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
        .select(`*, school:schools(name)`)
        .eq('id', userId)
        .single();

      if (userError) throw userError;

      // 2. Fetch recent 10 listings
      const { data: listings, error: listingsError } = await supabase
        .from(TABLES.LISTINGS)
        .select('id, title, price, moderation_status, created_at')
        // NOTE: listings table uses 'seller_id' as the owner FK, not 'user_id'
        .eq('seller_id', userId)
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

      // 4. Fetch active bans (not lifted, not expired)
      const { data: bans, error: bansError } = await supabase
        .from(TABLES.USER_BANS)
        .select('*')
        .eq('user_id', userId)
        .is('lifted_at', null)
        .or(`expires_at.is.null,expires_at.gt.${new Date().toISOString()}`);

      if (bansError) throw bansError;

      return {
        user: { ...user, school: (user as any).school?.name } as UserProfile,
        listings: listings || [],
        orders: orders || [],
        bans: bans || [],
      };
    },
    enabled: !!userId,
  });
}
