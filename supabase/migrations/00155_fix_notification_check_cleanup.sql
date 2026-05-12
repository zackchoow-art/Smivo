-- ============================================================
-- Fix: Clean up invalid notification rows and re-add CHECK
-- ============================================================

-- Clean up any rows with invalid type values
DELETE FROM public.notifications
WHERE type NOT IN (
  'order_placed', 'order_accepted', 'order_cancelled',
  'order_delivered', 'order_completed',
  'rental_reminder', 'rental_extension',
  'new_message', 'group_message', 'system'
);

-- Re-add the CHECK constraint (was dropped by 00154 but failed to re-add)
ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check CHECK (
    type = ANY (ARRAY[
      'order_placed', 'order_accepted', 'order_cancelled',
      'order_delivered', 'order_completed',
      'rental_reminder', 'rental_extension',
      'new_message', 'group_message', 'system'
    ])
  );
