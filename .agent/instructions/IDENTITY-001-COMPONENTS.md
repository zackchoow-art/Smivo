# 任务指令：Smivo 用户身份核心组件实现 (TASK-ID: IDENTITY-001)

## 1. 任务背景
统一 App 内的用户展示逻辑。目前用户信息（头像、名称）分散在各个 Widget 中，且缺乏在线状态反馈。

## 2. 执行边界 (Boundaries)
- **只读原则**：严禁修改 `UserProfile` 模型或 Repository 层的业务逻辑。
- **UI 规范**：必须使用 `context.smivoColors` 和 `context.smivoTypo` 提供的设计令牌，严禁硬编码颜色值。
- **文件位置**：新组件必须放在 `app/lib/shared/widgets/` 目录下。

## 3. 具体实施要求

### A. 创建 `app/lib/shared/widgets/smivo_user_avatar.dart`
- **输入参数**：`UserProfile user`, `double radius` (默认 20)。
- **在线状态显示**：
    - 定义“在线”为 `lastActiveAt` 在 10 分钟以内。
    - 在线：右上角显示 10px 的绿点 (`Colors.green`)，头像正常。
    - 离线：右上角显示 10px 的灰点 (`Colors.grey`)，头像应用灰度滤镜 (`ColorFilter.matrix` 或 `Greyscale` 效果)。
- **交互**：点击头像应弹出 `UserReviewsBottomSheet` (复用 `user_rating_badge.dart` 的逻辑)。

### B. 创建 `app/lib/shared/widgets/smivo_user_identity.dart`
- **输入参数**：`UserProfile user`, `String? label`, `VoidCallback? onActionTap`, `IconData? actionIcon`。
- **布局要求**：
    - 左侧使用 `SmivoUserAvatar`。
    - 中间显示 `displayName` (TitleMedium) 和 `email` (BodySmall)。
    - 下方集成现有的 `UserRatingBadge`。
- **适配**：支持参数控制是否显示背景卡片（适配订单页 vs 搜索页）。

## 4. 执行报告要求
- 请将执行报告保存为：`.agent/reports/REPORT_IDENTITY_001_COMPONENTS.md`。
- 报告中需包含：
    1. 新建文件的路径及核心逻辑说明。
    2. 针对“在线状态”计算逻辑的单元测试建议。
    3. 截图或描述组件在 Light/Dark 模式下的视觉表现。
