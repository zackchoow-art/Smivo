# BUG-005: Buyer Center 订单卡片样式优化

## 修改文件

**只修改这一个文件：**
- `lib/features/buyer/screens/buyer_center_screen.dart`

## 需求 1：日期格式和位置

**当前**：日期 `Apr 25` 在左侧商品信息的第三行。

**修改**：
- 日期格式改为 `M/d/yyyy HH:mm`（例如 `4/25/2026 12:15`）
- 将日期从左侧移到右侧，放在 `_StatusChip` 的下方
- 左侧商品信息只保留两行：商品名 + 价格·卖家名

**具体实现**：修改卡片 Row 的右侧部分，从单独的 `_StatusChip` 改为一个 Column，包含 StatusChip 和日期：
```dart
// 修改前（约第 229-230 行）
const SizedBox(width: 8),
_StatusChip(order: order, hasUnread: hasUnread),

// 修改后
const SizedBox(width: 8),
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    _StatusChip(order: order, hasUnread: hasUnread),
    const SizedBox(height: 4),
    Text(dateStr, style: typo.labelSmall.copyWith(
      color: colors.onSurface.withValues(alpha: 0.4))),
  ],
),
```

同时修改 dateStr 格式：
```dart
// 修改前
final dateStr = DateFormat('MMM d').format(order.createdAt);
// 修改后
final dateStr = DateFormat('M/d/yyyy HH:mm').format(order.createdAt);
```

并删除左侧的日期行（约第 227 行的 Text(dateStr, ...)）。

## 需求 2：订单状态文字颜色改为页面背景色

**当前**：状态文字颜色与背景色相同（如黄色背景+黄色文字）。
**修改**：所有状态的 textColor 统一改为 `colors.surfaceContainerLowest`（页面背景色）。

修改 `_resolveChip` 和 `_confirmedChip` 方法中的返回值，将第二个元素（textColor）全部改为使用页面背景色。

**但背景色（bgColor）保持不变，继续使用各状态对应的颜色。**

具体修改：`_resolveChip` 方法中，bgColor 不再使用 `withValues(alpha: 0.15)` 半透明，改为使用原色（不透明），textColor 改为页面背景色：
```dart
// 修改前
'pending' => (colors.statusPending.withValues(alpha: 0.15), colors.statusPending, 'Pending'),
// 修改后
'pending' => (colors.statusPending, colors.surfaceContainerLowest, 'Pending'),
```

对 `_confirmedChip` 中的所有返回值也做同样修改。

## 需求 3：减小卡片高度

- 将卡片 padding 从 `EdgeInsets.all(12)` 改为 `EdgeInsets.symmetric(horizontal: 12, vertical: 8)`
- 将图片尺寸从 `60x60` 改为 `48x48`
- 将卡片间距 margin bottom 从 `12` 改为 `8`

## 需求 5：统一状态容器宽度

在 `_StatusChip` 的 build 方法中，给状态容器一个固定的最小宽度，确保所有状态标签容器宽度一致：
```dart
// 修改前
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  ...
)

// 修改后
Container(
  constraints: const BoxConstraints(minWidth: 72),
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  ...
  child: Text(label, textAlign: TextAlign.center, ...),
)
```

## 严格边界

- ❌ 不要修改搜索栏代码
- ❌ 不要修改折叠功能代码
- ❌ 不要修改 `_buildSection` 的标题行代码
- ❌ 不要修改订单分类逻辑
- ❌ 不要修改路由导航
- ❌ 不要修改任何 provider
- ❌ 不要修改任何其他文件
- ❌ 不要添加新的 import
- ❌ 不要修改红色圆点的逻辑（保留 hasUnread 红色圆点）

## 验证步骤

```bash
cd /Users/george/smivo && flutter analyze
```

## 执行报告

写入：`.agent/reports/BUG-005-report.md`
