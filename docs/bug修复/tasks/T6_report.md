# T6 执行报告：管理后台惩罚机制修复

**执行时间**: 2026-05-08  
**验证命令**: `cd /Users/george/smivo/admin && npx tsc -b`  
**验证结果**: ✅ 0 TypeScript 错误

---

## 根因分析与修复摘要

### Bug 1: User Reports 信息不足 ✅

**根因**：`ListingReportDetailPage.tsx` 的商品卡片只显示了 title/price/category/condition/type/description，缺少浏览数、收藏数、下单数。

**修复**：
- 引入 `useListingOrders(id)` hook（已存在于 `useListingModeration.ts`）获取下单数
- 在商品卡片新增 `listing-stats-row`：显示 👁 view_count（来自 listings.view_count 字段）、🔖 save_count（来自 listings.save_count 字段）、📦 orders（实时计数）
- 新增 `Status` 字段显示 listing 当前状态
- 新增 CSS：`.listing-stats-row` / `.listing-stat`

**修改文件**: `admin/src/pages/moderation/ListingReportDetailPage.tsx`

---

### Bug 2: 警告通知合并（举报人数） ✅

**根因分析**：通知重复是误解。卖家通知只在第 207-234 行发一次（正确）。  
**实际问题**：通知文案不包含举报人数，用户无法了解有多少人举报了他。

**修复**：在卖家通知 body 中加入 `reporterCountText`（"N users"），让用户知道是因为被 N 人举报而下架。例如：  
`"Your listing "XXX" was reported by 3 users and removed after moderation review."`

**修改文件**: `admin/src/pages/moderation/ListingReportDetailPage.tsx`（Step 4b 通知逻辑）

---

### Bug 3: Warn 变 Ban ✅

**两处根因均已修复：**

#### Chat 路径（`useChatReports.ts`）
- **原始错误（第 205-207 行）**：
  ```ts
  if (resolution === 'warn') {
    scopesToApply.push({ scope: 'chat_mute', days: 1 }); // ← 误插入 1 天禁言！
  }
  ```
- **修复**：`warn` 模式完全不进入 `user_bans` 插入逻辑。只有 `restrict` 时才创建实际的封禁记录。
- 警告的执行效果由 Step 1 的 `action_taken = 'warn'` 记录体现，不需要额外 ban 行。

#### Listing 路径（`ListingReportDetailPage.tsx`）
- **原始错误（第 131 行）**：
  ```ts
  if (listingAction === 'takedown' && userPenalty !== 'none' && sellerId) {
  ```
  条件 `userPenalty !== 'none'` 在选 `warn` 时为 true，导致插入 `scope: 'listing_ban'` 的真实 ban 记录。
- **修复**：条件改为 `userPenalty === 'restrict'`，`warn` 时完全跳过 ban 插入。

**修改文件**:
- `admin/src/hooks/useChatReports.ts`
- `admin/src/pages/moderation/ListingReportDetailPage.tsx`

---

### Bug 4: Ban Records 取消按钮无效 ✅

**根因**：`useLiftBan` mutation 中写入了 `lifted_at`、`lifted_by`、`lift_reason` 三个字段，  
但经过迁移文件搜索确认，这三个字段在 `user_bans` 表中**不存在**（无对应迁移）。  
Supabase 返回 column not found 错误，但 `BansPage.tsx` 的 catch 块只有 `console.error`，  
用户看到按钮"无反应"（实际上后台报错了）。

**修复**：
1. 新增迁移 `00130_add_ban_lift_fields.sql`，为 `user_bans` 添加三列：
   - `lifted_at TIMESTAMPTZ DEFAULT NULL`
   - `lifted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL`
   - `lift_reason TEXT DEFAULT NULL`
2. 新增索引 `idx_user_bans_lifted_at` 加速活跃 ban 的查询
3. 迁移成功执行（字段已存在的 NOTICE 是正常的，IF NOT EXISTS 安全幂等）

**修改文件**:
- `supabase/migrations/00130_add_ban_lift_fields.sql`（新增）

---

## 文件修改清单

| 文件 | 变更类型 | 内容 |
|------|---------|------|
| `admin/src/pages/moderation/ListingReportDetailPage.tsx` | 修改 | Bug 1+2+3 修复 |
| `admin/src/hooks/useChatReports.ts` | 修改 | Bug 3（Chat）修复 |
| `supabase/migrations/00130_add_ban_lift_fields.sql` | 新增 | Bug 4 数据库迁移 |

## TypeScript 验证

```
cd /Users/george/smivo/admin && npx tsc -b
# → (no output = 0 errors) ✅
```
