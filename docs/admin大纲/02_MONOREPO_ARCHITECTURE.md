# SMIVO Monorepo 架构规范

> **文档定位**:Smivo 仓库的目录组织、构建发布管道、跨端协作的"宪法"。所有 Agent 与开发者在动手前必读。
>
> **配套文档**:
> - `00_DOCUMENT_INDEX.md`(总目录)
> - `01_MASTER_BRIEF.md`(产品全景)
> - `04_ADMIN_WEB_SPEC.md`(Admin Web 开发任务)
> - `08_PLAZA_FUTURE_SPEC.md`(Plaza 未来设计存档)

---

## 1. 仓库布局总览

Smivo 采用 **多端共仓(Monorepo)** 模式,App 端、Admin 后台、官网、Supabase 工程并存于同一个 Git 仓库。

```
smivo/                                  # Git 仓库根
├── README.md
├── .gitignore                          # 合并 Flutter / Node / Supabase 的忽略规则
├── docs/                               # 所有架构与规范文档
│   ├── SMIVO_PROJECT_MASTER_BRIEF.md
│   ├── SMIVO_MONOREPO_ARCHITECTURE.md
│   ├── SMIVO_MODERATION_AND_ADMIN_SPEC.md
│   └── SMIVO_PLAZA_FUTURE_SPEC.md
│
├── app/                                # Flutter App(iOS / Android / Web)
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── pubspec.yaml
│   └── ...
│
├── admin_web/                          # React Admin 控制台
│   ├── src/
│   ├── public/
│   ├── package.json
│   ├── vite.config.ts
│   ├── tailwind.config.ts
│   └── tsconfig.json
│
├── website/                            # 静态官网(纯 HTML/CSS)
│
└── supabase/                           # Supabase 工程
    ├── migrations/                     # 全部 SQL 迁移
    ├── functions/                      # Edge Functions(TypeScript)
    │   ├── _shared/                    # 跨 Function 共享代码与类型
    │   └── admin-*/                    # Admin 相关 Function 按业务分组
    └── config.toml
```

### 1.1 设计原则

- **每个子目录是一个独立的"项目"**:有自己的依赖管理、构建工具、发布管道。互不干涉。
- **根目录不放 `package.json`**:避免 Vercel 等工具误判仓库类型。当前阶段 **不引入** pnpm workspace 等多包管理器,等跨端共享需求成熟后再升级。
- **`docs/` 是宪法目录**:所有架构性决策必须落到这里。
- **`supabase/` 是后端真理之源**:数据库 schema、RPC、RLS、Edge Function 全部在这里管理,不允许从 Supabase 控制台手改。

---

## 2. Flutter 项目下沉迁移(必做的一次性手术)

### 2.1 背景

当前 Flutter 项目是仓库根项目。要进入 Monorepo 模式,必须把它**下沉**到 `app/` 子目录。

### 2.2 迁移步骤

```bash
# 在仓库根执行
mkdir app

# 把 Flutter 相关文件全部移入 app/
git mv lib app/
git mv android app/
git mv ios app/
git mv web app/
git mv test app/
git mv pubspec.yaml app/
git mv pubspec.lock app/
git mv analysis_options.yaml app/
git mv .metadata app/
# (其他 Flutter 生成的文件按实际情况移动)

# 提交一次性迁移
git commit -m "chore: relocate Flutter project under app/ for monorepo"
```

### 2.3 迁移后必须做的事

- **CI/CD 调整**:任何已配置的 GitHub Actions / fastlane / Codemagic 工作流,路径必须从根改为 `app/`。
- **本地开发命令更新**:`flutter run` 必须在 `app/` 目录下执行,或使用 `flutter run --pubspec=app/pubspec.yaml`。
- **iOS / Android 原生 IDE 配置**:Xcode 打开 `app/ios/Runner.xcworkspace`,Android Studio 打开 `app/android/`。
- **环境变量文件**:`.env` 等本地配置如果存在,确认路径仍可被 Flutter 找到。

### 2.4 风险提示

