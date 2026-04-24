# Task 011c: Rental Expiry Reminders — Batch 3

## Pre-requisites
- 011a (page split) and 011b (extension feature) MUST be complete
- Read `.agent/docs/theme-architecture.md` for styling rules
- Use ONLY theme tokens, NO hardcoded colors
- Read each target file fully before modifying

---

## Overview

Add rental expiry reminder system:
1. **Order-level preferences**: buyer sets days-before reminder + email opt-in
2. **SQL function** (called via cron): checks for due rentals and creates notifications
3. **Flutter UI widget**: `RentalReminderSettings` for the rental order detail page

### Architecture decision

For the reminder check mechanism, we use a **Supabase pg_cron + SQL function**
approach instead of a Deno Edge Function because:
- pg_cron runs directly in the database — no external HTTP calls needed
- The logic is simple (query + insert notifications) — no complex computation
- Email sending will be handled by a separate Edge Function triggered by
  a notification insert (future work — for now, just create the notification)

---

## Step 1: SQL Migration — Order Fields + Reminder Function

**Create file**: `supabase/migrations/00027_rental_reminders.sql`

```sql
-- ════════════════════════════════════════════════════════════
-- 00027: Rental Reminder System
--
-- 1. Add reminder preference fields to orders table
-- 2. Add 'rental_reminder' + 'rental_extension' to notification type constraint
-- 3. Create function to check and send rental expiry reminders
-- 4. Optionally set up pg_cron schedule (requires Supabase cron extension)
-- ════════════════════════════════════════════════════════════

-- ─── 1. Add reminder fields to orders ───

ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS reminder_days_before integer DEFAULT 1,
  ADD COLUMN IF NOT EXISTS reminder_email boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS reminder_sent boolean DEFAULT false;

-- ─── 2. Update notification type constraint ───
-- Drop and recreate the CHECK constraint to add new notification types

ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check CHECK (
    type = ANY (ARRAY[
      'order_placed'::text,
      'order_accepted'::text,
      'order_cancelled'::text,
      'order_delivered'::text,
      'order_completed'::text,
      'rental_reminder'::text,
      'rental_extension'::text,
      'system'::text
    ])
  );

-- ─── 3. Reminder check function ───
-- This function finds active rental orders approaching their end date
-- and creates reminder notifications for the buyer.

CREATE OR REPLACE FUNCTION public.check_rental_reminders()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_count integer := 0;
  v_order RECORD;
  v_listing_title text;
  v_days_left integer;
BEGIN
  FOR v_order IN
    SELECT o.id, o.buyer_id, o.listing_id, o.rental_end_date,
           o.reminder_days_before, o.reminder_email
    FROM public.orders o
    WHERE o.order_type = 'rental'
      AND o.rental_status = 'active'
      AND o.rental_end_date IS NOT NULL
      AND o.reminder_sent = false
      AND o.rental_end_date::date - CURRENT_DATE <= o.reminder_days_before
      AND o.rental_end_date::date >= CURRENT_DATE
  LOOP
    -- Get listing title for notification body
    SELECT l.title INTO v_listing_title
    FROM public.listings l
    WHERE l.id = v_order.listing_id;

    v_listing_title := coalesce(v_listing_title, 'your rental item');
    v_days_left := v_order.rental_end_date::date - CURRENT_DATE;

    -- Create in-app notification
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      v_order.buyer_id,
      'rental_reminder',
      'Rental Expiring Soon',
      CASE
        WHEN v_days_left = 0 THEN '"' || v_listing_title || '" rental expires today!'
        WHEN v_days_left = 1 THEN '"' || v_listing_title || '" rental expires tomorrow'
        ELSE '"' || v_listing_title || '" rental expires in ' || v_days_left || ' days'
      END,
      v_order.id,
      'order'
    );

    -- Mark reminder as sent
    UPDATE public.orders
    SET reminder_sent = true,
        updated_at = now()
    WHERE id = v_order.id;

    -- TODO: If v_order.reminder_email is true, trigger email via
    -- Supabase Edge Function or pg_net extension. Not implemented yet.

    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;

-- ─── 4. Reset reminder_sent when rental_end_date changes ───
-- This handles extensions: after end date is updated, allow new reminders.

CREATE OR REPLACE FUNCTION public.reset_rental_reminder()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF OLD.rental_end_date IS DISTINCT FROM NEW.rental_end_date THEN
    NEW.reminder_sent := false;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_rental_end_date_change ON public.orders;
CREATE TRIGGER on_rental_end_date_change
  BEFORE UPDATE OF rental_end_date ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.reset_rental_reminder();

-- ─── 5. Schedule with pg_cron (if available) ───
-- Run the reminder check daily at 8:00 AM UTC.
-- NOTE: If pg_cron is not enabled in your Supabase project,
-- these lines will fail silently. You can also set this up
-- manually in Supabase Dashboard > Database > Extensions > pg_cron.

-- Uncomment these lines if pg_cron is enabled:
-- SELECT cron.schedule(
--   'check-rental-reminders',
--   '0 8 * * *',
--   $$SELECT public.check_rental_reminders()$$
-- );
```

**Execute the migration**:
```bash
./db.sh -f supabase/migrations/00027_rental_reminders.sql
```

**Verify the new columns exist**:
```bash
./db.sh -c "SELECT column_name, data_type, column_default FROM information_schema.columns WHERE table_name = 'orders' AND column_name LIKE 'reminder%';"
```

---

## Step 2: Update Order Model

**File**: `lib/data/models/order.dart`

Add three new fields to the `Order` freezed class, AFTER the existing
`returnRequestedAt` field (around line 41):

