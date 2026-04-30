# SMIVO Plaza 未来设计存档

> **文档定位**:Plaza(校园广场 / 树洞)模块的设计存档。**本阶段不实施**,设计先行,以备未来启动时无缝衔接。
>
> **配套文档**:
> - `00_DOCUMENT_INDEX.md`(总目录)
> - `01_MASTER_BRIEF.md`(产品全景)
> - `03_MULTI_TENANT_ARCHITECTURE.md`(多校架构,Plaza 启动时复用)
> - `04_ADMIN_WEB_SPEC.md`(Admin Web,Plaza 启动时增加审核模块)

---

## 0. 实施状态

- **状态**:🟡 设计完成,实施推迟
- **推迟原因**:产品主导者决定先聚焦"信息审核 + 后台管理"基建,Plaza 待基建完备后再启动
- **重启条件**:Admin Web 上线 + Smith 用户量 > 500 + 至少 3 个用户提出社区类需求

---

## 1. 产品定位

> **Plaza 是 Smivo 的"社区温度调节器",不是流量主战场。**
>
> 以 Smith 实名校友圈为底色的内容社区,在特定"敏感分区"提供匿名保护伞,同时与 Listing 交易体系深度联动。

### 1.1 核心决策记录

| 决策维度 | 选择 | 理由 |
|---|---|---|
| 身份显示模式 | 实名为主,敏感分区可匿名 | 既保住熟人社区氛围,又给敏感话题留出口 |
| 内容形态 | 文本 / 图片 / 投票 / 失物招领 / Listing 联动 | 全功能社区,但 Listing 联动只允许用户主动发起,不自动派发 |
| 互动机制 | 点赞 / 评论(楼中楼)/ 转发 / 收藏 / 举报 / 屏蔽用户 | 标配社交功能 |
| 分区管理 | 预设固定 + Admin 后台可增 | 保留对社区氛围的强控制权 |
| 匿名代号策略 | 每帖独立代号(如"鳄梨#3829") | 隐私优先,Reddit/贴吧验证过的成熟方案 |
| 信息流形态 | 走关注体系(需建 follows 表) | 熟人/兴趣聚合,不依赖算法推荐 |
| 主导航位置 | 派生菜单入口(不抢首屏) | Plaza 是调味品不是主菜 |

### 1.2 风险提示

**冷启动风险**:派生菜单入口 + 关注体系,意味着 Plaza 冷启动会非常艰难——新用户没人可关注、入口又深。**MVP 阶段必须做"无关注 fallback":当用户关注数 < 3 时,信息流自动 fallback 到"分区最新"或"全站热门"**,否则首次进入 Plaza 是空白页就死了。

---

## 2. 数据库 Schema

### 2.1 plaza_categories — 分区表

```sql
CREATE TABLE plaza_categories (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug            text UNIQUE NOT NULL,           -- 'daily', 'tree_hole'
  name            text NOT NULL,
  description     text,
  icon_url        text,
  is_anonymous    boolean DEFAULT false,           -- 强制匿名分区
  display_order   int DEFAULT 0,
  is_active       boolean DEFAULT true,
  college_id      uuid,                            -- 一校一区预留(NULL=全站)
  created_at      timestamptz DEFAULT now(),
  created_by      uuid REFERENCES user_profiles(id)
);
```

**预填充种子数据**:

```sql
INSERT INTO plaza_categories (slug, name, is_anonymous, display_order) VALUES
  ('daily',         '日常',       false, 1),
  ('academic',      '学业',       false, 2),
  ('lost_found',    '失物招领',   false, 3),
  ('marketplace',   '二手转让',   false, 4),
  ('tree_hole',     '树洞',       true,  5),
  ('mental',        '心理互助',   true,  6),
  ('rant',          '吐槽',       true,  7);
```

**重要原则**:匿名规则由分区属性决定,**不是**用户每帖手动选。这样规则简单、不会出现"用户在实名区误发匿名"的事故。

### 2.2 user_follows — 关注关系

```sql
CREATE TABLE user_follows (
  follower_id     uuid REFERENCES user_profiles(id) ON DELETE CASCADE,
  following_id    uuid REFERENCES user_profiles(id) ON DELETE CASCADE,
  created_at      timestamptz DEFAULT now(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id <> following_id)
);
CREATE INDEX idx_follows_follower  ON user_follows(follower_id);
CREATE INDEX idx_follows_following ON user_follows(following_id);
```

### 2.3 forum_posts — 帖子表

