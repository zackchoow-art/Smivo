# Task 011a Report: Order Detail Refactor (Batch 1)

## 任务目标
将 `order_detail_screen.dart` 从单体结构拆分为：
1. **Thin Dispatcher**: `OrderDetailScreen` 仅负责加载数据和分发。
2. **Dedicated Screens**: `SaleOrderDetailScreen` 和 `RentalOrderDetailScreen`。
3. **Shared Widgets**: 5 个可复用的组件。

## 完成项

### 1. 共享组件提取
成功提取并标准化了以下组件，均使用 `SmivoThemeExtension` 令牌：
- `OrderHeaderCard`: 显示商品信息、价格和状态。
- `OrderTimeline`: 通用订单进度条。
- `OrderFinancialSummary`: 财务明细（支持租借费率）。
- `OrderInfoSection`: 订单基础信息及操作方信息。
- `RentalDateSection`: 租借特有的日期显示。

### 2. 证据照片系统升级
- **数据库**: 创建了 `00026_add_evidence_type.sql` 迁移文件，为 `order_evidence` 表添加了 `evidence_type` 列（默认为 `delivery`）。
- **模型**: 更新了 `OrderEvidence` 模型，增加了 `evidenceType` 字段。
- **Repository**: 更新了 `OrderEvidenceRepository`，支持上传时指定 `evidenceType` 并存储到对应的存储路径子文件夹下。
- **UI**: `EvidencePhotoSection` 现在支持通过 `label` 和 `evidenceType` 进行定制，分别显示“交付证据”和“归还证据”。

### 3. 订单详情页重构
- `OrderDetailScreen` 现在根据 `order.orderType` 自动分发到销售或租借详情页。
- 销售订单详情页实现了简化的状态流。
- 租借订单详情页实现了完整的生命周期管理，包括归还证据上传和退还押金操作。

### 4. 代码质量
- 运行 `flutter analyze` 结果为 **零 Error/Warning**。
- 统一了 Avatar 显示逻辑和颜色令牌使用。

## 待办事项 (Batch 2 预告)
- 实现订单延期请求功能。
- 优化证据照片的预览和删除功能。
- 增加更多的实时状态更新通知。
