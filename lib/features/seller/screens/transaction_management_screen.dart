import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/utils/price_format.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/seller/providers/transaction_stats_provider.dart';
import 'package:smivo/features/seller/providers/listing_views_provider.dart';
import 'package:smivo/features/chat/widgets/chat_popup.dart';
import 'package:smivo/features/listing/providers/listing_detail_provider.dart';

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
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    
    final listingAsync = ref.watch(listingDetailProvider(listingId));

    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('Manage Transactions'),
          bottom: const TabBar(tabs: [Tab(text: 'Views'), Tab(text: 'Saves'), Tab(text: 'Offers')]),
        ),
        body: Column(
          children: [
            // Listing preview — moved out of AppBar to fix overlap
            listingAsync.when(
              loading: () => const SizedBox(height: 64),
              error: (_, __) => const SizedBox(height: 64),
              data: (listing) {
                final imageUrl = listing.images.firstOrNull?.imageUrl;
                final isRental = listing.transactionType == 'rental';
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(radius.card),
                  ),
                  child: Row(
                    children: [
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(radius.sm),
                          child: Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover),
                        )
                      else
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(radius.sm),
                          ),
                          child: Icon(Icons.image_not_supported, size: 20, color: colors.outlineVariant),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listing.title, style: typo.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (!isRental)
                              Text('\$${listing.price.toStringAsFixed(0)}', style: typo.bodyMedium.copyWith(color: colors.primary, fontWeight: FontWeight.w600))
                            else
                              // NOTE: Show all available rental rates for rental listings
                              Wrap(
                                spacing: 8,
                                children: [
                                  if (listing.rentalDailyPrice != null)
                                    Text('\$${listing.rentalDailyPrice!.toStringAsFixed(0)}/day', style: typo.bodySmall.copyWith(color: colors.primary, fontWeight: FontWeight.w600)),
                                  if (listing.rentalWeeklyPrice != null)
                                    Text('\$${listing.rentalWeeklyPrice!.toStringAsFixed(0)}/wk', style: typo.bodySmall.copyWith(color: colors.primary, fontWeight: FontWeight.w600)),
                                  if (listing.rentalMonthlyPrice != null)
                                    Text('\$${listing.rentalMonthlyPrice!.toStringAsFixed(0)}/mo', style: typo.bodySmall.copyWith(color: colors.primary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: TabBarView(children: [
                _ViewsTab(listingId: listingId),
                _SavesTab(listingId: listingId),
                _OffersTab(listingId: listingId),
              ]),
            ),
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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(listingViewsProvider(listingId));
        await ref.read(listingViewsProvider(listingId).future);
      },
      child: viewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: Container(height: 300, alignment: Alignment.center, child: Text('Error: $e'))),
        data: (views) {
          if (views.isEmpty) {
            return SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: Container(height: 300, alignment: Alignment.center, child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.visibility_outlined, size: 48, color: colors.onSurface.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text('No views yet', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
            ])));
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
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
                  backgroundImage: view.viewerAvatarUrl != null && view.viewerAvatarUrl!.trim().isNotEmpty
                      ? NetworkImage(view.viewerAvatarUrl!)
                      : null,
                  child: view.viewerAvatarUrl == null || view.viewerAvatarUrl!.trim().isEmpty
                      ? Icon(Icons.person, color: colors.onSurface.withValues(alpha: 0.5))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(view.viewerName ?? 'Anonymous Guest', style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          Text(view.viewerEmail ?? '', style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.chat_outlined, size: 16),
                      label: const Text('Chat'),
                      // NOTE: Only enable chat if the viewer has a userId (not anonymous)
                      onPressed: view.viewerId == null ? null : () async {
                        final currentUserId = ref.read(authStateProvider).valueOrNull?.id;
                        if (currentUserId == null) return;
                        final chatRepo = ref.read(chatRepositoryProvider);
                        final room = await chatRepo.getOrCreateChatRoom(
                          listingId: listingId,
                          buyerId: view.viewerId!,
                          sellerId: currentUserId,
                        );
                        final listingData = ref.read(listingDetailProvider(listingId)).valueOrNull;
                        if (!context.mounted) return;
                        showChatPopup(
                          context,
                          chatRoomId: room.id,
                          otherUserName: view.viewerName ?? 'Viewer',
                          otherUserAvatar: view.viewerAvatarUrl,
                          otherUserEmail: view.viewerEmail,
                          listingTitle: listingData?.title ?? '',
                          listingPrice: listingData?.price ?? 0,
                          listingImageUrl: listingData?.images.firstOrNull?.imageUrl,
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('★★★★☆ 4.0', style: typo.bodySmall.copyWith(color: colors.priceAccent)),
                      const SizedBox(width: 8),
                      Text('Viewed on $timeStr', style: typo.bodySmall.copyWith(color: colors.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ])),
              ]),
            );
          },
          );
        },
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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(listingSavesProvider(listingId));
        await ref.read(listingSavesProvider(listingId).future);
      },
      child: savesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: Container(height: 300, alignment: Alignment.center, child: Text('Error: $e'))),
        data: (saves) {
          if (saves.isEmpty) {
            return SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: Container(height: 300, alignment: Alignment.center, child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bookmark_border, size: 48, color: colors.onSurface.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text('No saves yet', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
            ])));
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
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
                CircleAvatar(
                  backgroundColor: colors.surfaceContainerHigh,
                  backgroundImage: save.user?.avatarUrl != null && save.user!.avatarUrl!.trim().isNotEmpty
                      ? NetworkImage(save.user!.avatarUrl!)
                      : null,
                  child: save.user?.avatarUrl == null || save.user!.avatarUrl!.trim().isEmpty
                      ? Icon(Icons.person, color: colors.onSurface.withValues(alpha: 0.5))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(save.user?.displayName ?? 'Anonymous User', style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          Text(save.user?.email ?? '', style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.chat_outlined, size: 16),
                      label: const Text('Chat'),
                      onPressed: () async {
                        final currentUserId = ref.read(authStateProvider).valueOrNull?.id;
                        if (currentUserId == null || save.userId.isEmpty) return;
                        final chatRepo = ref.read(chatRepositoryProvider);
                        final room = await chatRepo.getOrCreateChatRoom(
                          listingId: listingId,
                          buyerId: save.userId,
                          sellerId: currentUserId,
                        );
                        final listingData = ref.read(listingDetailProvider(listingId)).valueOrNull;
                        if (!context.mounted) return;
                        showChatPopup(
                          context,
                          chatRoomId: room.id,
                          otherUserName: save.user?.displayName ?? 'User',
                          otherUserAvatar: save.user?.avatarUrl,
                          otherUserEmail: save.user?.email,
                          listingTitle: listingData?.title ?? '',
                          listingPrice: listingData?.price ?? 0,
                          listingImageUrl: listingData?.images.firstOrNull?.imageUrl,
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('★★★★☆ 4.0', style: typo.bodySmall.copyWith(color: colors.priceAccent)),
                      const SizedBox(width: 8),
                      Text('Saved on $dateStr', style: typo.bodySmall.copyWith(color: colors.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ])),
              ]),
            );
          },
          );
        },
      ),
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

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(listingOrdersProvider(listingId));
        await ref.read(listingOrdersProvider(listingId).future);
      },
      child: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: Container(height: 300, alignment: Alignment.center, child: Text('Error: $e'))),
        data: (orders) {
          if (orders.isEmpty) {
            return SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: Container(height: 300, alignment: Alignment.center,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.receipt_long_outlined, size: 48, color: colors.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('No offers yet', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
              ]),
            ));
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, ref, order, actionsState.isLoading);
            },
          );
        },
      ),
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
      case 'missed':
        statusColor = colors.outlineVariant;
        statusLabel = 'Missed';
      default:
        statusColor = colors.outlineVariant;
        statusLabel = order.status;
    }

    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id}),
      child: Container(
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
              backgroundColor: colors.surfaceContainerHigh,
              backgroundImage: order.buyer?.avatarUrl != null && order.buyer!.avatarUrl!.trim().isNotEmpty
                  ? NetworkImage(order.buyer!.avatarUrl!)
                  : null,
              child: order.buyer?.avatarUrl == null || order.buyer!.avatarUrl!.trim().isEmpty
                  ? Icon(Icons.person, color: colors.onSurface.withValues(alpha: 0.5), size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(buyerName, style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      Text(order.buyer?.email ?? '', style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Text(
                  formatOrderPrice(order),
                  style: typo.titleMedium.copyWith(color: colors.primary, fontWeight: FontWeight.bold),
                ),
              ]),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('★★★★☆ 4.0', style: typo.bodySmall.copyWith(color: colors.priceAccent)),
                  const SizedBox(width: 8),
                  Text('Submitted on $dateStr', style: typo.bodySmall.copyWith(color: colors.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ])),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.chat_outlined, size: 16),
                  label: const Text('Chat'),
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
                      otherUserEmail: order.buyer?.email,
                      listingTitle: order.listing?.title ?? '',
                      listingPrice: order.totalPrice,
                      priceLabel: formatOrderPriceLabel(order) ?? (order.orderType == 'rental' ? _formatRentalSummary(order) : null),
                      listingImageUrl: order.listing?.images.firstOrNull?.imageUrl,
                    );
                  },
                ),
                if (isPending) ...[
                  const SizedBox(width: 8),
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
                        try {
                          await ref.read(orderActionsProvider.notifier).acceptOrder(order.id);
                          // NOTE: Refresh the offers list so accepted/missed statuses show
                          ref.invalidate(listingOrdersProvider(listingId));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Offer accepted successfully')),
                          );
                          context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id});
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to accept: $e')),
                          );
                        }
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
                ],
              ],
            ),
          ]),
        ]),
      ),
    );
  }
}

String _formatRentalSummary(Order order) {
  if (order.totalPrice == 0) return formatOrderPrice(order);
  if (order.rentalStartDate == null || order.rentalEndDate == null) {
    return 'Total: \$${order.totalPrice.toStringAsFixed(0)}';
  }
  final days = order.rentalEndDate!.difference(order.rentalStartDate!).inDays;
  final duration = days > 0 ? days : 1;
  final unitLabel = duration == 1 ? 'Day' : 'Days';
  return '$duration $unitLabel, Total: \$${order.totalPrice.toStringAsFixed(0)}';
}
