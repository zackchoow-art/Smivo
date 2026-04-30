import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { 
  ReportWithUsers, 
  ReportStatus, 
  ReportReason,
  ReportResolution
} from '@/types/report';

const QUERY_KEY = ['chat-reports'] as const;

export interface ChatReportFilters {
  status?: ReportStatus;
  reason?: ReportReason;
}

/**
 * Hook for listing chat reports.
 * Filters by target_type = 'message'.
 */
export function useChatReports(page: number, filters: ChatReportFilters = {}) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'list', page, filters],
    queryFn: async () => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;

      // NOTE: We use a RPC or a complex select to get reporter/reported names if needed,
      // but for now we'll do a basic join if RLS allows or handle it in the view.
      // Migration 00044 introduced content_reports.
      let query = supabase
        .from(TABLES.CONTENT_REPORTS)
        .select(`
          *,
          reporter:reporter_id(display_name, email),
          reported:reported_user_id(display_name, email)
        `, { count: 'exact' })
        .eq('target_type', 'message')
        .range(from, to)
        .order('created_at', { ascending: false });

      if (filters.status) {
        query = query.eq('status', filters.status);
      }
      if (filters.reason) {
        query = query.eq('reason', filters.reason);
      }

      const { data, error, count } = await query;
      if (error) throw error;

      // Map join results to the ReportWithUsers interface
      const mappedData: ReportWithUsers[] = (data || []).map((item: any) => ({
        ...item,
        reporter_name: item.reporter?.display_name || null,
        reporter_email: item.reporter?.email || '',
        reported_name: item.reported?.display_name || null,
        reported_email: item.reported?.email || '',
        message_preview: item.detail // Assuming detail contains message content for chat reports
      }));

      return {
        data: mappedData,
        totalCount: count || 0,
      };
    },
  });
}

/**
 * Hook for a single chat report detail.
 */
export function useChatReport(id: string | undefined) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'detail', id],
    queryFn: async () => {
      if (!id) return null;
      const { data, error } = await supabase
        .from(TABLES.CONTENT_REPORTS)
        .select(`
          *,
          reporter:reporter_id(display_name, email),
          reported:reported_user_id(display_name, email)
        `)
        .eq('id', id)
        .single();

      if (error) throw error;

      const mapped: ReportWithUsers = {
        ...data,
        reporter_name: data.reporter?.display_name || null,
        reporter_email: data.reporter?.email || '',
        reported_name: data.reported?.display_name || null,
        reported_email: data.reported?.email || '',
        message_preview: data.detail
      };

      return mapped;
    },
    enabled: !!id,
  });
}

/**
 * Mutation for resolving a report.
 */
export function useResolveReport() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ 
      reportId, 
      resolution, 
      note,
      adminId 
    }: { 
      reportId: string; 
      resolution: ReportResolution; 
      note: string;
      adminId: string;
    }) => {
      const { data, error } = await supabase
        .from(TABLES.CONTENT_REPORTS)
        .update({
          status: resolution === 'dismiss' ? 'dismissed' : 'resolved',
          resolution,
          resolution_note: note,
          resolved_by: adminId,
          resolved_at: new Date().toISOString()
        })
        .eq('id', reportId)
        .select()
        .single();

      if (error) throw error;

      // Log to audit log
      await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
        admin_id: adminId,
        action_type: 'resolve_report',
        target_type: 'content_report',
        target_id: reportId,
        payload: { resolution, note }
      });

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}
