# BUG-006 Execution Report: Seller Center Refactor

## 核心任务完成情况

1. **移除视图切换功能**：
   - 移除了 `_isListView` 状态变量。
   - 删除了相关的网格/列表切换按钮。
   - 移除了仅由列表视图使用的遗留方法 `_buildListViewItem` 和 `_buildMiniStat`。

2. **改造四大区域为可折叠标题**：
   - 引入了 `_expandedSections` 状态 `Map`，用于管理四大部分（Active Listings, Awaiting Delivery, Active Transactions, History）的展开和折叠。
   - 使用了 `SliverMainAxisGroup` 组合原本分散的 Slivers，使得每个分类成为一个连贯的分组。
   - 添加了 `InkWell` 包装的头部（Header），使用了 `colors.surface` 和一致的排版（加粗的首字母大写黑色文字 `typo.titleMedium`），并包含动态统计数字及折叠指示箭头 (`keyboard_arrow_down` / `keyboard_arrow_up`)。
   - 各个内容区域现在被包在一个 `if (isExpanded)` 块中，使得点击标题时能够动态隐藏或显示下方内容。

3. **增加全局搜索功能**：
   - 在页面顶部的描述文字下方引入了 `TextField`（搜索框），具有统一的主题样式（带有边框、前置搜索图标和后置清除按钮）。
   - 搜索框实时改变 `_searchQuery` 状态。
   - 搜索会根据情况动态过滤订单（按 Title, Buyer Name, Price）和 Listings（按 Title, Description, Price），并且当搜索被触发时，会自动触发展开所有区域，便于查找。

4. **规范 statusLabel 的样式**：
   - 在 `_buildOrderCard` 中修改了状态标签。
   - 将 Container 的背景从带透明度的色彩改为了全不透明的主题色 (`colors.primary`)。
   - 将文本的颜色从主题色调整为了页面背景色 (`colors.surfaceContainerLowest`)，从而与 Buyer Center 中的状态标签（实心背景+纯色文字）样式完全对齐。
   - 附加了 `minWidth: 72` 约束以确保短文本下的样式一致性。

## 代码质量检查

- **编译无误**：重构后的 `lib/features/seller/screens/seller_center_screen.dart` 成功执行了 `flutter analyze`，并且输出了 `No issues found!`。
- **架构对齐**：通过本次更新，Seller Center 与 Buyer Center 在交互模型和视觉样式上实现了深度的统一，为以后功能扩展奠定了更加稳定的 UI 基础。
