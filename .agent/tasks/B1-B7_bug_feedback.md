# B1-B7: Bug 上报 + 贡献值体系（App 端）

> 执行 Agent: Gemini 3.1 Pro
> 优先级: P1
> 预计修改/创建文件数: 12-15

---

## 整体功能

用户可以通过「摇一摇」或 Settings 入口快速提交 Bug 反馈或改进建议。
系统记录用户贡献值流水，在用户档案展示社区贡献等级。

---

## 执行边界（严格遵守）

### ✅ 允许创建/修改的文件
**数据库:**
- `supabase/migrations/00050_feedback_and_contributions.sql`

**Models（新建）:**
- `app/lib/data/models/user_feedback.dart`
- `app/lib/data/models/contribution_entry.dart`

**Repository（新建）:**
- `app/lib/data/repositories/feedback_repository.dart`

**Providers（新建）:**
- `app/lib/features/settings/providers/feedback_provider.dart`
- `app/lib/features/settings/providers/contribution_provider.dart`

**Screens（新建）:**
- `app/lib/features/settings/screens/submit_feedback_screen.dart`
- `app/lib/features/settings/screens/my_contributions_screen.dart`

**修改:**
- `app/lib/data/models/user_profile.dart` — 增加 contribution 字段
- `app/lib/features/settings/screens/settings_screen.dart` — 增加入口
- `app/lib/core/router/app_routes.dart` — 增加路由常量
- `app/lib/core/router/router.dart` — 增加路由配置
- `app/pubspec.yaml` — 增加 `feedback: ^3.1.0` 依赖（或最新版本，先 `flutter pub add feedback` 确认）

### ❌ 禁止修改的文件
- 任何 admin 相关文件
- listing/chat/orders 相关文件
- 任何已有 model 的 `.freezed.dart` 或 `.g.dart` 文件（不要删除）
- moderation 相关文件

---

## 子任务 B1: 数据库表

创建 `supabase/migrations/00050_feedback_and_contributions.sql`:

```sql
-- Migration 00050: Bug feedback system + contribution value ledger
-- Supports user feedback submission, admin processing, and contribution tracking.

-- ═══════════════════════════════════════════════════════
-- 1. User feedbacks table
-- ═══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.user_feedbacks (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    -- Type: 'bug', 'improvement', 'feature_request', 'other'
    type text NOT NULL DEFAULT 'bug' CHECK (type IN ('bug', 'improvement', 'feature_request', 'other')),
    -- Title: short summary
    title text NOT NULL,
    -- Description: detailed explanation
    description text NOT NULL,
    -- Screenshot URL (stored in Supabase Storage)
    screenshot_url text,
    -- Device info: OS, app version, screen size (auto-collected)
    device_info jsonb,
    -- Status: 'pending', 'in_review', 'resolved', 'rejected', 'duplicate'
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_review', 'resolved', 'rejected', 'duplicate')),
    -- Admin response (optional)
    admin_response text,
    -- Points awarded for this feedback (set by admin when resolving)
    points_awarded int NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Rate limiting: max 5 feedbacks per user per day (enforced by unique partial index)
-- NOTE: This is a soft limit; the hard limit is enforced in the app/Edge Function.
-- We track daily counts via query, not via index.

-- Index for fetching user's own feedbacks
CREATE INDEX IF NOT EXISTS idx_feedbacks_user ON public.user_feedbacks (user_id, created_at DESC);
-- Index for admin processing queue
CREATE INDEX IF NOT EXISTS idx_feedbacks_status ON public.user_feedbacks (status, created_at);

-- RLS
ALTER TABLE public.user_feedbacks ENABLE ROW LEVEL SECURITY;

-- Users can read their own feedbacks
CREATE POLICY "Users can read own feedbacks"
    ON public.user_feedbacks FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- Users can insert their own feedbacks
CREATE POLICY "Users can insert own feedbacks"
    ON public.user_feedbacks FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- ═══════════════════════════════════════════════════════
-- 2. Contribution ledger (流水账)
-- ═══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.contribution_ledger (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    -- Points change: positive = earned, negative = deducted
    points int NOT NULL,
    -- Source type for future extensibility (Plaza, etc.)
    source_type text NOT NULL CHECK (source_type IN (
        'feedback_resolved',    -- Bug feedback was resolved by admin
        'feedback_bonus',       -- Extra bonus from admin
        'admin_adjustment',     -- Manual admin adjustment
        'plaza_activity'        -- Future: Plaza interactions
    )),
    -- Reference to the source record (e.g. feedback ID)
    source_id uuid,
    -- Description of why points were awarded/deducted
    description text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_contribution_user ON public.contribution_ledger (user_id, created_at DESC);

-- RLS
ALTER TABLE public.contribution_ledger ENABLE ROW LEVEL SECURITY;

-- Users can read their own contribution history
CREATE POLICY "Users can read own contributions"
    ON public.contribution_ledger FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- ═══════════════════════════════════════════════════════
-- 3. Add contribution fields to user_profiles
-- ═══════════════════════════════════════════════════════
ALTER TABLE public.user_profiles
    ADD COLUMN IF NOT EXISTS contribution_score int NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS contribution_level int NOT NULL DEFAULT 1,
    ADD COLUMN IF NOT EXISTS last_active_at timestamptz;

-- Contribution level thresholds:
-- Lv.1: 0-49, Lv.2: 50-149, Lv.3: 150-299, Lv.4: 300-499, Lv.5: 500+
-- Level calculation is done in app or via a DB trigger (Phase 2).
```

