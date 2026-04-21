# Chat Feature Integration Analysis

## Task 1: Status Report

| File | Data Source | Existing Logic / Methods | Missing Fields / Issues |
| :--- | :--- | :--- | :--- |
| `lib/data/models/chat_room.dart` | Real (Supabase) | `fromJson`, `toJson` | Missing `unread_count_buyer`, `unread_count_seller`. |
| `lib/data/models/message.dart` | Real (Supabase) | `fromJson`, `toJson` | Missing `message_type` (text/image/system) and `image_url`. |
| `lib/data/repositories/chat_repository.dart` | Real (Supabase) | `fetchChatRooms`, `getOrCreateChatRoom`, `fetchMessages`, `sendMessage`, `subscribeToMessages` | Mostly complete repository. `subscribeToMessages` is implemented but needs to be wired into Riverpod. |
| `lib/features/chat/providers/chat_provider.dart` | **Mock** | `ChatList` returns hardcoded `ChatConversation` objects. | Does not call `ChatRepository`. `ChatConversation` is a flat UI model that doesn't match the DB structure. |
| `lib/features/chat/screens/chat_list_screen.dart` | Mock State | Search bar UI, list of conversations. | Wired to `chatListProvider` (Mock). Uses a `chat_popup.dart` instead of a dedicated detail screen. |

---

## Task 2: Schema Mapping Analysis

### Chat Rooms Table (`chat_rooms`)

| DB Column | Dart Field | Match Status | Notes |
| :--- | :--- | :--- | :--- |
| `id` (uuid) | `String id` | ✅ Match | |
| `listing_id` (uuid) | `String listingId` | ✅ Match | |
| `buyer_id` (uuid) | `String buyerId` | ✅ Match | |
| `seller_id` (uuid) | `String sellerId` | ✅ Match | |
| `last_message_at` | `DateTime? lastMessageAt`| ✅ Match | |
| `unread_count_buyer`| **MISSING** | ❌ Missing | Add `int unreadCountBuyer`. |
| `unread_count_seller`| **MISSING** | ❌ Missing | Add `int unreadCountSeller`. |
| `created_at` | `DateTime createdAt` | ✅ Match | |
| `updated_at` | `DateTime updatedAt` | ✅ Match | |

### Messages Table (`messages`)

| DB Column | Dart Field | Match Status | Notes |
| :--- | :--- | :--- | :--- |
| `id` (uuid) | `String id` | ✅ Match | |
| `chat_room_id` (uuid)| `String chatRoomId` | ✅ Match | |
| `sender_id` (uuid) | `String senderId` | ✅ Match | |
| `content` (text) | `String content` | ✅ Match | |
| `message_type` (text)| **MISSING** | ❌ Missing | 'text', 'image', or 'system'. |
| `image_url` (text) | **MISSING** | ❌ Missing | |
| `is_read` (bool) | `bool isRead` | ✅ Match | |
| `created_at` | `DateTime createdAt` | ✅ Match | |
| `updated_at` | `DateTime updatedAt` | ✅ Match | |

---

## Task 3: Query Pattern Inventory

1.  **Conversation List**: `ChatRepository.fetchChatRooms(userId)`
    *   **Joins**: Needs `listings(title, price)` and `user_profiles(display_name, avatar_url)` (for the other participant).
    *   **Filtering**: `or('buyer_id.eq.$userId,seller_id.eq.$userId')`.

2.  **Message History**: `ChatRepository.fetchMessages(chatRoomId)`
    *   **Joins**: Usually standalone, but may join `user_profiles` for sender name/avatar if not cached.
    *   **Ordering**: `created_at` ascending.

3.  **Initiate Chat**: `ChatRepository.getOrCreateChatRoom(listingId, buyerId, sellerId)`
    *   Used when clicking "Message Seller" from a listing.

4.  **Send Message**: `ChatRepository.sendMessage(...)`
    *   Optimistic UI update recommended.

5.  **Mark as Read**: `ChatRepository.markMessagesAsRead(chatRoomId, userId)`
    *   **MISSING** in `ChatRepository`. Needs to update `is_read` and reset the relevant `unread_count` in `chat_rooms`.

6.  **Realtime Subscription**: `ChatRepository.subscribeToMessages(chatRoomId)`
    *   Subscribe to `INSERT` events on `messages` table filtered by `chatRoomId`.

---

## Task 4: Realtime Subscription Design Draft

### 1. Subscription Owner
The `AsyncNotifierProvider` for a specific chat room's messages should own the subscription.

```dart
@riverpod
class ChatMessages extends _$ChatMessages {
  RealtimeChannel? _channel;

  @override
  Future<List<Message>> build(String chatRoomId) async {
    // 1. Fetch initial history
    final messages = await ref.watch(chatRepositoryProvider).fetchMessages(chatRoomId);
    
    // 2. Subscribe to new messages
    _subscribe(chatRoomId);
    
    // 3. Cleanup on dispose
    ref.onDispose(() => _channel?.unsubscribe());
    
    return messages;
  }

  void _subscribe(String chatRoomId) {
    _channel = ref.read(chatRepositoryProvider).subscribeToMessages(
      chatRoomId: chatRoomId,
      onMessage: (message) {
        // Optimistically update state
        state = AsyncValue.data([...state.value ?? [], message]);
      },
    );
  }
}
```

### 2. Stream into UI
The `ChatMessagesProvider` provides the list of messages. The UI watches this and rebuilds on every new message event.

### 3. Reconnection Handling
`supabase_flutter` handles socket reconnection automatically. However, the provider should probably implement a "fetch missed" logic if the app comes back from background after a long time.

---

## Task 5: Unread Count Strategy

### Incrementing (Database Trigger Recommended)
To ensure accuracy even when the app is offline, a Postgres trigger should:
1.  When a message is inserted:
2.  If `sender_id == buyer_id`, increment `unread_count_seller` in `chat_rooms`.
3.  If `sender_id == seller_id`, increment `unread_count_buyer` in `chat_rooms`.

### Resetting (Application Logic)
When a user opens the chat room:
1.  Call a RPC or Repository method to:
    *   Update `messages` set `is_read = true` where `chat_room_id = ID` and `sender_id != current_user`.
    *   Update `chat_rooms` set `unread_count_[ROLE] = 0`.

---

## Task 6: Known Risks

1.  **Memory Leaks**: `RealtimeChannel.unsubscribe()` must be called in `ref.onDispose`. If providers are kept alive indefinitely, subscriptions will pile up.
2.  **Double Subscriptions**: Riverpod providers can rebuild. Use `ref.onDispose` and potentially check for existing channels before creating new ones.
3.  **Message Ordering**: If two messages arrive nearly simultaneously on a poor network, the UI might flicker or show them out of order. Always sort the local state by `created_at` after adding a new message.
4.  **Security (RLS)**:
    *   **Enforced**: Current RLS policy `Chat participants can read messages` correctly checks if `auth.uid()` is either the `buyer_id` or `seller_id` of the room.
    *   **Risk**: If RLS is misconfigured, user A could potentially listen to `messages` for a room they don't belong to. We must verify that `PostgresChangeFilter` combined with RLS prevents this server-side.
5.  **Local State Desync**: If a message is sent but the `sendMessage` call fails after the optimistic update, the UI must handle the "failed" state and allow retrying or removing the message.
