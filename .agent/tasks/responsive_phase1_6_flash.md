# Task: Phase 1 + Phase 6 — 简单页面响应式适配

## 执行边界 ⚠️
- **只修改本文件列出的文件**，不得修改其他任何文件
- **不得修改业务逻辑、Provider、Repository、Model**
- **不得修改 router.dart**
- 只修改 UI 布局相关代码（Container、Padding、Grid、Column/Row）
- 所有修改使用 `LayoutBuilder` + `Breakpoints` 类判断屏幕尺寸
- 必须 import `package:smivo/core/theme/breakpoints.dart`
- 必须 import `package:smivo/shared/widgets/content_width_constraint.dart`（需要时）

## Breakpoints 定义（已存在，直接使用）
```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1024;
  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}
```

## ContentWidthConstraint 用法
```dart
ContentWidthConstraint(
  maxWidth: 640, // 按需调整
  child: yourContent,
)
```

---

## Phase 1：Home 页面（6 个文件）

### 1-1. `lib/features/home/screens/home_screen.dart`
- 在 body 的最外层使用 `LayoutBuilder`，获取可用宽度
- 桌面模式（> 1024px）时，给整个内容区添加 `ContentWidthConstraint(maxWidth: 1280)`
- **不改变 GridView 的列数**（已有 IKEA/Teal 主题判断，保持不变）

### 1-2. `lib/features/home/widgets/home_header.dart`
- 桌面模式时搜索栏宽度限制为 `min(width * 0.4, 480)` px
- 不修改其他任何头部内容

### 1-3. `lib/features/home/widgets/featured_listing_card.dart`
- 桌面模式时添加 `maxWidth: 600` 约束（防止卡片过宽）
- 使用 `ConstrainedBox` 包裹

### 1-4. `lib/features/home/widgets/ikea_featured_listing_card.dart`
- 同 1-3，桌面时 `maxWidth: 600`

### 1-5. `lib/features/home/widgets/compact_listing_card.dart`
- 不需要修改（Grid 自动约束大小）

### 1-6. `lib/features/home/widgets/ikea_grid_listing_card.dart`
- 不需要修改

---

## Phase 6：Auth + Settings 页面（10 个文件）

所有页面的改造模式相同：用 `ContentWidthConstraint` 包裹页面主要内容区。

### 6-1. `lib/features/auth/screens/login_screen.dart`
- 整个表单区域 wrap with `ContentWidthConstraint(maxWidth: 420)`
- 使用 `LayoutBuilder`，桌面模式时用 `Center` widget 垂直居中表单

### 6-2. `lib/features/auth/screens/register_screen.dart`
- 同 login，`ContentWidthConstraint(maxWidth: 420)`

### 6-3. `lib/features/auth/screens/email_verification_screen.dart`
- `ContentWidthConstraint(maxWidth: 480)`

### 6-4. `lib/features/profile/screens/profile_setup_screen.dart`
- `ContentWidthConstraint(maxWidth: 480)`

### 6-5. `lib/features/settings/screens/settings_screen.dart`
- `ContentWidthConstraint(maxWidth: 640)`

### 6-6. `lib/features/settings/screens/edit_profile_screen.dart`
- `ContentWidthConstraint(maxWidth: 640)`

### 6-7. `lib/features/settings/screens/help_screen.dart`
- `ContentWidthConstraint(maxWidth: 768)`

### 6-8. `lib/features/settings/screens/notification_settings_screen.dart`
- `ContentWidthConstraint(maxWidth: 640)`

### 6-9. `lib/features/settings/screens/system_settings_screen.dart`
- `ContentWidthConstraint(maxWidth: 640)`

### 6-10. `lib/features/notifications/screens/notification_center_screen.dart`
- `ContentWidthConstraint(maxWidth: 768)`

---

## 完成后必做
1. 运行 `flutter analyze --no-fatal-infos`
2. 确保 **0 errors**
3. 将执行报告写入 `.agent/reports/responsive_phase1_6_report.md`，包含：
   - 修改了哪些文件
   - 每个文件改了什么
   - flutter analyze 结果
