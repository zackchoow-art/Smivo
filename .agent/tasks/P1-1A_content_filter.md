# P1-1 Phase A: 本地敏感词过滤系统

> 执行 Agent: Gemini 3.1 Pro
> 优先级: P1
> 预计修改文件数: 5-6

---

## 整体架构

```
用户提交内容 → 本地敏感词过滤（客户端）
  ├── 命中 → 立即拦截，提示修改
  └── 未命中 → 提交服务器 → [Phase B] Edge Function 二次检测
```

本 Phase A 仅实现客户端本地过滤部分。

---

## 执行边界（严格遵守）

### ✅ 允许创建/修改的文件
- `supabase/migrations/00049_sensitive_words.sql` — 创建敏感词表（不填充数据）
- `app/lib/core/utils/content_filter.dart` — 新建：敏感词过滤器工具类
- `app/lib/core/providers/content_filter_provider.dart` — 新建：Riverpod provider
- `app/lib/features/listing/providers/create_listing_provider.dart` — 注入过滤检查
- `app/lib/features/chat/providers/chat_provider.dart` — 注入过滤检查（发消息时）

### ❌ 禁止修改的文件
- 路由配置 (`router.dart`, `app_routes.dart`)
- 任何 model 文件 / freezed 文件
- `pubspec.yaml`（不需要新依赖）
- 任何 admin 相关文件
- `listing_repository.dart`

---

## 子任务 1a: 创建敏感词库表

### 设计要求
表结构需要兼容第三方批量导入工具（CSV/TXT 一行一词格式）。
未来 React Admin 后台将提供批量上传入口，使用 `INSERT ... ON CONFLICT (word) DO NOTHING`。
**本次不预填充敏感词数据** — 词库由管理员通过后台导入管理。

### 数据库变更
创建 `supabase/migrations/00049_sensitive_words.sql`:

```sql
-- Migration 00049: Sensitive words table for content moderation
-- Words are downloaded to Flutter client, cached locally, and checked before submission.
-- Admin backend will bulk-import words from third-party providers (Sightengine, etc.)

CREATE TABLE IF NOT EXISTS public.sensitive_words (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    -- Core field: the actual word or phrase to match
    word text NOT NULL,
    -- Category for admin organization (e.g. weapons, drugs, adult, hate, fraud)
    category text NOT NULL DEFAULT 'general',
    -- Severity: 'block' = prevent submission, 'warn' = show warning only
    severity text NOT NULL DEFAULT 'block' CHECK (severity IN ('block', 'warn')),
    -- Language code (ISO 639-1), supports multi-language expansion
    language text NOT NULL DEFAULT 'en',
    -- Source tracking: 'manual' = admin added, 'import' = bulk imported, 'api' = from third-party API
    source text NOT NULL DEFAULT 'manual',
    -- Soft switch to disable without deleting
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    -- UNIQUE constraint on word+language to prevent duplicates across imports
    CONSTRAINT unique_word_per_language UNIQUE (word, language)
);

-- Index for efficient client-side download query
CREATE INDEX IF NOT EXISTS idx_sensitive_words_active
    ON public.sensitive_words (is_active, severity, language);

-- RLS: All authenticated users can read active words (needed for client-side filter)
ALTER TABLE public.sensitive_words ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read active words"
    ON public.sensitive_words FOR SELECT
    TO authenticated
    USING (is_active = true);

-- NOTE: INSERT/UPDATE/DELETE policies will be added when React Admin is implemented.
-- Admin will use service_role key to bypass RLS for word management.
```

### 执行 SQL
```bash
./supabase/scripts/run_migration.sh supabase/migrations/00049_sensitive_words.sql
```

---

## 子任务 1b: 客户端过滤器

### 1. 创建 `app/lib/core/utils/content_filter.dart`

纯 Dart 工具类，无 Flutter 依赖：

```dart
/// Result of a content filter check.
class ContentFilterResult {
  final bool passed;
  final List<String> matchedWords;

  const ContentFilterResult({
    required this.passed,
    required this.matchedWords,
  });
}

/// Client-side sensitive word filter.
///
/// Uses case-insensitive word boundary matching to check text against
/// a downloaded word list. Multi-word phrases use substring matching.
class ContentFilter {
  final List<String> _words;

  ContentFilter(this._words);

  /// Checks [text] against the sensitive word list.
  /// Returns a result indicating whether the text passed and which words matched.
  ContentFilterResult check(String text) {
    if (_words.isEmpty || text.trim().isEmpty) {
      return const ContentFilterResult(passed: true, matchedWords: []);
    }

    final lowerText = text.toLowerCase();
    final matched = <String>[];

    for (final word in _words) {
      final lowerWord = word.toLowerCase();
      // Multi-word phrases: simple substring match
      if (lowerWord.contains(' ')) {
        if (lowerText.contains(lowerWord)) {
          matched.add(word);
        }
      } else {
        // Single words: word boundary regex to avoid false positives
        // e.g. "assess" should NOT match "ass"
        final pattern = RegExp(r'\b' + RegExp.escape(lowerWord) + r'\b');
        if (pattern.hasMatch(lowerText)) {
          matched.add(word);
        }
      }
    }

    return ContentFilterResult(
      passed: matched.isEmpty,
      matchedWords: matched,
    );
  }
}
```

