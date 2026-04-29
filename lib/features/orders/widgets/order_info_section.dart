import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/core/utils/price_format.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/chat/widgets/chat_popup.dart';
import 'package:smivo/features/shared/providers/status_resolver_provider.dart';
import 'package:smivo/features/shared/widgets/user_rating_badge.dart';

/// Collapsible order information section with buyer/seller profiles.
///
/// NOTE: Converted from StatelessWidget to ConsumerStatefulWidget
/// to support collapse animation and chat popup integration.
class OrderInfoSection extends ConsumerStatefulWidget {
  const OrderInfoSection({
    super.key,
    required this.order,
    required this.counterpartyName,
    this.buyer,
    this.seller,
    this.currentUserId,
  });

  final Order order;
  final String? counterpartyName;
  final UserProfile? buyer;
  final UserProfile? seller;
  final String? currentUserId;

  @override
  ConsumerState<OrderInfoSection> createState() => _OrderInfoSectionState();
}

class _OrderInfoSectionState extends ConsumerState<OrderInfoSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final typo = context.smivoTypo;
    final colors = context.smivoColors;
    final isRental = widget.order.orderType == 'rental';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Order Info',
                    style: typo.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.expand_more,
                    size: 20,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NOTE: Show only counterparty info, not the current user's own row
                if (widget.buyer != null &&
                    widget.buyer!.id != widget.currentUserId)
                  _buildUserRow(context, 'Buyer', widget.buyer!),
                if (widget.seller != null &&
                    widget.seller!.id != widget.currentUserId)
                  _buildUserRow(context, 'Seller', widget.seller!),
                if (widget.buyer != null || widget.seller != null)
                  const Divider(height: 16),
                // Info items Grid/List via LayoutBuilder
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = Breakpoints.isDesktop(
                      MediaQuery.sizeOf(context).width,
                    );
                    final itemWidth =
                        isDesktop
                            ? constraints.maxWidth / 2
                            : constraints.maxWidth;

                    return Wrap(
                      children: [
                        // 1. Listed date
                        SizedBox(
                          width: itemWidth,
                          child: _infoRow(
                            context,
                            'Listed',
                            _formatDate(widget.order.createdAt),
                          ),
                        ),
                        // 2. Transaction type
                        SizedBox(
                          width: itemWidth,
                          child: _infoRow(
                            context,
                            'Type',
                            isRental ? 'Rent' : 'Sale',
                          ),
                        ),
                        // 3. Status — use DB-driven label via StatusResolver
                        SizedBox(
                          width: itemWidth,
                          child: _infoRow(
                            context,
                            'Status',
                            _resolveStatusLabel(widget.order.status),
                          ),
                        ),
                        // 4. Pickup location
                        if (widget.order.pickupLocation != null)
                          SizedBox(
                            width: itemWidth,
                            child: _infoRow(
                              context,
                              'Pickup',
                              widget.order.pickupLocation!.name,
                            ),
                          ),
                        // 5. Price / Rental Total
                        SizedBox(
                          width: itemWidth,
                          child: _infoRow(
                            context,
                            isRental ? 'Rental Total' : 'Price',
                            '\$${widget.order.totalPrice.toStringAsFixed(2)}',
                          ),
                        ),
                        // NOTE: For rentals with deposit, show deposit and a Grand Total row
                        if (isRental && widget.order.depositAmount > 0) ...[
                          SizedBox(
                            width: itemWidth,
                            child: _infoRow(
                              context,
                              'Deposit',
                              '\$${widget.order.depositAmount.toStringAsFixed(2)}',
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth,
                            child: const Divider(height: 16),
                          ),
                          SizedBox(
                            width: constraints.maxWidth,
                            child: _infoRow(
                              context,
                              'Grand Total',
                              '\$${(widget.order.totalPrice + widget.order.depositAmount).toStringAsFixed(2)}',
                              isBold: true,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Builds a buyer/seller profile row with avatar, name, email, and message button.
  Widget _buildUserRow(BuildContext context, String role, UserProfile user) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final currentUserId = ref.read(authStateProvider).valueOrNull?.id;
    // NOTE: Don't show message button for the current user's own row
    final isSelf = user.id == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Left column: role label
          SizedBox(
            width: 48,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    role == 'Buyer'
                        ? colors.primary.withValues(alpha: 0.1)
                        : colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                role,
                textAlign: TextAlign.center,
                style: typo.labelSmall.copyWith(
                  color: role == 'Buyer' ? colors.primary : colors.success,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.surfaceContainerHigh,
            backgroundImage:
                user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
            child:
                user.avatarUrl == null || user.avatarUrl!.trim().isEmpty
                    ? Icon(
                      Icons.person,
                      size: 18,
                      color: colors.onSurface.withValues(alpha: 0.5),
                    )
                    : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? 'Unknown',
                  style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.email.isNotEmpty)
                  Text(
                    user.email,
                    style: typo.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 4),
                UserRatingBadge(user: user, role: role.toLowerCase()),
              ],
            ),
          ),
          if (!isSelf)
            IconButton(
              icon: Icon(Icons.chat_outlined, size: 18, color: colors.primary),
              tooltip: 'Message $role',
              onPressed: () => _openChat(user),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Future<void> _openChat(UserProfile user) async {
    final currentUserId = ref.read(authStateProvider).valueOrNull?.id;
    if (currentUserId == null) return;

    final chatRepo = ref.read(chatRepositoryProvider);
    final order = widget.order;

    final room = await chatRepo.getOrCreateChatRoom(
      listingId: order.listingId,
      buyerId: order.buyerId,
      sellerId: order.sellerId,
    );

    if (!mounted) return;
    showChatPopup(
      context,
      chatRoomId: room.id,
      otherUserName: user.displayName ?? 'User',
      otherUserAvatar: user.avatarUrl,
      otherUserEmail: user.email,
      listingTitle: order.listing?.title ?? '',
      listingPrice: order.totalPrice,
      priceLabel: formatOrderPriceLabel(order),
      listingImageUrl: order.listing?.images.firstOrNull?.imageUrl,
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: typo.bodyMedium.copyWith(color: colors.outlineVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: typo.bodyMedium.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? colors.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      DateFormat('MMM d, yyyy · h:mm a').format(dt.toLocal());

  String _resolveStatusLabel(String status) {
    final resolver = ref.read(statusResolverProvider).valueOrNull;
    if (resolver != null) return resolver.orderLabel(status);
    // Fallback if resolver not yet loaded
    return status
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
