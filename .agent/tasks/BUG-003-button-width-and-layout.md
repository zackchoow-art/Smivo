# BUG-003: 统一按钮宽度 + 移动 Request Return 按钮位置

## 需求

### 1. 统一按钮宽度（两个页面）

在 `sale_order_detail_screen.dart` 和 `rental_order_detail_screen.dart` 中，所有操作按钮应该有一致的宽度约束。

**当前问题**：按钮在不同深度的容器内（有的在 CollapsibleSection 内，有的在顶层 Column 内），导致页面上显示的宽度不一致。

**修复方案**：确保所有按钮都使用统一的宽度约束模式。当前已有的标准模式是：
```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 360),
    child: SizedBox(
      width: double.infinity,
      child: XxxButton(...),
    ),
  ),
)
```

需要检查并统一以下按钮：

**sale_order_detail_screen.dart:**
- Confirm Pickup 按钮（约第 190-211 行）— 已有 ConstrainedBox(maxWidth: 360) ✓
- Cancel Order 按钮（约第 368-397 行）— 已有 ConstrainedBox(maxWidth: 360) ✓

**rental_order_detail_screen.dart:**
- Confirm Delivery 按钮（约第 286-313 行）— 已有 ConstrainedBox(maxWidth: 360) ✓
- Cancel Order 按钮（约第 631-674 行）— 已有 ConstrainedBox(maxWidth: 360) ✓
- Request Return 按钮（约第 480-499 行）— 已有 ConstrainedBox(maxWidth: 360) ✓
- Confirm Return 按钮（约第 517-539 行）— 已有 ConstrainedBox(maxWidth: 360) ✓
- Confirm Deposit Refund 按钮（约第 561-586 行）— 已有 ConstrainedBox(maxWidth: 360) ✓

**rental_extension_card.dart:**
- Submit Request 按钮（约第 253-269 行）— ⚠️ 没有 ConstrainedBox 包裹，在 _buildAdjustmentUI 的 Container 内
- Adjust Rental Period 按钮（约第 104-110 行）— ⚠️ 没有 ConstrainedBox 包裹
- Approve / Reject 按钮（约第 417-441 行）— ⚠️ 使用 Wrap，没有统一宽度约束

对于 rental_extension_card.dart 中的按钮，由于它们已经在一个 padding 为 16 的 Container 内部，如果再加 ConstrainedBox(maxWidth: 360) 可能导致过窄。请根据实际效果判断是否需要调整。**如果不确定，不要改动这些按钮。**

### 2. 移动 Request Return 按钮位置（仅 rental_order_detail_screen.dart）

**当前位置**：`_buildRentalLifecycleActions` 方法生成的按钮位于页面最底部（第 170-173 行），在 `_buildStatusBanner` 和 `_buildChatSection` 之后。

**目标位置**：将 `_buildRentalLifecycleActions` 的调用移到 `_buildChatSection` 之前。

**当前代码（约第 167-173 行）：**
```dart
// Section 8: Chat History — collapsible, default closed
_buildChatSection(ref, order),
_buildStatusBanner(context, order),
if (order.rentalStatus != null) ...[
  const SizedBox(height: 12),
  _buildRentalLifecycleActions(context, ref, order, isBuyer, isSeller, isActing),
],
```

**修改为：**
```dart
// Rental lifecycle actions (Request Return, Confirm Return, etc.)
if (order.rentalStatus != null) ...[
  _buildRentalLifecycleActions(context, ref, order, isBuyer, isSeller, isActing),
  const SizedBox(height: 16),
],
// Section 8: Chat History — collapsible, default closed
_buildChatSection(ref, order),
_buildStatusBanner(context, order),
```

## 修改范围

**只修改以下文件：**
- `lib/features/orders/screens/rental_order_detail_screen.dart`
- `lib/features/orders/screens/sale_order_detail_screen.dart`

**可能需要修改（谨慎判断）：**
- `lib/features/orders/widgets/rental_extension_card.dart`

## 严格边界

- ❌ 不要修改任何 provider 文件
- ❌ 不要修改任何 repository 文件
- ❌ 不要修改任何 model 文件
- ❌ 不要修改 widget 的业务逻辑
- ❌ 不要修改按钮的 onPressed 回调内容
- ❌ 不要修改按钮的颜色/文字/图标等样式
- ❌ 不要修改 CollapsibleSection 的使用方式
- ❌ 不要重新排列其他 Section 的顺序
- ❌ 不要删除任何注释
- ⚠️ 这两个页面结构复杂，非常容易崩溃。请只做最小化改动，每次改动后都确认逻辑正确。

## 验证步骤

```bash
cd /Users/george/smivo && flutter analyze
```

## 执行报告

写入：`.agent/reports/BUG-003-report.md`

报告内容包括：
1. 具体修改了哪些文件哪些行
2. 修改前后对比
3. `flutter analyze` 结果
4. 对 rental_extension_card.dart 中按钮是否需要调整的判断结论
