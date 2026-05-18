/**
 * Hooks for admin-side listing editing (data maintenance only).
 *
 * These mutations directly update the listings/listing_images tables
 * and storage bucket WITHOUT triggering any app-side notifications,
 * order invalidation, or status changes. This is purely backend
 * data repair for admin use.
 */
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { TABLES } from '@/lib/constants';

// ── Types ───────────────────────────────────────────────────────────────────

export interface ListingUpdatePayload {
  listingId: string;
  title?: string;
  description?: string;
  price?: number;
}

export interface ImageUploadPayload {
  listingId: string;
  sellerId: string;
  file: File;
}

export interface ImageDeletePayload {
  imageId: string;
  imageUrl: string;
}

// ── Update listing text fields ──────────────────────────────────────────────

export function useAdminUpdateListing() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ listingId, ...fields }: ListingUpdatePayload) => {
      // Build update payload with only non-undefined fields
      const payload: Record<string, unknown> = {};
      if (fields.title !== undefined)       payload.title = fields.title;
      if (fields.description !== undefined) payload.description = fields.description;
      if (fields.price !== undefined)       payload.price = fields.price;

      if (Object.keys(payload).length === 0) {
        throw new Error('No fields to update');
      }

      // NOTE: We intentionally do NOT update 'status' or 'updated_at' here
      // to avoid triggering any app-side change detection or notification logic.
      const { error } = await supabase
        .from(TABLES.LISTINGS)
        .update(payload)
        .eq('id', listingId);

      if (error) throw error;
      return { listingId };
    },
    onSuccess: () => {
      // Invalidate all listing queries to refresh the table
      queryClient.invalidateQueries({ queryKey: ['listings'] });
    },
  });
}

// ── Upload a new image ──────────────────────────────────────────────────────

export function useAdminUploadListingImage() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ listingId, sellerId, file }: ImageUploadPayload) => {
      // Generate a unique filename to prevent collisions
      const ext = file.name.split('.').pop() || 'jpg';
      const fileName = `${Date.now()}_${Math.random().toString(36).slice(2, 8)}.${ext}`;

      // Storage path: {sellerId}/{listingId}/{fileName}
      // This matches the Flutter app's upload path convention.
      const storagePath = `${sellerId}/${listingId}/${fileName}`;

      // Step 1: Upload file to storage bucket
      const { error: uploadError } = await supabase.storage
        .from('listing-images')
        .upload(storagePath, file, {
          cacheControl: '3600',
          upsert: false,
        });

      if (uploadError) {
        console.error('[AdminUpload] Storage upload failed:', uploadError.message);
        throw uploadError;
      }

      // Step 2: Get the public URL
      const { data: { publicUrl } } = supabase.storage
        .from('listing-images')
        .getPublicUrl(storagePath);

      // Step 3: Get current max sort_order for this listing
      const { data: existingImages } = await supabase
        .from(TABLES.LISTING_IMAGES)
        .select('sort_order')
        .eq('listing_id', listingId)
        .order('sort_order', { ascending: false })
        .limit(1);

      const nextSortOrder = ((existingImages?.[0]?.sort_order as number) ?? -1) + 1;

      // Step 4: Insert record into listing_images table
      const { error: insertError } = await supabase
        .from(TABLES.LISTING_IMAGES)
        .insert({
          listing_id: listingId,
          image_url: publicUrl,
          sort_order: nextSortOrder,
        });

      if (insertError) {
        console.error('[AdminUpload] DB insert failed:', insertError.message);
        // Try to clean up the uploaded file
        await supabase.storage.from('listing-images').remove([storagePath]);
        throw insertError;
      }

      return { publicUrl, storagePath };
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['listings'] });
    },
  });
}

// ── Delete an image ─────────────────────────────────────────────────────────

export function useAdminDeleteListingImage() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ imageId, imageUrl }: ImageDeletePayload) => {
      // Step 1: Delete the DB record
      const { error: dbError } = await supabase
        .from(TABLES.LISTING_IMAGES)
        .delete()
        .eq('id', imageId);

      if (dbError) throw dbError;

      // Step 2: Delete the storage file
      // Extract storage path from the public URL.
      // URL format: https://{host}/storage/v1/object/public/listing-images/{path}
      const marker = '/object/public/listing-images/';
      const markerIndex = imageUrl.indexOf(marker);
      if (markerIndex !== -1) {
        const storagePath = decodeURIComponent(imageUrl.substring(markerIndex + marker.length));
        const { error: storageError } = await supabase.storage
          .from('listing-images')
          .remove([storagePath]);

        if (storageError) {
          // Log but don't throw — DB record is already deleted.
          // Orphaned storage files can be cleaned up later.
          console.warn('[AdminDelete] Storage delete failed:', storageError.message);
        }
      }

      return { imageId };
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['listings'] });
    },
  });
}
