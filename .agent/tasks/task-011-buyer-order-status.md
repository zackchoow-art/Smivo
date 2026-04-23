# Task 011: Buyer Order Status Display on Listing Detail

## Objective
When a buyer has already submitted an order for a listing, show
"Application Submitted · [date]" instead of the "Place Order" button.

## STRICT SCOPE — Create/modify these files ONLY:

1. **MODIFY** `lib/data/repositories/order_repository.dart`
2. **MODIFY** `lib/features/listing/providers/listing_detail_provider.dart`  
3. **RUN** `dart run build_runner build --delete-conflicting-outputs`
4. **MODIFY** `lib/features/listing/screens/listing_detail_screen.dart`

**DO NOT** modify any other files.

---

## Step 1: Add query method to OrderRepository

In `lib/data/repositories/order_repository.dart`, add this method to the
`OrderRepository` class (before the closing brace):

```dart
  /// Finds an existing order by listing and buyer.
  /// Returns null if no active order exists.
  Future<Order?> fetchOrderByListingAndBuyer({
    required String listingId,
    required String buyerId,
  }) async {
    try {
      final data = await _client
          .from(AppConstants.tableOrders)
          .select()
          .eq('listing_id', listingId)
          .eq('buyer_id', buyerId)
          .inFilter('status', ['pending', 'confirmed'])
          .maybeSingle();
      if (data == null) return null;
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
```

## Step 2: Add provider for existing buyer order

In `lib/features/listing/providers/listing_detail_provider.dart`, add
a new provider (append to the bottom of the file):

```dart
/// Checks if the current user already has a pending/confirmed order
/// for this listing. Returns the order if found, null otherwise.
@riverpod
Future<Order?> existingBuyerOrder(Ref ref, String listingId) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  
  final repo = ref.watch(orderRepositoryProvider);
  return repo.fetchOrderByListingAndBuyer(
    listingId: listingId,
    buyerId: user.id,
  );
}
```

Add the required imports at the top if not already present:
```dart
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
```

## Step 3: Run build_runner

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

## Step 4: Update listing detail screen

In `listing_detail_screen.dart`, replace the action button section.

Find the section (approximately the `if (!isOwnListing)` block wrapping
`SizedBox` with `ElevatedButton`).

Before that block, add a watch:
```dart
final existingOrder = ref.watch(existingBuyerOrderProvider(listing.id));
```

Then replace the `if (!isOwnListing)` button block with:

```dart
// Primary Action Button — hidden on own listing
if (!isOwnListing)
  existingOrder.when(
    loading: () => const SizedBox.shrink(),
    error: (_, __) => const SizedBox.shrink(),
    data: (order) {
      if (order != null) {
        // Buyer already submitted an order
        final submittedDate = DateFormat('MMM d, yyyy').format(order.createdAt);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Application Submitted',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                submittedDate,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.outlineVariant,
                ),
              ),
            ],
          ),
        );
      }
      
      // Normal action button (existing code)
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          // ... keep the entire existing onPressed and style code unchanged ...
        ),
      );
    },
  ),
```

Add the import at top:
```dart
import 'package:intl/intl.dart';
```

Also add the import for listing_detail_provider if the new provider
is not auto-imported:
```dart
import 'package:smivo/features/listing/providers/listing_detail_provider.dart';
```

IMPORTANT: When implementing the "Normal action button" branch inside
`data: (order)`, you must preserve the ENTIRE existing `ElevatedButton`
with all its `onPressed` logic exactly as-is. Do NOT delete or simplify
the existing order creation logic.

## Step 5: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-011.md`.
