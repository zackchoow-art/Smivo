# Phase 8: 行程闭环（到达确认 + 评价 + 日历 + 免责声明）— Sonnet 执行指令

## 身份

你是 Sonnet，负责 Smivo 拼车模块的 **行程闭环** 实现。

## 边界（严格遵守）

### ✅ 你可以做

- 在 `app/lib/features/carpool/providers/` 下新建文件
- 在 `app/lib/features/carpool/screens/` 下新建文件
- 在 `app/lib/features/carpool/widgets/` 下新建文件
- 在 `supabase/migrations/` 下新建 migration SQL 文件
- 修改 `app/lib/data/repositories/carpool_repository.dart`（仅追加新方法，不修改现有方法）
- 修改 `app/lib/data/models/` 目录下新建新 model 文件（如评价 model）
- 修改 `app/lib/core/constants/app_constants.dart`（仅追加新常量）

### 🚫 你不可以做

- 修改 `app/lib/core/router/router.dart`
- 修改 Phase 7 创建的任何文件
- 修改非 carpool 的其他 feature 目录
- 修改任何 `pubspec.yaml`
- 删除任何已有文件或代码

---

## 背景

### 当前拼车状态机

```
active → departed → arrived → completed
active → cancelled
```

行程目前只有 `active` 和 `cancelled` 两个终态。你需要补充 `departed`、`arrived`、`completed` 状态流转。

### 已存在的关键代码

- **CarpoolTrip model** (`app/lib/data/models/carpool_trip.dart`):
  - 字段: id, creatorId, schoolId, status, role, departureAddress, destinationAddress, departureTime, estimatedArrivalTime, totalSeats, availableSeats, members（列表）, creator（UserProfile?）
- **CarpoolMember model** (`app/lib/data/models/carpool_member.dart`):
  - 字段: id, tripId, userId, status, user (UserProfile?)
- **CarpoolRepository** (`app/lib/data/repositories/carpool_repository.dart`):
  - 已有: fetchActiveTrips, fetchTripDetail, fetchMyTrips, createTrip, updateTrip, cancelTrip, fetchTripMembers, requestJoinTrip, approveMember, rejectMember, leaveTrip, createProposal, fetchProposals, castVote
  - `updateTrip(tripId, Map<String, dynamic> updates)` 可用于更新 status
- **AppConstants** (`app/lib/core/constants/app_constants.dart`):
  - 已有: tableCarpoolTrips, tableCarpoolMembers, tableCarpoolProposals, tableCarpoolVotes, tableGroupChatRooms, tableGroupChatMembers, tableGroupMessages
- **已安装依赖**: `add_2_calendar` (已在 pubspec.yaml)

### 你可以引用的 Provider

- `carpoolRepositoryProvider` — Repository 实例
- `supabaseClientProvider` — 获取 `currentUser?.id`
- `carpoolTripDetailProvider(tripId)` — 获取行程详情
- `profileProvider` — 获取当前用户 Profile

### 你可以引用的 Widget

- `SmivoUserAvatar` — `import 'package:smivo/shared/widgets/smivo_user_avatar.dart'`
  - 构造函数: `SmivoUserAvatar({required UserProfile user, double radius, bool enableTap})`
  - **不要使用 AvatarWidget，它不存在**

---

## 任务清单（按顺序执行）

### 任务 1: Database Migration — 评价表

在 `supabase/migrations/` 下创建新的 migration 文件。

**文件命名规则**: 当前最大编号 + 1，格式 `00XXX_carpool_reviews.sql`。先执行以下命令确定编号:
```bash
ls supabase/migrations/ | tail -5
```

**SQL 内容:**

```sql
-- Carpool reviews: N-to-N peer reviews after trip completion
CREATE TABLE IF NOT EXISTS public.carpool_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES public.carpool_trips(id) ON DELETE CASCADE,
  reviewer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reviewee_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Each reviewer can only review each reviewee once per trip
  CONSTRAINT unique_review_per_trip UNIQUE (trip_id, reviewer_id, reviewee_id),
  -- Cannot review yourself
  CONSTRAINT no_self_review CHECK (reviewer_id != reviewee_id)
);

-- Index for fetching reviews by trip
CREATE INDEX idx_carpool_reviews_trip ON public.carpool_reviews(trip_id);
-- Index for fetching a user's received reviews
CREATE INDEX idx_carpool_reviews_reviewee ON public.carpool_reviews(reviewee_id);

-- RLS: members of the trip can read all reviews for that trip
ALTER TABLE public.carpool_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Trip members can read reviews"
  ON public.carpool_reviews FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.carpool_members
      WHERE carpool_members.trip_id = carpool_reviews.trip_id
        AND carpool_members.user_id = auth.uid()
        AND carpool_members.status = 'approved'
    )
  );

CREATE POLICY "Members can create their own reviews"
  ON public.carpool_reviews FOR INSERT
  WITH CHECK (
    reviewer_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.carpool_members
      WHERE carpool_members.trip_id = carpool_reviews.trip_id
        AND carpool_members.user_id = auth.uid()
        AND carpool_members.status = 'approved'
    )
  );

-- Also add the missing status values to carpool_trips if not already present
-- (departed, arrived, completed)
-- The status column is TEXT, no enum constraint, so no ALTER needed.
```

