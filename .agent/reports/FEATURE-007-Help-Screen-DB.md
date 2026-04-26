# 任务执行报告：帮助页面动态数据重构

**日期**: 2026-04-26
**分支**: `feature/theme-switching`

## 1. 任务背景与指令
用户要求改造 Settings 页面内的 Help 子页面：
1. 将原来硬编码在 Dart 文件中的 Q&A 替换为从数据库中动态读取。
2. 考虑分类别问题的交互设计。
3. 考虑相关的数据库结构。

## 2. 执行过程

### 2.1 数据库结构升级
* **文件操作**: 增加了 `supabase/migrations/00035_help_faqs.sql`。
* **执行细节**:
  * 创建了 `faqs` 表，包含 `category`、`question`、`answer`、`display_order` 等核心字段。
  * 开启了 RLS（行级安全），添加策略允许所有人仅可查询 (`select`)。
  * 将前一步生成的 `help_document.md` 中的常见问题及其分类批量作为初始数据 `insert` 到了表中。
  * 利用项目的 `./db.sh` 脚本成功将表结构部署到了本地/远程的 Supabase。

### 2.2 数据模型与 Provider
* **文件操作**: 新增了 `lib/data/models/faq.dart`；修改了 `lib/features/settings/providers/help_provider.dart`。
* **执行细节**:
  * 通过 `freezed` 创建了不可变的 `Faq` 模型类。
  * 重写了 `helpFaqs` 这个 Riverpod 提供器，使其变为 `FutureProvider`，调用 `supabaseClientProvider` 抓取 `faqs` 表的数据并按照 `display_order` 排序。
  * 运行了 `build_runner` 生成序列化代码。

### 2.3 帮助页 UI 交互改造
* **文件操作**: 修改了 `lib/features/settings/screens/help_screen.dart`，并在 `pubspec.yaml` 中引入了 `collection` 库以支持列表处理。
* **执行细节**:
  * 使用 `allFaqsAsync.when(...)` 妥善处理加载进度条（loading）和异常（error）。
  * 取回数据后，使用了 `collection` 库中的 `groupBy` 将一维的数据列表按 `category` 字段进行了聚合，生成类似于 `Map<String, List<Faq>>` 的结构。
  * 在 UI 渲染层面，循环渲染所有的类别（Category），每个类别作为一个块（带有专属副标题）。在分类下方渲染该分类所属的 `Faq` 问答条目，保留了搜索、点击折叠和展开的动态动画交互。

## 3. 执行结果
* 静态检查通过（无相关报错）。
* 功能符合预期：支持远程配置和修改 FAQ，再无需硬编码重新发版；界面按类别清晰地排列了所有的问答，支持展开及文本搜索过滤。
* 修改已提交至本地仓库（Commit: `"feat: database driven help screen faqs"`），并推送至远程 `feature/theme-switching` 分支。
