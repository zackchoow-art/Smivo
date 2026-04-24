# Task 010a: UI & Flow Optimization — Batch 1 (P0)

## Pre-requisites
- Read `.agent/docs/theme-architecture.md` for styling rules
- Use ONLY theme tokens, NO hardcoded colors
- Read each target file fully before modifying

---

## 1. Accept 后跳转到 Order Detail（而非 Seller Center）

### File: `lib/features/seller/screens/transaction_management_screen.dart`

**Line ~333**: Change the Accept success navigation from:
```dart
context.goNamed(AppRoutes.sellerCenter);
```
To:
```dart
context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id});
```

This ensures the seller lands on Order Detail to continue the next step
(confirm delivery, etc.) after accepting a buyer.

---

## 2. Seller Center — Active Transactions 卡片点击目标

### File: `lib/features/seller/screens/seller_center_screen.dart`

In the **ACTIVE TRANSACTIONS** section, find the `ListTile.onTap` that
currently navigates to listing detail. It should already navigate to
order detail — verify the `onTap` callback:

```dart
onTap: () => context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id}),
```

NOT listing detail. If it goes to listing detail, fix it.

---

## 3. 产品详情页 — 买家申请卡片增强 + Cancel 按钮

### File: `lib/features/listing/screens/listing_detail_screen.dart`

**Location**: Around line 268–280, the "Application Submitted" container.

**Current code** (line 270–280):
```dart
return Container(
  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
  decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.card)),
  child: Column(children: [
    Icon(Icons.check_circle, color: colors.success, size: 28),
    const SizedBox(height: 4),
    Text('Application Submitted', style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(submittedDate, style: typo.bodySmall.copyWith(color: colors.outlineVariant)),
  ]),
);
```

**Replace with** (add price info + Cancel button):

```dart
return Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: colors.surfaceContainerLow,
    borderRadius: BorderRadius.circular(radius.card),
  ),
  child: Column(children: [
    Icon(Icons.check_circle, color: colors.success, size: 28),
    const SizedBox(height: 4),
    Text('Application Submitted',
      style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(submittedDate,
      style: typo.bodySmall.copyWith(color: colors.outlineVariant)),
    const SizedBox(height: 8),
    // Price display — different format for sale vs rental
    if (order.orderType == 'rental') ...[
      Text(
        _formatRentalSummary(order),
        style: typo.bodyMedium.copyWith(
          color: colors.primary, fontWeight: FontWeight.w600),
      ),
    ] else ...[
      Text(
        '\$${order.totalPrice.toStringAsFixed(0)}',
        style: typo.titleMedium.copyWith(
          color: colors.primary, fontWeight: FontWeight.bold),
      ),
    ],
    // Cancel button — only for pending orders
    if (order.status == 'pending') ...[
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Cancel Application'),
                content: const Text(
                  'Are you sure you want to cancel your application?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Keep'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancel Application'),
                  ),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              await ref.read(orderActionsProvider.notifier)
                  .cancelOrder(order.id);
              if (context.mounted) Navigator.of(context).pop();
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.error,
            side: BorderSide(color: colors.error),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius.button)),
          ),
          child: const Text('Cancel Application'),
        ),
      ),
    ],
  ]),
);
```

**Add this helper method** inside the `_ListingDetailBody` class (or as
a top-level function):

```dart
String _formatRentalSummary(Order order) {
  final duration = order.rentalDuration ?? 1;
  final rateType = order.rentalRateType ?? 'DAY';
  final unitLabel = switch (rateType.toUpperCase()) {
    'DAY' => duration == 1 ? 'Day' : 'Days',
    'WEEK' => duration == 1 ? 'Week' : 'Weeks',
    'MONTH' => duration == 1 ? 'Month' : 'Months',
    _ => 'Days',
  };
  return '$duration $unitLabel, Total: \$${order.totalPrice.toStringAsFixed(0)}';
}
```

**NOTE**: Check if `Order` model has `rentalDuration` and `rentalRateType`
fields. If not, compute from `rentalStart`/`rentalEnd` dates, or display
just the total price.

**IMPORTANT**: You need to import `orderActionsProvider`:
```dart
import 'package:smivo/features/orders/providers/orders_provider.dart';
```

---

## 4. Evidence Photo 按钮显隐

### File: `lib/features/orders/screens/order_detail_screen.dart`

**Current code** (line 65):
```dart
EvidencePhotoSection(orderId: order.id, canUpload: order.status == 'confirmed' && (isBuyer || isSeller)),
```

**Replace with**:
```dart
EvidencePhotoSection(
  orderId: order.id,
  canUpload: _canUploadEvidence(order, isBuyer, isSeller),
),
```

**Add this helper method**:
```dart
bool _canUploadEvidence(Order order, bool isBuyer, bool isSeller) {
  if (!isBuyer && !isSeller) return false;

  if (order.orderType == 'sale') {
    // Sale: allow upload only before delivery is confirmed
    return order.status == 'confirmed'
        && !(order.deliveryConfirmedByBuyer ?? false)
        && !(order.deliveryConfirmedBySeller ?? false);
  } else {
    // Rental: allow upload during active/return phases
    final rs = order.rentalStatus;
    return rs == 'active' || rs == 'return_requested';
  }
}
```

---

## 5. Settings — 移除通知图标

### File: `lib/shared/widgets/custom_app_bar.dart`

The Settings page uses `CustomAppBar(showBackButton: true)`. The app bar
always shows `MessageBadgeIcon` in actions.

**Add a parameter** to hide actions:
```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showActions;       // <-- ADD
  final int unreadMessageCount;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.showActions = true,    // <-- ADD, default true
    this.unreadMessageCount = 3,
  });
```

In the `build()` method, change:
```dart
actions: showActions ? [
  MessageBadgeIcon(unreadCount: unreadMessageCount),
  const SizedBox(width: 8),
] : null,
```

### File: `lib/features/settings/screens/settings_screen.dart`

Change line 20:
```dart
appBar: const CustomAppBar(showBackButton: true, showActions: false),
```

---

## Files to modify (summary)

| File | Changes |
|------|---------|
| `transaction_management_screen.dart` | Accept → navigate to Order Detail |
| `seller_center_screen.dart` | Verify Active Transactions card taps → Order Detail |
| `listing_detail_screen.dart` | Application card: price + rental info + Cancel button |
| `order_detail_screen.dart` | Evidence photo conditional visibility |
| `custom_app_bar.dart` | Add `showActions` parameter |
| `settings_screen.dart` | Pass `showActions: false` |

## Testing

1. Accept offer → lands on Order Detail (not Seller Center)
2. Active Transactions card tap → Order Detail
3. Buyer sees price in Application Submitted card
4. Rental buyer sees "3 Days, Total: $300" format
5. Cancel button appears for pending orders, works correctly
6. Evidence photo button hidden after delivery confirmed (sale)
7. Evidence photo button hidden after return completed (rental)
8. Settings page: no notification icon in top right
9. Run `flutter analyze` — zero errors
