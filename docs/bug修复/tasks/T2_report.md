# 任务报告：Rent/Sale 商品下单前状态检测 (T2)

## 任务目标
在 `listing_detail_screen.dart` 中，买家点击下单按钮（Sale 和 Rent 通用按钮）时，实时从后端拉取商品最新状态。如果商品已下架（status != 'active'），则停止下单逻辑，并提示用户且刷新页面。

## 修改内容
### 1. `app/lib/features/listing/screens/listing_detail_screen.dart`
- **新增逻辑**：在下单按钮的 `onPressed` 回调开头添加了异步状态检查。
    - 使用 `listingRepositoryProvider.fetchListing(id)` 获取最新数据。
    - 增加了 `try-catch` 块以处理商品可能已被删除（404）的情况。
    - 如果 `status != 'active'`，显示 SnackBar 提示 "This item is no longer available"。
    - 调用 `ref.invalidate(listingDetailProvider(widget.id))` 刷新页面以显示最新状态。
- **异步安全处理**：
    - 在异步检查后增加了 `if (!context.mounted) return;`，以防止后续使用 `BuildContext` 时触发 `use_build_context_synchronously` 警告。

## 验证结果
- **代码完整性**：运行 `flutter analyze` 验证通过。
- **分析输出**：目前的分析结果显示 13 个 issues，均为本次任务前的既有预存问题（如弃用成员、未加花括号等），未引入任何新问题。
- **逻辑覆盖**：本次修改同时覆盖了 Sale 和 Rent 商品，因为它们共用同一个下单按钮的回调逻辑。

## 注意事项
- 本修改通过 `listingRepositoryProvider` 直接访问数据库，确保了状态检查的实时性。
- 如果网络连接失败，系统会默认将商品视为不可用，以保护买家不会向已失效的商品发起请求。
