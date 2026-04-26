# BUG-004 执行报告

## 执行时间
2026-04-26

## 1. 修改概述

**仅修改文件**：`lib/features/buyer/screens/buyer_center_screen.dart`

完成了 3 项需求：
- **需求 1**：删除视图切换功能（`_isListView`、视图切换 IconButton、`if (_isListView)` 分支、`_buildListViewItem` 方法）
- **需求 2**：区域标题改为首字母大写 + 黑色 + 可点击折叠/展开（含箭头图标）
- **需求 3**：在标题描述下方添加搜索栏，支持按商品名/卖家名/买家名/价格搜索，搜索时自动展开所有区域

---

## 2. 关键代码变更对比

### 删除：`_isListView` 状态变量

```dart
// 删除前
bool _isListView = false;

// 删除后（新增两个变量替代）
final Map<String, bool> _expandedSections = {
  'Requested': true,
  'Awaiting Delivery': true,
  'Active Transactions': true,
  'History': true,
};
String _searchQuery = '';
```

### 删除：右上角视图切换按钮

```dart
// 删除前（第 47-51 行）
IconButton(
  icon: Icon(_isListView ? Icons.grid_view_outlined : Icons.list_outlined, ...),
  onPressed: () => setState(() => _isListView = !_isListView),
),

// 删除后：Row 内只保留返回按钮，无切换 IconButton
```

### 新增：搜索栏（标题描述下方）

```dart
TextField(
  onChanged: (value) {
    setState(() {
      _searchQuery = value;
      // Auto-expand all sections during search
      if (value.isNotEmpty) {
        for (final key in _expandedSections.keys) {
          _expandedSections[key] = true;
        }
      }
    });
  },
  decoration: InputDecoration(
    hintText: 'Search by item, seller, or price…',
    prefixIcon: const Icon(Icons.search, size: 20),
    suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.close), ...) : null,
  ),
),
```

### 修改：搜索过滤 + 分类逻辑

```dart
// 修改前：直接用 orders 分类
final requested = orders.where((o) => o.status == 'pending').toList();

// 修改后：先过滤，再分类
final filtered = _searchQuery.isEmpty ? orders : orders.where((o) {
  final query = _searchQuery.toLowerCase();
  final title = o.listing?.title.toLowerCase() ?? '';
  // ... seller, buyer, price
  return title.contains(query) || ...;
}).toList();
final requested = filtered.where((o) => o.status == 'pending').toList();
```

### 修改：`_buildSection` 调用处标题

```dart
// 修改前
..._buildSection('REQUESTED', ...),
..._buildSection('AWAITING DELIVERY', ...),
..._buildSection('ACTIVE TRANSACTIONS', ...),
..._buildSection('HISTORY', ...),

// 修改后
..._buildSection('Requested', ...),
..._buildSection('Awaiting Delivery', ...),
..._buildSection('Active Transactions', ...),
..._buildSection('History', ...),
```

### 修改：`_buildSection` 标题行样式 + 折叠逻辑

```dart
// 修改前：纯 Row，labelSmall 灰色
Text('$title (${orders.length})', style: typo.labelSmall.copyWith(
  color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),

// 修改后：InkWell 可点击，titleMedium 黑色，右侧箭头图标
InkWell(
  onTap: () => setState(() => _expandedSections[title] = !isExpanded),
  child: Row(children: [
    Icon(icon, ...),
    Expanded(child: Text('$title (${orders.length})', style: typo.titleMedium.copyWith(
      color: colors.onSurface, fontWeight: FontWeight.w600))),
    Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, ...),
  ]),
),

// 折叠时隐藏列表
if (isExpanded)
  SliverPadding(...SliverList...),
```

### 删除：整个 `_buildListViewItem` 方法（共 33 行）

---

## 3. 说明：`isCompact` 参数 warning

`_StatusChip.isCompact` 参数是在 `_buildListViewItem` 中使用的（`isCompact: true`）。该方法删除后，`isCompact` 不再被外部调用，触发 `unused_element_parameter` warning。

由于任务文件明确要求 **"不要修改 `_StatusChip` 类"**，此 warning 被保留，符合任务约束。`_StatusChip` 全类代码与原版完全一致。

---

## 4. `flutter analyze` 结果

```
Analyzing buyer_center_screen.dart...

warning • A value for optional parameter 'isCompact' isn't ever given •
       lib/features/buyer/screens/buyer_center_screen.dart:245:48 •
       unused_element_parameter

1 issue found.
```

- **Error 数量：0**
- **Warning 数量：1**（因任务文件禁止修改 `_StatusChip`，属预期内保留 warning）
