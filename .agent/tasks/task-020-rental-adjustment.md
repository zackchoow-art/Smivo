# Task 020: 租期调整功能改进

## 分配给: Gemini 3.1 Pro High
## 复杂度: ⭐⭐⭐⭐⭐
## 依赖: T-019 已完成

## 背景
现有代码已有完整的数据库表 (`rental_extensions`)、Model (`RentalExtension`)、Repository (`RentalExtensionRepository`)、Provider (`RentalExtensionProvider`)、Widget (`RentalExtensionCard`)。

**问题**：当前 `RentalExtensionCard` 的买家交互使用 `showDatePicker` 让买家直接选日期。业务需求要求改为**按数量调整**（保持租赁方式不变，只改数量）。

## 重要规则
- **读完所有涉及文件后再修改**
- **不要修改数据库表结构**（`rental_extensions` 表和 trigger 已经完善）
- **不要修改 Order model**
- **主题 token 必须使用**: `context.smivoColors`, `context.smivoTypo`, `context.smivoRadius`
- 修改完成后运行 `flutter analyze`，必须零错误
- **修改完成后运行 `dart run build_runner build --delete-conflicting-outputs`** 如果修改了任何带 `@riverpod` 注解的代码

## 需要修改的文件

### 1. `lib/features/orders/widgets/rental_extension_card.dart` (340 行) — 重写

这是最主要的修改。**完全重写交互流程**。

#### 买家视角改进
当前行为：点击 Extend/Shorten → `showDatePicker` 选日期
改为：

1. 买家看到 "Adjust Rental Period" 按钮（仅 `rentalStatus == 'active'` 时显示）
2. 点击后显示内嵌（inline）调整区域（不用弹窗），包含：
   - 当前租赁方式标签（如 "Daily" / "Weekly" / "Monthly"，从订单推断）
   - **数量选择器**：`-` 按钮 / 数字 / `+` 按钮（初始值=当前数量）
   - 下方实时计算并显示：
     - 调整类型："Extension" 或 "Early Return"（根据数量增减自动判断）
     - 新结束日期
     - 调整天数（+N 或 -N）
     - 金额变化（+$X.XX 或 -$X.XX）
     - 新租金总计
   - "Submit Request" 按钮
3. 提交成功后：
   - 显示一个绿色对勾的 `SnackBar` 提示 "Request submitted successfully"
   - 收起调整区域
   - 刷新 extensions 列表

#### 推断租赁方式的逻辑
```dart
/// 从订单日期范围推断当前租赁方式和数量
({String rateType, int quantity, double unitPrice}) _inferRentalRate(Order order) {
  if (order.rentalStartDate == null || order.rentalEndDate == null) {
    return (rateType: 'daily', quantity: 1, unitPrice: order.listing?.rentalDailyPrice ?? 0);
  }
  final days = order.rentalEndDate!.difference(order.rentalStartDate!).inDays;
  final listing = order.listing;
  
  // Check monthly first (most coarse-grained)
  if (days >= 30 && days % 30 == 0 && (listing?.rentalMonthlyPrice ?? 0) > 0) {
    return (rateType: 'monthly', quantity: days ~/ 30, unitPrice: listing!.rentalMonthlyPrice!);
  }
  // Then weekly
  if (days >= 7 && days % 7 == 0 && (listing?.rentalWeeklyPrice ?? 0) > 0) {
    return (rateType: 'weekly', quantity: days ~/ 7, unitPrice: listing!.rentalWeeklyPrice!);
  }
  // Default to daily
  return (rateType: 'daily', quantity: days, unitPrice: listing?.rentalDailyPrice ?? 0);
}
```

#### 数量选择器逻辑
```dart
// 最小数量: 1（缩期不能缩到0或负数）
// 最大数量: 无上限（但可以设一个合理值如 365天 / 52周 / 12月）
// 新结束日期 = rentalStartDate + (newQuantity * daysPerUnit)
// priceDiff = (newQuantity - currentQuantity) * unitPrice
// newTotal = order.totalPrice + priceDiff
// requestType = newQuantity > currentQuantity ? 'extend' : 'shorten'
```

#### 卖家视角
保持现有逻辑（查看列表 + Approve/Reject），但改进显示内容：
- 每个 extension item 显示：
  - 提交时间（`ext.createdAt` 格式化）
  - 当前结束日期 → 新结束日期（用箭头显示）
  - 调整天数（+N 或 -N days）
  - 金额变化（+$X.XX 或 -$X.XX）
  - 新租金总计
  - 含押金的订单总额（`ext.newTotal + order.depositAmount`）
  - 状态 badge（Pending/Approved/Rejected）
  - Approve / Reject 按钮（仅 pending 状态）

#### 操作反馈
- Approve 成功：绿色对勾 SnackBar "Extension approved"
- Reject 成功：红色 SnackBar "Extension rejected"  
- 所有操作后自动刷新 extensions 列表 + order detail

### 2. 无需修改的文件
以下文件**不需要改动**（已经是完善的）：
- `rental_extension.dart` model — 字段完整
- `rental_extension_repository.dart` — CRUD 完整
- `rental_extension_provider.dart` — 三个 action 完整
- `00027_rental_extensions.sql` — 表+trigger+通知完整

### 3. `lib/features/orders/screens/rental_order_detail_screen.dart`
检查 `RentalExtensionCard` 的使用位置（约第 86-90 行），确保在 `rentalStatus == 'active'` 时显示。当前代码已经无条件显示它，需要加条件：
```dart
// 只在租赁进入 active 状态后显示调整卡片
if (order.rentalStatus != null) ...[
  RentalExtensionCard(
    order: order,
    isBuyer: isBuyer,
    isSeller: isSeller,
  ),
  const SizedBox(height: 16),
],
```

## OrderListingPreview Model 参考
`RentalExtensionCard` 通过 `order.listing` 访问价格信息。确保使用以下字段：
```dart
// lib/data/models/order_listing_preview.dart
double? rentalDailyPrice
double? rentalWeeklyPrice  
double? rentalMonthlyPrice
```

## Widget 设计参考

### 买家调整区域（inline，非弹窗）
```
╔══════════════════════════════════════╗
║  RENTAL PERIOD CHANGES              ║
║                                     ║
║  [Extension history items...]       ║
║                                     ║
║  ┌─ Adjust Rental Period ─────────┐ ║
║  │  Rate: Weekly                  │ ║
║  │  Quantity: [−]  3  [+]         │ ║
║  │                                │ ║
║  │  Extension (+1 week)           │ ║
║  │  New end: May 15, 2026         │ ║
║  │  Days change: +7               │ ║
║  │  Price change: +$25.00         │ ║
║  │  New rental total: $100.00     │ ║
║  │                                │ ║
║  │  [ Submit Request ]            │ ║
║  └────────────────────────────────┘ ║
╚══════════════════════════════════════╝
```

## 验证
```bash
flutter analyze
```
必须零错误。
