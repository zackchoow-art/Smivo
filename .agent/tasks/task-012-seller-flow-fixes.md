# Task 012: Seller 业务逻辑修复 + 邮件通知

> **状态**: 📋 待确认  
> **创建日期**: 2026-04-24  
> **优先级**: 高

---

## 排查结果

### ❌ 1. Sale：accept 后未自动下架

**现状**：`acceptOrder()` 只做了：
- 更新订单状态为 `confirmed`
- 取消同一 listing 的其他 pending 订单

**缺失**：没有把 listing status 改为 `sold`（或 `inactive`）。
Home 页 `fetchListings()` 只筛选 `status == 'active'`，所以如果不改 status，
商品仍然会在首页展示。

**修复方案**：
- `acceptOrder()` 增加判断：如果 `order.orderType == 'sale'`，
  调用 `listingRepo.updateStatus(listingId, 'sold')`
- listing_detail_screen：delist 按钮已有 `if (listing.status == 'active')` 条件，
  listing 变为 `sold` 后按钮自动隐藏 ✅

### ❌ 2. Rental：accept 后不应下架，双方 confirm delivery 后才下架

**现状**：`acceptOrder()` 没有改 listing status（✅ 不下架是正确的）。
但双方 confirm delivery 后也没有下架。

**修复方案**：
- `confirmDelivery()` 中，当 rental 双方都确认后（激活 rental status = active），
  同时把 listing status 改为 `rented`
- delist 按钮：listing status 不是 `active` 时已自动隐藏 ✅

### ❌ 3. Seller Center：缺少「待交货」区域

**现状**：只有 3 个区域：
1. Active Listings（status == 'active'）
2. Active Transactions（status == 'confirmed' 或 rentalStatus 进行中）
3. History（completed + cancelled + delisted）

**问题**：Active Transactions 的筛选条件 `status == 'confirmed'` 其实已经包含了
「等待交货」的订单。但 UI 上没有区分「等待交货」和「正在进行中的租赁」。

**修复方案**：拆分 Active Transactions 为两个子区域：
- **AWAITING DELIVERY** — `status == 'confirmed'` 且交货未完成
  （即 `!(deliveryConfirmedByBuyer && deliveryConfirmedBySeller)`）
- **ACTIVE TRANSACTIONS** — rental active/return 相关状态

### ❌ 4. History 合并逻辑

**现状**：每个 cancelled 订单独立显示一条记录。

**需求**：
- 如果卖家 delist 商品导致 3 笔订单全被取消 → 合并为 1 条记录，显示统计数据
- 如果卖家 accept 了某个买家导致其他 2 笔被取消 → 暂不显示这 2 笔被取消的，
  等到最终交易完成（或被 accept 的那笔也取消）后再合并显示

**实现方案**：
- 按 listing_id 分组 cancelled 订单
- 如果同一 listing 有 confirmed/completed 订单存在 → 先不展示 cancelled 的
- 如果同一 listing 只有 cancelled 订单 → 合并显示 1 条
- 点击可显示该 listing 的 views/saves/offers 统计

### ❌ 5. 邮件通知系统

**现状**：
- `notification_settings_screen.dart` 有 UI 但 toggles 是纯本地 state
  （没有持久化到 DB）
- 没有 `email_notifications_enabled` 字段在 `user_profiles` 表
- 没有邮件发送逻辑

**修复方案**（分步）：
- Step 1: `user_profiles` 加 `email_notifications_enabled boolean DEFAULT true`
- Step 2: 所有通知触发器中，检查该字段，如果为 true 则额外调用邮件 API
- Step 3: notification_settings_screen 的「Email Notifications」toggle 持久化
- Step 4: 实际邮件发送（Supabase Edge Function + Resend/SendGrid）→ 先标记 TODO，
  当前只在 DB 记录 email_queued 状态

---

## 执行文件列表

| 文件 | 操作 | 内容 |
|------|------|------|
| `orders_provider.dart` | MODIFY | acceptOrder: sale 自动 sold；confirmDelivery: rental 自动 rented |
| `listing_repository.dart` | MODIFY | 新增 `updateListingStatus(id, status)` 方法 |
| `seller_center_screen.dart` | MODIFY | 拆分 Awaiting Delivery + Active Transactions；History 合并 |
| `00029_email_notifications.sql` | CREATE | user_profiles 加字段 + 通知触发器更新 |
| `user_profile.dart` | MODIFY | 新增 emailNotificationsEnabled 字段 |
| `notification_settings_screen.dart` | MODIFY | Email toggle 持久化 |
| `profile_repository.dart` | MODIFY | 新增 updateEmailPref 方法 |
