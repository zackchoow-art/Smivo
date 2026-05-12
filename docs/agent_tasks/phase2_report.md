# Phase 2 完成报告：Dart Models + Repository

**执行时间：** 2026-05-11
**执行 Agent：** Claude Sonnet 4.6 (Antigravity)

---

## 1. 创建 / 修改的文件列表

| # | 操作 | 文件路径 | 行数 |
|---|------|----------|------|
| 1 | 创建 | `app/lib/data/models/carpool_trip.dart` | 53 |
| 2 | 创建 | `app/lib/data/models/carpool_member.dart` | 34 |
| 3 | 创建 | `app/lib/data/models/carpool_proposal.dart` | 37 |
| 4 | 创建 | `app/lib/data/models/carpool_vote.dart` | 26 |
| 5 | 创建 | `app/lib/data/models/group_chat_room.dart` | 29 |
| 6 | 创建 | `app/lib/data/models/group_chat_member.dart` | 27 |
| 7 | 创建 | `app/lib/data/models/group_message.dart` | 32 |
| 8 | 创建 | `app/lib/data/repositories/carpool_repository.dart` | 297 |
| 9 | 创建 | `app/lib/data/repositories/group_chat_repository.dart` | 158 |
| 10 | 修改 | `app/lib/core/constants/app_constants.dart` | 74 (+11 行) |

**总计：** 767 行（含新增行）

---

## 2. 设计决策与假设

### 2.1 循环依赖问题（CarpoolTrip ↔ CarpoolMember）

**问题：** `CarpoolTrip` 的嵌套 members 字段需要引用 `CarpoolMember`，而如果 `CarpoolMember` 也引用 `CarpoolTrip` 会产生循环 import。

**解决方案：** 采用**单向引用**策略：
- `CarpoolMember` 只嵌套 `UserProfile?`（不引用 `CarpoolTrip`）
- `CarpoolTrip` 引用 `CarpoolMember`（单向依赖链）

这与现有代码库的 `Order → OrderListingPreview`（非循环）模式一致。

### 2.2 GroupChatRoom ↔ GroupChatMember 同样处理

- `GroupChatMember` 只嵌套 `UserProfile?`
- `GroupChatRoom` 引用 `GroupChatMember`（单向）

### 2.3 Realtime 消息不含 joined 关系

`subscribeToGroupMessages` 的 callback 注释中明确说明：Supabase Realtime 的 `payload.newRecord` 不包含 JOIN 关系，`sender` 字段将为 `null`。Provider 层在接收到 Realtime 事件后需要重新 fetch 完整消息列表，或单独 fetch sender profile。

### 2.4 fetchMyTrips 使用 inner join

`fetchMyTrips` 使用 `carpool_members!inner(user_id)` + `.eq('members.user_id', userId)` 过滤，确保只返回该用户**确实加入**的行程（含创建者角色）。

### 2.5 RPC 方法命名假设

根据指令要求的 RPC 名称（Phase 1 由 Expert AI 创建）：
- `join_carpool_trip(p_trip_id, p_user_id)` → 返回 `CarpoolMember` 行
- `leave_carpool_trip(p_trip_id, p_user_id)` → 无返回
- `cast_carpool_vote(p_proposal_id, p_voter_id, p_vote)` → 无返回

如果 Phase 1 的 RPC 名称或参数名不同，只需更新 Repository 中对应的 `rpc()` 调用。

---

## 3. 偏离指令的地方

**无偏离。** 所有字段、方法签名、文件路径均严格按照指令执行：

- ✅ 未运行 `build_runner`（无 `.freezed.dart` / `.g.dart`）
- ✅ 未修改 `pubspec.yaml`、路由、现有 model 或 repository
- ✅ 未在 model 中添加任何业务逻辑
- ✅ 所有 Repository 方法捕获 `PostgrestException` → 重抛为 `DatabaseException`
- ✅ 所有 Repository 底部添加 `@riverpod` provider 注解
- ✅ AppConstants 只在末尾追加，未删除任何已有常量
- ✅ 表名全部使用 `AppConstants` 常量，无魔法字符串

---

## 4. 后续注意事项（供 Phase 3+ 参考）

1. 运行 `flutter pub run build_runner build --delete-conflicting-outputs` 生成所有 `.freezed.dart` 和 `.g.dart`
2. `fetchMyTrips` 的 `.eq('members.user_id', userId)` 语法需配合 `!inner` join 才能生效，请在集成测试中验证
3. `GroupMessage.fromJson` 收到 Realtime payload 时 `sender` 为 null，Phase 6 provider 层须处理此 null case
