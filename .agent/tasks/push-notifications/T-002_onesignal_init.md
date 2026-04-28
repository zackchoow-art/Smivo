# T-002: OneSignal SDK 初始化 + Push Notification Provider

## 任务目标

在 Flutter App 中初始化 OneSignal SDK，创建推送通知 Provider，实现登录/登出时的 player ID 管理。

## 前置条件

- T-001 已完成（UserProfile 模型已包含 `onesignalPlayerId` 字段，ProfileRepository 已包含 `updatePushToken` 方法）

## 执行边界

### ✅ 你必须做的

1. **修改 `lib/main.dart`**: 初始化 OneSignal SDK
2. **创建 `lib/core/providers/push_notification_provider.dart`**: 封装 OneSignal 逻辑
3. **修改 `lib/app.dart`**（如有必要）: 在 Widget 树中监听 push provider
4. **运行 build_runner 重新生成代码**
5. **运行 flutter analyze 检查零错误**

### ❌ 你不许做的

- 不要修改 `user_profile.dart` 模型（T-001 已完成）
- 不要修改 `profile_repository.dart`（T-001 已完成）
- 不要修改 Settings 页面（T-003 负责）
- 不要修改 iOS/Android 原生配置文件
- 不要修改 `pubspec.yaml`（onesignal_flutter 已添加）
- 不要修改 notification_provider.dart 或 notification_repository.dart
- 不要删除或重构任何现有代码

---

## 详细要求

### 1. 修改: `lib/main.dart`

将第 24 行的注释 `// NOTE: Initialize OneSignal here in Phase 2. See project-brief.md.` 替换为实际初始化代码：

```dart
import 'package:onesignal_flutter/onesignal_flutter.dart';

// 在 main() 中，Supabase.initialize 之后、runApp 之前：

// Initialize OneSignal for push notifications.
final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';
if (oneSignalAppId.isNotEmpty) {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose); // TODO: Remove in production
  OneSignal.initialize(oneSignalAppId);
}
```

### 2. 创建: `lib/core/providers/push_notification_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smivo/data/repositories/profile_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'push_notification_provider.g.dart';

/// Manages OneSignal push notification lifecycle:
/// - Requests permission on first login
/// - Stores player ID in user_profiles
/// - Handles login/logout identity
/// - Listens for notification opened events
@riverpod
class PushNotificationManager extends _$PushNotificationManager {
  @override
  Future<void> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;

    if (user == null) {
      // NOTE: Logout clears OneSignal identity so pushes stop
      OneSignal.logout();
      return;
    }

    // Associate Supabase user ID with OneSignal
    OneSignal.login(user.id);

    // Request push permission (iOS shows native dialog once)
    // NOTE: On web/Android this is a no-op or auto-granted
    if (!kIsWeb) {
      final granted = await OneSignal.Notifications.requestPermission(true);
      debugPrint('Push permission granted: $granted');
    }

    // Store player ID in DB for server-side push targeting
    _storePlayerId(user.id);

    // Setup notification opened handler
    OneSignal.Notifications.addClickListener((event) {
      // NOTE: Deep link handling will be added in a future phase.
      // For now, the app just opens to foreground.
      debugPrint('Notification clicked: ${event.notification.title}');
    });

    ref.onDispose(() {
      OneSignal.Notifications.removeClickListener(_onNotificationClicked);
    });
  }

  void _onNotificationClicked(OSNotificationClickEvent event) {
    debugPrint('Notification clicked: ${event.notification.title}');
  }

  Future<void> _storePlayerId(String userId) async {
    try {
      // NOTE: OneSignal v5 uses subscription ID instead of player ID
      final subscriptionId = OneSignal.User.pushSubscription.id;
      if (subscriptionId != null && subscriptionId.isNotEmpty) {
        final profileRepo = ref.read(profileRepositoryProvider);
        await profileRepo.updatePushToken(
          userId: userId,
          playerId: subscriptionId,
        );
      }
    } catch (e) {
      // HACK: Silently fail — push token storage is non-critical
      debugPrint('Failed to store push token: $e');
    }
  }
}
```

### 3. 确保 Provider 被监听

在 `lib/app.dart` 中（如果有的话），需要确保 `pushNotificationManagerProvider` 在 App 启动时被 watch。

查看 `lib/app.dart`，如果 App root widget 是一个 `ConsumerWidget`，在 build 方法中加一行：

```dart
// Initialize push notification lifecycle
ref.watch(pushNotificationManagerProvider);
```

如果 `app.dart` 不是 ConsumerWidget，则在 home_screen.dart 或 main scaffold 中 watch 它。

**关键**：只添加一行 `ref.watch(...)`，不要修改 app.dart 的其他任何内容。

### 4. 环境变量

确认 `assets/env` 文件中需要有 `ONESIGNAL_APP_ID=xxx` 这一行。但因为用户还没有创建 OneSignal App，所以 main.dart 中有 `if (oneSignalAppId.isNotEmpty)` 保护，不会崩溃。

**不要修改 `assets/env` 文件**（用户会手动添加 App ID）。

### 5. 代码生成

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6. 验证

```bash
flutter analyze --no-fatal-infos
```

---

## 关键注意事项

- OneSignal Flutter SDK v5 使用 `OneSignal.initialize()` 而不是 v3 的 `OneSignal.shared.setAppId()`
- 使用 `OneSignal.login(userId)` 关联用户身份，而不是 `setExternalUserId`
- `OneSignal.User.pushSubscription.id` 是 v5 获取 subscription ID 的方式
- 在 web 平台上 OneSignal 也能工作，但 `requestPermission` 行为不同
- 不要在 `AppDelegate.swift` 中做任何修改——OneSignal Flutter plugin 自动处理

---

## 执行报告

完成后，请将执行报告写入：
`/Users/george/smivo/.agent/tasks/push-notifications/T-002_report.md`

报告模板：

```markdown
# T-002 执行报告

## 完成状态: ✅ / ❌

## 修改文件清单
| 文件 | 操作 | 说明 |
|------|------|------|
| ... | 新建/修改 | ... |

## build_runner 输出
(粘贴关键输出行)

## flutter analyze 结果
(粘贴输出)

## 遇到的问题
(如有)
```
