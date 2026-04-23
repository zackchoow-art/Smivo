Smivo 项目会话归档

项目概述
Smivo：校园二手交易平台（Smith College 试点，多校架构已搭好）

学生用 .edu 邮箱注册，可买卖或出租物品
线下面交（Neilson Library、Campus Center 等固定 pickup 点）
Bundle ID: com.smivo
GitHub: https://github.com/zackchoow-art/Smivo（main 分支）
用户基地：Rancho Santa Margarita, CA，面向 Smith College


技术栈

前端：Flutter + Dart、Riverpod（@riverpod 代码生成）、GoRouter、freezed
后端：Supabase（PostgreSQL + Auth + Storage + Realtime）
开发环境：Google Antigravity IDE
当前使用模型：Gemini 3 Flash（Sonnet/Opus 配额用完，约 5 天后恢复）
工作方式：Claude 远程指挥 Flash，代码审查 + 任务规划


数据库结构（完整）
核心业务表

user_profiles — 用户资料（1:1 with auth.users）

id, email, display_name, avatar_url, school_id, is_verified, created_at, updated_at


schools — 学校（多校架构）

id, slug, name, email_domain, primary_color, logo_url, is_active
当前有：smith（Smith College, smith.edu, active）+ smivo-dev（调试用）


pickup_locations — 取货点

id, school_id, name, display_order, is_active
Smith 当前有 8 个：Neilson Library, Campus Center, Chapin Lawn, Northrop Hall Lobby, Davis Center, Wright Hall, Ford Hall, Other


listings — 商品

id, seller_id, school_id, title, description, category
price (销售用，租赁设为 0)
rental_daily_price, rental_weekly_price, rental_monthly_price
deposit_amount（新加的，租赁押金）
condition（新加的，'new'|'like_new'|'good'|'fair'|'poor'，默认 'good'）
transaction_type (sale|rental)
status (active|inactive|reserved|sold|rented) — reserved 是新加的
pickup_location_id, allow_pickup_change
view_count, save_count, inquiry_count
is_pinned, pinned_days


listing_images — 商品图片

id, listing_id, image_url, sort_order, created_at, updated_at
注意：此模型之前缺失了 @JsonKey，已修复


orders — 订单

id, listing_id, buyer_id, seller_id, school
order_type (sale|rental)
status (pending|confirmed|completed|cancelled)
total_price, deposit_amount（新加）
rental_start_date, rental_end_date, return_confirmed_at
delivery_confirmed_by_buyer, delivery_confirmed_by_seller


chat_rooms — 聊天会话

id, listing_id, buyer_id, seller_id
unread_count_buyer, unread_count_seller, last_message_at


messages — 聊天消息

id, chat_room_id, sender_id, content, message_type (text|image|system), image_url, is_read


saved_listings — 收藏

id, user_id, listing_id


notifications — 系统通知

id, user_id, type, title, body, is_read, related_order_id



存储桶 (Supabase Storage)

listing-images（public）

路径结构：{user_id}/{listing_id}/{uuid}.jpg
RLS：路径第一段必须是 auth.uid()


avatars（public）
chat-images —— 未建（以后 Sonnet 回来时做）

Realtime Publication
已加入 supabase_realtime：

messages
notifications
orders
listings（最后加的）


已执行的 Migrations
00001_initial_schema.sql          ✅ 全部表 + RLS + 初始触发器
00002_auth_enforcement.sql        ✅ handle_new_user（后来被 00012 重写）
00003_debug_backdoor.sql          ✅ test1/2/3@smivo.dev 白名单
00004_remove_debug_backdoor.sql   ⏳ 已准备好但还没跑（上线前跑）
00005_chat_auto_updates.sql       ✅ 消息插入时自动维护 chat_rooms
00006_order_listing_status_sync   ✅ 被 00014 替换
00007_chat_images_bucket.sql      ❌ 还没创建文件
00008_notifications.sql           ✅ 通知表 + 订单状态触发器
00009_orders_realtime.sql         ✅ orders 加入 realtime
00010_schools_and_pickup_locations ✅ schools + pickup_locations
00011_listings_school_pickup.sql  ✅ listings 加 school_id, pickup_location_id
00012_user_profiles_school.sql    ✅ user_profiles 加 school_id + 重写 handle_new_user
00013_drop_duplicate_pickup_flag  ✅ 删除重复字段 allow_buyer_suggest_pickup
00014_listing_reserved_status.sql ✅ 加 'reserved' 状态 + 新触发器
00015_listings_condition.sql      ✅ condition 字段
00016_listings_realtime.sql       ✅ listings 加入 realtime
00017_rental_deposit.sql          ✅ listings + orders 加 deposit_amount

