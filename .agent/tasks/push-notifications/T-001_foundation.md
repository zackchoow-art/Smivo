# T-001: Push Notification Foundation — DB Migration + Model + Repository

## 任务目标

为 push notification 功能添加数据基础：数据库新增推送相关字段、更新 UserProfile freezed 模型、扩展 ProfileRepository 方法。

## 执行边界

### ✅ 你必须做的

1. **创建 SQL Migration 文件**: `supabase/migrations/00042_push_notification_fields.sql`
2. **修改 UserProfile model**: `lib/data/models/user_profile.dart`
3. **修改 ProfileRepository**: `lib/data/repositories/profile_repository.dart`
4. **运行 build_runner 重新生成代码**
5. **运行 flutter analyze 检查零错误**

### ❌ 你不许做的

- 不要修改任何 screen、widget、provider 文件（除 profile_repository.dart 外的 provider 不许动）
- 不要修改 main.dart
- 不要修改 pubspec.yaml
- 不要修改 iOS/Android 原生配置
- 不要新增任何 import 到不属于你任务范围的文件
- 不要重构或格式化已有代码
- 不要删除现有字段或方法

---

## 详细要求

### 1. SQL Migration: `supabase/migrations/00042_push_notification_fields.sql`

```sql
-- ============================================================
-- Smivo — Push Notification User Preferences
-- ============================================================

ALTER TABLE public.user_profiles 
  ADD COLUMN IF NOT EXISTS onesignal_player_id text,
  ADD COLUMN IF NOT EXISTS push_notifications_enabled boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS push_messages boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS push_order_updates boolean NOT NULL DEFAULT true;

-- Index for fast lookup when sending push
CREATE INDEX IF NOT EXISTS idx_user_profiles_onesignal 
  ON public.user_profiles(onesignal_player_id) 
  WHERE onesignal_player_id IS NOT NULL;
```

### 2. UserProfile Model: `lib/data/models/user_profile.dart`

在现有 `UserProfile` freezed class 中新增以下字段（加在 `emailNotificationsEnabled` 下方）:

```dart
// OneSignal device token for push notifications
@JsonKey(name: 'onesignal_player_id') String? onesignalPlayerId,
// Master push notification toggle
@JsonKey(name: 'push_notifications_enabled') @Default(true) bool pushNotificationsEnabled,
// Push preference for new chat messages
@JsonKey(name: 'push_messages') @Default(true) bool pushMessages,
// Push preference for order status updates
@JsonKey(name: 'push_order_updates') @Default(true) bool pushOrderUpdates,
```

### 3. ProfileRepository: `lib/data/repositories/profile_repository.dart`

添加以下两个方法到 `ProfileRepository` class：

```dart
/// Stores the OneSignal player ID for push notification targeting.
Future<void> updatePushToken({
  required String userId,
  required String playerId,
}) async {
  try {
    await _client
        .from('user_profiles')
        .update({'onesignal_player_id': playerId})
        .eq('id', userId);
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}

/// Updates push notification preferences for the user.
Future<void> updatePushPreferences({
  required String userId,
  required bool pushEnabled,
  required bool pushMessages,
  required bool pushOrderUpdates,
}) async {
  try {
    await _client.from('user_profiles').update({
      'push_notifications_enabled': pushEnabled,
      'push_messages': pushMessages,
      'push_order_updates': pushOrderUpdates,
    }).eq('id', userId);
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}
```

### 4. 代码生成

运行以下命令重新生成 freezed 和 riverpod 代码：

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. 验证

运行以下命令确认零错误：

```bash
flutter analyze --no-fatal-infos
```

---

## 执行报告

完成后，请将执行报告写入：
`/Users/george/smivo/.agent/tasks/push-notifications/T-001_report.md`

报告模板：

```markdown
# T-001 执行报告

## 完成状态: ✅ / ❌

## 修改文件清单
| 文件 | 操作 | 说明 |
|------|------|------|
| ... | 新建/修改 | ... |

## build_runner 输出
(粘贴关键输出行)

## flutter analyze 结果
(粘贴输出: 0 issues / N issues)

## 遇到的问题
(如有)
```
