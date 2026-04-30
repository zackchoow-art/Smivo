# P1-2: 举报功能增强

> 执行 Agent: Gemini 3.1 Pro
> 优先级: P1
> 预计修改文件数: 5-7

---

## 执行边界（严格遵守）

### ✅ 允许修改的文件
- `supabase/migrations/` — 新建 migration SQL 文件
- `app/lib/data/repositories/moderation_repository.dart` — 增加防重复检查方法
- `app/lib/data/models/content_report.dart` — 如需调整 model
- `app/lib/core/providers/moderation_provider.dart` — 增加防重复检查逻辑
- `app/lib/features/listing/screens/listing_detail_screen.dart` — 修改举报 UI 为预设选项
- `app/lib/features/chat/screens/chat_room_screen.dart` — 修改举报 UI 为预设选项

### ❌ 禁止修改的文件
- 路由配置 (`router.dart`, `app_routes.dart`)
- 任何其他 feature 的文件
- `pubspec.yaml`
- 任何 model 的 freezed 注解以外的逻辑

---

## 子任务 2b: 防重复提交

### 数据库变更
创建 `supabase/migrations/00048_report_unique_constraint.sql`:

```sql
-- Add unique constraint to prevent duplicate reports per user per target
-- A user can only report the same listing or user once
ALTER TABLE public.content_reports
  ADD CONSTRAINT unique_report_per_target
  UNIQUE NULLS NOT DISTINCT (reporter_id, reported_user_id, listing_id, chat_room_id);
```

> 注意: `NULLS NOT DISTINCT` 让 NULL 被视为相等值，这样同一个 reporter + reported_user（listing_id=NULL, chat_room_id=NULL）只能存在一条记录。需要 PostgreSQL 15+，Supabase 已支持。

### Repository 变更
在 `moderation_repository.dart` 增加一个方法检查是否已举报：

```dart
/// Checks if the current user has already reported a specific target.
Future<bool> hasAlreadyReported({
  required String reporterId,
  required String reportedUserId,
  String? listingId,
  String? chatRoomId,
}) async {
  try {
    var query = _client
        .from('content_reports')
        .select('id')
        .eq('reporter_id', reporterId)
        .eq('reported_user_id', reportedUserId);
    
    if (listingId != null) {
      query = query.eq('listing_id', listingId);
    } else {
      query = query.isFilter('listing_id', null);
    }
    
    if (chatRoomId != null) {
      query = query.eq('chat_room_id', chatRoomId);
    } else {
      query = query.isFilter('chat_room_id', null);
    }
    
    final data = await query.limit(1);
    return data.isNotEmpty;
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}
```

### Provider 变更
在 `moderation_provider.dart` 的 `reportContent` 方法中，先调用 `hasAlreadyReported`，如果已存在则抛出异常或返回 false。

### UI 变更
在 `listing_detail_screen.dart` 和 `chat_room_screen.dart` 的举报弹窗中：
- 先调用检查方法
- 如果已举报，显示 SnackBar: "You have already reported this content."
- 不打开举报对话框

同时，在 `reportContent` 中捕获 PostgreSQL 23505 错误码（unique_violation），转为用户友好提示。

---

## 子任务 2a: 预设举报原因

### 数据库变更
在 **同一个** migration 文件 `00048_report_unique_constraint.sql`（或新建 `00049_report_reasons.sql`）中添加：

```sql
-- Add a reason_category column for preset reasons
ALTER TABLE public.content_reports
  ADD COLUMN IF NOT EXISTS reason_category text;

-- Insert preset report reasons into help_faqs or a new table
-- Using a simple approach: hardcode in the app, store selected + custom text in DB
```

> 建议: 举报原因不需要数据字典表（会过度工程化）。直接在 Flutter 端硬编码 6-8 个预设选项即可，选中的值存入 `reason_category` 字段，用户额外输入存 `reason` 字段。

### 预设原因列表（硬编码在 Flutter 中）
```dart
const List<String> reportReasons = [
  'Spam or misleading',
  'Inappropriate content',
  'Suspected scam',
  'Harassment or bullying',
  'Prohibited item',
  'Counterfeit or stolen',
  'Wrong category',
  'Other',
];
```

### UI 变更
将当前的 TextField 自由输入改为：
1. 一个 `ListView` 或 `Column` of `RadioListTile`，展示预设原因
2. 当选择 "Other" 时，显示一个额外的 TextField 让用户填写
3. 选中的 category 存入 `reason_category`，自定义文本存入 `reason`
4. 至少要选择一个原因才能提交（Submit 按钮 disabled 直到选择）

### 两个举报入口都需修改
1. `listing_detail_screen.dart` 第 1194-1264 行 — Report Listing 弹窗
2. `chat_room_screen.dart` 的举报入口 — Report User/Chat 弹窗

建议: 抽取一个共享的 `ReportDialog` widget 到 `app/lib/shared/widgets/report_dialog.dart`，避免在两个文件中重复代码。这个 widget 接收参数：
- `title` (e.g. "Report Listing" / "Report User")
- `onSubmit(String reasonCategory, String? customReason)` callback

---

## 执行完成后必须做的事

1. 如果新增了 SQL migration 文件，使用以下命令执行：
   ```bash
   ./supabase/scripts/run_migration.sh supabase/migrations/00048_report_unique_constraint.sql
   ```

2. 如果修改了 model (freezed)，运行代码生成：
   ```bash
   cd app && dart run build_runner build --delete-conflicting-outputs
   ```

3. 运行代码检查（必须在 app 文件夹下执行）：
   ```bash
   cd app && flutter analyze --no-fatal-infos
   ```

4. 生成执行报告写入 `.agent/tasks/P1-2_report.md`，包含：
   - 修改的文件列表和变更描述
   - flutter analyze 结果
   - 需要手动操作的步骤（如有）
