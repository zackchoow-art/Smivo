# Task 011b: Rental Extension Feature — Batch 2

## Pre-requisites
- 011a (page split) MUST be complete
- Read `.agent/docs/theme-architecture.md` for styling rules
- Read `.agent/tasks/task-011-order-detail-split.md` for architecture overview
- Use ONLY theme tokens, NO hardcoded colors
- Read each target file fully before modifying

---

## Overview

Add rental extension/shortening feature:
- Buyer can request to extend or shorten rental period
- System auto-calculates price difference
- Seller approves or rejects the request
- On approval, order dates and price update automatically

---

## Step 1: SQL Migration

**Create file**: `supabase/migrations/00026_rental_extensions.sql`

```sql
-- ════════════════════════════════════════════════════════════
-- 00026: Rental Extensions Table
--
-- Allows buyers to request rental period changes (extend/shorten).
-- Seller can approve or reject. On approval, order dates update.
-- ════════════════════════════════════════════════════════════

-- ─── New table for extension requests ───

CREATE TABLE public.rental_extensions (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id       uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  requested_by   uuid NOT NULL REFERENCES auth.users(id),
  request_type   text NOT NULL CHECK (request_type IN ('extend', 'shorten')),
  original_end_date timestamptz NOT NULL,
  new_end_date   timestamptz NOT NULL,
  price_diff     numeric(10,2) NOT NULL DEFAULT 0,
  new_total      numeric(10,2) NOT NULL,
  status         text NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending', 'approved', 'rejected')),
  responded_at   timestamptz,
  rejection_note text,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_rental_ext_order ON public.rental_extensions(order_id);
CREATE INDEX idx_rental_ext_status ON public.rental_extensions(status);

-- ─── RLS ───

ALTER TABLE public.rental_extensions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Buyer and seller can view extensions"
  ON public.rental_extensions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = rental_extensions.order_id
        AND (o.buyer_id = auth.uid() OR o.seller_id = auth.uid())
    )
  );

CREATE POLICY "Buyer can request extensions"
  ON public.rental_extensions FOR INSERT
  WITH CHECK (requested_by = auth.uid());

CREATE POLICY "Seller can respond to extensions"
  ON public.rental_extensions FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = rental_extensions.order_id
        AND o.seller_id = auth.uid()
    )
  );

-- ─── Auto-update order on approval ───

CREATE OR REPLACE FUNCTION public.apply_rental_extension()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Only act when status changes to 'approved'
  IF OLD.status = 'pending' AND NEW.status = 'approved' THEN
    UPDATE public.orders
    SET rental_end_date = NEW.new_end_date,
        total_price = NEW.new_total,
        updated_at = now()
    WHERE id = NEW.order_id;
  END IF;
  
  -- Set responded_at timestamp
  IF OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected') THEN
    NEW.responded_at := now();
    NEW.updated_at := now();
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_rental_extension_response
  BEFORE UPDATE OF status ON public.rental_extensions
  FOR EACH ROW EXECUTE FUNCTION public.apply_rental_extension();

-- ─── Notifications for extension requests ───

CREATE OR REPLACE FUNCTION public.notify_rental_extension()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
  v_seller_id uuid;
  v_buyer_id uuid;
  v_type_label text;
BEGIN
  SELECT o.seller_id, o.buyer_id, l.title
  INTO v_seller_id, v_buyer_id, v_listing_title
  FROM public.orders o
  JOIN public.listings l ON l.id = o.listing_id
  WHERE o.id = NEW.order_id;

  v_listing_title := coalesce(v_listing_title, 'a rental');
  v_type_label := CASE WHEN NEW.request_type = 'extend' THEN 'extension' ELSE 'early return' END;

  -- New request → notify seller
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      v_seller_id, 'rental_extension', 'Rental ' || initcap(v_type_label) || ' Request',
      'The buyer requested a rental ' || v_type_label || ' for "' || v_listing_title || '"',
      NEW.order_id, 'order'
    );
  END IF;

  -- Response → notify buyer
  IF TG_OP = 'UPDATE' AND OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected') THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      v_buyer_id,
      'rental_extension',
      'Rental ' || initcap(v_type_label) || ' ' || initcap(NEW.status),
      CASE WHEN NEW.status = 'approved'
        THEN 'The seller approved your rental ' || v_type_label || ' for "' || v_listing_title || '"'
        ELSE 'The seller rejected your rental ' || v_type_label || ' for "' || v_listing_title || '"'
      END,
      NEW.order_id,
      'order'
    );
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER on_rental_extension_notify
  AFTER INSERT OR UPDATE OF status ON public.rental_extensions
  FOR EACH ROW EXECUTE FUNCTION public.notify_rental_extension();

-- ─── Updated timestamp trigger ───

CREATE TRIGGER set_rental_extension_updated_at
  BEFORE UPDATE ON public.rental_extensions
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();
```

