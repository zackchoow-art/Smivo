# Smivo 用户身份组件重构与在线状态实施方案

**文档状态**：草案 / 待评审
**文档目的**：统一全 App 用户展示逻辑，实现“零代码”快速变更在线状态显示及用户信息交互。

## 1. 调查背景与现状总结
目前的 Smivo App 在展示用户信息（头像、名称、邮件）时存在高度碎片化：
- **硬编码占比 > 90%**：绝大多数页面（聊天、订单、卖家中心、管理端）通过直接读取 `user` 属性构建 UI。
- **组件不统一**：现有的 `SellerProfileCard` 耦合度高，无法在订单或聊天场景复用。
- **统计失效**：由于 App 未调用心跳 RPC，目前的在线状态依赖于 `user_profiles` 的字段同步，但 UI 缺乏直观反馈。

## 2. 重构目标：SmivoUserIdentity 系统
我们将构建一个分层的组件系统，替代所有硬编码位置。

### A. 原子组件：`SmivoUserAvatar` (仅头像卡片)
- **视觉逻辑**：
  - **在线**：头像为彩色 + 右上角/右下角显示绿点。
  - **离线**：头像应用灰度滤镜 (Grayscale) + 显示灰点。
- **交互逻辑**：
  - **点击头像**：触发弹出底部的“用户信息抽屉 (User Info Drawer)”。
  - *注：此交互将替换目前“点击评分弹出”的旧逻辑。*
- **最后在线时间**：内置时间计算逻辑（如：5 分钟内为在线）。

### B. 复合组件：`SmivoUserIdentity` (头像 + 文本)
- **模式 1：头像 + 名称**
  - 使用 `SmivoUserAvatar` 作为子组件。
  - 侧边展示 `displayName`。
- **模式 2：完整信息模式**
  - 使用 `SmivoUserAvatar` 作为子组件。
  - **布局调整**：将“用户最后上线时间”移动至与“用户评分”同一行，位置对齐在“消息图标”下方。
- **可定制化**：
  - **背景控制**：支持通过参数（如 `backgroundColor`, `useCardWrapper`）控制背景颜色和边框，以适配搜索列表、订单中心、商品详情等不同背景色。

## 3. 特定场景适配要求

### 订单详情页 (Order Details)
- **需求**：保留身份标签描述。
- **实施方案**：在替换 `order_info_section.dart` 中的用户信息块时，必须确保左侧的“买家/卖家”身份标签容器不被修改。新的 `SmivoUserIdentity` 组件将作为该容器右侧的内容插入。

### 抽屉组件 (User Info Drawer)
- **演进路线**：初期作为点击头像的唯一弹出反馈。目前先整合现有评分、基础信息。今后将以此为中心不断完善（如增加勋章、学校验证状态等）。

## 4. 实施清单 (部分)
- [ ] 创建 `app/lib/shared/widgets/user_avatar.dart` (原子头像)
- [ ] 创建 `app/lib/shared/widgets/user_identity_card.dart` (复合名片)
- [ ] 重构 `app/lib/features/orders/widgets/order_info_section.dart` (适配身份标签)
- [ ] 重构 `app/lib/features/listing/widgets/seller_profile_card.dart` (调整最后上线时间位置)
- [ ] 全局搜索并替换 17 处硬编码的 `CircleAvatar`。
