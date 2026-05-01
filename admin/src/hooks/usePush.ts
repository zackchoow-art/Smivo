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

/**
 * Sends a push job by calling the broadcast-announcement Edge Function.
 * Updates the push_jobs record status to 'sent' or 'failed'.
 */
export function useSendPushJob() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (jobId: string) => {
      // 1. Fetch the job to get title/body/audience
      const { data: job, error: fetchError } = await supabase
        .from(TABLES.PUSH_JOBS)
        .select('*')
        .eq('id', jobId)
        .single();

      if (fetchError || !job) throw new Error('Push job not found');

      // 2. Mark as sending
      await supabase
        .from(TABLES.PUSH_JOBS)
        .update({ status: 'sending' })
        .eq('id', jobId);

      // 3. Invoke the broadcast-announcement Edge Function
      const { data, error: fnError } = await supabase.functions.invoke(
        'broadcast-announcement',
        {
          body: {
            title: job.title,
            body: job.body,
            deep_link: job.deep_link,
            audience_type: job.audience_type,
            push_job_id: jobId,
          },
        }
      );

      if (fnError) {
        // Mark as failed with error details
        await supabase
          .from(TABLES.PUSH_JOBS)
          .update({
            status: 'failed',
            failure_breakdown: { error: fnError.message },
          })
          .eq('id', jobId);
        throw fnError;
      }

      // 4. Mark as sent with delivery stats
      const now = new Date().toISOString();
      await supabase
        .from(TABLES.PUSH_JOBS)
        .update({
          status: 'sent',
          sent_at: now,
          recipients_count: data?.recipients_count ?? null,
          delivered_count: data?.delivered_count ?? 0,
          onesignal_id: data?.onesignal_id ?? null,
        })
        .eq('id', jobId);

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PUSH_QUERY_KEY });
    },
  });
}
