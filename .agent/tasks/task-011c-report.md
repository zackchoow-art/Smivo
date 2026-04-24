# Task 011c Report: Rental Expiry Reminders (Batch 3)

## 任务目标
实现租赁到期提醒系统，包括：
1. 订单级别的提醒偏好设置（提前天数、邮件开关）。
2. 数据库自动检查逻辑（pg_cron + SQL function）。
3. 买家端配置 UI。

## 完成项

### 1. 数据库与后端逻辑
- **SQL 迁移**: 创建并执行了 `00028_rental_reminders.sql`。
  - 在 `orders` 表中新增了 `reminder_days_before` (默认 1), `reminder_email` (默认 false), `reminder_sent` (默认 false) 三个字段。
  - 更新了 `notifications` 表的 `type` 约束，增加了 `rental_reminder` 类型。
  - 实现了 `check_rental_reminders()` 函数，用于寻找即将到期的活跃租赁订单并生成通知。
  - 实现了 `reset_rental_reminder()` 触发器，确保在租赁展期（结束日期变更）后能再次触发提醒。

### 2. 数据层实现
- **Model**: 更新了 `Order` 模型，增加了三个提醒相关的字段，并重新生成了代码。
- **Repository**: 在 `OrderRepository` 中新增了 `updateReminderPreferences` 方法。
- **Provider**: 在 `OrderActions` Notifier 中新增了 `updateReminderPreferences` 方法，支持 UI 层的偏好更新。

### 3. UI 界面集成
- **RentalReminderSettings**: 开发了全新的设置组件：
  - **偏好配置**: 买家可以设置提前 1, 2, 3, 5, 7 天接收提醒。
  - **邮件开关**: 提供了邮件通知的开关（功能预留）。
  - **保存逻辑**: 只有在设置发生变化时才显示“保存”按钮，并提供保存状态反馈。
  - **状态展示**: 如果提醒已发送，会显示明确的已发送标识；否则显示预期的提醒日期。
- **页面集成**: 将 `RentalReminderSettings` 成功集成到 `RentalOrderDetailScreen`（仅限买家，且订单处于活跃状态）。

### 4. 代码质量与规范
- 运行 `flutter analyze` 结果为 **零 Error/Warning**。
- 样式完全遵循 `SmivoThemeExtension` 令牌。
- 使用 `DropdownButtonFormField` 和 `Checkbox` 提供标准的配置体验。

## 测试建议
1. 以买家身份登录，进入 Active 状态的租赁订单详情页。
2. 更改提醒天数并保存，验证数据库中字段已更新。
3. 验证卖家无法看到此设置卡片。
4. 手动运行 `SELECT public.check_rental_reminders();` 验证函数逻辑（当前应返回 0）。
