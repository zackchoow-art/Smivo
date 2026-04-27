# Task: Phase 4 — Orders Hub + Buyer/Seller Center 响应式适配

## 执行边界 ⚠️
- **只修改本文件列出的 8 个文件**，不得修改其他文件
- **不得修改业务逻辑、Provider、Repository、Model、router**
- 使用 `LayoutBuilder` + `Breakpoints` 类判断屏幕尺寸
- 使用已有的 `ContentWidthConstraint` 和 `SliverResponsiveGrid` 组件

## 可用的响应式组件（已创建，直接 import 使用）
```dart
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/shared/widgets/responsive_grid.dart';
import 'package:smivo/core/theme/breakpoints.dart';
```

### SliverResponsiveGrid 用法
```dart
SliverResponsiveGrid(
  itemCount: items.length,
  mobileColumns: 2,
  tabletColumns: 3,
  desktopColumns: 4,
  childAspectRatio: 0.72,
  crossAxisSpacing: 24,
  mainAxisSpacing: 12,
  itemBuilder: (context, index) => YourCard(...),
)
```

---

### 4-1. `lib/features/orders/screens/orders_screen.dart` (164 行)
- Hub 页面的 Buyer/Seller 卡片区域：`ContentWidthConstraint(maxWidth: 960)`
- 桌面模式时两张卡片改为 `Row` 横排（等宽），而非纵向堆叠

### 4-2. `lib/features/buyer/screens/buyer_center_screen.dart` (419 行)
- 当前 IKEA 主题使用固定 `crossAxisCount: 2` 的 SliverGrid
- 改为 `SliverResponsiveGrid`：手机 2 列 / 平板 3 列 / 桌面 4 列
- 整个内容区外层：桌面时 `ContentWidthConstraint(maxWidth: 1280)`
- Teal 主题列表模式：桌面时 `ContentWidthConstraint(maxWidth: 960)`

### 4-3. `lib/features/seller/screens/seller_center_screen.dart` (995 行)
- 同 4-2：所有 IKEA SliverGrid 替换为 `SliverResponsiveGrid`
- 整体内容区桌面 maxWidth 1280
- Teal 列表模式桌面 maxWidth 960
- **注意**：此文件有 4 个 section（Listings/Awaiting/Transactions/History），每个都有独立的 SliverGrid，全部要改

### 4-4. `lib/features/seller/screens/transaction_management_screen.dart` (561 行)
- Tab 内容区：`ContentWidthConstraint(maxWidth: 960)` 居中

### 4-5. `lib/features/buyer/widgets/ikea_buyer_order_card.dart` (199 行)
- 不需要修改（Grid 自动约束尺寸）

### 4-6. `lib/features/seller/widgets/ikea_seller_order_card.dart` (503 行)
- 不需要修改

### 4-7. `lib/features/orders/widgets/order_card.dart` (506 行)
- 不需要修改（列表项自适应）

### 4-8. `lib/features/orders/widgets/list_order_card.dart` (141 行)
- 不需要修改

---

## 完成后必做
1. 运行 `flutter analyze --no-fatal-infos`
2. 确保 **0 errors**
3. 将执行报告写入 `.agent/reports/responsive_phase4_report.md`
