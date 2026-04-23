# Task 022: Phase 2 — Fix RLS + Stats + Views + Cancel Lock + DM Button

## Overview
Phase 2 consolidation: 5 items in one batch since most share DB-level fixes.

---

## Part A: Fix Transaction Management RLS (Bug #7)

### 问题分析
`saved_listings` 表的 RLS 策略只允许 `auth.uid() = user_id`（即只有收藏者本人能看到自己的收藏记录）。
当卖家调用 `fetchSavedByListing(listingId)` 时，RLS 拒绝了卖家的查询，因为卖家不是收藏者。

`orders` 表的 RLS 已经允许 `buyer_id` 或 `seller_id` 读取，所以 Orders tab 应该没问题。
但 Saves tab 一定是空的。

### 修复：SQL migration

Create `supabase/migrations/00023_phase2_rls_stats_views.sql`:

```sql
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
```

**⚠️ USER 需手动执行此 SQL。**

---

## Part B: Record Listing Views in App (Flutter)

### B1. Add table constant

In `lib/core/constants/app_constants.dart`, add:
```dart
  static const String tableListingViews = 'listing_views';
```

### B2. Add repository method

In `lib/data/repositories/listing_repository.dart`, add this method:

```dart
  /// Records a view event for a listing.
  /// Silently fails if the insert errors (non-critical).
  Future<void> recordView({
    required String listingId,
    String? viewerId,
  }) async {
    try {
      final data = <String, dynamic>{
        'listing_id': listingId,
      };
      if (viewerId != null) {
        data['viewer_id'] = viewerId;
      }
      await _client
          .from(AppConstants.tableListingViews)
          .insert(data);
    } on PostgrestException catch (_) {
      // Non-critical — don't crash the app if view tracking fails
    }
  }
```

### B3. Call recordView in listing detail provider

In `lib/features/listing/providers/listing_detail_provider.dart`:

Find the `listingDetail` provider's build method. After successfully
fetching the listing, add a fire-and-forget view recording call:

```dart
  // Fire-and-forget view tracking
  final userId = ref.read(authStateProvider).valueOrNull?.id;
  ref.read(listingRepositoryProvider).recordView(
    listingId: id,
    viewerId: userId,
  );
```

This must be placed AFTER the listing is fetched, not inside the return.
Use a `.then()` pattern or add it before returning:

```dart
@riverpod
Future<Listing> listingDetail(Ref ref, String id) async {
  final repo = ref.watch(listingRepositoryProvider);
  final listing = await repo.fetchListing(id);

  // Fire-and-forget: record this view for analytics
  final userId = ref.read(authStateProvider).valueOrNull?.id;
  repo.recordView(listingId: id, viewerId: userId);

  return listing;
}
```

Make sure `authStateProvider` is imported.

---

## Part C: Views Tab in Transaction Management

### C1. Add provider for listing views

Create `lib/features/seller/providers/listing_views_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

part 'listing_views_provider.g.dart';

/// A single view event with optional viewer profile.
class ListingView {
  const ListingView({
    required this.id,
    required this.listingId,
    this.viewerName,
    this.viewerAvatarUrl,
    required this.viewedAt,
  });

  final String id;
  final String listingId;
  final String? viewerName;
  final String? viewerAvatarUrl;
  final DateTime viewedAt;
}

@riverpod
Future<List<ListingView>> listingViews(Ref ref, String listingId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final data = await client
        .from(AppConstants.tableListingViews)
        .select('*, viewer:user_profiles!viewer_id(display_name, avatar_url)')
        .eq('listing_id', listingId)
        .order('viewed_at', ascending: false)
        .limit(100);

    return data.map((json) => ListingView(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      viewerName: (json['viewer'] as Map<String, dynamic>?)?['display_name'] as String?,
      viewerAvatarUrl: (json['viewer'] as Map<String, dynamic>?)?['avatar_url'] as String?,
      viewedAt: DateTime.parse(json['viewed_at'] as String),
    )).toList();
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}
```

### C2. Replace Views tab placeholder

In `lib/features/seller/screens/transaction_management_screen.dart`,
find the Views tab content (likely a placeholder/Center widget) and
replace with a list showing view events.

Read the file first to find the exact placeholder, then replace with:
- A `ref.watch(listingViewsProvider(listingId))` call
- A ListView showing viewer name (or "Anonymous"), avatar, and time
- Show total view count at the top

---

## Part D: Cancel Lockout After Delivery Confirmation

In `lib/features/orders/screens/order_detail_screen.dart`:

Find the Cancel button section. Add a condition to hide/disable it
when delivery has been confirmed by either party.

Logic:
```dart
// Hide cancel button if either party has confirmed delivery
final canCancel = order.status == 'pending' ||
    (order.status == 'confirmed' &&
     !order.deliveryConfirmedByBuyer &&
     !order.deliveryConfirmedBySeller);
```

Only show the Cancel button when `canCancel` is true.

---

## Part E: DM Button in Transaction Management

In the Orders tab of `transaction_management_screen.dart`:

For each order row, add a message icon button that navigates to the
chat room with that buyer.

Logic:
```dart
IconButton(
  icon: const Icon(Icons.chat_outlined),
  onPressed: () async {
    // Find or create chat room for this listing + buyer
    final chatRepo = ref.read(chatRepositoryProvider);
    final room = await chatRepo.findOrCreateChatRoom(
      listingId: listingId,
      buyerId: order.buyerId,
      sellerId: currentUserId,
    );
    if (context.mounted) {
      context.pushNamed(
        AppRoutes.chatRoom,
        pathParameters: {'id': room.id},
      );
    }
  },
)
```

Check if `findOrCreateChatRoom` exists in `chat_repository.dart`.
If not, add it.

---

## Execution Order

1. Create SQL file → **USER executes manually**
2. Part B: listing_repository.dart + listing_detail_provider.dart + app_constants
3. Part C: listing_views_provider.dart + update transaction_management_screen
4. Part D: order_detail_screen.dart cancel lockout
5. Part E: transaction_management_screen.dart DM button
6. Run `dart run build_runner build --delete-conflicting-outputs`
7. Run `flutter analyze`

Report to `.agent/reports/report-022.md`
