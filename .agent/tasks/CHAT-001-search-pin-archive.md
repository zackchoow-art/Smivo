# CHAT-001: Chat 置顶/归档/搜索 — 数据层 + UI 全链路

## 目标
实现 chat 列表页的：搜索过滤、滑动操作（置顶/标记未读/归档）、活动/归档视图切换。

## 修改文件清单

### 新建
1. `supabase/migrations/00034_chat_pin_archive.sql` — 数据库迁移

### 修改
2. `lib/data/models/chat_room.dart` — 添加 3 个字段
3. `lib/data/repositories/chat_repository.dart` — 添加 3 个方法
4. `lib/features/chat/providers/chat_provider.dart` — ChatConversation 扩展 + 新方法
5. `lib/features/chat/screens/chat_list_screen.dart` — 完全重写
6. `lib/features/chat/widgets/chat_list_item.dart` — 包裹 Slidable

### 不修改
- ❌ `chat_room_screen.dart` — 聊天房间内部不动
- ❌ `chat_popup.dart` — 弹窗不动
- ❌ `message.dart` — 消息模型不动

---

## 步骤 1: 数据库迁移

创建 `supabase/migrations/00034_chat_pin_archive.sql`：

```sql
-- Add pin, archive, and manual unread override columns to chat_rooms.
-- These are per-room flags (not per-user), suitable for 1-on-1 chats.
ALTER TABLE public.chat_rooms
  ADD COLUMN IF NOT EXISTS is_pinned BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_unread_override BOOLEAN NOT NULL DEFAULT false;
```

## 步骤 2: ChatRoom 模型

在 `lib/data/models/chat_room.dart` 的 factory 中添加 3 个字段：

```dart
@JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
@JsonKey(name: 'is_archived') @Default(false) bool isArchived,
@JsonKey(name: 'is_unread_override') @Default(false) bool isUnreadOverride,
```

添加后**必须**运行 `dart run build_runner build --delete-conflicting-outputs` 重新生成 freezed 代码。

## 步骤 3: ChatRepository 新增方法

在 `lib/data/repositories/chat_repository.dart` 添加：

```dart
/// Toggle the pinned state of a chat room.
Future<void> togglePin(String chatRoomId, bool isPinned) async {
  try {
    await _client
        .from(AppConstants.tableChatRooms)
        .update({'is_pinned': isPinned})
        .eq('id', chatRoomId);
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}

/// Toggle the archived state of a chat room.
Future<void> toggleArchive(String chatRoomId, bool isArchived) async {
  try {
    await _client
        .from(AppConstants.tableChatRooms)
        .update({'is_archived': isArchived})
        .eq('id', chatRoomId);
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}

/// Toggle the manual unread override of a chat room.
Future<void> toggleUnreadOverride(String chatRoomId, bool isUnread) async {
  try {
    await _client
        .from(AppConstants.tableChatRooms)
        .update({'is_unread_override': isUnread})
        .eq('id', chatRoomId);
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}
```

## 步骤 4: ChatProvider 更新

### 4a. 扩展 ChatConversation

```dart
class ChatConversation {
  final String id;
  final String name;
  final String latestMessage;
  final String time;
  final int unreadCount;
  final String? avatarUrl;
  final String? initials;
  final String listingTitle;
  // NEW fields for search & features
  final String partnerName;
  final String partnerEmail;
  final String listingDescription;
  final double listingPrice;
  final bool isPinned;
  final bool isArchived;
  final bool isUnreadOverride;
  ...
}
```

### 4b. ChatRoomList 新增方法

在 `ChatRoomList` notifier 中添加操作方法：

```dart
Future<void> togglePin(String roomId, bool isPinned) async {
  await ref.read(chatRepositoryProvider).togglePin(roomId, isPinned);
  ref.invalidateSelf();
}

Future<void> toggleArchive(String roomId, bool isArchived) async {
  await ref.read(chatRepositoryProvider).toggleArchive(roomId, isArchived);
  ref.invalidateSelf();
}

Future<void> toggleUnreadOverride(String roomId, bool isUnread) async {
  await ref.read(chatRepositoryProvider).toggleUnreadOverride(roomId, isUnread);
  ref.invalidateSelf();
}
```

### 4c. 构建 ChatConversation 时填充搜索字段

