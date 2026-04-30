# P0-2: Notification Settings 页面改版

## 目标
重新设计 Settings → Notification Settings 页面，实现以下改进：
1. 增加 iOS 系统通知权限检测 + 跳转到系统设置的引导
2. 增加 Email Notifications 总开关
3. 重新组织通知分类为：订单状态更新、新消息、平台通知、校园通知
4. 每个分类可独立控制"推送通知"和"Email通知"两个开关
5. 移除无用的 Price Alerts 和 Weekly Email Digest 选项

## 背景
- 当前文件：`app/lib/features/settings/screens/notification_settings_screen.dart`
- 当前提供的通知偏好字段（`user_profiles` 表）：
  - `push_notifications_enabled` — 推送总开关
  - `push_order_updates` — 订单更新推送
  - `push_messages` — 新消息推送
- 需要新增的数据库字段（新 migration）：
  - `email_notifications_enabled` — Email 通知总开关
  - `email_order_updates` — 订单 Email 通知
  - `email_messages` — 消息 Email 通知
  - `push_platform_updates` — 平台通知推送
  - `email_platform_updates` — 平台通知 Email
  - `push_campus_updates` — 校园通知推送
  - `email_campus_updates` — 校园通知 Email

## 执行边界

### ✅ 允许修改的文件：
1. `app/lib/features/settings/screens/notification_settings_screen.dart` — UI 重构
2. `app/lib/features/settings/providers/` — 如需新增 provider
3. `app/lib/data/repositories/profile_repository.dart` — 增加新字段的更新方法
4. `app/lib/data/models/user_profile.dart` — 增加新字段
5. `supabase/migrations/00048_notification_settings_expansion.sql` — 新建迁移

### ❌ 禁止修改的文件：
- 路由文件
- 任何其他 Feature 的文件
- push_notification_provider.dart
- Edge Function
- iOS/Android 原生配置

## 实施方案

### 步骤 1：数据库迁移
新建 `supabase/migrations/00048_notification_settings_expansion.sql`

注意：检查 `supabase/migrations/00043_notification_preferences_expansion.sql` 是否已有部分字段。先读取该文件确认现有字段，**避免重复添加**。

新增以下字段到 `user_profiles`（如不存在）：
```sql
ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS email_notifications_enabled boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS email_order_updates boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS email_messages boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS push_platform_updates boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS email_platform_updates boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS push_campus_updates boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS email_campus_updates boolean NOT NULL DEFAULT true;
```

### 步骤 2：更新 Model
文件：`app/lib/data/models/user_profile.dart`

在 `UserProfile` freezed class 中增加新字段（全部 `@Default(true)` + nullable）：
```dart
@Default(true) bool emailNotificationsEnabled,
@Default(true) bool emailOrderUpdates,
@Default(true) bool emailMessages,
@Default(true) bool pushPlatformUpdates,
@Default(true) bool emailPlatformUpdates,
@Default(true) bool pushCampusUpdates,
@Default(true) bool emailCampusUpdates,
```

然后运行代码生成：
```bash
cd /Users/george/smivo/app && dart run build_runner build --delete-conflicting-outputs
```

### 步骤 3：更新 Repository
文件：`app/lib/data/repositories/profile_repository.dart`

确保 `updateNotificationPreferences` 方法支持更新所有新字段。

### 步骤 4：重构 UI
文件：`app/lib/features/settings/screens/notification_settings_screen.dart`

新的 UI 结构：

```
╔══════════════════════════════════════╗
║  Push Notifications [总开关]         ║
║  ┌──────────────────────────────────┐║
║  │ ⚠️ 系统通知已禁用               │║  ← 仅当 iOS 层面禁止时显示
║  │ 点击前往设置开启                  │║
║  └──────────────────────────────────┘║
║                                      ║
║  Email Notifications [总开关]        ║
║                                      ║
║  ── 通知分类 ─────────────────────   ║
║                                      ║
║  订单状态更新                        ║
║    Push [开关]    Email [开关]       ║
║                                      ║
║  新消息                              ║
║    Push [开关]    Email [开关]       ║
║                                      ║
║  平台通知                            ║
║    Push [开关]    Email [开关]       ║
║                                      ║
║  校园通知                            ║
║    Push [开关]    Email [开关]       ║
╚══════════════════════════════════════╝
```

iOS 系统通知检测逻辑：
```dart
import 'package:permission_handler/permission_handler.dart';
// 或使用 OneSignal 自带的检测：
final permissionGranted = await OneSignal.Notifications.permission;
```

如果 iOS 通知被禁用，显示一个警告 banner，点击调用：
```dart
import 'package:app_settings/app_settings.dart';
AppSettings.openAppSettings(type: AppSettingsType.notification);
```

**注意**：检查 `pubspec.yaml` 中是否已有 `app_settings` 或 `permission_handler` 依赖。如果没有，使用 OneSignal 自带的 `OneSignal.Notifications.permission` 检测权限状态，使用 `OneSignal.Notifications.requestPermission(true)` 尝试重新请求，避免添加新依赖。

### 步骤 5：移除无用选项
删除界面中 Price Alerts 和 Weekly Email Digest 相关的 UI（如果存在）。

## 验证步骤
1. 运行 `cd /Users/george/smivo/app && dart run build_runner build --delete-conflicting-outputs`
2. 运行 `cd /Users/george/smivo/app && flutter analyze --no-fatal-infos`，确保 **0 errors, 0 warnings**
3. 确认所有新字段在 Model、Repository、UI 三层一致
4. 确认 SQL 迁移文件无语法错误

## 执行报告
写入：`/Users/george/smivo/.agent/tasks/P0-2_report.md`

报告需包含：
1. 修改了哪些文件及具体变更
2. 代码生成和 `flutter analyze` 输出结果
3. 新增的依赖（如有）
4. 需要手动执行的 SQL
5. UI 变更说明