**执行 SQL:**
```bash
./supabase/scripts/run_migration.sh supabase/migrations/00050_feedback_and_contributions.sql
```

---

## 子任务 B2: Models

### `app/lib/data/models/user_feedback.dart`

```dart
@freezed
abstract class UserFeedback with _$UserFeedback {
  const factory UserFeedback({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String type,
    required String title,
    required String description,
    @JsonKey(name: 'screenshot_url') String? screenshotUrl,
    @JsonKey(name: 'device_info') Map<String, dynamic>? deviceInfo,
    @Default('pending') String status,
    @JsonKey(name: 'admin_response') String? adminResponse,
    @JsonKey(name: 'points_awarded') @Default(0) int pointsAwarded,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserFeedback;

  factory UserFeedback.fromJson(Map<String, dynamic> json) =>
      _$UserFeedbackFromJson(json);
}
```

### `app/lib/data/models/contribution_entry.dart`

```dart
@freezed
abstract class ContributionEntry with _$ContributionEntry {
  const factory ContributionEntry({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required int points,
    @JsonKey(name: 'source_type') required String sourceType,
    @JsonKey(name: 'source_id') String? sourceId,
    required String description,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ContributionEntry;

  factory ContributionEntry.fromJson(Map<String, dynamic> json) =>
      _$ContributionEntryFromJson(json);
}
```

### 修改 `app/lib/data/models/user_profile.dart`

在 `sellerRatingCount` 之后、闭合括号之前添加：

```dart
    // -- Community Contribution --
    @JsonKey(name: 'contribution_score') @Default(0) int contributionScore,
    @JsonKey(name: 'contribution_level') @Default(1) int contributionLevel,
    @JsonKey(name: 'last_active_at') DateTime? lastActiveAt,
```

---

## 子任务 B3-B4: Repository + Provider + 反馈提交页

### Repository: `app/lib/data/repositories/feedback_repository.dart`

提供方法：
- `submitFeedback(userId, type, title, description, screenshotUrl?, deviceInfo?)` — INSERT
- `fetchMyFeedbacks(userId)` — SELECT 自己的反馈列表
- `fetchMyContributions(userId)` — SELECT 贡献流水
- `getTodayFeedbackCount(userId)` — COUNT 今日提交数（用于客户端限流）

### Provider: `app/lib/features/settings/providers/feedback_provider.dart`

- `MyFeedbacksProvider` — AsyncNotifier，获取我的反馈列表
- `SubmitFeedbackAction` — Notifier，处理提交逻辑（含每日 5 条限制）

### Provider: `app/lib/features/settings/providers/contribution_provider.dart`

- `MyContributionsProvider` — AsyncNotifier，获取贡献流水
- 计算等级的纯函数：`int calculateLevel(int score)` — Lv.1: 0-49, Lv.2: 50-149, Lv.3: 150-299, Lv.4: 300-499, Lv.5: 500+