```sql
CREATE TABLE forum_posts (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id         uuid NOT NULL REFERENCES plaza_categories(id),
  author_id           uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  
  post_type           text NOT NULL CHECK (post_type IN 
                        ('text','image','poll','lost_found','listing_link')),
  title               text,
  content             text,
  metadata            jsonb DEFAULT '{}'::jsonb,
  -- text: null
  -- image: { images: [url1, url2, ...] }
  -- poll: { question, options: [{text, votes_count}], multi_select, expires_at }
  -- lost_found: { type: 'lost'|'found', item, location, time, contact_method, resolved }
  -- listing_link: { listing_id }
  
  is_anonymous        boolean NOT NULL DEFAULT false,
  anonymous_alias     text,
  
  hearts_count        int DEFAULT 0,
  comments_count      int DEFAULT 0,
  shares_count        int DEFAULT 0,
  bookmarks_count     int DEFAULT 0,
  
  status              text DEFAULT 'published' CHECK (status IN 
                        ('published','pending_review','hidden','deleted')),
  pinned_until        timestamptz,
  
  created_at          timestamptz DEFAULT now(),
  updated_at          timestamptz DEFAULT now()
);
CREATE INDEX idx_posts_category_created ON forum_posts(category_id, created_at DESC);
CREATE INDEX idx_posts_author           ON forum_posts(author_id);
CREATE INDEX idx_posts_status_created   ON forum_posts(status, created_at DESC);
```

### 2.4 forum_comments — 评论(楼中楼)

```sql
CREATE TABLE forum_comments (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id             uuid NOT NULL REFERENCES forum_posts(id) ON DELETE CASCADE,
  author_id           uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  parent_comment_id   uuid REFERENCES forum_comments(id) ON DELETE CASCADE,
  root_comment_id     uuid REFERENCES forum_comments(id) ON DELETE CASCADE,
  content             text NOT NULL,
  is_anonymous        boolean DEFAULT false,
  anonymous_alias     text,
  hearts_count        int DEFAULT 0,
  status              text DEFAULT 'published',
  created_at          timestamptz DEFAULT now()
);
CREATE INDEX idx_comments_post_root ON forum_comments(post_id, root_comment_id, created_at);
```

**楼中楼说明**:
- `parent_comment_id` NULL = 一级楼,非 NULL = 楼中楼回复
- `root_comment_id` 加速查询整条楼中楼链(一次查询拿到完整子树)

### 2.5 forum_interactions — 互动统一表

```sql
CREATE TABLE forum_interactions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  target_type     text NOT NULL CHECK (target_type IN ('post','comment')),
  target_id       uuid NOT NULL,
  interaction_type text NOT NULL CHECK (interaction_type IN ('heart','bookmark','share')),
  created_at      timestamptz DEFAULT now(),
  UNIQUE (user_id, target_type, target_id, interaction_type)
);
CREATE INDEX idx_interactions_target ON forum_interactions(target_type, target_id);
CREATE INDEX idx_interactions_user   ON forum_interactions(user_id, interaction_type);
```

### 2.6 poll_votes — 投票

```sql
CREATE TABLE poll_votes (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id         uuid NOT NULL REFERENCES forum_posts(id) ON DELETE CASCADE,
  user_id         uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  option_index    int NOT NULL,
  created_at      timestamptz DEFAULT now(),
  UNIQUE (post_id, user_id, option_index)
);
```

### 2.7 forum_reports — Plaza 举报

```sql
CREATE TABLE forum_reports (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id     uuid NOT NULL REFERENCES user_profiles(id),
  target_type     text NOT NULL CHECK (target_type IN ('post','comment','user')),
  target_id       uuid NOT NULL,
  reason          text NOT NULL,
  detail          text,
  status          text DEFAULT 'pending' CHECK (status IN ('pending','resolved','dismissed')),
  admin_id        uuid REFERENCES user_profiles(id),
  admin_note      text,
  resolved_at     timestamptz,
  created_at      timestamptz DEFAULT now()
);
CREATE INDEX idx_reports_status ON forum_reports(status, created_at DESC);
```

### 2.8 user_blocks — 屏蔽用户

```sql
CREATE TABLE user_blocks (
  blocker_id      uuid REFERENCES user_profiles(id) ON DELETE CASCADE,
  blocked_id      uuid REFERENCES user_profiles(id) ON DELETE CASCADE,
  created_at      timestamptz DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id)
);
```

---

## 3. 匿名代号生成函数(关键)