- **Antigravity 工作区配置**:迁移完成后,在 Antigravity 中应将 `app/` 与 `admin_web/` 设置为两个独立的 workspace 子根,避免语法补全 / Lint 错乱。
- **历史 PR 中的路径引用会失效**:迁移前应先合并所有进行中的 PR。

---

## 3. `.gitignore` 合并规范

仓库根的 `.gitignore` 必须同时覆盖三套工具链:

```gitignore
# === Flutter ===
app/.dart_tool/
app/build/
app/ios/Pods/
app/ios/.symlinks/
app/.flutter-plugins
app/.flutter-plugins-dependencies
app/android/.gradle/
app/android/local.properties
app/android/app/build/
app/.idea/

# === React / Node ===
admin_web/node_modules/
admin_web/dist/
admin_web/.vite/
admin_web/coverage/
admin_web/.turbo/

# === Supabase ===
supabase/.branches/
supabase/.temp/
supabase/.env

# === 通用 ===
.env
.env.local
.env.*.local
.DS_Store
*.log
.vscode/
.idea/
```

---

## 4. 构建与发布管道

每个子项目的产物去往**完全不同的目的地**,互不干扰。

| 项目 | 构建命令 | 发布目的地 |
|---|---|---|
| Flutter iOS | `cd app && flutter build ipa` | App Store Connect |
| Flutter Android | `cd app && flutter build appbundle` | Google Play Console |
| Flutter Web | `cd app && flutter build web` | 自托管 / Vercel(可选) |
| React Admin | `cd admin_web && pnpm build` | Vercel(子域 `admin.smivo.io`) |
| Static Website | `website/` 静态文件 | Vercel(`smivo.io`) |
| Edge Functions | `supabase functions deploy <name>` | Supabase 云 |
| DB Migrations | `supabase db push` | Supabase 云 Postgres |

### 4.1 Vercel 多 Project 部署策略

同一个 GitHub 仓库可以挂多个 Vercel Project,每个锁定不同子目录:

| Vercel Project | Root Directory | 域名 |
|---|---|---|
| `smivo-website` | `website/` | `smivo.io` |
| `smivo-admin` | `admin_web/` | `admin.smivo.io` |
| `smivo-app-web`(可选) | `app/build/web/` | `app.smivo.io` |

每个 Project 的"Ignored Build Step"应配置为只在对应目录变动时触发构建,避免改 Flutter 代码却触发 Admin 重新部署。

### 4.2 GitHub Actions 路径过滤

如使用 GitHub Actions,工作流应按目录区分:

```yaml
# .github/workflows/flutter.yml
on:
  push:
    paths:
      - 'app/**'
      - '.github/workflows/flutter.yml'

# .github/workflows/admin.yml
on:
  push:
    paths:
      - 'admin_web/**'
      - '.github/workflows/admin.yml'
```

---

## 5. 跨端协作的"真理之源"

### 5.1 当前阶段策略(MVP)

**手动维护一份 `docs/business-rules.md`**,把所有跨端共享的:
- 状态枚举值(如 `OrderStatus`、`ListingStatus`、`ReportStatus`)
- 业务规则常量(如租赁最小天数、敏感词命中等级)
- API 路径与版本

集中列在这一份文档里。Flutter 与 React 两端的代码 **必须引用这份文档**,任何修改必须先改文档再改代码。

### 5.2 升级触发条件

当出现以下任一信号时,启动跨端类型生成方案讨论:

- 跨端共享的枚举 / 状态机达到 **5 个以上**
- 出现过 **1 次以上** "两端定义不一致导致的线上 bug"
- 团队人数增加,出现"我不知道另一端定义"的认知负担

### 5.3 升级时的候选方案(供未来参考)

- **方案 A**:JSON Schema 驱动 + quicktype 自动生成 Dart / TypeScript 类型
- **方案 B**:pnpm workspace + `packages/shared-types` + `json_schema` Dart 插件
- **方案 C**:Supabase 自带的 `supabase gen types typescript` + 手写 Dart 镜像

