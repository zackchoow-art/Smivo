# Task 015: Transaction Management Page + Accept Flow

## Objective
Create the Transaction Management page that sellers access from their
listing detail page. This page shows three tabs: Views, Saves, Orders.
The Orders tab includes "Accept" buttons for pending orders.

## PREREQUISITE: Task 013 must be completed first.

## Files to create/modify:

### CREATE:
1. `lib/features/seller/screens/transaction_management_screen.dart`
2. `lib/features/seller/providers/transaction_stats_provider.dart`

### MODIFY:
3. `lib/core/router/app_routes.dart` — verify transactionManagement route exists
4. `lib/core/router/router.dart` — register the route
5. `lib/features/listing/screens/listing_detail_screen.dart` — wire the button
6. `lib/data/repositories/saved_repository.dart` — add fetchSavedListingUsers
7. `lib/data/repositories/order_repository.dart` — add fetchOrdersByListing

### RUN:
8. `dart run build_runner build --delete-conflicting-outputs`

**DO NOT** modify any other files.

---

## Step 1: Add repository methods

### In `lib/data/repositories/order_repository.dart`:
Add this method to `OrderRepository`:

```dart
  /// Fetches all orders for a specific listing.
  Future<List<Order>> fetchOrdersByListing(String listingId) async {
    try {
      final data = await _client
          .from(AppConstants.tableOrders)
          .select('''
            *,
            buyer:user_profiles!buyer_id(*),
            seller:user_profiles!seller_id(*)
          ''')
          .eq('listing_id', listingId)
          .order('created_at', ascending: false);
      return data.map((json) => Order.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
```

### In `lib/data/repositories/saved_repository.dart`:
Add this method to `SavedRepository`:

```dart
  /// Fetches all users who saved a specific listing (for seller stats).
  /// Returns a list of SavedListing records.
  Future<List<SavedListing>> fetchSavedByListing(String listingId) async {
    try {
      final data = await _client
          .from(AppConstants.tableSavedListings)
          .select('*, user:user_profiles!user_id(*)')
          .eq('listing_id', listingId)
          .order('created_at', ascending: false);
      return data.map((json) => SavedListing.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
```

**NOTE**: The `user` join field may not exist on the SavedListing model.
If this causes a fromJson error, query without the join and just return
the SavedListing list (user info can be fetched separately or the card
can show minimal info).

## Step 2: Create transaction_stats_provider.dart

Create `lib/features/seller/providers/transaction_stats_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/saved_listing.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/data/repositories/saved_repository.dart';

part 'transaction_stats_provider.g.dart';

/// Fetches all orders for a specific listing.
@riverpod
Future<List<Order>> listingOrders(Ref ref, String listingId) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.fetchOrdersByListing(listingId);
}

/// Fetches all saves for a specific listing.
@riverpod
Future<List<SavedListing>> listingSaves(Ref ref, String listingId) async {
  final repo = ref.watch(savedRepositoryProvider);
  return repo.fetchSavedByListing(listingId);
}
```

## Step 3: Create transaction_management_screen.dart

Create `lib/features/seller/screens/transaction_management_screen.dart`:

This is a **tabbed page** with 3 tabs: Views, Saves, Orders.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/seller/providers/transaction_stats_provider.dart';

class TransactionManagementScreen extends ConsumerWidget {
  const TransactionManagementScreen({
    super.key,
    required this.listingId,
  });

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('Manage Transactions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Views'),
              Tab(text: 'Saves'),
              Tab(text: 'Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ViewsTab(listingId: listingId),
            _SavesTab(listingId: listingId),
            _OrdersTab(listingId: listingId),
          ],
        ),
      ),
    );
  }
}

/// Views tab — placeholder since we don't have a listing_views table yet.
class _ViewsTab extends StatelessWidget {
  const _ViewsTab({required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_outlined,
              size: 48,
              color: AppColors.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            'View tracking coming soon',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.outlineVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Individual viewer details will appear here.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Saves tab — shows users who saved this listing.
class _SavesTab extends ConsumerWidget {
  const _SavesTab({required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savesAsync = ref.watch(listingSavesProvider(listingId));

    return savesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (saves) {
        if (saves.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_border,
                    size: 48,
                    color: AppColors.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('No saves yet',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.outlineVariant)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: saves.length,
          itemBuilder: (context, index) {
            final save = saves[index];
            final dateStr =
                DateFormat('MMM d, yyyy').format(save.createdAt);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('User',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('Saved on $dateStr',
                    style: AppTextStyles.bodySmall),
              ),
            );
          },
        );
      },
    );
  }
}

/// Orders tab — shows all orders with Accept buttons.
class _OrdersTab extends ConsumerWidget {
  const _OrdersTab({required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(listingOrdersProvider(listingId));
    final actionsState = ref.watch(orderActionsProvider);

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 48,
                    color: AppColors.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('No orders yet',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.outlineVariant)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _OrderCard(
              order: order,
              isActing: actionsState.isLoading,
              onAccept: order.status == 'pending'
                  ? () {
                      ref
                          .read(orderActionsProvider.notifier)
                          .acceptOrder(order.id);
                      // Refresh the listing orders after accepting
                      ref.invalidate(
                          listingOrdersProvider(listingId));
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isActing,
    this.onAccept,
  });

  final Order order;
  final bool isActing;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final buyerName = order.buyer?.displayName ?? 'Unknown Buyer';
    final dateStr = DateFormat('MMM d, yyyy').format(order.createdAt);
    final isPending = order.status == 'pending';

    Color statusColor;
    String statusLabel;
    switch (order.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusLabel = 'Pending';
        break;
      case 'confirmed':
        statusColor = AppColors.primary;
        statusLabel = 'Accepted';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusLabel = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusLabel = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = order.status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      statusColor.withValues(alpha: 0.1),
                  child: Icon(Icons.person,
                      color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(buyerName,
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600)),
                      Text(
                        '${order.orderType.toUpperCase()} · $dateStr',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (isPending && onAccept != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '\$${order.totalPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isActing ? null : onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm),
                      ),
                    ),
                    child: Text(
                      isActing ? 'Processing...' : 'Accept',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

## Step 4: Register route in router.dart

Add import:
```dart
import 'package:smivo/features/seller/screens/transaction_management_screen.dart';
```

Add this route (after the seller center route):
```dart
      GoRoute(
        name: AppRoutes.transactionManagement,
        path: AppRoutes.transactionManagementPath,
        builder: (context, state) => TransactionManagementScreen(
          listingId: state.pathParameters['id']!,
        ),
      ),
```

## Step 5: Wire the button in listing_detail_screen.dart

Find the "Manage Transactions" button that currently shows a SnackBar
(added in Task 013). Replace the `onPressed` callback:

**From:**
```dart
onPressed: () {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Transaction management coming soon'),
    ),
  );
},
```

**To:**
```dart
onPressed: () {
  context.pushNamed(
    AppRoutes.transactionManagement,
    pathParameters: {'id': listing.id},
  );
},
```

## Step 6: Run build_runner

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

## Step 7: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-015.md`.
