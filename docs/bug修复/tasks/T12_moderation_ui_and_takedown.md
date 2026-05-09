# T12: 全面改进内容审核客户端表现与商品下架副作用

本任务包含 5 个子任务，涉及 Flutter app 和 Supabase 后端。

---

## 子任务 A：增强 ModerationAwareImage 组件 — 显示违规类型

### 背景

当前 `ModerationAwareImage`（`app/lib/shared/widgets/moderation_aware_image.dart`）
在检测到违规时只显示一个 `visibility_off` 图标，没有告知用户为什么图片被模糊/删除。

### 需求

1. **blur 模式**：加载图片 + 高斯模糊 + 叠加文字：
   `"This image has been restricted for: {violation_type}"`
   例如 `"This image has been restricted for: sexual content"`

2. **auto_reject 模式**：不加载图片，显示灰色占位符 + 文字：
   `"This image has been removed for: {violation_type}"`

### 实现方案

**步骤 1**：修改 `FlaggedImageUrlsProvider`（`app/lib/core/providers/moderation_provider.dart`）

当前 provider 返回 `Set<String>`（只存 URL）。需要改为返回 `Map<String, List<String>>`，
key 是 URL，value 是违规原因列表。

数据来源：`backend_moderation_logs.image_details` 是一个 jsonb 数组，其中每个元素结构如下：
```json
{
  "url": "https://...",
  "flagged": true,
  "reasons": ["sexual"],
  "scores": {...}
}
```

对于 chat message（`target_type = 'message'`），`content_snapshot` 存的是图片 URL，
违规原因在 `image_details[0].reasons` 里。

修改后的 provider 应该：
```dart
// 返回 Map<url, reasons>
@Riverpod(keepAlive: true)
class FlaggedImageUrls extends _$FlaggedImageUrls {
  @override
  Future<Map<String, List<String>>> build() async {
    // ... 查询 backend_moderation_logs WHERE result = 'fail'
    // 从 image_details 中提取 url → reasons 映射
    // 从 content_snapshot 提取 URL 时，对应的 reasons 在 image_details[0].reasons
  }
}
```

**步骤 2**：修改 `ModerationAwareImage` 以使用新的 Map 数据

- `isFlagged` 检查：`urls.containsKey(imageUrl)`
- 获取违规类型：`urls[imageUrl]?.join(', ') ?? 'policy violation'`
- blur 模式：在模糊图片上显示文字说明
- auto_reject 模式：在灰色占位符上显示文字说明

**步骤 3**：由于改了 `FlaggedImageUrls` 的返回类型（Set → Map），
需要检查并更新所有使用 `flaggedImageUrlsProvider` 的地方：
- `chat_room_screen.dart` — 第 960 行附近
- `chat_popup.dart` — 第 678 行附近
- 其他位置用 `.containsKey()` 替换 `.contains()`

**步骤 4**：运行 `dart run build_runner build --delete-conflicting-outputs`
重新生成 `.g.dart` 文件（因为修改了 `@riverpod` 注解的 class）。

---

## 子任务 B：修复全屏图片查看器的违规图片漏洞

### 背景

`FullscreenImageViewer`（`app/lib/shared/widgets/fullscreen_image_viewer.dart`）
接受 `imageUrls` 列表。用户可以通过左右滑动查看所有图片。
如果第 N 张图被标记为违规，用户可以从第 N-1 张正常图片滑动到第 N 张看到原图。

### 需求

在全屏查看器中，违规图片必须被替换为占位符或跳过。

### 实现方案

**方案（推荐）**：将 `FullscreenImageViewer` 改为 `ConsumerStatefulWidget`，
在 `build` 中读取 `flaggedImageUrlsProvider`，对 `PhotoViewGalleryPageOptions` 做判断。

具体修改（`fullscreen_image_viewer.dart`）：

1. 导入 `flutter_riverpod` 和 `moderation_provider.dart`
2. 改为 `ConsumerStatefulWidget`（需要 `WidgetRef ref`）
3. 在 `PhotoViewGallery.builder` 的 `builder` 回调中：
   - 检查 `widget.imageUrls[index]` 是否在 `flaggedUrls` 中
   - 如果是，返回一个自定义的 `PhotoViewGalleryPageOptions.customChild`，
     显示违规占位符（不加载图片）
   - 如果不是，正常显示

4. 在 `_saveImage()` 中：
   - 检查当前图片是否被标记，如果是则拒绝下载并提示用户

示例代码：
```dart
PhotoViewGalleryPageOptions.customChild(
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.block, color: Colors.grey, size: 48),
        SizedBox(height: 16),
        Text(
          'This image has been restricted for: $reasons',
          style: TextStyle(color: Colors.grey, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
)
```

---

## 子任务 C：商品被 AI/人工下架时清空收藏和取消 offer

### 背景

当 AI 审核自动下架商品（`moderation_status = 'taken_down'`）或
人工审核下架（`status = 'delisted'` 或 `moderation_status = 'taken_down'`）时，
应该清空该商品的所有收藏记录和取消所有 pending 的 offer。

### 当前状态

