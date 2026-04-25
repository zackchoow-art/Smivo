# Task 020: 租期调整功能（新业务逻辑）

## 分配给: Gemini 3.1 Pro High
## 复杂度: ⭐⭐⭐⭐⭐
## 依赖: T-019 完成后再开始

## 概述
为租赁订单增加「调整租期」功能，允许买家在租期内申请延长或缩短租期，卖家审批。

## 涉及文件（需新建 + 修改）

### 新建文件
1. `supabase/migrations/00031_rental_adjustments.sql` — 数据库表
2. `lib/data/models/rental_adjustment.dart` — Model
3. `lib/features/orders/widgets/rental_adjustment_section.dart` — UI Widget
4. `lib/features/orders/providers/rental_adjustment_provider.dart` — Provider

### 修改文件
1. `lib/data/repositories/order_repository.dart` — 增加 CRUD 方法
2. `lib/features/orders/screens/rental_order_detail_screen.dart` — 集成 widget

## 数据库设计

```sql
CREATE TABLE rental_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  requested_by UUID NOT NULL REFERENCES auth.users(id),
  -- 调整前
  original_quantity INT NOT NULL,
  original_rate_type TEXT NOT NULL, -- 'daily'/'weekly'/'monthly'
  original_start_date TIMESTAMPTZ NOT NULL,
  original_end_date TIMESTAMPTZ NOT NULL,
  original_rental_price NUMERIC(10,2) NOT NULL,
  -- 调整后
  new_quantity INT NOT NULL,
  new_start_date TIMESTAMPTZ NOT NULL,
  new_end_date TIMESTAMPTZ NOT NULL,
  new_rental_price NUMERIC(10,2) NOT NULL,
  price_difference NUMERIC(10,2) NOT NULL, -- 正=加钱, 负=退款
  -- 审批
  status TEXT NOT NULL DEFAULT 'pending', -- pending/approved/rejected
  reviewed_by UUID REFERENCES auth.users(id),
  reviewed_at TIMESTAMPTZ,
  -- 时间戳
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS: 买家和卖家都能读取自己订单的调整记录
-- 买家可以创建调整申请
-- 卖家可以审批
```

## 前端逻辑

### 买家视角 — 提交调整申请
1. 显示「Adjust Rental Period」按钮（仅 `rental_status == 'active'` 的租赁订单）
2. 点击展开调整面板：
   - 显示当前租赁方式（日/周/月，不可修改）
   - 数量选择器（+/- 按钮）
   - 自动计算新的结束日期
   - 显示调整天数 + 新总金额
   - 「Submit Adjustment Request」按钮
3. 提交成功：绿色对勾 SnackBar + 刷新页面

### 卖家视角 — 审批调整
1. 如果有 pending 调整申请，在 Order Detail 中显示调整详情区域：
   - 提交时间
   - 新租期 (起始日 → 结束日)
   - 调整天数
   - 金额变化（缩期显示红色负数）
   - 新的租金总额（含押金）
2. 两个按钮：Accept / Reject
3. Accept：更新 `orders` 表的 `rental_end_date` 和 `total_price` + 更新调整状态为 approved
4. Reject：更新调整状态为 rejected

### Timeline 集成
调整申请被提交/批准/拒绝时，自动在 Timeline 显示对应事件。

## 项目架构参考
- 参考 `lib/data/repositories/order_repository.dart` 的方法风格
- Provider 使用 `@riverpod` 代码生成
- Model 使用 `freezed`
- 所有 UI 使用主题 token

## 验证
```bash
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```
必须零错误。
