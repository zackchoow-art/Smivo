# SMIVO 项目全景简报

> **文档定位**:Smivo 项目最高级别的产品与架构说明书,所有 Agent 与开发者的入门读物。
>
> **配套文档**:见 `00_DOCUMENT_INDEX.md`

---

## 1. 软件介绍与愿景

**Smivo** 是一款专为高校学生打造的 C2C(校园二手与租赁)高信任度交易平台与校园社区。

应用首发站为 **Smith College**。产品的核心愿景是通过 `.edu` 邮箱的严格身份壁垒,建立一个只有同校真实校友才能参与的"安全交易与交流圈",并计划未来通过"一校一区"的模式向全美其他高校横向扩张。

---

## 2. 核心问题

- **信任与安全短板**:解决 Facebook Marketplace 和 Craigslist 等平台因身份不明导致的面交安全隐患和诈骗问题
- **租赁摩擦成本**:传统闲鱼模式只支持"买卖"。Smivo 原生支持"时间计费租赁(日/周/月)",并自带押金流转机制
- **沟通效率**:将零散的讨价还价整合为结构化的"交易大厅"与订单全生命周期追踪

---

## 3. 技术架构

### 3.1 仓库结构

Monorepo 模式,详见 `02_MONOREPO_ARCHITECTURE.md`:
```
smivo/
├── docs/        — 所有规范文档
├── app/         — Flutter App(iOS/Android/Web)
├── admin_web/   — React Admin 控制台
├── website/     — 静态官网
└── supabase/    — Supabase 工程(migrations + functions)
```

### 3.2 技术栈

**App 端(`app/`)**
- Flutter
- Riverpod(状态管理,Code generation,AsyncNotifier)
- GoRouter(支持 Universal Links)
- Google Stitch 设计的双主题系统:Smivo Teal 圆角玻璃拟物 / IKEA 高对比度网格粗野风

**Admin Web(`admin_web/`)**
- React 18 + Vite + TypeScript
- Tailwind CSS + shadcn/ui
- TanStack Query + Zustand
- React Router v6
- Lucide React 图标
- Recharts 图表

**Website(`website/`)**
- 纯静态 HTML/CSS,Vercel 托管

**后端(`supabase/`)**
- PostgreSQL(Row Level Security)
- Supabase Auth(仅 `.edu` 邮箱后缀注册)
- Supabase Realtime(实时聊天 + Admin 协作同步)
- Supabase Storage(图片、订单凭证)
- Edge Functions(TypeScript / Deno,处理特权逻辑)

**第三方**
- OneSignal(推送通知)

---

## 4. 核心数据结构

主要业务表:
- `colleges` — 学校(多校架构,详见 03)
- `user_profiles` — 用户档案(含 `last_active_at`、`college_id`)
- `listings` & `listing_images` — 商品与图片
- `orders` — 订单流水(含租赁状态机)
- `order_evidence` — 交易凭证库
- `chat_rooms` & `messages` — 聊天
- `rental_extensions` — 租赁延期协商

Admin 与基建表(详见 04):
- `admin_users` & `admin_school_scopes` — 管理员与权限范围
- `admin_audit_logs` — 操作审计
- `system_settings` — Feature Flag
- `dict_categories` & `dict_items` — 数据字典
- `sensitive_words` — 敏感词词库
- `user_bans` — 封禁记录
- `user_reports` — 举报记录
- `user_feedbacks` & `feedback_replies` — 反馈
- `contribution_scores` — 贡献值流水
- `user_badges` — 用户徽章
- `push_jobs` — 推送任务
- `moderation_drafts` — 审核草稿
- `listing_moderation_notices` — 审核结果通知
- `hourly_active_users` — 时间桶聚合(Presence)

---

## 5. 已实现功能

1. **严格身份鉴权**:游客可浏览,但发起交易/聊天必须 `.edu` 邮箱注册
2. **商品发布双模交易**:一口价出售或按周期出租
3. **Transaction Dashboard**:卖家管理同一商品的所有报价,接受某 offer 时通过 RPC 原子化拒绝其他买家
4. **租赁订单状态机**:双方共同确认收货、租赁延期、归还请求、退还押金全链路
5. **内嵌实时聊天**:与订单绑定的私聊,实时接收消息
6. **全链路推送通知**:接入 OneSignal + Edge Function
7. **Universal Links**:`smivo.io/listing/xxx` 深度链接

---

## 6. 当前阶段开发(2026 Q2)

**目标**:多校架构基建 + Admin Web 完整后台 + 内容审核体系。

**核心交付**:
- 多校架构(详见 03)
- Admin Web 15 个页面(详见 04)
- 数据字典(详见 05)
- Presence 心跳 + Feature Flag(详见 06)
- App 端配套改造(详见 04 §10)

**已明确推迟的功能**:
- ⏸️ Plaza 校园广场(详见 08)
- ⏸️ 心愿单 / 漂流瓶
- ⏸️ 高级数据看板(留存漏斗、成交漏斗)
- ⏸️ 跨端类型生成基建
- ⏸️ 图片 AI 审核(NSFW 检测)

---

*文档版本:v2.0*
