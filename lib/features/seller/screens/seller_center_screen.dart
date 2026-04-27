import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/utils/price_format.dart';
import 'package:smivo/features/seller/providers/seller_center_provider.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:intl/intl.dart';
import 'package:smivo/features/notifications/providers/notification_provider.dart';
import 'package:smivo/features/shared/providers/status_resolver_provider.dart';

import 'package:smivo/shared/widgets/sticky_header_delegate.dart';
import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';
import 'package:smivo/features/seller/widgets/ikea_seller_order_card.dart';

class SellerCenterScreen extends ConsumerStatefulWidget {
  const SellerCenterScreen({super.key});

  @override
  ConsumerState<SellerCenterScreen> createState() => _SellerCenterScreenState();
}

class _SellerCenterScreenState extends ConsumerState<SellerCenterScreen> {
  final Map<String, bool> _expandedSections = {
    'Active Listings': true,
    'Awaiting Delivery': true,
    'Active Transactions': true,
    'History': true,
  };
  String _searchQuery = '';

  void _handleOrderTap(String orderId, bool hasUnread) {
    if (hasUnread) {
      final notifications = ref.read(notificationListProvider).valueOrNull ?? [];
      final unreadNotifs = notifications.where((n) => !n.isRead && n.relatedOrderId == orderId);
      for (final n in unreadNotifs) {
        ref.read(notificationListProvider.notifier).markAsRead(n.id);
      }
    }
    context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': orderId});
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(myListingsProvider);
    final ordersAsync = ref.watch(sellerOrdersProvider);
    final notificationsAsync = ref.watch(notificationListProvider);
    final notifications = notificationsAsync.valueOrNull ?? [];
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        top: false,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myListingsProvider);
            ref.invalidate(sellerOrdersProvider);
            await Future.wait([
              ref.read(myListingsProvider.future),
              ref.read(sellerOrdersProvider.future),
            ]);
          },
          child: CustomScrollView(physics: const AlwaysScrollableScrollPhysics(), slivers: [
          const CollapsingTitleAppBar(
            title: 'Seller Center',
            subtitle: 'Manage your listings and sales.',
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyHeaderDelegate(
              backgroundColor: colors.surfaceContainerLowest,
              minHeight: 64.0,
              maxHeight: 64.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      if (value.isNotEmpty) {
                        for (final key in _expandedSections.keys) {
                          _expandedSections[key] = true;
                        }
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search orders and listings…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => setState(() => _searchQuery = ''))
                      : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.md)),
                    filled: true,
                    fillColor: colors.surfaceContainerLow,
                  ),
                ),
              ),
            ),
          ),
          // 1. ACTIVE LISTINGS Section
          listingsAsync.when(
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            data: (listings) {
              final allActiveListings = listings.where((l) => l.status == 'active').toList();
              final activeListings = _searchQuery.isEmpty 
                ? allActiveListings 
                : allActiveListings.where((l) {
                    final q = _searchQuery.toLowerCase();
                    return l.title.toLowerCase().contains(q) || 
                           (l.description?.toLowerCase().contains(q) ?? false) || 
                           l.price.toStringAsFixed(2).contains(q);
                  }).toList();
              if (activeListings.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

              final isExpanded = _expandedSections['Active Listings'] ?? true;
              
              return SliverMainAxisGroup(slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(radius.sm),
                      onTap: () => setState(() => _expandedSections['Active Listings'] = !isExpanded),
                      child: Row(children: [
                        Icon(Icons.storefront_outlined, size: 16, color: colors.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Active Listings (${activeListings.length})', style: typo.titleMedium.copyWith(
                          color: colors.onSurface, fontWeight: FontWeight.w600))),
                        Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 20, color: colors.onSurface.withValues(alpha: 0.5)),
                      ]),
                    ),
                  ),
                ),
                if (isExpanded)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: colors.primary == const Color(0xFF004181)
                        ? SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final listing = activeListings[index];
                                return IkeaSellerOrderCard(
                                  cardType: IkeaSellerCardType.activeListing,
                                  listing: listing,
                                  hasUnread: false,
                                  onTap: () => context.pushNamed(
                                    AppRoutes.listingDetail,
                                    pathParameters: {'id': listing.id},
                                  ),
                                  statTaps: [
                                    () => context.pushNamed(AppRoutes.transactionManagement,
                                        pathParameters: {'id': listing.id}, queryParameters: {'tab': '0'}),
                                    () => context.pushNamed(AppRoutes.transactionManagement,
                                        pathParameters: {'id': listing.id}, queryParameters: {'tab': '1'}),
                                    () => context.pushNamed(AppRoutes.transactionManagement,
                                        pathParameters: {'id': listing.id}, queryParameters: {'tab': '2'}),
                                  ],
                                );
                              },
                              childCount: activeListings.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                            final listing = activeListings[index];
                            final imageUrl = listing.images.isNotEmpty ? listing.images.first.imageUrl : null;
                            return _buildActiveListingCard(listing, imageUrl);
                          }, childCount: activeListings.length)),
                  ),
              ]);
            },
          ),

          // 2. AWAITING DELIVERY Section (Accepted but not delivered)
          ordersAsync.when(
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            data: (orders) {
              final allAwaitingDelivery = orders.where((o) =>
                o.status == 'confirmed' &&
                !(o.deliveryConfirmedByBuyer && o.deliveryConfirmedBySeller)
              ).toList();
              
              final awaitingDelivery = _searchQuery.isEmpty ? allAwaitingDelivery : allAwaitingDelivery.where((o) {
                final q = _searchQuery.toLowerCase();
                final title = o.listing?.title.toLowerCase() ?? '';
                final buyer = o.buyer?.displayName?.toLowerCase() ?? '';
                final price = o.totalPrice.toStringAsFixed(2);
                return title.contains(q) || buyer.contains(q) || price.contains(q);
              }).toList();
              
              if (awaitingDelivery.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

              final isExpanded = _expandedSections['Awaiting Delivery'] ?? true;

              return SliverMainAxisGroup(slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(radius.sm),
                      onTap: () => setState(() => _expandedSections['Awaiting Delivery'] = !isExpanded),
                      child: Row(children: [
                        Icon(Icons.local_shipping, size: 16, color: colors.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Awaiting Delivery (${awaitingDelivery.length})', style: typo.titleMedium.copyWith(
                          color: colors.onSurface, fontWeight: FontWeight.w600))),
                        Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 20, color: colors.onSurface.withValues(alpha: 0.5)),
                      ]),
                    ),
                  ),
                ),
                if (isExpanded)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: colors.primary == const Color(0xFF004181)
                        ? SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final order = awaitingDelivery[index];
                                final hasUnread = notifications.any((n) => !n.isRead && n.relatedOrderId == order.id);
                                return IkeaSellerOrderCard(
                                  cardType: IkeaSellerCardType.awaitingDelivery,
                                  order: order,
                                  hasUnread: hasUnread,
                                  onTap: () => _handleOrderTap(order.id, hasUnread),
                                );
                              },
                              childCount: awaitingDelivery.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                            final order = awaitingDelivery[index];
                            final hasUnread = notifications.any((n) => !n.isRead && n.relatedOrderId == order.id);
                            return _buildAwaitingDeliveryCard(order, hasUnread);
                          }, childCount: awaitingDelivery.length)),
                  ),
              ]);
            },
          ),

          // 3. ACTIVE TRANSACTIONS Section (In-progress rentals)
          ordersAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (orders) {
              final allActiveTransactions = orders.where((o) =>
                o.status == 'confirmed' &&
                (o.rentalStatus == 'active' ||
                 o.rentalStatus == 'return_requested' ||
                 o.rentalStatus == 'returned')
              ).toList();

              final activeTransactions = _searchQuery.isEmpty ? allActiveTransactions : allActiveTransactions.where((o) {
                final q = _searchQuery.toLowerCase();
                final title = o.listing?.title.toLowerCase() ?? '';
                final buyer = o.buyer?.displayName?.toLowerCase() ?? '';
                final price = o.totalPrice.toStringAsFixed(2);
                return title.contains(q) || buyer.contains(q) || price.contains(q);
              }).toList();
              
              if (activeTransactions.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

              final isExpanded = _expandedSections['Active Transactions'] ?? true;

              return SliverMainAxisGroup(slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(radius.sm),
                      onTap: () => setState(() => _expandedSections['Active Transactions'] = !isExpanded),
                      child: Row(children: [
                        Icon(Icons.sync, size: 16, color: colors.success),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Active Transactions (${activeTransactions.length})', style: typo.titleMedium.copyWith(
                          color: colors.onSurface, fontWeight: FontWeight.w600))),
                        Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 20, color: colors.onSurface.withValues(alpha: 0.5)),
                      ]),
                    ),
                  ),
                ),
                if (isExpanded)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: colors.primary == const Color(0xFF004181)
                        ? SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final order = activeTransactions[index];
                                // NOTE: Use StatusResolver for DB-driven labels, same as Teal card.
                                final resolver =
                                    ref.watch(statusResolverProvider).valueOrNull;
                                final statusLabel = order.rentalStatus != null
                                    ? (resolver?.rentalLabel(order.rentalStatus!) ??
                                        order.rentalStatus!.replaceAll('_', ' ').toUpperCase())
                                    : (resolver?.orderLabel(order.status) ??
                                        order.status.toUpperCase());
                                final hasUnread = notifications.any((n) => !n.isRead && n.relatedOrderId == order.id);
                                return IkeaSellerOrderCard(
                                  cardType: IkeaSellerCardType.activeTransaction,
                                  order: order,
                                  statusLabel: statusLabel,
                                  hasUnread: hasUnread,
                                  onTap: () => _handleOrderTap(order.id, hasUnread),
                                );
                              },
                              childCount: activeTransactions.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                            final order = activeTransactions[index];
                            final statusLabel = order.rentalStatus?.replaceAll('_', ' ').toUpperCase() ?? order.status.toUpperCase();
                            final hasUnread = notifications.any((n) => !n.isRead && n.relatedOrderId == order.id);
                            return _buildOrderCard(order, statusLabel, hasUnread);
                          }, childCount: activeTransactions.length)),
                  ),
              ]);
            },
          ),

          // 4. HISTORY Section (Smart Merge)
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
                    final fullListing = listings.where((l) => l.id == o.listingId).firstOrNull;
                    historyItems.add(_HistoryItem(
                      title: o.listing?.title ?? fullListing?.title ?? 'Order',
                      subtitle: '${formatOrderPrice(o)} · ${o.buyer?.displayName ?? 'Buyer'}',
                      isCompleted: true,
                      orderId: o.id,
                      listingId: o.listingId,
                      createdAt: fullListing?.createdAt ?? o.createdAt,
                      updatedAt: o.updatedAt,
                      imageUrl: o.listing?.images.firstOrNull?.imageUrl ?? fullListing?.images.firstOrNull?.imageUrl,
                      onTap: () {
                        final hasUnread = notifications.any((n) => !n.isRead && n.relatedOrderId == o.id);
                        _handleOrderTap(o.id, hasUnread);
                      },
                    ));
                  }

                  // Add merged cancelled groups (only if no active sibling)
                  for (final entry in cancelledByListing.entries) {
                    if (listingsWithActiveSibling.contains(entry.key)) {
                      continue; // Skip cancelled ones if an active order exists for this listing
                    }
                    
                    final groupOrders = entry.value;
                    final listingPreview = groupOrders.first.listing;
                    final fullListing = listings.where((l) => l.id == entry.key).firstOrNull;
                    final title = fullListing?.title ?? listingPreview?.title ?? 'Listing';
                    
                    historyItems.add(_HistoryItem(
                      title: title,
                      subtitle: '${groupOrders.length} offer${groupOrders.length > 1 ? 's' : ''} cancelled',
                      isCompleted: false,
                      isMergedCancelled: true,
                      mergedOrders: groupOrders,
                      listing: fullListing,
                      listingId: entry.key,
                      createdAt: fullListing?.createdAt ?? groupOrders.first.createdAt,
                      updatedAt: groupOrders.first.updatedAt, // Use most recent update
                      imageUrl: fullListing?.images.firstOrNull?.imageUrl ?? listingPreview?.images.firstOrNull?.imageUrl,
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
                      listingId: l.id,
                      createdAt: l.createdAt,
                      updatedAt: l.updatedAt,
                      imageUrl: l.images.firstOrNull?.imageUrl,
                      onTap: () => context.pushNamed(AppRoutes.listingDetail, pathParameters: {'id': l.id}),
                    ));
                  }

                  final filteredHistory = _searchQuery.isEmpty ? historyItems : historyItems.where((i) {
                    final q = _searchQuery.toLowerCase();
                    return i.title.toLowerCase().contains(q) || i.subtitle.toLowerCase().contains(q);
                  }).toList();
                  
                  if (filteredHistory.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  final isExpanded = _expandedSections['History'] ?? true;

                  return SliverMainAxisGroup(slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      sliver: SliverToBoxAdapter(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(radius.sm),
                          onTap: () => setState(() => _expandedSections['History'] = !isExpanded),
                          child: Row(children: [
                            Icon(Icons.history, size: 16, color: colors.outlineVariant),
                            const SizedBox(width: 8),
                            Expanded(child: Text('History (${filteredHistory.length})', style: typo.titleMedium.copyWith(
                              color: colors.onSurface, fontWeight: FontWeight.w600))),
                            Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 20, color: colors.onSurface.withValues(alpha: 0.5)),
                          ]),
                        ),
                      ),
                    ),
                    if (isExpanded)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: colors.primary == const Color(0xFF004181)
                        ? SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = filteredHistory[index];
                                return IkeaSellerOrderCard(
                                  cardType: IkeaSellerCardType.history,
                                  historyItem: item,
                                  hasUnread: false,
                                  onTap: item.onTap,
                                );
                              },
                              childCount: filteredHistory.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = filteredHistory[index];
                              final dateStr =
                                  DateFormat('M/d/yyyy HH:mm').format(item.updatedAt ?? item.createdAt ?? DateTime.now());

                              return InkWell(
                                onTap: item.onTap,
                                borderRadius: BorderRadius.circular(radius.card),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(radius.card),
                                    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(radius.image),
                                      child: item.imageUrl != null
                                          ? Image.network(item.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)
                                          : Container(
                                              width: 48,
                                              height: 48,
                                              color: colors.surfaceContainerHigh,
                                              child: const Icon(Icons.image)),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(item.title,
                                          style: typo.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      if (item.subtitle.contains(r'$'))
                                        RichText(
                                          text: TextSpan(
                                            style: typo.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.7)),
                                            children: [
                                              TextSpan(
                                                text: item.subtitle.split(' · ').first,
                                                style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: item.subtitle.contains(' · ')
                                                    ? ' · ${item.subtitle.split(' · ').sublist(1).join(' · ')}'
                                                    : '',
                                              ),
                                            ],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      else
                                        Text(item.subtitle,
                                            style: typo.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.7))),
                                    ])),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _buildHistoryStatusChip(item),
                                        const SizedBox(height: 4),
                                        Text(
                                          dateStr,
                                          style: typo.labelSmall.copyWith(
                                            color: colors.onSurface.withValues(alpha: 0.4),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]),
                                ),
                              );
                            },
                            childCount: filteredHistory.length,
                          ),
                        ),
                      ),
                  ]);
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
        ),
      ),
    );
  }

  Widget _buildActiveListingCard(listing, imageUrl) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: GestureDetector(
        onTap: () => context.pushNamed(AppRoutes.listingDetail, pathParameters: {'id': listing.id}),
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(radius.image),
              child: imageUrl != null
                ? Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover)
                : Container(width: 48, height: 48, color: colors.surfaceContainerHigh, child: const Icon(Icons.image)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(listing.title, style: typo.bodyLarge.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: typo.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.7)),
                  children: [
                    TextSpan(
                      text: '\$${listing.price.toStringAsFixed(0)}',
                      style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' · ${listing.transactionType}'),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ])),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEnhancedStatItem(Icons.visibility_outlined, '${listing.viewCount}', () =>
                  context.pushNamed(AppRoutes.transactionManagement, pathParameters: {'id': listing.id}, queryParameters: {'tab': '0'})),
                const SizedBox(width: 32),
                _buildEnhancedStatItem(Icons.bookmark_outline, '${listing.saveCount}', () =>
                  context.pushNamed(AppRoutes.transactionManagement, pathParameters: {'id': listing.id}, queryParameters: {'tab': '1'})),
                const SizedBox(width: 32),
                _buildEnhancedStatItem(Icons.local_offer_outlined, '${listing.inquiryCount}', () =>
                  context.pushNamed(AppRoutes.transactionManagement, pathParameters: {'id': listing.id}, queryParameters: {'tab': '2'})),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAwaitingDeliveryCard(Order order, bool hasUnread) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final listing = order.listing;
    final imageUrl = listing?.images.isNotEmpty == true ? listing!.images.first.imageUrl : null;

    return InkWell(
      onTap: () => _handleOrderTap(order.id, hasUnread),
      borderRadius: BorderRadius.circular(radius.card),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(radius.card),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(radius.image),
            child: imageUrl != null
              ? Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover)
              : Container(width: 48, height: 48, color: colors.surfaceContainerHigh, child: const Icon(Icons.image)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(listing?.title ?? 'Order', style: typo.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: typo.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.7)),
                children: [
                  TextSpan(
                    text: '\$${order.totalPrice.toStringAsFixed(0)}',
                    style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' · ${order.pickupLocation?.name ?? 'Unknown location'}'),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ])),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasUnread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
                    ),
                  Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(radius.full)),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Awaiting\nDelivery', 
                        textAlign: TextAlign.center,
                        style: typo.labelSmall.copyWith(color: colors.surfaceContainerLowest, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildOrderCard(order, String statusLabel, bool hasUnread) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final listingTitle = order.listing?.title ?? 'Transaction';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Left side: image + title → Listing Detail
          Expanded(
            child: GestureDetector(
              onTap: () => context.pushNamed(
                AppRoutes.listingDetail,
                pathParameters: {'id': order.listingId},
              ),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colors.surfaceContainerHigh,
                    backgroundImage: order.buyer?.avatarUrl != null &&
                            order.buyer!.avatarUrl!.isNotEmpty
                        ? NetworkImage(order.buyer!.avatarUrl!)
                        : null,
                    child: order.buyer?.avatarUrl == null ||
                            order.buyer!.avatarUrl!.isEmpty
                        ? Icon(Icons.person,
                            color:
                                colors.onSurface.withValues(alpha: 0.5))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(listingTitle,
                            style: typo.bodyMedium
                                .copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: typo.bodySmall.copyWith(
                                color: colors.onSurface
                                    .withValues(alpha: 0.6)),
                            children: [
                              TextSpan(
                                text: formatOrderPrice(order),
                                style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' · ${order.buyer?.displayName ?? 'Buyer'}'),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          constraints: const BoxConstraints(minWidth: 72),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius:
                                BorderRadius.circular(radius.full),
                          ),
                          child: Text(statusLabel,
                              textAlign: TextAlign.center,
                              style: typo.labelSmall.copyWith(
                                color: colors.surfaceContainerLowest,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Right side: timestamps → Order Detail
          GestureDetector(
            onTap: () => _handleOrderTap(order.id, hasUnread),
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minWidth: 64, minHeight: 44),
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasUnread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                          color: colors.error, shape: BoxShape.circle),
                    ),
                  Text(
                    DateFormat('MM/dd HH:mm')
                        .format(order.createdAt.toLocal()),
                    style: typo.labelSmall.copyWith(
                        fontSize: 10,
                        color:
                            colors.onSurface.withValues(alpha: 0.4)),
                  ),
                  Text(
                    DateFormat('MM/dd HH:mm')
                        .format(order.updatedAt.toLocal()),
                    style: typo.labelSmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colors.primary),
                  ),
                  const SizedBox(height: 4),
                  Icon(Icons.chevron_right,
                      size: 16,
                      color: colors.onSurface.withValues(alpha: 0.3)),
                ],
              ),
            ),
          ),
        ],
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
                _buildSimpleStat(Icons.visibility_outlined, '${listing?.viewCount ?? 0}'),
                _buildSimpleStat(Icons.bookmark_outline, '${listing?.saveCount ?? 0}'),
                _buildSimpleStat(Icons.local_offer_outlined, '${orders.length}'),
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

  Widget _buildSimpleStat(IconData icon, String value) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return Column(children: [
      Icon(icon, size: 16, color: colors.primary),
      const SizedBox(height: 2),
      Text(value, style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildEnhancedStatItem(IconData icon, String count, VoidCallback onTap) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: colors.primary),
        const SizedBox(height: 2),
        Text(count, style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
      ]),
    );
  }

  Widget _buildHistoryStatusChip(_HistoryItem item) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final bgColor = item.isCompleted ? colors.success : colors.statusCancelled;
    final label = item.isCompleted ? 'Done' : 'Cancelled';

    return Container(
      constraints: const BoxConstraints(minWidth: 72),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(radius.full)),
      child: Text(
        label, 
        textAlign: TextAlign.center,
        style: typo.labelSmall.copyWith(color: colors.surfaceContainerLowest, fontWeight: FontWeight.w700),
      ),
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
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.orderId,
    this.listingId,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isDelisted;
  final bool isMergedCancelled;
  final List<Order>? mergedOrders;
  final dynamic listing; // Can be Listing or OrderListingPreview
  final VoidCallback onTap;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final String? orderId;
  final String? listingId;
}
