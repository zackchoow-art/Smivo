# Phase 8: Post-Trip Features — Sonnet 执行指令

## ⛔ 边界
- **只能创建/修改**下方列出的文件
- **不得**修改任何数据库 migration、现有 model、现有 repository
- **不得**修改 `pubspec.yaml`（`add_2_calendar` 已由 Phase 3 添加）
- **不得**运行 `build_runner`

## 📋 任务
实现拼车行程结束后的三个功能：到达确认、N-to-N 互评、系统日历集成。

## 📐 前置依赖
- Phase 1~7 已完成
- `carpool_repository.dart` 中已有 `confirmArrival()` 和 `submitCarpoolReview()` 方法
- `app/lib/data/models/carpool_trip.dart` 已有 `CarpoolTrip` model
- `app/lib/data/models/carpool_member.dart` 已有 `CarpoolMember` model
- `add_2_calendar` 包已在 `pubspec.yaml` 中

## 📁 需要创建的文件

### 1. `app/lib/features/carpool/screens/carpool_arrival_screen.dart`
到达确认页面：
- 页面显示行程摘要（出发地 → 目的地、出发时间）
- 大标题：「你已到达目的地了吗？」
- 两个按钮：「是，已到达」/「还没有」
- 点击「是」调用 `carpoolRepository.confirmArrival(tripId, userId)`
- 确认后自动跳转到互评页面
- 遵循现有 Screen 模板：使用 `ConsumerWidget`，`ref.watch` 获取数据

### 2. `app/lib/features/carpool/screens/carpool_review_screen.dart`
N-to-N 批量互评页面：
- 页面标题：「评价你的拼车伙伴」
- 展示该行程的所有其他成员列表（排除自己）
- 每位成员一个评价卡片：
  - 用户头像 + 姓名
  - 5 星评分选择器（必填）
  - 可选文字评论输入框
- 底部提交按钮，一次性提交所有评价
- 调用 `carpoolRepository.submitCarpoolReview()` 逐个提交
- 提交成功后 SnackBar 提示并返回

### 3. `app/lib/features/carpool/widgets/carpool_review_card.dart`
单个成员评价卡片 Widget：
- Props: `UserProfile user`, `int rating`, `String? comment`, callbacks
- 星星用 `Icon(Icons.star)` / `Icon(Icons.star_border)`，点击可选 1-5
- 评论用 `TextField`，maxLines: 3

### 4. `app/lib/features/carpool/widgets/calendar_sync_button.dart`
日历同步按钮 Widget：
- 使用 `add_2_calendar` 包
- Props: `CarpoolTrip trip`
- 按钮文字：「添加到日历」
- 点击后创建 `Event`：
  - title: '拼车: {departure} → {destination}'
  - startDate: trip.departureTime
  - endDate: trip.estimatedArrivalTime ?? trip.departureTime + 1h
  - location: trip.destinationAddress
- 使用 `Add2Calendar.addEvent2Cal(event)` 写入系统日历
- 同步成功后 SnackBar 提示

### 5. `app/lib/features/carpool/widgets/legal_disclaimer_dialog.dart`
法律免责声明弹窗 Widget：
- 标题：「校园互助免责声明」
- 内容（中英双语）：
  - 本平台仅提供信息匹配服务，不构成运输合同
  - 严禁非法营运和营利行为
  - 参与者应确保具备合法驾驶资格和有效保险
  - 平台不对行程中发生的任何事故或纠纷承担责任
  - 使用即表示同意以上条款
- 底部两个按钮：「不同意」（关闭）/「同意并继续」（回调）
- 用 `showDialog` 呈现，返回 `bool`

### 6. `app/lib/features/carpool/providers/carpool_review_provider.dart`
互评状态管理 Provider：
- `carpoolReviewProvider(tripId)` — AsyncNotifier
- 方法：
  - `loadReviewableMembers(tripId)` — 获取需要评价的成员列表
  - `submitReviews(tripId, List<{userId, rating, comment}>)` — 批量提交
- 状态：loading / data / error

## ✅ 完成报告
执行完成后，在 `docs/agent_tasks/phase8_report.md` 中写入：
1. 创建的文件列表
2. 每个文件的行数
3. 任何假设或问题
4. 是否偏离指令
