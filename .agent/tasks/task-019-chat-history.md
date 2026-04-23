# Task 019: Chat History in Order Detail

## Objective
Add a collapsible chat history section to the order detail screen.
Shows the full conversation between buyer and seller for that listing.

## STRICT SCOPE — Only modify:

1. `lib/features/orders/screens/order_detail_screen.dart`

**DO NOT** modify any other files. The chat repository already has
`fetchMessages` and `fetchChatRooms` methods.

---

## Step 1: Add chat history provider (inline)

We need to fetch the chat room for this order's listing + buyer + seller,
then fetch all messages. Add a new provider at the bottom of the
order detail screen file (or create a small provider file).

**Option A**: Add a new provider file.

Create `lib/features/orders/providers/order_chat_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/message.dart';
import 'package:smivo/data/repositories/chat_repository.dart';

part 'order_chat_provider.g.dart';

/// Fetches the chat history for a specific chat room.
@riverpod
Future<List<Message>> orderChatMessages(
  Ref ref,
  String chatRoomId,
) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.fetchMessages(chatRoomId);
}

/// Finds the chat room for a listing between buyer and seller.
@riverpod
Future<String?> orderChatRoomId(
  Ref ref, {
  required String listingId,
  required String buyerId,
  required String sellerId,
}) async {
  final repo = ref.watch(chatRepositoryProvider);
  try {
    final rooms = await repo.fetchChatRooms(buyerId);
    final match = rooms.where(
        (r) => r.listingId == listingId && 
               r.sellerId == sellerId).firstOrNull;
    return match?.id;
  } catch (_) {
    return null;
  }
}
```

Run: `dart run build_runner build --delete-conflicting-outputs`

## Step 2: Create chat history widget

Create `lib/features/orders/widgets/chat_history_section.dart`:

```dart
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
```

## Step 3: Integrate into order_detail_screen.dart

In the `_buildBody` method, add the chat history section after the
evidence photos section and before the action buttons.

Find a good spot (before `_buildActions`) and add:

```dart
          // Chat History (collapsible)
          Builder(
            builder: (context) {
              // Find the chat room for this listing + buyer/seller pair
              final chatRoomAsync = ref.watch(
                orderChatRoomIdProvider(
                  listingId: order.listingId,
                  buyerId: order.buyerId,
                  sellerId: order.sellerId,
                ),
              );
              
              return chatRoomAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (chatRoomId) {
                  if (chatRoomId == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      ChatHistorySection(
                        chatRoomId: chatRoomId,
                        currentUserId: currentUserId ?? '',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                },
              );
            },
          ),
```

Add these imports at top:
```dart
import 'package:smivo/features/orders/providers/order_chat_provider.dart';
import 'package:smivo/features/orders/widgets/chat_history_section.dart';
```

## Step 4: Run build_runner

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

## Step 5: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-019.md`.
