-- ════════════════════════════════════════════════════════════
-- 00106: Rental Reminder Cleanup Triggers
--
-- Handles two scenarios for stale rental_reminder notifications:
--
-- 1. Rental end date changes (extension approved):
--    - Delete existing UNREAD rental_reminder notifications for the order.
--    - The reminder_sent flag is already reset to false by the existing
--      reset_rental_reminder() trigger (migration 00028), so the next
--      check_rental_reminders() run will fire a fresh notification with
--      the correct new end date.
--
-- 2. Rental ends early (rental_status leaves 'active'):
--    - Delete all UNREAD rental_reminder notifications for the order.
--    - Prevents confusing "expiring soon" alerts appearing in the buyer's
--      notification center after the rental has already been returned.
-- ════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.cleanup_stale_rental_reminders()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- ── Scenario 1: rental_end_date changed (extension/shortening approved) ──
  -- Delete unread reminder notifications so the buyer's inbox shows the
  -- fresh notification that will be generated for the new end date.
  IF OLD.rental_end_date IS DISTINCT FROM NEW.rental_end_date THEN
    DELETE FROM public.notifications
    WHERE related_order_id = NEW.id
      AND type = 'rental_reminder'
      AND is_read = false;
  END IF;

  -- ── Scenario 2: rental ended early (returned / completed / cancelled) ──
  -- rental_status transitions away from 'active' means the rental is done.
  -- Remove any pending reminder notifications to avoid confusing the buyer.
  IF OLD.rental_status = 'active'
     AND NEW.rental_status IS DISTINCT FROM OLD.rental_status
     AND NEW.rental_status IN ('return_requested', 'returned', 'deposit_refunded', 'completed', 'cancelled') THEN
    DELETE FROM public.notifications
    WHERE related_order_id = NEW.id
      AND type = 'rental_reminder'
      AND is_read = false;

    -- NOTE: Also mark reminder_sent = true to prevent any future cron job
    -- run from re-firing a reminder for a completed rental.
    NEW.reminder_sent := true;
  END IF;

  RETURN NEW;
END;
$$;

-- NOTE: BEFORE trigger is used (not AFTER) so that we can also modify
-- NEW.reminder_sent in Scenario 2 within the same trigger.
-- The rental_end_date change fires as BEFORE UPDATE OF rental_end_date,
-- but we need to cover all columns (rental_end_date AND rental_status),
-- so we use a general BEFORE UPDATE trigger instead.
DROP TRIGGER IF EXISTS on_rental_reminder_cleanup ON public.orders;
CREATE TRIGGER on_rental_reminder_cleanup
  BEFORE UPDATE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.cleanup_stale_rental_reminders();
