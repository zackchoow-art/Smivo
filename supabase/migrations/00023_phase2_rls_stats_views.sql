-- ════════════════════════════════════════════════════════════
-- 00023: Phase 2 — RLS Fix + Stats Triggers + Listing Views
-- ════════════════════════════════════════════════════════════

-- ─── Part A: Fix saved_listings RLS ────────────────────────
-- Allow listing owners to see who saved their listings

CREATE POLICY "Sellers can view saves on their listings"
  ON public.saved_listings FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.listings
      WHERE listings.id = saved_listings.listing_id
      AND listings.seller_id = auth.uid()
    )
  );

-- Drop the old restrictive policy
DROP POLICY IF EXISTS "Users can read their own saves"
  ON public.saved_listings;


-- ─── Part B: Stats Triggers (save_count, inquiry_count) ───
-- Auto-update listings.save_count when saved_listings change

CREATE OR REPLACE FUNCTION public.update_listing_save_count()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.listings
    SET save_count = (
      SELECT count(*) FROM public.saved_listings
      WHERE listing_id = NEW.listing_id
    )
    WHERE id = NEW.listing_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.listings
    SET save_count = (
      SELECT count(*) FROM public.saved_listings
      WHERE listing_id = OLD.listing_id
    )
    WHERE id = OLD.listing_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER on_saved_listing_change
  AFTER INSERT OR DELETE ON public.saved_listings
  FOR EACH ROW EXECUTE FUNCTION public.update_listing_save_count();

-- Auto-update listings.inquiry_count when chat_rooms are created

CREATE OR REPLACE FUNCTION public.update_listing_inquiry_count()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  UPDATE public.listings
  SET inquiry_count = (
    SELECT count(*) FROM public.chat_rooms
    WHERE listing_id = NEW.listing_id
  )
  WHERE id = NEW.listing_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_chat_room_created
  AFTER INSERT ON public.chat_rooms
  FOR EACH ROW EXECUTE FUNCTION public.update_listing_inquiry_count();

-- Backfill existing data
UPDATE public.listings l
SET save_count = (
  SELECT count(*) FROM public.saved_listings sl
  WHERE sl.listing_id = l.id
);

UPDATE public.listings l
SET inquiry_count = (
  SELECT count(*) FROM public.chat_rooms cr
  WHERE cr.listing_id = l.id
);


-- ─── Part C: Listing Views Table ──────────────────────────
-- Track individual listing views for analytics

CREATE TABLE public.listing_views (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id  uuid NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  viewer_id   uuid REFERENCES public.user_profiles(id) ON DELETE SET NULL,
  viewed_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_listing_views_listing ON public.listing_views(listing_id);
CREATE INDEX idx_listing_views_viewer ON public.listing_views(viewer_id);

ALTER TABLE public.listing_views ENABLE ROW LEVEL SECURITY;

-- Anyone can insert a view (including anonymous guests)
CREATE POLICY "Anyone can record a view"
  ON public.listing_views FOR INSERT
  WITH CHECK (true);

-- Listing owner can read views on their listings
CREATE POLICY "Sellers can read views on their listings"
  ON public.listing_views FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.listings
      WHERE listings.id = listing_views.listing_id
      AND listings.seller_id = auth.uid()
    )
  );

-- Auto-update listings.view_count
CREATE OR REPLACE FUNCTION public.update_listing_view_count()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  UPDATE public.listings
  SET view_count = (
    SELECT count(*) FROM public.listing_views
    WHERE listing_id = NEW.listing_id
  )
  WHERE id = NEW.listing_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_listing_view
  AFTER INSERT ON public.listing_views
  FOR EACH ROW EXECUTE FUNCTION public.update_listing_view_count();
