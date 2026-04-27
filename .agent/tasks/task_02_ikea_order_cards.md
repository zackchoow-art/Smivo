# Task 02 — IKEA-Themed Square Order Cards for Buyer Center & Seller Center

## Assigned Agent
Sonnet 4.6 Thinking

## Status
DONE

## Objective
Create IKEA-theme square order card widgets for Buyer Center and Seller
Center. Both screens already have a default Teal-theme horizontal card
layout. When the IKEA theme is active, all section cards must switch to
new IKEA-themed square (grid-style) cards.

---

## Theme Detection Helper
IKEA theme is detected by checking:
```dart
final isIkea = context.smivoColors.primary == const Color(0xFF004181);
```
Use this check wherever theme-conditional rendering is needed.

---

## Reference: IKEA Grid Card Style (from `ikea_grid_listing_card.dart`)

The IKEA card visual style:
- White background (`colors.surfaceContainerLowest`)
- `BorderRadius.circular(radius.card)` corners
- `shadows.card` box shadow
- `Clip.antiAlias` clip
- Square `AspectRatio(aspectRatio: 1)` image at the top
- Info section below image with `padding: EdgeInsets.all(10)`
- Title and price on same row, `labelLarge` style
- Description in `bodySmall` with `onSurfaceVariant` color
- Location row with pin icon if available

---

## Files to Create

### 1. `lib/features/buyer/widgets/ikea_buyer_order_card.dart`

A square IKEA-style card for buyer orders.

**Layout (vertical column inside a square-ish container):**
```
┌──────────────────────────────┐
│ [Product Image — AspectRatio]│  ← same as IkeaGridListingCard
│  status chip (top-right)     │
│  unread dot (top-left)       │
├──────────────────────────────┤
│ [Product Title]    [Price]   │  ← Row: title + price
│ [Seller name / location]     │  ← bodySmall onSurfaceVariant
│ [Date string]                │  ← labelSmall faded
└──────────────────────────────┘
```

**Constructor parameters:**
```dart
const IkeaBuyerOrderCard({
  super.key,
  required this.order,         // dynamic (Order model)
  required this.sectionTitle,  // String — which section it's in
  required this.hasUnread,     // bool
  required this.onTap,         // VoidCallback
});
```

**Data to display (mirrors default Teal card in buyer_center_screen.dart):**
- Image: `order.listing?.images.first.imageUrl` (fallback: surfaceContainerHigh + icon)
- Title: `order.listing?.title ?? 'Order'`
- Price: `\$${order.totalPrice.toStringAsFixed(0)}`
- Seller or location:
  - If `sectionTitle == 'Awaiting Delivery'`: `order.pickupLocation?.name ?? 'Unknown location'`
  - Otherwise: `order.seller?.displayName ?? 'Seller'`
- Date: `DateFormat('M/d HH:mm').format(order.createdAt)`
- Status chip: Use the same `_StatusChip` logic but as an inline widget
  - Pending → orange chip 'Pending'
  - Awaiting Delivery → primary chip 'Pickup'
  - Active → green chip 'Active'
  - Returning → warning chip 'Returning'
  - Done → green chip 'Done'
  - Cancelled → red chip 'Missed'
- Unread dot: red circle (8x8) at image top-left if `hasUnread == true`

**Status chip colors** (same as `_StatusChip._resolveChip` in buyer_center_screen.dart):
```dart
'pending'   → (colors.statusPending,   Colors.white, 'Pending')
'confirmed' → depends on delivery state and rentalStatus (see buyer_center_screen.dart _confirmedChip)
'completed' → (colors.success,         Colors.white, 'Done')
'cancelled' → (colors.statusCancelled, Colors.white, 'Missed')
```

**Interactions (same as default Teal card):**
- `onTap`: call the provided `onTap` callback (navigates to order detail)

---

### 2. `lib/features/seller/widgets/ikea_seller_order_card.dart`

A square IKEA-style card for seller orders and listings.

The Seller Center has 4 section types, each needing a different card variant.
Use a required enum or string `cardType` parameter to switch layout:

```dart
enum IkeaSellerCardType { activeListing, awaitingDelivery, activeTransaction, history }

const IkeaSellerOrderCard({
  super.key,
  required this.cardType,
  this.order,           // dynamic Order? — null for activeListing
  this.listing,         // dynamic Listing? — for activeListing
  this.historyItem,     // _HistoryItem? — for history  
  required this.hasUnread,   // bool (false for listing/history)
  required this.onTap,       // VoidCallback (primary action)
  this.onSecondaryTap,       // VoidCallback? (for listing → listing detail)
});
```

