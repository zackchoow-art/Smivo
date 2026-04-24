# Task 011: Order Detail 页面拆分 + Rental 功能增强

> **状态**: 📋 待实施  
> **创建日期**: 2026-04-24  
> **优先级**: 高  
> **预估工作量**: 大（分 3 批执行）

---

## 架构概览

### 页面拆分策略

```
lib/features/orders/
  screens/
    order_detail_screen.dart            ← 保留为路由入口 (thin dispatcher)
    sale_order_detail_screen.dart        ← NEW: Sale 订单详情
    rental_order_detail_screen.dart      ← NEW: Rental 订单详情
  widgets/
    order_header_card.dart              ← NEW: 共享 listing 信息卡
    order_timeline.dart                 ← NEW: 共享 timeline widget
    order_financial_summary.dart        ← NEW: 共享金额汇总
    order_info_section.dart             ← NEW: 共享订单基本信息
    order_action_buttons.dart           ← NEW: 共享底部操作按钮
    evidence_photo_section.dart         ← EXISTING (保留)
    chat_history_section.dart           ← EXISTING (保留)
    rental_date_section.dart            ← NEW: Rent 专属日期信息
    rental_extension_card.dart          ← NEW: Rent 专属展期申请/审批
    rental_reminder_settings.dart       ← NEW: Rent 专属到期提醒设置
```

### 路由入口 (dispatcher)

```dart
// order_detail_screen.dart — 仅做分发
class OrderDetailScreen extends ConsumerWidget {
  Widget build(context, ref) {
    return orderAsync.when(
      data: (order) => order.orderType == 'rental'
          ? RentalOrderDetailScreen(order: order, ...)
          : SaleOrderDetailScreen(order: order, ...),
    );
  }
}
```

---

## 数据库变更

### 新表：`rental_extensions`

```sql
CREATE TABLE public.rental_extensions (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id       uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  requested_by   uuid NOT NULL REFERENCES auth.users(id),
  request_type   text NOT NULL CHECK (request_type IN ('extend', 'shorten')),
  new_end_date   timestamptz NOT NULL,
  price_diff     numeric(10,2) NOT NULL DEFAULT 0,
  new_total      numeric(10,2) NOT NULL,
  status         text NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending', 'approved', 'rejected')),
  responded_at   timestamptz,
  rejection_note text,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);
```

### Orders 表扩展

```sql
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS reminder_days_before integer DEFAULT 1,
  ADD COLUMN IF NOT EXISTS reminder_email boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS reminder_sent boolean DEFAULT false;
```

---

## Batch 1: 页面拆分 + 共享 Widgets 提取

### Sale 订单页面结构
```
OrderHeaderCard → OrderTimeline(4 steps) → FinancialSummary →
OrderInfoSection → DeliveryStatus → EvidencePhoto → ChatHistory → Actions
```

Cancel 按钮：双方 confirm delivery 后隐藏。

### Rental 订单页面结构
```
OrderHeaderCard → OrderTimeline(8 steps) → FinancialSummary(+rates+deposit) →
OrderInfoSection → RentalDateSection → DeliveryStatus →
EvidencePhoto(delivery) → EvidencePhoto(return) →
RentalExtensionCard → RentalReminderSettings → ChatHistory → Actions
```

---

## Batch 2: 租赁展期功能

### 新增文件
- `rental_extension.dart` — Freezed model
- `rental_extension_repository.dart` — CRUD
- `rental_extension_provider.dart` — Provider
- `rental_extension_card.dart` — 展期 UI
- `00026_rental_extensions.sql` — 数据库迁移

### 业务逻辑
- **展期**: 买家选新日期 → 计算差价 → 提交 → 卖家审批 → 更新订单
- **提前归还**: `request_type='shorten'` → price_diff 为负 → 卖家同意后更新

---

## Batch 3: 到期提醒（Edge Function）

### 新增文件
- `00027_rental_reminders.sql` — orders 表新字段
- `supabase/functions/check-rental-reminders/index.ts` — Edge Function
- `rental_reminder_settings.dart` — 提醒设置 UI

### Cron: 每天 8 AM 检查到期订单，推送通知 + 可选邮件

---

## 执行顺序

| 批次 | 内容 | 文件数 |
|------|------|--------|
| **Batch 1** | 页面拆分 + 共享 widgets + Cancel 隐藏 | ~8 个 |
| **Batch 2** | 展期功能（DB + Model + Repo + Provider + UI） | ~5 个 |
| **Batch 3** | 到期提醒（DB + Edge Function + UI） | ~3 个 |