**执行 migration:**
```bash
./supabase/scripts/run_migration.sh supabase/migrations/00XXX_carpool_reviews.sql
```

### 任务 2: Data Model — CarpoolReview

创建 `app/lib/data/models/carpool_review.dart`:

```dart
@freezed
abstract class CarpoolReview with _$CarpoolReview {
  const factory CarpoolReview({
    required String id,
    @JsonKey(name: 'trip_id') required String tripId,
    @JsonKey(name: 'reviewer_id') required String reviewerId,
    @JsonKey(name: 'reviewee_id') required String revieweeId,
    required int rating,
    String? comment,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // Joined data (reviewer profile, populated by select query)
    UserProfile? reviewer,
    UserProfile? reviewee,
  }) = _CarpoolReview;

  factory CarpoolReview.fromJson(Map<String, dynamic> json) =>
      _$CarpoolReviewFromJson(json);
}
```

**注意**: UserProfile import 路径是 `import 'package:smivo/data/models/user_profile.dart';`

### 任务 3: 更新 AppConstants

追加一行到 `app/lib/core/constants/app_constants.dart`:

```dart
static const tableCarpoolReviews = 'carpool_reviews';
```

### 任务 4: Repository 方法（追加到 carpool_repository.dart）

在 `CarpoolRepository` 类的末尾（`// ── Proposal queries` 部分之后）追加:

```dart
// ── Review queries ──────────────────────────────────────────────────────────

/// Submits a batch of reviews for a completed trip.
Future<void> submitReviews(List<Map<String, dynamic>> reviews) async {
  try {
    await _client
        .from(AppConstants.tableCarpoolReviews)
        .insert(reviews);
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}

/// Fetches all reviews for [tripId] with reviewer profiles joined.
Future<List<CarpoolReview>> fetchTripReviews(String tripId) async {
  try {
    final data = await _client
        .from(AppConstants.tableCarpoolReviews)
        .select('*, reviewer:user_profiles!reviewer_id(*), reviewee:user_profiles!reviewee_id(*)')
        .eq('trip_id', tripId)
        .order('created_at', ascending: true);
    return data.map((json) => CarpoolReview.fromJson(json)).toList();
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}

/// Fetches the average rating for a user across all carpool trips.
Future<double> fetchUserAverageRating(String userId) async {
  try {
    final data = await _client
        .from(AppConstants.tableCarpoolReviews)
        .select('rating')
        .eq('reviewee_id', userId);
    if (data.isEmpty) return 0.0;
    final total = data.fold<int>(0, (sum, row) => sum + (row['rating'] as int));
    return total / data.length;
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}

/// Marks a trip as departed.
Future<void> markDeparted(String tripId) async {
  await updateTrip(tripId, {'status': 'departed'});
}

/// Marks a trip as arrived.
Future<void> markArrived(String tripId) async {
  await updateTrip(tripId, {'status': 'arrived'});
}

/// Marks a trip as completed.
Future<void> markCompleted(String tripId) async {
  await updateTrip(tripId, {'status': 'completed'});
}
```

**记得在文件顶部追加 import:**
```dart
import 'package:smivo/data/models/carpool_review.dart';
```

### 任务 5: Provider — `carpool_lifecycle_provider.dart`

```
文件路径: app/lib/features/carpool/providers/carpool_lifecycle_provider.dart
```

包含三个 Provider:

#### `TripLifecycle`（AsyncNotifier）
- `build(String tripId)`: 返回 void
- `markDeparted()`: 调用 repo.markDeparted(tripId)，成功后 invalidate carpoolTripDetailProvider(tripId)
- `markArrived()`: 调用 repo.markArrived(tripId)，成功后同上 invalidate
- `markCompleted()`: 调用 repo.markCompleted(tripId)，成功后同上

#### `TripReviews`（AsyncNotifier）
- `build(String tripId)`: 调用 repo.fetchTripReviews(tripId) 返回 `List<CarpoolReview>`
- `submitReviews(tripId, List<Map<String, dynamic>> reviews)`:
  - 调用 repo.submitReviews(reviews)
  - 成功后 invalidateSelf()

#### `UserCarpoolRating`（Provider with family）
- `build(String userId)`: 调用 repo.fetchUserAverageRating(userId) 返回 double

