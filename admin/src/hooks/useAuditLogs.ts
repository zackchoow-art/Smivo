/**
 * Hook for fetching admin audit logs with pagination and filtering.
 */
import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { AuditLog } from '@/types';

export interface AuditLogFilters {
  actionType?: string;
  targetType?: string;
  adminId?: string;
  dateFrom?: string;
  dateTo?: string;
}

export interface UseAuditLogsOptions {
  page: number;
  pageSize?: number;
  filters?: AuditLogFilters;
}

export function useAuditLogs({ page, pageSize = DEFAULT_PAGE_SIZE, filters }: UseAuditLogsOptions) {
  return useQuery({
    queryKey: ['audit-logs', page, pageSize, filters],
    queryFn: async (): Promise<{ data: AuditLog[]; count: number }> => {
      const from = page * pageSize;
      const to = from + pageSize - 1;

      let query = supabase
        .from(TABLES.ADMIN_AUDIT_LOGS)
        .select('*', { count: 'exact' })
        .order('created_at', { ascending: false })
        .range(from, to);

      if (filters?.actionType) {
        query = query.eq('action', filters.actionType);
      }
      if (filters?.targetType) {
        query = query.eq('target_type', filters.targetType);
      }
      if (filters?.adminId) {
        query = query.eq('admin_id', filters.adminId);
      }
      if (filters?.dateFrom) {
        query = query.gte('created_at', filters.dateFrom);
      }
      if (filters?.dateTo) {
        query = query.lte('created_at', filters.dateTo);
      }

      const { data, error, count } = await query;

      if (error) throw error;
      return { data: data ?? [], count: count ?? 0 };
    },
  });
}

/** Fetch distinct action types for filter dropdown */
export function useAuditActionTypes() {
  return useQuery({
    queryKey: ['audit-action-types'],
    queryFn: async (): Promise<string[]> => {
      const { data, error } = await supabase
        .from(TABLES.ADMIN_AUDIT_LOGS)
        .select('action')
        .limit(100);

      if (error) throw error;
      // Deduplicate
      const unique = [...new Set((data ?? []).map((d) => d.action))];
      return unique.sort();
    },
    staleTime: 60_000,
  });
}
