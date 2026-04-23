# Task 013: Refactor Orders Tab → Hub + Seller Center

## Objective
1. Transform the existing "My Orders" tab into a hub page with two entry
   cards: "Buyer Center" and "Seller Center"
2. Create the Seller Center as a new feature page
3. Add a "Manage Transactions" button on listing detail (own listing)

## Files to create/modify:

### CREATE:
1. `lib/features/seller/screens/seller_center_screen.dart`
2. `lib/features/seller/providers/seller_center_provider.dart`

### MODIFY:
3. `lib/features/orders/screens/orders_screen.dart` — rewrite as hub
4. `lib/core/router/app_routes.dart` — add new routes
5. `lib/core/router/router.dart` — register new routes
6. `lib/features/listing/screens/listing_detail_screen.dart` — add "Manage Transactions" button

### RUN:
7. `dart run build_runner build --delete-conflicting-outputs`

**DO NOT** modify any other files.

---

## Step 1: Add routes to app_routes.dart

Add these constants to the `AppRoutes` class:

```dart
  // Route Names
  static const String sellerCenter = 'sellerCenter';
  static const String buyerCenter = 'buyerCenter';
  static const String transactionManagement = 'transactionManagement';

  // Route Paths
  static const String sellerCenterPath = '/seller-center';
  static const String buyerCenterPath = '/buyer-center';
  static const String transactionManagementPath = '/listing/:id/transactions';
```

## Step 2: Create seller_center_provider.dart

Create `lib/features/seller/providers/seller_center_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/repositories/listing_repository.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'seller_center_provider.g.dart';

/// Fetches all listings owned by the current user.
@riverpod
Future<List<Listing>> myListings(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  
  final repo = ref.watch(listingRepositoryProvider);
  return repo.fetchUserListings(user.id);
}

/// Fetches all orders where the current user is the seller.
@riverpod
Future<List<Order>> sellerOrders(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  
  final repo = ref.watch(orderRepositoryProvider);
  final allOrders = await repo.fetchOrders(user.id);
  return allOrders.where((o) => o.sellerId == user.id).toList();
}
```

**IMPORTANT**: Check if `listingRepositoryProvider` exists and if there is
a `fetchUserListings` method. If not, add it to `listing_repository.dart`:

```dart
/// Fetches all listings owned by [userId].
Future<List<Listing>> fetchUserListings(String userId) async {
  try {
    final data = await _client
        .from(AppConstants.tableListings)
        .select('*, images:listing_images(*), seller:user_profiles!seller_id(*), pickup_location:pickup_locations(*)')
        .eq('seller_id', userId)
        .order('created_at', ascending: false);
    return data.map((json) => Listing.fromJson(json)).toList();
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}
```

## Step 3: Create seller_center_screen.dart

Create `lib/features/seller/screens/seller_center_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/seller/providers/seller_center_provider.dart';

class SellerCenterScreen extends ConsumerWidget {
  const SellerCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(myListingsProvider);
    final ordersAsync = ref.watch(sellerOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Seller Center',
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your listings and sales.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Active Listings Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'ACTIVE LISTINGS',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            listingsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $e')),
              ),
              data: (listings) {
                final activeListings = listings
                    .where((l) => l.status == 'active')
                    .toList();
                
                if (activeListings.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.storefront_outlined,
                                size: 48,
                                color: AppColors.onSurface.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text(
                              'No active listings',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.outlineVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final listing = activeListings[index];
                        final imageUrl = listing.images.isNotEmpty
                            ? listing.images.first.imageUrl
                            : null;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl != null
                                  ? Image.network(imageUrl,
                                      width: 56, height: 56,
                                      fit: BoxFit.cover)
                                  : Container(
                                      width: 56, height: 56,
                                      color: AppColors.surfaceContainerLow,
                                      child: const Icon(Icons.image)),
                            ),
                            title: Text(listing.title,
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              '\$${listing.price.toStringAsFixed(0)} · ${listing.transactionType}',
                              style: AppTextStyles.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.visibility_outlined,
                                    size: 16,
                                    color: AppColors.outlineVariant),
                                const SizedBox(width: 4),
                                Text('${listing.viewCount}',
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                            onTap: () => context.pushNamed(
                              AppRoutes.listingDetail,
                              pathParameters: {'id': listing.id},
                            ),
                          ),
                        );
                      },
                      childCount: activeListings.length,
                    ),
                  ),
                );
              },
            ),

            // Sold / Completed Section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'COMPLETED SALES',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            ordersAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $e')),
              ),
              data: (orders) {
                final completedOrders = orders
                    .where((o) => o.status == 'completed' || o.status == 'cancelled')
                    .toList();
                
                if (completedOrders.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No completed sales yet',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final order = completedOrders[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: order.status == 'completed'
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              child: Icon(
                                order.status == 'completed'
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: order.status == 'completed'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(
                              order.listing?.title ?? 'Order',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '\$${order.totalPrice.toStringAsFixed(0)} · ${order.status}',
                              style: AppTextStyles.bodySmall,
                            ),
                            onTap: () => context.pushNamed(
                              AppRoutes.orderDetail,
                              pathParameters: {'id': order.id},
                            ),
                          ),
                        );
                      },
                      childCount: completedOrders.length,
                    ),
                  ),
                );
              },
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
```

## Step 4: Rewrite orders_screen.dart as a Hub

Replace the entire content of `lib/features/orders/screens/orders_screen.dart`
with a hub page that has two large entry cards:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Orders',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your campus transactions.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Buyer Center Card
              _HubCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Buyer Center',
                subtitle: 'Your purchase requests,\naccepted orders, and history.',
                gradient: const [Color(0xFF013DFD), Color(0xFF436BFF)],
                onTap: () => context.pushNamed(AppRoutes.buyerCenter),
              ),
              const SizedBox(height: 16),

              // Seller Center Card
              _HubCard(
                icon: Icons.storefront_outlined,
                title: 'Seller Center',
                subtitle: 'Active listings, incoming\norders, and sales history.',
                gradient: const [Color(0xFF7B2FF7), Color(0xFFA855F7)],
                onTap: () => context.pushNamed(AppRoutes.sellerCenter),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 64),
          ],
        ),
      ),
    );
  }
}
```

## Step 5: Register routes in router.dart

Add imports at the top:
```dart
import 'package:smivo/features/seller/screens/seller_center_screen.dart';
```

Add these routes after the `orderDetail` route (approximately after line 228):

```dart
      // ── Seller Center ─────────────────────────────────────
      GoRoute(
        name: AppRoutes.sellerCenter,
        path: AppRoutes.sellerCenterPath,
        builder: (context, state) => const SellerCenterScreen(),
      ),

      // ── Buyer Center (placeholder for now — Task 014) ─────
      GoRoute(
        name: AppRoutes.buyerCenter,
        path: AppRoutes.buyerCenterPath,
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Buyer Center'),
      ),
```

## Step 6: Add "Manage Transactions" button to listing detail

In `listing_detail_screen.dart`, find the `isOwnListing` stats section
(the block with `LISTING STATS`). After the stats Row and its
`SizedBox(height: AppSpacing.xl)`, add:

```dart
                            // Manage Transactions button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // TODO: Navigate to transaction management
                                  // (Task 015 will implement this)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Transaction management coming soon'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.manage_search),
                                label: const Text('Manage Transactions'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md),
                                  side: BorderSide(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
```

## Step 7: Run build_runner

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

## Step 8: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-013.md`.