```dart
    // Rental reminder preferences
    @JsonKey(name: 'reminder_days_before') @Default(1) int reminderDaysBefore,
    @JsonKey(name: 'reminder_email') @Default(false) bool reminderEmail,
    @JsonKey(name: 'reminder_sent') @Default(false) bool reminderSent,
```

**Run code generation** after modifying:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Step 3: Add Repository Method

**File**: `lib/data/repositories/order_repository.dart`

Add a method to update reminder preferences:

```dart
  /// Updates rental reminder preferences for an order.
  Future<void> updateReminderPreferences({
    required String orderId,
    required int daysBefore,
    required bool sendEmail,
  }) async {
    await _client
        .from(AppConstants.tableOrders)
        .update({
          'reminder_days_before': daysBefore,
          'reminder_email': sendEmail,
          'reminder_sent': false, // Reset so new reminder can fire
        })
        .eq('id', orderId);
  }
```

Place this method near the other update methods (after `updateRentalStatus`
or `confirmDelivery`).

---

## Step 4: Add Provider Method

**File**: `lib/features/orders/providers/orders_provider.dart`

Add a method to the `OrderActions` notifier class:

```dart
  /// Updates rental reminder preferences.
  Future<void> updateReminderPreferences({
    required String orderId,
    required int daysBefore,
    required bool sendEmail,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(orderRepositoryProvider).updateReminderPreferences(
        orderId: orderId,
        daysBefore: daysBefore,
        sendEmail: sendEmail,
      );
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
```

---

## Step 5: Create UI Widget

**Create file**: `lib/features/orders/widgets/rental_reminder_settings.dart`

This widget lets the buyer configure when to receive a reminder before
the rental expires.

### Constructor:

```dart
class RentalReminderSettings extends ConsumerStatefulWidget {
  const RentalReminderSettings({
    super.key,
    required this.order,
    required this.isBuyer,
  });
  final Order order;
  final bool isBuyer;
```

### Layout:

```
┌──────────────────────────────────────────────┐
│ 🔔 RENTAL REMINDER                          │
│                                              │
│ Remind me before rental expires              │
│                                              │
│  Days before:  [  1  ▾ ]                     │
│                                              │
│  □ Also send email notification              │
│                                              │
│  ✓ Reminder saved                            │
│    or                                        │
│  [Save Preferences]  (only if changed)       │
└──────────────────────────────────────────────┘
```

### Behavior:

1. **Visibility**: Only show when:
   - `isBuyer == true`
   - `order.orderType == 'rental'`
   - `order.rentalStatus == 'active'` (rental is currently active)
   - `order.rentalEndDate != null`

2. **Days before dropdown**: Options: 1, 2, 3, 5, 7 days
   - Default: `order.reminderDaysBefore`

3. **Email checkbox**: 
   - Default: `order.reminderEmail`

4. **Save button**: Only shows when values differ from current order values.
   Calls `ref.read(orderActionsProvider.notifier).updateReminderPreferences(...)`

5. **Saved indicator**: If `order.reminderSent == true`, show
   "✓ Reminder already sent" in a success-tinted container.
   If `order.reminderSent == false`, show
   "Reminder will be sent [N] day(s) before [end date]" as helper text.

### Style:
- Container with `surfaceContainerLow` background and `radius.lg` corners
- Use theme tokens for all colors and typography
- Dropdown uses `DropdownButtonFormField`
- Checkbox uses `Switch` or `Checkbox` widget

---

## Step 6: Integrate into RentalOrderDetailScreen

**File**: `lib/features/orders/screens/rental_order_detail_screen.dart`

Add the `RentalReminderSettings` widget after the `RentalExtensionCard`
and before the chat section.

Insert around line 84 (after the RentalExtensionCard block):

```dart
          // Rental reminder settings — only for active rentals, buyer only
          if (order.rentalStatus == 'active' && isBuyer) ...[
            RentalReminderSettings(
              order: order,
              isBuyer: isBuyer,
            ),
            const SizedBox(height: 16),
          ],
```

Import the widget at the top of the file:
```dart
import 'package:smivo/features/orders/widgets/rental_reminder_settings.dart';
```

---

## Step 7: Test the reminder function manually

After the SQL migration is applied, test the function manually:

```bash
./db.sh -c "SELECT public.check_rental_reminders();"
```

This should return 0 (no active rentals due yet). The function will create
notifications automatically when rentals approach their end date.

---

## Testing Checklist

1. SQL migration executes without errors
2. New `reminder_*` columns exist on `orders` table
3. `notifications_type_check` constraint includes `rental_reminder` and `rental_extension`
4. Order model generates correctly with new fields (`build_runner build`)
5. Buyer sees reminder settings card on active rental orders
6. Buyer can change days-before and toggle email
7. Save button appears only when values changed
8. Save persists to database (verify via `./db.sh`)
9. `check_rental_reminders()` function returns 0 (no due rentals)
10. If a rental end date is manually set to today in DB, running
    `check_rental_reminders()` creates a notification
11. After rental extension is approved, `reminder_sent` resets to false
12. Seller does NOT see the reminder settings card
13. Reminder card hidden for non-active rentals
14. Run `flutter analyze` — zero errors

---

## Files summary

| File | Action |
|------|--------|
| `supabase/migrations/00027_rental_reminders.sql` | CREATE + EXECUTE via `./db.sh` |
| `lib/data/models/order.dart` | MODIFY — add 3 reminder fields |
| `lib/data/repositories/order_repository.dart` | MODIFY — add `updateReminderPreferences` |
| `lib/features/orders/providers/orders_provider.dart` | MODIFY — add provider method |
| `lib/features/orders/widgets/rental_reminder_settings.dart` | CREATE |
| `lib/features/orders/screens/rental_order_detail_screen.dart` | MODIFY — add widget |
