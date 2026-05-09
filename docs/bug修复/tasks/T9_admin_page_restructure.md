# T9: 管理后台页面重构 — 拆分、移动与补全

## 执行边界

### 允许修改的文件

- `admin/src/pages/moderation/ListingModerationPage.tsx` — 移除 User Reports 和 AI Reviewed 标签页内容
- `admin/src/pages/moderation/UserReportsPage.tsx` — **新建**，从 ListingModerationPage 拆出 User Reports
- `admin/src/pages/moderation/AiReviewedPage.tsx` — **新建**，从 ListingModerationPage 拆出 AI Reviewed
- `admin/src/pages/settings/SystemConfigsPage.tsx` — 新增 Sensitive Words 标签页
- `admin/src/pages/settings/FeatureFlagsPage.tsx` — 改名逻辑 + feedback.shortcuts 编辑
- `admin/src/pages/settings/SettingsPage.tsx` — 已存在，可能需要微调
- `admin/src/components/layout/Sidebar.tsx` — 调整分组与入口
- `admin/src/components/layout/TopBar.tsx` — 确保只保留 Profile 入口
- `admin/src/router.tsx` — 更新路由映射
- `admin/src/hooks/useAdminRole.ts` — 如需调整权限

### 禁止修改的文件

- `app/` 目录下任何文件
- `supabase/` 目录下任何文件
- 其他未列出的 admin/ 文件（除非确有必要，且必须在报告中说明理由）

---

## 子任务详情

### 1. System Queue 页面拆分（ListingModerationPage.tsx）

**当前状态**：`ListingModerationPage.tsx`（632行）是一个三 tab 页面：
- `viewTab === 'system'`：System Queue（listing 审核队列）
- `viewTab === 'user'`：User Reports（用户举报的 listing，使用 `useGroupedListingReports` hook）
- `viewTab === 'ai_reviewed'`：AI Reviewed（后端 AI 审核日志，使用 `useBackendModerationLogs` hook）

**操作**：
1. **保留** `ListingModerationPage.tsx` 中只保留 `viewTab === 'system'` 的内容
2. 移除三 tab 切换 UI（`lm-tabs-container`），改为单一 System Queue 页面标题
3. 移除不再需要的 import 和 state（`reportStatus`, `reportReason`, `useGroupedListingReports`, `aiPage`, `logFilters`, `useBackendModerationLogs`）

### 2. 新建 User Reports 独立页面

**新建文件**：`admin/src/pages/moderation/UserReportsPage.tsx`

**内容来源**：从 `ListingModerationPage.tsx` 的 `viewTab === 'user'` 部分提取：
- 使用 `useGroupedListingReports` hook（已存在于 `admin/src/hooks/useListingReports.ts`）
- 需要的 state：`reportStatus`, `reportReason`
- 包含筛选器（reason + status）和报告表格
- 点击行跳转到 `/moderation/listing-reports/:listing_id`
- 批量操作按钮（Batch Approve / Batch Reject）
- 复用 `lm-*` 样式类或定义自己的样式

**页面标题**：`User Reports`

### 3. 新建 AI Reviewed 独立页面

**新建文件**：`admin/src/pages/moderation/AiReviewedPage.tsx`

**内容来源**：从 `ListingModerationPage.tsx` 的 `viewTab === 'ai_reviewed'` 部分提取：
- 使用 `useBackendModerationLogs` hook（已存在于 `admin/src/hooks/useBackendModerationLogs.ts`）
- 需要的 state：`aiPage`, `logFilters`
- 包含三个筛选器（target type / result / engine）
- 表格展示 AI 审核日志（时间、引擎、类型、用户、结果、动作、原因）
- 分页组件
- 复用 `lm-*` 样式类或定义自己的样式
- 导入 `BackendModerationLog` 和 `LogFilters` 类型

### 4. 侧边栏重构（Sidebar.tsx）

**当前结构**：
```
Review: System Queue, User Reports, Chat Reports, User Feedback, AI Reviewed
Content Moderation: All Listings, Sensitive Words
Users: ...
Engagement: Push Notifications
Analytics: ...
(Audit Log)
```

**目标结构**：
```
Review: System Queue, User Reports, Chat Reports, User Feedback
Content Moderation: All Listings, AI Reviewed
Users: User List, Ban Records
Engagement: Push Notifications
Analytics: Data Dashboard
Configuration: Data Dictionary, Platform Settings, Admin Management, Schools, Test Data Cleanup
(Audit Log)
```

**具体改动**：
1. 从 Review 组移除 AI Reviewed
2. AI Reviewed 添加到 Content Moderation 组（放在 All Listings 下面）
3. Sensitive Words 从 Content Moderation 组移除（它将作为 Platform Settings 的一个标签页）
4. 恢复 Configuration 组（之前被删掉了），包含：Data Dictionary, Platform Settings, Admin Management, Schools, Test Data Cleanup
5. Configuration 组权限：与之前一致，各个子项使用各自的权限控制