```sql
-- 生成稳定的"每帖独立代号"
-- 输入: user_id + post_id  →  输出: "鳄梨#3829" 形式
CREATE OR REPLACE FUNCTION generate_anonymous_alias(
  p_user_id uuid, 
  p_post_id uuid
) RETURNS text AS $$
DECLARE
  alias_words text[] := ARRAY[
    '鳄梨','柠檬','薄荷','栗子','桃子','橘子','椰子','榛果',
    '布丁','麻薯','奶盖','摩卡','可可','拿铁','焦糖','抹茶'
  ];
  hash_val bigint;
  word_idx int;
  num_suffix int;
BEGIN
  hash_val := abs(hashtext(p_user_id::text || p_post_id::text));
  word_idx := (hash_val % array_length(alias_words, 1)) + 1;
  num_suffix := (hash_val / array_length(alias_words, 1)) % 9000 + 1000;
  RETURN alias_words[word_idx] || '#' || num_suffix::text;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

**评论沿用同一帖子的 alias** → 楼主在自己帖子下回复评论时,代号与帖子代号一致(便于读者识别"楼主回复了"),实现方式是评论的 alias 用 `(comment.author_id, comment.post_id)` 而非 `(comment.author_id, comment.id)`。

---

## 4. 脱敏视图(隐私红线)

```sql
-- 前端永远查这个视图,拿不到匿名帖的 author_id
CREATE OR REPLACE VIEW forum_posts_public AS
SELECT 
  p.id, p.category_id, p.post_type, p.title, p.content, p.metadata,
  p.hearts_count, p.comments_count, p.shares_count, p.bookmarks_count,
  p.pinned_until, p.created_at, p.updated_at,
  
  -- 关键脱敏:匿名帖不暴露 author_id
  CASE WHEN p.is_anonymous THEN NULL ELSE p.author_id END AS author_id,
  
  -- 显示名:匿名用 alias,实名用 profile
  CASE WHEN p.is_anonymous 
    THEN p.anonymous_alias 
    ELSE up.display_name END AS display_name,
  CASE WHEN p.is_anonymous 
    THEN NULL 
    ELSE up.avatar_url END AS avatar_url,
    
  p.is_anonymous
FROM forum_posts p
LEFT JOIN user_profiles up ON up.id = p.author_id
WHERE p.status = 'published';

-- 撤销原表的前端查询权限
REVOKE SELECT ON forum_posts FROM authenticated;
GRANT  SELECT ON forum_posts_public TO authenticated;
```

评论同理,建 `forum_comments_public` 视图。

**这是隐私红线,实施时必须坚守**——匿名帖如果暴露 `author_id`,整个匿名系统形同虚设。

---

## 5. RLS 策略要点

```sql
ALTER TABLE forum_posts ENABLE ROW LEVEL SECURITY;

-- 写入:本人 + 已登录
CREATE POLICY "insert_own_post" ON forum_posts FOR INSERT
  WITH CHECK (auth.uid() = author_id);

-- 更新/删除:仅本人
CREATE POLICY "update_own_post" ON forum_posts FOR UPDATE
  USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id AND status = 'published');

-- SELECT 不开放给前端(走 forum_posts_public 视图)
-- Admin 走 service_role,绕过 RLS

ALTER TABLE user_blocks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "manage_own_blocks" ON user_blocks FOR ALL
  USING (auth.uid() = blocker_id);
```

---

## 6. 关注体系信息流(带冷启动 fallback)

```sql
CREATE OR REPLACE FUNCTION feed_following(
  p_user_id uuid,
  p_limit int DEFAULT 20,
  p_cursor timestamptz DEFAULT now()
) RETURNS SETOF forum_posts_public AS $$
DECLARE
  follow_count int;
BEGIN
  SELECT COUNT(*) INTO follow_count 
  FROM user_follows WHERE follower_id = p_user_id;
  
  -- 冷启动 fallback:关注数 < 3,返回全站热门
  IF follow_count < 3 THEN
    RETURN QUERY
    SELECT * FROM forum_posts_public
    WHERE created_at < p_cursor
      AND author_id NOT IN (
        SELECT blocked_id FROM user_blocks WHERE blocker_id = p_user_id
      )
    ORDER BY (hearts_count + comments_count * 2) DESC, created_at DESC
    LIMIT p_limit;
  ELSE
    RETURN QUERY
    SELECT pp.* FROM forum_posts_public pp
    JOIN user_follows uf ON uf.following_id = pp.author_id
    WHERE uf.follower_id = p_user_id
      AND pp.created_at < p_cursor
      AND pp.author_id NOT IN (
        SELECT blocked_id FROM user_blocks WHERE blocker_id = p_user_id
      )
    ORDER BY pp.created_at DESC
    LIMIT p_limit;
  END IF;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
