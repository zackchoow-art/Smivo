# Task 012a Report: Seller Center Refactor

## 任务目标
重构卖家中心 (Seller Center) 的布局，从 3 个区域增加到 4 个区域，并实现历史记录的智能合并逻辑。

## 完成项

### 1. 区域重构
卖家中心现在被划分为 4 个清晰的区域：
- **ACTIVE LISTINGS**: 用户当前正在售卖/出租的活跃物品（状态为 `active`）。
- **AWAITING DELIVERY (新)**: 已接受（confirmed）但尚未完成交付确认的订单。
  - 销售订单显示 "Awaiting Pickup"。
  - 租赁订单显示 "Awaiting Delivery"。
- **ACTIVE TRANSACTIONS**: 已经完成交付确认、正在进行的租赁订单（rental_status 为 `active`, `return_requested`, 或 `returned`）。
- **HISTORY**: 已完成或已取消的订单，以及已下架的物品。

### 2. 历史记录智能合并逻辑 (Smart Merge)
为了保持历史界面的整洁，实现了以下逻辑：
- **单独显示**: 已完成 (Completed) 的订单和已下架 (Delisted) 的物品。
- **智能合并**: 如果一个 Listing 下有多个已取消 (Cancelled) 的订单，且该 Listing 没有活跃或已完成的订单，则将其合并为一张卡片。
  - 卡片显示：“X offer(s) cancelled”。
  - 点击卡片会弹出对话框，显示该物品的统计数据（浏览量、收藏量、报价量）。
- **智能隐藏**: 如果一个 Listing 已有成功的交易（confirmed 或 completed），则隐藏其名下所有已取消的订单，直到交易完全结束。

### 3. UI 与代码质量
- **样式规范**: 完全遵循 `SmivoThemeExtension` 令牌，使用语义化颜色（primary, success, warning, error, outlineVariant）。
- **图标更新**: 
  - 合并取消项使用 `Icons.playlist_remove` 图标，背景为警告色 (warning)。
  - 已完成项使用 `Icons.check_circle` (success)。
  - 已下架项使用 `Icons.remove_circle` (onSurface)。
- **静态分析**: 运行 `flutter analyze` 确认 **零 Error / 零 Warning**。

## 变更文件
- `lib/features/seller/screens/seller_center_screen.dart`: 重构了核心 build 逻辑，新增了 Awaiting Delivery 过滤，实现了 History 合并算法。