### 任务 6: Widget — `legal_disclaimer_dialog.dart`

```
文件路径: app/lib/features/carpool/widgets/legal_disclaimer_dialog.dart
```

一个 StatelessWidget，使用 `AlertDialog`:
- 标题: "校园拼车免责声明"
- 内容: 5 条规则（用 Column + Row 排列）:
  1. "本拼车功能仅限校园互助出行，严禁非法营运或营利行为"
  2. "所有行程均由用户自行协商安排，平台不承担交通事故等任何责任"
  3. "请核实同行人身份，注意人身和财产安全"
  4. "发布虚假信息、恶意占座等行为将被封号处理"
  5. "使用本功能即表示您已阅读并同意以上条款"
- 操作按钮:
  - "不同意" TextButton → Navigator.pop(context, false)
  - "同意并继续" ElevatedButton → Navigator.pop(context, true)

提供静态方法:
```dart
static Future<bool> show(BuildContext context) async {
  return await showDialog<bool>(context: context, builder: (_) => const LegalDisclaimerDialog()) ?? false;
}
```

### 任务 7: Widget — `review_batch_sheet.dart`

```
文件路径: app/lib/features/carpool/widgets/review_batch_sheet.dart
```

一个 `ConsumerStatefulWidget` 底部弹窗，用于批量评价行程中的所有同行者。

**Props:**
- `String tripId`
- `List<CarpoolMember> members` — 全部 approved 成员（已过滤掉自己）

**UI:**
- 标题: "评价同行者"
- 每位成员一行:
  - SmivoUserAvatar + displayName
  - 5 颗星的打分 (1-5)，使用 `Row` of `IconButton(Icons.star / Icons.star_border)`
  - 可选评论 `TextField`
- 提交按钮: "提交评价"
  - 构建 reviews 列表: `[{trip_id, reviewer_id, reviewee_id, rating, comment}]`
  - 调用 `ref.read(tripReviewsProvider(tripId).notifier).submitReviews(tripId, reviews)`
  - 成功后 Navigator.pop + SnackBar

### 任务 8: Widget — `calendar_sync_button.dart`

```
文件路径: app/lib/features/carpool/widgets/calendar_sync_button.dart
```

一个 StatelessWidget 按钮，点击后将行程写入系统日历。

**Props:**
- `CarpoolTrip trip`

**逻辑:**
```dart
import 'package:add_2_calendar/add_2_calendar.dart';

void _syncToCalendar() {
  final event = Event(
    title: '拼车: ${trip.departureAddress} → ${trip.destinationAddress}',
    description: trip.note ?? '校园拼车行程',
    location: trip.departureAddress,
    startDate: trip.departureTime,
    endDate: trip.estimatedArrivalTime ?? trip.departureTime.add(const Duration(hours: 1)),
  );
  Add2Calendar.addEvent2Cal(event);
}
```

**UI:** `TextButton.icon(icon: Icons.calendar_month, label: "添加到日历", onPressed: _syncToCalendar)`

### 任务 9: Screen — `arrival_confirmation_screen.dart`

```
文件路径: app/lib/features/carpool/screens/arrival_confirmation_screen.dart
```

一个 `ConsumerWidget` 轻量页面，在用户到达目的地后引导确认。

**Props:**
- `String tripId`

**UI:**
1. 监听 `carpoolTripDetailProvider(tripId)`
2. 显示行程摘要卡片（出发 → 目的，时间）
3. "您已到达目的地吗？" 文本
4. 两个按钮:
   - "是的，已到达" ElevatedButton → 调用 `markArrived()` → 然后弹出 ReviewBatchSheet
   - "还没有" OutlinedButton → Navigator.pop

---

## 代码风格

1. 所有 Widget 继承 `ConsumerWidget` 或 `ConsumerStatefulWidget`
2. 使用 `ref.watch` + `AsyncValue.when` 处理异步状态
3. 注释用英文，UI 文案用中文
4. 使用 `@riverpod` 注解
5. 不使用 `withOpacity()`，改用 `withValues(alpha: )`
6. 不使用 `AvatarWidget`
7. freezed model 需要 `// ignore_for_file: invalid_annotation_target` 在文件第一行

## 生成代码

完成所有 Dart 文件后运行:
```bash
cd app && flutter pub run build_runner build
```

## 验证

```bash
cd app && flutter analyze lib/features/carpool/ lib/data/repositories/carpool_repository.dart lib/data/models/carpool_review.dart
```
确保 0 errors, 0 warnings。

## 完成报告

写入 `docs/agent_tasks/phase8_report.md`，包含:
1. 创建/修改的文件列表和行数
2. Migration 文件编号和是否成功执行
3. 遇到的问题或假设
4. 占位代码说明
5. 是否偏离指令