### 2. 创建 `app/lib/core/providers/content_filter_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/core/utils/content_filter.dart';

part 'content_filter_provider.g.dart';

/// Downloads and caches the sensitive word list from Supabase.
///
/// keepAlive ensures the list stays in memory across the app lifecycle.
/// The provider loads words with severity='block' and is_active=true.
/// If the table is empty (no words imported yet), the filter passes all content.
@Riverpod(keepAlive: true)
class SensitiveWords extends _$SensitiveWords {
  @override
  Future<ContentFilter> build() async {
    final client = ref.watch(supabaseClientProvider);
    final data = await client
        .from('sensitive_words')
        .select('word')
        .eq('is_active', true)
        .eq('severity', 'block');

    final words = data.map((row) => row['word'] as String).toList();
    return ContentFilter(words);
  }
}
```

### 3. 修改 `app/lib/features/listing/providers/create_listing_provider.dart`

在 `CreateListingAction.submit()` 方法中，找到注释 `// Basic validation` 代码块结束后、`// TODO(images)` 注释之前的位置，插入内容过滤检查：

```dart
      // Content filter — block submission if local sensitive words detected
      final filter = ref.read(sensitiveWordsProvider).valueOrNull;
      if (filter != null) {
        final titleResult = filter.check(title);
        final descResult = filter.check(description);
        if (!titleResult.passed || !descResult.passed) {
          final allMatched = {
            ...titleResult.matchedWords,
            ...descResult.matchedWords,
          };
          throw ArgumentError(
            'Your listing contains restricted content and cannot be posted. '
            'Please revise the following: ${allMatched.join(", ")}',
          );
        }
      }
```

需要在文件顶部增加 import：
```dart
import 'package:smivo/core/providers/content_filter_provider.dart';
```

**关键设计：**
- 使用 `valueOrNull` — 如果词库还没加载完则不阻塞（容错）
- 如果 `sensitive_words` 表为空（管理员还没导入词库），filter.check() 直接 pass
- 错误信息展示匹配到的词，帮助用户修改

### 4. 修改聊天消息发送（如果存在 sendMessage 方法）

在 `app/lib/features/chat/providers/chat_provider.dart` 中找到发送消息的方法，在实际发送前增加同样的过滤检查：

```dart
      // Content filter — block message if local sensitive words detected
      final filter = ref.read(sensitiveWordsProvider).valueOrNull;
      if (filter != null) {
        final result = filter.check(messageText);
        if (!result.passed) {
          throw Exception(
            'Your message contains restricted content: ${result.matchedWords.join(", ")}',
          );
        }
      }
```

**注意：** 需要先阅读 `chat_provider.dart` 找到 sendMessage 方法的确切位置。如果该方法直接发送到 Supabase 而不经过 provider（例如直接在 screen 里调用 repository），则在对应的 screen 文件中增加检查。

**重要：** 仅对文本消息做检查。图片消息不在此检查范围内（图片审核在 Phase B 的 Edge Function 中处理）。

---

## 执行完成后必须做的事

1. 运行 SQL migration：
   ```bash
   ./supabase/scripts/run_migration.sh supabase/migrations/00049_sensitive_words.sql
   ```

2. 运行代码生成（因为新增了 @riverpod provider）：
   ```bash
   cd app && dart run build_runner build --delete-conflicting-outputs
   ```

3. 运行代码检查（必须在 app 文件夹下执行）：
   ```bash
   cd app && flutter analyze --no-fatal-infos
   ```

4. 生成执行报告写入 `.agent/tasks/P1-1A_report.md`，包含：
   - 修改的文件列表和变更描述
   - flutter analyze 结果
   - 需要手动操作的步骤（如有）

## 关键注意事项
- **不要预填充敏感词数据** — 词库由管理员通过后台批量导入
- **不要添加 pending_review 状态** — 这是 Phase B 的任务
- **不要修改 pubspec.yaml** — 不需要额外依赖
- **不要修改 listing_repository.dart 或 chat_repository.dart** — 过滤是客户端行为
- **不要修改任何 model 文件** — 不需要新 model
