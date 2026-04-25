# Task 014: 商品详情页 UI 调整

## 分配给: Flash
## 复杂度: ⭐⭐
## 涉及文件
- `lib/features/listing/screens/listing_detail_screen.dart` (529 行)

## 重要规则
- **只做 UI 调整，不要修改或删除任何业务逻辑代码**
- **不要删除任何现有的下单流程、delist 功能、聊天弹窗、取消申请等代码**
- **读完整个文件再开始修改**

## 修改清单

### A. Sale 模式按钮文字修改
**文件**: `listing_detail_screen.dart` 第 443 行  
把：
```dart
child: Text(isSale ? 'Place Order' : 'Request to Rent', ...)
```
改为：
```dart
child: Text(isSale ? 'Request to Buy' : 'Request to Rent', ...)
```

### B. 下单成功后跳转修改
**文件**: `listing_detail_screen.dart` 第 434 行  
把：
```dart
context.goNamed(AppRoutes.orders);
```
改为：
```dart
context.goNamed(AppRoutes.home);
```

### C. 成色标签位置调整
目前成色标签显示在图片上（第 127 行 `statusTag`，传给 `ListingImageCarousel` 的 `tagText`）。

1. **Sale 模式图片上不再显示成色标签**：第 131 行改为对 sale 不传 tagText：
```dart
ListingImageCarousel(imageUrls: imageUrls, tagText: isSale ? null : 'AVAILABLE NOW', isSale: isSale),
```
注意：`ListingImageCarousel` 的 `tagText` 参数需要是 `String?` 类型并在 null 时不渲染。如果它是 required String，需要改为 optional。

2. **在产品标题下方添加成色文字**（约第 133-134 行之间）：
```dart
Text(listing.title, style: typo.displayLarge.copyWith(fontSize: 32, letterSpacing: -1, height: 1.1)),
const SizedBox(height: 4),
Text(_conditionLabel(listing.condition).toUpperCase(),
  style: typo.bodyMedium.copyWith(
    color: colors.onSurface.withValues(alpha: 0.55),
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  ),
),
```

### D. Rent 模式 — 卖家自己的商品隐藏交互区域
在 `RentalOptionsSection` 或包含 Day/Week/Month 按钮 + Rental Period 的区域，加上 `if (!isOwnListing)` 条件包裹。

对于卖家自己的商品，替代显示一个只读的价格展示区：
```dart
if (isOwnListing && !isSale) ...[
  const SizedBox(height: 16),
  // Read-only rental rates display
  Row(children: [
    if (listing.rentalDailyPrice != null && listing.rentalDailyPrice! > 0)
      Expanded(child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(radius.button),
        ),
        child: Column(children: [
          Text('Day', style: typo.labelMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('\$${listing.rentalDailyPrice!.toStringAsFixed(0)}', style: typo.bodySmall.copyWith(color: colors.primary)),
        ]),
      )),
    // 同样处理 weekly 和 monthly
  ]),
],
```

### E. Pickup Location — 卖家视角只读
找到 Pickup Location 下拉框/选择组件，加 `if (!isOwnListing)` 条件使卖家只能看不能改。

### F. 卖家信息栏改进
找到显示 seller info 的区域（搜索 `seller` 或 `SellerProfileCard`）：
1. 确认头像加载：检查 `seller?.avatarUrl` 是否有空字符串兜底
2. 在该区域上方加 `Text('Seller', style: typo.titleSmall)` 标签
3. 在用户名下方加 `Text(seller?.email ?? '', style: typo.bodySmall.copyWith(color: colors.outlineVariant))`

UserProfile model 已有 `email` 字段（见 `lib/data/models/user_profile.dart`）。

## 验证
```bash
flutter analyze
```
必须零错误。
