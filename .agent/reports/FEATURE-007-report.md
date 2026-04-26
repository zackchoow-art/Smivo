# 任务执行报告：UI与通知状态体验优化

## 任务背景
在本次任务中，我们解决并优化了两个关键的用户体验问题：
1. **排版截断问题**：Buyer Center 和 Seller Center 的 `Awaiting Delivery / Pickup` 标签，由于宽度固定导致长单词（如 `Awaiting`）在窄屏或特定字号渲染时被强制字内截断，严重影响美观。
2. **通知消退逻辑不合理**：应用内红点与徽章（Badge）的提醒机制存在局限，用户必须进入专门的 `Notifications` 页面点击通知才能将其标为已读，而在 Seller / Buyer Center 中直接点击带红点提示的订单卡片后，由于通知未被消解，导致红点和消息徽章依旧存在。

## 执行过程

### 1. 修复状态标签排版溢出（FittedBox + 硬换行）
*   **目标文件**：
    *   `lib/features/buyer/screens/buyer_center_screen.dart`
    *   `lib/features/seller/screens/seller_center_screen.dart`
*   **执行逻辑**：
    *   将原标签的 `Padding` 从 `horizontal: 10` 缩减到 `horizontal: 4`，释放最大可用宽度。
    *   将单行的文字强制修改为带物理换行符的两行结构：`'Awaiting\nPickup'` 和 `'Awaiting\nDelivery'`。
    *   在 `Text` 外部嵌套一层 `FittedBox(fit: BoxFit.scaleDown)`。
*   **达成效果**：确保在这 72px 宽度的容器内，单词强制分列两排显示，并且在极端情况下会自动等比缩小而不是暴力截断。

### 2. 实现“点击卡片消除未读红点”逻辑
*   **目标文件**：
    *   `lib/features/buyer/screens/buyer_center_screen.dart`
    *   `lib/features/seller/screens/seller_center_screen.dart`
*   **执行逻辑**：
    *   在两者的 `State` 组件内均添加了私有辅助方法 `_handleOrderTap`。
    *   在 `_handleOrderTap` 中，首先判断被点击的卡片是否有红点（`hasUnread`）。
    *   若有红点，读取 `notificationListProvider`，过滤出 `!isRead` 且 `relatedOrderId` 匹配的通知。
    *   遍历这些关联通知，逐一调用 `ref.read(notificationListProvider.notifier).markAsRead(n.id)` 同步云端与本地状态为已读。
    *   执行原定的页面路由跳转 `context.pushNamed(AppRoutes.orderDetail, ...)`。
    *   替换了原所有硬编码的 `onTap` 路由跳转为调用 `_handleOrderTap`。
*   **达成效果**：实现点击即已读，得益于 Riverpod 的响应式设计，所有相关的 UI 红点及底部导航徽章会立刻清空，体验极其流畅。

## 验证与状态
1. 涉及的所有修改已完成，并在开发环境中进行了可用性论证。
2. Flutter 分析未报告相关错误。
3. 代码现已提交至版本控制并推送到 GitHub 远程仓库。
