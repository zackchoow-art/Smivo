# Task 019: Order Details 页重构（Timeline + Info + Financial Summary）

## 分配给: Sonnet 4.6 Thinking（或同等高能力 agent）
## 复杂度: ⭐⭐⭐⭐
## 依赖: Phase 1 已完成

## 重要规则
- **读完所有涉及文件后再修改**
- **不要修改 provider 或 repository 层代码**
- **主题 token 必须使用**: `context.smivoColors`, `context.smivoTypo`, `context.smivoRadius`
- **不要删除任何现有功能代码**（Delivery Status, Evidence Photos, Chat Section, Rental Extension, Cancel 等功能保留）
- **Order model 字段参考**: `lib/data/models/order.dart`（下方已列出关键字段）

## Order Model 关键字段
```dart
String id, listingId, buyerId, sellerId, orderType, status
DateTime createdAt, updatedAt
DateTime? rentalStartDate, rentalEndDate, returnConfirmedAt, depositRefundedAt, returnRequestedAt
bool deliveryConfirmedByBuyer, deliveryConfirmedBySeller
double totalPrice, depositAmount
String? rentalStatus, pickupLocationId
UserProfile? buyer, seller
OrderListingPreview? listing
PickupLocation? pickupLocation
```

## 涉及文件（按修改顺序）

### 1. `lib/features/orders/widgets/order_timeline.dart` (121 行) — 重写

当前 `TimelineStep` model 只有 `label`, `date`, `isCompleted`。需要扩展并重新设计布局。

**新 TimelineStep model**:
```dart
class TimelineStep {
  const TimelineStep({
    required this.label,
    required this.isCompleted,
    this.date,
    this.subtitle,     // 买家名称、地址等附加信息
    this.isCancelled,  // 取消/missed 状态用红色
  });
  final String label;
  final DateTime? date;
  final bool isCompleted;
  final String? subtitle;
  final bool? isCancelled;
}
```

**新布局设计 — 时间在左侧，状态在右侧**:
```
  2026-04-20     ● Order Placed
  10:30 AM       │  by Alex Johnson
                 │
  2026-04-21     ● Accepted
  2:15 PM        │  Alex Johnson's offer
                 │
  ─ ─ ─ ─       ○ Picked Up
                    at Smith College Main Gate
```

设计要点：
- 左侧固定宽度（约100px），显示日期和时间（分两行）
- 中间是竖线 + 圆点
- 右侧显示 label（加粗）和 subtitle（浅色小字）
- 已完成步骤：实心圆点（primary 色）+ 实色竖线
- 未完成步骤：空心圆点 + 虚色竖线
- 取消/missed 步骤：红色圆点
- 无日期的步骤：左侧显示 "—"

### 2. `lib/features/orders/screens/sale_order_detail_screen.dart` (332 行)

**修改 `_buildSaleSteps`** (第 72-91 行):
```dart
List<TimelineStep> _buildSaleSteps(Order order) {
  return [
    TimelineStep(
      label: 'Order Placed',
      date: order.createdAt,
      isCompleted: true,
      subtitle: 'by ${order.buyer?.displayName ?? 'Buyer'}',
    ),
    TimelineStep(
      label: 'Accepted',
      date: order.status != 'pending' && order.status != 'cancelled' && order.status != 'missed'
          ? order.updatedAt : null,
      isCompleted: order.status == 'confirmed' || order.status == 'completed',
      subtitle: order.status != 'pending' ? '${order.buyer?.displayName ?? 'Buyer'}\'s offer' : null,
    ),
    TimelineStep(
      label: 'Picked Up',
      date: order.status == 'completed' ? order.updatedAt : null,
      isCompleted: order.status == 'completed',
      subtitle: order.pickupLocation?.name,
    ),
    if (order.status == 'cancelled')
      TimelineStep(
        label: 'Cancelled',
        date: order.updatedAt,
        isCompleted: true,
        isCancelled: true,
      ),
    if (order.status == 'missed')
      TimelineStep(
        label: 'Offer Missed',
        date: order.updatedAt,
        isCompleted: true,
        isCancelled: true,
        subtitle: 'Another offer was accepted',
      ),
  ];
}
```

**移除 Accept Order 按钮** (第 165-191 行 `case 'pending'` 中的 `if (isSeller)` ElevatedButton):
- 删除卖家的 "Accept Order" 按钮
- 保留 Cancel 按钮
- 卖家在 pending 状态看到的应该是一个提示文本 "Waiting for buyer to pick up" 或类似信息

**保留**：Confirm Pickup (买家)、Cancel、completed/cancelled 状态显示。

### 3. `lib/features/orders/screens/rental_order_detail_screen.dart` (536 行)

