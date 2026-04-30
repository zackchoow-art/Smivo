# Execution Report: D1-D3 用户在线状态系统

## 完成情况

### 1. 数据库配置
- 成功创建并执行了迁移脚本 `00051_user_heartbeat.sql`。
- 创建了轻量级的 `user_heartbeats` 表，使用 `UPSERT` (ON CONFLICT UPDATE) 模式进行数据维护以保持每个用户一条记录。
- 创建了 `update_last_active` 函数和 `trg_heartbeat_update_profile` 触发器，在接收到心跳时自动更新 `user_profiles` 表的 `last_active_at` 字段。
- 设置了对应的 Row Level Security (RLS) 策略，任何认证用户均可读取心跳信息，但只能写入/更新自己的心跳信息。

### 2. 代码和逻辑变更
- 在 `app_constants.dart` 中新增了 `tableUserHeartbeats` 静态常量。
- 在 `profile_repository.dart` 中实现了两个新方法：
  - `sendHeartbeat`: 利用 upsert 操作更新在线时间和设备平台信息。
  - `getLastActiveAt`: 帮助抓取用户的最后活动时间（备用或未来拓展功能）。
- 创建了 `heartbeat_provider.dart`，包含 `HeartbeatManager` Provider：
  - 利用 `AppLifecycleListener` 监听页面生命周期，App 退到后台时暂停心跳，返回前台时恢复心跳。
  - 前台状态下默认每 5 分钟向 Supabase 发起一次心跳更新。
  - 静默处理网络请求失败错误，避免影响正常用户体验。

### 3. UI 呈现
- 创建了 `LastActiveBadge` 组件 (`app/lib/shared/widgets/last_active_badge.dart`)：
  - 根据最后活动时间计算时间差，10分钟内显示绿色的 `Online`。
  - 大于10分钟则利用 `timeago` 组件渲染出形如 "5m ago", "2h ago" 的字样。
- 修改了 `seller_profile_card.dart`，在用户的邮箱下方成功集成了 `LastActiveBadge` 组件以展示卖家的最新在线状态。
- 在 `home_screen.dart` 的 build 流程中植入了 `ref.watch(heartbeatManagerProvider);`，保证只有当用户进入到主 App 模块且登录时激活心跳系统。

### 4. 代码生成和检查
- 利用 `--build-filter="lib/core/providers/heartbeat_provider.g.dart"` 成功独立生成了相应的 Riverpod 文件，避开了原有的生成冲突。
- 经过 `flutter analyze` 验证，该部分新代码不存在报错，系统编译稳定。

本阶段 P1 优先级的用户在线状态上报与展示功能已经完全按照执行边界和要求完成开发。