migration 00111 中的 `notify_listing_taken_down()` 触发器只发通知，
没有清理收藏和订单。

`cancel_pending_orders_on_delist()` RPC 是在用户手动下架时调用的
（`listing_detail_screen.dart` 中的 `_showDelistDialog`），但不会被自动下架触发。

### 实现方案

**写一个新 migration（00131）**：修改 `notify_listing_taken_down()` 触发器，
增加以下逻辑：

```sql
-- 在 notify_listing_taken_down() 中添加：

-- 1. 取消该商品的所有 pending 订单
UPDATE public.orders
SET status = 'cancelled',
    cancelled_by = NEW.seller_id,
    updated_at = now()
WHERE listing_id = NEW.id
  AND status = 'pending';

-- 2. 清空该商品的所有收藏记录
DELETE FROM public.saved_listings
WHERE listing_id = NEW.id;
```

**注意**：
- `cancelled_by = NEW.seller_id` 让通知触发器能正确发送 "listing removed" 消息
- 取消订单时现有的 `notify_order_status_change` 触发器会自动为买家生成通知
- 同时处理 `status` 变为 `delisted` 的情况（手动下架也应该清理，但这个已经
  在客户端通过 RPC 处理了。为安全起见，在触发器中也加上。）

修改触发函数为同时监听 `moderation_status = 'taken_down'` **和** `status = 'delisted'`。

执行 migration 后验证。

---

## 子任务 D：商品详情页 pending order 信息卡完善

### 背景

当买家已经提交过申请（order status = 'pending'）时，
商品详情页底部应该隐藏 "Request to Buy/Rent" 按钮，
替换为一个信息栏显示：
- 第一行：`"Application Submitted, awaiting seller's approval"`
- 第二行：`"Submitted: {date}"`
- 第三行：`"Expected Pickup: {date}"`
- 下方：Cancel 按钮

### 当前状态

代码中已经有一个状态卡（第 979-1152 行），当 `order != null` 时显示。
这个卡片确实会替换 request 按钮（因为有 return）。

**需要补充的内容**：
1. 对 pending 状态，添加 "awaiting seller's approval" 副标题
2. 添加 "Expected Pickup" 日期行（从 `order.rentalStartDate` 或 sale delivery date 获取）
3. 确保 Cancel 按钮对 pending 状态可见（当前已有，第 1033-1149 行）

### 实现

修改 `listing_detail_screen.dart` 第 957-1010 行的 pending 分支：

在 `title` 和 `submittedDate` 之间，添加：
```dart
if (order.status == 'pending') ...[
  const SizedBox(height: 2),
  Text(
    'Awaiting seller\'s approval',
    style: typo.bodySmall.copyWith(
      color: colors.outlineVariant,
    ),
  ),
],
```

在 `submittedDate` 下面、price 显示前面，添加 expected pickup date 行：
```dart
if (order.rentalStartDate != null) ...[
  const SizedBox(height: 4),
  Text(
    'Expected Pickup: ${DateFormat('MMM d, yyyy').format(order.rentalStartDate!.toLocal())}',
    style: typo.bodySmall.copyWith(
      color: colors.outlineVariant,
    ),
  ),
],
```

**注意**：sale 订单可能没有 rentalStartDate，请检查 Order model 中是否有
通用的 pickup date 字段。如果没有，只对 rental 订单显示此行。

---

## 子任务 E：商品详情页 Campus 显示验证（仅验证，不需要修改）

### 已验证内容

商品详情页的 Pickup Location 区域下方已经有 Campus 显示（第 522-562 行）。
使用了 `Icons.school_outlined` + `Campus: $schoolName` + 与其他标题相同的
`typo.labelLarge.copyWith(fontWeight: FontWeight.bold)` 样式。

订单提交时 school 字段也有正确赋值逻辑（第 1621-1648 行）：
- 买家更改地址 → 使用买家的 school name
- 买家不更改地址 → 使用 listing 的 school name

数据库中所有现有订单的 school 字段均不为空。

**请在做其他子任务时顺便检查**：
1. `listing.schoolId` 是否可能为 null（如果旧 listing 没有 schoolId 字段）
2. `activeSchools` 为空列表时是否会导致 schoolName = null → 不显示

如果 `listing.schoolId` 为 null，代码中 `activeSchools.where(...)` 永远不匹配，
返回 null → `SizedBox.shrink()` → 不显示 campus 行。这符合预期。

---

## 执行顺序

1. 子任务 A（改 provider + 改 widget）
2. 子任务 B（改 fullscreen viewer）
3. 运行 `dart run build_runner build --delete-conflicting-outputs`
4. 子任务 D（改 listing detail）
5. 子任务 C（写 migration）
6. 执行 migration：`./supabase/scripts/run_migration.sh 00131`
7. 运行 `flutter analyze` 确保无错误

## 不要修改的文件

- `moderate-content/index.ts` — Edge Function 不需要改
- `moderation_provider.dart` 中的 `ImageModerationMode` provider — T11 已修过
- `moderation_provider.dart` 中 BlockedUsers/ModerationActions 等 — 与本任务无关
