# Task 007: Optimize Manage Transactions Page

## Overview

Redesign the Manage Transactions page for better UX: rename tabs, unify card
layout across all three tabs, make listing detail stats clickable for direct
navigation, and implement the Accept order flow.

---

## Changes Required

### 1. Rename "Orders" → "Offers" everywhere

**Files to modify:**

#### `lib/features/seller/screens/transaction_management_screen.dart`
- Change tab label from `'Orders'` to `'Offers'` (line 27)
- Rename `_OrdersTab` class to `_OffersTab`
- Update all internal references

#### `lib/features/listing/screens/listing_detail_screen.dart`
- Change `'Inquiries'` to `'Offers'` in the stats section (line 185)
- The stat field `listing.inquiryCount` stays — just the display label changes

#### `lib/features/seller/providers/transaction_stats_provider.dart`
- If there are any references to "orders" or "inquiries" in display strings,
  rename to "offers"

---

### 2. Add `initialTab` support to TransactionManagementScreen

The screen needs to accept an optional tab index so clicking a specific stat
card navigates directly to that tab.

#### `lib/features/seller/screens/transaction_management_screen.dart`

Add `initialTab` parameter:

```dart
class TransactionManagementScreen extends ConsumerWidget {
  const TransactionManagementScreen({
    super.key,
    required this.listingId,
    this.initialTab = 0,
  });
  final String listingId;
  final int initialTab;
  // ...
  DefaultTabController(
    length: 3,
    initialIndex: initialTab,
    // ...
  )
}
```

#### `lib/core/router/router.dart`

Pass `initialTab` from query parameter:

```dart
GoRoute(
  name: AppRoutes.transactionManagement,
  path: AppRoutes.transactionManagementPath,
  builder: (context, state) => TransactionManagementScreen(
    listingId: state.pathParameters['id']!,
    initialTab: int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0,
  ),
),
```

---

### 3. Make listing detail stat cards clickable

#### `lib/features/listing/screens/listing_detail_screen.dart`

**Remove** the "Manage Transactions" OutlinedButton (lines 188–196).

**Make each `_StatCard` clickable** — wrap with `GestureDetector` and navigate
to the transaction management screen with the corresponding tab index:

```dart
Row(children: [
  _StatCard(
    icon: Icons.visibility_outlined, label: 'Views',
    count: listing.viewCount,
    onTap: () => context.pushNamed(
      AppRoutes.transactionManagement,
      pathParameters: {'id': listing.id},
      queryParameters: {'tab': '0'},
    ),
  ),
  const SizedBox(width: 12),
  _StatCard(
    icon: Icons.bookmark_outline, label: 'Saves',
    count: listing.saveCount,
    onTap: () => context.pushNamed(
      AppRoutes.transactionManagement,
      pathParameters: {'id': listing.id},
      queryParameters: {'tab': '1'},
    ),
  ),
  const SizedBox(width: 12),
  _StatCard(
    icon: Icons.local_offer_outlined, label: 'Offers',
    count: listing.inquiryCount,
    onTap: () => context.pushNamed(
      AppRoutes.transactionManagement,
      pathParameters: {'id': listing.id},
      queryParameters: {'tab': '2'},
    ),
  ),
]),
```

Update `_StatCard` to accept `onTap`:

```dart
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Wrap with GestureDetector, keep existing design
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: Container(/* existing layout */),
    ));
  }
}
```

---

### 4. Redesign card layout — unified across all three tabs

All three tabs (Views, Saves, Offers) must use the **same card layout**:

```
┌─────────────────────────────────────────────┐
│  [Avatar]  Name             [Chat] [Status] │
│            ★★★★☆ (placeholder)              │
│            Apr 23, 2026 3:45 PM             │
│                                             │
│            (Offers tab only:)               │
│            $120      [Accept Button]        │
└─────────────────────────────────────────────┘
```

**Card content for ALL tabs:**
- Left: `CircleAvatar` with user icon (or avatar image if available)
- Name: Viewer/Saver/Buyer display name
- Rating: Show `★★★★☆` as placeholder text (hardcoded "★★★★☆ 4.0")
- Timestamp: "Viewed on ...", "Saved on ...", or "Submitted on ..."
- Chat button: Opens `showChatPopup()` (import from `chat_popup.dart`)
- Status chip: colored badge (only for Offers tab)

