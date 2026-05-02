import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smivo/data/models/chat_room.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/listing/providers/listing_detail_provider.dart';
import 'package:smivo/data/models/message.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/core/providers/moderation_provider.dart';

import 'package:smivo/shared/widgets/report_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/shared/widgets/user_rating_badge.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/data/repositories/chat_repository.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.chatRoomId});

  final String chatRoomId;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  bool _isSending = false;
  bool _selectionMode = false;
  final Set<String> _selectedMessageIds = {};
  // Heartbeat timer: refreshes updated_at in user_active_sessions every 90s
  // to keep the session alive within the Edge Function's 2-minute TTL window.
  Timer? _sessionHeartbeat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(chatMessagesProvider(widget.chatRoomId).notifier).markAsRead();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = ref.read(authStateProvider).value?.id;
      debugPrint('[Chat] Setting activeChatRoomProvider = ${widget.chatRoomId}');
      // Update in-memory state for client-side Foreground Listener suppression.
      ref.read(activeChatRoomProvider.notifier).setActive(widget.chatRoomId);
      // Update DB for server-side Edge Function suppression.
      if (userId != null) {
        _writeActiveSession(userId);
        // Heartbeat: re-write updated_at every 90s so the 2-min Edge Function
        // TTL doesn't expire while the user is actively reading the chat room.
        _sessionHeartbeat = Timer.periodic(
          const Duration(seconds: 90),
          (_) => _writeActiveSession(userId),
        );
      }
    });
  }

  void _writeActiveSession(String userId) {
    ref.read(chatRepositoryProvider).setActiveSession(
      userId: userId,
      chatRoomId: widget.chatRoomId,
    ).catchError((e) {
      debugPrint('[Chat] setActiveSession failed (non-critical): $e');
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    // Stop the heartbeat before clearing — prevents a race where the timer
    // fires between clearActiveSession and the next push delivery.
    _sessionHeartbeat?.cancel();
    debugPrint('[Chat] Clearing activeChatRoomProvider on dispose.');
    // Clear in-memory state.
    ref.read(activeChatRoomProvider.notifier).setActive(null);
    // Clear DB state so Edge Function resumes push delivery immediately.
    final userId = ref.read(authStateProvider).value?.id;
    if (userId != null) {
      ref.read(chatRepositoryProvider).clearActiveSession(userId).catchError((e) {
        debugPrint('[Chat] clearActiveSession failed (non-critical): $e');
      });
    }
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the ID of the other party in this chat room.
  ///
  /// Reads from the already-loaded chatRoomProvider cache first; falls back
  /// to an async fetch only when the cache is empty (first load).
  Future<String?> _getRecipientId() async {
    final currentUserId = ref.read(authStateProvider).value?.id;
    if (currentUserId == null) return null;
    final chatRoom = await ref.read(chatRoomProvider(widget.chatRoomId).future);
    return chatRoom.buyerId == currentUserId
        ? chatRoom.sellerId
        : chatRoom.buyerId;
  }

  /// Checks eligibility and returns the result map, or null if the check
  /// could not be performed (recipient ID unknown, network error, etc.).
  Future<Map<String, bool>?> _checkEligibility() async {
    final senderId   = ref.read(authStateProvider).value?.id;
    final recipientId = await _getRecipientId();
    if (senderId == null || recipientId == null) return null;
    return ref.read(chatRepositoryProvider).checkChatEligibility(
      senderId:    senderId,
      recipientId: recipientId,
    );
  }

  void _showBlockedSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message failed: You have been blocked by the recipient'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRecipientRestrictedSnackBar({
    required bool isMuted,
    required bool isFrozen,
  }) {
    if (!mounted) return;
    final reason = isFrozen ? 'frozen' : 'muted';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message sent, but the recipient is currently $reason by the platform and may not receive it'),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    // Check eligibility before sending (block status + recipient restrictions).
    Map<String, bool>? eligibility;
    try {
      eligibility = await _checkEligibility();
    } catch (_) {
      // NOTE: If the eligibility check fails (e.g. network error), we allow
      // the send to proceed rather than silently blocking the user.
    }

    if (eligibility?['isBlockedByRecipient'] == true) {
      _showBlockedSnackBar();
      return;
    }

    setState(() => _isSending = true);
    try {
      final warning = await ref
          .read(chatMessagesProvider(widget.chatRoomId).notifier)
          .sendMessage(text);
      _inputController.clear();
      _scrollToBottom();

      // Show filter warning if the message contained warn-level sensitive words.
      // The message has already been sent; this is a gentle reminder only.
      if (warning != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(warning),
            backgroundColor: Colors.amber.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Warn if the recipient has a platform restriction.
      final isMuted  = eligibility?['recipientIsMuted']  == true;
      final isFrozen = eligibility?['recipientIsFrozen'] == true;
      if (isMuted || isFrozen) {
        _showRecipientRestrictedSnackBar(isMuted: isMuted, isFrozen: isFrozen);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Send failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _handlePickImage() async {
    if (_isSending) return;

    // Block check before picking an image — fast-fail before opening gallery.
    Map<String, bool>? eligibility;
    try {
      eligibility = await _checkEligibility();
    } catch (_) {
      // Allow on error — same policy as text messages.
    }

    if (eligibility?['isBlockedByRecipient'] == true) {
      _showBlockedSnackBar();
      return;
    }

    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;

    setState(() => _isSending = true);
    try {
      final bytes = await image.readAsBytes();
      await ref
          .read(chatMessagesProvider(widget.chatRoomId).notifier)
          .sendImage(bytes, image.name);
      _scrollToBottom();

      final isMuted  = eligibility?['recipientIsMuted']  == true;
      final isFrozen = eligibility?['recipientIsFrozen'] == true;
      if (isMuted || isFrozen) {
        _showRecipientRestrictedSnackBar(isMuted: isMuted, isFrozen: isFrozen);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image send failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
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
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatRoomId));
    final currentUserId = ref.watch(authStateProvider).value?.id;
    final colors = context.smivoColors;

    // Re-mark as read whenever new messages arrive while viewing this chat.
    ref.listen(chatMessagesProvider(widget.chatRoomId), (previous, next) {
      final prevLen = previous?.value?.length ?? 0;
      final nextLen = next.value?.length ?? 0;
      if (nextLen > prevLen) {
        // New message arrived while user is on this screen
        ref.read(chatMessagesProvider(widget.chatRoomId).notifier).markAsRead();
      }
    });

    final roomAsync = ref.watch(chatRoomProvider(widget.chatRoomId));
    final typo = context.smivoTypo;
    // NOTE: ContentWidthConstraint is applied on desktop to center the
    // message area and input bar, keeping them readable at wide widths.
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Breakpoints.isDesktop(screenWidth);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surfaceContainerLowest,
        elevation: 0,
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectionMode = false;
                    _selectedMessageIds.clear();
                  });
                },
              )
            : const BackButton(),
        title: _selectionMode
            ? Text(
                '${_selectedMessageIds.length} Selected',
                style: typo.titleMedium.copyWith(fontWeight: FontWeight.w700),
              )
            : roomAsync.when(
          loading: () => const SizedBox(),
          error: (_, __) => const Text('Error'),
          data: (room) {
            final otherUser =
                room.buyerId == currentUserId ? room.seller : room.buyer;
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.surfaceContainerHigh,
                  backgroundImage:
                      otherUser?.avatarUrl != null &&
                              otherUser!.avatarUrl!.trim().isNotEmpty
                          ? NetworkImage(otherUser.avatarUrl!)
                          : null,
                  child:
                      otherUser?.avatarUrl == null ||
                              otherUser!.avatarUrl!.trim().isEmpty
                          ? Icon(
                            Icons.person,
                            color: colors.onSurface.withValues(alpha: 0.5),
                            size: 18,
                          )
                          : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        otherUser?.displayName ?? 'User',
                        style: typo.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (otherUser?.email != null)
                        Text(
                          otherUser!.email,
                          style: typo.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      if (otherUser != null)
                        UserRatingBadge(
                          user: otherUser,
                          role:
                              room.buyerId == currentUserId
                                  ? 'seller'
                                  : 'buyer',
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        titleSpacing: 0,
        actions: [
          roomAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (room) {
              if (_selectionMode) {
                return TextButton(
                  onPressed: _selectedMessageIds.isEmpty
                      ? null
                      : () => _handleReportSelection(room),
                  child: Text(
                    'Report',
                    style: typo.labelLarge.copyWith(
                      color: _selectedMessageIds.isEmpty
                          ? colors.onSurfaceVariant
                          : colors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              final otherUser =
                  room.buyerId == currentUserId ? room.seller : room.buyer;
              if (otherUser == null) return const SizedBox();
              return IconButton(
                icon: Icon(Icons.block, color: colors.error),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              context.smivoRadius.xl,
                            ),
                          ),
                          title: const Text('Block User'),
                          content: const Text(
                            'Are you sure you want to block this user? You will no longer see their listings.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Block',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    if (!context.mounted) return;
                    final goRouter = GoRouter.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    try {
                      await ref
                          .read(moderationActionsProvider.notifier)
                          .blockUser(otherUser.id);
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('User blocked.')),
                      );
                      if (goRouter.canPop()) {
                        goRouter.pop();
                      } else {
                        goRouter.goNamed(AppRoutes.home);
                      }
                    } catch (e) {
                      debugPrint('Error blocking user: $e');
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Error blocking user: $e')),
                      );
                    }
                  }
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SelectionArea(
        child: Column(
          children: [
            // NOTE: Extract listingId from room data to watch listing
            // independently. This avoids nested async and prevents
            // the listing preview from flickering when room refreshes.
            _buildListingPreview(context, roomAsync),
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Say hello!'),
                  );
                }
                // NOTE: On desktop the message list is constrained to 720px
                // for readability. ContentWidthConstraint centers it.
                final listView = ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    final isMine = msg.senderId == currentUserId;
                    return _MessageBubble(
                      message: msg,
                      isMine: isMine,
                      isSelected: _selectedMessageIds.contains(msg.id),
                      selectionMode: _selectionMode,
                      onSelect: (id) {
                        setState(() {
                          if (_selectedMessageIds.contains(id)) {
                            _selectedMessageIds.remove(id);
                            if (_selectedMessageIds.isEmpty) {
                              _selectionMode = false;
                            }
                          } else {
                            _selectedMessageIds.add(id);
                          }
                        });
                      },
                      onLongPress: (id) {
                        if (!_selectionMode) {
                          setState(() {
                            _selectionMode = true;
                            _selectedMessageIds.add(id);
                          });
                        }
                      },
                    );
                  },
                );
                return isDesktop
                    ? ContentWidthConstraint(maxWidth: 720, child: listView)
                    : listView;
              },
            ),
          ),
          // NOTE: Input bar also constrained on desktop for visual consistency.
          isDesktop
              ? ContentWidthConstraint(maxWidth: 720, child: _buildInputBar())
              : _buildInputBar(),
        ],
      ),
    ),
  );
}

  /// Builds the listing preview bar independently from the room
  /// async state to avoid nested loading flicker.
  Widget _buildListingPreview(
    BuildContext context,
    AsyncValue<ChatRoom> roomAsync,
  ) {
    final room = roomAsync.value;
    if (room == null) return const SizedBox.shrink();

    final listingAsync = ref.watch(listingDetailProvider(room.listingId));
    final listing = listingAsync.value;
    if (listing == null) return const SizedBox.shrink();

    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final imageUrl =
        listing.images.isNotEmpty ? listing.images.first.imageUrl : null;

    final orderAsync = ref.watch(
      latestOrderByListingAndBuyerProvider(
        listingId: room.listingId,
        buyerId: room.buyerId,
      ),
    );
    final order = orderAsync.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          if (order != null && order.status != 'pending') {
            context.pushNamed(
              AppRoutes.orderDetail,
              pathParameters: {'id': order.id},
              extra: order,
            );
          } else {
            context.pushNamed(
              AppRoutes.listingDetail,
              pathParameters: {'id': listing.id},
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  borderRadius: BorderRadius.circular(radius.xs),
                  image:
                      imageUrl != null
                          ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    imageUrl == null ? const Icon(Icons.image, size: 16) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  listing.title,
                  style: typo.labelLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${listing.price.toStringAsFixed(0)}',
                style: typo.labelLarge.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: colors.shadow)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Add Button
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: colors.primary),
              onPressed: _handlePickImage,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(radius.lg),
                ),
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: typo.bodyMedium.copyWith(
                      color: colors.outlineVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon:
                  _isSending
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Icon(Icons.send, color: colors.primary),
              onPressed: _isSending ? null : _handleSend,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleReportSelection(ChatRoom room) async {
    final currentUserId = ref.read(authStateProvider).value?.id;
    final otherUser = room.buyerId == currentUserId ? room.seller : room.buyer;
    if (otherUser == null || currentUserId == null) return;

    final messages =
        ref.read(chatMessagesProvider(widget.chatRoomId)).value ?? [];
    final selectedMessages =
        messages.where((m) => _selectedMessageIds.contains(m.id)).toList();

    if (selectedMessages.isEmpty) return;

    // Calculate time window: 20 days before earliest, 20 days after latest selected message
    DateTime earliest = selectedMessages.first.createdAt;
    DateTime latest = selectedMessages.first.createdAt;

    for (final m in selectedMessages) {
      if (m.createdAt.isBefore(earliest)) earliest = m.createdAt;
      if (m.createdAt.isAfter(latest)) latest = m.createdAt;
    }

    final startWindow = earliest.subtract(const Duration(days: 20));
    final endWindow = latest.add(const Duration(days: 20));

    // Show report dialog
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (ctx) => ReportDialog(
            title: 'Report Chat',
            onSubmit: (category, reason) async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                // Fetch context messages for evidence
                final repo = ref.read(chatRepositoryProvider);
                final evidenceMessages = await repo.fetchMessagesInWindow(
                  chatRoomId: room.id,
                  start: startWindow,
                  end: endWindow,
                );

                final evidenceJson = {
                  'window_start': startWindow.toIso8601String(),
                  'window_end': endWindow.toIso8601String(),
                  'messages': evidenceMessages.map((m) => m.toJson()).toList(),
                };

                await ref
                    .read(moderationActionsProvider.notifier)
                    .reportContent(
                      reportedUserId: otherUser.id,
                      chatRoomId: room.id,
                      reasonCategory: category,
                      reason: reason,
                      selectedMessageIds: _selectedMessageIds.toList(),
                      evidence: evidenceJson,
                    );

                setState(() {
                  _selectionMode = false;
                  _selectedMessageIds.clear();
                });

                if (context.mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Report submitted with evidence.'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                    ),
                  );
                }
              }
            },
          ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.isSelected = false,
    this.selectionMode = false,
    this.onSelect,
    this.onLongPress,
  });

  final Message message;
  final bool isMine;
  final bool isSelected;
  final bool selectionMode;
  final Function(String id)? onSelect;
  final Function(String id)? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return GestureDetector(
      onLongPress: () => onLongPress?.call(message.id),
      onTap: () {
        if (selectionMode) {
          onSelect?.call(message.id);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment:
              isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (selectionMode) ...[
              Checkbox(
                value: isSelected,
                onChanged: (_) => onSelect?.call(message.id),
                shape: const CircleBorder(),
                activeColor: colors.primary,
              ),
              const SizedBox(width: 4),
            ],
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        message.messageType == 'image'
                            ? EdgeInsets.zero
                            : const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                    decoration: BoxDecoration(
                      color:
                          isMine ? colors.chatBubbleSelf : colors.chatBubbleOther,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(radius.lg),
                        topRight: Radius.circular(radius.lg),
                        bottomLeft: Radius.circular(
                          isMine ? radius.lg : radius.xs,
                        ),
                        bottomRight: Radius.circular(
                          isMine ? radius.xs : radius.lg,
                        ),
                      ),
                    ),
                    child:
                        message.messageType == 'image' && message.imageUrl != null
                            ? GestureDetector(
                              onTap:
                                  () => showDialog(
                                    context: context,
                                    builder:
                                        (_) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: EdgeInsets.zero,
                                          child: Stack(
                                            children: [
                                              InteractiveViewer(
                                                child: Center(
                                                  child: Image.network(
                                                    message.imageUrl!,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 40,
                                                right: 20,
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          Navigator.pop(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(radius.card),
                                child: Image.network(
                                  message.imageUrl!,
                                  width: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        width: 200,
                                        height: 150,
                                        color: colors.surfaceContainerHigh,
                                        child: const Icon(Icons.broken_image),
                                      ),
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 200,
                                      height: 150,
                                      color: colors.surfaceContainerHigh,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            : IgnorePointer(
                              ignoring: selectionMode,
                              child: SelectableText(
                                message.content,
                                style: typo.bodyLarge.copyWith(
                                  color:
                                      isMine
                                          ? colors.chatBubbleTextSelf
                                          : colors.chatBubbleTextOther,
                                  height: 1.4,
                                ),
                              ),
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Text(
                      DateFormat(
                        'yyyy-MM-dd HH:mm',
                      ).format(message.createdAt.toLocal()),
                      style: typo.labelSmall.copyWith(
                        color: colors.outlineVariant,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
