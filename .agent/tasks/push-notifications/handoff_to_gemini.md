# 消息推送系统 — 完整技术交接文档

> 本文档由 Antigravity (Gemini 2.5 Pro) 编写，交接给 Gemini 3.1 Pro High 执行后续改进。
> 日期: 2026-04-28

---

## 一、项目背景

Smivo 是一个大学校园二手交易平台 (Flutter + Supabase)。本次任务是推送通知系统的后续完善。
基础设施已搭建完成，但存在若干 Gap 需要修复。

### 项目规则 (MUST READ)

在开始任何修改前，请务必阅读以下规则文件：
- **架构规则**: 项目根目录下无独立文件，请遵循 `lib/` 下的目录结构
- **代码风格**: 所有 Dart 文件使用 2 空格缩进，注释用英文，所有回复用中文
- **依赖注入**: 所有依赖通过 Riverpod 注入，Repository 是唯一与 Supabase 交互的层
- **屏幕→Provider→Repository→Supabase**: 这是唯一允许的依赖方向

---

## 二、当前数据结构

### 2.1 `notifications` 表 (PostgreSQL)

```sql
-- 位于 supabase/migrations/00008_notifications.sql (初始) + 后续迁移修改
CREATE TABLE public.notifications (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type             text NOT NULL,  -- 见下方约束
  title            text NOT NULL,
  body             text NOT NULL,
  related_order_id uuid REFERENCES public.orders(id) ON DELETE SET NULL,
  is_read          boolean NOT NULL DEFAULT false,
  action_type      text NOT NULL DEFAULT 'none'
                     CHECK (action_type IN ('none', 'order', 'url', 'route')),
  action_url       text,
  email_queued     boolean NOT NULL DEFAULT false,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

-- 类型约束 (来自 00028_rental_reminders.sql):
ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check CHECK (
    type = ANY (ARRAY[
      'order_placed', 'order_accepted', 'order_cancelled',
      'order_delivered', 'order_completed',
      'rental_reminder', 'rental_extension',
      'system'
    ])
  );
```

**注意**: 如果要新增 `new_message` 类型，需要 ALTER 这个 CHECK CONSTRAINT。

### 2.2 `user_profiles` 表 — 推送相关字段

```sql
-- 位于 supabase/migrations/00042_push_notification_fields.sql
ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS onesignal_player_id text,
  ADD COLUMN IF NOT EXISTS push_notifications_enabled boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS push_messages boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS push_order_updates boolean NOT NULL DEFAULT true;

-- 另有 email 偏好 (来自 00029):
-- email_notifications_enabled boolean NOT NULL DEFAULT true
```

### 2.3 `messages` 表 (聊天消息)

```sql
-- 位于 supabase/migrations/00005_chat.sql (初始)
CREATE TABLE public.messages (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id      uuid NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  sender_id    uuid NOT NULL REFERENCES auth.users(id),
  content      text,
  image_url    text,
  is_read      boolean NOT NULL DEFAULT false,
  created_at   timestamptz NOT NULL DEFAULT now()
);
```

### 2.4 `chat_rooms` 表

```sql
CREATE TABLE public.chat_rooms (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id   uuid NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  buyer_id     uuid NOT NULL REFERENCES auth.users(id),
  seller_id    uuid NOT NULL REFERENCES auth.users(id),
  last_message text,
  last_message_at timestamptz,
  -- ... 其他字段
);
```

### 2.5 `orders` 表 — 租期提醒相关字段

```sql
-- 来自 00028_rental_reminders.sql
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS reminder_days_before integer DEFAULT 1,
  ADD COLUMN IF NOT EXISTS reminder_email boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS reminder_sent boolean DEFAULT false;
```

---

## 三、当前实现路径

### 3.1 通知生成链路 (DB Triggers)

所有通知由 PostgreSQL 数据库触发器自动创建，INSERT 到 `notifications` 表。

**已存在的 Trigger 函数:**

