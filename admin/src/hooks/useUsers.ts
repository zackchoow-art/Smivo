import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { UserProfile } from '@/types/user-profile';

const QUERY_KEY = ['users'] as const;

export interface UserFilters {
  search?: string;
  schoolId?: string;
  status?: string; // 'all' | 'restricted'
  punished?: string; // 'all' | 'yes'
}

export function useUsers(page: number, filters: UserFilters = {}) {
  return useQuery({
    queryKey: [...QUERY_KEY, page, filters],
    queryFn: async () => {
      let userIdsToInclude: string[] | null = null;

      // Filter by restriction/punishment status first if needed
      if (filters.status === 'restricted' || filters.punished === 'yes') {
        let banQuery = supabase.from(TABLES.USER_BANS).select('user_id');
        
        if (filters.status === 'restricted') {
          const now = new Date().toISOString();
          banQuery = banQuery.is('lifted_at', null).or(`expires_at.is.null,expires_at.gt.${now}`);
        }
        
        const { data: bans } = await banQuery;
        if (bans) {
          userIdsToInclude = Array.from(new Set(bans.map((b: any) => b.user_id)));
        } else {
          userIdsToInclude = [];
        }
      }

      if (userIdsToInclude !== null && userIdsToInclude.length === 0) {
        return { data: [], totalCount: 0 };
      }

      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;

      let query = supabase
        .from(TABLES.USER_PROFILES)
        // NOTE: Removed admin_roles join from list query — it caused PostgREST FK
        // resolution errors. Admin role info is fetched in useUserDetail for detail page.
        .select(`*, school_obj:school_id(name)`, { count: 'exact' })
        .range(from, to)
        .order('created_at', { ascending: false });

      if (userIdsToInclude !== null) {
        query = query.in('id', userIdsToInclude);
      }

      if (filters.schoolId && filters.schoolId !== 'all') {
        query = query.eq('school_id', filters.schoolId);
      }

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
          school: u.school_obj?.name || u.school,
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

      // 1. Fetch user profile (without admin_roles join to avoid FK disambiguation)
      const { data: user, error: userError } = await supabase
        .from(TABLES.USER_PROFILES)
        .select(`*, school_obj:school_id(name)`)
        .eq('id', userId)
        .single();

      if (userError) throw userError;

      // 2. Fetch admin role records separately (if any)
      const { data: adminRoles } = await supabase
        .from(TABLES.ADMIN_ROLES)
        .select('role, scope_type, scope_id')
        .eq('user_id', userId)
        .eq('is_active', true);

      // Fetch school names for school-scoped roles
      const schoolScopeIds = (adminRoles ?? [])
        .filter((r) => r.scope_type === 'school' && r.scope_id)
        .map((r) => r.scope_id!);

      let managedSchools: string[] = [];
      if (schoolScopeIds.length > 0) {
        const { data: schools } = await supabase
          .from(TABLES.COLLEGES)
          .select('name')
          .in('id', schoolScopeIds);
        managedSchools = (schools ?? []).map((s) => s.name);
      }

      // 3. Fetch recent 10 listings
      const { data: listings, error: listingsError } = await supabase
        .from(TABLES.LISTINGS)
        .select('id, title, price, moderation_status, created_at')
        // NOTE: listings table uses 'seller_id' as the owner FK, not 'user_id'
        .eq('seller_id', userId)
        .order('created_at', { ascending: false })
        .limit(10);

      if (listingsError) throw listingsError;

      // 4. Fetch recent 10 orders (as buyer or seller)
      const { data: orders, error: ordersError } = await supabase
        .from(TABLES.ORDERS)
        .select('id, status, total_price, created_at, listing:listings(title)')
        .or(`buyer_id.eq.${userId},seller_id.eq.${userId}`)
        .order('created_at', { ascending: false })
        .limit(10);

      if (ordersError) throw ordersError;

      // 5. Fetch active bans (not lifted, not expired)
      const { data: bans, error: bansError } = await supabase
        .from(TABLES.USER_BANS)
        .select('*')
        .eq('user_id', userId)
        .is('lifted_at', null)
        .or(`expires_at.is.null,expires_at.gt.${new Date().toISOString()}`);

      if (bansError) throw bansError;

      // 6. Fetch latest heartbeat (device telemetry)
      const { data: heartbeat } = await supabase
        .from('user_heartbeats')
        .select('last_seen_at, app_version, build_number, device_model, os_version, platform, ip_address, locale')
        .eq('user_id', userId)
        .maybeSingle();

      return {
        user: { 
          ...user, 
          school: (user as any).school_obj?.name || user.school,
          managed_schools: managedSchools,
        } as UserProfile,
        listings: listings || [],
        orders: orders || [],
        bans: bans || [],
        heartbeat: heartbeat || null,
      };
    },
    enabled: !!userId,
  });
}

