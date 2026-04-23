import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/seller/providers/seller_center_provider.dart';

class SellerCenterScreen extends ConsumerWidget {
  const SellerCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(myListingsProvider);
    final ordersAsync = ref.watch(sellerOrdersProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.of(context).pop()),
                const SizedBox(width: 8),
                Text('Seller Center', style: typo.headlineLarge.copyWith(fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 8),
              Text('Manage your listings and sales.', style: typo.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.7))),
            ])),
          ),
          // Active Listings
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(child: Text('ACTIVE LISTINGS',
              style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          listingsAsync.when(
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            data: (listings) {
              final activeListings = listings.where((l) => l.status == 'active').toList();
              if (activeListings.isEmpty) {
                return SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Center(child: Column(children: [
                    Icon(Icons.storefront_outlined, size: 48, color: colors.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('No active listings', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
                  ])),
                ));
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                  final listing = activeListings[index];
                  final imageUrl = listing.images.isNotEmpty ? listing.images.first.imageUrl : null;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.md)),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl != null
                          ? Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover)
                          : Container(width: 56, height: 56, color: colors.surfaceContainerLow, child: const Icon(Icons.image)),
                      ),
                      title: Text(listing.title, style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text('\$${listing.price.toStringAsFixed(0)} · ${listing.transactionType}', style: typo.bodySmall),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.visibility_outlined, size: 16, color: colors.outlineVariant), const SizedBox(width: 4),
                        Text('${listing.viewCount}', style: typo.bodySmall),
                      ]),
                      onTap: () => context.pushNamed(AppRoutes.listingDetail, pathParameters: {'id': listing.id}),
                    ),
                  );
                }, childCount: activeListings.length)),
              );
            },
          ),
          // Completed Sales
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            sliver: SliverToBoxAdapter(child: Text('COMPLETED SALES',
              style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5))),
          ),
          ordersAsync.when(
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            data: (orders) {
              final completedOrders = orders.where((o) => o.status == 'completed' || o.status == 'cancelled').toList();
              if (completedOrders.isEmpty) {
                return SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text('No completed sales yet', style: typo.bodyMedium.copyWith(color: colors.outlineVariant))),
                ));
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                  final order = completedOrders[index];
                  final isCompleted = order.status == 'completed';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.md)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCompleted ? colors.success.withValues(alpha: 0.1) : colors.error.withValues(alpha: 0.1),
                        child: Icon(isCompleted ? Icons.check_circle : Icons.cancel,
                          color: isCompleted ? colors.success : colors.error, size: 24),
                      ),
                      title: Text(order.listing?.title ?? 'Order', style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text('\$${order.totalPrice.toStringAsFixed(0)} · ${order.status}', style: typo.bodySmall),
                      onTap: () => context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id}),
                    ),
                  );
                }, childCount: completedOrders.length)),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
      ),
    );
  }
}
