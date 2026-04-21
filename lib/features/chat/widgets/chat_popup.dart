import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/data/models/message.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';

Future<void> showChatPopup(
  BuildContext context, {
  required String chatRoomId,
  required String otherUserName,
  String? otherUserAvatar,
  required String listingTitle,
  required double listingPrice,
  String? listingImageUrl,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.2),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: ChatPopupWidget(
            chatRoomId: chatRoomId,
            otherUserName: otherUserName,
            otherUserAvatar: otherUserAvatar,
            listingTitle: listingTitle,
            listingPrice: listingPrice,
            listingImageUrl: listingImageUrl,
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
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
    required this.listingTitle,
    required this.listingPrice,
    this.listingImageUrl,
  });

  final String chatRoomId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String listingTitle;
  final double listingPrice;
  final String? listingImageUrl;

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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref.read(chatMessagesProvider(widget.chatRoomId).notifier).sendMessage(text);
    _controller.clear();

    // Scroll to bottom
    _scrollToBottom();
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
    final currentUserId = ref.watch(authStateProvider).valueOrNull?.id;
    final currentUserProfile = ref.watch(profileProvider).valueOrNull;

    // Re-mark as read whenever new messages arrive while viewing this chat.
    ref.listen(chatMessagesProvider(widget.chatRoomId), (previous, next) {
      final prevLen = previous?.valueOrNull?.length ?? 0;
      final nextLen = next.valueOrNull?.length ?? 0;
      if (nextLen > prevLen) {
        // New message arrived while user is on this screen
        ref.read(chatMessagesProvider(widget.chatRoomId).notifier).markAsRead();
      }
    });

    const backgroundColor = Color(0xFFF5F4FA);
    const primaryBlue = Color(0xFF3B67FF);
    const headerBlue = Color(0xFF2B2A51);
    const bubbleLeftBg = Color(0xFFE2DDFA);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: widget.otherUserAvatar != null
                          ? NetworkImage(widget.otherUserAvatar!)
                          : null,
                      child: widget.otherUserAvatar == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.otherUserName,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: headerBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF546387)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // --- Item Card ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
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
                          color: const Color(0xFFDCDDDF),
                          borderRadius: BorderRadius.circular(4),
                          image: widget.listingImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(widget.listingImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: widget.listingImageUrl == null
                            ? const Icon(Icons.image, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.listingTitle,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: headerBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${widget.listingPrice.toStringAsFixed(0)}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: primaryBlue,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Chat Messages Area ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: backgroundColor.withOpacity(0.3),
                  child: messagesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (messages) {
                      if (messages.isEmpty) {
                        return const Center(child: Text('No messages yet'));
                      }
                      
                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[messages.length - 1 - index];
                          final isMine = msg.senderId == currentUserId;
                          
                          if (isMine) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildRightBubble(
                                msg,
                                primaryBlue,
                                Colors.white,
                                currentUserProfile?.avatarUrl,
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildLeftBubble(
                                msg,
                                msg.sender?.avatarUrl ?? widget.otherUserAvatar,
                                bubbleLeftBg,
                                headerBlue,
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F4FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Message ${widget.otherUserName}...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: const Color(0xFF9EA3C0),
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
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.send_outlined,
                            color: Colors.white,
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
    );
  }

  Widget _buildTimestamp(DateTime createdAt, {required bool isMine}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        timeago.format(createdAt, locale: 'en_short'),
        style: AppTextStyles.bodySmall.copyWith(
          color: const Color(0xFF585781),
          fontSize: 10,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null ? const Icon(Icons.person, size: 12) : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: Text(
                  msg.content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 32),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 4),
          child: Text(
            timeago.format(msg.createdAt, locale: 'en_short'),
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF546387),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  msg.content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 12,
              backgroundImage: myAvatarUrl != null ? NetworkImage(myAvatarUrl) : null,
              child: myAvatarUrl == null ? const Icon(Icons.person, size: 12) : null,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 32, top: 4),
          child: Text(
            timeago.format(msg.createdAt, locale: 'en_short'),
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF546387),
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
