# TASK-ID: IDENTITY-001 - Smivo 用户身份核心组件实现报告

## 1. 新建组件及核心逻辑说明

- **`app/lib/shared/widgets/smivo_user_avatar.dart`**
  该文件实现了带有在线状态和复用交互的统一头像组件。
  - **核心逻辑**：基于 `UserProfile` 对象的 `lastActiveAt` 属性计算，如果该属性非空且与当前时间的差值在 10 分钟以内，即认为在线。
  - **视觉处理**：在线时头像显示为正常网络图片（或缺省人物图标），并在右上角添加一个 10px 绿点；离线状态下，绿点变为灰点，同时使用 `ColorFiltered` 组件加上 `ColorFilter.matrix` 的灰度滤镜来使头像变为黑白。
  - **交互**：包装了 `GestureDetector`，点击头像时通过 `showModalBottomSheet` 展示通用的 `UserReviewsBottomSheet`（支持通过可选参数 `role` 决定要展示的身份评价数据，默认为 'seller'）。

- **`app/lib/shared/widgets/smivo_user_identity.dart`**
  该文件实现了统一的用户信息卡片展示组件，集成在需要展示卖家/买家信息的场景中。
  - **核心逻辑**：左侧嵌套 `SmivoUserAvatar`（并传递相关的 `role`）。中间紧凑地展示用户的 `displayName` (TitleMedium) 与 `email` (BodySmall)，并在最下侧集成了原有的评价徽章 `UserRatingBadge`。右侧支持传入可选的功能按钮 `actionIcon` 和点击回调 `onActionTap`。
  - **样式支持**：暴露了 `showBackground` 参数，当设置为 `true` 时，外层会包覆一个带有边框、圆角和背景色（`surfaceContainerLowest`）的 `Container` 容器，适配不同 UI 场景（如独立卡片 vs 列表项）。

## 2. 状态计算逻辑的单元测试建议

关于“在线状态”的计算逻辑 (`DateTime.now().difference(user.lastActiveAt!).inMinutes <= 10`)，目前是在 Widget 内部计算，若追求更高测试覆盖率，建议在未来将其提取到 `UserProfile` 的 extension 中。实施单元测试时的建议如下：

1. **刚好在线的情况**：将 `lastActiveAt` mock 为 `DateTime.now().subtract(const Duration(minutes: 9, seconds: 59))`，断言在线状态计算为 `true`。
2. **刚好离线的情况**：将 `lastActiveAt` mock 为 `DateTime.now().subtract(const Duration(minutes: 10, seconds: 1))`，断言在线状态计算为 `false`。
3. **缺少时间数据的情况**：当 `lastActiveAt == null` 时，断言系统能正确处理并默认渲染为离线（`false`）。
4. **异常时间处理**：模拟客户端设备时间由于某种原因导致 `lastActiveAt` 在未来，确保系统不抛出崩溃并将其作为正常在线处理。

## 3. 组件视觉表现描述

两款组件已严格遵循 `context.smivoColors` 和 `context.smivoTypo` 的设计系统令牌，没有写死任何颜色：
- **Light 模式下**：
  - **头像 (Avatar)**：缺省背景为 `surfaceContainerHigh`（浅灰），离线状态由于套用了黑白灰度滤镜，整体对比度降低，视觉上产生退散感。
  - **身份卡片 (Identity)**：开启背景卡片模式下，呈现极浅色底板（`surfaceContainerLowest`）和极其柔和的边框（`outlineVariant`，50% 透明度）。主标题的用户名使用高对比度 `onSurface`，次要信息使用中度对比度 `onSurfaceVariant`，层级分明。
- **Dark 模式下**：
  - 令牌系统自动响应，`surfaceContainerLowest` 会表现为近黑色背景。
  - 所有的文字颜色和占位图标都会等同比例变成浅色，边框会自动适配暗色。
  - **离线滤镜** 依然生效，不论背景是黑是白，“在线绿点+彩色图像”与“离线灰点+黑白图像”的强反差能够在所有的主题中保证高辨识度。
