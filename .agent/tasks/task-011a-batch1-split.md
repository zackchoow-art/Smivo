# Task 011a: Order Detail 页面拆分 — Batch 1

## Pre-requisites
- Read `.agent/docs/theme-architecture.md` for styling rules
- Read `.agent/tasks/task-011-order-detail-split.md` for architecture overview
- Use ONLY theme tokens, NO hardcoded colors
- Read each target file fully before modifying

---

## Overview

Split `order_detail_screen.dart` (413 lines) into:
1. A thin **dispatcher** that routes to Sale or Rental screens
2. **Shared widgets** extracted from existing methods
3. **SaleOrderDetailScreen** — for `orderType == 'sale'`
4. **RentalOrderDetailScreen** — for `orderType == 'rental'`

---

## Step 1: Create Shared Widgets

Extract methods from the EXISTING `order_detail_screen.dart` into standalone
StatelessWidget files. Each widget receives `Order` and other data via
constructor — NO provider dependencies inside these widgets.

### 1a. `lib/features/orders/widgets/order_header_card.dart`

Extract from `_buildListingCard()` (lines 171-193).

```dart
class OrderHeaderCard extends StatelessWidget {
  const OrderHeaderCard({super.key, required this.order});
  final Order order;
  // ... identical to _buildListingCard() body
}
```

### 1b. `lib/features/orders/widgets/order_timeline.dart`

Extract from `_buildTimeline()` + `_buildTimelineRow()` + `_TimelineStep`.

```dart
class TimelineStep {
  const TimelineStep({required this.label, required this.isCompleted, this.date});
  final String label;
  final DateTime? date;
  final bool isCompleted;
}

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.steps});
  final List<TimelineStep> steps;
  // ... renders timeline rows
}
```

### 1c. `lib/features/orders/widgets/order_financial_summary.dart`

Extract from `_buildFinancialSummary()` + `_summaryRow()` (lines 135-169).

```dart
class OrderFinancialSummary extends StatelessWidget {
  const OrderFinancialSummary({super.key, required this.order});
  final Order order;
}
```

### 1d. `lib/features/orders/widgets/order_info_section.dart`

Extract from `_buildInfoSection()` + `_infoRow()` + `_statusText()`
(lines 195-209, 362-378).

```dart
class OrderInfoSection extends StatelessWidget {
  const OrderInfoSection({
    super.key,
    required this.order,
    required this.counterpartyName,
  });
  final Order order;
  final String? counterpartyName;
}
```

### 1e. `lib/features/orders/widgets/rental_date_section.dart`

Extract from `_buildRentalSection()` (lines 211-219).

```dart
class RentalDateSection extends StatelessWidget {
  const RentalDateSection({super.key, required this.order});
  final Order order;
}
```

---

## Step 2: Create `SaleOrderDetailScreen`

**File**: `lib/features/orders/screens/sale_order_detail_screen.dart`

This is a `ConsumerWidget` that receives the `Order` object and `orderId`.

```dart
class SaleOrderDetailScreen extends ConsumerWidget {
  const SaleOrderDetailScreen({
    super.key,
    required this.order,
    required this.orderId,
  });
  final Order order;
  final String orderId;
```

**Body structure** (in order):
1. `OrderHeaderCard(order: order)`
2. `OrderTimeline(steps: _buildSaleSteps(order))`
   - Steps: Order Placed → Accepted → Picked Up
3. `OrderFinancialSummary(order: order)`
4. `OrderInfoSection(order: order, counterpartyName: ...)`
5. Delivery status (if confirmed/completed):
   ```
   Delivery Confirmation
   Buyer:  ✓ Confirmed / Waiting
   Seller: ✓ Confirmed / Waiting
   ```
6. `EvidencePhotoSection(orderId: order.id, canUpload: ...)`
   - `canUpload`: only if `status == 'confirmed'` AND neither party confirmed
7. Chat history section (via `orderChatRoomIdProvider`)
8. **Action buttons**:
   - `pending` + seller: [Accept Order] [Cancel]
   - `pending` + buyer: [Cancel]
   - `confirmed` + buyer: [Confirm Pickup] [Cancel*]
   - `confirmed` + seller: "Waiting for buyer..." [Cancel*]
   - `completed`: "✓ Order completed"
   - `cancelled`: "✕ Order was cancelled"
   
   **Cancel hidden when**: `deliveryConfirmedByBuyer || deliveryConfirmedBySeller`

**Actions**: Use existing `orderActionsProvider` methods:
- `acceptOrder(orderId)`
- `confirmDelivery(order)` — for sale, only buyer calls this
- `cancelOrder(orderId)`

**Listen** to `orderActionsProvider` for errors (show SnackBar).

---

## Step 3: Create `RentalOrderDetailScreen`

**File**: `lib/features/orders/screens/rental_order_detail_screen.dart`

Same structure as Sale but with rental-specific additions:

