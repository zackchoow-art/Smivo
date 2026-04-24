# Task 007 Report: Optimize Manage Transactions Page

## 修改的文件列表及摘要

1.  **lib/data/repositories/order_repository.dart**
    *   新增 `cancelOtherPendingOrders` 方法：当一个订单被接受时，自动将该 listing 下的其他所有 pending 订单状态更新为 `cancelled`。

2.  **lib/features/orders/providers/orders_provider.dart**
    *   更新 `OrderActions.acceptOrder` 方法：现在会先获取订单详情以获取 `listingId`，在接受当前订单后，自动调用 `cancelOtherPendingOrders` 逻辑，实现“一键成交，其他置灰”的效果。

3.  **lib/features/seller/screens/transaction_management_screen.dart**
    *   **重命名**：将 Tab 标签从 "Orders" 改为 "Offers"，并重构了内部类名（`_OrdersTab` -> `_OffersTab`）。
    *   **initialTab 支持**：新增 `initialTab` 参数，支持通过路由直接跳转到指定的 Tab（Views/Saves/Offers）。
    *   **UI 统一**：重构了 Views、Saves 和 Offers 三个 Tab 的卡片布局，使用统一的 `Container` 装饰，包含头像、姓名、评价占位符、时间戳及私聊按钮。
    *   **风格修正**：移除了 HACK 代码，全面使用 `ThemeExtension` (`context.smivoColors`, `context.smivoTypo`, `context.smivoRadius`)。针对 Offers Tab，使用了 `Container` 和 `GestureDetector` 以增强 Material 稳定性。
    *   **接受流程**：实现了 Accept 按钮的二次确认弹窗，确认后执行接受逻辑并自动返回 Seller Center。
    *   **私聊集成**：集成了 `showChatPopup`，支持从订单卡片直接发起私聊。

4.  **lib/features/listing/screens/listing_detail_screen.dart**
    *   **Stats 增强**：将 "Inquiries" 重命名为 "Offers"，并使 "Views"、"Saves"、"Offers" 三个统计卡片均可点击，点击后跳转至管理页面的相应 Tab。
    *   **清理**：移除了冗余的 "Manage Transactions" 按钮，使 UI 更加简洁。

5.  **lib/core/router/router.dart**
    *   更新路由配置：支持从 query parameter 中解析 `tab` 参数并传递给 `TransactionManagementScreen`。

## 未完成项目
*   无。所有要求的功能已全部实现并测试通过。

## Flutter Analyze 结果
*   **No issues found!** (所有 lint 错误及主题属性引用错误已修复)
