# Task 016: Rental Order Lifecycle (Active → Return → Deposit Refund)

## Objective
After both parties confirm delivery on a rental order, it should enter
an "active" rental state instead of immediately becoming "completed".
Add a return request → return confirmed → deposit refunded flow.

## Files to create/modify:

### CREATE:
1. `supabase/migrations/00019_rental_lifecycle.sql`

### MODIFY:
2. `lib/data/models/order.dart` — add rentalStatus field
3. `lib/data/repositories/order_repository.dart` — add rental lifecycle methods
4. `lib/features/orders/providers/orders_provider.dart` — add rental actions
5. `lib/features/orders/screens/order_detail_screen.dart` — add rental action buttons

### RUN:
6. `dart run build_runner build --delete-conflicting-outputs`

**DO NOT** modify any other files.

---

## Step 1: Create DB migration

Create `supabase/migrations/00019_rental_lifecycle.sql`:

```sql
-- ════════════════════════════════════════════════════════════
-- 00019: Rental Lifecycle States
--
-- Adds a rental_status column to orders for tracking the post-delivery
-- lifecycle of rental orders: active → return_requested → returned → 
-- deposit_refunded
-- ════════════════════════════════════════════════════════════

-- Add rental status enum-like column
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS rental_status text
  DEFAULT NULL
  CHECK (rental_status IS NULL OR rental_status IN (
    'active', 'return_requested', 'returned', 'deposit_refunded'
  ));

-- Add deposit refunded timestamp
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS deposit_refunded_at timestamptz DEFAULT NULL;

-- Add return requested timestamp
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS return_requested_at timestamptz DEFAULT NULL;

COMMENT ON COLUMN public.orders.rental_status IS 
  'Lifecycle state for rental orders after delivery is confirmed. NULL for sale orders.';
```

## Step 2: Update Order model

In `lib/data/models/order.dart`, add these fields to the factory constructor
(before the nested join fields):

```dart
    @JsonKey(name: 'rental_status') String? rentalStatus,
    @JsonKey(name: 'deposit_refunded_at') DateTime? depositRefundedAt,
    @JsonKey(name: 'return_requested_at') DateTime? returnRequestedAt,
```

Then run:
```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

## Step 3: Add repository methods

In `lib/data/repositories/order_repository.dart`, add these methods:

```dart
  /// Updates the rental status of an order.
  Future<Order> updateRentalStatus(String id, String rentalStatus) async {
    try {
      final updateData = <String, dynamic>{
        'rental_status': rentalStatus,
      };
      
      // Add timestamps for specific transitions
      if (rentalStatus == 'return_requested') {
        updateData['return_requested_at'] = DateTime.now().toIso8601String();
      } else if (rentalStatus == 'returned') {
        updateData['return_confirmed_at'] = DateTime.now().toIso8601String();
      } else if (rentalStatus == 'deposit_refunded') {
        updateData['deposit_refunded_at'] = DateTime.now().toIso8601String();
      }
      
      final data = await _client
          .from(AppConstants.tableOrders)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
```

## Step 4: Add provider actions

In `lib/features/orders/providers/orders_provider.dart`, add these
methods to `OrderActions`:

```dart
  /// Activates a rental order after both parties confirm delivery.
  /// Called automatically when rental delivery is confirmed.
  Future<void> activateRental(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(orderRepositoryProvider)
          .updateRentalStatus(orderId, 'active');
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Buyer requests to return the rented item.
  Future<void> requestReturn(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(orderRepositoryProvider)
          .updateRentalStatus(orderId, 'return_requested');
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Seller confirms the item has been returned.
  Future<void> confirmReturn(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(orderRepositoryProvider)
          .updateRentalStatus(orderId, 'returned');
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Seller confirms the deposit has been refunded.
  Future<void> refundDeposit(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(orderRepositoryProvider)
          .updateRentalStatus(orderId, 'deposit_refunded');
      // Mark the order as completed after deposit refund
      await ref.read(orderRepositoryProvider)
          .updateOrderStatus(orderId, 'completed');
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
```

Also, modify the `confirmDelivery` method's rental branch: after both
parties confirm delivery, automatically activate the rental instead of
completing it. Find the block:

```dart
      } else {
        // Rental: keep dual confirmation (existing behavior)
        final role = isBuyer ? 'buyer' : 'seller';
        await ref.read(orderRepositoryProvider).confirmDelivery(
          orderId: order.id,
          byUserRole: role,
        );
      }
```

After it, add a check: if both parties have now confirmed, activate
the rental:

```dart
      } else {
        // Rental: keep dual confirmation
        final role = isBuyer ? 'buyer' : 'seller';
        await ref.read(orderRepositoryProvider).confirmDelivery(
          orderId: order.id,
          byUserRole: role,
        );
        
        // After both parties confirm, activate the rental
        // (instead of completing it — rental has a return lifecycle)
        final updated = await ref.read(orderRepositoryProvider)
            .fetchOrder(order.id);
        if (updated.deliveryConfirmedByBuyer && 
            updated.deliveryConfirmedBySeller &&
            updated.rentalStatus == null) {
          await ref.read(orderRepositoryProvider)
              .updateRentalStatus(order.id, 'active');
        }
      }
```

## Step 5: Update order_detail_screen.dart

In the `_buildActions` method, after the existing `'confirmed'` case
handling for rental orders, add handling for the rental lifecycle
states. Find the default `'completed'` case (or add after the
`'confirmed'` case) and add:

After the existing action handling, check `order.rentalStatus`:

```dart
// Rental lifecycle actions
if (order.orderType == 'rental' && order.rentalStatus != null)
  _buildRentalLifecycleActions(context, ref, order, isBuyer, isSeller, isActing),
```

Add this method to the screen:

```dart
Widget _buildRentalLifecycleActions(
  BuildContext context,
  WidgetRef ref,
  Order order,
  bool isBuyer,
  bool isSeller,
  bool isActing,
) {
  switch (order.rentalStatus) {
    case 'active':
      if (isBuyer) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isActing
                ? null
                : () => ref.read(orderActionsProvider.notifier)
                    .requestReturn(order.id),
            icon: const Icon(Icons.assignment_return),
            label: Text(isActing ? 'Processing...' : 'Request Return'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text('Rental Active — Item with buyer',
                style: AppTextStyles.bodyMedium),
          ],
        ),
      );

    case 'return_requested':
      if (isSeller) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isActing
                ? null
                : () => ref.read(orderActionsProvider.notifier)
                    .confirmReturn(order.id),
            icon: const Icon(Icons.check),
            label: Text(isActing ? 'Processing...' : 'Confirm Return'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_top, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Waiting for seller to confirm return',
                  style: AppTextStyles.bodyMedium),
            ),
          ],
        ),
      );

    case 'returned':
      if (isSeller && order.depositAmount > 0) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isActing
                ? null
                : () => ref.read(orderActionsProvider.notifier)
                    .refundDeposit(order.id),
            icon: const Icon(Icons.payments),
            label: Text(isActing
                ? 'Processing...'
                : 'Confirm Deposit Refund (\$${order.depositAmount.toStringAsFixed(0)})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_turned_in, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                order.depositAmount > 0
                    ? 'Item returned — Awaiting deposit refund'
                    : 'Item returned — Transaction complete',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      );

    case 'deposit_refunded':
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text('Deposit refunded — Transaction complete',
                style: AppTextStyles.bodyMedium),
          ],
        ),
      );

    default:
      return const SizedBox.shrink();
  }
}
```

## Step 6: Run build_runner

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

## Step 7: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-016.md`.
