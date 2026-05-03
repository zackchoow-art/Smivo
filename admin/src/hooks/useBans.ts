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
 * Uses the apply_restriction RPC which implements the accumulation (stacking) strategy:
 *   - If an active restriction of the same scope exists, the duration is stacked on top.
 *   - Otherwise a fresh restriction record is inserted.
 * After applying, dispatches an in-app + push notification to the user with
 * smart messaging depending on whether this is a new restriction or an extension.
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
      // Call the centralised stacking RPC instead of a raw INSERT.
      // The RPC handles the accumulation logic and updates audit logs.
      const { data: rpcResult, error: rpcError } = await supabase.rpc('apply_restriction', {
        p_user_id:       userId,
        p_college_id:    collegeId,
        p_admin_id:      adminId,
        p_scope:         scope,
        p_ban_type:      banType,
        p_duration_days: durationDays,
        p_reason_code:   reasonCode,
        p_reason_detail: reasonDetail ?? ''
      });

      if (rpcError) throw rpcError;

      const result = rpcResult as {
        action: 'created' | 'extended' | 'superseded';
        ban_id: string;
        new_expires_at: string | null;
        prev_expires_at: string | null;
      };

      // ── Build human-readable notification copy ────────────────────────────
      const scopeLabel: Record<RestrictionScope, string> = {
        chat_mute:      'send messages',
        listing_ban:    'post listings',
        feedback_ban:   'submit feedback',
        account_freeze: 'use your account'
      };
      const featureLabel = scopeLabel[scope] ?? scope;

      const expiryStr = result.new_expires_at
        ? new Date(result.new_expires_at).toLocaleDateString('en-US', {
            year: 'numeric', month: 'long', day: 'numeric'
          })
        : null;

      const durationStr = banType === 'permanent'
        ? 'permanently'
        : durationDays
          ? `for ${durationDays} day${durationDays !== 1 ? 's' : ''}`
          : null;

      let notifTitle: string;
      let notifBody: string;

      if (result.action === 'superseded') {
        // A permanent ban is already active — inform of violation without changing times.
        notifTitle = 'Violation Recorded';
        notifBody  =
          `A new violation (${reasonCode}) has been recorded on your account. ` +
          `Your existing account restriction remains in effect. ` +
          `Please review our Community Guidelines at smivo.io/safety.`;

      } else if (result.action === 'extended') {
        // Existing restriction was extended — clearly communicate the new end date.
        const prevStr = result.prev_expires_at
          ? new Date(result.prev_expires_at).toLocaleDateString('en-US', {
              year: 'numeric', month: 'long', day: 'numeric'
            })
          : null;

        notifTitle = 'Restriction Extended';
        notifBody  =
          `Due to a new violation (${reasonCode}), your ability to ${featureLabel} ` +
          (durationStr ? `has been extended by ${durationStr}. ` : 'has been extended. ') +
          (expiryStr
            ? `Your restriction is now lifted on ${expiryStr}` +
              (prevStr ? ` (previously ${prevStr})` : '') + '.' 
            : 'This restriction is now permanent.') +
          ` If you believe this is an error, contact us at smivo.io/support.`;

      } else {
        // Fresh restriction — standard notice.
        notifTitle = 'Account Restriction Applied';
        notifBody  =
          `Your ability to ${featureLabel} has been restricted ` +
          (durationStr ? `${durationStr} ` : '') +
          `due to a violation of our Community Guidelines (${reasonCode}). ` +
          (expiryStr
            ? `This restriction will be lifted on ${expiryStr}. `
            : 'This restriction is permanent. ') +
          `If you believe this is an error, please contact us at smivo.io/support.`;
      }

      // Dispatch in-app notification (triggers push via Supabase webhook).
      await supabase.rpc('send_moderation_notification', {
        p_user_id:    userId,
        p_type:       'restriction_applied',
        p_title:      notifTitle,
        p_body:       notifBody,
        p_action_type: 'route',
        p_action_url: '/notifications'
      });

      return result;
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
