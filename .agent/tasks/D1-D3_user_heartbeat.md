# D1-D3: 用户在线状态（App 端）

> 执行 Agent: Gemini 3.1 Pro
> 优先级: P1
> 预计修改/创建文件数: 8-10

---

## 整体功能

App 前台运行时每 5 分钟向服务器上报心跳，
在用户信息展示区域（如卖家卡片）显示「X 分钟前在线」。

---

## 执行边界（严格遵守）

### ✅ 允许创建/修改的文件
**数据库:**
- `supabase/migrations/00051_user_heartbeat.sql`

**Provider（新建）:**
- `app/lib/core/providers/heartbeat_provider.dart`

**Widgets（新建）:**
- `app/lib/shared/widgets/last_active_badge.dart`

**修改:**
- `app/lib/core/constants/app_constants.dart` — 增加心跳表名常量
- `app/lib/data/repositories/profile_repository.dart` — 增加心跳上报和查询方法
- `app/lib/app.dart`（或 main.dart 中 ProviderScope 的位置）— 初始化心跳监听
- `app/lib/features/listing/screens/listing_detail_screen.dart` — 卖家卡片显示「X 分钟前在线」
  **注意：** 只在卖家卡片区域增加一行 LastActiveBadge，不要改动其他 UI

### ❌ 禁止修改的文件
- 任何 admin 相关文件
- chat/orders 相关文件
- 任何已有 model 的 `.freezed.dart` 或 `.g.dart` 文件（不要删除）
- `pubspec.yaml`（不需要新依赖）
- `user_profile.dart` model — 上一个任务（B1-B7）已经加了 `last_active_at` 字段

---

## 子任务 D1: 数据库表

创建 `supabase/migrations/00051_user_heartbeat.sql`:

```sql
-- Migration 00051: User heartbeat for online status tracking
-- App sends heartbeat every 5 minutes while in foreground.
-- Used to show "X minutes ago" on user profiles.
-- Time bucket aggregation for DAU/WAU/MAU will be Phase 2 (Admin).

-- ═══════════════════════════════════════════════════════
-- 1. Heartbeat table (lightweight, one row per user updated in-place)
-- ═══════════════════════════════════════════════════════
-- NOTE: We use UPSERT (ON CONFLICT UPDATE) pattern instead of INSERT.
-- This keeps the table small (one row per user) rather than growing unbounded.

CREATE TABLE IF NOT EXISTS public.user_heartbeats (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    last_seen_at timestamptz NOT NULL DEFAULT now(),
    -- App version and platform for analytics
    app_version text,
    platform text, -- 'ios', 'android', 'web'
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.user_heartbeats ENABLE ROW LEVEL SECURITY;

-- Any authenticated user can read heartbeats (needed to show "X min ago")
CREATE POLICY "Authenticated users can read heartbeats"
    ON public.user_heartbeats FOR SELECT
    TO authenticated
    USING (true);

-- Users can upsert their own heartbeat
CREATE POLICY "Users can upsert own heartbeat"
    ON public.user_heartbeats FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own heartbeat"
    ON public.user_heartbeats FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- ═══════════════════════════════════════════════════════
-- 2. Also update last_active_at on user_profiles when heartbeat is sent
-- ═══════════════════════════════════════════════════════
-- This is a convenience column for quick lookups without joining heartbeats.
-- NOTE: last_active_at column is added by migration 00050.

CREATE OR REPLACE FUNCTION public.update_last_active()
RETURNS trigger AS $$
BEGIN
    UPDATE public.user_profiles
    SET last_active_at = NEW.last_seen_at,
        updated_at = now()
    WHERE id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_heartbeat_update_profile
    AFTER INSERT OR UPDATE ON public.user_heartbeats
    FOR EACH ROW
    EXECUTE FUNCTION public.update_last_active();
```

**执行 SQL:**
```bash
./supabase/scripts/run_migration.sh supabase/migrations/00051_user_heartbeat.sql
```

---

## 子任务 D2: App 心跳上报

### 1. 常量 `app/lib/core/constants/app_constants.dart`

添加：
```dart
static const String tableUserHeartbeats = 'user_heartbeats';
```

### 2. Repository 方法（修改 `profile_repository.dart`）

添加方法：
```dart
/// Upserts heartbeat for online status tracking.
/// Uses ON CONFLICT to keep the table at one row per user.
Future<void> sendHeartbeat({
  required String userId,
  String? appVersion,
  String? platform,
}) async {
  await _client.from('user_heartbeats').upsert({
    'user_id': userId,
    'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    'app_version': appVersion,
    'platform': platform,
    'updated_at': DateTime.now().toUtc().toIso8601String(),
  }, onConflict: 'user_id');
}

/// Fetches last_active_at for a specific user.
Future<DateTime?> getLastActiveAt(String userId) async {
  final data = await _client
      .from('user_heartbeats')
      .select('last_seen_at')
      .eq('user_id', userId)
      .maybeSingle();
  if (data == null) return null;
  return DateTime.tryParse(data['last_seen_at'] as String);
}
```

