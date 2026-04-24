# Task 012a: Seller Center Refactor — Sections + History Merge

## Pre-requisites
- Read `.agent/docs/theme-architecture.md` for styling rules
- Read `lib/features/seller/screens/seller_center_screen.dart` FULLY before modifying
- Read `lib/features/seller/providers/seller_center_provider.dart` FULLY before modifying
- Use ONLY theme tokens, NO hardcoded colors

---

## Overview

Refactor Seller Center from 3 sections to 4, plus implement smart History
merge logic for cancelled orders.

---

## Current Sections (3)

1. **ACTIVE LISTINGS** — listings with `status == 'active'`
2. **ACTIVE TRANSACTIONS** — orders with `status == 'confirmed'` or rental in progress
3. **HISTORY** — completed + cancelled orders + delisted listings

## Target Sections (4)

1. **ACTIVE LISTINGS** — no change
2. **AWAITING DELIVERY** — NEW section  
3. **ACTIVE TRANSACTIONS** — narrowed scope
4. **HISTORY** — smart merge logic

---

## Step 1: Seller Center Provider Updates

**File**: `lib/features/seller/providers/seller_center_provider.dart`

Check if `sellerOrdersProvider` fetches orders with the necessary fields.
It must include: `status`, `orderType`, `rentalStatus`, `listingId`,
`deliveryConfirmedByBuyer`, `deliveryConfirmedBySeller`, `listing`, `buyer`.

No changes needed if it already fetches all seller orders.

---

## Step 2: Seller Center Screen — Section Split

**File**: `lib/features/seller/screens/seller_center_screen.dart`

### Section 2: AWAITING DELIVERY (NEW)

Filter: Orders where the seller has accepted (confirmed) but delivery is NOT
yet complete.

```dart
final awaitingDelivery = orders.where((o) =>
  o.status == 'confirmed' &&
  !(o.deliveryConfirmedByBuyer && o.deliveryConfirmedBySeller)
).toList();
```

**UI**: Same card style as current Active Transactions. Each card shows:
- Buyer avatar + name
- Listing title + price
- Status badge: "Awaiting Pickup" (for sale) or "Awaiting Delivery" (for rental)
- Tap → order detail

**Position**: Between ACTIVE LISTINGS and ACTIVE TRANSACTIONS.

### Section 3: ACTIVE TRANSACTIONS (narrowed)

Filter: Only rental orders that have passed delivery confirmation
(rentalStatus is active, return_requested, or returned).

```dart
final activeTransactions = orders.where((o) =>
  o.status == 'confirmed' &&
  (o.rentalStatus == 'active' ||
   o.rentalStatus == 'return_requested' ||
   o.rentalStatus == 'returned')
).toList();
```

**UI**: Same card style. Status badge shows the rental status.

### Section 4: HISTORY — Smart Merge Logic

This is the most complex part. The history section needs smart grouping.

#### Rules:

1. **Completed orders**: Show individually as before.

2. **Cancelled orders with an active/confirmed sibling**: 
   If a listing has both cancelled orders AND a confirmed/completed order,
   **DO NOT** show the cancelled ones. They will appear after the transaction
   fully resolves.

3. **Cancelled orders (all cancelled for a listing)**:
   If a listing has ONLY cancelled orders (e.g., seller delisted and all
   pending orders were cancelled), **merge into 1 card** per listing.
   
4. **Delisted listings**: Show individually as before.

#### Implementation:

```dart
// Group cancelled orders by listingId
final cancelledByListing = <String, List<Order>>{};
final nonCancelled = <Order>[];

for (final o in orders) {
  if (o.status == 'cancelled') {
    cancelledByListing.putIfAbsent(o.listingId, () => []).add(o);
  } else if (o.status == 'completed') {
    nonCancelled.add(o);
  }
}

// Check if any listing with cancelled orders also has active/confirmed orders
final listingsWithActiveOrder = orders
    .where((o) => o.status == 'confirmed' || o.status == 'completed')
    .map((o) => o.listingId)
    .toSet();

final historyItems = <_HistoryItem>[];

// Add completed orders
for (final o in nonCancelled) {
  historyItems.add(_HistoryItem(
    title: o.listing?.title ?? 'Order',
    subtitle: '\$${o.totalPrice.toStringAsFixed(0)} · Completed',
    isCompleted: true,
    onTap: () => navigateToOrderDetail(o.id),
  ));
}

// Add merged cancelled groups (only if no active sibling)
for (final entry in cancelledByListing.entries) {
  if (listingsWithActiveOrder.contains(entry.key)) {
    // Skip — will show after the active order resolves
    continue;
  }
  
  final orders = entry.value;
  final listing = orders.first.listing;
  final title = listing?.title ?? 'Listing';
  
  historyItems.add(_HistoryItem(
    title: title,
    subtitle: '${orders.length} offer(s) cancelled',
    isCompleted: false,
    isMergedCancelled: true,
    mergedOrders: orders,
    onTap: () => _showMergedCancelledDetails(context, listing, orders),
  ));
}

// Add delisted listings
for (final l in delistedListings) {
  historyItems.add(_HistoryItem(
    title: l.title,
    subtitle: 'Delisted',
    isCompleted: false,
    isDelisted: true,
    onTap: () => navigateToListingDetail(l.id),
  ));
}
```

#### Merged Cancelled Detail Dialog:

When user taps a merged cancelled card, show a dialog or bottom sheet:

```
┌──────────────────────────────────────┐
│ "Vintage Desk Lamp"                  │
│                                      │
│ 👁 12 Views · ❤️ 3 Saves · 📩 3 Offers │
│                                      │
│ All offers were cancelled when you   │
│ delisted this item.                  │
│                                      │
│              [Close]                 │
└──────────────────────────────────────┘
```

- Views: from `listing.viewCount`
- Saves: from `listing.saveCount`
- Offers: length of the cancelled orders group

---

## Step 3: Update _HistoryItem class

The existing `_HistoryItem` class needs new fields:

```dart
class _HistoryItem {
  const _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isDelisted = false,
    this.isMergedCancelled = false,
    this.mergedOrders,
    this.listing,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isDelisted;
  final bool isMergedCancelled;
  final List<Order>? mergedOrders;
  final Listing? listing;
  final VoidCallback? onTap;
}
```

Update the leading icon for merged cancelled items:
- Icon: `Icons.playlist_remove` with `warning` color background

---

## Testing Checklist

1. Sale order: after accept → listing status = 'sold' → gone from home feed ✅
2. Sale order: listing detail hides delist button ✅ (already conditional on 'active')
3. Rental order: after accept → listing stays active on home feed ✅
4. Rental order: after both confirm delivery → listing status = 'rented' → gone ✅
5. Seller Center: "AWAITING DELIVERY" shows accepted but undelivered orders
6. Seller Center: "ACTIVE TRANSACTIONS" only shows active rentals
7. History: 3 cancelled orders from same listing → 1 merged card
8. History: cancelled orders with an active sibling → hidden
9. History: tap merged card → shows views/saves/offers stats
10. History: completed orders show individually
11. `flutter analyze` — zero errors

---

## Files summary

| File | Action |
|------|--------|
| `lib/features/seller/screens/seller_center_screen.dart` | MODIFY — 4 sections + history merge |
