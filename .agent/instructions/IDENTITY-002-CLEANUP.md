# 任务指令：全局用户 UI 清理与替换 (TASK-ID: IDENTITY-002)

## 1. 任务背景
在 `SmivoUserIdentity` 组件创建后，需要将 App 中所有零散、硬编码的用户信息展示块替换为统一组件。

## 2. 执行边界 (Boundaries)
- **依赖性**：必须在 `IDENTITY-001` 任务完成后执行。
- **功能对齐**：替换过程严禁删除原有的功能逻辑（如：消息按钮、身份标签）。
- **回归测试**：替换后必须运行 `flutter analyze` 确保无编译错误。

## 3. 具体替换清单

### A. 订单详情页重构 (`app/lib/features/orders/widgets/order_info_section.dart`)
- **操作**：找到 `_buildUserRow` 方法。
- **替换内容**：将内部手写的 `CircleAvatar` 和文本 Column 整体替换为 `SmivoUserIdentity`。
- **注意**：保留最左侧的 `Buyer/Seller` 身份容器。

### B. 卖家卡片重构 (`app/lib/features/listing/widgets/seller_profile_card.dart`)
- **操作**：将整个卡片内容替换为 `SmivoUserIdentity`。
- **注意**：确保“最后上线时间”标签现在整合在组件内部，位置需符合 `user_identity_refactor_plan.md` 提到的“与评分同行”的设计。

### C. 全局清理
- 搜索 `CircleAvatar` 在 `features/` 下的 17 处使用。
- 凡是属于“展示用户个人资料”场景的，一律替换为 `SmivoUserAvatar` 或 `SmivoUserIdentity`。

## 4. 执行报告要求
- 请将执行报告保存为：`.agent/reports/REPORT_IDENTITY_002_CLEANUP.md`。
- 报告中需包含：
    1. 涉及修改的文件列表。
    2. 针对 `order_info_section.dart` 替换前后的代码对比 (Diff)。
    3. `flutter analyze` 的结果确认。