在 `chat_list_screen.dart` 构建 `ChatConversation` 时，需要填充新字段。
由于 `ChatListingPreview` 只有 `id` 和 `title`（没有 description 和 price），
**需要扩展查询**。

**选项 A**：扩展 `ChatListingPreview` 模型添加 `description` 和 `price`。
**选项 B**：扩展 `fetchChatRooms` 查询的 listing select。

**执行选项 B**（最小改动）：

在 `chat_repository.dart` 的 `fetchChatRooms` 查询中，把：
```
listing:listings(id, title, images:listing_images(image_url))
```
改为：
```
listing:listings(id, title, description, price, images:listing_images(image_url))
```

同时在 `ChatListingPreview` 模型中添加：
```dart
String? description,
@Default(0.0) double price,
```

**额外修改**：`lib/data/models/chat_listing_preview.dart` — 添加 2 个字段。

## 步骤 5: ChatListScreen 重写

改为 `ConsumerStatefulWidget`。

### 5a. State 变量
```dart
String _searchQuery = '';
bool _showArchived = false; // false = 活动消息, true = 归档消息
```

### 5b. 右上角切换按钮
在标题行右侧添加一个 `IconButton`：
- 显示 `Icons.archive_outlined`（当前看活动）或 `Icons.chat_bubble_outline`（当前看归档）
- 点击切换 `_showArchived`

### 5c. 搜索栏
给搜索 `TextField` 添加 `onChanged` → 更新 `_searchQuery`。

### 5d. 数据过滤逻辑
```dart
// 1. 按活动/归档过滤
final filtered = rooms.where((r) => r.isArchived == _showArchived).toList();

// 2. 按搜索关键词过滤
final searchFiltered = _searchQuery.isEmpty
    ? filtered
    : filtered.where((room) {
        final q = _searchQuery.toLowerCase();
        final conv = buildConversation(room); // 提取构建逻辑
        return conv.listingTitle.toLowerCase().contains(q)
            || conv.partnerName.toLowerCase().contains(q)
            || conv.partnerEmail.toLowerCase().contains(q)
            || conv.listingDescription.toLowerCase().contains(q)
            || conv.listingPrice.toString().contains(q)
            || conv.latestMessage.toLowerCase().contains(q);
      }).toList();

// 3. 排序：置顶的排最前
searchFiltered.sort((a, b) {
  if (a.isPinned && !b.isPinned) return -1;
  if (!a.isPinned && b.isPinned) return 1;
  return 0; // 保持原有时间排序
});
```

### 5e. 空状态
- 活动消息为空："No conversations yet. Start chatting from a listing."
- 归档为空："No archived conversations."
- 搜索无结果："No matching conversations."

## 步骤 6: ChatListItem 重写

用 `flutter_slidable` 包裹。

```dart
import 'package:flutter_slidable/flutter_slidable.dart';

Slidable(
  key: ValueKey(conversation.id),
  // 右滑（startActionPane）：置顶 + 标记未读
  startActionPane: ActionPane(
    motion: const DrawerMotion(),
    extentRatio: 0.5,
    children: [
      SlidableAction(
        onPressed: (_) => onTogglePin?.call(),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        icon: conversation.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
        label: conversation.isPinned ? 'Unpin' : 'Pin',
      ),
      SlidableAction(
        onPressed: (_) => onToggleUnread?.call(),
        backgroundColor: colors.warning,
        foregroundColor: Colors.white,
        icon: Icons.mark_email_unread_outlined,
        label: 'Unread',
      ),
    ],
  ),
  // 左滑（endActionPane）：归档
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    extentRatio: 0.25,
    children: [
      SlidableAction(
        onPressed: (_) => onArchive?.call(),
        backgroundColor: colors.outlineVariant,
        foregroundColor: Colors.white,
        icon: Icons.archive_outlined,
        label: 'Archive',
      ),
    ],
  ),
  child: // 原有的卡片内容
)
```

**注意**：归档视图中，左滑应变为"取消归档"(Unarchive)。

### ChatListItem 新增回调

```dart
final VoidCallback? onTogglePin;
final VoidCallback? onToggleUnread;
final VoidCallback? onArchive;
```

### 置顶视觉标识

置顶的聊天卡片左侧添加一个小 📌 图标或改变背景色。

## 验证

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
cd /Users/george/smivo && flutter analyze
```

## 执行报告

写入：`.agent/reports/CHAT-001-report.md`
