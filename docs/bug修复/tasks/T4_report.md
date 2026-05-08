# 任务报告：Transaction Management 页 Offers 卡片补充信息 (T4)

## 任务目标
在 Manage Transactions 页面的 Offers 卡片上添加显示购买时间/租期、交付地址以及学校名称。

## 修改内容
### 1. `app/lib/features/seller/screens/transaction_management_screen.dart`
- **新增 UI 模块**：在 Offers 卡片的买家信息下方新增了一个信息栏，通过 `Wrap` 布局展示以下三项信息：
    - **📅 购买时间 / 租期**：如果是租赁订单，显示租期（如 `05/08 - 05/15/2026`）；如果是购买订单，显示下单日期（如 `05/08/2026`）。
    - **📍 交付地址**：显示 `order.pickupLocationName`（如果存在）。
    - **🏫 学校**：显示 `order.school`。
- **UI 优化**：
    - 增加了 `Divider` 分隔符，使信息层次更清晰。
    - 使用了 `Icons` 图标（calendar, location, school）增强可读性。
    - 样式采用 `context.smivoTypo.bodySmall` 配合灰色文字，保持界面简洁且符合设计规范。
- **新增辅助方法**：在 `_OffersTab` 类中添加了私有方法 `_buildInfoItem` 用于统一渲染带图标的信息项。

## 数据来源说明
- **购买时间 / 租期**：直接使用 `order.createdAt` (Sale) 或 `order.rentalStartDate` / `order.rentalEndDate` (Rental)。这些字段在 `Order` 模型中已存在且已由后端返回。
- **交付地址**：使用 `order.pickupLocationName`。该字段在 `Order` 模型中已存在。
- **学校名称**：使用 `order.school` 字符串字段。

## 验证结果
- **代码完整性**：运行 `flutter analyze` 验证通过。
- **分析输出**：`No issues found!`。

## 截图效果预览（逻辑说明）
- 卡片现在在买家姓名/价格下方会显示：
  `📅 05/08/2026   📍 Smith Campus   🏫 Smith College`
- 如果是租赁且有具体日期：
  `📅 05/08 - 05/15/2026   📍 Smith Campus   🏫 Smith College`
