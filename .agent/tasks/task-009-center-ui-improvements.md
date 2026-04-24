# Task 009: Seller/Buyer Center UI Improvements

## Overview

Four areas:
1. Seller Center card styling (background color + stats layout)
2. Seller Center list/card view toggle
3. Buyer Center same improvements
4. ~~Delist fix~~ (DONE — already fixed in this session)

**IMPORTANT**: Read `.agent/docs/theme-architecture.md` before starting.
Use ONLY theme tokens (`context.smivoColors`, `context.smivoTypo`,
`context.smivoRadius`) for all styling. NO hardcoded colors.

---

## 1. Seller Center — Card Background & Stats Layout

### File: `lib/features/seller/screens/seller_center_screen.dart`

#### 1a. Add card background color

Current cards have only a border with no fill, making them hard to see.
Add a background color from the theme system:

```dart
// Use surfaceContainerLow for card backgrounds — it provides subtle
// contrast against the page's surfaceContainerLowest background.
decoration: BoxDecoration(
  color: colors.surfaceContainerLow,          // <-- ADD THIS
  borderRadius: BorderRadius.circular(radius.card),
  border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
),
```

Apply this to ALL card containers in the screen:
- Active Listings cards
- Active Transactions cards
- History cards

#### 1b. Stats row — split number and label into two lines

Current: `👁 12 Views` (single line)

New layout — number on top, label below, each stat is a tappable column:

```dart
// Each stat button in the listing card footer:
GestureDetector(
  onTap: () => context.pushNamed(
    AppRoutes.transactionManagement,
    pathParameters: {'id': listing.id},
    queryParameters: {'tab': '0'},
  ),
  child: Column(children: [
    Icon(Icons.visibility_outlined, size: 16, color: colors.primary),
    const SizedBox(height: 2),
    Text('${listing.viewCount}',
      style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
    Text('Views',
      style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5))),
  ]),
),
```

Repeat for Saves (tab 1) and Offers (tab 2). Use `listing.saveCount` and
`listing.inquiryCount` respectively.

The three stats should be evenly spaced in a `Row` with `MainAxisAlignment.spaceAround`.

---

## 2. Seller Center — List/Card View Toggle

Add a toggle button in the header area (next to "ACTIVE LISTINGS" label)
that switches between card view and list view.

### State management

Use a simple local `StatefulWidget` or convert `SellerCenterScreen` from
`ConsumerWidget` to `ConsumerStatefulWidget` with a `bool _isListView` state:

```dart
class SellerCenterScreen extends ConsumerStatefulWidget {
  // ...
}

class _SellerCenterScreenState extends ConsumerState<SellerCenterScreen> {
  bool _isListView = false;
  // ...
}
```

### Toggle button

Place next to the section header:

```dart
Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  Text('ACTIVE LISTINGS', style: typo.labelSmall.copyWith(...)),
  IconButton(
    icon: Icon(_isListView ? Icons.grid_view : Icons.list, size: 20),
    onPressed: () => setState(() => _isListView = !_isListView),
  ),
]),
```

### Card mode (default, current)

Keep the current enhanced card layout (image + title + price + stats row).

### List mode

A compact row layout for each listing:

```dart
Container(
  margin: const EdgeInsets.only(bottom: 8),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    color: colors.surfaceContainerLow,
    borderRadius: BorderRadius.circular(radius.sm),
  ),
  child: Row(children: [
    // Thumbnail
    ClipRRect(
      borderRadius: BorderRadius.circular(radius.image),
      child: Image.network(imageUrl, width: 40, height: 40, fit: BoxFit.cover),
    ),
    const SizedBox(width: 12),
    // Title + price
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(listing.title, style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1, overflow: TextOverflow.ellipsis),
      Text('\$${listing.price.toStringAsFixed(0)} · ${listing.transactionType}',
        style: typo.bodySmall),
    ])),
    // Mini stats
    Row(mainAxisSize: MainAxisSize.min, children: [
      _MiniStat(icon: Icons.visibility_outlined, count: listing.viewCount,
        onTap: () => /* navigate tab 0 */),
      const SizedBox(width: 8),
      _MiniStat(icon: Icons.bookmark_outline, count: listing.saveCount,
        onTap: () => /* navigate tab 1 */),
      const SizedBox(width: 8),
      _MiniStat(icon: Icons.local_offer_outlined, count: listing.inquiryCount,
        onTap: () => /* navigate tab 2 */),
    ]),
  ]),
)
```

Tapping the card body → listing detail, tapping each mini stat → transaction tab.

Apply the same toggle to Active Transactions and History sections.

---

## 3. Buyer Center — Same Improvements

### File: `lib/features/buyer/screens/buyer_center_screen.dart`

Apply the SAME two improvements:

### 3a. Card background color

Currently uses `Card > ListTile`. Replace with `Container` using
`colors.surfaceContainerLow` as background:

```dart
Container(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: colors.surfaceContainerLow,
    borderRadius: BorderRadius.circular(radius.card),
  ),
  child: Row(children: [
    CircleAvatar(...),
    const SizedBox(width: 12),
    Expanded(child: Column(...)),
    _StatusChip(status: order.status),
  ]),
)
```

### 3b. List/Card view toggle

Same pattern as Seller Center:
- Convert to `ConsumerStatefulWidget`
- Add toggle button in header
- Card mode: current layout with background fix
- List mode: compact single-line row

### 3c. Card content should show

For each order card:
- Listing image thumbnail (from `order.listing?.images`)
- Listing title
- Price + order type
- Seller name (`order.seller?.displayName` if available, else 'Seller')
- Status chip
- Tap → order detail

---

## Files to modify

| File | Changes |
|------|---------|
| `lib/features/seller/screens/seller_center_screen.dart` | Background color, stats two-line layout, list/card toggle |
| `lib/features/buyer/screens/buyer_center_screen.dart` | Background color, list/card toggle, Container replaces Card |

## Rules

- Use ONLY theme tokens — NO hardcoded colors
- Import `theme_extensions.dart` for `context.smivoColors` etc.
- Use `colors.surfaceContainerLow` for card backgrounds
- Use `radius.card` for card corners, `radius.image` for image thumbnails
- Read each file fully before modifying
- Run `flutter analyze` after completion — must be zero errors

## Testing

1. Seller Center: cards have visible background color
2. Stats show number above label in two lines
3. Toggle button switches between card and list view in all sections
4. Buyer Center: same card background + list/card toggle
5. All taps navigate correctly (listing detail, transaction tabs, order detail)
6. Theme switching (teal ↔ ikea) works correctly with new layouts
