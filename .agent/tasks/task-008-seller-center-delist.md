# Task 008: Seller Center Redesign + Delist Button

## Overview

Three areas of work:
1. Enhance Seller Center listing cards with Saves/Offers counts + clickable stats
2. Reorganize Seller Center into 3 sections: Active Listings, Active Transactions, History
3. Add "Delist" button on listing detail page (own listings only)

---

## 1. Seller Center — Enhanced Active Listing Cards

### File: `lib/features/seller/screens/seller_center_screen.dart`

**Current state**: Each listing card shows only `viewCount` in trailing.

**New card design** — replace the current `Card > ListTile` with a richer layout:

```
┌──────────────────────────────────────────────┐
│ [Image]  Title                               │
│          $price · sale/rent                  │
│                                              │
│   👁 12 Views    🔖 5 Saves    🏷 3 Offers   │
└──────────────────────────────────────────────┘
```

**Behavior:**
- Tapping the **card body** (image, title, price area) → navigates to listing detail:
  `context.pushNamed(AppRoutes.listingDetail, pathParameters: {'id': listing.id})`
- Tapping **Views** → navigates to manage transactions tab 0:
  `context.pushNamed(AppRoutes.transactionManagement, pathParameters: {'id': listing.id}, queryParameters: {'tab': '0'})`
- Tapping **Saves** → tab 1
- Tapping **Offers** → tab 2

**Implementation approach:**
- Use a `Container` with `BoxDecoration` (not `Card`) to avoid potential theme crash
- The top section (image + title + price) is wrapped in a `GestureDetector` → listing detail
- The bottom stat row has 3 individual `GestureDetector` areas → transaction management tabs
- Stats use `listing.viewCount`, `listing.saveCount`, `listing.inquiryCount`

---

## 2. Seller Center — Three Sections

### File: `lib/features/seller/screens/seller_center_screen.dart`

Reorganize the page into 3 sections:

### Section A: ACTIVE LISTINGS (existing, enhanced per above)
- Listings where `status == 'active'`
- No change to data source

### Section B: ACTIVE TRANSACTIONS (new)
- Orders where the seller has accepted (`status == 'confirmed'`) but delivery
  is NOT yet confirmed
- Rental orders that are currently active (`rental_status == 'active'`)
- Also includes: `rental_status == 'return_requested'` or `'returned'`

**Filter logic:**
```dart
final activeTransactions = orders.where((o) =>
  (o.status == 'confirmed') ||
  (o.rentalStatus == 'active') ||
  (o.rentalStatus == 'return_requested') ||
  (o.rentalStatus == 'returned')
).toList();
```

**Card design** — similar to current completed sales cards:
```
┌──────────────────────────────────────────────┐
│ [Status Icon]  Listing Title                 │
│                $total · Buyer Name            │
│                Status chip                    │
└──────────────────────────────────────────────┘
```

- Status icon: green circle for confirmed, blue for active rental
- Tapping card → order detail page
- Show buyer name from `order.buyer?.displayName`

### Section C: HISTORY (renamed from "COMPLETED SALES")
- Orders where `status == 'completed'` or `status == 'cancelled'`
- **Also include**: Delisted listings (listings with `status == 'cancelled'`)
  — show these as a separate subsection or mixed in with cancelled orders

**Current code already has this section** — just rename the label:
- `'COMPLETED SALES'` → `'HISTORY'`
- Keep existing card design

---

## 3. Listing Detail — Delist Button

### File: `lib/features/listing/screens/listing_detail_screen.dart`

**Location**: After the stats section, where the old "Manage Transactions"
button used to be (around line 214).

**Only visible when**: `isOwnListing == true` AND `listing.status == 'active'`

**Design:**
```dart
// Delist button — red outline, danger action
SizedBox(width: double.infinity, child: OutlinedButton.icon(
  onPressed: () => _showDelistDialog(context, ref, listing),
  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
  label: const Text('Delist This Item', style: TextStyle(color: Colors.red)),
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12),
    side: const BorderSide(color: Colors.red, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
)),
```

**Confirmation dialog:**
```dart
void _showDelistDialog(BuildContext context, WidgetRef ref, Listing listing) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delist Item'),
      content: Text('Are you sure you want to delist "${listing.title}"? '
        'This will cancel all pending offers and remove it from the marketplace.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Listed')),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            // 1. Update listing status to cancelled
            final listingRepo = ref.read(listingRepositoryProvider);
            await listingRepo.delistListing(listing.id);
            // 2. Cancel all pending orders for this listing
            final orderRepo = ref.read(orderRepositoryProvider);
            await orderRepo.cancelAllPendingOrders(listing.id);
            // 3. Navigate back
            if (context.mounted) {
              context.goNamed(AppRoutes.sellerCenter);
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delist'),
        ),
      ],
    ),
  );
}
```

### File: `lib/data/repositories/listing_repository.dart`

Add a new method:

```dart
/// Delists a listing by setting its status to 'cancelled'.
Future<void> delistListing(String id) async {
  try {
    await _client
        .from(AppConstants.tableListings)
        .update({'status': 'cancelled'})
        .eq('id', id);
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}
```

### File: `lib/data/repositories/order_repository.dart`

Add a method to cancel ALL pending orders (not just "other"):

```dart
/// Cancels all pending orders for a listing (used when delisting).
Future<void> cancelAllPendingOrders(String listingId) async {
  try {
    await _client
        .from(AppConstants.tableOrders)
        .update({'status': 'cancelled'})
        .eq('listing_id', listingId)
        .eq('status', 'pending');
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}
```

---

## Files to modify (summary)

| File | Changes |
|------|---------|
| `lib/features/seller/screens/seller_center_screen.dart` | Redesign listing cards (stats + split taps), add Active Transactions section, rename History |
| `lib/features/listing/screens/listing_detail_screen.dart` | Add Delist button with confirmation dialog |
| `lib/data/repositories/listing_repository.dart` | Add `delistListing()` method |
| `lib/data/repositories/order_repository.dart` | Add `cancelAllPendingOrders()` method |

## Important notes

- Use `context.smivoColors` / `context.smivoTypo` / `context.smivoRadius` for
  all styling (the theme fallback fix is in place)
- For listing cards in Seller Center, prefer `Container` over `Card` widget
- Read each file fully before modifying
- Run `flutter analyze` after completion

## Testing

1. Seller Center shows 3 sections: Active Listings, Active Transactions, History
2. Listing cards show Views, Saves, Offers counts
3. Tapping card body → listing detail; tapping stat → manage transactions tab
4. Delist button appears on own active listings
5. Delist confirmation dialog works, listing status changes, pending orders cancelled
6. Delisted item no longer appears in Active Listings
