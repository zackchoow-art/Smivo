# Smivo v3.0 调试与逻辑审计报告 (2026-04-23)

## 1. [严重] 租赁订单生命周期逻辑中断 (Rental Lifecycle Logic Break)
- **Bug 现象**：当买卖双方确认交付后，租赁订单被错误地标记为 `completed`，导致无法进入后续租赁流程（归还、押金退还）。
- **根本原因**：`OrderRepository.confirmDelivery` 强制设置 `status = 'completed'`。
- **修复建议**：增加订单类型判断，仅 `sale` 类型在交付后完成；`rental` 类型在双方确认后进入 `active` 状态。
- **涉及文件**：`lib/data/repositories/order_repository.dart`

## 2. 聊天室图片发送功能故障 (AppStorageException)
- **Bug 现象**：发送图片时报错 `Bucket not found`。
- **根本原因**：Supabase 中缺少名为 `chat-images` 的存储桶，或 RLS 权限未配置。
- **修复建议**：在 Supabase 创建 `chat-images` 存储桶并配置相应的 RLS 策略。
- **涉及文件**：Supabase 控制台 / `lib/data/repositories/storage_repository.dart`

## 3. 订单与租赁状态逻辑矛盾 (State Inconsistency)
- **Bug 现象**：总体 `status` 与 `rental_status` 在状态流转上存在重叠和冲突。
- **根本原因**：状态更新逻辑分散，且没有统一的生命周期终点定义。
- **修复建议**：租赁订单统一在 `deposit_refunded` 之后才标记总体 `status` 为 `completed`。
- **涉及文件**：`lib/data/repositories/order_repository.dart`, `lib/features/orders/providers/orders_provider.dart`

## 4. 商品详情页出现两个 App Bar (Double App Bar)
- **Bug 现象**：页面顶部有两组返回/分享/收藏按钮，一组随页面滚动，另一组固定（实际为两组重叠）。
- **根本原因**：`ListingImageCarousel` 内部和 `ListingDetailScreen` 外部各有一套按钮逻辑。
- **修复建议**：移除 `ListingImageCarousel` 内部的 `Positioned` 按钮，保留外部固定的导航按钮。
- **涉及文件**：`lib/features/listing/widgets/listing_image_carousel.dart`

## 5. 买家视角：下单日期显示不精确
- **Bug 现象**：已下单订单下方显示的日期仅有年月日，没有具体时间。
- **根本原因**：使用的 `DateFormat` 模板不含时间信息。
- **修复建议**：更改为 `DateFormat('MMM d, yyyy · h:mm a')`。
- **涉及文件**：`lib/features/listing/screens/listing_detail_screen.dart`

## 6. 卖家视角：Listing Stats 数据为 0
- **Bug 现象**：浏览量、收藏量和咨询量统计数据不更新。
- **根本原因**：缺乏对应的增量更新逻辑和数据库触发器。
- **修复建议**：
    - 增加 `incrementViewCount` 逻辑。
    - 在数据库中为 `saved_listings` 和 `chat_rooms` 添加触发器以自动更新 `listings` 表的计数字段。
- **涉及文件**：`lib/data/repositories/listing_repository.dart`, Supabase Migrations

## 7. 管理页面 (Manage Transactions) 数据为空
- **Bug 现象**：点击进入管理页面后，所有标签页（Views, Saves, Orders）均不显示数据。
- **根本原因**：查询过滤参数或 RLS 权限可能限制了卖家对关联数据的访问。
- **修复建议**：检查 `fetchOrdersByListing` 等方法的查询逻辑，并验证数据库层面的 RLS 策略。
- **涉及文件**：`lib/data/repositories/order_repository.dart`, `lib/data/repositories/saved_repository.dart`
