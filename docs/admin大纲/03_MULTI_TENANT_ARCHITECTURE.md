# SMIVO 多校架构(Multi-Tenant Architecture)规范

> **文档定位**:Smivo 多租户架构的设计规范。本文档定义如何在同一个 Supabase 后端支持多所学校的数据隔离与权限管理。
>
> **配套文档**:`00_DOCUMENT_INDEX.md` 中的总目录

---

## 1. 设计原则

### 1.1 多租户模式选型

Smivo 采用**模式 C:共享数据库 + 行级隔离**:

| 模式 | 隔离强度 | 复杂度 | 适合 Smivo |
|---|---|---|---|
| A. 物理隔离(每校独立数据库) | 最强 | 极高 | ❌ 太重 |
| B. Schema 隔离(每校独立 schema) | 强 | 高 | ⚠️ 偏重 |
| **C. 共享数据库 + 行级隔离** | 中 | 中 | ✅ **采用** |

**实现方式**:每个业务表添加 `college_id` 字段,通过 Row Level Security (RLS) 强制隔离。

### 1.2 核心约束

- **数据隔离**:学校管理员**永远**只能看到本校数据
- **跨校能力**:仅平台超管 / 平台审核员可跨校
- **App 端隔离**:用户只能看到本校数据(用户的 `college_id` 在注册时按邮箱后缀自动归类)
- **零信任前端**:所有隔离由数据库 RLS 强制,前端不持有 Service Role Key

---

## 2. 学校实体设计

### 2.1 colleges 表

```sql
CREATE TABLE colleges (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code            text UNIQUE NOT NULL,           -- 'smith', 'mt_holyoke'
  name            text NOT NULL,                  -- 'Smith College'
  short_name      text,                            -- 'Smith'
  email_domain    text NOT NULL UNIQUE,           -- '@smith.edu'
  logo_url        text,
  primary_color   text,                            -- 品牌色
  is_active       boolean DEFAULT true,
  launched_at     timestamptz,                    -- 正式上线时间
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);
CREATE INDEX idx_colleges_active ON colleges(is_active);
CREATE INDEX idx_colleges_domain ON colleges(email_domain);
```

### 2.2 初始化数据

```sql
INSERT INTO colleges (code, name, short_name, email_domain, is_active, launched_at) VALUES
  ('smith', 'Smith College', 'Smith', '@smith.edu', true, now());
```

### 2.3 用户与学校的归类逻辑

用户注册时,Edge Function 根据邮箱后缀自动查找对应学校:

```typescript
// /functions/v1/auth/signup
const emailDomain = '@' + email.split('@')[1];
const college = await supabase
  .from('colleges')
  .select('id')
  .eq('email_domain', emailDomain)
  .eq('is_active', true)
  .single();

if (!college) {
  throw new Error('UNSUPPORTED_DOMAIN: 您的邮箱后缀暂未在 Smivo 上线');
}

await supabase.auth.admin.createUser({
  email,
  user_metadata: { college_id: college.id }
});
```

---

## 3. 三级权限模型

### 3.1 角色定义

```
Platform Super Admin (平台超管)
  ├─ 所有学校 + 平台级配置 + 学校管理
  ├─ 唯一能看到"学校管理"页面的角色
  └─ 唯一能修改 Feature Flag 的角色

Platform Moderator (平台审核员)
  ├─ 跨校审核(被授权的学校)
  ├─ 可见所有授权学校的数据
  ├─ 不能改学校级配置、不能看学校管理
  └─ 数据字典只读权限

School Admin (学校管理员)
  ├─ 仅本校管理(数据完全隔离)
  ├─ 不能看其他学校数据,不能跨校
  └─ 可在本校添加其他学校管理员
```

### 3.2 数据库设计

```sql
-- Admin 用户主表
CREATE TABLE admin_users (
  user_id           uuid PRIMARY KEY REFERENCES user_profiles(id),
  role              text NOT NULL CHECK (role IN ('platform_super', 'platform_moderator', 'school_admin')),
  is_platform_wide  boolean DEFAULT false,         -- true=可看全平台数据
  created_at        timestamptz DEFAULT now(),
  created_by        uuid REFERENCES user_profiles(id)
);

-- Admin 的学校权限范围
CREATE TABLE admin_school_scopes (
  admin_id      uuid NOT NULL REFERENCES admin_users(user_id) ON DELETE CASCADE,
  college_id    uuid NOT NULL REFERENCES colleges(id),
  permissions   jsonb DEFAULT '{}'::jsonb,         -- 该校的细分权限,如 {"moderation": true, "user_mgmt": false}
  granted_at    timestamptz DEFAULT now(),
  granted_by    uuid REFERENCES user_profiles(id),
  PRIMARY KEY (admin_id, college_id)
);

CREATE INDEX idx_scopes_admin ON admin_school_scopes(admin_id);
CREATE INDEX idx_scopes_college ON admin_school_scopes(college_id);
```