升级时机由项目主导者决定,本文档不预设。

---

## 6. 环境变量与密钥管理

### 6.1 三层环境隔离

| 环境 | 用途 | 配置位置 |
|---|---|---|
| `local` | 本地开发 | 各端的 `.env.local`(gitignored) |
| `staging` | 内部测试 | Vercel / Supabase 的 staging 项目 |
| `production` | 线上 | Vercel / Supabase 的 production 项目 |

### 6.2 关键密钥分发

| 密钥 | 谁持有 | 谁绝不持有 |
|---|---|---|
| `SUPABASE_ANON_KEY` | Flutter App、React Admin、Website | (公开,可放前端) |
| `SUPABASE_SERVICE_ROLE_KEY` | **仅 Edge Functions** | 前端任何一端 |
| OneSignal REST API Key | **仅 Edge Functions** | 前端 |
| OneSignal App ID | Flutter App、Edge Functions | (半公开) |

**红线**:`SERVICE_ROLE_KEY` 任何时候都**不允许**出现在 `app/` 或 `admin_web/` 的代码、配置、构建产物中。

---

## 7. 分支与提交规范

### 7.1 分支策略

- `main` — 生产分支,受保护,只能通过 PR 合并
- `develop` — 集成分支(可选,小团队可省略)
- `feat/<scope>-<short-desc>` — 功能分支,如 `feat/admin-sensitive-words`
- `fix/<scope>-<short-desc>` — 修复分支
- `chore/<short-desc>` — 杂项

### 7.2 提交信息约定(Conventional Commits)

```
<type>(<scope>): <subject>

类型:feat / fix / chore / docs / refactor / test / style / perf
作用域:app / admin / supabase / website / docs
```

示例:
- `feat(admin): add sensitive word list page`
- `fix(app): correct order status badge color`
- `chore(supabase): add migration for sensitive_words table`

### 7.3 跨目录改动的处理

**强烈建议**:涉及多个子项目的改动**拆分成多个 PR**,每个 PR 只动一个子项目。例外:数据库 schema 变更同时影响 App 和 Admin 时,可在同一 PR 中改三处(supabase + app + admin_web),但 PR 描述必须详细说明影响范围。

---

## 8. Antigravity 开发环境配置建议

- **Workspace 子根**:在 Antigravity 中将 `app/`、`admin_web/`、`supabase/` 设置为独立的 workspace folders
- **Agent 接手指引**:任何 AI Agent 接手时的标准动作:
  1. `view /docs/SMIVO_PROJECT_MASTER_BRIEF.md`
  2. `view /docs/SMIVO_MONOREPO_ARCHITECTURE.md`(本文)
  3. `view /docs/SMIVO_MODERATION_AND_ADMIN_SPEC.md`(如涉及当前任务)
  4. 列出仓库根目录,确认 `app/` 与 `admin_web/` 都存在
- **避免的危险操作**:
  - 不要在根目录执行 `flutter` 或 `pnpm` 命令(必须 `cd` 到对应子目录)
  - 不要在 `app/` 中安装 npm 包,也不要在 `admin_web/` 中执行 Flutter 命令
  - 不要让任何 AI Agent 自己决定"要不要把根目录变成 pnpm workspace",这是需要人类决策的架构变更

---

## 9. 已知风险与待办

| 风险 | 缓解策略 | 状态 |
|---|---|---|
| Flutter 下沉迁移失败导致历史 PR 失效 | 迁移前合并所有 in-flight PR | 待执行 |
| 跨端类型不一致导致 bug | 当前手动维护 business-rules.md;触发条件后升级 | 监控中 |
| Vercel 误判仓库为 Node 项目 | 不在根目录建 package.json;为每个 Project 配置 Root Directory | 已规避 |
| Service Role Key 泄漏到前端 | 严格只在 Edge Function 中持有 | 已规范化 |
| GitHub 仓库体积膨胀 | 严格的 .gitignore | 已规范化 |

---

*文档版本:v1.0 · 维护者:Smivo 项目主导*
*最后更新:2026-04-29*
