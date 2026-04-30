# P0-1: 推送通知跳转优化 — order_placed 打开 Manage Transactions

## 目标
当卖家收到 `order_placed` 推送通知并点击时，跳转到该商品的 **Transaction Management** 页面的 **Offers 标签**（tab=2），而非当前的 Order Detail 页面。

## 背景
- 当前逻辑（`push_notification_provider.dart` 第 61-62 行）：所有 `order_*` 类型通知都跳转到 `orderDetail` 页面
- 期望行为：`order_placed` 应跳转到 `transactionManagement` 页面（卖家在这里 Accept/Reject offers）
- Transaction Management 路由：`/listing/:id/transactions?tab=2`，需要 `listing_id`（非 `order_id`）
- **问题**：当前 DB trigger 只传递 `related_order_id`，不传递 `listing_id`

## 执行边界

### ✅ 允许修改的文件：
1. `app/lib/core/providers/push_notification_provider.dart` — 修改 `_onNotificationClicked` 跳转逻辑
2. `supabase/functions/push-notification/index.ts` — 在 push payload 的 data 中增加 `listing_id`
3. `supabase/migrations/00047_order_placed_listing_id.sql` — （新建）修改 `notify_order_placed()` 触发器，在通知记录中携带 `listing_id`（存入 `action_url` 字段）

### ❌ 禁止修改的文件：
- 路由文件 (`router.dart`, `app_routes.dart`)
- 任何 Screen 文件
- 任何 Model 文件
- 任何其他 Provider 文件
- iOS/Android 配置文件

## 实施方案

### 步骤 1：修改 DB Trigger — `notify_order_placed()`
在 `supabase/migrations/` 下新建 `00047_order_placed_listing_id.sql`，重新定义 `notify_order_placed()` 函数：
- 在 INSERT 时设置 `action_url` 为 `/listing/{listing_id}/transactions?tab=2`
- 保持 `related_order_id` 不变（不删除，其他通知仍需要它）
- `action_type` 设为 `'route'`

```sql
CREATE OR REPLACE FUNCTION public.notify_order_placed()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
BEGIN
  SELECT title INTO v_listing_title
  FROM public.listings
  WHERE id = NEW.listing_id;

  INSERT INTO public.notifications
    (user_id, type, title, body, related_order_id, action_type, action_url)
  VALUES (
    NEW.seller_id,
    'order_placed',
    'New order received',
    'Someone placed an order for "' || coalesce(v_listing_title, 'your listing') || '"',
    NEW.id,
    'route',
    '/listing/' || NEW.listing_id::text || '/transactions?tab=2'
  );
  RETURN NEW;
END;
$$;
```

### 步骤 2：修改 Edge Function — 确保 `listing_id` 传入 push data
文件：`supabase/functions/push-notification/index.ts`

当 `action_url` 存在时，已经会传入 OneSignal payload（已有逻辑），无需修改 Edge Function。
确认 Edge Function 的 data 中包含：`action_url`。如果已经包含则跳过此步。

### 步骤 3：修改 Flutter 端 — `_onNotificationClicked`
文件：`app/lib/core/providers/push_notification_provider.dart`

修改 `_onNotificationClicked` 方法的逻辑：

```dart
void _onNotificationClicked(OSNotificationClickEvent event) {
  debugPrint('Notification clicked: ${event.notification.title}');
  final data = event.notification.additionalData;
  if (data == null) return;

  final type = data['type'] as String?;
  final orderId = data['order_id'] as String?;
  final actionUrl = data['action_url'] as String?;

  final router = ref.read(routerProvider);

  // order_placed has a special route: Transaction Management Offers tab
  // Other order notifications still go to order detail
  if (actionUrl != null && actionUrl.isNotEmpty) {
    router.push(actionUrl);
  } else if (type != null && type.startsWith('order_') && orderId != null) {
    router.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': orderId});
  }
}
```

关键变更：**把 `actionUrl` 检查提升到最高优先级**，而不是只在 `order_` 条件不满足时才 fallback。这样 `order_placed` 因为有 `action_url = /listing/.../transactions?tab=2`，会直接走 `router.push(actionUrl)` 路径。其他 order 通知因为 `action_type = 'order'` 且没有 `action_url`，仍然走 `orderId` 逻辑。

## 验证步骤
1. 运行 `cd /Users/george/smivo/app && flutter analyze --no-fatal-infos`，确保 **0 errors, 0 warnings**
2. 确认 `push_notification_provider.dart` 中 `actionUrl` 检查在 `order_` 检查之前
3. 确认 SQL migration 文件语法正确
4. 确认 Edge Function 的 `index.ts` 无语法错误

## 执行报告
写入：`/Users/george/smivo/.agent/tasks/P0-1_report.md`

报告需包含：
1. 修改了哪些文件及具体变更
2. `flutter analyze` 输出结果
3. 注意事项（如 SQL 需手动在 Supabase Dashboard 执行）