**Body structure**:
1. `OrderHeaderCard(order: order)`
2. `OrderTimeline(steps: _buildRentalSteps(order))`
   - Steps: Order Placed → Accepted → Delivered → Active → Return Requested → Returned → Deposit Refunded → Completed
3. `OrderFinancialSummary(order: order)` — includes rental rates + deposit
4. `OrderInfoSection(order: order, counterpartyName: ...)`
5. `RentalDateSection(order: order)` — start/end/return dates
6. Delivery status (if confirmed/completed)
7. `EvidencePhotoSection` for **delivery** evidence
   - `canUpload`: `status == 'confirmed'` AND neither confirmed delivery
8. `EvidencePhotoSection` for **return** evidence (separate section)
   - Show only when `rentalStatus` is 'active' or 'return_requested'
   - `canUpload`: `rentalStatus == 'active' || rentalStatus == 'return_requested'`
   - Label this section "Return Evidence" to distinguish from delivery evidence
9. Chat history section
10. **Base action buttons** (same Cancel logic as Sale):
    - `pending`: [Accept/Cancel]
    - `confirmed`: [Confirm Delivery] [Cancel*]
    - Cancel hidden after both confirm delivery
11. **Rental lifecycle actions** (from `_buildRentalLifecycleActions`):
    - `active` + buyer: [Request Return]
    - `active` + seller: "Rental Active — Item with buyer"
    - `return_requested` + seller: [Confirm Return]
    - `return_requested` + buyer: "Waiting for seller..."
    - `returned` + seller + deposit>0: [Confirm Deposit Refund]
    - `returned` + buyer: "Awaiting deposit refund"
    - `deposit_refunded`: "✓ Deposit refunded"
    - `completed`: "✓ Complete"
    - `cancelled`: "✕ Cancelled"

**NOTE**: For evidence photos during return, you need to differentiate between
delivery evidence and return evidence. Options:
- Use a different `evidenceType` parameter or different subfolder
- For now, use the same `EvidencePhotoSection` but pass a `label` parameter
  (modify the existing widget to accept an optional `label: 'Return Evidence'`)

---

## Step 4: Modify `order_detail_screen.dart` to Dispatcher

Replace the ENTIRE body of `order_detail_screen.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/orders/screens/sale_order_detail_screen.dart';
import 'package:smivo/features/orders/screens/rental_order_detail_screen.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final currentUserId = ref.watch(authStateProvider).valueOrNull?.id;

    return orderAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(child: Text('Error: $err')),
      ),
      data: (order) {
        if (order.orderType == 'rental') {
          return RentalOrderDetailScreen(
            order: order,
            orderId: orderId,
            currentUserId: currentUserId,
          );
        }
        return SaleOrderDetailScreen(
          order: order,
          orderId: orderId,
          currentUserId: currentUserId,
        );
      },
    );
  }
}
```

---

## Step 5: Modify `EvidencePhotoSection` to support labels

**File**: `lib/features/orders/widgets/evidence_photo_section.dart`

Add an optional `label` parameter:
```dart
class EvidencePhotoSection extends ConsumerStatefulWidget {
  const EvidencePhotoSection({
    super.key,
    required this.orderId,
    required this.canUpload,
    this.label = 'Evidence Photos',  // <-- ADD
    this.evidenceType = 'delivery',  // <-- ADD for folder separation
  });
  final String orderId;
  final bool canUpload;
  final String label;             // <-- ADD
  final String evidenceType;      // <-- ADD
```

Use `label` in the section header. Use `evidenceType` as a subfolder when
uploading to storage (e.g., `order-evidence/{orderId}/{evidenceType}/`).

---

## Testing Checklist

1. Navigate to a **sale** order → `SaleOrderDetailScreen` renders correctly
2. Navigate to a **rental** order → `RentalOrderDetailScreen` renders correctly
3. All shared widgets display correct data
4. Accept/Cancel/Confirm Delivery work on Sale orders
5. Full rental lifecycle works: Confirm Delivery → Active → Request Return → 
   Confirm Return → Refund Deposit → Complete
6. Evidence photos upload and display correctly
7. Cancel button hidden after delivery confirmed (both types)
8. Chat history displays in both types
9. Return evidence section appears only during active/return phases (rental)
10. Run `flutter analyze` — zero errors

---

## Files summary

| File | Action |
|------|--------|
| `order_header_card.dart` | CREATE |
| `order_timeline.dart` | CREATE |
| `order_financial_summary.dart` | CREATE |
| `order_info_section.dart` | CREATE |
| `rental_date_section.dart` | CREATE |
| `sale_order_detail_screen.dart` | CREATE |
| `rental_order_detail_screen.dart` | CREATE |
| `order_detail_screen.dart` | MODIFY → thin dispatcher |
| `evidence_photo_section.dart` | MODIFY → add label + evidenceType |