### Screen: `app/lib/features/settings/screens/submit_feedback_screen.dart`

UI 要求：
- 类型选择：SegmentedButton 或 Chip（Bug / Improvement / Feature Request / Other）
- 标题输入框
- 描述输入框（多行）
- 截图附加按钮（从相册选择或相机拍摄，上传到 `order-files` bucket 的 `feedbacks/` 子目录）
- 自动收集设备信息（OS、App 版本）存入 device_info JSON
- 提交按钮 + loading 状态 + 成功弹窗
- 每日限流：提交前检查今日已提交数，>=5 则提示「今日提交已达上限」
- 使用 `context.smivoColors` 和 `context.smivoTypo` 主题系统

### Screen: `app/lib/features/settings/screens/my_contributions_screen.dart`

UI 要求：
- 顶部卡片：总分 + 当前等级（🎖️ Lv.X）+ 距离下一级差多少分
- 下方流水列表：日期 + 描述 + 积分变动（绿色正数，红色负数）
- 空状态提示
- 使用 `context.smivoColors` 和 `context.smivoTypo` 主题系统

---

## 子任务 B5-B6: 路由 + Settings 入口 + 用户档案双标签

### 路由

在 `app_routes.dart` 中添加：
```dart
static const String submitFeedback = 'submitFeedback';
static const String submitFeedbackPath = '/feedback/submit';
static const String myContributions = 'myContributions';
static const String myContributionsPath = '/contributions';
```

在 `router.dart` 中添加对应的 GoRoute 配置（同级于 settings）。

### Settings 入口

在 `settings_screen.dart` 中添加两个新的列表项：
- 🐛 Report a Bug → 跳转到 `submitFeedbackPath`
- 🎖️ My Contributions → 跳转到 `myContributionsPath`

放在 Help Center 附近。

### 用户档案双标签（展示）

在用户信息展示的地方（如卖家卡片、Profile 页面），显示两个标签：
- 💼 交易信用 ⭐ X.X（来自 buyer_rating / seller_rating）
- 🎖️ 社区贡献 Lv.X（来自 contribution_level）

**注意：** 这个修改范围较大，涉及多个 screen 的卖家卡片。本次只在以下位置添加：
1. `settings_screen.dart` 顶部用户信息区域
2. 不要修改 listing_detail 等其他页面（避免越界）

---

## 代码生成与验证

1. 运行 SQL migration：
   ```bash
   ./supabase/scripts/run_migration.sh supabase/migrations/00050_feedback_and_contributions.sql
   ```

2. 安装新依赖：
   ```bash
   cd app && flutter pub add feedback
   ```
   注意：`feedback` 包用于摇一摇反馈。如果版本冲突，先检查兼容版本。

3. 运行代码生成（仅为新建的 model 和 provider 生成）：
   ```bash
   cd app && dart run build_runner build --build-filter="lib/data/models/user_feedback.g.dart" --build-filter="lib/data/models/user_feedback.freezed.dart" --build-filter="lib/data/models/contribution_entry.g.dart" --build-filter="lib/data/models/contribution_entry.freezed.dart" --build-filter="lib/data/models/user_profile.g.dart" --build-filter="lib/data/models/user_profile.freezed.dart" --build-filter="lib/data/repositories/feedback_repository.g.dart" --build-filter="lib/features/settings/providers/feedback_provider.g.dart" --build-filter="lib/features/settings/providers/contribution_provider.g.dart" --delete-conflicting-outputs
   ```
   ⚠️ **不要使用不带 --build-filter 的全局 build_runner**，会删除其他 .g.dart 文件！

4. 代码检查：
   ```bash
   cd app && flutter analyze --no-fatal-infos
   ```

5. 写入报告到 `.agent/tasks/B1-B7_report.md`

## ⚠️ 关键注意事项
- **不要删除任何已有的 .g.dart 或 .freezed.dart 文件**
- **不要修改 pubspec.yaml 中已有的依赖版本**
- **不要修改 listing/chat/orders 相关文件**
- build_runner 必须使用 `--build-filter` 参数，只生成新增文件
