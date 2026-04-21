import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';
import 'package:smivo/features/chat/widgets/chat_list_item.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/core/router/app_routes.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomListProvider);
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final currentUserId = authUser?.id;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Title
              Text(
                'Chat',
                style: AppTextStyles.displayLarge.copyWith(
                  color: const Color(0xFF2B2A51),
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Search Bar
              TextField(
                style: AppTextStyles.bodyLarge.copyWith(
                  color: const Color(0xFF2B2A51),
                ),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: const Color(0xFF585781).withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF585781).withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF2EFFF),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Chat List
              Expanded(
                child: chatRoomsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Error loading conversations'),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(chatRoomListProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (rooms) {
                    if (rooms.isEmpty) {
                      return const Center(
                        child: Text(
                          'No conversations yet. Start chatting from a listing.',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        
                        // Data Transformation
                        final otherUser = (room.buyerId == currentUserId) 
                            ? room.seller 
                            : room.buyer;
                        
                        final unreadCount = (room.buyerId == currentUserId)
                            ? room.unreadCountBuyer
                            : room.unreadCountSeller;
                        
                        final lastMessagePreview = room.lastMessage.isNotEmpty
                            ? room.lastMessage.first.content
                            : 'No messages yet';
                            
                        final timeText = room.lastMessageAt != null
                            ? timeago.format(room.lastMessageAt!, locale: 'en_short')
                            : '';

                        // Construct display model
                        // NOTE: Packing listing title into the name field to fit existing UI
                        // as requested in the formatting example.
                        final conversation = ChatConversation(
                          id: room.id,
                          listingTitle: room.listing?.title ?? 'Unknown Listing',
                          name: room.listing?.title ?? 'Unknown Listing',
                          latestMessage: '${otherUser?.displayName ?? 'User'} · $lastMessagePreview',
                          time: timeText,
                          hasUnread: unreadCount > 0,
                          avatarUrl: otherUser?.avatarUrl,
                          initials: otherUser?.displayName?.substring(0, 1).toUpperCase(),
                        );

                        return ChatListItem(
                          conversation: conversation,
                          onTap: () {
                            context.pushNamed(
                              AppRoutes.chatRoom,
                              pathParameters: {'id': room.id},
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