### 3. Provider `app/lib/core/providers/heartbeat_provider.dart`

```dart
/// Sends heartbeat every 5 minutes while the app is in foreground.
/// keepAlive: true — lives for the entire app session.
///
/// Uses AppLifecycleListener (Flutter 3.13+) to pause heartbeat
/// when app goes to background and resume when returning.
@Riverpod(keepAlive: true)
class HeartbeatManager extends _$HeartbeatManager {
  Timer? _timer;

  @override
  void build() {
    // Start heartbeat on build
    _startHeartbeat();

    // Listen to app lifecycle
    final listener = AppLifecycleListener(
      onResume: _startHeartbeat,
      onPause: _stopHeartbeat,
      onDetach: _stopHeartbeat,
    );

    ref.onDispose(() {
      _stopHeartbeat();
      listener.dispose();
    });
  }

  void _startHeartbeat() {
    // Send immediately, then every 5 minutes
    _sendHeartbeat();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _sendHeartbeat());
  }

  void _stopHeartbeat() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendHeartbeat() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    try {
      await ref.read(profileRepositoryProvider).sendHeartbeat(
        userId: user.id,
        platform: _getPlatform(),
      );
    } catch (_) {
      // Heartbeat failure is non-critical — silently ignore
    }
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }
}
```

**需要 import:**
```dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show AppLifecycleListener;
```

### 4. 初始化心跳

在 `app.dart` 的 build 方法中（或在 HomeScreen 等需要登录后才显示的页面中），
添加 `ref.watch(heartbeatManagerProvider);` 来初始化心跳。

**关键：** 只在用户已登录时激活。建议在 homeScreen build() 中 watch。

---

## 子任务 D3: 显示「X 分钟前在线」

### Widget: `app/lib/shared/widgets/last_active_badge.dart`

```dart
/// Displays "X minutes ago" badge for a user's last active time.
///
/// Shows:
/// - "Online" (green dot) if within 10 minutes
/// - "5m ago", "2h ago", "3d ago" using timeago package
/// - Nothing if lastActiveAt is null (user never sent heartbeat)
class LastActiveBadge extends StatelessWidget {
  final DateTime? lastActiveAt;

  const LastActiveBadge({super.key, this.lastActiveAt});

  @override
  Widget build(BuildContext context) {
    if (lastActiveAt == null) return const SizedBox.shrink();

    final now = DateTime.now().toUtc();
    final diff = now.difference(lastActiveAt!);

    final isOnline = diff.inMinutes <= 10;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isOnline ? 'Online' : timeago.format(lastActiveAt!),
          style: context.smivoTypo.caption.copyWith(
            color: isOnline ? Colors.green : context.smivoColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
```

### 集成到 listing_detail_screen.dart

在卖家信息卡片中（显示卖家头像、名字、邮箱的位置），在邮箱下方添加：

```dart
LastActiveBadge(lastActiveAt: sellerProfile.lastActiveAt),
```

**注意：**
- `sellerProfile` 已经在 listing detail 中可用
- `lastActiveAt` 字段已在 user_profile.dart model 中（B1-B7 任务添加）
- 如果 B1-B7 尚未执行，先跳过这一步，只完成心跳上报部分

---

## 代码生成与验证

1. 运行 SQL migration：
   ```bash
   ./supabase/scripts/run_migration.sh supabase/migrations/00051_user_heartbeat.sql
   ```

2. 运行代码生成（仅为新增 provider 生成）：
   ```bash
   cd app && dart run build_runner build --build-filter="lib/core/providers/heartbeat_provider.g.dart" --delete-conflicting-outputs
   ```
   ⚠️ **不要使用不带 --build-filter 的全局 build_runner**

3. 代码检查：
   ```bash
   cd app && flutter analyze --no-fatal-infos
   ```

4. 写入报告到 `.agent/tasks/D1-D3_report.md`

## ⚠️ 关键注意事项
- **不要删除任何已有的 .g.dart 或 .freezed.dart 文件**
- **不要修改 pubspec.yaml**（timeago 已在依赖中）
- **不要修改 user_profile.dart model**（last_active_at 由 B1-B7 任务添加）
- **如果 B1-B7 尚未执行**，则不要在 listing_detail 中集成 LastActiveBadge
- build_runner 必须使用 `--build-filter` 参数
- 心跳失败必须静默忽略，不能影响用户体验
- kIsWeb / Platform.isIOS 的判断需要放在 heartbeat_provider 中，不放在 widget 里
