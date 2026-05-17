import 'dart:ui';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:smivo/data/models/message.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/shared/widgets/moderation_aware_image.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';

Future<void> showChatPopup(
  BuildContext context, {
  required String chatRoomId,
  required String otherUserName,
  String? otherUserAvatar,
  String? otherUserEmail,
  UserProfile? otherUserProfile,
  required String listingTitle,
  required double listingPrice,
  String? listingImageUrl,
  String? priceLabel,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: context.smivoColors.shadow.withValues(alpha: 0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      // NOTE: Padding with viewInsets.bottom shifts the entire dialog upward
      // when the keyboard appears, preventing it from covering the input field.
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: ChatPopupWidget(
              chatRoomId: chatRoomId,
              otherUserName: otherUserName,
              otherUserAvatar: otherUserAvatar,
              otherUserEmail: otherUserEmail,
              otherUserProfile: otherUserProfile,
              listingTitle: listingTitle,
              listingPrice: listingPrice,
              listingImageUrl: listingImageUrl,
              priceLabel: priceLabel,
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

class ChatPopupWidget extends ConsumerStatefulWidget {
  const ChatPopupWidget({
    super.key,
    required this.chatRoomId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.otherUserEmail,
    this.otherUserProfile,
    required this.listingTitle,
    required this.listingPrice,
    this.listingImageUrl,
    this.priceLabel,
  });

  final String chatRoomId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? otherUserEmail;
  final UserProfile? otherUserProfile;
  final String listingTitle;
  final double listingPrice;
  final String? listingImageUrl;
  final String? priceLabel;

  @override
  ConsumerState<ChatPopupWidget> createState() => _ChatPopupWidgetState();
}

class _ChatPopupWidgetState extends ConsumerState<ChatPopupWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark as read when opening
    Future.microtask(() {
      ref.read(chatMessagesProvider(widget.chatRoomId).notifier).markAsRead();
    });
  }

  /// Returns the ID of the other party in this chat room.
  Future<String?> _getRecipientId() async {
    final currentUserId = ref.read(authStateProvider).value?.id;
    if (currentUserId == null) return null;
    final chatRoom = await ref.read(chatRoomProvider(widget.chatRoomId).future);
    return chatRoom.buyerId == currentUserId
        ? chatRoom.sellerId
        : chatRoom.buyerId;
  }

  /// Checks block / mute / freeze status before sending.
  ///
  /// Returns null when the check cannot be performed (no network, etc.).
  /// On failure we allow the send to proceed — same policy as ChatRoomScreen.
  Future<Map<String, bool>?> _checkEligibility() async {
    final senderId = ref.read(authStateProvider).value?.id;
    final recipientId = await _getRecipientId();
    if (senderId == null || recipientId == null) return null;
    return ref
        .read(chatRepositoryProvider)
        .checkChatEligibility(senderId: senderId, recipientId: recipientId);
  }

  void _showSnackBar(String message, {required Color color}) {
    if (!mounted) return;
    // NOTE: chat-popup is inside a dialog, so we use the root ScaffoldMessenger
    // to ensure the SnackBar appears above the dialog layer.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final colors = context.smivoColors;

    // Pre-send eligibility check — mirrors ChatRoomScreen._handleSend logic.
    Map<String, bool>? eligibility;
    try {
      eligibility = await _checkEligibility();
    } catch (_) {
      // NOTE: Allow send on network error to avoid silently blocking users.
    }

    if (eligibility?['isBlockedByRecipient'] == true) {
      _showSnackBar(
        'Message failed: You have been blocked by the recipient',
        color: colors.error,
      );
      return;
    }

    if (eligibility?['senderIsMuted'] == true) {
      _showSnackBar(
        'You are currently muted by the platform and cannot send messages',
        color: colors.error,
      );
      return;
    }

    try {
      // sendMessage applies keyword filtering and returns a warning string
      // when warn-severity words are detected. The message is always sent.
      final warning = await ref
          .read(chatMessagesProvider(widget.chatRoomId).notifier)
          .sendMessage(text);
      _controller.clear();
      _scrollToBottom();

      // Show content-filter warning if applicable.
      if (warning != null) {
        _showSnackBar(warning, color: Colors.amber.shade800);
      }

      // Warn if recipient has a platform restriction.
      final isMuted = eligibility?['recipientIsMuted'] == true;
      final isFrozen = eligibility?['recipientIsFrozen'] == true;
      if (isMuted || isFrozen) {
        final reason = isFrozen ? 'frozen' : 'muted';
        _showSnackBar(
          'Message sent, but the recipient is currently $reason by the platform',
          color: colors.warning,
        );
      }
    } catch (e) {
      _showSnackBar('Send failed: ${e.toString()}', color: colors.error);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    Future.microtask(() {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatRoomId));
    final currentUserId = ref.watch(authStateProvider).value?.id;
    final currentUserProfile = ref.watch(profileProvider).value;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    // NOTE: On desktop the popup is constrained to 480px via ConstrainedBox
    // to prevent it from stretching across large monitors.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = Breakpoints.isDesktop(screenWidth);
    final popupWidth = isDesktop ? 480.0 : screenWidth * 0.85;
    // NOTE: When the keyboard is visible, reduce popup height so it fits
    // within the remaining viewport above the keyboard (min 300px for usability).
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final maxPopupHeight = screenHeight * 0.75;
    final popupHeight = keyboardHeight > 0
        ? (screenHeight - keyboardHeight - 48).clamp(300.0, maxPopupHeight)
        : maxPopupHeight;

    // Re-mark as read whenever new messages arrive while viewing this chat.
    ref.listen(chatMessagesProvider(widget.chatRoomId), (previous, next) {
      final prevLen = previous?.value?.length ?? 0;
      final nextLen = next.value?.length ?? 0;
      if (nextLen > prevLen) {
        ref.read(chatMessagesProvider(widget.chatRoomId).notifier).markAsRead();
      }
    });

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Container(
        width: popupWidth,
        height: popupHeight,
        decoration: BoxDecoration(
          color: colors.background.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(radius.xl),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                // --- Header ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      if (widget.otherUserProfile != null)
                        SmivoUserAvatar(
                          user: widget.otherUserProfile!,
                          radius: 24,
                          enableTap: true,
                        )
                      else
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colors.surfaceContainerHigh,
                          backgroundImage:
                              widget.otherUserAvatar != null &&
                                      widget.otherUserAvatar!.trim().isNotEmpty
                                  ? NetworkImage(widget.otherUserAvatar!)
                                  : null,
                          child:
                              widget.otherUserAvatar == null ||
                                      widget.otherUserAvatar!.trim().isEmpty
                                  ? Icon(
                                    Icons.person,
                                    color: colors.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                    size: 28,
                                  )
                                  : null,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.otherUserName,
                              style: typo.titleMedium.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            if (widget.otherUserEmail != null)
                              Text(
                                widget.otherUserEmail!,
                                style: typo.bodySmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colors.onSurfaceVariant),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // --- Item Card ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final room =
                          ref.watch(chatRoomProvider(widget.chatRoomId)).value;
                      return GestureDetector(
                        onTap: () {
                          if (room == null) return;
                          final order =
                              ref
                                  .read(
                                    latestOrderByListingAndBuyerProvider(
                                      listingId: room.listingId,
                                      buyerId: room.buyerId,
                                    ),
                                  )
                                  .value;

                          Navigator.of(context).pop(); // Close popup

                          if (order != null && order.status != 'pending') {
                            context.pushNamed(
                              AppRoutes.orderDetail,
                              pathParameters: {'id': order.id},
                              extra: order,
                            );
                          } else {
                            context.pushNamed(
                              AppRoutes.listingDetail,
                              pathParameters: {'id': room.listingId},
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(radius.md),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(
                                    radius.xs,
                                  ),
                                  image:
                                      widget.listingImageUrl != null
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              widget.listingImageUrl!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                ),
                                child:
                                    widget.listingImageUrl == null
                                        ? const Icon(Icons.image, size: 16)
                                        : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.listingTitle,
                                  style: typo.labelLarge.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // NOTE: Hide price when it is 0 (free/give-away).
                              // If priceLabel is explicitly provided (e.g. rental
                              // rate strings), always show it regardless.
                              if (widget.priceLabel != null ||
                                  widget.listingPrice > 0)
                                Text(
                                  widget.priceLabel ??
                                      '\$${widget.listingPrice.toStringAsFixed(0)}',
                                  style: typo.labelLarge.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // --- Chat Messages Area ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: colors.background.withValues(alpha: 0.3),
                    child: messagesAsync.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                      data: (messages) {
                        if (messages.isEmpty) {
                          return const Center(child: Text('No messages yet'));
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[messages.length - 1 - index];
                            final isMine = msg.senderId == currentUserId;

                            if (isMine) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildRightBubble(
                                  msg,
                                  colors.chatBubbleSelf,
                                  colors.chatBubbleTextSelf,
                                  currentUserProfile?.avatarUrl,
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildLeftBubble(
                                  msg,
                                  msg.sender?.avatarUrl ??
                                      widget.otherUserAvatar,
                                  colors.chatBubbleOther,
                                  colors.chatBubbleTextOther,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),

                // --- Bottom Input Area ---
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                  ),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(radius.md),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: 'Message ${widget.otherUserName}...',
                              hintStyle: typo.bodyMedium.copyWith(
                                color: colors.outlineVariant,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(radius.md),
                            ),
                            child: Icon(
                              Icons.send_outlined,
                              color: colors.onPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftBubble(
    Message msg,
    String? avatarUrl,
    Color bgColor,
    Color textColor,
  ) {
    final typo = context.smivoTypo;
    final colors = context.smivoColors;
    final radius = context.smivoRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(radius.lg),
                    topRight: Radius.circular(radius.lg),
                    bottomRight: Radius.circular(radius.lg),
                    bottomLeft: Radius.circular(radius.xs),
                  ),
                ),
                child:
                    msg.messageType == 'image' && msg.imageUrl != null
                        ? _buildImageMessage(msg.imageUrl!)
                        : SelectableText(
                          msg.content,
                          style: typo.bodyMedium.copyWith(
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 4),
          child: Text(
            timeago.format(msg.createdAt, locale: 'en_short'),
            style: typo.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightBubble(
    Message msg,
    Color bgColor,
    Color textColor,
    String? myAvatarUrl,
  ) {
    final typo = context.smivoTypo;
    final colors = context.smivoColors;
    final radius = context.smivoRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 48),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(radius.lg),
                    topRight: Radius.circular(radius.lg),
                    bottomLeft: Radius.circular(radius.lg),
                    bottomRight: Radius.circular(radius.xs),
                  ),
                ),
                child:
                    msg.messageType == 'image' && msg.imageUrl != null
                        ? _buildImageMessage(msg.imageUrl!)
                        : SelectableText(
                          msg.content,
                          style: typo.bodyMedium.copyWith(
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4, top: 4),
          child: Text(
            timeago.format(msg.createdAt, locale: 'en_short'),
            style: typo.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageMessage(String url) {
    final radius = context.smivoRadius;
    final colors = context.smivoColors;

    return Container(
      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 300),
      // NOTE: ModerationAwareImage handles blur for AI-flagged images.
      // It is a ConsumerWidget and reads flaggedImageUrlsProvider internally.
      child: ModerationAwareImage(
        imageUrl: url,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(radius.sm),
        placeholder: Container(
          width: 200,
          height: 150,
          color: colors.surfaceContainerHigh,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