| 函数名 | 触发表 | 触发事件 | 生成的通知类型 | 最终版本文件 |
|--------|--------|---------|-------------|------------|
| `notify_order_placed()` | `orders` | INSERT | `order_placed` → 发给卖家 | `00022_notification_action_type.sql` |
| `notify_order_status_change()` | `orders` | UPDATE of status | `order_accepted` → 买家<br>`order_cancelled` → 双方/失败买家<br>`order_completed` → 双方 | `00029_email_notifications.sql` |
| `notify_delivery_confirmed()` | `orders` | UPDATE of delivery flags | `order_delivered` → 对方 | `00022_notification_action_type.sql` |
| `notify_rental_extension()` | `rental_extensions` | INSERT / UPDATE of status | `rental_extension` → 卖家(请求) / 买家(审批) | `00029_email_notifications.sql` |
| `check_rental_reminders()` | 手动/pg_cron调用 | — | `rental_reminder` → 买家 | `00029_email_notifications.sql` |

**重要**: 这些函数被多次 `CREATE OR REPLACE`，以下是每个函数的**最终版本所在文件**:
- `notify_order_placed()` → `00022` (未在 00029 中重写)
- `notify_order_status_change()` → `00029` (最终版)
- `notify_delivery_confirmed()` → `00022` (未在后续重写)
- `notify_rental_extension()` → `00029` (最终版)
- `check_rental_reminders()` → `00029` (最终版)

### 3.2 Push 推送链路

```
notifications 表 INSERT
  → Database Webhook (Supabase Dashboard 已配置)
  → Edge Function: supabase/functions/push-notification/index.ts
  → 查询 user_profiles 获取 onesignal_player_id + 偏好
  → 根据偏好决定是否发送
  → 调用 OneSignal REST API POST https://api.onesignal.com/notifications
  → OneSignal → APNs/FCM → 用户设备
```

**Edge Function 文件**: `supabase/functions/push-notification/index.ts` (111行)

**Edge Function 偏好判断逻辑** (第48-73行):
```
1. push_notifications_enabled == false → 跳过所有推送
2. type ∈ [order_placed, order_accepted, order_cancelled, order_delivered, order_completed]
   && push_order_updates == false → 跳过
3. type == 'new_message' && push_messages == false → 跳过
4. onesignal_player_id 为空 → 跳过
5. 其他类型 (rental_reminder, rental_extension, system) → 只要总开关开就推送
```

**OneSignal Payload 结构** (第77-86行):
```json
{
  "app_id": "env.ONESIGNAL_APP_ID",
  "include_subscription_ids": ["player_id_from_db"],
  "headings": { "en": "notification.title" },
  "contents": { "en": "notification.body" },
  "data": {
    "type": "order_placed",
    "order_id": "uuid-or-undefined"
  }
}
```

### 3.3 Flutter App 端

**OneSignal 初始化**: `lib/main.dart` (第27-31行)
```dart
final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';
if (oneSignalAppId.isNotEmpty) {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(oneSignalAppId);
}
```

**Push Provider**: `lib/core/providers/push_notification_provider.dart` (69行)
- 监听 `authStateProvider`，登录时:
  - `OneSignal.login(user.id)` 关联身份
  - 请求推送权限 (iOS native dialog)
  - 存储 `pushSubscription.id` 到 DB 的 `onesignal_player_id`
- 登出时: `OneSignal.logout()`
- 点击处理: `_onNotificationClicked` — **当前只打印 debugPrint，不跳转**

**In-App 通知**: `lib/features/notifications/providers/notification_provider.dart`
- 通过 Supabase Realtime 监听 `notifications` 表变化
- 通知中心页面: `lib/features/notifications/screens/notification_center_screen.dart`
- 点击处理 `_handleTap` (第253-270行): 根据 `action_type` 导航:
  - `'order'` → `context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': orderId})`
  - `'url'` → `launchUrl()`
  - `'route'` → `context.push(actionUrl)`
  - `'none'` → 无操作

### 3.4 Settings 页通知开关

**Provider 文件**: `lib/features/settings/providers/settings_provider.dart` (145行)

