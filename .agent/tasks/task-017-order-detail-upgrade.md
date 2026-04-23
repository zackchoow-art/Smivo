# Task 017: Order Detail Screen Upgrade

## Objective
Upgrade the order detail screen from a basic info display to a
comprehensive full-page view with timeline, financial summary,
and pickup location. This is a UI-only refactor of the existing
`order_detail_screen.dart` — no new DB tables needed for this step.

(Evidence photos are deferred to a future task.)

## STRICT SCOPE — Only modify:
- `lib/features/orders/screens/order_detail_screen.dart`

**DO NOT** modify any other files.

---

## Changes Required

Rewrite the `_buildBody` method to include the following sections
in order:

### 1. Listing Card (keep existing _buildListingCard)

### 2. Status Timeline
Replace the simple status text with a visual step timeline:

```dart
Widget _buildTimeline(Order order) {
  final steps = <_TimelineStep>[
    _TimelineStep(
      label: 'Order Placed',
      date: order.createdAt,
      isCompleted: true,
    ),
    _TimelineStep(
      label: 'Accepted',
      date: order.status != 'pending' && order.status != 'cancelled'
          ? order.updatedAt
          : null,
      isCompleted: order.status == 'confirmed' ||
          order.status == 'completed',
    ),
    if (order.orderType == 'sale')
      _TimelineStep(
        label: 'Picked Up',
        date: order.status == 'completed' ? order.updatedAt : null,
        isCompleted: order.status == 'completed',
      ),
    if (order.orderType == 'rental') ...[
      _TimelineStep(
        label: 'Delivered',
        date: order.deliveryConfirmedByBuyer &&
                order.deliveryConfirmedBySeller
            ? order.updatedAt
            : null,
        isCompleted: order.deliveryConfirmedByBuyer &&
            order.deliveryConfirmedBySeller,
      ),
      _TimelineStep(
        label: 'Returned',
        date: order.returnConfirmedAt,
        isCompleted: order.returnConfirmedAt != null,
      ),
    ],
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('ORDER TIMELINE',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.5),
            letterSpacing: 0.5,
          )),
      const SizedBox(height: AppSpacing.md),
      ...steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;
        
        return _buildTimelineRow(step, isLast);
      }),
    ],
  );
}

Widget _buildTimelineRow(_TimelineStep step, bool isLast) {
  final dateStr = step.date != null
      ? DateFormat('MMM d, yyyy · h:mm a').format(step.date!.toLocal())
      : '—';

  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dot + Line
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isCompleted
                      ? AppColors.primary
                      : AppColors.surfaceContainerHigh,
                  border: Border.all(
                    color: step.isCompleted
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    width: 2,
                  ),
                ),
                child: step.isCompleted
                    ? const Icon(Icons.check,
                        size: 8, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.isCompleted
                        ? AppColors.primary
                        : AppColors.surfaceContainerHigh,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: step.isCompleted
                          ? AppColors.onSurface
                          : AppColors.outlineVariant,
                    )),
                if (step.date != null)
                  Text(dateStr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.outlineVariant,
                      )),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
```

Add this helper class at the bottom of the file:
```dart
class _TimelineStep {
  const _TimelineStep({
    required this.label,
    required this.isCompleted,
    this.date,
  });
  final String label;
  final DateTime? date;
  final bool isCompleted;
}
```

### 3. Financial Summary
Replace the simple price display with a structured card:

```dart
Widget _buildFinancialSummary(Order order) {
  return Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FINANCIAL SUMMARY',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            )),
        const SizedBox(height: AppSpacing.md),
        _summaryRow('Type', order.orderType.toUpperCase()),
        if (order.orderType == 'rental' && order.listing != null) ...[
          if ((order.listing!.rentalDailyPrice ?? 0) > 0)
            _summaryRow('Daily Rate',
                '\$${order.listing!.rentalDailyPrice!.toStringAsFixed(2)}'),
          if ((order.listing!.rentalWeeklyPrice ?? 0) > 0)
            _summaryRow('Weekly Rate',
                '\$${order.listing!.rentalWeeklyPrice!.toStringAsFixed(2)}'),
          if ((order.listing!.rentalMonthlyPrice ?? 0) > 0)
            _summaryRow('Monthly Rate',
                '\$${order.listing!.rentalMonthlyPrice!.toStringAsFixed(2)}'),
        ],
        if (order.depositAmount > 0)
          _summaryRow('Deposit',
              '\$${order.depositAmount.toStringAsFixed(2)}'),
        const Divider(),
        _summaryRow(
          'Total',
          '\$${order.totalPrice.toStringAsFixed(2)}',
          isBold: true,
        ),
      ],
    ),
  );
}

Widget _summaryRow(String label, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primary : null,
            )),
      ],
    ),
  );
}
```

### 4. Pickup Location (keep existing, but wrap in a section)

### 5. Counterparty Info (keep existing)

### 6. Delivery Status + Rental Lifecycle (keep existing)

### 7. Action Buttons (keep existing _buildActions)

## New _buildBody layout order:

```dart
Widget _buildBody(...) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildListingCard(order),
        const SizedBox(height: AppSpacing.lg),
        
        _buildTimeline(order),
        const SizedBox(height: AppSpacing.lg),

        _buildFinancialSummary(order),
        const SizedBox(height: AppSpacing.lg),

        _buildInfoSection(order, counterpartyName),
        const SizedBox(height: AppSpacing.lg),

        if (order.orderType == 'rental' && order.rentalStartDate != null) ...[
          _buildRentalSection(order),
          const SizedBox(height: AppSpacing.lg),
        ],

        if (order.status == 'confirmed' || order.status == 'completed')
          _buildDeliveryStatus(order),

        const SizedBox(height: AppSpacing.xl),
        _buildActions(context, ref, order, isBuyer, isSeller, isActing),
        
        // Add rental lifecycle actions
        if (order.orderType == 'rental' && order.rentalStatus != null) ...[
          const SizedBox(height: AppSpacing.md),
          _buildRentalLifecycleActions(
              context, ref, order, isBuyer, isSeller, isActing),
        ],
      ],
    ),
  );
}
```

Add this import at top if not already present:
```dart
import 'package:intl/intl.dart';
```

## Step 2: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-017.md`.
