# Smivo 后台管理 & 数据库踩坑手册

> **目的**：记录开发 Admin Dashboard 和 Supabase 数据库过程中遇到的所有坑，
> 供后续 agent 在处理后台管理相关任务时参考，避免重复踩坑。
>
> **最后更新**：2026-05-03 · Migration 00093

---

## 目录

1. [PostgREST Schema 缓存](#1-postgrest-schema-缓存)
2. [RLS 无限递归](#2-rls-无限递归)
3. [UUID 与 Text 类型不匹配](#3-uuid-与-text-类型不匹配)
4. [DELETE 顺序与外键约束](#4-delete-顺序与外键约束)
5. [ON DELETE SET NULL 的唯一约束陷阱](#5-on-delete-set-null-的唯一约束陷阱)
6. [SECURITY DEFINER 函数注意事项](#6-security-definer-函数注意事项)
7. [表名与代码中的别名映射](#7-表名与代码中的别名映射)
8. [React Hook Form disabled 字段陷阱](#8-react-hook-form-disabled-字段陷阱)
9. [Zod 数字字段 NaN 验证](#9-zod-数字字段-nan-验证)
10. [Admin RBAC 架构演变](#10-admin-rbac-架构演变)
11. [RPC 函数参数类型](#11-rpc-函数参数类型)
12. [迁移文件命名冲突](#12-迁移文件命名冲突)
13. [Admin 用户删除的 FK 依赖链](#13-admin-用户删除的-fk-依赖链)
14. [常见 HTTP 错误码与数据库错误码对照表](#14-常见错误码对照表)
15. [无 school_id 的表在 Cleanup 中被遗漏](#15-无-school_id-的表在-cleanup-中被遗漏)
16. [pg_safeupdate 禁止无条件 DELETE](#16-pg_safeupdate-禁止无条件-delete)
17. [迁移变更日志](#17-迁移变更日志)

---

## 1. PostgREST Schema 缓存

### 问题
修改或重建 RPC 函数后，通过 Supabase JS SDK 调用时仍返回 **404 Not Found**，
即使函数已经在 SQL Editor 中可以正常执行。

### 原因
PostgREST 有内部 schema cache。当你 `CREATE OR REPLACE FUNCTION` 或
`DROP + CREATE FUNCTION` 后，PostgREST 不会自动感知函数签名变更。

### 解决方案
**每次修改 RPC 函数后，必须在迁移脚本末尾加上：**

```sql
NOTIFY pgrst, 'reload schema';
```

### 注意事项
- 即使加了 NOTIFY，生效也可能需要 10-30 秒
- 如果函数签名（参数类型、返回类型）发生变化，必须先 `DROP FUNCTION` 再 `CREATE`
- `CREATE OR REPLACE` 不能改变函数签名，只能改变函数体
- 在 Supabase Dashboard SQL Editor 中直接执行 SQL 不受此限制（直连 DB）

### 涉及迁移
`00085_fix_cleanup_type_cast.sql`（末尾添加了 NOTIFY）

---

## 2. RLS 无限递归

### 问题
所有 Admin 相关表的 RLS 策略在查询时报错：
`42P17: infinite recursion detected in policy for relation "admin_users"`

### 原因
多个表的 RLS 策略通过子查询检查 `admin_users` 表：
```sql
-- BAD: 检查 admin_users 触发 admin_users 自身的 RLS，形成递归
USING (
  EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE user_id = auth.uid() AND is_active = true
  )
)
```
当 `admin_users` 表自身也有 RLS 且策略中查询自身时，产生无限递归。

### 解决方案
**创建 SECURITY DEFINER 辅助函数来绕过 RLS：**

```sql
-- GOOD: SECURITY DEFINER 绕过 RLS
CREATE OR REPLACE FUNCTION public.is_active_admin()
RETURNS boolean LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE user_id = auth.uid() AND is_active = true
  );
$$;

-- 然后在 RLS 策略中使用函数
CREATE POLICY "..." ON some_table
  USING (public.is_active_admin());
```

### 可用的辅助函数
| 函数 | 用途 |
|------|------|
| `is_active_admin()` | 检查当前用户是否是任何活跃管理员 |
| `is_platform_sysadmin()` | 检查是否是 sysadmin 角色 |
| `is_platform_super_admin()` | 同上（旧别名，保持兼容） |
| `admin_has_college_access(uuid)` | 检查是否有某学校的访问权限 |

### 涉及迁移
`00053`, `00054_fix_all_admin_rls_recursion.sql`, `00068`, `00069`

### 规则
**永远不要在 RLS 策略的 USING 子句中直接查询 `admin_users` 表。**
必须通过上述 SECURITY DEFINER 辅助函数间接查询。

---

## 3. UUID 与 Text 类型不匹配

### 问题
RPC 函数中对 UUID 列执行比较或插入时报错：
- `42883: operator does not exist: uuid = text`
- `42804: column "target_id" is of type uuid but expression is of type text`

### 踩坑场景

#### 场景 A：moderation_queue.target_id
`moderation_queue.target_id` 在 migration 00059 中定义为 **uuid** 类型。
但早期代码错误地将其当作 text 处理：

```sql
-- BAD: 将 uuid 数组转为 text 再比较
DELETE FROM public.moderation_queue
  WHERE target_id = ANY(SELECT unnest(v_listing_ids)::text);

-- GOOD: 直接用 uuid 数组比较
DELETE FROM public.moderation_queue
  WHERE target_id = ANY(v_listing_ids);
```

#### 场景 B：admin_audit_logs.target_id
`admin_audit_logs.target_id` 也是 **uuid** 类型。
不能插入文本字符串：

```sql
-- BAD: 插入文本 'all'
INSERT INTO admin_audit_logs (..., target_id, ...)
VALUES (..., 'all', ...);

-- BAD: 将 uuid 参数转为 text
VALUES (..., p_school_id::text, ...);

-- GOOD: 使用零值 UUID 表示平台级操作
VALUES (..., '00000000-0000-0000-0000-000000000000'::uuid, ...);

-- GOOD: 直接使用 uuid 参数
VALUES (..., p_school_id, ...);
```

### 规则
- **在写任何涉及某列的 SQL 之前，先确认该列的实际数据类型**
- UUID 列之间比较不需要任何类型转换
- 永远不要对 UUID 列使用 `::text` 转换后再做比较
- 需要一个"无目标"的 UUID 占位符时，使用零值 UUID

### 涉及迁移
`00083`, `00084`, `00085_fix_cleanup_type_cast.sql`

---

## 4. DELETE 顺序与外键约束

### 问题
批量删除数据时报错：
- `23503: update or delete on table "xxx" violates foreign key constraint`
- HTTP 409 Conflict

### 原因
PostgreSQL 外键约束要求必须先删除子表记录，再删除父表记录。

### 正确的删除顺序

以下是经过验证的完整删除顺序（子表 → 父表）：

```
1. rental_extensions    (→ orders)
2. order_evidence       (→ orders)
3. messages             (→ chat_rooms)
4. content_reports      (→ listings, chat_rooms, users) ⚠️ 必须在父表之前
5. listing_views        (→ listings)
6. moderation_queue     (→ listings)
7. listing_moderation_notices (→ listings)
8. moderation_drafts    (→ listings)
9. saved_listings       (→ listings)
10. listing_images      (→ listings)
11. chat_rooms          (→ listings)
12. orders              (→ listings)
13. listings            ← 所有子表已清空，安全删除
14. user_blocks         (→ user_profiles × 2)
15. user_feedbacks      (→ user_profiles)
16. contribution_ledger (→ user_profiles)
17. notifications       (→ user_profiles, chat_rooms)
18. user_bans           (→ user_profiles)
19. user_active_sessions(→ user_profiles)
20. user_heartbeats     (→ user_profiles)
21. hourly_active_users
```

### 涉及迁移
`00083`, `00084`, `00085`

---

## 5. ON DELETE SET NULL 的唯一约束陷阱

### 问题
删除 `listings` 或 `chat_rooms` 记录时报错：
`23505: duplicate key value violates unique constraint "unique_report_per_target"`

### 原因
`content_reports` 表有以下结构：
- FK：`listing_id` → listings (ON DELETE SET NULL)
- FK：`chat_room_id` → chat_rooms (ON DELETE SET NULL)
- Unique constraint：`(reporter_id, reported_user_id, listing_id, chat_room_id)`

当删除一个 listing 时：
1. ON DELETE SET NULL 将 `content_reports.listing_id` 置为 NULL
2. 如果同一个 reporter + reported_user 之前还有其他 report 且 listing_id 也是 NULL
3. 就会出现两条 `(reporter, reported, NULL, chat_room_id)` 的记录
4. 违反唯一约束

### 解决方案
**必须在删除 listings/chat_rooms 之前先删除 content_reports：**

```sql
-- GOOD: 先删 reports，再删 listings
DELETE FROM public.content_reports WHERE listing_id = ANY(v_listing_ids);
DELETE FROM public.content_reports WHERE chat_room_id = ANY(v_room_ids);
DELETE FROM public.content_reports WHERE reporter_id = ANY(v_user_ids)
                                    OR reported_user_id = ANY(v_user_ids);
-- 然后再安全地删除 listings 和 chat_rooms
DELETE FROM public.listings WHERE ...;
```

### 规则
**任何有 ON DELETE SET NULL + 唯一约束组合的表，必须先显式删除子记录。**
不要依赖 CASCADE 或 SET NULL 行为。

### 涉及迁移
`00085_fix_cleanup_type_cast.sql`

---

## 6. SECURITY DEFINER 函数注意事项

### 关键规则

1. **必须在函数开头做权限检查**：
   ```sql
   IF NOT public.is_platform_sysadmin() THEN
     RAISE EXCEPTION 'Permission denied: sysadmin only';
   END IF;
   ```

2. **授权给 authenticated 角色**（不是 anon）：
   ```sql
   GRANT EXECUTE ON FUNCTION public.xxx() TO authenticated;
   ```

3. **设置 search_path**（防止 schema 注入）：
   ```sql
   CREATE FUNCTION ... SECURITY DEFINER
   SET search_path = public AS $$...$$;
   ```

4. **is_platform_sysadmin() 内部使用 admin_users 表**（migration 00068 后），
   不再使用旧的 `admin_roles` 表。

5. **删除 auth.users 需要设置 search_path**：
   ```sql
   SET search_path = public, auth
   ```

### 涉及迁移
`00041`, `00067`, `00068`, `00078-00082`, `00085`

---

## 7. 表名与代码中的别名映射

### 关键映射

| 数据库表名 | Admin 代码常量 | 说明 |
|-----------|---------------|------|
| `schools` | `TABLES.COLLEGES` | 代码中叫 "colleges"，数据库中叫 "schools" |
| `admin_users` | `TABLES.ADMIN_USERS` | 统一 RBAC 来源（migration 00068 后） |
| `admin_roles` | ❌ 已弃用 | 00068 后弃用，仅保留历史数据 |
| `content_reports` | `TABLES.CONTENT_REPORTS` | 不是 "reports" |
| `user_feedbacks` | `TABLES.USER_FEEDBACKS` | 注意是复数 |
| `system_settings` | `TABLES.SYSTEM_SETTINGS` | 不是 "feature_flags" |

### 常见错误
- 查询 `colleges` 表 → 应该查 `schools`
- 查询 `admin_roles` → 应该查 `admin_users`（00068 迁移后）
- 代码中的 College 类型对应数据库的 schools 表

### React Hook 命名
Hook 函数名用 `useColleges` 但内部查询 `TABLES.COLLEGES` = `'schools'`。
TypeScript 类型定义中 `College` 接口的字段必须匹配 `schools` 表的列名。

---

## 8. React Hook Form disabled 字段陷阱

### 问题
CollegeDialog 中编辑学校后点击保存，表单静默失败，不保存也不报错。

### 原因
React Hook Form 中，设为 `disabled` 的 input 其值**会被从表单数据中移除**。
如果 Zod 校验规则要求该字段必填（如 `slug`），表单校验静默失败。

```tsx
// BAD: disabled 的字段不会被包含在表单提交数据中
<input {...register('slug')} disabled={isEditing} />

// GOOD: readOnly 保持值在表单数据中，但用户不能编辑
<input {...register('slug')} readOnly={isEditing} />
```

### 规则
- 需要 **只读但仍然提交** 的字段，用 `readOnly` 而非 `disabled`
- 如果字段值对表单验证有要求，绝不能用 `disabled`

### 涉及文件
`admin/src/components/settings/CollegeDialog.tsx`

---

## 9. Zod 数字字段 NaN 验证

### 问题
清空数字输入框后提交表单时，Zod 校验静默失败。

### 原因
HTML `<input type="number">` 在清空时产生 `NaN`（通过 `valueAsNumber`）。
Zod 的 `z.number()` 不接受 `NaN`，导致校验静默失败。

### 解决方案
使用 `z.preprocess()` 预处理：

```ts
student_count: z.preprocess((val) => {
  if (val === '' || val === null || val === undefined || Number.isNaN(val))
    return null;
  return Number(val);
}, z.number().int().positive().nullable().optional()),
```

### 规则
所有可选数字字段都应该用 `z.preprocess` 包裹，
安全处理 `NaN`、空字符串、`null`、`undefined`。

---

## 10. Admin RBAC 架构演变

### 时间线

| 迁移 | 变更 |
|------|------|
| 00036 | 创建 `admin_roles` 表 |
| 00039 | 创建 `admin_users` + `admin_school_scopes` 表 |
| 00052 | Web Admin 基础设施，大量 RLS 策略 |
| 00053 | 修复 `admin_users` RLS 递归 |
| 00054 | 修复所有 12 个表的 20 条递归策略 |
| 00068 | **统一到 admin_users**，弃用 admin_roles |
| 00069 | 修复 00068 引入的新递归 |

### 当前状态（00068+）
- **RBAC 来源**：`admin_users` 表（唯一来源）
- **角色层级**：sysadmin > platform_admin > platform_reviewer > school_admin > school_reviewer
- **学校权限**：`admin_school_scopes` 表
- **弃用表**：`admin_roles`（仅保留历史数据，不再写入）

### 规则
- 任何新的 admin 功能必须检查 `admin_users`，不是 `admin_roles`
- 使用 `is_platform_sysadmin()` 检查最高权限
- 使用 `is_active_admin()` 检查是否是任何管理员
- 使用 `admin_has_college_access(college_id)` 检查学校级权限

---

## 11. RPC 函数参数类型

### 规则
- Supabase JS SDK 调用 RPC 时，参数值会被序列化为 JSON
- UUID 值在 JSON 中是字符串，PostgREST 会自动转为 uuid
- 不要在函数内部对 uuid 参数做 `::text` 转换
- 函数参数类型必须与数据库列类型精确匹配

### 示例
```ts
// JS 端传递 UUID 字符串 — PostgREST 自动转为 uuid
const { data, error } = await supabase.rpc('clear_school_test_data', {
  p_school_id: 'eb9e5e21-646d-43ba-92bd-fbd50f482d26',
});
```

```sql
-- SQL 端参数已经是 uuid，直接用
CREATE FUNCTION clear_school_test_data(p_school_id uuid) ...
  -- GOOD: 直接比较
  WHERE school_id = p_school_id
  -- BAD: 不必要的类型转换
  WHERE school_id = p_school_id::text
```

---

## 12. 迁移文件命名冲突

### 问题
部分迁移编号有重复（如两个 00033、两个 00034、两个 00043 等）。

### 当前重复编号
| 编号 | 文件 A | 文件 B |
|------|--------|--------|
| 00033 | `delete_account_rpc` | `fix_accept_rpc_security` |
| 00034 | `chat_pin_archive` | `listing_rls_order_participants` |
| 00043 | `new_message_notification` | `notification_preferences_expansion` |
| 00044 | `review_system` | `ugc_moderation` |
| 00051 | `update_feedback_status` | `user_heartbeat` |
| 00065 | `dict_access_level` | `user_active_sessions` |
| 00066 | `check_chat_eligibility` | `remove_dict_school_duplicates` |
| 00067 | `content_filter_warn_message` | `roles_and_cleanup_rpcs` |
| 00068 | `admin_messages_policy` | `unify_admin_roles` |
| 00069 | `admin_reward_points` | `fix_rls_recursion` |

### 规则
- **新迁移必须使用当前最大编号 + 1**（当前最大 = 00093）
- 下一个迁移应该是 `00094_xxx.sql`
- 命名格式：`00NNN_简洁描述.sql`

---

## 13. Admin 用户删除的 FK 依赖链

### 问题
删除用户时各种 FK 约束错误。

### 正确删除顺序
用户删除需要按照以下顺序清理关联数据：

```
1. rental_extensions (通过 orders 关联)
2. order_evidence (通过 orders 关联)
3. orders (buyer_id / seller_id)
4. notifications (user_id)
5. messages (sender_id)
6. chat_rooms (buyer_id / seller_id)
7. saved_listings (user_id)
8. listing_images (通过 listings 关联)
9. listings (seller_id)
10. content_reports (reporter_id / reported_user_id)
11. moderation_queue (user_id)
12. user_feedbacks (user_id)
13. user_active_sessions (user_id)
14. admin_roles (user_id)
15. school_admins (user_id)
16. admin_audit_logs (admin_id)
17. user_bans (user_id)
18. user_reviews (reviewer_id / target_user_id)
19. user_profiles (id)
20. auth.users (id)   ← 需要 search_path 包含 auth
```

### 涉及迁移
`00078`, `00079`, `00080_admin_delete_user_robust.sql`, `00081`

---

## 14. 常见错误码对照表

| HTTP | PG Code | 含义 | 常见原因 |
|------|---------|------|---------|
| 404 | 42883 | 函数不存在 | PostgREST schema cache 过期，需要 NOTIFY |
| 400 | 42804 | 类型不匹配 | uuid 列与 text 值比较 |
| 400 | 22P02 | 无效输入语法 | 向 uuid 列插入非 uuid 文本如 'all' |
| 409 | 23505 | 唯一约束冲突 | ON DELETE SET NULL 导致重复行 |
| 409 | 23503 | 外键约束冲突 | DELETE 顺序错误，子记录未先删除 |
| 403 | 42501 | 权限不足 | RLS 阻止，或未 GRANT EXECUTE |
| 500 | 42P17 | 无限递归 | RLS 策略循环引用 admin_users |
| 400 | P0001 | 自定义异常 | RAISE EXCEPTION（如权限检查失败） |

---

## 15. 无 school_id 的表在 Cleanup 中被遗漏

### 问题
学校级清理执行成功后，`user_feedbacks`、`contribution_ledger`、`admin_audit_logs`
中的数据仍然存在。

### 原因
这三个表**没有 `school_id` 列**，无法按学校过滤：

| 表 | FK 关联 | school_id? |
|----|---------|------------|
| `user_feedbacks` | `user_id → auth.users` | ❌ 无 |
| `contribution_ledger` | `user_id → auth.users` | ❌ 无 |
| `admin_audit_logs` | `admin_id → admin_users` | 有 `college_id` 但不可靠 |

清理函数原先只删除 `WHERE user_id = ANY(v_user_ids)` 的记录，
但如果 feedback 提交者的 `user_profiles.school_id` 不匹配（或为 NULL），
记录就会被跳过。`admin_audit_logs` 则从未被纳入删除范围。

### 解决方案
通过 `v_user_ids`（学校用户 ID 数组）间接关联删除：

```sql
-- GOOD: 通过用户 ID 关联到学校，只删该校数据
DELETE FROM public.user_feedbacks WHERE user_id = ANY(v_user_ids);
DELETE FROM public.contribution_ledger WHERE user_id = ANY(v_user_ids);
-- admin_audit_logs 不删除，审计日志必须保留
```

> ⚠️ **不要用 `WHERE true` 全量删除**——这会清空所有学校的数据！
> Migration 00086/00087 曾这样做（pre-launch 临时方案），
> 已在 00088 中修复为生产安全的学校级删除。

### 规则
- **编写清理函数时，列出所有目标表并检查每个表是否有 school_id 列**
- 没有 school_id 的表必须通过 `user_id = ANY(v_user_ids)` 间接关联删除
- **永远不要在学校级清理中使用 `WHERE true`** — 会影响其他学校
- `admin_audit_logs` 不应被删除，审计日志必须永久保留
- 清理后立即插入一条新的 audit log 记录本次操作

### 涉及迁移
`00086`, `00087`, `00088_production_safe_cleanup.sql`（最终修复）

---

## 16. pg_safeupdate 禁止无条件 DELETE

### 问题
全量删除表数据时报错：
`21000: DELETE requires a WHERE clause`

### 原因
Supabase 默认启用了 `pg_safeupdate` 扩展，禁止没有 WHERE 子句的 DELETE 和 UPDATE 语句，
防止意外清空整张表。这个限制在 SECURITY DEFINER 函数内也生效。

### 解决方案
**给所有无条件 DELETE 加上 `WHERE true`：**

```sql
-- BAD: pg_safeupdate 拒绝
DELETE FROM public.user_feedbacks;

-- GOOD: 加 WHERE true 绕过检查
DELETE FROM public.user_feedbacks WHERE true;
```

### 规则
- **Supabase 中所有无条件 DELETE/UPDATE 必须加 `WHERE true`**
- 这包括 SECURITY DEFINER 函数内部的语句
- `TRUNCATE` 不受此限制，但需要更高权限

### 涉及迁移
`00087_fix_cleanup_where_clause.sql`

---

## 17. 迁移变更日志

### 最近重要迁移摘要

| 编号 | 文件 | 核心变更 |
|------|------|---------|
| 00052 | `admin_web_infrastructure` | Admin Web 全部基础设施表 |
| 00054 | `fix_all_admin_rls_recursion` | 修复 20 条 RLS 递归策略 |
| 00068 | `unify_admin_roles` | RBAC 统一到 admin_users，5 级角色 |
| 00076 | `apply_restriction_rpc` | 用户限制 RPC（叠加处罚） |
| 00077 | `platform_defaults` | 平台默认字典数据系统 |
| 00078-82 | `admin_delete/create_user` | 管理员用户增删 RPC |
| 00083 | `fix_school_cleanup_rpc` | 补充缺失的 FK 依赖表删除 |
| 00084 | `fix_platform_cleanup_rpc` | 同上（平台级） |
| 00085 | `fix_cleanup_type_cast` | 修复 uuid/text 类型、DELETE 顺序、唯一约束 |
| 00086 | `fix_cleanup_feedback_audit` | 清理函数补充 feedbacks、contributions、audit_logs |
| 00087 | `fix_cleanup_where_clause` | pg_safeupdate: 无条件 DELETE 加 WHERE true |
| 00088 | `production_safe_cleanup` | 恢复学校级作用域，生产安全，保留 audit log |
| 00089 | `open_peeps_avatar` | Open Peeps 头像系统 |
| 00090 | `image_moderation_infrastructure` | platform_secrets 加密存储 + image_moderation_usage 月计数器 |
| 00091 | `pickup_location_defaults` | platform_pickup_location_defaults 表 + import_platform_defaults 扩展支持 pickup_location |
| 00092 | `fix_school_dict_rls` | 修复 school_categories/school_conditions/pickup_locations 写策略改用 admin_users 表；补充 pickup_locations 缺失的 INSERT/UPDATE/DELETE policy |
| 00093 | `admin_storage_policy` | 允许 admin_users 上传文件到 listing-images/moderation-test/ 路径 |

### 更新本文档
**每次创建新的数据库迁移时，请在上表中追加一行，并在相关章节补充踩坑记录。**
