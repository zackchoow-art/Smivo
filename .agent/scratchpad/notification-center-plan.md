# 通知中心页面设计方案 (Notification Center)

日期：2026-04-23
状态：已确认，待实施

---

## 1. 背景与现状

### 已有基础设施
- ✅ `notifications` 表（type, title, body, is_read, related_order_id）
- ✅ 6 种通知类型的 DB 触发器（order_placed, accepted, cancelled, delivered, completed, system）
- ✅ Realtime 订阅（新通知实时推送到客户端）
- ✅ Provider 层完整（`NotificationList` + `totalUnreadNotifications`）
- ✅ 主页 `HomeHeader` 已显示未读数 badge
- ✅ 底部导航栏 Chat Tab 已有未读消息数量 badge

### 缺少的部分
- ❌ 通知中心 UI 页面
- ❌ 主页消息图标 → 当前跳转聊天列表，应改为跳转通知中心
- ❌ 通知列表项组件
- ❌ 通知点击后的导航逻辑

---

## 2. 关键决策

### 主页右上角图标
- **仅用于系统通知**，改为铃铛图标 🔔
- 用户聊天消息已由底部导航栏 Chat Tab 的 badge 覆盖
- 点击 🔔 → 跳转通知中心页面

### 通知点击行为分类
| 行为类型 | 说明 | 数据字段 |
|---------|------|---------|
| **跳转订单详情** | 订单相关通知，点击跳转到 `orderDetail` | `related_order_id` |
| **仅标记已读** | 无更多内容的系统消息，点击即变灰 | `action_type = 'none'` |
| **打开链接** | 未来广告/推广类消息，点击打开外部链接 | `action_type = 'url'`, `action_url` |
| **跳转 App 页面** | 功能推送（如"快来看新功能"），跳转到指定页面 | `action_type = 'route'`, `action_url` |

---

## 3. 页面设计

### 页面结构

```
┌────────────────────────────────────────┐
│  ←  Notifications        Mark All Read │
├────────────────────────────────────────┤
│  🔵 📦 New order received              │ → 跳转 orderDetail
│     Someone placed an order for        │
│     "IKEA Desk"                        │
│     2 min ago                          │
├────────────────────────────────────────┤
│  🔵 ✅ Order accepted                   │ → 跳转 orderDetail
│     The seller accepted your order     │
│     for "MacBook Pro"                  │
│     1 hour ago                         │
├────────────────────────────────────────┤
│  ⚪ 📢 Welcome to Smivo!               │ → 点击标记已读
│     Start browsing campus deals.       │
│     2 days ago                         │
├────────────────────────────────────────┤
│  ⚪ 🎉 Order completed                  │   已读状态
│     Your order for "Yoga Mat" is done  │
│     3 days ago                         │
└────────────────────────────────────────┘
```

### 列表项设计
- **未读指示器**：左侧蓝色圆点（未读）/ 灰色空心（已读）
- **类型图标**：根据 notification type 显示对应 Material Icon
- **标题**：加粗，一行显示
- **正文**：灰色次要文字，最多两行
- **时间**：相对时间（"2 min ago" / "1 hour ago" / "Apr 20"）
- **可跳转标识**：右侧小箭头 `>`（仅有跳转目标的通知显示）

### 空状态
- 居中铃铛图标 + "No notifications yet" 文案

---

## 4. 通知类型映射

| type | 图标 | 颜色 | 点击行为 |
|------|------|------|---------|
| `order_placed` | `Icons.shopping_bag_outlined` | Primary Blue | → orderDetail |
| `order_accepted` | `Icons.check_circle_outline` | Green | → orderDetail |
| `order_cancelled` | `Icons.cancel_outlined` | Red | → orderDetail |
| `order_delivered` | `Icons.local_shipping_outlined` | Orange | → orderDetail |
| `order_completed` | `Icons.celebration_outlined` | Gold | → orderDetail |
| `system` | `Icons.campaign_outlined` | Grey | 按 action_type 决定 |

---

## 5. DB Schema 扩展

为支持未来的链接/路由跳转，需要给 `notifications` 表加两个字段：

```sql
ALTER TABLE public.notifications
  ADD COLUMN action_type text NOT NULL DEFAULT 'none'
    CHECK (action_type IN ('none', 'order', 'url', 'route')),
  ADD COLUMN action_url  text;
```

- `action_type = 'none'`：点击仅标记已读
- `action_type = 'order'`：跳转到 `related_order_id` 对应的订单详情
- `action_type = 'url'`：打开 `action_url` 指定的外部链接
- `action_type = 'route'`：跳转 `action_url` 指定的 app 内路由

现有的订单触发器自动插入的通知需要同步设置 `action_type = 'order'`。

---

## 6. 改动清单

| # | 类型 | 文件 | 说明 |
|---|------|------|------|
| 1 | DB | `supabase/migrations/00022_notification_action_type.sql` | 新增 action_type + action_url 列，更新触发器 |
| 2 | Model | `lib/data/models/notification.dart` | 新增 actionType + actionUrl 字段 |
| 3 | Route | `lib/core/router/app_routes.dart` | 新增 `notificationCenter` 路由 |
| 4 | Route | `lib/core/router/router.dart` | 注册通知中心路由 |
| 5 | Screen | `lib/features/notifications/screens/notification_center_screen.dart` | 通知中心页面 |
| 6 | Widget | `lib/features/notifications/widgets/notification_list_item.dart` | 通知列表项组件 |
| 7 | Modify | `lib/features/home/widgets/home_header.dart` | 图标改为铃铛 🔔，跳转通知中心 |
| 8 | Modify | `lib/shared/widgets/message_badge_icon.dart` | 改为 NotificationBadgeIcon（铃铛样式） |
| 9 | Build | 运行 `dart run build_runner build` | 生成 freezed 代码 |

---

## 7. 不在此次范围

- [ ] 推送通知（OneSignal 集成）— Phase 2+
- [ ] 通知分组/折叠（同一订单的多条通知合并显示）
- [ ] 通知删除（左滑删除）
- [ ] 广告类通知的内容管理后台

---

## 8. 依赖关系

- 无前置依赖，可独立实施
- 建议在 Bug #20 修复完成后执行
- Task 编号：021
