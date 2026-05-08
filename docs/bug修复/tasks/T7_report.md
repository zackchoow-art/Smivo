# T7: 管理后台布局重构 执行报告

## 任务执行概要

本次任务依据需求对管理后台的左侧边栏导航和顶部导航栏进行了布局及权限重构。通过更新导航分组、调整入口位置及限制相应权限，我们有效优化了内容管理界面结构，并清理了侧边栏层级。

## 1. 修改/新建的文件

- **`admin/src/components/layout/Sidebar.tsx`**：重构导航分组，增加 "Review" 组并调整 "Content" 组，清理不必要的入口。
- **`admin/src/components/layout/TopBar.tsx`**：在管理员头像下拉菜单中加入 "Settings" 入口。
- **`admin/src/router.tsx`**：增加了 `User Reports` 及 `AI Reviewed` 占位路由映射，确保点击新建侧边栏项不会导致应用崩溃。
- **`admin/src/hooks/useAdminRole.ts`**：调整 Push Notifications 的可见权限。

## 2. 具体调整内容

### 1. 侧边栏分组调整 (Review 与 Content)
将原来的 Content 分组一分为二：
*   **新建 "Review" 分组**：
    *   System Queue (`/moderation/listings`)：原 Listing Review。
    *   User Reports (`/moderation/user-reports`)：使用占位符页面进行支持。
    *   Chat Reports (`/moderation/chat-reports`)。
    *   User Feedback (`/feedback`)：从 Engagement 组移入。
    *   AI Reviewed (`/moderation/ai-reviewed`)：使用占位符页面进行支持。
*   **更新 "Content" 分组**：
    *   仅保留 All Listings (`/moderation/all-listings`) 和 Sensitive Words (`/moderation/sensitive-words`)。

### 2. Sensitive Words 权限更新
确认并保持了 `Sensitive Words` 的权限验证：由于其不再按学校做差异化管理，可见性继续通过 `canViewSensitiveWords` (被设定为 `_isSysadmin || isPlatformAdmin`) 控制，以严格限制仅系统管理员和平台级管理员可用。

### 3. Push Notifications 权限更新
在 `useAdminRole.ts` 以及对应的侧边栏入口控制中，将 `canViewPush` 的访问权限设定为极严格的仅限于 `_isSysadmin`，禁止其他非平台核心管理员角色查看或使用。

### 4. Settings 入口移至 TopBar 下拉菜单
*   **侧边栏**：删除了左下角空位中的 "Settings" 链接入口（同时移除了未使用到的 `Settings` 图标引入，确保 TypeScript 类型全过）。
*   **顶部栏**：修改了 `TopBar.tsx` 的头像下拉菜单，在 `Sign Out` 之前新增了一行 `Settings` 快捷入口（点击可安全跳转到 `/settings/profile`），并且点击后自动关闭菜单。

## 3. TypeScript 验证结果

执行了 `cd admin && npx tsc -b` 编译检查命令。
在清理掉由于删除 Settings 入口造成的无效引入警告后，系统目前 **0 TypeScript 错误**，各项重构完全符合强类型规范要求。
