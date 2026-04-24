-- ════════════════════════════════════════════════════════════
-- 00025: Fix view_count (exclude seller) + inquiry_count (count orders)
--
-- 1. view_count: Exclude views from the listing's own seller
-- 2. inquiry_count: Count orders (not chat_rooms) for accurate Offers stat
-- 3. Clean up existing seller self-views from listing_views
-- ════════════════════════════════════════════════════════════

-- ─── 1. Fix view_count trigger to exclude seller's own views ───

CREATE OR REPLACE FUNCTION public.update_listing_view_count()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_seller_id uuid;
BEGIN
  -- Get the listing's seller ID
  SELECT seller_id INTO v_seller_id
  FROM public.listings
  WHERE id = NEW.listing_id;

  -- Don't count if viewer is the seller
  IF NEW.viewer_id IS NOT NULL AND NEW.viewer_id = v_seller_id THEN
    -- Delete the self-view record (optional: keep it but don't count)
    DELETE FROM public.listing_views WHERE id = NEW.id;
    RETURN NULL;
  END IF;

  UPDATE public.listings
  SET view_count = (
    SELECT count(*) FROM public.listing_views lv
    JOIN public.listings l ON l.id = lv.listing_id
    WHERE lv.listing_id = NEW.listing_id
      AND (lv.viewer_id IS NULL OR lv.viewer_id != l.seller_id)
  )
  WHERE id = NEW.listing_id;
  RETURN NEW;
END;
$$;

-- ─── 2. inquiry_count should count orders, not chat_rooms ───

-- Drop old trigger on chat_rooms
DROP TRIGGER IF EXISTS on_chat_room_created ON public.chat_rooms;

-- Create new function counting orders
CREATE OR REPLACE FUNCTION public.update_listing_inquiry_count()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  UPDATE public.listings
  SET inquiry_count = (
    SELECT count(*) FROM public.orders
    WHERE listing_id = COALESCE(NEW.listing_id, OLD.listing_id)
  )
  WHERE id = COALESCE(NEW.listing_id, OLD.listing_id);
  RETURN NEW;
END;
$$;

-- Trigger on orders table (INSERT and UPDATE to catch cancellations)
DROP TRIGGER IF EXISTS on_order_inquiry_count ON public.orders;
CREATE TRIGGER on_order_inquiry_count
  AFTER INSERT OR UPDATE OF status OR DELETE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.update_listing_inquiry_count();

-- ─── 3. Backfill: clean up existing data ───

-- Remove seller self-views
DELETE FROM public.listing_views lv
USING public.listings l
WHERE lv.listing_id = l.id
  AND lv.viewer_id = l.seller_id;

-- Recalculate all view_counts (excluding seller)
UPDATE public.listings l
SET view_count = (
  SELECT count(*) FROM public.listing_views lv
  WHERE lv.listing_id = l.id
    AND (lv.viewer_id IS NULL OR lv.viewer_id != l.seller_id)
);

-- Recalculate all inquiry_counts from orders
UPDATE public.listings l
SET inquiry_count = (
  SELECT count(*) FROM public.orders o
  WHERE o.listing_id = l.id
);