**Card layout per type:**

#### `activeListing`:
```
┌──────────────────────────────┐
│ [Listing Image — square]     │
├──────────────────────────────┤
│ [Title]          [Price]     │
│ [Type: Sale/Rental]          │
│ [👁 N]  [🔖 N]  [🏷 N]      │ ← 3 icon-stat buttons, same navigation as Teal
└──────────────────────────────┘
```
- Image: `listing.images.first.imageUrl`
- Title: `listing.title`
- Price: `\$${listing.price.toStringAsFixed(0)}`
- Type label: `listing.transactionType`
- Stats: viewCount, saveCount, inquiryCount (tappable icons)
  - Each icon tap navigates to TransactionManagement with tab 0/1/2

#### `awaitingDelivery`:
```
┌──────────────────────────────┐
│ [Product Image]              │
│  [unread dot top-left]       │
├──────────────────────────────┤
│ [Title]           [Price]    │
│ [Location]                   │
│ [Awaiting Delivery chip]     │
└──────────────────────────────┘
```
- Chip: `colors.primary` background, 'Awaiting\nDelivery' text in white

#### `activeTransaction`:
```
┌──────────────────────────────┐
│ [Buyer Avatar — square crop] │
│  [unread dot top-left]       │
├──────────────────────────────┤
│ [Listing Title]              │
│ [Price · Buyer Name]         │
│ [Status chip] [timestamps]   │
└──────────────────────────────┘
```
- Left tap → listing detail
- Right area tap → order detail (via `onTap`)
- Status chip text = `statusLabel` string parameter

#### `history`:
```
┌──────────────────────────────┐
│ [Image or fallback]          │
├──────────────────────────────┤
│ [Title]                      │
│ [Subtitle (price or status)] │
│ [Done/Cancelled chip]        │
│ [Date]                       │
└──────────────────────────────┘
```

---

## Files to Modify

### 3. `lib/features/buyer/screens/buyer_center_screen.dart`

In `_buildSection(...)`:
- After resolving `colors`, add IKEA theme check:
  ```dart
  final isIkea = colors.primary == const Color(0xFF004181);
  ```
- In `SliverChildBuilderDelegate` builder, replace the existing
  `InkWell(... Container(Row(...)))` card block with:
  ```dart
  if (isIkea)
    IkeaBuyerOrderCard(
      order: order,
      sectionTitle: title,
      hasUnread: hasUnread,
      onTap: () => _handleOrderTap(order.id, hasUnread),
    )
  else
    // ... existing default card ...
  ```
- Add import: `import 'package:smivo/features/buyer/widgets/ikea_buyer_order_card.dart';`
- When `isIkea`, change the `SliverList` to a `SliverGrid` with 2 columns:
  ```dart
  SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.78,
    ),
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        // ... IkeaBuyerOrderCard ...
      },
      childCount: orders.length,
    ),
  )
  ```

### 4. `lib/features/seller/screens/seller_center_screen.dart`

Same pattern per section:
- Add IKEA theme check at top of each section builder
- Replace `_buildActiveListingCard`, `_buildAwaitingDeliveryCard`,
  `_buildOrderCard`, and the History inline card with IKEA variant
- Change `SliverList` to `SliverGrid` (2 columns, same delegate as above)
  when `isIkea`
- The History section uses `SliverList` with `IkeaSellerOrderCard(cardType: IkeaSellerCardType.history, ...)`
- Add import: `import 'package:smivo/features/seller/widgets/ikea_seller_order_card.dart';`

**Note on activeTransaction card**: The `statusLabel` String is already computed
in the existing `SliverChildBuilderDelegate` — pass it through to `IkeaSellerOrderCard`.
The `_HistoryItem` class lives inside `seller_center_screen.dart`; you can
pass `_HistoryItem` as `dynamic` to the card widget.

---

## Strict Boundaries — DO NOT:
- Modify any file not listed in "Files to Modify/Create" above.
- Change existing Teal-theme card logic — only add the `if (isIkea)` branch.
- Remove any existing import, widget, helper method, or class.
- Change navigation logic (AppRoutes calls stay identical).
- Run `build_runner` or `flutter pub get`.
- Rename any existing method, class, or provider.

---

## Validation
After completing all changes, run:
```
flutter analyze
```
There must be zero **errors**. Info-level warnings are acceptable.

---

## Report
Write the execution report to:
`.agent/reports/task_02_report.md`

Report must include:
- List of all files created and modified (with line-count diff)
- Summary of each card variant implemented
- Full output of `flutter analyze`
- Status: DONE / FAILED
- Any design decisions made and why
