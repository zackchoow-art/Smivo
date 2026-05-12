-- Carpool reviews: N-to-N peer reviews after trip completion
CREATE TABLE IF NOT EXISTS public.carpool_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES public.carpool_trips(id) ON DELETE CASCADE,
  reviewer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reviewee_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Each reviewer can only review each reviewee once per trip
  CONSTRAINT unique_review_per_trip UNIQUE (trip_id, reviewer_id, reviewee_id),
  -- Cannot review yourself
  CONSTRAINT no_self_review CHECK (reviewer_id != reviewee_id)
);

-- Index for fetching reviews by trip
CREATE INDEX idx_carpool_reviews_trip ON public.carpool_reviews(trip_id);
-- Index for fetching a user's received reviews
CREATE INDEX idx_carpool_reviews_reviewee ON public.carpool_reviews(reviewee_id);

-- RLS: members of the trip can read all reviews for that trip
ALTER TABLE public.carpool_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Trip members can read reviews"
  ON public.carpool_reviews FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.carpool_members
      WHERE carpool_members.trip_id = carpool_reviews.trip_id
        AND carpool_members.user_id = auth.uid()
        AND carpool_members.status = 'approved'
    )
  );

CREATE POLICY "Members can create their own reviews"
  ON public.carpool_reviews FOR INSERT
  WITH CHECK (
    reviewer_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.carpool_members
      WHERE carpool_members.trip_id = carpool_reviews.trip_id
        AND carpool_members.user_id = auth.uid()
        AND carpool_members.status = 'approved'
    )
  );

-- Also add the missing status values to carpool_trips if not already present
-- (departed, arrived, completed)
-- The status column is TEXT, no enum constraint, so no ALTER needed.