| Provider | 持久化 | DB 字段 |
|----------|--------|--------|
| `PushNotificationsState` | ✅ DB | `push_notifications_enabled` |
| `PushMessagesNotifState` | ✅ DB | `push_messages` |
| `PushOrderUpdatesNotifState` | ✅ DB | `push_order_updates` |
| `EmailNotificationsState` | ✅ DB | `email_notifications_enabled` |
| `PriceAlertsNotifState` | ❌ 内存 | 无 |
| `CampusAnnouncementsNotifState` | ❌ 内存 | 无 |
| `WeeklyEmailDigestNotifState` | ❌ 内存 | 无 |

**UI 文件**: `lib/features/settings/screens/notification_settings_screen.dart` (206行)
- `_loadPrefs()` 方法在 initState 中从 profile 加载初始值
- 每个持久化 toggle 的 `onChanged` 调用 provider 的 `toggle()` 方法，传入 `userId`、`profileRepo` 和兄弟状态

**ProfileRepository 相关方法**: `lib/data/repositories/profile_repository.dart`
- `updatePushToken({userId, playerId})` → 更新 `onesignal_player_id`
- `updatePushPreferences({userId, pushEnabled, pushMessages, pushOrderUpdates})` → 更新 3 个推送偏好字段
- `updateEmailNotificationPref({userId, enabled})` → 更新 email 偏好

---

## 四、已识别的 Gap 与改进任务

### 🔴 Gap 1: 聊天消息无系统推送 (高优先级)

**问题**: 用户收到新聊天消息时，只有 App 内 Realtime 更新，没有 iPhone/Android 系统推送。

**原因**: `messages` 表 INSERT 时没有 trigger 创建 `new_message` 类型的 notification 记录。

**修复步骤**:

1. **新建 SQL Migration** (如 `00043_new_message_notification.sql`):
   ```sql
   -- 1. 更新 notifications.type 约束，新增 'new_message'
   ALTER TABLE public.notifications
     DROP CONSTRAINT IF EXISTS notifications_type_check;
   ALTER TABLE public.notifications
     ADD CONSTRAINT notifications_type_check CHECK (
       type = ANY (ARRAY[
         'order_placed', 'order_accepted', 'order_cancelled',
         'order_delivered', 'order_completed',
         'rental_reminder', 'rental_extension',
         'new_message', 'system'
       ])
     );

   -- 2. 创建触发函数
   CREATE OR REPLACE FUNCTION public.notify_new_message()
   RETURNS trigger
   LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = ''
   AS $$
   DECLARE
     v_room RECORD;
     v_recipient_id uuid;
     v_sender_name text;
     v_listing_title text;
     v_related_order_id uuid;
     v_email_enabled boolean;
   BEGIN
     -- 获取聊天室信息
     SELECT cr.buyer_id, cr.seller_id, cr.listing_id
     INTO v_room
     FROM public.chat_rooms cr
     WHERE cr.id = NEW.room_id;

     -- 确定接收方 (对方)
     IF NEW.sender_id = v_room.buyer_id THEN
       v_recipient_id := v_room.seller_id;
     ELSE
       v_recipient_id := v_room.buyer_id;
     END IF;

     -- 获取发送者名称
     SELECT coalesce(display_name, 'Someone') INTO v_sender_name
     FROM public.user_profiles WHERE id = NEW.sender_id;

     -- 获取商品标题
     SELECT coalesce(title, 'an item') INTO v_listing_title
     FROM public.listings WHERE id = v_room.listing_id;

     -- 查找关联订单 (可选，用于点击跳转)
     SELECT id INTO v_related_order_id
     FROM public.orders
     WHERE listing_id = v_room.listing_id
       AND ((buyer_id = v_room.buyer_id AND seller_id = v_room.seller_id)
         OR (buyer_id = v_room.seller_id AND seller_id = v_room.buyer_id))
     ORDER BY created_at DESC
     LIMIT 1;

     -- 检查 email 偏好
     SELECT coalesce(email_notifications_enabled, true)
     INTO v_email_enabled
     FROM public.user_profiles WHERE id = v_recipient_id;

     -- 创建通知
     INSERT INTO public.notifications
       (user_id, type, title, body, related_order_id, action_type, action_url, email_queued)
     VALUES (
       v_recipient_id,
       'new_message',
       'New message from ' || v_sender_name,
       CASE
         WHEN NEW.image_url IS NOT NULL THEN v_sender_name || ' sent a photo for "' || v_listing_title || '"'
         ELSE coalesce(left(NEW.content, 100), 'New message') || ' — "' || v_listing_title || '"'
       END,
       v_related_order_id,
       'route',                              -- 使用 route action_type
       '/chat/' || NEW.room_id::text,        -- 跳转到聊天室
       coalesce(v_email_enabled, true)
     );

     RETURN NEW;
   END;
   $$;

   -- 3. 绑定触发器
   CREATE TRIGGER on_new_message_notify
     AFTER INSERT ON public.messages
     FOR EACH ROW EXECUTE FUNCTION public.notify_new_message();
   ```

