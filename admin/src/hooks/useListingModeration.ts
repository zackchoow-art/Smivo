import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE, MODERATION_STATUS } from '@/lib/constants';
import type { ListingWithDetails, ModerationStatus } from '@/types';
import { useSchoolScopeStore } from '@/stores/school-scope-store';

const LISTINGS_QUERY_KEY = ['listings'] as const;

export interface ListingModerationFilters {
  status?: ModerationStatus | 'all';
}

export interface AllListingsFilters {
  dateSort?: 'newest' | 'oldest';
  categoryId?: string | 'all';
}

/**
 * Fetch paginated listings for moderation, sorted by priority.
 * Priority sorting: urgent (1) > normal (2) > low (3). Can be handled on SQL or JS side.
 * In Supabase, we can sort by moderation_priority field, or handle it on the client, but for simplicity, we add sorting to the request if specific filtering is supported.
 */
export function useListingsModeration(page: number, filters?: ListingModerationFilters) {
  const currentCollegeId = useSchoolScopeStore((state) => state.currentCollegeId);

  return useQuery({
    queryKey: [...LISTINGS_QUERY_KEY, 'list', page, filters, currentCollegeId],
    queryFn: async () => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;
      
      let query = supabase
        .from(TABLES.LISTINGS)
        .select(`
          *,
          images:listing_images(image_url),
          seller:user_profiles!seller_id(id, display_name, email, avatar_url)
        `, { count: 'exact' });

      // NOTE: Filter by school scope — non-sysadmin admins only see their school's listings
      if (currentCollegeId) {
        query = query.eq('school_id', currentCollegeId);
      }

      if (filters?.status && filters.status !== 'all') {
        query = query.eq('moderation_status', filters.status);
      }

      // Sorted by intercepted time (created_at), oldest first.
      query = query.order('created_at', { ascending: true });
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
      
      const mapped = data as ListingWithDetails;
      
      try {
        // Find next/prev within the pending_review queue
        const { data: nextData } = await supabase
          .from(TABLES.LISTINGS)
          .select('id')
          .eq('moderation_status', MODERATION_STATUS.PENDING_REVIEW)
          .lt('created_at', data.created_at)
          .order('created_at', { ascending: false })
          .limit(1)
          .maybeSingle();

        const { data: prevData } = await supabase
          .from(TABLES.LISTINGS)
          .select('id')
          .eq('moderation_status', MODERATION_STATUS.PENDING_REVIEW)
          .gt('created_at', data.created_at)
          .order('created_at', { ascending: true })
          .limit(1)
          .maybeSingle();

        mapped.next_id = nextData?.id;
        mapped.prev_id = prevData?.id;
      } catch (e) {
        console.error('Failed to fetch prev/next listing ids', e);
      }

      return mapped;
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
        targetStatus = MODERATION_STATUS.REJECTED;
        draftDecision = 'takedown';
      }

      // 1. Update the listing status
      const updatePayload: Record<string, any> = {
        moderation_status: targetStatus,
        moderation_note: reason || null,
        moderated_by: adminId,
        moderated_at: new Date().toISOString(),
      };

      // IMPORTANT: When rejecting or taking down, deactivate the listing
      // so it disappears from public feeds and 'active' lists.
      if (action === 'reject' || action === 'takedown') {
        updatePayload.status = 'inactive';
      }

      const { error: updateError } = await supabase
        .from(TABLES.LISTINGS)
        .update(updatePayload)
        .eq('id', id);

      if (updateError) throw updateError;

      // 1.5. Update associated images status to sync with listing decision
      const imageStatus = action === 'approve' ? MODERATION_STATUS.APPROVED : MODERATION_STATUS.REJECTED;
      const { error: imageError } = await supabase
        .from(TABLES.LISTING_IMAGES)
        .update({
          moderation_status: imageStatus,
          moderation_reasons: action === 'approve' ? null : (reason || 'Taken down by administrator')
        })
        .eq('listing_id', id);

      if (imageError) {
        console.error('Failed to update listing images status', imageError);
      }

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
 * NOTE: When rejecting, we also set status = 'inactive' so the listing is
 * immediately hidden from the app home feed (which filters by status='active').
 * moderation_status='rejected' provides the admin-level audit trail.
 */
export function useBatchModerateListings() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ ids, action, adminId }: { ids: string[], action: 'approve' | 'reject' | 'takedown', adminId: string }) => {
      // NOTE: 'takedown' uses TAKEN_DOWN (not REJECTED) so the DB trigger
      // listing_taken_down_trigger fires and cancels pending orders / clears
      // saved_listings. 'reject' is reserved for non-user-report rejections
      // where the cleanup trigger is not needed.
      let targetModerationStatus: string;
      if (action === 'approve') {
        targetModerationStatus = MODERATION_STATUS.APPROVED;
      } else if (action === 'takedown') {
        targetModerationStatus = MODERATION_STATUS.TAKEN_DOWN;
      } else {
        targetModerationStatus = MODERATION_STATUS.REJECTED;
      }

      // NOTE: When rejecting or taking down, we must also deactivate the
      // listing. The listings.status CHECK constraint only allows:
      // active, inactive, reserved, sold, rented.
      // 'rejected' / 'taken_down' are NOT valid status values — they live
      // in moderation_status.
      const updatePayload: Record<string, any> = {
        moderation_status: targetModerationStatus,
        moderated_by: adminId,
        moderated_at: new Date().toISOString(),
      };

      if (action === 'reject' || action === 'takedown') {
        // IMPORTANT: Set status to inactive so the listing disappears from
        // the app home feed immediately, regardless of client-side filter version.
        updatePayload.status = 'inactive';
      }

      const { error } = await supabase
        .from(TABLES.LISTINGS)
        .update(updatePayload)
        .in('id', ids);

      if (error) {
        console.error('[useBatchModerateListings] listings UPDATE failed:', error);
        throw error;
      }

      // 1.5. Batch update associated images status
      const imagesModerationStatus = action === 'approve'
        ? MODERATION_STATUS.APPROVED
        : MODERATION_STATUS.REJECTED;  // images always use REJECTED for audit clarity
      const { error: imagesError } = await supabase
        .from(TABLES.LISTING_IMAGES)
        .update({
          moderation_status: imagesModerationStatus,
          moderation_reasons: action === 'approve' ? null : 'Taken down by administrator'
        })
        .in('listing_id', ids);

      if (imagesError) {
        console.error('[useBatchModerateListings] images update failed:', imagesError);
      }

      // Batch audit log insert for all affected listings
      const auditRows = ids.map((listingId) => ({
        admin_id: adminId,
        action: `listing_${action}`,
        target_type: 'listing',
        target_id: listingId,
        payload: { batch: true, action },
      }));

      const { error: auditError } = await supabase
        .from(TABLES.ADMIN_AUDIT_LOGS)
        .insert(auditRows);

      if (auditError) {
        console.error('[useBatchModerateListings] audit log failed:', auditError);
      }

      return ids;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: LISTINGS_QUERY_KEY });
    },
  });
}

