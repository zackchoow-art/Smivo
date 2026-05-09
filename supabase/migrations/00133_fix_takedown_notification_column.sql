-- ============================================================
-- Migration 00133: Fix notify_listing_taken_down() column bug
-- ============================================================
-- Problem: Migration 00131 rewrote notify_listing_taken_down() but
-- used a non-existent column 'metadata' in the notifications INSERT.
-- The notifications table has no 'metadata' column; it was added
-- in migration 00022 as 'action_type' + 'action_url'.
--
-- This causes the DB trigger to throw:
--   ERROR: column "metadata" of relation "notifications" does not exist
-- which rolls back the entire listings UPDATE transaction and prevents
-- admin takedown actions from completing.
--
-- Fix: Replace 'metadata' with valid columns 'action_type' + 'action_url'.
-- ============================================================

CREATE OR REPLACE FUNCTION public.notify_listing_taken_down()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_new_status   TEXT;
  v_new_mod      TEXT;
  v_old_status   TEXT;
  v_old_mod      TEXT;
  v_is_takedown  BOOLEAN;
  v_is_delist    BOOLEAN;
BEGIN
  v_new_status := NEW.status;
  v_new_mod    := NEW.moderation_status;
  v_old_status := OLD.status;
  v_old_mod    := OLD.moderation_status;

  -- Determine whether this update represents a takedown or delist event
  v_is_takedown := (v_new_mod = 'taken_down' AND v_old_mod IS DISTINCT FROM 'taken_down');
  v_is_delist   := (v_new_status = 'delisted'  AND v_old_status IS DISTINCT FROM 'delisted');

  IF v_is_takedown OR v_is_delist THEN

    -- 1. Send in-app notification to seller
    -- NOTE: Use action_type + action_url (not 'metadata' which doesn't exist)
    INSERT INTO public.notifications (
      user_id,
      type,
      title,
      body,
      action_type,
      action_url
    ) VALUES (
      NEW.seller_id,
      'listing_taken_down',
      'Your listing has been removed',
      'Your listing "' || NEW.title || '" has been removed from the marketplace.',
      'route',
      '/settings/trust-and-safety'
    );

    -- 2. Cancel all pending orders for this listing
    -- NOTE: cancelled_by = NEW.seller_id so the order notification trigger
    -- sends the buyer the correct "seller cancelled" message.
    UPDATE public.orders
    SET
      status       = 'cancelled',
      cancelled_by = NEW.seller_id,
      updated_at   = now()
    WHERE listing_id = NEW.id
      AND status     = 'pending';

    -- 3. Remove all saved_listings records for this listing
    DELETE FROM public.saved_listings
    WHERE listing_id = NEW.id;

  END IF;

  RETURN NEW;
END;
$$;
