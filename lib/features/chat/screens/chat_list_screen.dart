import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/chat_room.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';
import 'package:smivo/features/chat/widgets/chat_list_item.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/shared/widgets/sticky_header_delegate.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  String _searchQuery = '';
  // false = active conversations, true = archived conversations
  bool _showArchived = false;

  /// Transforms a [ChatRoom] into a [ChatConversation] display model.
  ///
  /// Centralised here so both the list builder and search filter
  /// use the same transformation logic.
  ChatConversation _buildConversation(ChatRoom room, String? currentUserId) {
    final isBuyer = room.buyerId == currentUserId;
    final otherUser = isBuyer ? room.seller : room.buyer;

    final rawUnread =
        isBuyer ? room.unreadCountBuyer : room.unreadCountSeller;
    // Manual unread override takes priority over the database count
    final effectiveUnread =
        room.isUnreadOverride ? (rawUnread > 0 ? rawUnread : 1) : rawUnread;

    final lastMessagePreview = room.lastMessage.isNotEmpty
        ? room.lastMessage.first.content
        : 'No messages yet';
    final timeText = room.lastMessageAt != null
        ? timeago.format(room.lastMessageAt!, locale: 'en_short')
        : '';

    return ChatConversation(
      id: room.id,
      listingTitle: room.listing?.title ?? 'Unknown Listing',
      // NOTE: name field shows listing title as per existing UI convention
      name: room.listing?.title ?? 'Unknown Listing',
      latestMessage:
          '${otherUser?.displayName ?? 'User'} · $lastMessagePreview',
      time: timeText,
      unreadCount: effectiveUnread,
      avatarUrl: otherUser?.avatarUrl,
      initials: otherUser?.displayName?.isNotEmpty == true
          ? otherUser!.displayName!.substring(0, 1).toUpperCase()
          : null,
      // Search fields
      partnerName: otherUser?.displayName ?? '',
      partnerEmail: otherUser?.email ?? '',
      listingDescription: room.listing?.description ?? '',
      listingPrice: room.listing?.price ?? 0.0,
      // Feature flags
      isPinned: room.isPinned,
      isArchived: room.isArchived,
      isUnreadOverride: room.isUnreadOverride,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomsAsync = ref.watch(chatRoomListProvider);
    final currentUserId =
        ref.watch(authStateProvider).valueOrNull?.id;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(chatRoomListProvider);
            await ref.read(chatRoomListProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _showArchived ? 'Archived' : 'Chat',
                          style: typo.headlineLarge.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: _showArchived
                            ? 'Show active chats'
                            : 'Show archived chats',
                        icon: Icon(
                          _showArchived
                              ? Icons.chat_bubble_outline
                              : Icons.archive_outlined,
                          color: colors.onSurfaceVariant,
                        ),
                        onPressed: () =>
                            setState(() => _showArchived = !_showArchived),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyHeaderDelegate(
                  backgroundColor: colors.surfaceContainerLowest,
                  minHeight: 68.0,
                  maxHeight: 68.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      style: typo.bodyLarge.copyWith(color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search conversations...',
                        hintStyle: typo.bodyLarge.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close,
                                    color: colors.onSurfaceVariant, size: 18),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                        filled: true,
                        fillColor: colors.surfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(radius.input),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              chatRoomsAsync.when(
                loading: () =>
                    const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Error loading conversations'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(chatRoomListProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (rooms) {
                  // Step 1: Filter by active / archived view
                  final viewFiltered = rooms
                      .where((r) => r.isArchived == _showArchived)
                      .toList();

                  // Step 2: Apply search query
                  final searchFiltered = _searchQuery.isEmpty
                      ? viewFiltered
                      : viewFiltered.where((room) {
                          final q = _searchQuery.toLowerCase();
                          final conv = _buildConversation(
                              room, currentUserId);
                          return conv.listingTitle
                                  .toLowerCase()
                                  .contains(q) ||
                              conv.partnerName
                                  .toLowerCase()
                                  .contains(q) ||
                              conv.partnerEmail
                                  .toLowerCase()
                                  .contains(q) ||
                              conv.listingDescription
                                  .toLowerCase()
                                  .contains(q) ||
                              conv.listingPrice
                                  .toStringAsFixed(2)
                                  .contains(q) ||
                              conv.latestMessage
                                  .toLowerCase()
                                  .contains(q);
                        }).toList();

                  // Step 3: Sort — pinned rooms always at top
                  searchFiltered.sort((a, b) {
                    if (a.isPinned && !b.isPinned) return -1;
                    if (!a.isPinned && b.isPinned) return 1;
                    return 0;
                  });

                  if (searchFiltered.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No matching conversations.'
                              : _showArchived
                                  ? 'No archived conversations.'
                                  : 'No conversations yet.\nStart chatting from a listing.',
                          textAlign: TextAlign.center,
                          style: typo.bodyMedium.copyWith(
                              color: colors.outlineVariant),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final room = searchFiltered[index];
                          final conversation =
                              _buildConversation(room, currentUserId);

                          return ChatListItem(
                            conversation: conversation,
                            isArchiveView: _showArchived,
                            onTap: () {
                              context.pushNamed(
                                AppRoutes.chatRoom,
                                pathParameters: {'id': room.id},
                              );
                            },
                            onTogglePin: () => ref
                                .read(chatRoomListProvider.notifier)
                                .togglePin(room.id, !room.isPinned),
                            onToggleUnread: () => ref
                                .read(chatRoomListProvider.notifier)
                                .toggleUnreadOverride(
                                    room.id, !room.isUnreadOverride),
                            onArchive: () => ref
                                .read(chatRoomListProvider.notifier)
                                .toggleArchive(
                                    room.id, !room.isArchived),
                          );
                        },
                        childCount: searchFiltered.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