**注意**：需要重新导入之前被移除的 lucide-react 图标：`BookOpen`, `UserCog`, `GraduationCap`, `Cpu`, `Trash2`

### 5. TopBar 调整

**当前状态**：头像下拉菜单有 Settings 链接（跳转到 /settings hub 页面）

**目标**：把 Settings 链接改为 Profile（跳转到 /settings/profile）。因为 Configuration 已经回到侧边栏了，头像下拉只需要提供个人资料的入口。

改动：
1. 将 `navigate('/settings')` 改为 `navigate('/settings/profile')`
2. 将 "Settings" 文字改为 "Profile"

### 6. Sensitive Words 合并到 Platform Settings

**当前状态**：
- `SystemConfigsPage.tsx` 有三个 tab：Content Moderation, Feature Flags, Image Moderation
- `SensitiveWordsPage.tsx` 是独立页面（396 行），功能完整

**操作**：
1. 在 `SystemConfigsPage.tsx` 中新增第四个 tab：`Sensitive Words`
2. 该 tab 直接渲染 `<SensitiveWordsPage />` 组件
3. 从路由和侧边栏中移除 `/moderation/sensitive-words` 的独立入口
4. 在路由中保留 `/moderation/sensitive-words` 路径但重定向到 `/settings/configs?tab=sensitive-words`（或直接删除，因为侧边栏已没有这个入口）

**实现方式**：
- 在 `SystemConfigsPage.tsx` 中：
  ```tsx
  type Tab = 'configs' | 'flags' | 'moderation' | 'sensitive_words';
  ```
- 在 tab 按钮组中新增 Sensitive Words tab
- 权限控制：这个 tab 仅在 `canViewSensitiveWords`（sysadmin only）时显示
- Tab 内容区域：当 `activeTab === 'sensitive_words'` 时直接渲染 `<SensitiveWordsPage />`

### 7. Feature Flags 页面改名 + feedback.shortcuts 编辑

**当前状态**：
- `FeatureFlagsPage.tsx` 标题是 "System Configurations & Feature Flags"
- `feedback.shortcuts` 是存在 `system_configs` 表中的 JSON 数组值（preset shortcut replies）
- 当前 FeatureFlagsPage 对非布尔值只显示 "Edit in DB or via specific settings page"，无法在 UI 中编辑

**操作 A — 改名**：
1. 保持文件名 `FeatureFlagsPage.tsx` 不变（避免大范围路由改动）
2. 将页面标题 `System Configurations & Feature Flags` 改为 `System Configuration`
3. 路由中侧边栏对应入口的 label 也改为 `System Configuration`（如果有引用的话）

**操作 B — feedback.shortcuts 编辑功能**：
1. 在 FeatureFlagsPage 中，当识别到 `flag.key === 'feedback.shortcuts'` 时，渲染一个专用的 JSON 数组编辑器代替 "Edit in DB" 提示
2. 编辑器功能：
   - 解析 `feedback.shortcuts` 的值为 `string[]`
   - 以列表形式展示每个快捷回复
   - 每行可以编辑文本内容
   - 可以添加新的快捷回复
   - 可以删除某个快捷回复
   - 可以拖拽排序（可选，不强制）
   - 点击 "Save" 将修改后的数组 JSON.stringify 后调用 `updateConfig.mutate` 保存
3. **数据来源**：`system_configs` 表中 `config_key = 'feedback.shortcuts'`，`config_value` 是 JSON 数组字符串
4. 使用 `useUpdateSystemConfig` hook 保存更改

### 8. 路由更新（router.tsx）

**需要更新的路由**：
1. `/moderation/user-reports` → 从 `PlaceholderPage` 改为 `UserReportsPage`
2. `/moderation/ai-reviewed` → 从 `PlaceholderPage` 改为 `AiReviewedPage`
3. `/moderation/sensitive-words` → 可以保留指向 `SensitiveWordsPage`（兼容直接访问），或重定向
4. 确保 `/settings` hub 页面路由仍然存在但可以考虑删除（因为 Configuration 已回到侧边栏），如果删除则 TopBar 的 Profile 直接跳 `/settings/profile`
5. 新增必要的 import

---

## 验证步骤

1. 运行 `cd /Users/george/smivo/admin && npx tsc -b`，确保 **0 TypeScript 错误**
2. 检查以下页面路径是否可正常访问（无崩溃）：
   - `/moderation/listings`（System Queue，不再有 tab 切换）
   - `/moderation/user-reports`（独立页面，有内容）
   - `/moderation/ai-reviewed`（独立页面，有内容）
   - `/settings/configs`（Platform Settings，应有 4 个 tab 包括 Sensitive Words）
   - `/settings/feature-flags`（改名为 System Configuration，feedback.shortcuts 可编辑）

## 报告

将执行报告写入 `docs/bug修复/tasks/T9_report.md`，包含：
- 新建/修改的文件列表
- 每个文件的关键改动描述
- TypeScript 编译结果
