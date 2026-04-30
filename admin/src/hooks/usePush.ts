import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { PushJob, PushStatus } from '@/types';

const PUSH_QUERY_KEY = ['push_jobs'] as const;

export interface PushJobsFilters {
  status?: PushStatus | 'all';
}

/**
 * Fetch paginated push jobs.
 */
export function usePushJobs(page: number, filters?: PushJobsFilters) {
  return useQuery({
    queryKey: [...PUSH_QUERY_KEY, page, filters],
    queryFn: async () => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;
      
      let query = supabase
        .from(TABLES.PUSH_JOBS)
        .select('*', { count: 'exact' });

      if (filters?.status && filters.status !== 'all') {
        query = query.eq('status', filters.status);
      }

      query = query.order('created_at', { ascending: false });
      query = query.range(from, to);

      const { data, error, count } = await query;
      
      if (error) throw error;
      
      return { 
        data: (data ?? []) as PushJob[], 
        count: count ?? 0 
      };
    },
  });
}

/**
 * Fetch recent push jobs (e.g. for dashboard/overview).
 */
export function useRecentPushJobs(limit: number = 5) {
  return useQuery({
    queryKey: [...PUSH_QUERY_KEY, 'recent', limit],
    queryFn: async () => {
      const { data, error } = await supabase
        .from(TABLES.PUSH_JOBS)
        .select('*')
        .order('created_at', { ascending: false })
        .limit(limit);

      if (error) throw error;
      return data as PushJob[];
    },
  });
}

export type CreatePushJobPayload = Omit<
  PushJob, 
  'id' | 'created_at' | 'status' | 'delivered_count' | 'opened_count' | 'clicked_count' | 'failure_breakdown' | 'onesignal_id' | 'sent_at' | 'recipients_count'
> & {
  status?: PushStatus; // Allowing to set 'draft' or 'scheduled'
};

/**
 * Mutation to create a new push job.
 */
export function useCreatePushJob() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (payload: CreatePushJobPayload) => {
      const { error, data } = await supabase
        .from(TABLES.PUSH_JOBS)
        .insert({
          ...payload,
          status: payload.status || 'draft',
          delivered_count: 0,
          opened_count: 0,
          clicked_count: 0,
        })
        .select()
        .single();

      if (error) throw error;
      return data as PushJob;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PUSH_QUERY_KEY });
    },
  });
}
