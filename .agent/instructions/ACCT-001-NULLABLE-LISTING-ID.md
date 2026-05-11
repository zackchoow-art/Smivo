# 指令文件：Account Deletion App-Side Adaptation (ACCT-001)

## 背景

数据库迁移 `00139` 已将 `orders.listing_id` 从 `NOT NULL + ON DELETE RESTRICT` 改为 `NULLABLE + ON DELETE SET NULL`。这修复了活跃用户无法删除账户的 409 Conflict 错误。

但 App 端的 `Order` 模型和相关 UI 需要适配 `listing_id` 可能为 null 的场景。

### 何时 listing_id 为 null？

当一个用户删除账户后，其发布的商品被级联删除，此时另一方（买家/卖家）的订单中 `listing_id` 会被设为 NULL。

## 任务清单

### 1. Order 模型：listing_id 改为可空

**文件**: `app/lib/data/models/order.dart`

将:
```dart
@JsonKey(name: 'listing_id') required String listingId,
```
改为:
```dart
@JsonKey(name: 'listing_id') String? listingId,
```

### 2. 运行 freezed 代码生成

```bash
cd app && dart run build_runner build --delete-conflicting-outputs
```

### 3. 修复所有 `order.listingId` 的使用

以下文件引用了 `order.listingId`，需要处理 null 情况：

| 文件 | 使用方式 | 修复方案 |
|------|----------|----------|
| `orders_provider.dart:243` | `acceptOrderAndRejectOthers(orderId, order.listingId)` | listingId 为空时不执行 accept（理论上不会发生，因为该商品已被删除） |
| `orders_provider.dart:250` | `updateListingStatus(order.listingId, 'sold')` | 加 null check: `if (order.listingId != null)` |
| `orders_provider.dart:337` | `updateListingStatus(order.listingId, 'rented')` | 同上 |
| `order_info_section.dart:264` | `listingId: order.listingId` | 传入可空参数或加条件 |
| `list_order_card.dart:183` | `listingId: order.listingId` | 传入可空参数或加条件 |
| `sale_order_detail_screen.dart:333,335` | 条件渲染 + `listingId: order.listingId` | 加 `order.listingId != null &&` 到条件 |
| `sale_order_detail_screen.dart:398` | `listingId: order.listingId` | null check |
| `rental_order_detail_screen.dart:504,506` | 同上 | 同上 |
| `rental_order_detail_screen.dart:579` | 同上 | 同上 |
| `transaction_management_screen.dart:860` | `listingId: order.listingId` | null check |

**修复原则**：
- 如果 `listingId` 为 null，跳过与商品相关的操作（导航到商品详情、更新商品状态等）
- 在 UI 中，如果商品已删除，显示 "Item no longer available" 而非跳转

### 4. Order 查询中的 listing join

**文件**: `app/lib/data/repositories/order_repository.dart`

当前查询使用内连接 `listing:listings(...)` 获取嵌套商品数据。当 `listing_id` 为 NULL 时，内连接不会返回该订单（丢失数据）。

需要确认 PostgREST 对可空外键的 JOIN 行为：
- 如果 `listing_id` 为 null，PostgREST 的嵌套 select 会返回 `listing: null`，这是安全的
- `OrderListingPreview? listing` 已经是可空类型，所以模型层兼容

**无需修改查询**，但需要在 UI 层处理 `order.listing == null` 的情况。

### 5. 删除失败时的用户反馈

**文件**: `app/lib/features/settings/screens/edit_profile_screen.dart`

当前删除是 fire-and-forget（第 401-405 行），失败时无反馈。需要改进：

将 fire-and-forget 改为等待结果，在失败时显示 SnackBar。

```dart
// 改前：
context.goNamed(AppRoutes.home);
ref.read(authProvider.notifier).deleteAccount();

// 改后：
try {
  await ref.read(authProvider.notifier).deleteAccount();
  if (context.mounted) {
    context.goNamed(AppRoutes.home);
  }
} catch (e) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete account. Please try again.')),
    );
  }
}
```

**注意**：由于我们之前已修复了 `auth_provider.dart` 中的 `deleteAccount()` 方法（加了 `ref.mounted` 检查），现在可以安全地 await 它。

### 6. 运行 flutter analyze

确保所有修改通过静态分析。

## 执行边界

- **仅修改** 上述列出的文件
- **不要修改** 数据库或迁移文件
- **不要修改** `admin/` 目录下的任何文件
- **不要修改** 路由配置
- `dart run build_runner` 生成的 `.freezed.dart` 和 `.g.dart` 文件除外

## 验收标准

1. `flutter analyze` 无 error
2. `order.listingId` 可以为 null 且不会导致运行时崩溃
3. 当 listing 已删除时，UI 优雅降级（显示占位文本而非崩溃）
4. 删除账户失败时用户看到错误提示

## 执行报告保存位置

`/Users/george/smivo/.agent/reports/ACCT-001-execution-report.md`
