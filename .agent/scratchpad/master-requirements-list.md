# Smivo 项目修改需求清单 (Master Requirements List)

版本：v3.0
日期：2026-04-23
状态：✅ 全部完成

---

## 1. 卖家统计与"交易管理"页面 ✅ (Task 013, 015)
*   ✅ **入口按钮**：在商品详情页的卖家专属统计区域下方，新增"交易管理"按钮。
*   ✅ **独立页面实现**：导航至三 Tab 页面（Views / Saves / Orders）。
*   ✅ **分区统计与列表穿透**：
    *   ⏳ **查看 (Views)**：占位——需 `listing_views` 表支持（Phase 2）。
    *   ✅ **收藏 (Saves)**：显示收藏用户列表及时间。
    *   ✅ **下单 (Orders)**：显示买家信息、下单时间、状态标签。
*   ✅ **核心操作**：待处理申请显示"Accept"按钮，一键接受。

## 2. 商品详情页 - 状态逻辑与 UI 优化 ✅ (Task 008-012)
*   ✅ **买家下单状态**：已提交申请时，按钮替换为"Application Submitted"卡片。
*   ✅ **收藏功能**：Save 按钮已激活；发布者本人隐藏。
*   ✅ **UI 修正**：
    *   ✅ 固定返回按钮位置。
    *   ✅ 图片标签改为成色显示。
    *   ✅ "about this item" → "DESCRIPTION"，移至名称下方。
    *   ✅ 移除"Smith College Campus"冗余文本。
*   ✅ **布局修复**：Rental Period + Total 金额行改为两行 Column 布局。

## 3. 卖家中心 ✅ (Task 013)
*   ✅ **架构定义**：独立为 `SellerCenterScreen`。
*   ✅ **上架商品分区**：显示活跃商品（含 View 统计），可点击进入详情。
*   ✅ **已成交商品分区**：展示 completed/cancelled 订单历史。

## 4. 买家中心 ✅ (Task 014)
*   ✅ **架构定义**：独立为 `BuyerCenterScreen`。
*   ✅ **求购区 (Requested)**：pending 状态订单。
*   ✅ **已买到商品区 (Active/History)**：confirmed + completed/cancelled。
*   ✅ **状态标签**：Pending / Active / Done / Missed。

## 5. 租赁订单逻辑修复 ✅ (Task 016)
*   ✅ **状态流转**：双方确认收货后进入 `rental_status: active`。
*   ✅ **生命周期**：active → return_requested → returned → deposit_refunded → completed。
*   ✅ **DB Migration**：`00019_rental_lifecycle.sql` 已执行。

## 6. 订单详情、快照与安全性 ✅ (Task 017, 018, 019)
*   ✅ **租赁详情**：财务汇总卡片显示 type、rates、deposit、total。
*   ✅ **拍照取证功能**：最多 5 张取证照片，存储于 `order-evidence` bucket。
*   ✅ **详细快照页**：
    *   ✅ 全流程时间轴（Order Placed → Accepted → Delivered → Returned）。
    *   ✅ 财务汇总卡片。
    *   ✅ 位置信息 (Pickup Location)。
    *   ✅ 照片证据画廊。
    *   ✅ 可折叠聊天记录。
*   ⏳ **取消锁定**：确认收货后锁定取消权限（Phase 2 安全加固）。

## 7. 产品发布页 ✅ (Task 009)
*   ✅ **视觉简化**：移除顶部标题及假消息图标。
*   ✅ **功能裁剪**：移除置顶选项及费用计算。

---

## 剩余待做项 (Phase 2)
- [ ] Views 用户穿透（需 `listing_views` 表记录具体浏览者）
- [ ] 确认收货后锁定取消权限
- [ ] 私信按钮（交易管理页面 → 打开与该用户的 chat）
