import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/seller/providers/seller_center_provider.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/listing.dart';

class SellerCenterScreen extends ConsumerStatefulWidget {
  const SellerCenterScreen({super.key});

  @override
  ConsumerState<SellerCenterScreen> createState() => _SellerCenterScreenState();
}

class _SellerCenterScreenState extends ConsumerState<SellerCenterScreen> {
  bool _isListView = false;

  @override
  Widget build(BuildContext context) {
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
          // 1. ACTIVE LISTINGS Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ACTIVE LISTINGS',
                    style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),
                  IconButton(
                    icon: Icon(_isListView ? Icons.grid_view_outlined : Icons.list_outlined, size: 20, color: colors.primary),
                    onPressed: () => setState(() => _isListView = !_isListView),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
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
                  
                  if (_isListView) {
                    return _buildListViewItem(listing, imageUrl);
                  }

                  return _buildActiveListingCard(listing, imageUrl);
                }, childCount: activeListings.length)),
              );
            },
          ),

          // 2. AWAITING DELIVERY Section (Accepted but not delivered)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            sliver: SliverToBoxAdapter(
              child: Text('AWAITING DELIVERY',
                style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),
            ),
          ),
          ordersAsync.when(
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            data: (orders) {
              final awaitingDelivery = orders.where((o) =>
                o.status == 'confirmed' &&
                !(o.deliveryConfirmedByBuyer && o.deliveryConfirmedBySeller)
              ).toList();

              if (awaitingDelivery.isEmpty) {
                return SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Center(child: Text('Nothing awaiting delivery', style: typo.bodyMedium.copyWith(color: colors.outlineVariant))),
                ));
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                  final order = awaitingDelivery[index];
                  final statusLabel = order.orderType == 'sale' ? 'Awaiting Pickup' : 'Awaiting Delivery';
                  return _buildOrderCard(order, statusLabel);
                }, childCount: awaitingDelivery.length)),
              );
            },
          ),

          // 3. ACTIVE TRANSACTIONS Section (In-progress rentals)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            sliver: SliverToBoxAdapter(
              child: Text('ACTIVE TRANSACTIONS',
                style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),
            ),
          ),
          ordersAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (orders) {
              final activeTransactions = orders.where((o) =>
                o.status == 'confirmed' &&
                (o.rentalStatus == 'active' ||
                 o.rentalStatus == 'return_requested' ||
                 o.rentalStatus == 'returned')
              ).toList();

              if (activeTransactions.isEmpty) {
                return SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Center(child: Text('No active transactions', style: typo.bodyMedium.copyWith(color: colors.outlineVariant))),
                ));
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                  final order = activeTransactions[index];
                  final statusLabel = order.rentalStatus?.replaceAll('_', ' ').toUpperCase() ?? order.status.toUpperCase();
                  return _buildOrderCard(order, statusLabel);
                }, childCount: activeTransactions.length)),
              );
            },
          ),

          // 4. HISTORY Section (Smart Merge)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            sliver: SliverToBoxAdapter(child: Text('HISTORY',
              style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5))),
          ),
          ordersAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (orders) {
              return listingsAsync.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (listings) {
                  // --- History Merge Logic ---
                  
                  // 1. Group cancelled orders by listingId
                  final cancelledByListing = <String, List<Order>>{};
                  final completedOrders = <Order>[];

                  for (final o in orders) {
                    if (o.status == 'cancelled') {
                      cancelledByListing.putIfAbsent(o.listingId, () => []).add(o);
                    } else if (o.status == 'completed') {
                      completedOrders.add(o);
                    }
                  }

                  // 2. Find listings that have at least one active or confirmed order
                  final listingsWithActiveSibling = orders
                      .where((o) => o.status == 'confirmed' || o.status == 'completed')
                      .map((o) => o.listingId)
                      .toSet();

                  final historyItems = <_HistoryItem>[];

                  // Add completed orders individually
                  for (final o in completedOrders) {
                    historyItems.add(_HistoryItem(
                      title: o.listing?.title ?? 'Order',
                      subtitle: '\$${o.totalPrice.toStringAsFixed(0)} · Completed',
                      isCompleted: true,
                      onTap: () => context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': o.id}),
                    ));
                  }

                  // Add merged cancelled groups (only if no active sibling)
                  for (final entry in cancelledByListing.entries) {
                    if (listingsWithActiveSibling.contains(entry.key)) {
                      continue; // Skip cancelled ones if an active order exists for this listing
                    }
                    
                    final groupOrders = entry.value;
                    final listing = groupOrders.first.listing;
                    // Note: We need the full listing for stats, but order.listing is only a preview.
                    // We'll try to find the real listing from myListings.
                    final fullListing = listings.where((l) => l.id == entry.key).firstOrNull;
                    final title = fullListing?.title ?? listing?.title ?? 'Listing';
                    
                    historyItems.add(_HistoryItem(
                      title: title,
                      subtitle: '${groupOrders.length} offer${groupOrders.length > 1 ? 's' : ''} cancelled',
                      isCompleted: false,
                      isMergedCancelled: true,
                      mergedOrders: groupOrders,
                      listing: fullListing,
                      onTap: () => _showMergedCancelledDetails(context, fullListing, groupOrders),
                    ));
                  }

                  // Add delisted (inactive) listings
                  final delistedListings = listings.where((l) => l.status == 'inactive').toList();
                  for (final l in delistedListings) {
                    historyItems.add(_HistoryItem(
                      title: l.title,
                      subtitle: 'Delisted',
                      isCompleted: false,
                      isDelisted: true,
                      onTap: () => context.pushNamed(AppRoutes.listingDetail, pathParameters: {'id': l.id}),
                    ));
                  }

                  if (historyItems.isEmpty) {
                    return SliverToBoxAdapter(child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(child: Text('No history items yet', style: typo.bodyMedium.copyWith(color: colors.outlineVariant))),
                    ));
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                      final item = historyItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(radius.card),
                          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getHistoryItemColor(context, item).withValues(alpha: 0.1),
                            child: Icon(_getHistoryItemIcon(item), color: _getHistoryItemColor(context, item), size: 20),
                          ),
                          title: Text(item.title, style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          subtitle: Text(item.subtitle, style: typo.bodySmall),
                          onTap: item.onTap,
                        ),
                      );
                    }, childCount: historyItems.length)),
                  );
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
      ),
    );
  }

  Widget _buildActiveListingCard(listing, imageUrl) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => context.pushNamed(AppRoutes.listingDetail, pathParameters: {'id': listing.id}),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(radius.image),
                child: imageUrl != null
                  ? Image.network(imageUrl, width: 64, height: 64, fit: BoxFit.cover)
                  : Container(width: 64, height: 64, color: colors.surfaceContainerLow, child: const Icon(Icons.image)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(listing.title, style: typo.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('\$${listing.price.toStringAsFixed(0)} · ${listing.transactionType}', 
                  style: typo.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.7))),
              ])),
            ]),
          ),
        ),
        Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.1)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _buildEnhancedStatItem(Icons.visibility_outlined, '${listing.viewCount}', 'Views', () =>
              context.pushNamed(AppRoutes.transactionManagement, pathParameters: {'id': listing.id}, queryParameters: {'tab': '0'})),
            _buildEnhancedStatItem(Icons.bookmark_outline, '${listing.saveCount}', 'Saves', () =>
              context.pushNamed(AppRoutes.transactionManagement, pathParameters: {'id': listing.id}, queryParameters: {'tab': '1'})),
            _buildEnhancedStatItem(Icons.local_offer_outlined, '${listing.inquiryCount}', 'Offers', () =>
              context.pushNamed(AppRoutes.transactionManagement, pathParameters: {'id': listing.id}, queryParameters: {'tab': '2'})),
          ]),
        ),
      ]),
    );
  }

  Widget _buildOrderCard(order, String statusLabel) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.surfaceContainerHigh,
          backgroundImage: order.buyer?.avatarUrl != null && order.buyer!.avatarUrl!.isNotEmpty
              ? NetworkImage(order.buyer!.avatarUrl!)
              : null,
          child: order.buyer?.avatarUrl == null || order.buyer!.avatarUrl!.isEmpty
              ? Icon(Icons.person, color: colors.onSurface.withValues(alpha: 0.5))
              : null,
        ),
        title: Text(order.listing?.title ?? 'Transaction', style: typo.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text('\$${order.totalPrice.toStringAsFixed(0)} · ${order.buyer?.displayName ?? 'Buyer'}\n$statusLabel', style: typo.bodySmall),
        isThreeLine: true,
        onTap: () => context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id}),
      ),
    );
  }

  void _showMergedCancelledDetails(BuildContext context, Listing? listing, List<Order> orders) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.lg)),
        title: Text(listing?.title ?? 'Cancelled Offers', style: typo.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSimpleStat(Icons.visibility_outlined, '${listing?.viewCount ?? 0}', 'Views'),
                _buildSimpleStat(Icons.bookmark_outline, '${listing?.saveCount ?? 0}', 'Saves'),
                _buildSimpleStat(Icons.local_offer_outlined, '${orders.length}', 'Offers'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'All offers were cancelled when you delisted this item or accepted another offer.',
              style: typo.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.7)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(IconData icon, String value, String label) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return Column(children: [
      Icon(icon, size: 16, color: colors.primary),
      const SizedBox(height: 2),
      Text(value, style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold)),
      Text(label, style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5))),
    ]);
  }

  Color _getHistoryItemColor(BuildContext context, _HistoryItem item) {
    final colors = context.smivoColors;
    if (item.isCompleted) return colors.success;
    if (item.isMergedCancelled) return colors.warning;
    if (item.isDelisted) return colors.onSurface.withValues(alpha: 0.5);
    return colors.error;
  }

  IconData _getHistoryItemIcon(_HistoryItem item) {
    if (item.isCompleted) return Icons.check_circle;
    if (item.isMergedCancelled) return Icons.playlist_remove;
    if (item.isDelisted) return Icons.remove_circle;
    return Icons.cancel;
  }

  Widget _buildListViewItem(listing, imageUrl) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.sm),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.pushNamed(AppRoutes.listingDetail, pathParameters: {'id': listing.id}),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius.image),
            child: imageUrl != null
              ? Image.network(imageUrl, width: 40, height: 40, fit: BoxFit.cover)
              : Container(width: 40, height: 40, color: colors.surfaceContainerLow, child: const Icon(Icons.image, size: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => context.pushNamed(AppRoutes.listingDetail, pathParameters: {'id': listing.id}),
            behavior: HitTestBehavior.opaque,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(listing.title, style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('\$${listing.price.toStringAsFixed(0)} · ${listing.transactionType}',
                style: typo.bodySmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5))),
            ]),
          ),
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          _buildMiniStat(Icons.visibility_outlined, listing.viewCount, () =>
            context.pushNamed(AppRoutes.transactionManagement, pathParameters: {'id': listing.id}, queryParameters: {'tab': '0'})),
          const SizedBox(width: 8),
          _buildMiniStat(Icons.bookmark_outline, listing.saveCount, () =>
            context.pushNamed(AppRoutes.transactionManagement, pathParameters: {'id': listing.id}, queryParameters: {'tab': '1'})),
          const SizedBox(width: 8),
          _buildMiniStat(Icons.local_offer_outlined, listing.inquiryCount, () =>
            context.pushNamed(AppRoutes.transactionManagement, pathParameters: {'id': listing.id}, queryParameters: {'tab': '2'})),
        ]),
      ]),
    );
  }

  Widget _buildMiniStat(IconData icon, int count, VoidCallback onTap) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: colors.primary),
        Text('$count', style: typo.labelSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
      ]),
    );
  }

  Widget _buildEnhancedStatItem(IconData icon, String count, String label, VoidCallback onTap) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: colors.primary),
        const SizedBox(height: 2),
        Text(count, style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
        Text(label, style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5))),
      ]),
    );
  }
}

class _HistoryItem {
  const _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isDelisted = false,
    this.isMergedCancelled = false,
    this.mergedOrders,
    this.listing,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isDelisted;
  final bool isMergedCancelled;
  final List<Order>? mergedOrders;
  final dynamic listing; // Can be Listing or OrderListingPreview
  final VoidCallback onTap;
}