业务逻辑关键规则（已实现）
订单状态机（销售）
pending (下单等接单)
  → [卖家 Accept] → confirmed (listing 变 reserved，首页消失)
  → [任何一方 Cancel] → cancelled (listing 恢复 active)
  
confirmed (等线下交易)
  → [买家 Confirm Pickup] → completed (单边确认，listing 变 sold)
  → [任何一方 Cancel] → cancelled
订单状态机（租赁）

保持双方确认逻辑（暂未改）
完整租赁流程（active_rental、归还确认、押金退回）在 Phase 3 backlog

Pickup Location

卖家发布时选 pickup location
卖家可勾选 allow_pickup_change，允许买家建议别的地点
数据从数据库加载（myPickupLocationsProvider）

租赁定价规则（刚实现）

3 个费率（日/周/月）+ 押金
复选框控制启用（默认勾选 Daily）
未勾选的输入框禁用 + 显示 "—"
勾选的必须 > 0
押金可以为 0（默认空，提交视为 0）
listing.price 租赁时 = 0，订单 total_price 下单时计算

租赁下单计算（未做）

买家下单时选择：日/周/月 + 数量
计算 total_price = 单价 × 数量
存入 order


已完成的重要功能
✅ 完整 MVP 功能链

Auth：登录、邮箱验证、调试后门（test1/2/3@smivo.dev）
发布商品：表单 + 图片上传（Web 兼容，XFile）+ condition + pickup
浏览：首页列表 + 商品详情（实时 Realtime 刷新）
聊天：完整实现（chat_popup + ChatRoomScreen + 未读徽章）
订单：创建、接单、取消、完成（销售流程单边确认）
通知：数据库触发器自动生成 + 首页徽章

✅ 修复的重要 Bug

'rent' vs 'rental' 不一致 → 统一 'rental'
Storage RLS 路径要求 userId → 修复
Listing 模型 allow_pickup_change / allow_buyer_suggest_pickup 重复字段 → 删除后者
ListingImage 模型缺失 @JsonKey → 补上
SavedListing 模型缺失 @JsonKey → 补上
数据库 JSON 空值反序列化（Freezed required String 收到 null）→ 修复
首页不实时刷新 → 加 Realtime 订阅
订单列表不实时刷新 → 加 Realtime 订阅
聊天室看消息不自动 markAsRead → 加 ref.listen


关键文件路径
前端

lib/data/models/ — 所有 freezed 模型
lib/data/repositories/ — 与 Supabase 交互的 Repository
lib/features/ — 按业务模块分的功能

auth/, listing/, chat/, orders/, home/, notifications/, profile/, settings/, shared/


lib/core/ — 共用基础设施

router/ (GoRouter + AppRoutes)
theme/ (AppColors, AppSpacing, AppTextStyles)
providers/ (supabase_provider)
exceptions/, constants/, utils/


lib/shared/widgets/ — 共用 UI (AppShell, MessageBadgeIcon 等)
web/index.html — Web 入口（已加 Cropper.js CDN）

配置

.env — Supabase URL 和 anon key（不在 Git）
.env.example — 模板
supabase/migrations/ — 所有 SQL
.agent/scratchpad/ — 重要决策和设计文档

theme-refactor-plan.md
pre-launch-checklist.md
listings-integration-analysis.md / chat-integration-analysis.md / orders-integration-analysis.md
order-flow-backlog.md（Phase 2 和 Phase 3）




重要的决策和约定

语言：英文为主（用户是 Smith College 学生），开发者说中文但 App 内容英文
代码风格：

每个文件顶部 // ignore_for_file: invalid_annotation_target
所有 Supabase 返回数据必须有 @JsonKey snake_case 映射
freezed + json_serializable，必跑 build_runner


模型设计：

所有表都有 created_at / updated_at（已有 handle_updated_at 触发器）
嵌套 join 字段（如 seller, images, pickupLocation）一律 nullable + @Default([])
insert 时要 .remove('id'), .remove('created_at'), .remove('updated_at') 让 DB 生成


Realtime 订阅模式：provider 用 class 而非 function，build() 里 subscribe，onDispose 清理
图片格式：用 XFile（跨平台），不用 dart:io.File
调试后门：kDebugBackdoorEnabled = true，上线前改 false
提交按钮 UX：发布商品页永远可点，提交时校验并用红色边框标错（其他表单保持禁用惯例）


