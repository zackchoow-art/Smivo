# CHAT-001 执行报告

## 执行时间
2026-04-26

## 1. 修改文件总览

| 文件 | 操作 | 说明 |
|------|------|------|
| `supabase/migrations/00034_chat_pin_archive.sql` | 新建 | 给 chat_rooms 添加 3 列 |
| `lib/data/models/chat_listing_preview.dart` | 修改 | 添加 description + price 字段 |
| `lib/data/models/chat_room.dart` | 修改 | 添加 isPinned + isArchived + isUnreadOverride 字段 |
| `lib/data/repositories/chat_repository.dart` | 修改 | 扩展 fetchChatRooms 查询 + 添加 3 个方法 |
| `lib/features/chat/providers/chat_provider.dart` | 修改 | 扩展 ChatConversation + 添加 3 个 notifier 方法 |
| `lib/features/chat/screens/chat_list_screen.dart` | 完全重写 | 搜索/归档切换/置顶排序 |
| `lib/features/chat/widgets/chat_list_item.dart` | 完全重写 | Slidable 滑动操作 |

---

## 2. 关键变更详情

### 步骤 1 — SQL 迁移

```sql
ALTER TABLE public.chat_rooms
  ADD COLUMN IF NOT EXISTS is_pinned BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_unread_override BOOLEAN NOT NULL DEFAULT false;
```

### 步骤 2a — `ChatListingPreview` 新增字段

```dart
String? description,   // 搜索用
@Default(0.0) double price,  // 搜索用
```

### 步骤 2b — `ChatRoom` 新增字段

```dart
@JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
@JsonKey(name: 'is_archived') @Default(false) bool isArchived,
@JsonKey(name: 'is_unread_override') @Default(false) bool isUnreadOverride,
```

### 步骤 3 — `fetchChatRooms` 查询扩展

```dart
// 改前
listing:listings(id, title, images:listing_images(image_url))
// 改后
listing:listings(id, title, description, price, images:listing_images(image_url))
```

### 步骤 3 — `ChatRepository` 新增方法

```dart
Future<void> togglePin(String chatRoomId, bool isPinned)
Future<void> toggleArchive(String chatRoomId, bool isArchived)
Future<void> toggleUnreadOverride(String chatRoomId, bool isUnread)
```

### 步骤 4a — `ChatConversation` 扩展

新增 7 个字段：`partnerName`, `partnerEmail`, `listingDescription`,
`listingPrice`, `isPinned`, `isArchived`, `isUnreadOverride`。
所有字段带默认值，向后兼容现有调用方。

### 步骤 4b — `ChatRoomList` 新增 notifier 方法

```dart
Future<void> togglePin(String roomId, bool isPinned)
Future<void> toggleArchive(String roomId, bool isArchived)
Future<void> toggleUnreadOverride(String roomId, bool isUnread)
```
每个方法调用 repository 后调用 `ref.invalidateSelf()` 触发刷新。

### 步骤 5 — `ChatListScreen` 重写

- 转为 `ConsumerStatefulWidget`
- State 变量：`_searchQuery`, `_showArchived`
- 右上角切换按钮：`Icons.archive_outlined` ↔ `Icons.chat_bubble_outline`
- 搜索栏：`onChanged` 实时过滤
- 过滤顺序：① 归档/活动分类 → ② 搜索关键词 → ③ 置顶排序
- 搜索字段：listingTitle / partnerName / partnerEmail / listingDescription / listingPrice / latestMessage
- 3 种空状态文案：搜索无结果 / 归档为空 / 无对话

### 步骤 6 — `ChatListItem` 重写（Slidable）

```
右滑（startActionPane, extentRatio: 0.5）:
  ├── 📌 Pin / Unpin   → colors.primary
  └── ✉️ Unread       → colors.warning

左滑（endActionPane, extentRatio: 0.25）:
  └── 📦 Archive / Unarchive（归档视图时变绿色）
```

置顶卡片特征：
- 背景色：`colors.primary.withValues(alpha: 0.07)`
- 标题前显示 `Icons.push_pin`（size 12）

---

## 3. `build_runner` 执行结果

```
Built with build_runner in 11s; wrote 69 outputs.
```

成功重新生成全项目的 freezed / json_serializable / riverpod_generator 代码。

---

## 4. `flutter analyze` 结果

```
Analyzing smivo...

4 issues found (info level only).
```

- **Error 数量：0**
- **Warning 数量：0**
- **Info 数量：4**（均为 `edit_profile_screen.dart` 的 `use_build_context_synchronously` 误报，与本任务无关）

---

## 5. ⚠️ 重要提醒

> **SQL 迁移文件 `00034_chat_pin_archive.sql` 已创建但未执行。**
> 请在 Supabase Dashboard → SQL Editor 中手动执行，否则：
> - `isPinned / isArchived / isUnreadOverride` 列不存在，所有 fetchChatRooms 调用会返回 JSON 解析默认值（false）
> - `togglePin / toggleArchive / toggleUnreadOverride` 方法会抛出 Supabase 错误
