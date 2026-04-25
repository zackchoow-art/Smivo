import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/utils/price_format.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/orders/widgets/transaction_snapshot_modal.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/chat/widgets/chat_popup.dart';

class ListOrderCard extends ConsumerWidget {
  const ListOrderCard({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = order.listing?.images.firstOrNull?.imageUrl;
    final title = order.listing?.title ?? 'Untitled Listing';
    final status = order.status;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return InkWell(
      onTap: () => context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id}),
      borderRadius: BorderRadius.circular(radius.card),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(radius.card),
          boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            _buildImage(imageUrl, colors, radius),
            const SizedBox(width: 12),
            Expanded(child: _buildDetails(context, title, status, colors, typo)),
            const SizedBox(width: 8),
            _buildActions(context, ref, status, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl, SmivoColors colors, SmivoRadius radius) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius.sm),
        child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.sm)),
      child: Icon(Icons.image_not_supported, color: colors.outlineVariant),
    );
  }

  Widget _buildDetails(BuildContext context, String title, String status, SmivoColors colors, SmivoTypography typo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: typo.titleMedium.copyWith(height: 1.2)),
        const SizedBox(height: 4),
        Text('${formatOrderPrice(order)} • ${_statusText(status)}',
          style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.6))),
        if (status == 'completed')
          GestureDetector(
            onTap: () => TransactionSnapshotModal.show(context, title: 'Order Snapshot'),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('View Order Snapshot',
                style: typo.labelSmall.copyWith(color: colors.primary.withValues(alpha: 0.7), fontWeight: FontWeight.w500, decoration: TextDecoration.underline)),
            ),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, String status, SmivoColors colors) {
    return Row(
      children: [
        if (status == 'pending' || status == 'confirmed')
          IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            icon: Icon(Icons.info_outline, color: colors.primary, size: 20),
            onPressed: () => context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id}))
        else if (status == 'completed')
          IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            icon: Icon(Icons.receipt_long_outlined, color: colors.primary, size: 20),
            onPressed: () => TransactionSnapshotModal.show(context, title: 'Order Snapshot')),
        const SizedBox(width: 12),
        IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          icon: Icon(Icons.chat_bubble_outline, color: colors.primary, size: 20),
          onPressed: () => _openChat(context, ref)),
      ],
    );
  }

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    final isBuyer = order.buyerId == user.id;
    final otherProfile = isBuyer ? order.seller : order.buyer;
    try {
      final chatRoom = await ref.read(chatRepositoryProvider).getOrCreateChatRoom(
        listingId: order.listingId, buyerId: order.buyerId, sellerId: order.sellerId);
      if (!context.mounted) return;
      showChatPopup(context, chatRoomId: chatRoom.id,
        otherUserName: otherProfile?.displayName ?? 'User', 
        otherUserAvatar: otherProfile?.avatarUrl,
        otherUserEmail: otherProfile?.email,
        listingTitle: order.listing?.title ?? 'Order',
        listingPrice: order.totalPrice,
        priceLabel: formatOrderPriceLabel(order) ?? (order.orderType == 'rental' ? _formatRentalSummary(order) : null),
        listingImageUrl: order.listing?.images.firstOrNull?.imageUrl);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _statusText(String s) => switch (s) {
    'pending' => 'Action Needed', 'confirmed' => 'In Progress',
    'completed' => 'Completed', 'cancelled' => 'Cancelled', _ => s.toUpperCase(),
  };

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
}