2. **注意事项**:
   - 需要防止用户正在查看该聊天室时产生推送（可在 Edge Function 或 trigger 中处理）
   - `action_type` 建议用 `'route'`，`action_url` 设为 `/chat/{room_id}`
   - 需要确认 GoRouter 中 chatRoom 路由的 path 格式，查看 `lib/core/router/router.dart`

3. **在 Supabase Dashboard 中手动执行 SQL**

### 🔴 Gap 2: Push 推送点击后无页面跳转 (高优先级)

**问题**: 用户点击 iPhone 推送通知后，App 打开但停留在当前页面，不跳转到对应订单/聊天。

**修复文件**: `lib/core/providers/push_notification_provider.dart`

**修复方案**: 在 `_onNotificationClicked` 中解析 OneSignal 的 `additionalData`，使用 GoRouter 导航。

```dart
void _onNotificationClicked(OSNotificationClickEvent event) {
  final data = event.notification.additionalData;
  if (data == null) return;

  final type = data['type'] as String?;
  final orderId = data['order_id'] as String?;

  // 需要获取 GoRouter 实例进行导航
  // 方案1: 通过 ref.read(routerProvider) 如果有暴露 GoRouter 的 provider
  // 方案2: 使用 GlobalKey<NavigatorState> 或 rootNavigatorKey
  // 具体取决于 lib/core/router/router.dart 的实现方式

  if (type != null && type.startsWith('order_') && orderId != null) {
    // 导航到 Order Detail
    router.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': orderId});
  } else if (type == 'new_message') {
    final roomId = data['room_id'] as String?;
    if (roomId != null) {
      // 导航到 Chat Room
      // 需要确认 chatRoom 路由参数格式
    }
  }
}
```

**注意**: 需要先查看 `lib/core/router/router.dart` 确认:
1. GoRouter 实例是否通过 Riverpod Provider 暴露
2. 是否有 `navigatorKey` 可以在 Provider 中使用
3. chatRoom 路由的参数格式 (path parameter vs query parameter)

**额外**: 如果实现了 Gap 1 的 `new_message` 推送，Edge Function 的 payload `data` 中需要额外传递 `room_id`。需要修改 `supabase/functions/push-notification/index.ts` 的 payload 构建逻辑，增加对 `action_url` 字段的解析。

### 🟡 Gap 3: 租期提醒 pg_cron 未配置 (中优先级)

**问题**: `check_rental_reminders()` 函数已创建但没有定时调用。

**修复**: 在 Supabase Dashboard → SQL Editor 中执行:
```sql
-- 需要先启用 pg_cron 扩展 (Supabase Dashboard → Database → Extensions → 搜索 pg_cron → Enable)
SELECT cron.schedule(
  'check-rental-reminders',
  '0 8 * * *',  -- 每天早上 8:00 UTC
  $$SELECT public.check_rental_reminders()$$
);
```

这是纯 SQL 操作，不需要修改 Flutter 代码。

### 🟢 Gap 4-7 (低优先级，Phase 2)

