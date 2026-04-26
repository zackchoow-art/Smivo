# BUG-004: Buyer Center 页面优化

## 修改文件

**只修改这一个文件：**
- `lib/features/buyer/screens/buyer_center_screen.dart`

## 需求 1：删除视图切换，仅保留列表模式

- 删除 `_isListView` 状态变量（第 18 行）
- 删除右上角的视图切换 IconButton（第 47-51 行）
- 删除 `_buildSection` 中的 `if (_isListView)` 分支（第 129-131 行），保留卡片模式的代码作为唯一展示模式（即保留第 133-164 行的 InkWell 卡片代码）
- 删除整个 `_buildListViewItem` 方法（第 170-202 行）
- 由于删除了切换功能，`ConsumerStatefulWidget` 仍需保留（因为后续需求会添加新的状态变量）

**注意**：保留的是当前卡片视图模式（带图片、商品名、价格的那个），不是 ListTile 模式。

## 需求 2：区域标题改为可折叠 + 样式调整

### 标题样式
- 标题颜色改为黑色（`colors.onSurface`）
- 标题格式：从全大写 `'REQUESTED'` 改为首字母大写 `'Requested'`
- 其他标题同理：`'Awaiting Delivery'`、`'Active Transactions'`、`'History'`

### 可折叠功能
- 为每个区域添加折叠/展开功能
- 添加 state 变量来跟踪每个区域的展开状态，默认全部展开：
  ```dart
  final Map<String, bool> _expandedSections = {
    'Requested': true,
    'Awaiting Delivery': true,
    'Active Transactions': true,
    'History': true,
  };
  ```
- 修改 `_buildSection` 方法的标题行：
  - 点击标题行可以折叠/展开该区域
  - 标题行右侧添加展开/折叠的箭头图标（`Icons.keyboard_arrow_down` / `Icons.keyboard_arrow_up`）
  - 当区域折叠时，隐藏下方的订单列表（SliverList 部分）

### _buildSection 调用处标题更改
```dart
// 修改前
..._buildSection('REQUESTED', requested, Icons.hourglass_top, colors.warning, notifications),
..._buildSection('AWAITING DELIVERY', awaitingDelivery, Icons.local_shipping, colors.primary, notifications),
..._buildSection('ACTIVE TRANSACTIONS', activeTransactions, Icons.sync, colors.success, notifications),
..._buildSection('HISTORY', history, Icons.history, colors.outlineVariant, notifications),

// 修改后
..._buildSection('Requested', requested, Icons.hourglass_top, colors.warning, notifications),
..._buildSection('Awaiting Delivery', awaitingDelivery, Icons.local_shipping, colors.primary, notifications),
..._buildSection('Active Transactions', activeTransactions, Icons.sync, colors.success, notifications),
..._buildSection('History', history, Icons.history, colors.outlineVariant, notifications),
```

### _buildSection 标题行样式修改
```dart
// 修改前
Text('$title (${orders.length})', style: typo.labelSmall.copyWith(
  color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),

// 修改后：黑色标题，可点击
Text('$title (${orders.length})', style: typo.titleMedium.copyWith(
  color: colors.onSurface, fontWeight: FontWeight.w600)),
```

## 需求 3：搜索功能

### UI
- 在页面标题描述文字下方、第一个区域上方添加搜索栏
- 使用 `TextField` + `InputDecoration` + 搜索图标
- 添加 state 变量：`String _searchQuery = '';`
- 搜索框有清除按钮（当有输入内容时显示 X 图标）

### 搜索逻辑
- 搜索时对所有 4 个区域的订单进行筛选
- 当有搜索关键词时，自动展开所有区域（设置所有 `_expandedSections` 值为 true）
- 搜索字段（模糊匹配，不区分大小写）：
  - `order.listing?.title` — 商品名称
  - `order.listing?.description` — 商品描述
  - `order.seller?.displayName` — 卖家姓名
  - `order.buyer?.displayName` — 买家姓名
  - `order.totalPrice.toStringAsFixed(2)` — 订单总价

### 筛选实现位置
在 `data: (orders)` 回调中，先进行搜索过滤，再分类：
```dart
data: (orders) {
  // Search filter
  final filtered = _searchQuery.isEmpty ? orders : orders.where((o) {
    final query = _searchQuery.toLowerCase();
    final title = o.listing?.title?.toLowerCase() ?? '';
    final desc = o.listing?.description?.toLowerCase() ?? '';
    final seller = o.seller?.displayName?.toLowerCase() ?? '';
    final buyer = o.buyer?.displayName?.toLowerCase() ?? '';
    final price = o.totalPrice.toStringAsFixed(2);
    return title.contains(query) || desc.contains(query) || 
           seller.contains(query) || buyer.contains(query) || 
           price.contains(query);
  }).toList();

  final requested = filtered.where(...).toList();
  // ... 其余分类同理使用 filtered 而不是 orders
}
```

## 严格边界

- ❌ 不要修改任何 provider 文件
- ❌ 不要修改 `_StatusChip` 类（第 209-277 行）—— 完全保持不变
- ❌ 不要修改路由导航逻辑
- ❌ 不要修改卡片项的布局（保留当前的 InkWell + Container + Row 结构）
- ❌ 不要修改 Scaffold、SafeArea、RefreshIndicator 结构
- ❌ 不要添加新的 import（除非搜索需要新的 widget）
- ❌ 不要修改任何其他文件

## 验证步骤

```bash
cd /Users/george/smivo && flutter analyze
```

## 执行报告

写入：`.agent/reports/BUG-004-report.md`

报告内容：
1. 修改概述
2. 关键代码变更对比
3. `flutter analyze` 结果
