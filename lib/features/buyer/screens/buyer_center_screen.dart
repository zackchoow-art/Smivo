import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/buyer/providers/buyer_center_provider.dart';
import 'package:smivo/features/notifications/providers/notification_provider.dart';

class BuyerCenterScreen extends ConsumerStatefulWidget {
  const BuyerCenterScreen({super.key});

  @override
  ConsumerState<BuyerCenterScreen> createState() => _BuyerCenterScreenState();
}

class _BuyerCenterScreenState extends ConsumerState<BuyerCenterScreen> {
  // NOTE: Track collapse state for each section; all expanded by default.
  final Map<String, bool> _expandedSections = {
    'Requested': true,
    'Awaiting Delivery': true,
    'Active Transactions': true,
    'History': true,
  };

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(buyerOrdersProvider);
    final notificationsAsync = ref.watch(notificationListProvider);
    final notifications = notificationsAsync.valueOrNull ?? [];
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(buyerOrdersProvider);
            await ref.read(buyerOrdersProvider.future);
          },
          child: CustomScrollView(physics: const AlwaysScrollableScrollPhysics(), slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 8),
                  Text('Buyer Center', style: typo.headlineLarge.copyWith(fontWeight: FontWeight.w900)),
                ]),
              ]),
              const SizedBox(height: 8),
              Text('Track your purchase requests and orders.', style: typo.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: 16),
              // Search bar — expands all sections when query is active
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    // NOTE: Auto-expand all sections during search so results
                    // in collapsed sections are not hidden from the user.
                    if (value.isNotEmpty) {
                      for (final key in _expandedSections.keys) {
                        _expandedSections[key] = true;
                      }
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by item, seller, or price…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.md)),
                ),
              ),
            ])),
          ),
          ordersAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
            data: (orders) {
              // Apply search filter first, then categorise
              final filtered = _searchQuery.isEmpty
                  ? orders
                  : orders.where((o) {
                      final query = _searchQuery.toLowerCase();
                      // NOTE: listing.title is required String, not nullable.
                      final title = o.listing?.title.toLowerCase() ?? '';
                      final seller = o.seller?.displayName?.toLowerCase() ?? '';
                      final buyer = o.buyer?.displayName?.toLowerCase() ?? '';
                      final price = o.totalPrice.toStringAsFixed(2);
                      return title.contains(query) ||
                          seller.contains(query) ||
                          buyer.contains(query) ||
                          price.contains(query);
                    }).toList();

              // REQUESTED: pending orders
              final requested = filtered.where((o) => o.status == 'pending').toList();

              // AWAITING DELIVERY: confirmed but delivery not yet done by both
              final awaitingDelivery = filtered.where((o) =>
                o.status == 'confirmed' &&
                !(o.deliveryConfirmedByBuyer && o.deliveryConfirmedBySeller),
              ).toList();

              // ACTIVE TRANSACTIONS: rental orders in active lifecycle
              final activeTransactions = filtered.where((o) =>
                o.status == 'confirmed' &&
                o.deliveryConfirmedByBuyer &&
                o.deliveryConfirmedBySeller &&
                o.rentalStatus != null,
              ).toList();

              // HISTORY: completed or cancelled
              final history = filtered.where((o) => o.status == 'completed' || o.status == 'cancelled').toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.shopping_bag_outlined, size: 48, color: colors.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text(_searchQuery.isNotEmpty ? 'No matching orders' : 'No orders yet',
                      style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
                  const SizedBox(height: 8),
                  Text(_searchQuery.isNotEmpty ? 'Try a different keyword.' : 'Browse listings to find what you need!',
                      style: typo.bodySmall.copyWith(color: colors.outlineVariant)),
                ])));
              }
              return SliverMainAxisGroup(slivers: [
                ..._buildSection('Requested', requested, Icons.hourglass_top, colors.warning, notifications),
                ..._buildSection('Awaiting Delivery', awaitingDelivery, Icons.local_shipping, colors.primary, notifications),
                ..._buildSection('Active Transactions', activeTransactions, Icons.sync, colors.success, notifications),
                ..._buildSection('History', history, Icons.history, colors.outlineVariant, notifications),
              ]);
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
        ),
      ),
    );
  }

  List<Widget> _buildSection(String title, List orders, IconData icon, Color color, List notifications) {
    if (orders.isEmpty) return [];
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final isExpanded = _expandedSections[title] ?? true;

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        sliver: SliverToBoxAdapter(
          child: InkWell(
            borderRadius: BorderRadius.circular(radius.sm),
            onTap: () => setState(() => _expandedSections[title] = !isExpanded),
            child: Row(children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$title (${orders.length})',
                  style: typo.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 20,
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ]),
          ),
        ),
      ),
      // NOTE: Hide the list entirely when the section is collapsed.
      if (isExpanded)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
            final order = orders[index];
            final listing = order.listing;
            final imageUrl = listing?.images.isNotEmpty == true ? listing!.images.first.imageUrl : null;
            final sellerName = order.seller?.displayName ?? 'Seller';
            final dateStr = DateFormat('M/d/yyyy HH:mm').format(order.createdAt);
            final hasUnread = notifications.any((n) => !n.isRead && n.relatedOrderId == order.id);

            return InkWell(
              onTap: () => context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id}),
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
                          TextSpan(
                            text: title == 'Awaiting Delivery'
                              ? ' · ${order.pickupLocation?.name ?? 'Unknown location'}'
                              : ' · $sellerName',
                          ),
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
                      if (title == 'Awaiting Delivery')
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
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(radius.full)),
                              child: Text(
                                'Awaiting Pickup',
                                textAlign: TextAlign.center,
                                style: typo.labelSmall.copyWith(color: colors.surfaceContainerLowest, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _StatusChip(order: order, hasUnread: hasUnread),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: typo.labelSmall.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.4),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ]),
              ),
            );
          }, childCount: orders.length)),
        ),
    ];
  }
}

