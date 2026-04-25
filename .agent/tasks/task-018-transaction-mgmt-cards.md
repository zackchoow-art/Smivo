# Task 018: Manage Transactions 页卡片改进

## 分配给: Flash
## 复杂度: ⭐⭐
## 涉及文件
- `lib/features/seller/screens/transaction_management_screen.dart` (395 行)

## 重要规则
- 只做 UI 调整，不改 Accept/Chat 等业务逻辑
- 读完整个文件再开始修改

## 修改清单

### A. 标题下方加商品信息展示区
在 `TransactionManagementScreen` 的 TabBar 上方（标题行下方），加一个商品简易展示区。
需要拿到当前 listing 数据（该页面通过 `listingId` 参数构建）。

```dart
// Quick listing preview
Container(
  padding: const EdgeInsets.all(12),
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: colors.surfaceContainerLow,
    borderRadius: BorderRadius.circular(radius.card),
  ),
  child: Row(children: [
    // Listing image thumbnail
    ClipRRect(
      borderRadius: BorderRadius.circular(radius.sm),
      child: Image.network(listingImageUrl, width: 48, height: 48, fit: BoxFit.cover),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(listingTitle, style: typo.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      Text('\$${listingPrice}', style: typo.bodyMedium.copyWith(color: colors.primary, fontWeight: FontWeight.w600)),
    ])),
  ]),
)
```

### B. Offers 卡片改进 (_OffersTab)
找到 `_buildOrderCard` 方法：

1. **头像验证**：确认 `order.buyer?.avatarUrl` 正确加载，空值兜底
2. **买家姓名下方加邮箱**：
```dart
Text(order.buyer?.email ?? '', style: typo.bodySmall.copyWith(color: colors.outlineVariant))
```
3. **点击卡片导航到 Order Details**：
```dart
GestureDetector(
  onTap: () => context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': order.id}),
  child: Container(... existing card ...),
)
```
4. **调整 pending/金额位置互换**：目前 "Pending" chip 和金额的位置互换一下
5. **消息图标改为按钮**：把 `IconButton(icon: Icon(Icons.chat_outlined))` 改为 `OutlinedButton.icon` 或 `TextButton.icon`，放在 Accept 按钮左边

### C. Views 和 Saves 卡片改进 (_ViewsTab, _SavesTab)
1. **头像验证**：确认正确加载
2. **添加邮箱**：在名字下方加 email 显示
3. **消息图标改为按钮**：放在右侧
4. **点击卡片不跳转**：确认没有 `onTap` / `GestureDetector`（如果有，移除）

## 验证
```bash
flutter analyze
```
必须零错误。
