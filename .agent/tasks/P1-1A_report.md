# Execution Report: P1-1 Phase A: 本地敏感词过滤系统

## 变更文件列表与描述

1. **`supabase/migrations/00049_sensitive_words.sql`**
   - 创建了 `sensitive_words` 表，用于管理平台的敏感词。表结构包含了 `word`（敏感词本体）、`category`（分类）、`severity`（严重程度：block/warn）、`language`（语言支持），以及相应的 `is_active` 控制开关和重复校验约束（`unique_word_per_language`）。
   - 添加了索引 `idx_sensitive_words_active` 以及 Row Level Security (RLS) 支持客户端（认证用户）安全且高效地下载有效的拦截词列表。

2. **`app/lib/core/utils/content_filter.dart`**
   - 新建了纯 Dart 工具类 `ContentFilter` 及其返回值模型 `ContentFilterResult`。
   - 核心逻辑支持了“多词短语子串匹配”以及“单字敏感词全词边界正则匹配” (Word boundary Regex)，避免出现误杀正常词汇的情况。

3. **`app/lib/core/providers/content_filter_provider.dart`**
   - 新建了 `@Riverpod(keepAlive: true)` provider `SensitiveWords`。
   - 负责启动时连接 Supabase 的 `sensitive_words` 表将处于活动状态且严重等级为 'block' 的词库缓存到内存供本地快速过滤。

4. **`app/lib/features/listing/providers/create_listing_provider.dart`**
   - 在商品发布逻辑的 `submit()` 方法内，调用 `ref.read(sensitiveWordsProvider).valueOrNull`，动态执行对标题 (`title`) 和描述 (`description`) 的拦截过滤。若命中敏感词将直接阻断提交流程，并向用户抛出具体的敏感词修改建议提示。

5. **`app/lib/features/chat/providers/chat_provider.dart`**
   - 在聊天发送逻辑 `sendMessage()` 方法内部，加入同样的文本过滤检测，保障一对一直接交流的信息合规。

## Flutter 代码生成及静态分析结果

- **代码生成 (`build_runner`)**:
  成功执行针对 `content_filter_provider.dart` 的单文件过滤编译，规避了全局编译的冲突问题：
  ```bash
  cd app && dart run build_runner build --build-filter="lib/core/providers/content_filter_provider.g.dart" --delete-conflicting-outputs
  ```
- **Flutter Analyze**:
  通过 `flutter analyze --no-fatal-infos` 进行扫描，并未引入任何针对当前新增修改的语法错误。项目中原本存在的约 1900 处历史模型签名报错仍被保留并隔离，核心新增功能无恙。

## 需要手动操作的步骤
目前所有相关的客户端本地拦截功能已就位。
- 数据库表结构已执行创建，但根据需求，**表中目前没有存入任何敏感词**，由将来的 Admin 系统通过第三方导入。
- 可以使用任意 SQL 工具向 `sensitive_words` 中手动录入词汇（例如插入 `weapon`, `scam`）后，在 App 中发新帖或发消息，验证拦截效果。
