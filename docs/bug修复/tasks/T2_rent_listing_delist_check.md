# T2: Rent 商品详情页下单前检测商品状态

## 任务目标
在 rent 商品详情页（`listing_detail_screen.dart`）中，当买家点击下单按钮时，先实时检查商品是否已下架（status != 'active'），如果已下架则：
1. 不执行下单操作
2. 显示 SnackBar 提示用户 "This item is no longer available"
3. 刷新页面数据让用户看到最新状态

同样的检测也要应用到 sale 商品的下单按钮。

## 执行边界
### 允许修改的文件：
- `app/lib/features/listing/screens/listing_detail_screen.dart`

### 严禁修改的文件：
- 任何 provider 文件
- 任何 repository 文件
- 任何 model 文件
- 任何 admin/ 目录文件
- 任何 supabase/ 目录文件
- 任何 widget 文件

## 实现步骤

### 1. 找到下单按钮的 onPressed 回调
在 `listing_detail_screen.dart` 中找到 sale 和 rent 两种类型的下单按钮处理逻辑。

### 2. 在 onPressed 回调开头添加检测
```dart
// Before submitting order, re-fetch listing to check if still active
final freshListing = await ref.read(listingRepositoryProvider).fetchListing(listing.id);
if (freshListing == null || freshListing.status != 'active') {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This item is no longer available')),
    );
    // Refresh the page
    ref.invalidate(listingDetailProvider(widget.id));
  }
  return;
}
```

### 3. 注意事项
- 使用 `listingRepositoryProvider` 获取最新数据，不要自己创建 Supabase 调用
- 确保 `listingRepository` 有 `fetchListing(id)` 方法（或类似方法）。如果没有，请在 listing_detail_screen 中使用现有的 provider 重新加载
- 如果 repository 没有单独获取 listing 的方法，可以使用 `ref.read(listingDetailProvider(listing.id).future)` 来获取最新数据

## 验证要求
执行以下命令确保 0 错误：
```bash
cd /Users/george/smivo/app && flutter analyze
```

## 执行报告
完成后将执行报告写入文件：`docs/bug修复/tasks/T2_report.md`

报告内容包括：
1. 修改了哪些文件，修改了哪些行
2. 新增了什么逻辑
3. flutter analyze 的输出结果
4. 是否有需要注意的副作用
