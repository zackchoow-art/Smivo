import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type { 
  ReportWithUsers, 
  ReportStatus, 
  ReportReason,
  ReportResolution
} from '@/types/report';

const QUERY_KEY = ['listing-reports'] as const;

export interface ListingReportFilters {
  status?: ReportStatus;
  reason?: ReportReason;
}

export function useListingReports(page: number, filters: ListingReportFilters = {}) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'list', page, filters],
    queryFn: async () => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;

      let query = supabase
        .from(TABLES.CONTENT_REPORTS)
        .select(`
          *,
          reporter:user_profiles!reporter_id(display_name, email),
          reported:user_profiles!reported_user_id(display_name, email)
        `, { count: 'exact' })
        .not('listing_id', 'is', null)
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

      const mappedData: ReportWithUsers[] = (data || []).map((item: any) => ({
        ...item,
        reporter_name: item.reporter?.display_name || null,
        reporter_email: item.reporter?.email || '',
        reported_name: item.reported?.display_name || null,
        reported_email: item.reported?.email || '',
        reason: item.reason_category || 'other',
        detail: item.reason,
        message_preview: item.reason
      }));

      return {
        data: mappedData,
        totalCount: count || 0,
      };
    },
  });
}

export interface GroupedListingReport {
  listing_id: string;
  listing_title: string;
  listing_images: string[];
  reported_user_id: string;
  reported_name: string | null;
  reported_email: string;
  report_count: number;
  reasons: string[];
  first_reported_at: string;
  reports: ReportWithUsers[];
}

export function useGroupedListingReports(filters?: { status?: string; reason?: string }) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'grouped', filters],
    queryFn: async () => {
      let query = supabase
        .from(TABLES.CONTENT_REPORTS)
        .select(`
          *,
          reporter:user_profiles!reporter_id(display_name, email, avatar_url),
          reported:user_profiles!reported_user_id(display_name, email, avatar_url),
          listing:listings!listing_id(title, images:listing_images(image_url))
        `)
        .not('listing_id', 'is', null)
        .order('created_at', { ascending: true }); // Oldest first

      if (filters?.status && filters.status !== 'all') {
        query = query.eq('status', filters.status);
      }
      if (filters?.reason && filters.reason !== 'all') {
        query = query.eq('reason_category', filters.reason);
      }
        
      const { data, error } = await query;
      if (error) throw error;
      
      const mappedData: ReportWithUsers[] = (data || []).map((item: any) => ({
        ...item,
        reporter_name: item.reporter?.display_name || null,
        reporter_email: item.reporter?.email || '',
        reporter_avatar: item.reporter?.avatar_url || null,
        reported_name: item.reported?.display_name || null,
        reported_email: item.reported?.email || '',
        reported_avatar: item.reported?.avatar_url || null,
        reason: item.reason_category || 'other',
        detail: item.reason,
        message_preview: item.reason
      }));

      // Group by target_id
      const groupedMap = new Map<string, GroupedListingReport>();
      
      for (const report of mappedData) {
        if (!report.listing_id) continue;
        
        if (!groupedMap.has(report.listing_id)) {
          groupedMap.set(report.listing_id, {
            listing_id: report.listing_id,
            listing_title: (report as any).listing?.title || 'Unknown Listing',
            listing_images: (report as any).listing?.images?.map((img: any) => img.image_url) || [],
            reported_user_id: report.reported_user_id || '',
            reported_name: report.reported_name,
            reported_email: report.reported_email,
            report_count: 0,
            reasons: [],
            first_reported_at: report.created_at,
            reports: []
          });
        }
        
        const group = groupedMap.get(report.listing_id)!;
        group.reports.push(report);
        group.report_count++;
        const category = (report as any).reason_category || 'other';
        if (!group.reasons.includes(category)) {
          group.reasons.push(category);
        }
      }
      
      return Array.from(groupedMap.values());
    }
  });
}

export function useListingReportDetail(id: string | undefined) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'detail', id],
    queryFn: async () => {
      if (!id) return null;
      const { data, error } = await supabase
        .from(TABLES.CONTENT_REPORTS)
        .select(`
          *,
          reporter:user_profiles!reporter_id(display_name, email, avatar_url),
          reported:user_profiles!reported_user_id(display_name, email, avatar_url)
        `)
        .eq('id', id)
        .single();

      if (error) throw error;

      const mapped: ReportWithUsers = {
        ...data,
        reporter_name: data.reporter?.display_name || null,
        reporter_email: data.reporter?.email || '',
        reporter_avatar: data.reporter?.avatar_url || null,
        reported_name: data.reported?.display_name || null,
        reported_email: data.reported?.email || '',
        reported_avatar: data.reported?.avatar_url || null,
        reason: data.reason_category || 'other',
        detail: data.reason,
        message_preview: data.reason
      };

      return mapped;
    },
    enabled: !!id,
  });
}

export function useListingReportsByListingId(listingId: string | undefined) {
  return useQuery({
    queryKey: [...QUERY_KEY, 'by-listing', listingId],
    queryFn: async () => {
      if (!listingId) return [];
      const { data, error } = await supabase
        .from(TABLES.CONTENT_REPORTS)
        .select(`
          *,
          reporter:user_profiles!reporter_id(display_name, email, avatar_url),
          reported:user_profiles!reported_user_id(display_name, email, avatar_url)
        `)
        .eq('listing_id', listingId)
        .order('created_at', { ascending: true });

      if (error) throw error;

      return (data || []).map((item: any) => ({
        ...item,
        reporter_name: item.reporter?.display_name || null,
        reporter_email: item.reporter?.email || '',
        reporter_avatar: item.reporter?.avatar_url || null,
        reported_name: item.reported?.display_name || null,
        reported_email: item.reported?.email || '',
        reported_avatar: item.reported?.avatar_url || null,
        reason: item.reason_category || 'other',
        detail: item.reason,
        message_preview: item.reason
      })) as ReportWithUsers[];
    },
    enabled: !!listingId,
  });
}

export function useResolveListingReport() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ 
      reportId, 
      resolution, 
      note,
      adminId,
      giveReward,
      rewardPoints,
    }: { 
      reportId: string; 
      resolution: ReportResolution; 
      note: string;
      adminId: string;
      giveReward?: boolean;
      rewardPoints?: number;
    }) => {
      const { data, error } = await supabase
        .from(TABLES.CONTENT_REPORTS)
        .update({
          status: resolution === 'dismiss' ? 'dismissed' : 'resolved',
          resolution_note: note,
          // NOTE: action_taken allows the app to display the exact penalty to both parties.
          // The reported-user RLS policy only exposes 'warn'/'restrict' records.
          action_taken: resolution === 'dismiss' ? null : resolution === 'warn' ? 'warn' : 'restrict',
          reporter_reward_points: (giveReward && rewardPoints && resolution !== 'dismiss') ? rewardPoints : 0,
        })
        .eq('id', reportId)
        .select()
        .single();

      if (error) throw error;

      await supabase.from(TABLES.ADMIN_AUDIT_LOGS).insert({
        admin_id: adminId,
        action: 'resolve_listing_report',
        target_type: 'listing_report',
        target_id: reportId,
        payload: { action: resolution, notes: note },
      });

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });
}