/**
 * Fetch all listings for the All Listings page.
 */
export function useAllListings(page: number, filters?: AllListingsFilters) {
  const currentCollegeId = useSchoolScopeStore((state) => state.currentCollegeId);

  return useQuery({
    queryKey: [...LISTINGS_QUERY_KEY, 'all-listings', page, filters, currentCollegeId],
    queryFn: async () => {
      const from = page * DEFAULT_PAGE_SIZE;
      const to = from + DEFAULT_PAGE_SIZE - 1;
      
      let query = supabase
        .from(TABLES.LISTINGS)
        .select(`
          *,
          images:listing_images(image_url),
          seller:user_profiles!seller_id(id, display_name, email, avatar_url)
        `, { count: 'exact' });

      // NOTE: Filter by school scope — non-sysadmin admins only see their school's listings
      if (currentCollegeId) {
        query = query.eq('school_id', currentCollegeId);
      }

      if (filters?.categoryId && filters.categoryId !== 'all') {
        query = query.eq('category', filters.categoryId);
      }

      query = query.order('created_at', { ascending: filters?.dateSort === 'oldest' });
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
 * Simulate an AI review by tagging a listing and sending it to the System Queue.
 */
export function useSimulateAIReview() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      listingId,
      trigger,
      action,
      priority
    }: {
      listingId: string;
      trigger: string;
      action: string;
      priority: string;
    }) => {
      const { error } = await supabase
        .from(TABLES.LISTINGS)
        .update({
          moderation_status: MODERATION_STATUS.PENDING_REVIEW,
          moderation_trigger: trigger,
          moderation_note: `[AI SIMULATION] Recommendation: ${action}`,
          moderation_priority: priority
        })
        .eq('id', listingId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: LISTINGS_QUERY_KEY });
    },
  });
}

/**
 * Fetch orders associated with a listing
 */
export function useListingOrders(listingId: string | undefined) {
  return useQuery({
    queryKey: ['orders', 'listing', listingId],
    queryFn: async () => {
      if (!listingId) return [];
      
      const { data, error } = await supabase
        .from(TABLES.ORDERS)
        .select(`
          *,
          buyer:user_profiles!buyer_id(id, display_name, email, avatar_url)
        `)
        .eq('listing_id', listingId)
        .order('created_at', { ascending: false });
        
      if (error) throw error;
      return data as any[];
    },
    enabled: !!listingId,
  });
}
