# Task: Phase 5 — Order Detail 页面响应式适配

## 执行边界 ⚠️
- **只修改本文件列出的 6 个文件**，不得修改其他文件
- **不得修改业务逻辑、Provider、Repository、Model、router**
- 使用 `LayoutBuilder` + `Breakpoints` 类判断屏幕尺寸

## 可用工具
```dart
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/core/theme/breakpoints.dart';
```

---

### 5-1. `lib/features/orders/screens/sale_order_detail_screen.dart` (430 行)
- 整个滚动内容区：`ContentWidthConstraint(maxWidth: 768)` 居中
- 底部操作按钮区域也需居中约束

### 5-2. `lib/features/orders/screens/rental_order_detail_screen.dart` (801 行)
- 整个滚动内容区：`ContentWidthConstraint(maxWidth: 768)` 居中
- 底部操作按钮区域也需居中约束
- 注意此文件最大（801行），修改时需特别小心保留所有现有逻辑

### 5-3. `lib/features/orders/widgets/order_timeline.dart` (182 行)
- 不需要修改（已在 ContentWidthConstraint 内部）

### 5-4. `lib/features/orders/widgets/order_info_section.dart` (279 行)
- 桌面模式（> 1024px）时：信息项排列从单列改为 2 列 Grid
- 手机/平板保持单列
- 使用 `LayoutBuilder` 判断

### 5-5. `lib/features/orders/widgets/rental_extension_card.dart` (573 行)
- 不需要修改（外层约束会控制宽度）

### 5-6. `lib/features/orders/widgets/chat_history_section.dart` (116 行)
- 不需要修改

---

## 完成后必做
1. 运行 `flutter analyze --no-fatal-infos`
2. 确保 **0 errors**
3. 将执行报告写入 `.agent/reports/responsive_phase5_report.md`
