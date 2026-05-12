# Phase 4: Carpool Trip Publishing UI — Gemini Pro 执行指令

## ⛔ 边界
- **只能创建/修改**下方列出的文件
- **不得**修改数据库、现有 model/repository、pubspec.yaml
- **不得**修改 `router.dart`（路由由 Opus 统一配置）
- **不得**运行 `build_runner`
- 所有 Widget 使用 `ConsumerWidget` 或 `ConsumerStatefulWidget`

## 📋 任务
创建拼车功能的发布、列表、详情三个核心 Screen 及相关 Widget 和 Provider。

## 📐 前置依赖
- Phase 1 (DB Schema) 已完成
- Phase 2 (Models + Repository) 已完成：
  - `CarpoolTrip`, `CarpoolMember` model 可用
  - `CarpoolRepository` 可用（通过 `ref.watch(carpoolRepositoryProvider)`）
- Phase 3 (Maps) 已完成：
  - `MapLocationPicker` widget 可用（`import 'package:smivo/core/maps/map_location_picker.dart'`）
  - `MapRoutePreview` widget 可用

## 📐 代码规范
- 使用 `ref.watch()` 读取状态，`ref.read()` 触发操作
- 所有异步操作用 `AsyncValue.when()` 处理 loading/data/error
- Widget 代码不超过 200 行，超出则提取子 Widget
- 使用 `Theme.of(context)` 获取主题色，不硬编码颜色
- 中文 UI 文案，英文代码注释

## 📁 需要创建的文件

### 1. `app/lib/features/carpool/providers/carpool_list_provider.dart`
```
@riverpod
class CarpoolList extends _$CarpoolList {
  // build() → fetchActiveTrips(schoolId)
  // refresh() → 刷新列表
}

@riverpod
class MyCarpool extends _$MyCarpool {
  // build() → fetchMyTrips(userId)
}
```

### 2. `app/lib/features/carpool/providers/carpool_detail_provider.dart`
```
@riverpod
class CarpoolDetail extends _$CarpoolDetail {
  // build(tripId) → fetchTripDetail(tripId)
  // cancelTrip()
}
```

### 3. `app/lib/features/carpool/providers/create_carpool_provider.dart`
```
@riverpod
class CreateCarpool extends _$CreateCarpool {
  // createTrip({role, departure, destination, time, seats, luggage, approval, closingTime, note})
  // 成功后 invalidate carpool list
}
```

### 4. `app/lib/features/carpool/screens/carpool_list_screen.dart`
拼车列表页面：
- AppBar: 标题「拼车广场」，右侧「+」按钮跳转创建页
- 列表使用 `ListView.builder`
- 每项使用 `CarpoolTripCard` widget
- 支持下拉刷新 `RefreshIndicator`
- 空状态提示：「暂无拼车信息，快来发布第一个吧！」
- Loading 用 `CircularProgressIndicator`
- Error 用 `Text(error.toString())` + 重试按钮

### 5. `app/lib/features/carpool/screens/create_carpool_screen.dart`
创建拼车页面（表单）：
- AppBar: 标题「发布拼车」
- 表单字段（顺序）：
  1. **角色选择**：两个 ChoiceChip —「我是司机」/「我是发起人（找人分摊）」
  2. **出发地点**：点击展开 `MapLocationPicker`，选择后显示地址文本
  3. **目的地**：同上
  4. **出发时间**：`DateTimePicker`，不早于当前时间
  5. **座位数**：Slider 或 DropdownButton，1-4
  6. **行李限额**：DropdownButton —「不限」/「仅小包」/「中等行李」/「大件行李」
  7. **审核模式**：Switch —「自动接受」/「手动审核」
  8. **截止报名时间**：可选，DateTimePicker
  9. **备注**：TextField, maxLines: 3
- 底部按钮：「发布拼车」，loading 态禁用
- 发布前弹出 `LegalDisclaimerDialog`（来自 Phase 8），用户同意后才提交
  - 如果 Phase 8 未完成，先用简单 `AlertDialog` 占位
- 发布成功后 SnackBar + 返回列表

### 6. `app/lib/features/carpool/screens/carpool_detail_screen.dart`
拼车详情页面：
- 顶部：路线预览（`MapRoutePreview` widget，iOS 显示地图，Web 显示文本卡片）
- 信息卡片：
  - 出发地 → 目的地（地址文本）
  - 出发时间（格式化显示）
  - 预计到达时间
  - 剩余座位：「2/4 座」
  - 行李限额
  - 审核模式
  - 备注
- 发起人信息卡片（头像 + 姓名 + 评分）
- 已加入成员列表（头像行）
- 底部操作按钮（根据身份不同显示不同按钮）：
  - 未加入用户：「申请加入」
  - 已申请等待中：「申请已提交，等待审核」（灰色禁用）
  - 已加入成员：「退出行程」
  - 发起人自己：「取消行程」+ 「管理成员」
- 日历同步按钮（`CalendarSyncButton`，Phase 8，先用占位）

### 7. `app/lib/features/carpool/widgets/carpool_trip_card.dart`
列表卡片 Widget：
- Props: `CarpoolTrip trip`, `VoidCallback? onTap`
- 显示：出发地 → 目的地（箭头连接）、出发时间、剩余座位、发起人头像+姓名
- 右侧角色标签：「司机」/「拼车」
- 圆角卡片，带阴影
- 点击跳转详情

### 8. `app/lib/features/carpool/widgets/member_avatar_row.dart`
成员头像行 Widget：
- Props: `List<CarpoolMember> members`, `int totalSeats`
- 横排显示已加入成员头像（CircleAvatar），空座位用虚线圆圈
- 显示文字「2/4 已加入」

### 9. `app/lib/features/carpool/widgets/seat_indicator.dart`
座位可视化 Widget：
- Props: `int available`, `int total`
- 用小圆点/图标表示座位状态（实心=已占、空心=可用）

## ✅ 完成报告
执行完成后，在 `docs/agent_tasks/phase4_report.md` 中写入：
1. 创建的文件列表和行数
2. 遇到的问题或假设
3. 占位代码说明（如 Phase 8 的组件未完成时的降级处理）
4. 是否偏离指令
