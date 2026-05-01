import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { 
  BanWithUser, 
  BanType, 
  BanStatus,
  RestrictionScope 
} from '@/types/ban';

const QUERY_KEY = ['user-bans'] as const;

export interface BanFilters {
  type?: BanType;
  status?: BanStatus;
  scope?: RestrictionScope;
}

/**
 * Hook for listing user bans with optional scope filtering.
 */
export function useBans(page: number, filters: BanFilters = {}) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'list', page, filters],
    queryFn: async () => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;

      let query = supabase
        .from(TABLES.USER_BANS)
        .select(`
          *,
          user:user_id(display_name, email),
          admin:banned_by(display_name)
        `, { count: 'exact' })
        .range(from, to)
        .order('created_at', { ascending: false });

      if (filters.type) {
        query = query.eq('ban_type', filters.type);
      }

      if (filters.scope) {
        query = query.eq('scope', filters.scope);
      }
      
      // Status filtering logic (active, expired, lifted)
      const now = new Date().toISOString();
      if (filters.status === 'active') {
        query = query.is('lifted_at', null).or(`expires_at.is.null,expires_at.gt.${now}`);
      } else if (filters.status === 'expired') {
        query = query.is('lifted_at', null).not('expires_at', 'is', null).lt('expires_at', now);
      } else if (filters.status === 'lifted') {
        query = query.not('lifted_at', 'is', null);
      }

      const { data, error, count } = await query;
      if (error) throw error;

      const mappedData: BanWithUser[] = (data || []).map((item: any) => {
        let status: BanStatus = 'active';
        if (item.lifted_at) status = 'lifted';
        else if (item.expires_at && new Date(item.expires_at) < new Date()) status = 'expired';

        return {
          ...item,
          user_display_name: item.user?.display_name || null,
          user_email: item.user?.email || '',
          banned_by_name: item.admin?.display_name || null,
          status
        };
      });

      return {
        data: mappedData,
        totalCount: count || 0,
      };
    },
  });
}

/**
 * Fetch active restrictions for a specific user.
 * Returns all active (not lifted, not expired) restriction scopes.
 */
export function useUserActiveRestrictions(userId?: string) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'active', userId],
    queryFn: async () => {
      if (!userId) return [];

      const now = new Date().toISOString();
      const { data, error } = await supabase
        .from(TABLES.USER_BANS)
        .select('id, scope, ban_type, expires_at, reason_detail, banned_at')
        .eq('user_id', userId)
        .is('lifted_at', null)
        .or(`expires_at.is.null,expires_at.gt.${now}`)
        .order('scope');

      if (error) throw error;
      return data || [];
    },
    enabled: !!userId,
  });
}

/**
 * Mutation for creating a new restriction (ban with scope).
 */
export function useCreateBan() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      userId,
      collegeId,
      banType,
      scope,
      reasonCode,
      reasonDetail,
      durationDays,
      adminId
    }: {
      userId: string;
      collegeId: string;
      banType: BanType;
      scope: RestrictionScope;
      reasonCode: string;
      reasonDetail: string;
      durationDays: number | null;
      adminId: string;
    }) => {
      const bannedAt = new Date().toISOString();
      let expiresAt: string | null = null;
      
      if (banType === 'temporary' && durationDays) {
        const date = new Date();
        date.setDate(date.getDate() + durationDays);
        expiresAt = date.toISOString();
      }

      const { data, error } = await supabase
        .from(TABLES.USER_BANS)
        .insert({
          user_id: userId,
          college_id: collegeId,
          ban_type: banType,
          scope,
          reason_code: reasonCode,
          reason_detail: reasonDetail,
          duration_days: durationDays,
          expires_at: expiresAt,
          banned_by: adminId,
          banned_at: bannedAt
        })
        .select()
        .single();

      if (error) throw error;

      // Log to audit log
      await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
        admin_id: adminId,
        action: 'create_restriction',
        target_type: 'user',
        target_id: userId,
        payload: { banType, scope, reasonCode, expiresAt }
      });

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}

/**
 * Mutation for lifting a ban / restriction.
 */
export function useLiftBan() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      banId,
      liftReason,
      adminId
    }: {
      banId: string;
      liftReason: string;
      adminId: string;
    }) => {
      const { data, error } = await supabase
        .from(TABLES.USER_BANS)
        .update({
          lifted_at: new Date().toISOString(),
          lifted_by: adminId,
          lift_reason: liftReason
        })
        .eq('id', banId)
        .select()
        .single();

      if (error) throw error;

      // Log to audit log
      await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
        admin_id: adminId,
        action: 'lift_restriction',
        target_type: 'user_ban',
        target_id: banId,
        payload: { liftReason }
      });

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
