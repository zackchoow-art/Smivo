import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type {
  UserFeedback,
  FeedbackStatus,
  FeedbackType,
  FeedbackWithUser,
} from '@/types/feedback';

const QUERY_KEY = ['feedbacks'] as const;

export interface FeedbackFilters {
  status?: FeedbackStatus;
  // NOTE: DB column is 'type', not 'category' or 'feedback_type'
  type?: FeedbackType;
}

export function useFeedbacks(page: number, filters: FeedbackFilters = {}) {
  return useQuery({
    queryKey: [...QUERY_KEY, page, filters],
    queryFn: async () => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;

      let query = supabase
        .from(TABLES.USER_FEEDBACKS)
        .select('*', { count: 'exact' })
        .range(from, to)
        .order('created_at', { ascending: false });

      if (filters.status) {
        query = query.eq('status', filters.status);
      }
      // NOTE: DB column is 'type', not 'category' / 'feedback_type'
      if (filters.type) {
        query = query.eq('type', filters.type);
      }

      const { data, error, count } = await query;
      if (error) throw error;

      return {
        data: (data ?? []) as UserFeedback[],
        totalCount: count ?? 0,
      };
    },
    staleTime: 60 * 1000,
  });
}

/**
 * Hook to get all pending (submitted) feedbacks for quick navigation.
 */
export function usePendingFeedbacks() {
  return useQuery({
    queryKey: [...QUERY_KEY, 'pending'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from(TABLES.USER_FEEDBACKS)
        .select('id')
        .eq('status', 'submitted')
        .order('created_at', { ascending: false });

      if (error) throw error;
      return (data || []) as { id: string }[];
    },
  });
}

/**
 * Hook for a single feedback item with joined user info.
 */
export function useFeedback(id: string | undefined) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'detail', id],
    queryFn: async () => {
      if (!id) return null;
      const { data, error } = await supabase
        .from(TABLES.USER_FEEDBACKS)
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;

      let user = null;
      if (data.user_id) {
        const { data: userData } = await supabase
          .from(TABLES.USER_PROFILES)
          .select('display_name, email, avatar_url')
          .eq('id', data.user_id)
          .maybeSingle();
        user = userData;
      }

      return {
        ...data,
        user_display_name: user?.display_name || null,
        user_email: user?.email || '',
        user_avatar_url: user?.avatar_url || null,
      } as FeedbackWithUser;
    },
    enabled: !!id,
  });
}

/**
 * Mutation for responding to/resolving feedback.
 * NOTE: DB columns are admin_response (text) and points_awarded (int).
 * There is NO admin_judgment, admin_notes, or contribution_points column.
 */
export function useResolveFeedback() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      feedbackId,
      status,
      adminResponse,
      points,
      adminId,
      userId,
    }: {
      feedbackId: string;
      status: FeedbackStatus;
      adminResponse: string;
      points: number;
      adminId: string;
      userId: string;
    }) => {
      // 1. Update feedback with correct DB column names
      const { error: updateError } = await supabase
        .from(TABLES.USER_FEEDBACKS)
        .update({
          status: status,                 // DB constraint: submitted|read|accepted|high_contribution
          admin_response: adminResponse,   // DB column: admin_response
          points_awarded: points,          // DB column: points_awarded
        })
        .eq('id', feedbackId);

      if (updateError) throw updateError;

      // 2. Award contribution points if > 0
      if (points > 0) {
        const { error: ledgerError } = await supabase
          .from(TABLES.CONTRIBUTION_LEDGER)
          .insert({
            user_id: userId,
            delta: points,
            reason: 'Feedback reward',
            source_type: 'feedback',
            source_id: feedbackId,
          });

        if (ledgerError) {
          // NOTE: Non-critical — log but don't block
          console.warn('[useFeedbacks] contribution ledger insert failed:', ledgerError.message);
        }
      }

      // 3. Log to audit log
      await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
        admin_id: adminId,
        action: 'resolve_feedback',
        target_type: 'user_feedback',
        target_id: feedbackId,
        payload: { adminResponse, points },
      });

      // 4. Notify the feedback submitter (in-app + email)
      // NOTE: Only notify if there is a real response and the feedback was
      // more than just 'read' (i.e. has meaningful admin engagement).
      if (userId && adminResponse && adminResponse.trim().length > 0) {
        const statusLabel: Record<string, string> = {
          read: 'read',
          accepted: 'accepted',
          high_contribution: 'highly valued',
          dismissed: 'reviewed',
        };
        const label = statusLabel[status] ?? 'reviewed';

        const pointsText = points > 0 ? ` You earned +${points} contribution points!` : '';
        const notifBody = `Your feedback has been ${label}. Admin response: ${adminResponse.substring(0, 120)}${adminResponse.length > 120 ? '...' : ''}${pointsText}`;

        const { error: notifErr } = await supabase.rpc('send_moderation_notification', {
          p_user_id: userId,
          p_type: 'feedback_responded',
          p_title: status === 'high_contribution'
            ? '🌟 Your feedback was highly valued!'
            : status === 'accepted'
            ? '✅ Your feedback was accepted'
            : '💬 Response to your feedback',
          p_body: notifBody,
          p_action_type: 'route',
          p_action_url: '/settings/feedbacks',
        });

        if (notifErr) {
          // NOTE: Non-critical — feedback is already resolved, notification failure
          // should not roll back the resolution.
          console.warn('[useFeedbacks] Notification send failed:', notifErr.message);
        }
      }
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({
        queryKey: [...QUERY_KEY, 'detail', variables.feedbackId],
      });
    },
  });
}

