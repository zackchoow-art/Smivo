# Phase 2: Dart Models + Repository — Sonnet 执行指令

## ⛔ 边界
- **只能创建/修改**下方列出的文件，不得修改其他任何文件
- **不得**修改 `pubspec.yaml`、路由、现有 model 或 repository
- **不得**运行 `build_runner`，只写 `.dart` 源文件，`.freezed.dart` 和 `.g.dart` 由人工后续生成
- **不得**在 model 中添加任何业务逻辑

## 📋 任务
根据 Phase 1 已创建的数据库 Schema，创建对应的 Dart 数据模型和 Repository。

## 📐 代码规范（严格遵循）

### Model 文件模板
参考 `app/lib/data/models/order.dart` 的结构：
```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'xxx.freezed.dart';
part 'xxx.g.dart';

/// Doc comment explaining what this model represents.
@freezed
abstract class Xxx with _$Xxx {
  const factory Xxx({
    required String id,
    @JsonKey(name: 'snake_case_field') required String camelCaseField,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Xxx;

  factory Xxx.fromJson(Map<String, dynamic> json) => _$XxxFromJson(json);
}
```

### Repository 文件模板
参考 `app/lib/data/repositories/chat_repository.dart`：
- 构造函数接收 `SupabaseClient`
- 所有方法 `async`，捕获 `PostgrestException` 转为 `AppException`
- 使用 `AppConstants` 中的表名常量
- 底部用 `@riverpod` 注解生成 provider

## 📁 需要创建的文件

### 1. `app/lib/data/models/carpool_trip.dart`
字段（对应 `carpool_trips` 表）：
- `id` (String, required)
- `creatorId` (String, required, json: creator_id)
- `schoolId` (String, required, json: school_id)
- `role` (String, required) — 'driver' | 'organizer'
- `departureAddress` (String, required, json: departure_address)
- `departureLat` (double?, json: departure_lat)
- `departureLng` (double?, json: departure_lng)
- `departurePlaceId` (String?, json: departure_place_id)
- `destinationAddress` (String, required, json: destination_address)
- `destinationLat` (double?, json: destination_lat)
- `destinationLng` (double?, json: destination_lng)
- `destinationPlaceId` (String?, json: destination_place_id)
- `departureTime` (DateTime, required, json: departure_time)
- `estimatedArrivalTime` (DateTime?, json: estimated_arrival_time)
- `totalSeats` (int, required, json: total_seats) — 1~4
- `availableSeats` (int, required, json: available_seats)
- `luggageLimit` (String?, json: luggage_limit) — 'none' | 'small' | 'medium' | 'large'
- `approvalMode` (String, default 'manual', json: approval_mode) — 'auto' | 'manual'
- `status` (String, default 'active') — 'active' | 'inactive' | 'departed' | 'completed' | 'cancelled'
- `closingTime` (DateTime?, json: closing_time)
- `note` (String?)
- `createdAt` (DateTime, required, json: created_at)
- `updatedAt` (DateTime, required, json: updated_at)
- 嵌套 join（可选）：`UserProfile? creator`, `List<CarpoolMember> members` (default [])

### 2. `app/lib/data/models/carpool_member.dart`
字段（对应 `carpool_members` 表）：
- `id` (String, required)
- `tripId` (String, required, json: trip_id)
- `userId` (String, required, json: user_id)
- `role` (String, required) — 'creator' | 'member'
- `status` (String, default 'pending') — 'pending' | 'approved' | 'rejected' | 'left' | 'kicked'
- `joinedAt` (DateTime?, json: joined_at)
- `createdAt` (DateTime, required, json: created_at)
- 嵌套 join（可选）：`UserProfile? user`

### 3. `app/lib/data/models/carpool_proposal.dart`
字段（对应 `carpool_proposals` 表）：
- `id` (String, required)
- `tripId` (String, required, json: trip_id)
- `proposerId` (String, required, json: proposer_id)
- `proposalType` (String, required, json: proposal_type) — 'change_time' | 'change_departure' | 'change_destination' | 'kick_member'
- `oldValue` (String?, json: old_value)
- `newValue` (String?, json: new_value)
- `targetUserId` (String?, json: target_user_id) — for kick proposals
- `status` (String, default 'pending') — 'pending' | 'approved' | 'rejected' | 'expired'
- `requiredVotes` (int, required, json: required_votes)
- `currentVotes` (int, default 0, json: current_votes)
- `expiresAt` (DateTime?, json: expires_at)
- `createdAt` (DateTime, required, json: created_at)
- `updatedAt` (DateTime, required, json: updated_at)