### 3.3 角色与表的对应关系

| 角色 | is_platform_wide | admin_school_scopes |
|---|---|---|
| Platform Super | true | 不限制(所有学校都能管) |
| Platform Moderator | false 或 true | 列出授权的学校 |
| School Admin | false | 仅本校 1 条记录 |

### 3.4 权限判定函数(关键 RPC)

```sql
-- 判断当前 admin 是否有权限访问某个学校的数据
CREATE OR REPLACE FUNCTION admin_has_college_access(p_college_id uuid)
RETURNS boolean AS $$
DECLARE
  v_admin record;
BEGIN
  SELECT * INTO v_admin FROM admin_users WHERE user_id = auth.uid();
  
  IF v_admin IS NULL THEN
    RETURN false;
  END IF;
  
  -- 平台超管 / 全平台权限的审核员:无限制
  IF v_admin.is_platform_wide THEN
    RETURN true;
  END IF;
  
  -- 其他角色:检查 admin_school_scopes
  RETURN EXISTS (
    SELECT 1 FROM admin_school_scopes 
    WHERE admin_id = auth.uid() AND college_id = p_college_id
  );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
```

---

## 4. 业务表的 college_id 字段

### 4.1 必须添加 college_id 的表

```sql
ALTER TABLE user_profiles    ADD COLUMN college_id uuid NOT NULL REFERENCES colleges(id);
ALTER TABLE listings         ADD COLUMN college_id uuid NOT NULL REFERENCES colleges(id);
ALTER TABLE orders           ADD COLUMN college_id uuid NOT NULL REFERENCES colleges(id);
ALTER TABLE chat_rooms       ADD COLUMN college_id uuid NOT NULL REFERENCES colleges(id);
ALTER TABLE messages         ADD COLUMN college_id uuid NOT NULL REFERENCES colleges(id);
ALTER TABLE user_reports     ADD COLUMN college_id uuid NOT NULL REFERENCES colleges(id);
ALTER TABLE user_bans        ADD COLUMN college_id uuid NOT NULL REFERENCES colleges(id);
ALTER TABLE user_feedbacks   ADD COLUMN college_id uuid NOT NULL REFERENCES colleges(id);
ALTER TABLE moderation_drafts ADD COLUMN college_id uuid NOT NULL REFERENCES colleges(id);
ALTER TABLE hourly_active_users ADD COLUMN college_id uuid; -- 已存在,保留 NULL 兼容
ALTER TABLE push_jobs        ADD COLUMN college_id uuid REFERENCES colleges(id); -- NULL 表示全平台推送

-- 加索引
CREATE INDEX idx_listings_college ON listings(college_id);
CREATE INDEX idx_orders_college ON orders(college_id);
-- ... 类似为其他表加索引
```

### 4.2 不需要 college_id 的表

平台级配置表,不分学校:
- `colleges`(本身就是学校列表)
- `admin_users` / `admin_school_scopes`(平台级)
- `system_settings`(全平台开关)
- `dict_categories` / `dict_items`(全平台共享字典)
- `sensitive_words`(全平台共享词库)
- `admin_audit_logs`(记录所有 admin 操作)

### 4.3 自动注入 college_id 的触发器

为防止前端漏传 `college_id`,在所有业务表添加 BEFORE INSERT 触发器:

```sql
CREATE OR REPLACE FUNCTION auto_inject_college_id()
RETURNS trigger AS $$
DECLARE
  v_user_college uuid;
BEGIN
  IF NEW.college_id IS NULL THEN
    -- 从当前用户的 profile 中读取 college_id
    SELECT college_id INTO v_user_college 
    FROM user_profiles WHERE id = auth.uid();
    
    IF v_user_college IS NULL THEN
      RAISE EXCEPTION 'CANNOT_DETERMINE_COLLEGE_ID';
    END IF;
    
    NEW.college_id := v_user_college;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 应用到各业务表
CREATE TRIGGER trg_inject_college_listings
  BEFORE INSERT ON listings
  FOR EACH ROW EXECUTE FUNCTION auto_inject_college_id();
-- 类似为其他表创建
```

---

## 5. RLS 策略

### 5.1 业务表的标准 RLS 模式

每个业务表的 RLS 都遵循同一模式:

```sql
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;

-- 普通用户:只能看本校数据
CREATE POLICY "users_see_own_college" ON listings FOR SELECT
  USING (
    college_id = (SELECT college_id FROM user_profiles WHERE id = auth.uid())
  );

-- 普通用户:只能写本校数据
CREATE POLICY "users_write_own_college" ON listings FOR INSERT
  WITH CHECK (
    college_id = (SELECT college_id FROM user_profiles WHERE id = auth.uid())
  );

-- Admin:基于权限范围访问
CREATE POLICY "admins_access_authorized_colleges" ON listings FOR ALL
  USING (admin_has_college_access(college_id));
```