**After creating the file, execute it**:
```bash
./db.sh -f supabase/migrations/00026_rental_extensions.sql
```

**IMPORTANT**: If `set_updated_at()` function doesn't exist, check for
the actual trigger function name used in other tables and use that instead.
Run `./db.sh -c "SELECT routine_name FROM information_schema.routines WHERE routine_name LIKE '%updated%'"` 
to find it.

---

## Step 2: Create Freezed Model

**Create file**: `lib/data/models/rental_extension.dart`

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rental_extension.freezed.dart';
part 'rental_extension.g.dart';

/// Represents a rental period extension or shortening request.
///
/// Maps to the `rental_extensions` table. Buyers request changes,
/// sellers approve or reject them.
@freezed
abstract class RentalExtension with _$RentalExtension {
  const factory RentalExtension({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'requested_by') required String requestedBy,
    @JsonKey(name: 'request_type') required String requestType,
    @JsonKey(name: 'original_end_date') required DateTime originalEndDate,
    @JsonKey(name: 'new_end_date') required DateTime newEndDate,
    @JsonKey(name: 'price_diff') @Default(0.0) double priceDiff,
    @JsonKey(name: 'new_total') required double newTotal,
    @Default('pending') String status,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'rejection_note') String? rejectionNote,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _RentalExtension;

  factory RentalExtension.fromJson(Map<String, dynamic> json) =>
      _$RentalExtensionFromJson(json);
}
```

**Run code generation**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Step 3: Create Repository

**Create file**: `lib/data/repositories/rental_extension_repository.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/rental_extension.dart';

part 'rental_extension_repository.g.dart';

class RentalExtensionRepository {
  RentalExtensionRepository(this._client);
  final SupabaseClient _client;

  /// Fetches all extension requests for an order, newest first.
  Future<List<RentalExtension>> fetchExtensions(String orderId) async {
    final response = await _client
        .from('rental_extensions')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: false);
    return response.map((e) => RentalExtension.fromJson(e)).toList();
  }

  /// Creates a new extension/shortening request.
  Future<RentalExtension> createExtension({
    required String orderId,
    required String requestedBy,
    required String requestType,
    required DateTime originalEndDate,
    required DateTime newEndDate,
    required double priceDiff,
    required double newTotal,
  }) async {
    final response = await _client
        .from('rental_extensions')
        .insert({
          'order_id': orderId,
          'requested_by': requestedBy,
          'request_type': requestType,
          'original_end_date': originalEndDate.toIso8601String(),
          'new_end_date': newEndDate.toIso8601String(),
          'price_diff': priceDiff,
          'new_total': newTotal,
        })
        .select()
        .single();
    return RentalExtension.fromJson(response);
  }

  /// Seller approves an extension request.
  Future<void> approveExtension(String extensionId) async {
    await _client
        .from('rental_extensions')
        .update({'status': 'approved'})
        .eq('id', extensionId);
  }

  /// Seller rejects an extension request.
  Future<void> rejectExtension(String extensionId, {String? note}) async {
    await _client
        .from('rental_extensions')
        .update({
          'status': 'rejected',
          if (note != null) 'rejection_note': note,
        })
        .eq('id', extensionId);
  }
}

@riverpod
RentalExtensionRepository rentalExtensionRepository(Ref ref) =>
    RentalExtensionRepository(ref.watch(supabaseClientProvider));
```

**Run code generation**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Step 4: Create Provider

**Create file**: `lib/features/orders/providers/rental_extension_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/rental_extension.dart';
import 'package:smivo/data/repositories/rental_extension_repository.dart';

part 'rental_extension_provider.g.dart';

/// Fetches all extension requests for a given order.
@riverpod
Future<List<RentalExtension>> orderExtensions(Ref ref, String orderId) async {
  final repo = ref.watch(rentalExtensionRepositoryProvider);
  return repo.fetchExtensions(orderId);
}

/// Handles extension request actions (create, approve, reject).
@riverpod
class RentalExtensionActions extends _$RentalExtensionActions {
  @override
  FutureOr<void> build() {}

