# BUG-006: Seller Center 页面改进（参考 Buyer Center 的 BUG-004 + BUG-005）

## 修改文件

**只修改这一个文件：**
- `lib/features/seller/screens/seller_center_screen.dart`

## 参考标准

请参考已完成的 Buyer Center 改进：
- `lib/features/buyer/screens/buyer_center_screen.dart`

## 需求概述

将 Buyer Center 的以下改进同步到 Seller Center：

### 1. 删除视图切换功能

- 删除 `_isListView` 状态变量（第 21 行）
- 删除 Active Listings 标题行右侧的视图切换 IconButton（第 84-88 行）
- 删除 `if (_isListView)` 分支（第 115-117 行），保留 `_buildActiveListingCard` 作为唯一展示模式
- 删除整个 `_buildListViewItem` 方法（第 600-648 行）
- 删除 `_buildMiniStat` 方法（第 650-665 行）（它只被 `_buildListViewItem` 使用）

### 2. 区域标题可折叠 + 样式调整

添加折叠状态 Map：
```dart
final Map<String, bool> _expandedSections = {
  'Active Listings': true,
  'Awaiting Delivery': true,
  'Active Transactions': true,
  'History': true,
};
```

**标题样式修改**：
- 从全大写改为首字母大写：`'Active Listings'`、`'Awaiting Delivery'`、`'Active Transactions'`、`'History'`
- 颜色改为 `colors.onSurface`（黑色）
- 字体改为 `typo.titleMedium.copyWith(color: colors.onSurface, fontWeight: FontWeight.w600)`
- 添加折叠/展开箭头图标
- 点击标题行可折叠/展开

**重要**：Seller Center 的 4 个区域目前是分散在 build 方法中的独立 Sliver 块（不像 Buyer Center 有统一的 `_buildSection` 方法）。你需要将每个区域的标题改为可点击的 InkWell，并在折叠时隐藏下方内容。

每个区域的改造模式：
```dart
// 标题 Sliver
SliverPadding(
  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
  sliver: SliverToBoxAdapter(
    child: InkWell(
      onTap: () => setState(() => _expandedSections['Xxx'] = !(_expandedSections['Xxx'] ?? true)),
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text('Xxx (${count})', style: typo.titleMedium.copyWith(
          color: colors.onSurface, fontWeight: FontWeight.w600))),
        Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 20, color: colors.onSurface.withValues(alpha: 0.5)),
      ]),
    ),
  ),
),
// 内容 Sliver — 仅在展开时显示
if (isExpanded) ...内容...
```

**注意**：
- Active Listings 区域的标题需要显示活跃商品数量，如 `Active Listings (3)`
- Awaiting Delivery / Active Transactions / History 区域需要显示订单数量
- 区域内容为空时不显示该区域（保持当前行为），**但空状态文字也应该被折叠控制**

### 3. 添加搜索功能

在页面标题描述文字下方添加搜索栏（与 Buyer Center 风格一致）。

添加 state 变量：`String _searchQuery = '';`

搜索栏 UI：
```dart
const SizedBox(height: 12),
TextField(
  onChanged: (value) {
    setState(() {
      _searchQuery = value;
      if (value.isNotEmpty) {
        for (final key in _expandedSections.keys) {
          _expandedSections[key] = true;
        }
      }
    });
  },
  decoration: InputDecoration(
    hintText: 'Search orders and listings…',
    prefixIcon: const Icon(Icons.search, size: 20),
    suffixIcon: _searchQuery.isNotEmpty 
      ? IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => setState(() => _searchQuery = ''))
      : null,
    ...（样式与 Buyer Center 一致）
  ),
),
```

搜索范围：
- **Active Listings**：`listing.title`、`listing.description`、`listing.price`
- **Order 卡片**（Awaiting Delivery / Active Transactions）：`order.listing?.title`、`order.buyer?.displayName`、`order.totalPrice`
- **History 区域**：`item.title`、`item.subtitle`

搜索时自动展开所有区域。

### 4. 卡片样式统一（参考 BUG-005）

**Order 卡片（_buildOrderCard）**：
- 当前已有较好的结构，不做大改
- 但注意 `statusLabel` 的容器目前是半透明背景+彩色文字，请改为与 Buyer Center 一致：**不透明背景色 + 页面背景色文字 (`colors.surfaceContainerLowest`)**
- 添加 `minWidth: 72` 统一状态标签宽度
- 状态文字居中 `textAlign: TextAlign.center`

## 严格边界

- ❌ 不要修改任何 provider 文件
- ❌ 不要修改 `_HistoryItem` 类（保持不变）
- ❌ 不要修改 `_showMergedCancelledDetails` 方法
- ❌ 不要修改路由导航逻辑
- ❌ 不要修改 History 区域的合并逻辑（cancelledByListing、completedOrders、delistedListings 的分类逻辑）
- ❌ 不要修改任何其他文件
- ❌ 不要修改 Scaffold、SafeArea、RefreshIndicator 结构

## 验证步骤

```bash
cd /Users/george/smivo && flutter analyze
```

## 执行报告

写入：`.agent/reports/BUG-006-report.md`
