import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:smivo/core/theme/theme_extensions.dart';
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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Title
              Text(
                'Chat',
                style: typo.displayLarge.copyWith(
                  color: colors.onSurface,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 12),
              
              // Search Bar
              TextField(
                style: typo.bodyLarge.copyWith(
                  color: colors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: typo.bodyLarge.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius.input),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Chat List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(chatRoomListProvider);
                    await ref.read(chatRoomListProvider.future);
                  },
                  child: chatRoomsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Error loading conversations'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => ref.invalidate(chatRoomListProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (rooms) {
                      if (rooms.isEmpty) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Text(
                                'No conversations yet. Start chatting from a listing.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                          unreadCount: unreadCount,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
