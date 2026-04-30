# 执行报告: P0-1 推送通知跳转优化

## 1. 修改文件清单

### ✅ 创建 SQL Migration
- **文件**: `supabase/migrations/00047_order_placed_listing_id.sql`
- **变更**: 重新定义了 `notify_order_placed()` 触发器函数。现在在创建 `order_placed` 通知时，会将 `action_url` 字段设为 `/listing/{listing_id}/transactions?tab=2`，并且 `action_type` 设为 `'route'`，以便 Flutter 客户端能够直接路由到商品交易管理的 Offers 标签页。同时保留了 `related_order_id` 字段。

### ✅ 修改 Flutter 客户端逻辑
- **文件**: `app/lib/core/providers/push_notification_provider.dart`
- **变更**: 更新了 `_onNotificationClicked` 方法，将 `actionUrl` 的检查提升为最高优先级。当存在 `actionUrl` 且不为空时，会直接执行 `router.push(actionUrl)`。这样不仅能够支持 `order_placed` 直接跳转到交易管理页，原本的深层链接跳转逻辑依然有效；其他无 `actionUrl` 且 `type` 为 `order_` 开头的通知仍然 fallback 到 `orderDetail` 页面。

### ✅ Edge Function 检查
- **文件**: `supabase/functions/push-notification/index.ts`
- **结果**: 确认已存在相关代码，会将 `action_url` 包含在 OneSignal payload 的 `data` 字段中正确传递给客户端，无需修改。

## 2. `flutter analyze` 结果
运行命令 `flutter analyze --no-fatal-infos` 的结果表示成功（共 25 个 issues 均是不影响逻辑的 info 级别的提示，无 Error 或 Warning）：

```text
Resolving dependencies... 
...
Got dependencies!
Analyzing app...                                                

   info • Statements in an if should be enclosed in a block • ... (多个文件提示)
   info • 'Share' is deprecated and shouldn't be used. Use SharePlus instead • ...
   
25 issues found. (ran in 2.5s)
```

## 3. 注意事项与后续步骤
- **手动执行 SQL**: 新创建的 migration 文件 `00047_order_placed_listing_id.sql` 必须在 Supabase 的 SQL Editor 面板中手动执行，或使用 CLI 工具 `supabase db push` 部署至云端，以便让该触发器的新逻辑在数据库中生效。