/// Displays a context-aware status chip for buyer orders.
///
/// Uses both order status and rental status to show the most
/// meaningful label for the buyer's current state.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.order, this.hasUnread = false});
  final dynamic order;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    final (bgColor, textColor, label) = _resolveChip(colors);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasUnread) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Container(
          constraints: const BoxConstraints(minWidth: 72),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(context.smivoRadius.full)),
          child: Text(
            label, 
            textAlign: TextAlign.center,
            style: typo.labelSmall.copyWith(color: textColor, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  (Color, Color, String) _resolveChip(dynamic colors) {
    final status = order.status as String;
    final rentalStatus = order.rentalStatus as String?;

    return switch (status) {
      'pending' => (colors.statusPending, colors.surfaceContainerLowest, 'Pending'),
      'confirmed' => _confirmedChip(colors, rentalStatus),
      'completed' => (colors.success, colors.surfaceContainerLowest, 'Done'),
      'cancelled' => (colors.statusCancelled, colors.surfaceContainerLowest, 'Missed'),
      _ => (colors.outlineVariant, colors.surfaceContainerLowest, status),
    };
  }

  /// More granular chip labels for confirmed orders based on delivery/rental state.
  (Color, Color, String) _confirmedChip(dynamic colors, String? rentalStatus) {
    final deliveredByBoth = (order.deliveryConfirmedByBuyer as bool) &&
        (order.deliveryConfirmedBySeller as bool);

    if (!deliveredByBoth) {
      return (colors.statusConfirmed, colors.surfaceContainerLowest, 'Pickup');
    }

    // Delivery done — show rental lifecycle status
    return switch (rentalStatus) {
      'active' => (colors.success, colors.surfaceContainerLowest, 'Active'),
      'return_requested' => (colors.warning, colors.surfaceContainerLowest, 'Returning'),
      'returned' => (colors.primary, colors.surfaceContainerLowest, 'Returned'),
      'deposit_refunded' => (colors.success, colors.surfaceContainerLowest, 'Refunded'),
      _ => (colors.statusConfirmed, colors.surfaceContainerLowest, 'Active'),
    };
  }
}
