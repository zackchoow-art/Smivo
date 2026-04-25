# Task 021: Missed 状态 + 通知 Badge

## 分配给: Gemini 3.1 Pro High
## 复杂度: ⭐⭐⭐
## 可与 Flash 任务并行执行

## 概述
三个子任务：
1. 竞争失败的订单从 `cancelled` 改为 `missed`
2. 底部导航栏 Orders 按钮显示 badge 数字
3. Buyer/Seller Center 入口显示待处理数量

## 涉及文件

### 新建
- `supabase/migrations/00032_missed_order_status.sql`

### 修改
- `lib/features/orders/providers/orders_provider.dart` — 添加 unread count provider
- `lib/shared/widgets/main_scaffold.dart`（或底部导航栏所在文件）— badge 显示
- `lib/features/orders/screens/orders_hub_screen.dart` — Buyer/Seller Center 卡片上显示数量
- `lib/features/buyer/screens/buyer_center_screen.dart` — 在 section headers 显示数量

## 修改清单

### A. SQL Migration: missed 状态
```sql
-- 00032_missed_order_status.sql

-- 1. 更新 check constraint 允许 'missed' 状态
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check
  CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'missed'));

-- 2. 更新 accept_order 函数：将同一 listing 的其他 pending 订单标记为 missed（非 cancelled）
CREATE OR REPLACE FUNCTION accept_order_and_reject_others(
  p_order_id UUID,
  p_listing_id UUID
) RETURNS VOID AS $$
BEGIN
  -- Accept the chosen order
  UPDATE orders SET status = 'confirmed', updated_at = now()
  WHERE id = p_order_id AND status = 'pending';

  -- Mark other pending orders for the same listing as missed
  UPDATE orders SET status = 'missed', updated_at = now()
  WHERE listing_id = p_listing_id
    AND id != p_order_id
    AND status = 'pending';

  -- Create notifications for missed orders
  INSERT INTO notifications (user_id, title, body, action_type, related_order_id)
  SELECT buyer_id, 'Offer Missed', 'Another buyer was selected for this item.', 'order', id
  FROM orders
  WHERE listing_id = p_listing_id
    AND id != p_order_id
    AND status = 'missed';
END;
$$ LANGUAGE plpgsql;
```

注意：需要检查当前 `acceptOrder` 在 provider/repository 中是如何调用的。如果用的是直接 UPDATE 而不是函数调用，需要创建这个函数并在 repository 中改为调用它。

### B. 通知 Badge — 底部导航栏
1. 创建一个 provider 统计未读订单动态数：
```dart
@riverpod
Future<int> unreadOrderUpdatesCount(Ref ref) async {
  // 统计 notifications 表中 action_type == 'order' 且 is_read == false 的数量
}
```

2. 在底部导航栏的 Orders 图标上加 `Badge` widget：
```dart
Badge(
  isLabelVisible: count > 0,
  label: Text('$count'),
  child: Icon(Icons.receipt_long_outlined),
)
```

### C. Buyer/Seller Center 入口卡片数量
在 Orders Hub 页面的 Buyer Center / Seller Center 卡片上，显示各自的待处理订单数。

### D. 订单列表红点
在 BuyerCenter 和 SellerCenter 的订单列表中，对有未读通知的订单显示红点。

## 项目架构参考
- 通知 provider：`lib/features/notifications/providers/notification_provider.dart`
- 订单 provider：`lib/features/orders/providers/orders_provider.dart`
- 底部导航栏：搜索 `BottomNavigationBar` 或 `NavigationBar` 找到所在文件
- 当前 acceptOrder 逻辑：查看 `orders_provider.dart` 中的 `acceptOrder` 方法

## 验证
```bash
flutter analyze
```
必须零错误。SQL migration 文件创建后由用户手动执行。
