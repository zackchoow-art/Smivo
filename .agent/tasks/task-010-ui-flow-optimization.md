# Task 010: UI 布局及业务流程优化

> **状态**: 📋 待实施  
> **创建日期**: 2026-04-24  
> **优先级**: 高

---

## 变更清单

### 1. 产品详情页 — 买家视角增强

**文件**: `lib/features/listing/screens/listing_detail_screen.dart`

**当前状态**: 买家已提交申请时，底部显示 "Application Submitted" + 日期时间。

**需要新增**:

#### 1a. 显示成交金额
- 在 "Application Submitted" 卡片中增加订单总价显示
- Sale 订单：显示 `$totalPrice`
- Rental 订单：显示租赁方式和金额，格式示例：`3 Days, Total: $300`
  - 需从 order 对象中获取 `rentalRateType`、`rentalDuration`、`totalPrice`

#### 1b. 添加 Cancel 按钮
- 在金额信息下方增加 "Cancel" 按钮
- 点击后弹出确认对话框
- 确认后：取消该订单（`status = 'cancelled'`），返回上一页
- 仅在 `order.status == 'pending'` 时显示

**示意布局**:
```
┌────────────────────────────────────────────┐
│ ✓ Application Submitted                   │
│   Apr 24, 2026 3:45 PM                    │
│   3 Days, Total: $300                     │
│                                            │
│   [ Cancel Application ]                   │
└────────────────────────────────────────────┘
```

---

### 2. 全局 — 用户真实头像

**影响范围**: 所有显示用户头像的页面

**要求**: 所有 `CircleAvatar` 都应优先拉取用户的 `avatarUrl`，仅在无头像时显示占位 icon。

**需检查的页面**:
- Manage Transactions（Views / Saves / Offers tab 卡片）
- Seller Center（Active Transactions 卡片）
- Buyer Center（订单卡片）
- Order Detail（买家/卖家信息区）
- Chat 列表 / Chat Popup
- Settings / Profile

**标准模式**:
```dart
CircleAvatar(
  backgroundImage: user.avatarUrl != null
      ? NetworkImage(user.avatarUrl!)
      : null,
  child: user.avatarUrl == null
      ? Icon(Icons.person)
      : null,
)
```

---

### 3. Chat Popup — 订单金额校验

**文件**: `lib/features/chat/widgets/chat_popup.dart`

**问题**: 从产品详情页点击聊天图标弹出的 chat-popup 界面，
上方订单信息区的金额可能显示有误。

**排查点**:
- 传入 `listingPrice` 的值是否正确（是否传了 listing 的价格而非 order 的 totalPrice）
- 对于 rental 订单，应显示 order 的 `totalPrice` 而非 listing 的 `price`
- 确认所有调用 `showChatPopup()` 的地方传参一致

---

### 4. Settings 页 — 移除通知推送图标

**文件**: `lib/features/settings/screens/settings_screen.dart`

**变更**: 移除右上角的系统消息推送图标（notification bell），
仅保留左上角的返回 (back) 图标。

---

### 5. "错过商品" 通知文案优化

**场景**: 卖家 Accept 某个买家后，其他买家的 pending 订单被自动 cancelled。

**当前文案**: "订单被取消"

**优化文案**: 改为更友好的提示，例如：
- 推送通知标题: `Offer Missed`
- 推送通知内容: `Another buyer was selected for "{listing.title}". Keep browsing!`
- History 中的显示: `Missed` 状态标签（而非 `Cancelled`）

**涉及文件**:
- 通知创建逻辑（`OrderActionsNotifier` 或触发通知的代码）
- Buyer Center 的 `_StatusChip`（已有 `Missed` 标签 ✅）
- 可能需要在 order 表中增加一个字段区分 "主动取消" 和 "被抢先"，
  或者用 `cancellation_reason` 字段

---

### 6. Seller Center — Accept 后导航优化

**文件**: `lib/features/seller/screens/seller_center_screen.dart`

**当前问题**:
- 卖家 Accept 买家后，没有跳转到 Order Details 的入口
- 卡片上的图片/标题点击后跳转到了产品详情页，而非 Order Details

**需要的变更**:

#### 6a. Accept 后自动跳转
- 在 `_OffersTab` 中，Accept 成功后跳转到该订单的 Order Detail：
  ```dart
  context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': orderId});
  ```
  （而非当前的 `context.goNamed(AppRoutes.sellerCenter)`）

