# Smivo Bug Fix Report #020 (2026-04-23)

## 修复概述
本报告详细记录了针对 `debugging-report-2026-04-23.md` 中提出的 Bug #1、#3、#4、#5 的修复情况。Bug #2 已由 `task-020b` 独立处理。

## 详细修复记录

### 1. 租赁订单生命周期逻辑修复 (Bug #1 & #3)
- **修改文件**：`lib/data/repositories/order_repository.dart`, `lib/features/orders/providers/orders_provider.dart`
- **修复逻辑**：
    - 在 `confirmDelivery` 方法中增加了 `orderType` 区分。
    - **改进**：租赁（Rental）订单在双方确认后不再被错误地强制转为 `completed`，而是保持 `confirmed` 状态，由 Provider 推进至 `rental_status: active`。
    - 解决了租赁订单生命周期过早结束的严重 Bug。

### 2. 详情页 AppBar 重复按钮移除 (Bug #4)
- **修改文件**：`lib/features/listing/widgets/listing_image_carousel.dart`
- **修复逻辑**：
    - 删除了轮播组件内部自带的返回、分享和收藏按钮。
    - 统一使用详情页外层的固定悬浮按钮，解决了页面滚动时按钮重叠和 UI 冗余的问题。

### 3. 下单日期与时间精确化 (Bug #5)
- **修改文件**：`lib/features/listing/screens/listing_detail_screen.dart`
- **修复逻辑**：
    - 将 `submittedDate` 的格式从 `MMM d, yyyy` 更新为 `MMM d, yyyy · h:mm a`。
    - 增加了 `.toLocal()` 调用，确保时间以用户本地时区显示。

## 关联任务说明 (Bug #2)
- **Bug #2 (Storage Bucket missing)** 已被 `task-020b` (Storage Merge) 替代。
- 我们采用了更优的方案：将 `chat-images` 和 `order-evidence` 合并为统一的 `order-files` 存储桶。
- 已删除冗余的 `00021_chat_images_bucket.sql`，请使用 `00021_order_files_bucket.sql`。

## 验证结果
- **静态分析**：运行 `flutter analyze` 通过，无编译错误。
- **状态确认**：所有上述 Bug 修复已在当前代码库中生效。

## 待处理项 (Phase 2)
- Bug #6 (Listing Stats 0)：浏览量追踪与计数触发器。
- Bug #7 (Manage Transactions Empty)：RLS 权限深度调试。
