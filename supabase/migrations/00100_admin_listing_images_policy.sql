-- Migration 00100: Allow admins to update listing_images
--
-- Problem: Admin dashboard needs to sync per-image moderation status
-- when a listing is rejected or approved, but RLS on listing_images
-- only allowed the owner to update.
--
-- Solution: Add a policy for authenticated admin users to update
-- any listing_image row.

-- 1. Check if the policy already exists to avoid errors
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'listing_images' 
        AND policyname = 'Admin users can update listing images'
    ) THEN
        CREATE POLICY "Admin users can update listing images"
          ON public.listing_images FOR UPDATE
          USING (public.is_active_admin());
    END IF;
END
$$;

-- 2. Notify PostgREST to refresh schema cache
NOTIFY pgrst, 'reload schema';
