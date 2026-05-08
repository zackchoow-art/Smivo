# T1: Sale 订单详情页恢复已预订状态 UI

## 任务目标
在 sale 商品详情页（`listing_detail_screen.dart`）中，当买家已经对某个 sale 商品提交过订单（existingOrder 存在）时：
1. 隐藏底部的 "Request to Buy" 按钮
2. 显示一个"已预订"状态卡片，包含：预定时间（订单创建时间）和当前订单状态
3. 显示 Cancel 按钮（仅当订单状态为 pending 或 confirmed 且未确认交付时）
4. 参考 rent 订单详情页的类似逻辑保持 UI 统一

## 执行边界
### 允许修改的文件：
- `app/lib/features/listing/screens/listing_detail_screen.dart`

### 严禁修改的文件：
- 任何 provider 文件
- 任何 repository 文件  
- 任何 model 文件
- 任何 admin/ 目录文件
- 任何 supabase/ 目录文件
- 任何其他 screen 文件

## 实现步骤

### 1. 分析现有代码
- 在 `listing_detail_screen.dart` 中找到 `existingBuyerOrderProvider` 的使用位置
- 找到底部操作按钮区域（Request to Buy / Submit Rental Application）
- 参考 `rental_order_detail_screen.dart` 中的已提交状态 UI

### 2. 修改 listing_detail_screen.dart
在 sale 类型商品的底部操作区域，增加条件判断：

```dart
// 当 existingOrder 有数据时：
// - 如果是 pending 状态：显示 "Application Submitted" 卡片 + 预定时间 + Cancel 按钮
// - 如果是 confirmed 状态：显示 "Order Confirmed" 卡片 + 确认时间 + Cancel 按钮（如果可取消）
// - 如果是 completed/cancelled/missed：显示对应状态信息
// 当 existingOrder 无数据时：正常显示 "Request to Buy" 按钮
```

### 3. UI 设计参考
- 使用 `context.smivoColors` 和 `context.smivoTypo` 获取主题样式
- 状态卡片使用 `Container` + `BoxDecoration`（圆角、背景色）
- 预定时间格式：`MM/dd/yyyy HH:mm`
- Cancel 按钮使用红色 `OutlinedButton`

## 验证要求
执行以下命令确保 0 错误：
```bash
cd /Users/george/smivo/app && flutter analyze
```

## 执行报告
完成后将执行报告写入文件：`docs/bug修复/tasks/T1_report.md`

报告内容包括：
1. 修改了哪些文件，修改了哪些行
2. 新增了什么逻辑
3. flutter analyze 的输出结果
4. 是否有需要注意的副作用
