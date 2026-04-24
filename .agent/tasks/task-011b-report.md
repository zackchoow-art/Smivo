# Task 011b Report: Rental Extension Feature (Batch 2)

## 任务目标
实现租赁展期（Extension）和提前归还（Shorten）请求功能，包括：
1. 数据库存储与自动更新逻辑。
2. 买家端提交请求 UI。
3. 卖家端审批/拒绝 UI。
4. 价格差异自动计算。

## 完成项

### 1. 数据库与后端逻辑
- **SQL 迁移**: 创建并执行了 `00027_rental_extensions.sql`。
  - 创建了 `rental_extensions` 表。
  - 实现了 `apply_rental_extension()` 触发器函数，在卖家批准请求时自动更新 `orders` 表的 `rental_end_date` 和 `total_price`。
  - 实现了 `notify_rental_extension()` 触发器函数，在请求提交和响应时自动发送通知。
  - 配置了 RLS 策略，确保买卖双方的隐私和操作权限。

### 2. 数据层实现
- **Model**: 创建了 `RentalExtension` Freezed 模型，支持 JSON 序列化。
- **Repository**: 创建了 `RentalExtensionRepository`，封装了 CRUD 操作。
- **Provider**: 创建了 `RentalExtensionActions` Notifier 和 `orderExtensionsProvider`，支持实时刷新和状态管理。

### 3. UI 界面集成
- **RentalExtensionCard**: 开发了全新的卡片组件，集成了：
  - **历史记录**: 以列表形式展示所有历史请求及其状态（Pending, Approved, Rejected）。
  - **申请表单**: 买家在租赁 active 状态下可以点击 Extend/Shorten，通过日期选择器选择新日期，系统会自动计算价格差异。
  - **审批操作**: 卖家可以直接在详情页对 Pending 状态的请求进行“批准”或“拒绝”（支持填写拒绝理由）。
- **页面集成**: 将 `RentalExtensionCard` 成功集成到 `RentalOrderDetailScreen`。

### 4. 代码质量与规范
- 运行 `flutter analyze` 结果为 **零 Error/Warning**。
- 样式完全遵循 `SmivoThemeExtension` 令牌。
- 价格计算逻辑：`额外天数 * 商品日租金`。

## 测试建议
1. 以买家身份登录，进入 Active 状态的订单详情页，提交 Extension 请求。
2. 以卖家身份登录，在通知或订单详情页查看请求，执行批准或拒绝。
3. 验证批准后，订单的主价格和结束日期是否已更新。
