# T9 执行报告：管理后台页面重构

**执行时间**: 2026-05-08  
**验证命令**: `cd /Users/george/smivo/admin && npx tsc -b`  
**验证结果**: ✅ 0 TypeScript 错误

---

## 新建/修改文件清单

| 文件 | 变更类型 | 关键改动 |
|------|---------|---------|
| `admin/src/pages/moderation/UserReportsPage.tsx` | **新建** | 从 ListingModerationPage 提取 User Reports tab 为独立页面 |
| `admin/src/pages/moderation/AiReviewedPage.tsx` | **新建** | 从 ListingModerationPage 提取 AI Reviewed tab 为独立页面 |
| `admin/src/pages/moderation/ListingModerationPage.tsx` | 重写 | 移除三 tab 结构，只保留 System Queue 单页 |
| `admin/src/components/layout/Sidebar.tsx` | 修改 | 结构重组 + 恢复 Configuration 组 |
| `admin/src/components/layout/TopBar.tsx` | 修改 | 头像下拉 Settings → Profile |
| `admin/src/pages/settings/SystemConfigsPage.tsx` | 修改 | 新增 Sensitive Words 第四个 tab |
| `admin/src/pages/settings/FeatureFlagsPage.tsx` | 修改 | 标题改名 + 添加 ShortcutsEditor 组件 |
| `admin/src/router.tsx` | 修改 | 路由映射更新 + 移除无用 import |

---

## 子任务详情

### 1. ListingModerationPage 拆分 ✅
- 移除三 tab 切换 UI (`lm-tabs-container`)
- 移除所有 `viewTab === 'user'` / `viewTab === 'ai_reviewed'` 相关 state 和渲染逻辑
- 移除 `useGroupedListingReports`、`useBackendModerationLogs` 等不再需要的 import
- 页面标题从 "Listing Review" 改为 "System Queue"

### 2. UserReportsPage.tsx 新建 ✅
- 提取原 `viewTab === 'user'` 内容：`reportStatus` / `reportReason` state
- 筛选器（reason + status）+ 表格
- 行点击跳转 `/moderation/listing-reports/:listing_id`
- Batch Approve / Batch Reject 按钮
- 内联 `lm-*` 样式

### 3. AiReviewedPage.tsx 新建 ✅
- 提取原 `viewTab === 'ai_reviewed'` 内容：`aiPage` / `logFilters` state
- 三个筛选器（target type / result / engine）
- 日志表格（时间、引擎、类型、用户、结果、动作、原因）
- 分页组件
- 导入 `BackendModerationLog` / `LogFilters` 类型

### 4. Sidebar 重构 ✅
- Review 组：移除 AI Reviewed
- Content Moderation 组：添加 AI Reviewed（`<Bot>` 图标），移除 Sensitive Words 入口
- 恢复 Configuration 组，包含 6 项：Data Dictionary, Platform Settings, System Configuration, Admin Management, Schools, Test Data Cleanup
- 新增导入：`Bot`, `BookOpen`, `UserCog`, `GraduationCap`, `Cpu`, `Trash2`

### 5. TopBar 调整 ✅
- 头像下拉菜单中 "Settings"（`navigate('/settings')`）→ "Profile"（`navigate('/settings/profile')`）
- Configuration 已回到侧边栏，头像下拉专注于个人资料入口

### 6. Sensitive Words 嵌入 Platform Settings ✅
- `SystemConfigsPage.tsx` Tab 类型新增 `'sensitive_words'`
- 导入 `SensitiveWordsPage`
- 新增第四个 tab 按钮：Sensitive Words（`<ShieldAlert>` 图标，仅 PLATFORM_SUPER_ADMIN 可见）
- Tab 内容渲染：`activeTab === 'sensitive_words'` 时直接渲染 `<SensitiveWordsPage />`

### 7. FeatureFlagsPage 改名 + feedback.shortcuts 编辑器 ✅
- 页面标题从 "System Configurations & Feature Flags" 改为 "System Configuration"
- 新增 `ShortcutsEditor` 顶层组件：
  - 解析 `feedback.shortcuts` config_value 为 `string[]`
  - 列表展示每条快捷回复，可编辑文本
  - Add 按钮新增条目，Remove 按钮删除条目
  - dirty 标记变更，点击 Save 触发 `updateConfig.mutate` 保存
  - 只读模式（非 super admin）：input 禁用，不显示 Add/Save

### 8. router.tsx 更新 ✅
- `moderation/user-reports` → `<UserReportsPage />` (原 PlaceholderPage)
- `moderation/ai-reviewed` → `<AiReviewedPage />` (原 PlaceholderPage)
- 移除不再使用的 `PlaceholderPage` import（避免 TS6133 noUnusedLocals 错误）

---

## TypeScript 编译结果

```
cd /Users/george/smivo/admin && npx tsc -b
# → (no output = 0 errors) ✅
```
