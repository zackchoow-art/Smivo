import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { 
  UserFeedback, 
  FeedbackStatus, 
  FeedbackType, 
  FeedbackWithUser, 
  FeedbackJudgment 
} from '@/types/feedback';

const QUERY_KEY = ['feedbacks'] as const;

export interface FeedbackFilters {
  status?: FeedbackStatus;
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
      if (filters.type) {
        query = query.eq('feedback_type', filters.type);
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
 * Hook for a single feedback item.
 */
export function useFeedback(id: string | undefined) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'detail', id],
    queryFn: async () => {
      if (!id) return null;
      const { data, error } = await supabase
        .from(TABLES.USER_FEEDBACKS)
        .select(`
          *,
          user:user_id(display_name, email, avatar_url)
        `)
        .eq('id', id)
        .single();

      if (error) throw error;

      return {
        ...data,
        user_display_name: data.user?.display_name || null,
        user_email: data.user?.email || '',
        user_avatar_url: data.user?.avatar_url || null,
      } as FeedbackWithUser;
    },
    enabled: !!id,
  });
}

/**
 * Mutation for resolving feedback.
 */
export function useResolveFeedback() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      feedbackId,
      judgment,
      adminReply,
      points,
      adminId,
      userId,
      collegeId
    }: {
      feedbackId: string;
      judgment: FeedbackJudgment;
      adminReply: string;
      points: number;
      adminId: string;
      userId: string;
      collegeId: string;
    }) => {
      // 1. Update feedback
      const { error: updateError } = await supabase
        .from(TABLES.USER_FEEDBACKS)
        .update({
          status: 'resolved',
          judgment,
          admin_reply: adminReply,
          contribution_awarded: points,
          resolved_by: adminId,
          resolved_at: new Date().toISOString()
        })
        .eq('id', feedbackId);

      if (updateError) throw updateError;

      // 2. Award contribution points if > 0
      if (points > 0) {
        const { error: ledgerError } = await supabase
          .from(TABLES.CONTRIBUTION_LEDGER)
          .insert({
            user_id: userId,
            college_id: collegeId,
            delta: points,
            reason: `Feedback reward: ${judgment}`,
            source_type: 'feedback',
            source_id: feedbackId
          });
        
        if (ledgerError) throw ledgerError;
      }

      // 3. Log to audit log
      await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
        admin_id: adminId,
        action_type: 'resolve_feedback',
        target_type: 'user_feedback',
        target_id: feedbackId,
        payload: { judgment, points }
      });
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
      queryClient.invalidateQueries({ queryKey: [...QUERY_KEY, 'detail', variables.feedbackId] });
    },
  });
}