以下是 Settings 页上存在但无后端功能的开关，暂不需要修改:
- **Price Alerts**: 需要 watchlist + 价格追踪机制
- **Campus Announcements**: 需要管理员广播系统
- **Weekly Email Digest**: 需要定时任务 + 邮件模板
- **Email 发送服务**: `email_queued` 标记已就位但无消费端

---

## 五、关键文件索引

### Supabase / 后端

| 文件 | 内容 |
|------|------|
| `supabase/functions/push-notification/index.ts` | Edge Function — 推送决策逻辑 |
| `supabase/migrations/00008_notifications.sql` | notifications 表初始创建 |
| `supabase/migrations/00022_notification_action_type.sql` | 添加 action_type 字段 + 重写部分 triggers |
| `supabase/migrations/00024_missed_order_notification.sql` | 竞争失败通知逻辑 |
| `supabase/migrations/00027_rental_extensions.sql` | rental_extensions 表 + 通知 |
| `supabase/migrations/00028_rental_reminders.sql` | 租期提醒系统 |
| `supabase/migrations/00029_email_notifications.sql` | Email 偏好 + 所有 trigger 最终版 |
| `supabase/migrations/00042_push_notification_fields.sql` | push 偏好字段 |

### Flutter / 前端

| 文件 | 内容 |
|------|------|
| `lib/main.dart` | OneSignal SDK 初始化 |
| `lib/app.dart` | watch pushNotificationManagerProvider (第20行) |
| `lib/core/providers/push_notification_provider.dart` | OneSignal 生命周期管理 |
| `lib/core/router/router.dart` | GoRouter 配置 (导航跳转需要参考) |
| `lib/core/router/app_routes.dart` | 路由名称常量 |
| `lib/data/models/notification.dart` | AppNotification freezed 模型 |
| `lib/data/models/user_profile.dart` | UserProfile freezed 模型 (含推送字段) |
| `lib/data/repositories/profile_repository.dart` | updatePushToken + updatePushPreferences |
| `lib/data/repositories/notification_repository.dart` | 通知 CRUD 操作 |
| `lib/features/notifications/providers/notification_provider.dart` | 通知列表 state + Realtime 监听 |
| `lib/features/notifications/screens/notification_center_screen.dart` | 通知中心 UI + 点击跳转逻辑 |
| `lib/features/notifications/widgets/notification_list_item.dart` | 单条通知 UI |
| `lib/features/settings/providers/settings_provider.dart` | 通知开关 state |
| `lib/features/settings/screens/notification_settings_screen.dart` | 设置页 UI |

### iOS 原生

| 文件 | 内容 |
|------|------|
| `ios/Runner/Runner.entitlements` | aps-environment = development |
| `ios/Runner/Info.plist` | UIBackgroundModes → remote-notification |

### 环境配置

| 文件 / 位置 | 内容 |
|------------|------|
| `assets/env` | `ONESIGNAL_APP_ID=e6cea15a-5496-48b4-81da-fe7409bb4799` |
| Supabase Edge Function Secrets | `ONESIGNAL_APP_ID` + `ONESIGNAL_REST_API_KEY` |
| Supabase Database Webhook | `notifications` 表 INSERT → `push-notification` Edge Function |

---

## 六、执行边界

### 允许修改的文件
- `supabase/migrations/` 下新建迁移文件
- `supabase/functions/push-notification/index.ts` (如需扩展 payload)
- `lib/core/providers/push_notification_provider.dart` (点击跳转)
- `lib/data/models/notification.dart` (如需新增字段)

### 禁止修改的文件
- `lib/main.dart` (除非有充分理由)
- `lib/app.dart`
- `lib/data/repositories/profile_repository.dart`
- `lib/features/settings/` (Settings 页已完成)
- `ios/` 原生配置文件
- 已有的 migration 文件 (只能新建，不能改旧的)

### 执行完成后
1. 运行 `dart run build_runner build --delete-conflicting-outputs`
2. 运行 `flutter analyze --no-fatal-infos` 确保 0 errors
3. 将新建的 SQL migration 文件路径告知用户，需要用户手动在 Supabase Dashboard 执行
4. 将执行报告写入 `/Users/george/smivo/.agent/tasks/push-notifications/improvement_report.md`
