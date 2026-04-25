# Task 015: Seller Center 卡片改进

## 分配给: Flash
## 复杂度: ⭐⭐
## 涉及文件
- `lib/features/seller/screens/seller_center_screen.dart` (542 行)

## 重要规则
- 只做 UI 调整，不改业务逻辑
- 读完整个文件再开始修改

## 修改清单

### A. Active Listings 大卡片模式
找到大卡片中显示 views / saves / offers 文字的部分（搜索 `views` / `saves` / `offers` 文本）。
- 删除文字说明（如 `Text('Views')`, `Text('Saves')`, `Text('Offers')`）
- 只保留图标和数字

### B. Active Listings 列表模式
找到列表模式中三个图标的 Row，加大间距：
- 每个图标之间加 `SizedBox(width: 16)` 或更大的间距（目前可能是 8 或 4）
- 确保触摸目标至少 44x44

### C. History 卡片修复
1. **订单图片修复**：检查 History 区域加载的图片 URL。Order model 中图片可能通过 `order.listing` join 拿到。搜索 History 区域看当前从哪取图片。
2. **双行时间戳**：右侧显示：
   - 第一行：发布时间 `listing.createdAt`
   - 第二行：结束时间 `order.updatedAt`（完成/取消的时间）
3. **分区点击导航**：
   - 把卡片改为 `Row`，左侧（图片+标题）包裹 `GestureDetector` 导航到 `AppRoutes.listingDetail`
   - 右侧（时间戳区域）包裹 `GestureDetector` 导航到 `AppRoutes.orderDetail`

## 验证
```bash
flutter analyze
```
必须零错误。