### 4. `app/lib/data/models/carpool_vote.dart`
字段（对应 `carpool_votes` 表）：
- `id` (String, required)
- `proposalId` (String, required, json: proposal_id)
- `voterId` (String, required, json: voter_id)
- `vote` (String, required) — 'approve' | 'reject'
- `createdAt` (DateTime, required, json: created_at)

### 5. `app/lib/data/models/group_chat_room.dart`
字段（对应 `group_chat_rooms` 表）：
- `id` (String, required)
- `tripId` (String, required, json: trip_id)
- `name` (String, required)
- `createdBy` (String, required, json: created_by)
- `createdAt` (DateTime, required, json: created_at)
- `updatedAt` (DateTime, required, json: updated_at)
- 嵌套 join（可选）：`List<GroupChatMember> members` (default [])

### 6. `app/lib/data/models/group_chat_member.dart`
字段（对应 `group_chat_members` 表）：
- `id` (String, required)
- `roomId` (String, required, json: room_id)
- `userId` (String, required, json: user_id)
- `joinedAt` (DateTime, required, json: joined_at)
- 嵌套 join（可选）：`UserProfile? user`

### 7. `app/lib/data/models/group_message.dart`
字段（对应 `group_messages` 表）：
- `id` (String, required)
- `roomId` (String, required, json: room_id)
- `senderId` (String, required, json: sender_id)
- `content` (String, required)
- `messageType` (String, default 'text', json: message_type) — 'text' | 'image' | 'system'
- `imageUrl` (String?, json: image_url)
- `createdAt` (DateTime, required, json: created_at)
- 嵌套 join（可选）：`UserProfile? sender`

### 8. `app/lib/data/repositories/carpool_repository.dart`
方法清单（全部 async，catch PostgrestException → AppException）：
- `fetchActiveTrips(String schoolId)` → `List<CarpoolTrip>`（带 creator join）
- `fetchTripDetail(String tripId)` → `CarpoolTrip`（带 members + creator join）
- `fetchMyTrips(String userId)` → `List<CarpoolTrip>`
- `createTrip({...})` → `CarpoolTrip`
- `updateTrip(String tripId, Map<String, dynamic> updates)` → void
- `cancelTrip(String tripId)` → void
- `fetchTripMembers(String tripId)` → `List<CarpoolMember>`（带 user join）
- `requestJoinTrip(String tripId, String userId)` → `CarpoolMember`（调用 RPC `join_carpool_trip`）
- `respondToJoinRequest(String memberId, bool approve)` → void
- `leaveTrip(String tripId, String userId)` → void（调用 RPC）
- `createProposal({...})` → `CarpoolProposal`
- `fetchProposals(String tripId)` → `List<CarpoolProposal>`
- `castVote(String proposalId, String voterId, String vote)` → void（调用 RPC `cast_carpool_vote`）
- 底部加 `@riverpod` provider 注解

### 9. `app/lib/data/repositories/group_chat_repository.dart`
方法清单：
- `fetchGroupChatRoom(String tripId)` → `GroupChatRoom`（带 members join）
- `fetchGroupMessages(String roomId)` → `List<GroupMessage>`（带 sender join）
- `sendGroupMessage({roomId, senderId, content})` → `GroupMessage`
- `sendGroupImageMessage({roomId, senderId, imageUrl})` → `GroupMessage`
- `subscribeToGroupMessages({roomId, onMessage})` → `RealtimeChannel`
- 底部加 `@riverpod` provider 注解

### 10. 修改 `app/lib/core/constants/app_constants.dart`
在现有常量区域**末尾添加**（不删除任何已有常量）：
```dart
// Carpool tables
static const String tableCarpoolTrips = 'carpool_trips';
static const String tableCarpoolMembers = 'carpool_members';
static const String tableCarpoolProposals = 'carpool_proposals';
static const String tableCarpoolVotes = 'carpool_votes';
// Group chat tables
static const String tableGroupChatRooms = 'group_chat_rooms';
static const String tableGroupChatMembers = 'group_chat_members';
static const String tableGroupMessages = 'group_messages';
```

## ✅ 完成报告
执行完成后，在 `docs/agent_tasks/phase2_report.md` 中写入：
1. 创建/修改的文件列表
2. 每个文件的行数
3. 遇到的任何问题或假设
4. 是否有偏离指令的地方（如有请说明原因）
