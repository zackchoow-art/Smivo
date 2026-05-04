import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';

const LOGS_QUERY_KEY = ['backend-moderation-logs'] as const;

export interface BackendModerationLog {
  id: string;
  target_type: 'listing' | 'message' | 'profile';
  target_id: string;
  user_id: string;
  engine: 'openai' | 'google_vision' | 'sensitive_words';
  review_mode: 'sensitive_words' | 'ai' | 'both';
  result: 'pass' | 'fail';
  action_taken: 'approve' | 'reject' | 'flag' | 'blur';
  text_details: Record<string, any>;
  image_details: Array<{
    index: number;
    url: string;
    flagged: boolean;
    reasons: string[];
    scores?: Record<string, number>;
  }>;
  content_snapshot: string | null;
  created_at: string;
  // Joined fields
  user_profile?: {
    display_name: string | null;
    email: string | null;
    avatar_url: string | null;
  };
}

export interface LogFilters {
  targetType?: 'listing' | 'message' | 'profile' | 'all';
  result?: 'pass' | 'fail' | 'all';
  engine?: 'openai' | 'google_vision' | 'sensitive_words' | 'all';
}

/**
 * Fetch paginated backend moderation logs for the AI Reviewed tab.
 * Joins user_profiles for display info.
 */
export function useBackendModerationLogs(page: number, filters?: LogFilters) {
  return useQuery({
    queryKey: [...LOGS_QUERY_KEY, 'list', page, filters],
    queryFn: async () => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;

      let query = supabase
        .from(TABLES.BACKEND_MODERATION_LOGS)
        .select(`
          *,
          user_profile:user_profiles(display_name, email, avatar_url)
        `, { count: 'exact' });

      if (filters?.targetType && filters.targetType !== 'all') {
        query = query.eq('target_type', filters.targetType);
      }
      if (filters?.result && filters.result !== 'all') {
        query = query.eq('result', filters.result);
      }
      if (filters?.engine && filters.engine !== 'all') {
        query = query.eq('engine', filters.engine);
      }

      query = query.order('created_at', { ascending: false });
      query = query.range(from, to);

      const { data, error, count } = await query;
      if (error) throw error;

      return {
        data: (data ?? []) as BackendModerationLog[],
        count: count ?? 0,
      };
    },
  });
}

/**
 * Fetch moderation logs for a specific target (e.g. one listing).
 * Used in the All Listings expanded detail panel.
 */
export function useTargetModerationLogs(targetId: string | null) {
  return useQuery({
    queryKey: [...LOGS_QUERY_KEY, 'target', targetId],
    queryFn: async () => {
      if (!targetId) return [];

      const { data, error } = await supabase
        .from(TABLES.BACKEND_MODERATION_LOGS)
        .select('*')
        .eq('target_id', targetId)
        .order('created_at', { ascending: false })
        .limit(20);

      if (error) throw error;
      return (data ?? []) as BackendModerationLog[];
    },
    enabled: !!targetId,
  });
}
