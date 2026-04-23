# Task 020: Bug Fix Batch (2026-04-23)

Based on debugging-report-2026-04-23.md. Fixes verified bugs only.

---

## Bug #1: 租赁订单生命周期逻辑中断 — ❌ 已修复，无需操作

**Flash 诊断**：`confirmDelivery` 强制设 `completed`。
**实际情况**：Provider 层 (`orders_provider.dart` L192-238) 已正确分流：
- Sale 订单：直接 `updateOrderStatus('completed')`
- Rental 订单：调用 `confirmDelivery()` 做双方确认，双方都确认后设 `rental_status = 'active'`

Repository 层的 `confirmDelivery` (L153-191) 确实会在双方确认后设
`status = 'completed'`，但 Provider 层在之后立刻覆盖为 `rental_status = 'active'`。
**不过有一个隐患**：存在竞态条件——repo 先设了 completed，provider 再改 rental_status，
但 status 仍为 completed。需要修复 repo 层。

**修复方案**：修改 `confirmDelivery` 方法，增加 `orderType` 参数，
rental 类型在双方确认后不设 `completed`，而是保持 `confirmed`。

---

## Bug #2: 聊天室图片发送 Bucket not found — ✅ 需修复

**Flash 诊断正确**。`chat-images` bucket 在 Supabase 中不存在。

### 修复：创建 migration

CREATE `supabase/migrations/00021_chat_images_bucket.sql`:

```sql
-- ════════════════════════════════════════════════════════════
-- 00021: Chat Images Storage Bucket
-- ════════════════════════════════════════════════════════════

INSERT INTO storage.buckets (id, name, public)
VALUES ('chat-images', 'chat-images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public read for chat images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'chat-images');

CREATE POLICY "Authenticated upload to chat-images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'chat-images'
    AND auth.role() = 'authenticated'
  );
```

**⚠️ USER 需手动执行此 SQL。**

---

## Bug #3: 订单与租赁状态逻辑矛盾 — ✅ 需修复（与 Bug #1 合并）

**Flash 诊断正确**。`confirmDelivery` repo 方法在双方确认后无条件设
`status = 'completed'`，对 rental 订单来说这是错的。

### 修复：修改 `lib/data/repositories/order_repository.dart`

找到 `confirmDelivery` 方法 (L153-191)，增加 `orderType` 参数。
如果是 rental 类型，双方确认后 **不设 completed**，而是保持 `confirmed`，
让 Provider 层的 `updateRentalStatus('active')` 去推进状态。

将整个 `confirmDelivery` 方法替换为：

```dart
  /// Confirms delivery by [byUserRole] ('buyer' or 'seller').
  ///
  /// For sale orders: if both confirmed, transitions to 'completed'.
  /// For rental orders: stays in 'confirmed', provider layer activates rental.
  Future<Order> confirmDelivery({
    required String orderId,
    required String byUserRole,
    required String orderType,
  }) async {
    try {
      final field = byUserRole == 'buyer'
          ? 'delivery_confirmed_by_buyer'
          : 'delivery_confirmed_by_seller';

      // Step 1: confirm delivery by this role
      await _client
          .from(AppConstants.tableOrders)
          .update({field: true})
          .eq('id', orderId);

      // Step 2: fetch updated record to check both confirmations
      final current = await _client
          .from(AppConstants.tableOrders)
          .select('delivery_confirmed_by_buyer, delivery_confirmed_by_seller, status')
          .eq('id', orderId)
          .single();

      final bothConfirmed =
          current['delivery_confirmed_by_buyer'] == true &&
          current['delivery_confirmed_by_seller'] == true;

      // Step 3: only complete sale orders automatically.
      // Rental orders stay in 'confirmed' — provider layer activates rental.
      if (bothConfirmed &&
          current['status'] != 'completed' &&
          orderType == 'sale') {
        await _client
            .from(AppConstants.tableOrders)
            .update({'status': 'completed'})
            .eq('id', orderId);
      }

      return fetchOrder(orderId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
```

Then update the Provider call in `lib/features/orders/providers/orders_provider.dart`
(around line 214):

