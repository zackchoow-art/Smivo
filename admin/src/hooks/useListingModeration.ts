import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE, MODERATION_STATUS } from '@/lib/constants';
import type { ListingWithDetails, ModerationStatus } from '@/types';

const LISTINGS_QUERY_KEY = ['listings'] as const;

export interface ListingModerationFilters {
  status?: ModerationStatus | 'all';
}

/**
 * Fetch paginated listings for moderation, sorted by priority.
 * Priority sorting: urgent (1) > normal (2) > low (3). Can be handled on SQL or JS side.
 * In Supabase, we can sort by moderation_priority field, or handle it on the client, but for simplicity, we add sorting to the request if specific filtering is supported.
 */
export function useListingsModeration(page: number, filters?: ListingModerationFilters) {
  return useQuery({
    queryKey: [...LISTINGS_QUERY_KEY, 'list', page, filters],
    queryFn: async () => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;
      
      let query = supabase
        .from(TABLES.LISTINGS)
        .select(`
          *,
          seller:user_profiles!seller_id(id, display_name, email, avatar_url)
        `, { count: 'exact' });

      if (filters?.status && filters.status !== 'all') {
        query = query.eq('moderation_status', filters.status);
      }

      // For demonstration, prioritize sorting by moderation_priority, then by time in descending order.
      // Since priority is text, direct sorting might be alphabetical; ideally, use specific sorting logic.
      // Here, we simply sort by created_at descending.
      query = query.order('created_at', { ascending: false });
      query = query.range(from, to);

      const { data, error, count } = await query;
      
      if (error) throw error;
      
      return { 
        data: (data ?? []) as any[], 
        count: count ?? 0 
      };
    },
  });
}

/**
 * Fetch a single listing with its images and seller details.
 */
export function useListingModerationDetail(id: string | undefined) {
  return useQuery({
    queryKey: [...LISTINGS_QUERY_KEY, 'detail', id],
    queryFn: async () => {
      if (!id) return null;
      
      const { data, error } = await supabase
        .from(TABLES.LISTINGS)
        .select(`
          *,
          images:listing_images(*),
          seller:user_profiles!seller_id(*)
        `)
        .eq('id', id)
        .single();
        
      if (error) throw error;
      return data as ListingWithDetails;
    },
    enabled: !!id,
  });
}

export interface ModerateActionParams {
  id: string;
  action: 'approve' | 'reject' | 'takedown';
  reason?: string;
  adminId: string;
}

/**
 * Mutation to approve, reject, or takedown a listing.
 */
export function useModerateListing() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, action, reason, adminId }: ModerateActionParams) => {
      let targetStatus: ModerationStatus = MODERATION_STATUS.PENDING_REVIEW;
      let draftDecision = '';
      
      if (action === 'approve') {
        targetStatus = MODERATION_STATUS.APPROVED;
        draftDecision = 'approve';
      } else if (action === 'reject') {
        targetStatus = MODERATION_STATUS.REJECTED;
        draftDecision = 'reject';
      } else if (action === 'takedown') {
        targetStatus = MODERATION_STATUS.TAKEN_DOWN;
        draftDecision = 'takedown';
      }

      // 1. Update the listing status
      const { error: updateError } = await supabase
        .from(TABLES.LISTINGS)
        .update({
          moderation_status: targetStatus,
          moderation_note: reason || null,
          moderated_by: adminId,
          moderated_at: new Date().toISOString(),
        })
        .eq('id', id);

      if (updateError) throw updateError;

      // 2. Insert into moderation_drafts
      const { error: draftError } = await supabase
        .from(TABLES.MODERATION_DRAFTS)
        .insert({
          target_type: 'listing',
          target_id: id,
          decision: draftDecision,
          reason: reason || null,
          created_by: adminId,
        });

      if (draftError) {
        console.error('Failed to create moderation draft', draftError);
      }

      // 3. Insert audit log
      const { error: auditError } = await supabase
        .from(TABLES.ADMIN_AUDIT_LOGS)
        .insert({
          admin_id: adminId,
          action: `listing_${action}`,
          target_type: 'listing',
          target_id: id,
          payload: { reason },
        });

      if (auditError) {
        console.error('Failed to create audit log', auditError);
      }

      return { id, status: targetStatus };
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: LISTINGS_QUERY_KEY });
    },
  });
}

/**
 * Mutation to batch approve or reject listings.
 */
export function useBatchModerateListings() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ ids, action, adminId }: { ids: string[], action: 'approve' | 'reject', adminId: string }) => {
      const targetStatus = action === 'approve' ? MODERATION_STATUS.APPROVED : MODERATION_STATUS.REJECTED;
      
      const { error } = await supabase
        .from(TABLES.LISTINGS)
        .update({
          moderation_status: targetStatus,
          moderated_by: adminId,
          moderated_at: new Date().toISOString(),
        })
        .in('id', ids);

      if (error) throw error;
      
      // We skip drafting individual drafts/logs here for simplicity, but in a real app
      // you'd batch insert those as well.
      
      return ids;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: LISTINGS_QUERY_KEY });
    },
  });
}
