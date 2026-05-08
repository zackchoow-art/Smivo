# T6: 管理后台惩罚机制修复 + Ban Records + User Reports + 警告通知合并

## 任务目标
1. **User Reports 页面信息不足**：补充商品详情（浏览数、收藏数、下单数等）
2. **警告通知重复**：被举报用户收到多张警告卡片，应合并为一条
3. **惩罚机制 Bug**：管理员选择 "warn" 但用户被 ban 了，调查默认值问题
4. **Ban Records 取消按钮无效**：修复 lift ban 功能

## 执行边界
### 允许修改：
- `admin/src/pages/moderation/ListingReportDetailPage.tsx`
- `admin/src/pages/moderation/ChatReportDetailPage.tsx`
- `admin/src/pages/users/BansPage.tsx`
- `admin/src/hooks/useListingReports.ts`
- `admin/src/hooks/useChatReports.ts`
- `admin/src/hooks/useBans.ts`
- `admin/src/types/` 下相关类型文件
- `admin/src/components/` 下相关组件

### 严禁修改：
- `app/` 目录下任何文件
- `supabase/migrations/` 下的现有迁移文件
- `website/` 目录

### 允许新增：
- `supabase/migrations/` 下的新迁移文件（如需修复数据库逻辑）

## 实现要点

### Bug 1: User Reports 信息不足
在 ListingReportDetailPage 的商品展示区域，补充以下信息（从 listings 表 join）：
- 商品描述、价格、交易类型、状态、condition
- view_count, save_count（如果字段存在）
- 下单人数（orders count）

### Bug 2: 警告通知合并
调查通知发送逻辑。当多个用户举报同一商品/聊天时，管理员处理后应只发一条合并通知给被举报者：
- 通知内容：因为哪个商品（或跟谁的聊天）被 N 人举报
- 查看 `useResolveListingReport` / `useResolveChatReport` 中的通知发送逻辑

### Bug 3: 惩罚机制 — warn 变 ban
重点调查以下文件：
- `ListingReportDetailPage.tsx` 和 `ChatReportDetailPage.tsx` 中的处理表单
- 检查表单提交时 `scope` 和 `banType` 的默认值
- 检查是否存在 `account_freeze` 作为默认 scope（这会导致 ban 效果）
- 检查 `useCreateBan` 被调用时传入的参数

### Bug 4: Ban Records 取消按钮
在 BansPage.tsx 中：
- 找到 lift/cancel 按钮
- 检查 `useLiftBan` mutation 是否正确调用
- 检查按钮的 onClick 是否正确绑定
- 检查 banId 是否正确传入

## 验证
```bash
cd /Users/george/smivo/admin && npx tsc -b
```

## 报告文件：`docs/bug修复/tasks/T6_report.md`