**Additional for Offers tab only:**
- Price display: `$totalPrice`
- Accept button

#### Styling guidance

The theme extension null crash has been fixed (`theme_extensions.dart` now uses
`?? .teal()` fallback instead of `!`). You **can** use `context.smivoColors`,
`context.smivoTypo`, `context.smivoRadius` in all three tabs.

However, for the **Offers tab card builder specifically**, prefer using
`Container` with `BoxDecoration` instead of `Card` widget, and
`GestureDetector` with styled `Container` instead of `ElevatedButton`,
as an extra precaution against Material widget internal theme issues.

Use the same theme tokens that Views and Saves tabs use for consistency.

---

### 5. Accept button flow

When the seller taps Accept on an offer:

1. Show a confirmation dialog: "Accept this offer from [buyer name]?"
2. On confirm:
   a. Call `ref.read(orderActionsProvider.notifier).acceptOrder(orderId)`
   b. **Set all OTHER pending orders for this listing to "cancelled"** with
      a note "missed" — this requires a new repository method:

```dart
/// In OrderRepository:
Future<void> cancelOtherPendingOrders(String listingId, String acceptedOrderId) async {
  await _client
    .from(AppConstants.tableOrders)
    .update({'status': 'cancelled'})
    .eq('listing_id', listingId)
    .eq('status', 'pending')
    .neq('id', acceptedOrderId);
}
```

   c. Navigate back to Seller Center:
      `context.goNamed(AppRoutes.sellerCenter)`

3. Add the new method to `OrderActionsNotifier` or call it directly from
   the screen.

---

### 6. Chat button implementation for Offers tab

Use `showChatPopup` from `chat_popup.dart`. For each order card:

```dart
import 'package:smivo/features/chat/widgets/chat_popup.dart';

// In the chat button onPressed:
onPressed: () async {
  final currentUserId = ref.read(authStateProvider).valueOrNull?.id;
  if (currentUserId == null) return;
  final chatRepo = ref.read(chatRepositoryProvider);
  final room = await chatRepo.getOrCreateChatRoom(
    listingId: order.listingId,
    buyerId: order.buyerId,
    sellerId: order.sellerId,
  );
  if (!context.mounted) return;
  showChatPopup(
    context,
    chatRoomId: room.id,
    otherUserName: order.buyer?.displayName ?? 'Buyer',
    otherUserAvatar: order.buyer?.avatarUrl,
    listingTitle: order.listing?.title ?? '',
    listingPrice: order.totalPrice,
    listingImageUrl: order.listing?.images?.firstOrNull?.imageUrl,
  );
},
```

For Views and Saves tabs, the chat button needs the viewer/saver's user ID
to create or find a chat room. This requires knowing the listing's seller ID.
If the data model doesn't include enough info, use a simple `IconButton` that
navigates to the full chat room page instead:

```dart
// Fallback for Views/Saves where we may not have full chat context:
IconButton(
  icon: const Icon(Icons.chat_outlined, size: 20),
  onPressed: () {
    // Navigate to chat list or show a "Message" snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat coming soon')),
    );
  },
),
```

---

## Files to modify (summary)

| File | Changes |
|------|---------|
| `lib/features/seller/screens/transaction_management_screen.dart` | Rename Orders→Offers, redesign all cards, add initialTab, implement Accept flow |
| `lib/features/listing/screens/listing_detail_screen.dart` | Rename Inquiries→Offers, make stats clickable, remove Manage Transactions button |
| `lib/core/router/router.dart` | Pass initialTab query parameter |
| `lib/data/repositories/order_repository.dart` | Add `cancelOtherPendingOrders` method |
| `lib/features/orders/providers/orders_provider.dart` | Expose cancel-others method in provider (if needed) |

## Testing

After implementation, verify:
1. Clicking each stat card (Views/Saves/Offers) on listing detail navigates
   to the correct tab
2. The "Manage Transactions" button is removed from listing detail
3. All three tabs show cards with unified layout
4. Offers tab shows Accept button for pending orders
5. Accept flow: confirms dialog → accepts order → cancels others → goes to seller center
6. Chat popup opens correctly from Offers tab cards
7. No `Unexpected null value` errors — verify by testing in Chrome AND iOS simulator