export function useUserSummary(userId: string | null) {
  return useQuery({
    queryKey: ['user-summary', userId],
    queryFn: async () => {
      if (!userId) return null;
      
      const now = new Date().toISOString();

      const [
        profileRes,
        reportsRes,
        bansRes,
        activeBansRes,
        listingsRes,
        purchasesRes,
        recentActivityRes
      ] = await Promise.all([
        supabase.from('user_profiles').select('*').eq('id', userId).single(),
        supabase.from('content_reports').select('id', { count: 'exact', head: true }).eq('reported_user_id', userId).in('status', ['resolved']),
        supabase.from('user_bans').select('id', { count: 'exact', head: true }).eq('user_id', userId),
        supabase.from('user_bans').select('scope, expires_at').eq('user_id', userId).is('lifted_at', null).or(`expires_at.is.null,expires_at.gt.${now}`),
        supabase.from('listings').select('id', { count: 'exact', head: true }).eq('seller_id', userId),
        supabase.from('orders').select('id', { count: 'exact', head: true }).eq('buyer_id', userId),
        supabase.from('orders').select('*, listing:listings(title, price)').or(`buyer_id.eq.${userId},seller_id.eq.${userId}`).order('created_at', { ascending: false }).limit(10)
      ]);

      return {
        profile: profileRes.data,
        reportsCount: reportsRes.count || 0,
        punishmentsCount: bansRes.count || 0,
        activeBans: activeBansRes.data || [],
        listingsCount: listingsRes.count || 0,
        purchasesCount: purchasesRes.count || 0,
        recentActivity: recentActivityRes.data || []
      };
    },
    enabled: !!userId,
  });
}

/**
 * Gracefully soft-deletes a user via admin_graceful_delete_user RPC
 * (migration 00144). Same logic as the app-side delete_own_account():
 * delists listings, cancels orders, sends farewell messages, anonymizes
 * profile, bans auth, forces logout, and writes an audit log.
 *
 * Completed orders and chat history are preserved for counterparties.
 */
export function useAdminDeleteUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (userId: string) => {
      const { data, error } = await supabase.rpc('admin_graceful_delete_user', {
        p_user_id: userId,
      });
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}

export interface CreateAdminUserParams {
  email: string;
  displayName: string;
  password?: string;
  role: string;
  schoolId: string;
}

export function useCreateAdminUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (params: CreateAdminUserParams) => {
      const { data, error } = await supabase.functions.invoke('admin-create-user', {
        body: {
          email: params.email,
          displayName: params.displayName,
          password: params.password || 'password123',
          role: params.role,
          schoolId: params.schoolId,
        }
      });
      if (error) throw error;
      if (data.error) throw new Error(data.error);
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}

export function useUpdateUserSchool() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ userId, schoolId }: { userId: string; schoolId: string }) => {
      // Step 1: Look up the school name so we can sync both fields
      const { data: schoolData, error: schoolErr } = await supabase
        .from(TABLES.COLLEGES)
        .select('name')
        .eq('id', schoolId)
        .single();

      if (schoolErr) throw schoolErr;

      // NOTE: user_profiles has two school fields:
      //   school_id — FK to colleges table (used for data isolation and filtering)
      //   school     — legacy text field used by the Flutter app for display
      // Both must be kept in sync whenever a user's school is changed.
      const { data, error } = await supabase
        .from(TABLES.USER_PROFILES)
        .update({
          school_id: schoolId,
          school: schoolData.name,
        })
        .eq('id', userId)
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: (_, { userId }) => {
      queryClient.invalidateQueries({ queryKey: [...QUERY_KEY, 'detail', userId] });
      queryClient.invalidateQueries({ queryKey: ['user-summary', userId] });
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}
