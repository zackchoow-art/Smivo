# T4: Transaction Management 页 Offers 卡片补充信息

## 任务目标
在 Manage Transactions 页面的 Offers 卡片上添加显示：
1. 购买时间（或租期，如果是 rental 订单）
2. 交付地址（pickup location）
3. 学校名称

## 执行边界
### 允许修改的文件：
- `app/lib/features/seller/screens/transaction_management_screen.dart`
- `app/lib/features/seller/providers/` 下的相关 provider 文件（如需要加载额外数据）

### 严禁修改的文件：
- 任何 model 文件
- 任何 repository 文件
- 任何 admin/ 目录文件
- 任何 supabase/ 目录文件
- 任何不在 seller feature 下的文件

## 实现步骤

### 1. 分析现有 Offers 卡片
- 打开 `transaction_management_screen.dart`
- 找到 Offers Tab 的卡片列表
- 了解每张卡片目前显示了什么信息（buyer avatar, name, email, order amount, status chips）
- 确认 Order model 中是否已包含 pickup location 和 school 信息

### 2. 确认数据可用性
- 检查 Order model 是否有以下字段：
  - `createdAt`（购买时间）
  - `rentalStartDate` / `rentalEndDate`（租期）
  - `pickupLocationName` 或 `pickupLocation`（交付地址）
  - `school`（学校名）
- 如果数据已通过 provider 加载，直接使用
- 如果需要额外 join，修改 provider 中的查询

### 3. 修改 Offers 卡片 UI
在每张 offer 卡片上，在现有信息下方添加：
- 📅 购买时间 / 租期：`MM/dd/yyyy` 或 `MM/dd - MM/dd/yyyy`
- 📍 交付地址：地址文本
- 🏫 学校：学校名称

使用 `context.smivoTypo.bodySmall` + 灰色文字样式，保持卡片简洁。

## 验证要求
执行以下命令确保 0 错误：
```bash
cd /Users/george/smivo/app && flutter analyze
```

## 执行报告
完成后将执行报告写入文件：`docs/bug修复/tasks/T4_report.md`

报告内容包括：
1. 修改了哪些文件，修改了哪些行
2. 数据来源说明（字段是否已在 model 中存在）
3. flutter analyze 的输出结果
