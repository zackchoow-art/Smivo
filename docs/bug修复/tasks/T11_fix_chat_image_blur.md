# T11: 修复聊天图片模糊处理不生效问题

## 背景

AI 审核管道已恢复（migration 00128），`backend_moderation_logs` 中已正确记录了
违规图片（result='fail', action_taken='blur'）。但 app 端 `ModerationAwareImage`
组件没有对聊天中的违规图片进行模糊处理。

## 根因分析（已确认）

有 **两个** 独立的问题导致图片模糊不生效：

### 问题 1：RLS 阻止普通用户读取 moderation logs（致命）

文件：`supabase/migrations/00094_backend_moderation_infrastructure.sql` (第 60-64 行)

```sql
CREATE POLICY "Admin users can read moderation logs"
  ON public.backend_moderation_logs FOR SELECT
  USING ( public.is_admin_user() );
```

`backend_moderation_logs` 的 SELECT RLS 策略只允许管理员读取。
`FlaggedImageUrlsProvider`（`app/lib/core/providers/moderation_provider.dart` 第 217-269 行）
查询此表时，普通用户得到 **空结果集** → `ModerationAwareImage` 永远判断为 "未标记" → 不模糊。

### 问题 2：ImageModerationMode provider 查询列名错误（非致命但需修）

文件：`app/lib/core/providers/moderation_provider.dart` 第 186-206 行

```dart
final data = await supabase
    .from('system_configs')
    .select('value')                          // ❌ 实际列名是 config_value
    .eq('key', 'image_moderation_mode')       // ❌ 实际列名是 config_key
    .maybeSingle();
```

`system_configs` 表的列名是 `config_key` 和 `config_value`，不是 `key` 和 `value`。
查询永远返回 null → 永远 fallback 到 `'blur'`。
目前默认行为碰巧是对的，但当管理员设置 `auto_reject` 时这里不会生效。

## 修复任务

### 任务 1：添加 RLS 策略允许用户读取自己的审核记录

写一个新 migration SQL 文件 `supabase/migrations/00129_allow_user_read_own_moderation_logs.sql`。

添加一条新的 SELECT 策略：**用户只能读取自己内容的审核记录**（`user_id = auth.uid()`）。

```sql
CREATE POLICY "Users can read own moderation logs"
  ON public.backend_moderation_logs FOR SELECT
  USING ( auth.uid() = user_id );
```

**注意**：保留原来的管理员策略不变，新增这条即可（OR 关系）。

### 任务 2：修复 ImageModerationMode provider 的列名

文件：`app/lib/core/providers/moderation_provider.dart`

将第 193-195 行的查询从：
```dart
.select('value')
.eq('key', 'image_moderation_mode')
```

改为：
```dart
.select('config_value')
.eq('config_key', 'image_moderation_mode')
```

同时修复第 198 行的解析：
```dart
final value = data?['value'] as String?;
```
改为：
```dart
final value = data?['config_value'] as String?;
```

### 任务 3：确保 `image_moderation_mode` 配置存在于数据库

检查 `system_configs` 表中是否存在 `config_key = 'image_moderation_mode'` 的行。
如果不存在，在 migration 00129 中一起添加：

```sql
INSERT INTO public.system_configs (config_key, config_value, description)
VALUES ('image_moderation_mode', '"blur"'::jsonb,
  'How to handle AI-flagged images on client: blur | auto_reject')
ON CONFLICT (config_key) DO NOTHING;
```

### 任务 4：验证 FlaggedImageUrlsProvider 的 RLS 兼容性

文件：`app/lib/core/providers/moderation_provider.dart` 第 229-233 行

确认这个查询在添加新 RLS 策略后能正确返回数据：

```dart
final data = await supabase
    .from('backend_moderation_logs')
    .select('content_snapshot, image_details')
    .eq('result', 'fail')
    .limit(500);
```

**检查点**：新策略加了 `user_id = auth.uid()` 限制，这意味着用户只能看到
**自己发送的** 违规图片的记录。但对于 **接收方**（看到对方发来的违规图片），
他们的 `user_id` 不是日志中的 `user_id`（日志记录的是发送者）。

**这是一个关键问题**：接收方也需要能看到这条记录才能模糊处理对方发来的图片。

解决方案有两个，请选择方案 A：

**方案 A（推荐）**：RLS 策略不要限制 user_id，而是限制用户只能读 result='fail' 的记录：

```sql
CREATE POLICY "Authenticated users can read flagged moderation logs"
  ON public.backend_moderation_logs FOR SELECT
  USING (
    auth.role() = 'authenticated'
    AND result = 'fail'
  );
```

这样所有已认证用户都能查到被标记的图片 URL，但不能看到 pass 的记录（不泄露未违规内容的审核详情）。

### 任务 5：运行验证

1. 执行 migration：`./supabase/scripts/run_migration.sh 00129`
2. 运行 `flutter analyze` 确保无新错误
3. 运行 `build_runner` 如果修改了带 `@riverpod` 注解的代码

## 不要修改的文件

- `moderation_aware_image.dart` — 组件逻辑本身没问题
- `moderate-content/index.ts` — Edge Function 不需要改
- 已有的管理员 RLS 策略 — 保留不变

## 执行顺序

1. 创建 migration 00129
2. 修改 `moderation_provider.dart` 中的列名
3. 执行 migration
4. 运行 `flutter analyze`
5. 报告完成
