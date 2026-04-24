import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/buyer/providers/buyer_center_provider.dart';

class BuyerCenterScreen extends ConsumerStatefulWidget {
  const BuyerCenterScreen({super.key});

  @override
  ConsumerState<BuyerCenterScreen> createState() => _BuyerCenterScreenState();
}

class _BuyerCenterScreenState extends ConsumerState<BuyerCenterScreen> {
  bool _isListView = false;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(buyerOrdersProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 8),
                  Text('Buyer Center', style: typo.headlineLarge.copyWith(fontWeight: FontWeight.w900)),
                ]),
                IconButton(
                  icon: Icon(_isListView ? Icons.grid_view_outlined : Icons.list_outlined, size: 20, color: colors.primary),
                  onPressed: () => setState(() => _isListView = !_isListView),
                  visualDensity: VisualDensity.compact,
                ),
              ]),
              const SizedBox(height: 8),
              Text('Track your purchase requests and orders.', style: typo.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.7))),
            ])),
          ),
          ordersAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
            data: (orders) {
              final requested = orders.where((o) => o.status == 'pending').toList();
              final active = orders.where((o) => o.status == 'confirmed').toList();
              final history = orders.where((o) => o.status == 'completed' || o.status == 'cancelled').toList();
              
              if (orders.isEmpty) {
                return SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.shopping_bag_outlined, size: 48, color: colors.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text('No orders yet', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
                  const SizedBox(height: 8),
                  Text('Browse listings to find what you need!', style: typo.bodySmall.copyWith(color: colors.outlineVariant)),
                ])));
              }
              return SliverMainAxisGroup(slivers: [
                ..._buildSection('REQUESTED', requested, Icons.hourglass_top, colors.warning),
                ..._buildSection('ACTIVE', active, Icons.local_shipping, colors.primary),
                ..._buildSection('HISTORY', history, Icons.history, colors.outlineVariant),
              ]);
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
      ),
    );
  }

  List<Widget> _buildSection(String title, List orders, IconData icon, Color color) {
    if (orders.isEmpty) return [];
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        sliver: SliverToBoxAdapter(child: Row(children: [
          Icon(icon, size: 16, color: color), const SizedBox(width: 8),
          Text('$title (${orders.length})', style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),
        ])),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
          final order = orders[index];
          final isMissed = order.status == 'cancelled';
          final listing = order.listing;
          final imageUrl = listing?.images.isNotEmpty == true ? listing!.images.first.imageUrl : null;
          final sellerName = order.seller?.displayName ?? 'Seller';
          final dateStr = DateFormat('MMM d').format(order.createdAt);

          if (_isListView) {
            return _buildListViewItem(order, listing, imageUrl, sellerName, dateStr, icon, color, isMissed);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(radius.card),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: InkWell(
              onTap: () => context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id}),
              borderRadius: BorderRadius.circular(radius.card),
              child: Column(children: [
                Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(radius.image),
                    child: imageUrl != null
                      ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                      : Container(width: 60, height: 60, color: colors.surfaceContainerHigh, child: const Icon(Icons.image)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(listing?.title ?? 'Order', style: typo.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('\$${order.totalPrice.toStringAsFixed(0)} · $sellerName',
                      style: typo.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.7))),
                    Text(dateStr, style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5))),
                  ])),
                  const SizedBox(width: 8),
                  _StatusChip(status: order.status),
                ]),
              ]),
            ),
          );
        }, childCount: orders.length)),
      ),
    ];
  }

  Widget _buildListViewItem(order, listing, imageUrl, sellerName, dateStr, icon, color, isMissed) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.sm),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        dense: true,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(radius.xs),
          child: imageUrl != null
            ? Image.network(imageUrl, width: 32, height: 32, fit: BoxFit.cover)
            : Container(width: 32, height: 32, color: colors.surfaceContainerHigh, child: const Icon(Icons.image, size: 16)),
        ),
        title: Text(listing?.title ?? 'Order', style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('\$${order.totalPrice.toStringAsFixed(0)} · $sellerName', style: typo.bodySmall),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(dateStr, style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.4))),
          const SizedBox(width: 8),
          _StatusChip(status: order.status, isCompact: true),
        ]),
        onTap: () => context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id}),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, this.isCompact = false});
  final String status;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final (bgColor, textColor, label) = switch (status) {
      'pending' => (colors.statusPending.withValues(alpha: 0.15), colors.statusPending, 'Pending'),
      'confirmed' => (colors.statusConfirmed.withValues(alpha: 0.15), colors.statusConfirmed, 'Active'),
      'completed' => (colors.success.withValues(alpha: 0.15), colors.success, 'Done'),
      'cancelled' => (colors.statusCancelled.withValues(alpha: 0.15), colors.statusCancelled, 'Missed'),
      _ => (colors.outlineVariant.withValues(alpha: 0.15), colors.outlineVariant, status),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 10, vertical: isCompact ? 2 : 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(context.smivoRadius.full)),
      child: Text(label, style: (isCompact ? typo.labelSmall : typo.labelSmall).copyWith(
        color: textColor, fontWeight: FontWeight.w700, fontSize: isCompact ? 10 : null)),
    );
  }
}