Replace:
```dart
        await ref.read(orderRepositoryProvider).confirmDelivery(
          orderId: order.id,
          byUserRole: role,
        );
```

With:
```dart
        await ref.read(orderRepositoryProvider).confirmDelivery(
          orderId: order.id,
          byUserRole: role,
          orderType: order.orderType,
        );
```

---

## Bug #4: 商品详情页两个 App Bar — ✅ 需修复

**Flash 诊断正确**。`ListingImageCarousel` 内部 (L148-197) 有一组
back/share/favorite 按钮；`ListingDetailScreen` 外部 (L578-639) 也有
一组 floating back + bookmark 按钮。两组重叠。

### 修复：修改 `lib/features/listing/widgets/listing_image_carousel.dart`

删除 L147-197 的整个 Navigation Buttons 区域（back + share + favorite）。
保留外部 `ListingDetailScreen` 的 floating buttons。

找到以下代码块并删除（约 L147-197）：

```dart
          // Navigation Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.sm,
            child: IconButton(
              ...
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            right: AppSpacing.sm,
            child: Row(
              children: [
                IconButton( ... share ... ),
                IconButton( ... favorite ... ),
              ],
            ),
          ),
```

即删除从 `// Navigation Buttons` 注释到 Stack children 结束之间的两个
Positioned widget。

---

## Bug #5: 下单日期不精确 — ✅ 需修复

**Flash 诊断正确**。

### 修复：修改 `lib/features/listing/screens/listing_detail_screen.dart`

找到 L407:
```dart
final submittedDate = DateFormat('MMM d, yyyy').format(order.createdAt);
```

替换为:
```dart
final submittedDate = DateFormat('MMM d, yyyy · h:mm a').format(order.createdAt.toLocal());
```

---

## Bug #6: Listing Stats 数据为 0 — ⏳ 延后

**Flash 诊断正确但方案不完整**。

Stats 字段 (`view_count`, `saves_count`, `inquiries_count`) 需要：
1. DB 触发器在 `saved_listings` INSERT/DELETE 时更新 `listings.saves_count`
2. DB 触发器在 `chat_rooms` INSERT 时更新 `listings.inquiries_count`
3. `listing_views` 表 + 浏览统计逻辑

这属于 **Phase 2 功能**（view tracking），不在此 bugfix batch 范围。
**跳过。**

---

## Bug #7: 管理页面数据为空 — 需调查

**Flash 诊断可能正确**。需要检查 RLS 策略是否允许卖家读取关联数据。

### 调查方向（不在此 Task 中修复）：
1. 检查 `saved_listings` 表的 RLS 是否允许 listing 的 seller 查看
2. 检查 `orders` 表 RLS 是否允许 seller 通过 `listing_id` 查询

如果 RLS 限制了卖家访问，需要新增策略：
```sql
-- 卖家可以查看其 listing 的收藏记录
CREATE POLICY "Seller can view saves on their listings"
  ON public.saved_listings FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.listings
      WHERE listings.id = saved_listings.listing_id
      AND listings.seller_id = auth.uid()
    )
  );
```

**⚠️ 这需要先测试确认是否确实是 RLS 问题。**
请在 Supabase Dashboard SQL Editor 中运行以下查询来验证：
```sql
-- 用卖家身份登录后检查
SELECT * FROM saved_listings WHERE listing_id = '<your_listing_id>';
SELECT * FROM orders WHERE listing_id = '<your_listing_id>';
```

如果返回空结果但数据确实存在，则确认是 RLS 问题。

---

## 执行顺序

1. **Bug #3 + #1**：修改 `order_repository.dart` 和 `orders_provider.dart`（confirmDelivery）
2. **Bug #4**：修改 `listing_image_carousel.dart`（删除重复按钮）
3. **Bug #5**：修改 `listing_detail_screen.dart`（日期格式）
4. **Bug #2**：创建 `00021_chat_images_bucket.sql`（⚠️ 需 USER 执行 SQL）
5. 运行 `flutter analyze` 验证

**Bug #6 和 #7 延后到 Phase 2。**

---

## 验证

```bash
cd /Users/george/smivo && flutter analyze
```

报告写入 `.agent/reports/report-020.md`。
