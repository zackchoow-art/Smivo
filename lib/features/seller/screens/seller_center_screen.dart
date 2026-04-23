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
                                size: 24,
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
