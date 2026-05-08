# T7: 管理后台布局重构 (侧边栏/Settings/Push 权限/Sensitive Words)

## 任务目标
1. 把 Listing Review 栏改为 "Review" 栏，包含：System Queue、User Reports、Chat Reports、User Feedback、AI Reviewed
2. Push Notifications 设为平台功能，仅 sysadmin 可见
3. Sensitive Words 从 Content 移到 Content Moderation（Review 栏下）
4. Settings 入口改为点击右上角用户头像进入，删除左边栏的 Settings 入口

## 执行边界
### 允许修改：
- `admin/src/components/layout/Sidebar.tsx`
- `admin/src/components/layout/TopBar.tsx`
- `admin/src/router.tsx`
- `admin/src/hooks/useAdminRole.ts`

### 严禁修改：
- `app/` 目录下任何文件
- `supabase/` 目录下任何文件
- 页面组件内部逻辑（只改路由和导航，不改页面内容）

## 实现要点

### 1. Sidebar.tsx 重构
当前 Content 组（第二组）有：
- All Listings, Listing Review, Chat Reports, Sensitive Words

改为 "Review" 组：
```
Review:
  - System Queue → path: /moderation/listings (原 Listing Review)
  - User Reports → path: /moderation/user-reports (需要确认路由，可能用 listing-reports 分页)
  - Chat Reports → path: /moderation/chat-reports
  - User Feedback → path: /feedback
  - AI Reviewed → path: /moderation/ai-reviewed (需要确认)

Content:
  - All Listings → path: /moderation/all-listings
  - Sensitive Words → path: /moderation/sensitive-words
```

### 2. Push Notifications 权限
在 Sidebar.tsx 中，把 Push Notifications 的 visible 从 `perms.canViewPush` 改为 `perms.isSysadmin`。

### 3. Settings 入口移到头像
- 从 Sidebar 删除 Settings 链接
- 在 TopBar.tsx 的头像下拉菜单中添加 "Settings" 选项（Profile 入口）
- 下拉菜单：Email + Role → Settings → Sign Out

### 4. 路由调整（如需）
确认 router.tsx 中路由与 Sidebar 链接匹配。

## 验证
```bash
cd /Users/george/smivo/admin && npx tsc -b
```

## 报告文件：`docs/bug修复/tasks/T7_report.md`
