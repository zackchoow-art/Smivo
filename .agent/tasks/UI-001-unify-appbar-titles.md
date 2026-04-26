# UI-001: 统一 AppBar 和页面大标题样式

## 目标
统一 9 个页面的顶部导航栏和页面大标题的字体字号颜色。

## 统一标准

### 标准 A：使用 CustomAppBar + body 大标题
- AppBar：`CustomAppBar(showActions: false)`
- 页面大标题：`typo.headlineLarge.copyWith(fontWeight: FontWeight.w900, color: colors.onSurface)`
- 标题位置：body 顶部，`Padding(horizontal: 24, vertical: 8)` 内

### 标准 B：保留原生 AppBar（有特殊 actions/TabBar 的页面）
- AppBar 标题样式统一为：`typo.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w800)`
- AppBar 背景色：`colors.surfaceContainerLowest`
- leading 返回按钮：`Icon(Icons.arrow_back_ios_new, size: 20, color: colors.onSurface)`

---

## 修改清单

### 第 1 组：Settings 子页面 — 颜色统一（5 个文件）

这 5 个文件已经使用 CustomAppBar + body 大标题，只需将 `colors.settingsText` 改为 `colors.onSurface`。

#### 1. `lib/features/settings/screens/settings_screen.dart`
- 找到所有 `colors.settingsText` → 替换为 `colors.onSurface`
- 仅改标题和子标题中的颜色引用

#### 2. `lib/features/settings/screens/edit_profile_screen.dart`
- 找到所有 `colors.settingsText` 或 `colors.settingsTextSecondary` → 分别替换为 `colors.onSurface` 和 `colors.onSurfaceVariant`

#### 3. `lib/features/settings/screens/help_screen.dart`
- 找到所有 `colors.settingsText` → 替换为 `colors.onSurface`

#### 4. `lib/features/settings/screens/system_settings_screen.dart`
- 找到所有 `colors.settingsText` → 替换为 `colors.onSurface`

#### 5. `lib/features/settings/screens/notification_settings_screen.dart`
- 找到所有 `colors.settingsText` → 替换为 `colors.onSurface`
- 找到所有 `colors.settingsTextSecondary` → 替换为 `colors.onSurfaceVariant`

### 第 2 组：添加 CustomAppBar（2 个文件）

#### 6. `lib/features/buyer/screens/buyer_center_screen.dart`
当前：无 AppBar，body 内有标题 `typo.headlineLarge.copyWith(fontWeight: FontWeight.w900)`

改为：
- 在 Scaffold 中添加 `appBar: const CustomAppBar(showActions: false),`
- 需要 import CustomAppBar
- 标题保持 `typo.headlineLarge.copyWith(fontWeight: FontWeight.w900, color: colors.onSurface)`（加 color）

#### 7. `lib/features/seller/screens/seller_center_screen.dart`
当前：无 AppBar，body 内有标题 `typo.headlineLarge.copyWith(fontWeight: FontWeight.w900)`

改为：
- 在 Scaffold 中添加 `appBar: const CustomAppBar(showActions: false),`
- 需要 import CustomAppBar
- 标题保持 `typo.headlineLarge.copyWith(fontWeight: FontWeight.w900, color: colors.onSurface)`（加 color）

### 第 3 组：统一原生 AppBar 样式（2 个文件）

#### 8. `lib/features/notifications/screens/notification_center_screen.dart`
当前 AppBar：
```dart
appBar: AppBar(
  backgroundColor: colors.background,
  surfaceTintColor: Colors.transparent,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
    onPressed: () { ... },
  ),
  title: Text('Notifications', style: typo.headlineSmall),
  actions: [ TextButton(...) ],
),
```

改为：
```dart
appBar: AppBar(
  backgroundColor: colors.surfaceContainerLowest,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  leading: IconButton(
    icon: Icon(Icons.arrow_back_ios_new, color: colors.onSurface, size: 20),
    onPressed: () { ... },
  ),
  title: Text('Notifications', style: typo.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
  actions: [ TextButton(...) ],  // 保持原有 Clear All
),
```

#### 9. `lib/features/seller/screens/transaction_management_screen.dart`
当前 AppBar：
```dart
appBar: AppBar(
  title: const Text('Manage Transactions'),
  bottom: const TabBar(...),
),
```

改为：
```dart
appBar: AppBar(
  backgroundColor: colors.surfaceContainerLowest,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  leading: IconButton(
    icon: Icon(Icons.arrow_back_ios_new, color: colors.onSurface, size: 20),
    onPressed: () => context.pop(),
  ),
  title: Text('Manage Transactions', style: typo.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
  bottom: const TabBar(...),  // 保持原有 TabBar
),
```

---

## 验证

```bash
flutter analyze
```

## 报告

写入 `.agent/reports/UI-001-report.md`
