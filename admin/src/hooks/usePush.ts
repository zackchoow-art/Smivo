import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { PushJob, PushStatus } from '@/types';

const PUSH_QUERY_KEY = ['push_jobs'] as const;

// ─── Rental Reminder Types ───────────────────────────────────────────────────

export interface PendingRentalReminder {
  order_id: string;
  listing_title: string;
  buyer_id: string;
  buyer_name: string;
  buyer_email: string;
  rental_end_date: string;
  reminder_days_before: number;
  reminder_email: boolean;
  days_until_expiry: number;
  // The exact calendar date when check_rental_reminders() will fire this push.
  // Computed as: rental_end_date - reminder_days_before days.
  scheduled_send_date: Date;
  // Days from today until the push fires (negative = overdue, 0 = today)
  days_until_send: number;
  notification_preview: string;
}

const REMINDERS_QUERY_KEY = ['pending_rental_reminders'] as const;

/**
 * Fetches all active rental orders whose reminder window has arrived
 * but the reminder has not yet been sent. Used to populate the admin queue.
 */
export function usePendingRentalReminders() {
  return useQuery({
    queryKey: REMINDERS_QUERY_KEY,
    queryFn: async () => {
      // Query orders joined with user_profiles and listings to build the queue.
      // NOTE: Use column name 'buyer_id' as the FK hint (not the constraint name),
      // consistent with all other hooks (useListingModeration, useChatReports, etc.)
      const { data, error } = await supabase
        .from(TABLES.ORDERS)
        .select(`
          id,
          rental_end_date,
          reminder_days_before,
          reminder_email,
          listings!inner ( title ),
          buyer:user_profiles!buyer_id ( id, display_name, email )
        `)
        .eq('order_type', 'rental')
        .eq('rental_status', 'active')
        .eq('reminder_sent', false)
        .not('rental_end_date', 'is', null)
        .order('rental_end_date', { ascending: true });

      if (error) throw error;

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      // NOTE: Show ALL active rentals with pending reminders (not just due ones),
      // so admins can see the full pipeline and identify upcoming reminders in advance.
      // The urgency label and color distinguish "today / tomorrow / N days" visually.
      const reminders: PendingRentalReminder[] = (data ?? [])
        .map((row: any) => {
          const endDate = new Date(row.rental_end_date);
          endDate.setHours(0, 0, 0, 0);
          const msPerDay = 1000 * 60 * 60 * 24;
          const daysUntil = Math.round((endDate.getTime() - today.getTime()) / msPerDay);
          const listingTitle = row.listings?.title ?? 'Rental Item';
          const buyerName = row.buyer?.display_name ?? 'Buyer';

          let preview = '';
          if (daysUntil <= 0) preview = `"${listingTitle}" rental expires today!`;
          else if (daysUntil === 1) preview = `"${listingTitle}" rental expires tomorrow`;
          else preview = `"${listingTitle}" rental expires in ${daysUntil} days`;

          // Calculate the exact date the push notification will be dispatched.
          // The cron job (check_rental_reminders) fires when:
          //   rental_end_date - today <= reminder_days_before
          // So the first day the push fires is: rental_end_date - reminder_days_before
          const daysBefore = row.reminder_days_before ?? 1;
          const scheduledSendDate = new Date(endDate);
          scheduledSendDate.setDate(scheduledSendDate.getDate() - daysBefore);
          const daysUntilSend = Math.round(
            (scheduledSendDate.getTime() - today.getTime()) / msPerDay,
          );

          return {
            order_id: row.id,
            listing_title: listingTitle,
            buyer_id: row.buyer?.id ?? '',
            buyer_name: buyerName,
            buyer_email: row.buyer?.email ?? '',
            rental_end_date: row.rental_end_date,
            reminder_days_before: daysBefore,
            reminder_email: row.reminder_email ?? false,
            days_until_expiry: daysUntil,
            scheduled_send_date: scheduledSendDate,
            days_until_send: daysUntilSend,
            notification_preview: preview,
          };
        })
        // Exclude already-expired rentals (past end date) — they would have been missed
        .filter((r) => r.days_until_expiry >= 0);

      return reminders;
    },
    // Refresh every 5 minutes so the admin queue stays current
    refetchInterval: 5 * 60 * 1000,
  });
}

/**
 * Triggers the check-rental-reminders Edge Function manually from admin.
 * Processes all due reminders and queues them for push delivery.
 */
export function useTriggerRentalReminders() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async () => {
      const { data, error } = await supabase.functions.invoke(
        'check-rental-reminders',
        { method: 'POST' },
      );
      if (error) throw error;
      return data as { success: boolean; reminders_processed: number; message: string };
    },
    onSuccess: () => {
      // Refresh pending queue after processing
      queryClient.invalidateQueries({ queryKey: REMINDERS_QUERY_KEY });
    },
  });
}

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
