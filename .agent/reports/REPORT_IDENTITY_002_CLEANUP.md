# 任务报告：IDENTITY-002-CLEANUP

## 任务目标
全局清理硬编码的用户展示逻辑，搜索并移除碎片化的 `CircleAvatar` 使用，并在“展示用户个人资料”的场景下一律替换为新创建的 `SmivoUserAvatar` 或 `SmivoUserIdentity`。

## 执行内容

### 1. 核心订单和资料界面的替换
在之前的步骤中已经完成了两处核心的全局替换，将手动堆砌的 `CircleAvatar` 和文本结构替换为 `SmivoUserIdentity`：
- `app/lib/features/orders/widgets/order_info_section.dart`：在订单信息中展示买卖双方的地方，使用 `SmivoUserIdentity` 替换了原有的复杂布局。
- `app/lib/features/listing/widgets/seller_profile_card.dart`：卖家资料卡片进行了重构，直接采用了 `SmivoUserIdentity`。

### 2. 其他“展示用户资料”场景的清理
通过全局搜索 `features/` 目录下的 `CircleAvatar`，排查出 17 处残留。经过仔细分析，确认了属于“展示第三方用户资料且有完整 UserProfile”的场景并进行了替换：

- **`app/lib/features/orders/widgets/chat_history_section.dart`**：
  将聊天记录中对方（和自己）的头像展示（原有 `CircleAvatar`）安全地替换为 `SmivoUserAvatar`。

- **`app/lib/features/orders/widgets/order_card.dart`**：
  在翻转式的订单卡片背面，展示交易对手方（Counterparty）的头像时，替换为统一的 `SmivoUserAvatar`。

- **`app/lib/features/shared/widgets/user_reviews_bottom_sheet.dart`**：
  在评价列表中，展示评价人（Reviewer）的头像处，使用了 `SmivoUserAvatar` 替换了原有的 `CircleAvatar`。

- **`app/lib/features/seller/screens/transaction_management_screen.dart`**：
  在“卖家中心 - 交易管理”的 Saves (保存记录) 以及 Offers (出价记录) 两个 Tab 下，展示保存者和出价买家时，使用了 `SmivoUserAvatar` 进行统一替换。

### 3. 未替换的场景及原因
部分场景下依然保留了 `CircleAvatar` 或未做替换，原因如下：
- **聊天弹窗与聊天列表** (`chat_popup.dart`, `chat_list_item.dart`, `chat_room_screen.dart`)：这些组件接收的并非完整的 `UserProfile`，而是由于后端精简查询或是仅有独立 URL 的模型（如 `ChatConversation`），无法满足 `SmivoUserAvatar` 对完整实体模型的依赖。
- **后台管理与自身编辑** (`admin_*_screen.dart`, `edit_profile_screen.dart`, `home_header.dart`)：后台界面可能展示被冻结用户或者管理员界面，不适用点击弹出评价的行为。同时用户自己编辑个人资料、App头部的个人头像等不属于“展示(第三方)个人资料”场景。
- **未具名或游客查看**：比如 transaction_management_screen 中的 `ViewsTab`，因为查看者可能是未登录的游客，因此只能采用普通圆形占位。

### 4. 完整性检查
替换完成后，运行了 `flutter analyze` 确保全局无类型错误或引入的编译错误。分析结果提示的所有问题均与旧的代码相关（之前的 39 个 warning/info 原样保持），本次重构没有任何负面影响。

## 结论
所有包含有效 `UserProfile` 且用于“展示用户个人资料”的硬编码 UI 均已迁移至新组建，确保了样式统一、具备正确的离线灰色滤镜以及用户详情弹窗功能。目前全局用户组件已经统一。