  Future<void> requestExtension({
    required String orderId,
    required String requestedBy,
    required String requestType,
    required DateTime originalEndDate,
    required DateTime newEndDate,
    required double priceDiff,
    required double newTotal,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(rentalExtensionRepositoryProvider).createExtension(
        orderId: orderId,
        requestedBy: requestedBy,
        requestType: requestType,
        originalEndDate: originalEndDate,
        newEndDate: newEndDate,
        priceDiff: priceDiff,
        newTotal: newTotal,
      );
      ref.invalidate(orderExtensionsProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> approveExtension(String extensionId, String orderId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(rentalExtensionRepositoryProvider).approveExtension(extensionId);
      // Refresh both extensions list and order detail (dates/price updated)
      ref.invalidate(orderExtensionsProvider(orderId));
      // NOTE: Import orders_provider and invalidate orderDetailProvider
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rejectExtension(String extensionId, String orderId, {String? note}) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(rentalExtensionRepositoryProvider).rejectExtension(extensionId, note: note);
      ref.invalidate(orderExtensionsProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

**IMPORTANT**: In `approveExtension`, also import and invalidate the order
detail provider so the updated dates/price reflect:
```dart
import 'package:smivo/features/orders/providers/orders_provider.dart';
// ... inside approveExtension:
ref.invalidate(orderDetailProvider(orderId));
ref.invalidate(allOrdersProvider);
```

**Run code generation**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Step 5: Create UI Widget

**Create file**: `lib/features/orders/widgets/rental_extension_card.dart`

This widget shows:
1. **History**: List of past extension requests with status badges
2. **New Request form**: Only for buyer, only when `rentalStatus == 'active'`
3. **Approval UI**: Only for seller, only when there's a pending request

### Layout:

```
┌──────────────────────────────────────────────┐
│ RENTAL PERIOD CHANGES                        │
│                                              │
│ ┌──────────────────────────────────────────┐ │
│ │ 📅 Extension Request           Pending   │ │
│ │ New end: Jun 15, 2026                    │ │
│ │ Price change: +$150 → Total: $600        │ │
│ │ [Approve]  [Reject]        (seller only) │ │
│ └──────────────────────────────────────────┘ │
│                                              │
│ ┌──────────────────────────────────────────┐ │
│ │ 📅 Extension Request          Approved   │ │
│ │ Extended to Jun 10 → Jun 15              │ │
│ │ +$150                                    │ │
│ └──────────────────────────────────────────┘ │
│                                              │
│ [🔄 Request Extension] [⬅️ Request Early     │
│                           Return]            │
│                          (buyer only)        │
└──────────────────────────────────────────────┘
```

### Behavior:

**Buyer clicks "Request Extension"**:
1. Show a date picker for new end date (must be after current end date)
2. Auto-calculate price difference:
   - Get the listing's daily rate from `order.listing`
   - Extra days × daily rate = price_diff
   - new_total = order.totalPrice + price_diff
3. Show confirmation dialog with price summary
4. Submit → `rentalExtensionActions.requestExtension()`

**Buyer clicks "Request Early Return"**:
1. Show date picker (must be after today, before current end date)
2. `requestType = 'shorten'`, `priceDiff` is negative
3. Submit

**Seller sees pending request**:
1. [Approve] button → calls `approveExtension()`
2. [Reject] button → optional rejection note dialog → calls `rejectExtension()`

### Implementation notes:

- This is a `ConsumerWidget` that takes `Order order`, `bool isBuyer`, `bool isSeller`
- Watch `orderExtensionsProvider(order.id)` for the list
- Watch `rentalExtensionActionsProvider` for loading state
- Use theme tokens for all colors, radii, typography
- Status badges: Pending (warning color), Approved (success), Rejected (error)

---

## Step 6: Integrate into RentalOrderDetailScreen

**File**: `lib/features/orders/screens/rental_order_detail_screen.dart`

Add the `RentalExtensionCard` widget after the return evidence section,
before the chat section.

Around line 76 (after the return evidence section), add:

```dart
// Rental extension section — show when rental is active
if (order.rentalStatus == 'active' ||
    order.rentalStatus == 'return_requested') ...[
  RentalExtensionCard(
    order: order,
    isBuyer: isBuyer,
    isSeller: isSeller,
  ),
  const SizedBox(height: 16),
],
```

Also show extension history for already-processed extensions even in
later statuses (returned, completed):
```dart
// Always show extension history if any exist
RentalExtensionCard(
  order: order,
  isBuyer: isBuyer,
  isSeller: isSeller,
),
const SizedBox(height: 16),
```

Import the widget at the top of the file.

---

## Testing Checklist

1. SQL migration executes without errors
2. Freezed model generates correctly (`build_runner build`)
3. Buyer can see "Request Extension" button when rental is active
4. Buyer can select a new end date and see calculated price diff
5. Extension request appears in the card with "Pending" badge
6. Seller sees the pending request with Approve/Reject buttons
7. Seller approves → order end_date and total_price update
8. Seller rejects → rejection note displays, status shows "Rejected"
9. Notifications sent to seller on request, buyer on response
10. "Request Early Return" creates a shorten request
11. Extension history shows all past requests
12. Run `flutter analyze` — zero errors
13. Run `dart run build_runner build --delete-conflicting-outputs` — no errors

---

## Files summary

| File | Action |
|------|--------|
| `supabase/migrations/00026_rental_extensions.sql` | CREATE + EXECUTE via `./db.sh` |
| `lib/data/models/rental_extension.dart` | CREATE |
| `lib/data/repositories/rental_extension_repository.dart` | CREATE |
| `lib/features/orders/providers/rental_extension_provider.dart` | CREATE |
| `lib/features/orders/widgets/rental_extension_card.dart` | CREATE |
| `lib/features/orders/screens/rental_order_detail_screen.dart` | MODIFY — add extension card |