未完成任务
当前正在做（下一步从这里继续）
批次 4 - UI 显示修复（做到一半）：

✅ 4.1 主页卡片租金显示（day/week/month 优先级）
✅ 4.2 商品详情页租赁选项（真实数据 + 条件显示）
⏳ 4.3 订单详情页（下一步）：

租赁订单的 3 个按钮（日/周/月）按 > 0 条件显示
显示真实押金金额



批次 5 - 下单时计算租赁总价（未做）：

买家下单租赁商品时，UI 提供"选择租赁方式 + 填数量"
OrderActions.createOrder 实时计算 total_price

挂起的任务列表
用户明确提过但未做：

商品详情页的自己商品显示模式（需求 2a+2b）

如果是 currentUserId == listing.sellerId：

隐藏卖家信息卡片
隐藏 Place Order 按钮
显示热度数据：view_count, save_count, inquiry_count（不做分享）


点击列表头像可发消息（2c - 以后做）
下架商品按钮（2d）


Condition 字段的 UI（Task 2.1 的 UI 部分）

发布表单加 condition 选择器
商品卡片/详情页显示真实 condition（替代 "Like new" 硬编码）
注意：之前有 Flash 越界了要加这个，被拦下来了


图片裁剪功能（当前绕过了）

image_cropper 12.x 的 Web 配置有布局问题
目前上传不裁剪，直接用原图
解决方案待探索（可能用 image_cropper 别的版本或换包）


订单卡片 Pickup 显示

当前显示的是学校名（order.school）
需要改为真实 pickup location 名
可能需要 orders 表加 pickup_location_id 快照字段


注册页面 UI（上线前必做，用户之前跳过了）
主题系统重构（等 Sonnet 回来做）

大量硬编码颜色（0xFF2B2A51, 0xFF013DFD 等）
大量硬编码圆角（16, 20, 24 等）
目标：A/B 双主题 + Settings 切换 + SharedPreferences 持久化
Design 2 "Democratic Architect"（IKEA 配色：深蓝 #004181 + 黄 #fdd816）


withOpacity 弃用警告（约 18 处）

改为 withValues(alpha:)
低优先级，暂不影响运行



Phase 2 backlog（见 order-flow-backlog.md）

多买家竞争 + 重新发布
被抢单通知
卖家视角的 pending 订单管理

Phase 3 backlog

完整租赁流程（active_rental 状态、归还确认、押金退回）

上线前必做

运行 00004_remove_debug_backdoor.sql
设置 kDebugBackdoorEnabled = false
注册页面 UI
删除 test1/2/3@smivo.dev 账号
修复图片裁剪（或确认不做裁剪）
Condition 字段的 UI 绑定
自己商品的详情页逻辑
主题系统（视情况）


工作流约定（和 Claude）
任务执行模式（重要）

用户先描述需求
Claude 分析后给 Flash 完整指令（包含准确代码）
用户复制指令给 Flash
Flash 改完后用户直接测试（不经 Claude 审查，除非用户选 plan A）
测试失败时贴现象给 Claude 诊断

给 Flash 的指令风格

包含完整代码片段，少让 Flash 自己判断
明确列出"只改哪些文件"和"不改哪些文件"
指令末尾要求 flutter analyze + "Report errors only"
跨平台 issue 多发生在 Web，要特别提醒

调试方法

终端看不到 Dart 错误时：加 debugPrint 打印完整 stackTrace
Supabase 错误：直接在 SQL Editor 验证数据
数据不一致：先查 DB schema vs 模型 vs UI 是否 3 层对齐

已踩过的坑

Flash 经常越界，做计划外的事 → 要明确约束
Freezed 不自动转 snake_case → 必须显式 @JsonKey
Supabase join 一对多返回数组 → 模型用 List 即可
Web 不支持 dart:io.File → 用 XFile
Storage RLS 严格 → 路径必须对
indexedStack 不销毁 → autoDispose 失效，需要 Realtime
update column check constraint 要用 drop constraint + add constraint 组合


测试账号

test1@smivo.dev
test2@smivo.dev
登录页有调试开关（kDebugBackdoorEnabled = true 时显示）
切换到调试模式可输入完整 email


下一次会话开场建议
复制这份文档到新会话开头，然后告诉 Claude：

刚和你继续 Smivo 项目。读完归档文档后，当前任务是批次 4 的 4.3 —— 订单详情页租赁相关 UI 修复：

租赁订单 3 个按钮（日/周/月）按 rental_*_price > 0 条件显示
显示真实 depositAmount

给我 Flash 指令。