import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/orders/providers/order_chat_provider.dart';

class ChatHistorySection extends ConsumerStatefulWidget {
  const ChatHistorySection({
    super.key,
    required this.chatRoomId,
    required this.currentUserId,
  });

  final String chatRoomId;
  final String currentUserId;

  @override
  ConsumerState<ChatHistorySection> createState() =>
      _ChatHistorySectionState();
}

class _ChatHistorySectionState extends ConsumerState<ChatHistorySection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(orderChatMessagesProvider(widget.chatRoomId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            children: [
              Text('CHAT HISTORY',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  )),
              const Spacer(),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.outlineVariant,
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: AppSpacing.md),
          messagesAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (messages) {
              if (messages.isEmpty) {
                return Text(
                  'No messages yet.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.outlineVariant,
                  ),
                );
              }

              return Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  shrinkWrap: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe =
                        msg.senderId == widget.currentUserId;
                    final senderName =
                        msg.sender?.displayName ?? 'Unknown';
                    final timeStr = DateFormat('MMM d · h:mm a')
                        .format(msg.createdAt.toLocal());

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: isMe
                                ? AppColors.primary
                                    .withValues(alpha: 0.1)
                                : AppColors.surfaceContainerHigh,
                            child: Text(
                              senderName.isNotEmpty
                                  ? senderName[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.labelSmall
                                  .copyWith(
                                color: isMe
                                    ? AppColors.primary
                                    : AppColors.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isMe ? 'You' : senderName,
                                      style: AppTextStyles
                                          .bodySmall
                                          .copyWith(
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      timeStr,
                                      style: AppTextStyles
                                          .bodySmall
                                          .copyWith(
                                        color: AppColors
                                            .outlineVariant,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(msg.content,
                                    style: AppTextStyles
                                        .bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
