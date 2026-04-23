import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/seller/providers/transaction_stats_provider.dart';
import 'package:smivo/features/seller/providers/listing_views_provider.dart';

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

/// Views tab — shows individual viewer details.
class _ViewsTab extends ConsumerWidget {
  const _ViewsTab({required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewsAsync = ref.watch(listingViewsProvider(listingId));

    return viewsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (views) {
        if (views.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.visibility_outlined,
                    size: 48,
                    color: AppColors.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('No views yet',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.outlineVariant)),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Total Views: ${views.length}',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: views.length,
                itemBuilder: (context, index) {
                  final view = views[index];
                  final timeStr = DateFormat('MMM d, h:mm a').format(view.viewedAt.toLocal());

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.surfaceContainerHigh,
                        backgroundImage: view.viewerAvatarUrl != null
                            ? NetworkImage(view.viewerAvatarUrl!)
                            : null,
                        child: view.viewerAvatarUrl == null
                            ? const Icon(Icons.person, color: AppColors.onSurface)
                            : null,
                      ),
                      title: Text(view.viewerName ?? 'Anonymous Guest',
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text('Viewed on $timeStr',
                          style: AppTextStyles.bodySmall),
                    ),
                  );
                },
              ),
            ),
          ],
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

    // FIXME: Debug — trace provider state
    // ignore: avoid_print
    print('[_OrdersTab] ordersAsync state: $ordersAsync');

    return ordersAsync.when(
      loading: () {
        // ignore: avoid_print
        print('[_OrdersTab] STATE: loading');
        return const Center(child: CircularProgressIndicator());
      },
      error: (e, _) {
        // ignore: avoid_print
        print('[_OrdersTab] STATE: error — $e');
        return Center(child: Text('Error: $e'));
      },
      data: (orders) {
        // ignore: avoid_print
        print('[_OrdersTab] STATE: data — ${orders.length} orders');
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

class _OrderCard extends ConsumerWidget {
  const _OrderCard({
    required this.order,
    required this.isActing,
    this.onAccept,
  });

  final Order order;
  final bool isActing;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                IconButton(
                  icon: const Icon(Icons.chat_outlined, size: 20),
                  tooltip: 'Message buyer',
                  onPressed: () async {
                    final currentUserId = ref.read(authStateProvider).valueOrNull?.id;
                    if (currentUserId == null) return;

                    final chatRepo = ref.read(chatRepositoryProvider);
                    final room = await chatRepo.getOrCreateChatRoom(
                      listingId: order.listingId,
                      buyerId: order.buyerId,
                      sellerId: order.sellerId,
                    );
                    if (context.mounted) {
                      context.pushNamed(
                        AppRoutes.chatRoom,
                        pathParameters: {'id': room.id},
                      );
                    }
                  },
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