```

**重要原则**:**匿名分区的帖在关注流里不出现**——因为匿名帖逻辑上是"无主"的,出现在"我关注的人发布"里会破坏匿名假象。匿名帖只在"分区时间线"里露出。

---

## 7. 关键交互流程

### 7.1 发帖流

```
用户选分区 → 分区决定是否强制匿名 → 内容编辑(根据 post_type 切换表单) 
→ 客户端敏感词预校验(提示) → 提交 → Edge Function 二次校验 + Moderation API
→ 命中:进 pending_review;未命中:直接 published
→ 推送给关注者
```

### 7.2 屏蔽用户的级联效果

- 屏蔽后:对方的帖子、评论、楼中楼回复**全部不可见**
- 但:**对方仍能看到我的帖子**(单向屏蔽,避免社交压力)
- 匿名分区:屏蔽**不生效**(因为不知道是谁)——这点要在 UI 上明示

---

## 8. Flutter 端目录结构(实施时参考)

```
app/lib/features/plaza/
├── data/
│   ├── models/
│   │   ├── plaza_category.dart
│   │   ├── forum_post.dart
│   │   ├── forum_comment.dart
│   │   └── ...
│   └── repositories/
│       ├── plaza_repository.dart        # 走 forum_posts_public
│       ├── follow_repository.dart
│       └── interaction_repository.dart
├── application/
│   ├── feed_controller.dart             # AsyncNotifier,管理 feed 分页
│   ├── post_compose_controller.dart     # 发帖状态机
│   ├── follow_controller.dart
│   └── ...
└── presentation/
    ├── feed/
    │   ├── feed_page.dart               # Tab: 关注 / 分区
    │   ├── widgets/post_card.dart
    │   └── widgets/empty_follow_state.dart
    ├── category/
    │   └── category_timeline_page.dart
    ├── compose/
    │   ├── compose_page.dart            # 根据 post_type 切换表单
    │   └── widgets/...
    ├── post_detail/
    │   ├── post_detail_page.dart
    │   └── widgets/comment_thread.dart
    └── profile/
        └── follow_list_page.dart
```

---

## 9. Admin Web 接口契约(实施时启用)

| 接口 | 用途 | 权限 |
|---|---|---|
| `GET  /admin/plaza/categories` | 列出所有分区(含禁用) | admin |
| `POST /admin/plaza/categories` | 新建分区 | super_admin |
| `PATCH /admin/plaza/categories/:id` | 改名/排序/启停 | admin |
| `GET  /admin/plaza/reports?status=pending` | 待处理举报队列 | moderator |
| `POST /admin/plaza/reports/:id/resolve` | 处理举报 | moderator |
| `POST /admin/plaza/posts/:id/pin` | 置顶帖子 | moderator |
| `POST /admin/plaza/posts/:id/hide` | 隐藏帖子(软删) | moderator |

---

## 10. 待决事项(启动时处理)

| 待决项 | 决策时机 |
|---|---|
| 失物招领是否升级为独立表(强搜索)| MVP 上线后看实际使用频率 |
| 匿名代号词库是否本地化(英文版)| 国际化时(若产品扩展到非中文校园)|
| Plaza 是否引入"小组"概念(分区下细分)| 用户量 > 1000 后评估 |
| 是否做"热度算法排序"(取代纯时间序)| Plaza 日活帖 > 50 时评估 |
| 是否引入"楼主标识"(Reddit OP 标记)| 实施时与 UI 一并决定 |

---

## 11. 启动 Plaza 时的检查清单

未来启动 Plaza 开发时,按此清单逐项确认:

- [ ] Admin Web 已稳定运行,管理员审核流程顺畅
- [ ] 敏感词系统已成熟,中文词库覆盖充分
- [ ] 用户封禁机制已就位,可以处理 Plaza 违规
- [ ] Smith 用户量已建立基本规模(建议 > 500 活跃用户)
- [ ] 已重读本文档,确认所有决策点仍然成立(产品方向可能已变)
- [ ] 评估是否需要先升级"跨端类型生成"工具链(Plaza 数据模型复杂,共享类型多)

---

*文档版本:v1.0 · 维护者:Smivo 项目主导*
*最后更新:2026-04-29*
*预计实施时间:Q3 2026 或更晚(取决于基建与用户量)*
