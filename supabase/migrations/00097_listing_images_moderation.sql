-- Migration to add per-image moderation tracking
ALTER TABLE public.listing_images
ADD COLUMN moderation_status TEXT NOT NULL DEFAULT 'auto_approved' CHECK (moderation_status IN ('auto_approved', 'pending_review', 'approved', 'rejected', 'taken_down')),
ADD COLUMN moderation_reasons TEXT;

-- Notify PostgREST to refresh schema cache
NOTIFY pgrst, 'reload schema';
