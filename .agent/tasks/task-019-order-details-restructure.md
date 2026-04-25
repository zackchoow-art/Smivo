# Task 019: Order Details 页重构

## 分配给: Sonnet 4.6 Thinking
## 复杂度: ⭐⭐⭐⭐
## 涉及文件
- `lib/features/orders/screens/sale_order_detail_screen.dart` (332 行)
- `lib/features/orders/screens/rental_order_detail_screen.dart` (536 行)
- `lib/features/orders/widgets/order_timeline.dart`
- `lib/features/orders/widgets/order_info_section.dart`
- `lib/features/orders/widgets/order_financial_summary.dart`
- `lib/features/orders/widgets/order_header_card.dart`

## 项目架构参考
- 主题 token：`context.smivoColors`, `context.smivoTypo`, `context.smivoRadius`
- Order model：`lib/data/models/order.dart`（有 `buyer`, `seller` UserProfile join 和所有状态字段）
- Order Status Flows 文档：`/Users/george/.gemini/antigravity/brain/83380731-1725-4f03-9dfd-13bda320394f/artifacts/order_status_flows.md`

## 修改清单

### 1. Order Timeline 重新设计
**当前问题**：Timeline 看起来像硬编码/占位符，不是真实数据驱动的。

**新设计**：
- 时间在**左侧**（日期 + 时间）
- 竖线连接
- 状态 + 用户信息在**右侧**

**Timeline 步骤内容改进**：
- **买家下单步骤**：右侧显示买家名称（可能有多个买家申请，按时间先后从上到下显示）
  - 注意：当前 Order model 是一个订单只对应一个买家。多个买家的申请是多个 Order 记录。Timeline 只需显示当前这一笔订单的买家。
- **卖家 Accept 步骤**：右侧显示买家名称
- **Pickup 步骤**：右侧显示 pickup 地址（从 `order.pickupLocation?.name` 或地址字段获取）
- **Sale vs Rent 不同流程**：
  - Sale: 下单 → 接受 → Pickup 确认 → 完成
  - Rent: 下单 → 接受 → 双方确认交付 → 激活 → 归还请求 → 确认归还 → 退押金 → 完成

### 2. Financial Summary 改进
**Rent 订单**：删除 `Total` 行。该区域只展示：
- 日租金（如果有）
- 周租金（如果有）
- 月租金（如果有）
- 不显示 "Total" 计算

**Sale 订单**：保持现有行为。

### 3. Order Info 栏重新排列
替换当前 `OrderInfoSection` 的内容为：
1. 第一行：商品上架时间（`order.listing?.createdAt` 或 `order.createdAt`）
2. 第二行：类型（Sale / Rent）
3. 第三行：订单 Status（当前状态，用 chip 显示）
4. 第四行：Pickup 地址
5. 第五行：售价 或 租金合计
6. 第六行：押金（仅 rent 且 deposit > 0）
7. 第七行：`Divider()`
8. 第八行：订单总计（租金 + 押金）

### 4. Rental Period 栏改进
当前的 Rental Period 区域改为显示：
1. 第一行：`3 Days` / `1 Week` / `2 Months`（根据 `order.rentalRateType` 和计算的数量）
2. 第二行：开始日期 `order.rentalStartDate`
3. 第三行：结束日期 `order.rentalEndDate`

### 5. 移除 Accept Order 按钮
在 sale_order_detail_screen 和 rental_order_detail_screen 中，找到 Accept 按钮并移除。
这个页面只作为订单信息展示 + 后续操作（如 Confirm Pickup, Cancel 等仍保留）。

### 6. 通知标题匹配
按 order_status_flows 文档中的「通知时机总结」，确认各状态的通知文字正确。

## 验证
```bash
flutter analyze
```
必须零错误。不要修改 provider 或 repository 层。