#### 6b. Active Transactions 卡片点击目标
- Active Transactions 区的卡片：
  - 点击图片 / 商品标题 → **Order Detail**（而非 Listing Detail）
  - 因为此时已进入交易流程，卖家需要看的是订单进度

---

### 7. Order Details — Evidence Photo 按钮显隐逻辑

**文件**: `lib/features/orders/screens/order_detail_screen.dart`

#### 7a. Sale 订单
- Confirm Delivery 之后：**隐藏** "Add Evidence Photo" 按钮
- 对买家和卖家都隐藏

#### 7b. Rental 订单
- 在**归还阶段**时：可以上传照片（记录归还物品状态）
- 归还完成（`rental_status == 'returned'` 或之后）：**隐藏**上传按钮

**判断逻辑**:
```dart
bool showEvidenceButton;
if (order.orderType == 'sale') {
  // Sale: hide after either party confirmed delivery
  showEvidenceButton = order.status == 'confirmed'
      && !order.buyerDeliveryConfirmed
      && !order.sellerDeliveryConfirmed;
} else {
  // Rental: show during return phase only
  showEvidenceButton = order.rentalStatus == 'return_requested'
      || order.rentalStatus == 'active';
}
```

---

### 8. [待讨论] Sale vs Rent 分离 Order Detail 页面

**背景**: Sale 和 Rental 的业务流程差异较大：

| 维度 | Sale | Rental |
|------|------|--------|
| 流程 | pending → confirmed → delivery confirmed → completed | pending → confirmed → delivery → active → return → returned → deposit refund → completed |
| 时间信息 | 无 | 租赁开始/结束日期 |
| 金额 | 一次性总价 | 日/周/月费率 + 押金 |
| Evidence Photo | 交货前可上传 | 交货前 + 归还时可上传 |
| 操作按钮 | Confirm Pickup | Request Return → Confirm Return → Refund Deposit |

**方案 A: 维持单页面（推荐）**
- 用条件渲染控制 sale/rental 差异区域
- 优点：维护一个文件，共享通用逻辑（聊天、证据照片、状态 timeline）
- 缺点：build() 方法可能变长

**方案 B: 拆分为两个页面**
- `SaleOrderDetailScreen` + `RentalOrderDetailScreen`
- 优点：每个页面逻辑清晰
- 缺点：大量重复代码（timeline、chat history、evidence photos 等），维护成本高

**我推荐方案 A**，因为：
- 两种订单 70%+ 的 UI 是相同的（header、chat、evidence、basic info）
- 可以将差异部分提取为私有方法：`_buildSaleActions()` / `_buildRentalActions()`
- 不需要拆分 Seller Center 卡片组件，只需在卡片上显示不同的 status 信息

> **✅ 已确认方案 A — 维持单页面，条件渲染差异区域。**

---

## 执行文件

| 文件 | 内容 |
|------|------|
| `task-010a-p0-fixes.md` | P0：Accept 导航、买家申请卡片、Evidence Photo、Settings |
| `task-010b-p1-fixes.md` | P1/P2：Missed 通知文案、Chat Popup 金额、全局头像 |

---

## 实施优先级建议

| 优先级 | 任务 | 复杂度 |
|--------|------|--------|
| P0 | #6 Accept 后导航 + 卡片点击目标 | 低 |
| P0 | #1 买家申请卡片增强 + Cancel | 中 |
| P1 | #7 Evidence Photo 按钮显隐 | 低 |
| P1 | #4 Settings 移除通知图标 | 低 |
| P1 | #5 Missed 通知文案 | 中 |
| P2 | #3 Chat Popup 金额校验 | 低 |
| P2 | #2 全局头像检查 | 中（面广） |
| — | #8 Sale/Rent 分离 | 待讨论 |

---

## 涉及文件

| 文件 | 变更 |
|------|------|
| `listing_detail_screen.dart` | #1 买家申请卡片 + Cancel |
| `seller_center_screen.dart` | #6 Accept 导航 + 卡片点击 |
| `transaction_management_screen.dart` | #6a Accept 后跳转 |
| `order_detail_screen.dart` | #7 Evidence Photo 显隐 |
| `settings_screen.dart` | #4 移除通知图标 |
| `chat_popup.dart` | #3 金额校验 |
| 多个文件 | #2 全局头像 |
| 通知相关 provider/repository | #5 Missed 文案 |
