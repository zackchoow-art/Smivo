# 架构设计方案：Smivo Admin Control Center (管理后台)

## 1. 概览 (Overview)

Smivo 管理后台是一个独立部署在 `admin.smivo.io` 的 Web 应用程序，
基于 **React 19 + Vite 6 + TypeScript** 构建，与 Flutter 客户端共用同一个 Supabase 数据库。

**代码位置**：仓库根目录 `admin/`
**部署方式**：GitHub → Vercel（Root Directory = `admin/`）
**技术栈**：Vite 6 + React 19 + TypeScript + @supabase/supabase-js + React Router DOM v7

核心定位：**社区风控防火墙** · **业务增长监控引擎** · **平台全局配置中心**

> NOTE: Flutter 端 (`app/lib/features/admin/`) 中保留了一个轻量的 In-App Admin 面板，
> 供管理员在移动端执行紧急操作（如系统广播、测试数据清理）。
> Web Admin 是功能完整的管理控制台，覆盖所有管理模块。

## 2. 核心模块划分 (Modules)

### 2.1 📊 Dashboard（数据大盘与监控）
- **核心指标卡片**：今日 DAU、本月 MAU、当前在线人数、总商品数、累计交易额。
- **实时活动大屏**：通过"心跳与时间桶"拉取的实时活跃折线图，近期新注册用户滚动列表。
- **业务分布图**：商品品类占比饼图，各大校区用户分布占比。

### 2.2 👥 User Management（用户与权限管理）
- **用户列表**：按学校、状态（活跃/封禁）、注册时间检索。
- **用户画像 (User Profile)**：查看某个用户的历史发布、订单流水、被举报记录。
- **风控操作**：封禁/解封 (Ban/Suspend)，强制验证。
- **RBAC 权限分配**：分配管理员角色（超级管理员、风控审核员、内容运营）。

### 2.3 🛡️ Trust & Safety（风控与内容审核）
- **举报中心 (UGC Reports)**：统一处理用户发起的商品举报、聊天举报、用户违规举报。
- **商品库巡查**：全站商品图文流展示，支持一键强制下架 (Force Takedown)。
- **交易仲裁调解**：调阅异常订单的"交接凭证照片 (Evidence Photos)"及买卖双方的聊天记录进行人工仲裁。

### 2.4 🛍️ Transactions（交易流水大厅）
- **全站订单总览**：实时查询 Pending, Confirmed, Active, Completed 等所有状态订单。
- **租赁押金池监控**：追踪租赁订单的押金状态及退款记录。
- **超时告警**：高亮显示超期未归还、超期未确认收货的异常交易。

### 2.5 📢 Operations（运营与触达中心）
- **OneSignal 推送中心**：编写文案，圈选用户（如：仅向 Smith College 用户发送），执行全局 Push 推送。
- **FAQ 动态管理**：新增/编辑/删除帮助中心的 QA，App 端实时同步生效。
- **App 动态横幅 (Banners)**：管理首页轮播图或系统紧急公告横幅。

### 2.6 ⚙️ System Config（系统全局配置）
- **校区管理 (Campuses)**：配置新学校的名称及其对应的 `.edu` 邮箱后缀校验规则。
- **分类管理 (Categories)**：动态增删商品类目。
- **全局系统开关**：App 维护模式、强制升级提醒等。

## 3. 认证与权限 (Auth & RBAC)

### 数据库表
- `admin_roles` 表：user_id, role, scope_type, scope_id, is_active
- 角色类型：`sysadmin`（全局管理员）、`moderator`（内容审核员）、`operator`（运营）

### 权限检查
- `is_platform_sysadmin()` — SECURITY DEFINER 函数，绕过 RLS 检查用户是否为全局管理员
- Admin 端可使用 Service Role Key 执行需要绕过 RLS 的操作（存储在 admin/.env）
- 所有敏感操作通过 SECURITY DEFINER RPC 函数执行（如 `admin_clear_test_data`）

## 4. 前端架构 (admin/src/)

```
admin/src/
├── components/         # 可复用 UI 组件（表格、卡片、图表等）
├── features/           # 按功能模块组织
│   ├── dashboard/      # 数据大盘
│   ├── users/          # 用户管理
│   ├── moderation/     # 内容审核
│   ├── transactions/   # 交易管理
│   ├── operations/     # 运营中心
│   └── config/         # 系统配置
├── hooks/              # 自定义 React Hooks
├── lib/                # Supabase 客户端、工具函数、常量
│   ├── supabase.ts     # Supabase 客户端单例
│   └── api/            # 数据库查询封装
├── pages/              # 路由级页面组件
└── types/              # TypeScript 类型定义（镜像数据库 Schema）
```

## 5. 实施阶段计划 (Roadmap)

- **Phase 1** ✅ 架构搭建：Monorepo 重组完成，Vite + React + TS 项目已初始化
- **Phase 2**：完成 Admin 登录鉴权 + Dashboard 数据统计面板 + 用户风控（封禁）
- **Phase 3**：UGC 举报审核流 + 商品强制下架 + 风控闭环
- **Phase 4**：OneSignal 推送面板 + 全局配置（学校、分类管理）
- **Phase 5**：订单深度调阅 + 聊天记录仲裁功能
