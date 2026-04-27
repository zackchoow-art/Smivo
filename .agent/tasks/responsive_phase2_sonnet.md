# Task: Phase 2 — Listing Detail + Create Listing 响应式适配

## 执行边界 ⚠️
- **只修改本文件列出的 4 个文件**，不得修改其他文件
- **不得修改业务逻辑、Provider、Repository、Model、router**
- 只修改 UI 布局相关代码
- 使用 `LayoutBuilder` + `Breakpoints` 类判断屏幕尺寸
- 必须 import `package:smivo/core/theme/breakpoints.dart`
- 必须 import `package:smivo/shared/widgets/content_width_constraint.dart`

## Breakpoints（已有，直接用）
```dart
Breakpoints.isMobile(width)   // < 600
Breakpoints.isTablet(width)   // 600-1024
Breakpoints.isDesktop(width)  // > 1024
```

---

### 2-1. `lib/features/listing/screens/listing_detail_screen.dart` (625 行)
改造要点：
- **图片区域**：在 build 中使用 `LayoutBuilder` 获取宽度
  - 手机：保持当前 aspect ratio（约 4:3）
  - 平板：aspect ratio 改为 16:9
  - 桌面：aspect ratio 改为 2:1，且 maxHeight 500px
- **信息区域**：用 `ContentWidthConstraint(maxWidth: 768)` 包裹图片下方所有内容
- **底部操作栏**：桌面模式时也用 `ContentWidthConstraint(maxWidth: 768)` 居中

### 2-2. `lib/features/listing/widgets/listing_image_carousel.dart` (153 行)
- 桌面模式时，整个轮播组件添加 `maxHeight: 500` 约束
- 使用 `ConstrainedBox`

### 2-3. `lib/features/listing/widgets/rental_options_section.dart` (276 行)
- 桌面模式时，日期选择区和费率卡片改为 `Row` 横排
- 手机/平板保持 `Column` 纵排
- 使用 `LayoutBuilder` 判断

### 2-4. `lib/features/listing/screens/create_listing_form_screen.dart` (407 行)
- 整个表单区域 wrap with `ContentWidthConstraint(maxWidth: 640)`
- 图片选择区域桌面时 maxHeight 约束

---

## 完成后必做
1. 运行 `flutter analyze --no-fatal-infos`
2. 确保 **0 errors**
3. 将执行报告写入 `.agent/reports/responsive_phase2_report.md`
