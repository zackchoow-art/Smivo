# 任务报告：修复 Sale 订单 UI 状态显示 (T1)

## 任务目标
解决 `listing_detail_screen.dart` 中 Sale 商品在已有订单时的 UI 不一致问题。当买家已提交订单时，应隐藏 "Request to Buy" 按钮，并显示包含订单状态、预定时间及取消按钮的状态卡片。

## 修改内容
### 1. `app/lib/features/listing/screens/listing_detail_screen.dart`
- **逻辑增强**：在 `existingOrder.when` 的 `data` 分支中，增加了对 Sale 订单的特殊处理。
- **状态卡片更新**：
    - 针对 Sale 订单，将标题改为 **"已预订"**（Pending 状态）。
    - 引入了动态的标题、图标和颜色逻辑，支持 `pending`, `confirmed`, `completed`, `cancelled`, `missed` 等多种状态。
    - **时间格式**：Sale 订单使用 `MM/dd/yyyy HH:mm` 格式，Rental 订单保持原有的 `MMM d, yyyy · h:mm a` 格式。
- **取消逻辑优化**：
    - 统一了取消按钮的显示逻辑：除了 `pending` 状态外，如果订单处于 `confirmed` 状态且双方均未确认送达/取货，也允许取消（参考了 `rental_order_detail_screen.dart` 的逻辑）。
    - 动态更新对话框标题和按钮文本（"Cancel Application" vs "Cancel Order"）。
- **UI 统一样式**：使用了 `context.smivoColors` 和 `context.smivoTypo` 确保与整体设计系统一致。

## 验证结果
- **代码完整性**：运行 `flutter analyze` 验证通过。虽然存在一些预现的 info/warning（如弃用成员、缺少花括号等），但本次修改范围（L942-L1150）内未引入任何新错误。
- **UI 逻辑**：
    - Sale + Pending -> 显示 "已预订" + 时间 (MM/dd/yyyy HH:mm) + 取消按钮。
    - Rent + Pending -> 显示 "Application Submitted" + 时间 + 取消按钮。
    - 订单取消逻辑已扩展至未确认送达的 `confirmed` 状态。

## 结论
任务已按要求完成，UI 表现现在与租赁订单详情页保持一致，且满足了 Sale 订单的特殊显示需求。