### 5.2 Admin 操作绕过 RLS

Edge Functions 使用 Service Role Key 时**自动绕过 RLS**。Admin 的所有写操作必须通过 Edge Function,绝不允许前端直接连数据库写入。

---

## 6. 数据迁移指引(地基阶段执行一次)

### 6.1 迁移顺序

```sql
-- Step 1: 创建 colleges 表并插入 Smith
CREATE TABLE colleges (...);
INSERT INTO colleges (...);

-- Step 2: 给所有业务表添加 college_id(允许 NULL)
ALTER TABLE user_profiles ADD COLUMN college_id uuid REFERENCES colleges(id);
-- ... 其他表

-- Step 3: 回填现有数据(全部归到 Smith)
UPDATE user_profiles SET college_id = (SELECT id FROM colleges WHERE code = 'smith');
UPDATE listings SET college_id = (SELECT id FROM colleges WHERE code = 'smith');
-- ... 其他表

-- Step 4: 加 NOT NULL 约束
ALTER TABLE user_profiles ALTER COLUMN college_id SET NOT NULL;
-- ... 其他表

-- Step 5: 创建索引
CREATE INDEX idx_listings_college ON listings(college_id);
-- ... 其他索引

-- Step 6: 创建触发器
-- ... 见 §4.3

-- Step 7: 启用 RLS
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
-- ... 其他表

-- Step 8: 创建 RLS 策略
-- ... 见 §5.1
```

### 6.2 迁移验证清单

- [ ] 所有业务表都有 `college_id` 且 NOT NULL
- [ ] 所有 RLS 策略已创建
- [ ] App 端正常运行(用户能看到 Smith 数据)
- [ ] 跨校隔离测试:创建一个 Mt Holyoke 用户,确认看不到 Smith 数据
- [ ] Admin Web 学校切换器正常工作

---

## 7. 学校切换器(Admin Web 顶栏)

### 7.1 行为定义

| 角色 | 切换器显示什么 |
|---|---|
| Platform Super Admin | 所有学校 + "🌐 全平台视图" |
| Platform Moderator(全平台权限) | 同上 |
| Platform Moderator(部分授权) | 仅授权学校 |
| School Admin | 固定显示其学校,不可切换 |

### 7.2 默认行为

**首次登录**:平台超管/审核员默认进入"上次选的学校"(localStorage 持久化);**无上次记录则进入第一个授权的学校**。

### 7.3 切换语义

切换学校 = **整个 Admin Web 内容区数据源切换**。所有列表、统计、操作都基于"当前选中学校"。
切换到"全平台视图"时:跨校汇总数据,部分需要单校上下文的操作(如发推送)会显示提示。

### 7.4 前端实现

使用 Zustand 全局状态:

```typescript
// admin_web/src/stores/school-scope-store.ts
interface SchoolScopeState {
  currentScope: 'platform' | string;  // 'platform' 或 college_id
  availableScopes: { id: string; name: string; isPlatform?: boolean }[];
  setScope: (scope: string) => void;
}
```

所有 API 请求都自动携带 `currentScope` 作为查询参数,Edge Function 负责按此过滤数据。

---

## 8. App 端的多校适配

### 8.1 注册流

用户输入 `.edu` 邮箱 → Edge Function 根据邮箱后缀查询 `colleges` 表 → 创建用户时自动归类到对应学校。

不在 `colleges` 中的邮箱后缀(如 `@harvard.edu` 在 Smivo 暂未上线)→ 友好提示"您的学校暂未上线 Smivo,加入等候名单"。

### 8.2 数据查询

App 端**不需要传 `college_id`**——RLS 自动过滤,用户的 JWT 中的 `auth.uid()` 关联到 user_profiles.college_id,只能看到本校数据。

### 8.3 跨校浏览(未来扩展)

MVP 不支持。未来如果开放跨校浏览,需:
- 增加 Feature Flag `cross_college_browse_enabled`
- 调整 RLS 策略
- App 端加学校筛选器

---

## 9. 已知风险与待办

| 风险 | 缓解 |
|---|---|
| 用户邮箱后缀变更后 college_id 错乱 | 邮箱后缀绑定后不允许修改;若必要,走 Admin 手动迁移流程 |
| 触发器无法处理批量历史数据 | 一次性迁移走 SQL,触发器仅服务新数据 |
| Service Role Key 使用过广 | 严格在 Edge Function 中使用,前端永不持有 |
| 跨校 admin 误操作影响多校 | 所有跨校写操作必须有当前 school_scope 上下文,审计日志记录目标学校 |

---

*文档版本:v1.0*
