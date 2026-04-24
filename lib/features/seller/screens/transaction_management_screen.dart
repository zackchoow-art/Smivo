import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/seller/providers/transaction_stats_provider.dart';
import 'package:smivo/features/seller/providers/listing_views_provider.dart';
import 'package:smivo/features/chat/widgets/chat_popup.dart';

class TransactionManagementScreen extends ConsumerWidget {
  const TransactionManagementScreen({
    super.key,
    required this.listingId,
    this.initialTab = 0,
  });
  final String listingId;
  final int initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('Manage Transactions'),
          bottom: const TabBar(tabs: [Tab(text: 'Views'), Tab(text: 'Saves'), Tab(text: 'Offers')]),
        ),
        body: TabBarView(children: [
          _ViewsTab(listingId: listingId),
          _SavesTab(listingId: listingId),
          _OffersTab(listingId: listingId),
        ]),
      ),
    );
  }
}

/// Views tab — shows individual viewer details.
class _ViewsTab extends ConsumerWidget {
  const _ViewsTab({required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewsAsync = ref.watch(listingViewsProvider(listingId));
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return viewsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (views) {
        if (views.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.visibility_outlined, size: 48, color: colors.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('No views yet', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
          ]));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16), itemCount: views.length,
          itemBuilder: (context, index) {
            final view = views[index];
            final timeStr = DateFormat('MMM d, h:mm a').format(view.viewedAt.toLocal());
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(radius.md),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(
                  backgroundColor: colors.surfaceContainerHigh,
                  backgroundImage: view.viewerAvatarUrl != null ? NetworkImage(view.viewerAvatarUrl!) : null,
                  child: view.viewerAvatarUrl == null ? Icon(Icons.person, color: colors.onSurface) : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(view.viewerName ?? 'Anonymous Guest', style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.chat_outlined, size: 20),
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat coming soon')));
                      },
                    ),
                  ]),
                  Text('★★★★☆ 4.0', style: typo.bodySmall.copyWith(color: colors.priceAccent)),
                  const SizedBox(height: 4),
                  Text('Viewed on $timeStr', style: typo.bodySmall.copyWith(color: colors.onSurface.withValues(alpha: 0.6))),
                ])),
              ]),
            );
          },
        );
      },
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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return savesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (saves) {
        if (saves.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.bookmark_border, size: 48, color: colors.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('No saves yet', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
          ]));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16), itemCount: saves.length,
          itemBuilder: (context, index) {
            final save = saves[index];
            final dateStr = DateFormat('MMM d, yyyy').format(save.createdAt);
            // NOTE: fetchSavedByListing joins user profiles but SavedListing model doesn't have it yet.
            // For now use placeholder but the design matches.
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(radius.md),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('User', style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.chat_outlined, size: 20),
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat coming soon')));
                      },
                    ),
                  ]),
                  Text('★★★★☆ 4.0', style: typo.bodySmall.copyWith(color: colors.priceAccent)),
                  const SizedBox(height: 4),
                  Text('Saved on $dateStr', style: typo.bodySmall.copyWith(color: colors.onSurface.withValues(alpha: 0.6))),
                ])),
              ]),
            );
          },
        );
      },
    );
  }
}

/// Offers tab — shows all orders with Accept buttons.
class _OffersTab extends ConsumerWidget {
  const _OffersTab({required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(listingOrdersProvider(listingId));
    final actionsState = ref.watch(orderActionsProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.receipt_long_outlined, size: 48, color: colors.onSurface.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text('No offers yet', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
            ]),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(context, ref, order, actionsState.isLoading);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, Order order, bool isActing) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final buyerName = order.buyer?.displayName ?? 'Unknown Buyer';
    final dateStr = DateFormat('MMM d, h:mm a').format(order.createdAt.toLocal());
    final isPending = order.status == 'pending';

    Color statusColor;
    String statusLabel;
    switch (order.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusLabel = 'Pending';
      case 'confirmed':
        statusColor = colors.primary;
        statusLabel = 'Accepted';
      case 'completed':
        statusColor = colors.success;
        statusLabel = 'Completed';
      case 'cancelled':
        statusColor = colors.error;
        statusLabel = 'Cancelled';
      default:
        statusColor = colors.outlineVariant;
        statusLabel = order.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.1),
            backgroundImage: order.buyer?.avatarUrl != null ? NetworkImage(order.buyer!.avatarUrl!) : null,
            child: order.buyer?.avatarUrl == null ? Icon(Icons.person, color: statusColor, size: 20) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(buyerName, style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.chat_outlined, size: 20),
                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  onPressed: () async {
                    final currentUserId = ref.read(authStateProvider).valueOrNull?.id;
                    if (currentUserId == null) return;
                    final chatRepo = ref.read(chatRepositoryProvider);
                    final room = await chatRepo.getOrCreateChatRoom(
                      listingId: order.listingId,
                      buyerId: order.buyerId,
                      sellerId: order.sellerId,
                    );
                    if (!context.mounted) return;
                    showChatPopup(
                      context,
                      chatRoomId: room.id,
                      otherUserName: order.buyer?.displayName ?? 'Buyer',
                      otherUserAvatar: order.buyer?.avatarUrl,
                      listingTitle: order.listing?.title ?? '',
                      listingPrice: order.totalPrice,
                      listingImageUrl: order.listing?.images.firstOrNull?.imageUrl,
                    );
                  },
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(radius.xl),
                  ),
                  child: Text(statusLabel, style: typo.labelSmall.copyWith(
                    color: statusColor, fontWeight: FontWeight.w700, fontSize: 10,
                  )),
                ),
              ]),
            ]),
            Text('★★★★☆ 4.0', style: typo.bodySmall.copyWith(color: colors.priceAccent)),
            const SizedBox(height: 4),
            Text('Submitted on $dateStr', style: typo.bodySmall.copyWith(color: colors.onSurface.withValues(alpha: 0.6))),
          ])),
        ]),
        if (isPending) ...[
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              '\$${order.totalPrice.toStringAsFixed(0)}',
              style: typo.titleMedium.copyWith(color: colors.primary, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: isActing ? null : () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Accept Offer'),
                    content: Text('Accept this offer from $buyerName? Other pending offers will be cancelled.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: colors.primary),
                        child: const Text('Accept'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await ref.read(orderActionsProvider.notifier).acceptOrder(order.id);
                  if (!context.mounted) return;
                  context.goNamed(AppRoutes.sellerCenter);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(radius.button),
                ),
                child: Text(isActing ? '...' : 'Accept',
                  style: typo.labelLarge.copyWith(color: colors.onPrimary, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}