**修改 `_buildRentalSteps`** (第 112-140 行):
```dart
List<TimelineStep> _buildRentalSteps(Order order) {
  final steps = <TimelineStep>[
    TimelineStep(
      label: 'Order Placed',
      date: order.createdAt,
      isCompleted: true,
      subtitle: 'by ${order.buyer?.displayName ?? 'Buyer'}',
    ),
    TimelineStep(
      label: 'Accepted',
      date: order.status != 'pending' && order.status != 'cancelled' && order.status != 'missed'
          ? order.updatedAt : null,
      isCompleted: order.status == 'confirmed' || order.status == 'completed',
      subtitle: order.status != 'pending' ? '${order.buyer?.displayName ?? 'Buyer'}\'s offer' : null,
    ),
    TimelineStep(
      label: 'Delivered',
      date: order.deliveryConfirmedByBuyer && order.deliveryConfirmedBySeller
          ? order.updatedAt : null,
      isCompleted: order.deliveryConfirmedByBuyer && order.deliveryConfirmedBySeller,
      subtitle: order.pickupLocation?.name,
    ),
  ];

  // Add rental lifecycle steps
  if (order.rentalStatus == 'active' || ...) {
    steps.add(TimelineStep(
      label: 'Returned',
      date: order.returnConfirmedAt,
      isCompleted: order.returnConfirmedAt != null,
    ));
  }
  if (order.depositRefundedAt != null) {
    steps.add(TimelineStep(
      label: 'Deposit Refunded',
      date: order.depositRefundedAt,
      isCompleted: true,
    ));
  }
  if (order.status == 'completed') {
    steps.add(TimelineStep(
      label: 'Completed',
      date: order.updatedAt,
      isCompleted: true,
    ));
  }
  if (order.status == 'cancelled') {
    steps.add(TimelineStep(label: 'Cancelled', date: order.updatedAt, isCompleted: true, isCancelled: true));
  }
  if (order.status == 'missed') {
    steps.add(TimelineStep(label: 'Offer Missed', date: order.updatedAt, isCompleted: true, isCancelled: true));
  }
  return steps;
}
```

**移除 Accept Order 按钮**（同 sale，在 `_buildActions` 方法中的 `case 'pending'` 里的 isSeller block）

### 4. `lib/features/orders/widgets/order_financial_summary.dart` (98 行) — 修改

**Rent 订单删除 Total 行**：
把第 59-65 行的 Divider + Total 行改为仅在 sale 订单时显示：
```dart
if (order.orderType != 'rental') ...[
  const Divider(),
  _summaryRow(context, 'Total', '\$${order.totalPrice.toStringAsFixed(2)}', isBold: true),
],
```

### 5. `lib/features/orders/widgets/order_info_section.dart` (81 行) — 重写内容

替换当前内容为新的排列方式：
```dart
children: [
  Text('Order Info', style: typo.titleMedium),
  const SizedBox(height: 8),
  // 1. 商品上架时间
  _infoRow(context, 'Listed', order.listing != null 
    ? _formatDate(order.createdAt) : '—'),
  // 2. 类型
  _infoRow(context, 'Type', order.orderType == 'rental' ? 'Rent' : 'Sale'),
  // 3. 状态
  _infoRow(context, 'Status', _statusText(order.status)),
  // 4. Pickup 地址
  if (order.pickupLocation != null)
    _infoRow(context, 'Pickup', order.pickupLocation!.name),
  // 5. 售价或租金合计
  _infoRow(context, order.orderType == 'rental' ? 'Rental Total' : 'Price',
    '\$${order.totalPrice.toStringAsFixed(2)}'),
  // 6. 押金（仅租赁 + 有押金）
  if (order.orderType == 'rental' && order.depositAmount > 0)
    _infoRow(context, 'Deposit', '\$${order.depositAmount.toStringAsFixed(2)}'),
  // 7. 分割线
  if (order.orderType == 'rental' && order.depositAmount > 0) ...[
    const Divider(),
    // 8. 订单总计
    _infoRow(context, 'Grand Total', 
      '\$${(order.totalPrice + order.depositAmount).toStringAsFixed(2)}',
      isBold: true),
  ],
],
```

需要修改 `_infoRow` 支持 `isBold` 参数。

### 6. `lib/features/orders/widgets/rental_date_section.dart` (60 行) — 修改

改为显示：
```dart
// 第一行：租赁数量和方式 (如 "3 Days" / "1 Week" / "2 Months")
_infoRow(context, 'Duration', _computeRentalDuration(order)),
// 第二行：开始日期
_infoRow(context, 'Start', _formatDate(order.rentalStartDate!)),
// 第三行：结束日期  
_infoRow(context, 'End', order.rentalEndDate != null 
  ? _formatDate(order.rentalEndDate!) : '—'),
```

需要添加 `_computeRentalDuration` 方法：根据 `rentalStartDate` 和 `rentalEndDate` 的差值 + listing 上的可用 rate types 来推断是 daily/weekly/monthly。

简单逻辑：
```dart
String _computeRentalDuration(Order order) {
  if (order.rentalStartDate == null || order.rentalEndDate == null) return '—';
  final days = order.rentalEndDate!.difference(order.rentalStartDate!).inDays;
  if (days % 30 == 0 && days >= 30) return '${days ~/ 30} Month${days ~/ 30 > 1 ? 's' : ''}';
  if (days % 7 == 0 && days >= 7) return '${days ~/ 7} Week${days ~/ 7 > 1 ? 's' : ''}';
  return '$days Day${days > 1 ? 's' : ''}';
}
```

## 验证
```bash
flutter analyze
```
必须零错误。在 Chrome 上手动测试 Sale 和 Rental 订单详情页。
