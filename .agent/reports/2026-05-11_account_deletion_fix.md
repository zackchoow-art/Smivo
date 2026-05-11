# 执行报告：优雅账户删除 — 完整方案

**日期**：2026-05-11  
**执行者**：Antigravity (架构级)  
**状态**：数据库完成 + App 模型完成，UI 适配待执行

---

## 一、方案决策

### 用户需求

| # | 需求 | 实现方式 |
|---|------|----------|
| 1 | 已删除用户的商品自动下架 | RPC 中 UPDATE listings SET status = 'inactive' |
| 2 | pending 交易取消 | RPC 中 UPDATE orders SET status = 'cancelled' |
| 3 | 租期内交易取消 | RPC 中 UPDATE orders WHERE rental_status IN ('active', 'return_requested', 'returned') |
| 4 | 聊天会话发送告别消息 | RPC 中 INSERT INTO messages (system 类型) |
| 5 | 新消息提示无法送达 | App 端检查 partner.deletedAt != null → 禁用输入 |
| 6 | 已完成历史订单保留 | 软删除策略 — 不删除 user_profiles |
| 7 | 所有设备强制登出 | RPC 中 DELETE FROM auth.sessions + auth.refresh_tokens |

### 关键架构决策：软删除 vs 硬删除

**选择了软删除 + 匿名化**，原因如下：

```
问题：user_profiles.id → auth.users.id ON DELETE CASCADE
      orders.buyer_id / seller_id → user_profiles ON DELETE CASCADE

如果硬删除 auth.users → 级联删除 user_profiles → 级联删除所有 orders

要保留完成的订单，需要：
  方案 A：改 FK 为 SET NULL → buyer_id, seller_id 变为可空
           影响：Order 模型、所有查询、所有 UI、RLS 策略 — 工程量极大
  
  方案 B：软删除 — 保留 user_profiles + auth.users 行，匿名化 PII
           影响：仅需添加 deleted_at 字段 — 工程量极小
```

**方案 B 的优势**：
- 所有 FK 关系自然保持，零模型变更
- Order、ChatRoom、Message 的查询和 RLS 全部不受影响
- 其他用户看到的 display_name 自动变为 "Deleted User"
- Auth 账户通过 banned_until 禁用，原始邮箱释放可重新注册

### 关于迁移 00139 的说明

`00139` 将 `orders.listing_id` 改为 `NULLABLE + SET NULL`，这在软删除模式下**不再是必需的**（因为 listings 只是 delisted 而不是 deleted）。但保留这个改动是安全的，作为防御性设计——如果将来某个管理员或清理任务真的删除了 listing，orders 不会因此被阻塞。

`ACCT-001` 指令文件中的 "Order 模型 listingId 改为可空" 任务**可以推迟**——因为在软删除模式下，listing_id 不会变为 null。但长期来看仍建议执行。

---

## 二、已执行的变更

### 数据库迁移 00140 + 00141: 优雅账户删除

**RPC `delete_own_account()` 完整逻辑**：

```
A. UPDATE listings SET status = 'inactive'     — 下架所有商品
B. UPDATE orders SET status = 'cancelled'       — 取消 pending/confirmed
C. UPDATE orders SET rental_status = NULL       — 取消活跃租期
D. INSERT INTO messages (系统消息)               — 告别消息
E. DELETE FROM saved_listings, notifications...  — 清理非核心隐私数据
F. UPDATE user_profiles SET deleted_at = now()   — 匿名化 PII
G. UPDATE auth.users SET banned_until = 9999     — 禁用账户 + 释放邮箱
H. DELETE FROM auth.sessions + refresh_tokens   — 强制所有设备登出
```

**user_profiles 新增列**：
```sql
deleted_at timestamptz  — 软删除时间戳
```

### App 端模型变更

**UserProfile** (`user_profile.dart`):
```dart
@JsonKey(name: 'deleted_at') DateTime? deletedAt,  // 新增
```

**AuthRepository** (`auth_repository.dart`):
- 更新 doc comment 反映软删除行为
- 调用逻辑不变：`rpc('delete_own_account')` → `signOut()`

### 代码生成
- `dart run build_runner build` ✅
- `flutter analyze` ✅ 0 error

---

## 三、待执行的 App 端 UI 适配

**指令文件**：`.agent/instructions/ACCT-002-DELETED-USER-UI.md`

| 任务 | 文件 | 复杂度 |
|------|------|--------|
| 系统消息居中样式 | chat_room_screen.dart | 低 |
| 已删除用户禁用输入 | chat_room_screen.dart, chat_popup.dart | 中 |
| 头像无在线状态 | smivo_user_avatar.dart | 低 |
| 订单详情隐藏消息按钮 | sale_/rental_order_detail_screen.dart | 低 |
| 删除确认文案更新 | edit_profile_screen.dart | 低 |
| 删除失败错误反馈 | edit_profile_screen.dart | 低 |

**推荐执行者**：Gemini Flash（模式清晰，逻辑简单）

**提示词**：
```
请阅读并执行 .agent/instructions/ACCT-002-DELETED-USER-UI.md 中的所有任务。
这是 Flutter app 的 UI 适配任务：用户删除账户后，
其 Profile 仍保留但 deletedAt 不为空，需要在聊天、订单等页面适配显示。
执行完成后将报告保存到 .agent/reports/ACCT-002-execution-report.md
```

---

## 四、RPC 执行流水账（对账用）

当用户 A 删除账户时：

```
1. A 的所有 active/reserved listings → inactive
2. A 参与的 pending/confirmed orders → cancelled (cancelled_by = A)
3. A 参与的 active rental orders → cancelled (rental_status = null)
4. A 参与的每个 chat_room → 收到系统告别消息
5. A 的 saved_listings, notifications, sessions, blocks, bans → 删除
6. A 的 user_profiles → anonymized (display_name='Deleted User', email=scrambled)
7. A 的 auth.users → banned + email scrambled
8. A 的 auth.sessions + refresh_tokens → 全部删除（强制登出）

结果：
- A 无法登录（banned_until = 9999）
- A 在其他设备上立即被登出（session 销毁 → JWT 刷新失败 → 401）
- A 的原始邮箱可重新注册
- A 参与的已完成订单保留（counterparty 可见 "Deleted User"）
- A 的聊天会话保留（对方看到告别消息）
- A 的 listings 保留但 inactive（不出现在首页）
```

---

## 五、相关文件索引

| 文件 | 变更类型 | 迁移 |
|------|----------|------|
| `supabase/migrations/00139_fix_delete_own_account.sql` | 已执行 | listing_id SET NULL |
| `supabase/migrations/00140_graceful_account_deletion.sql` | 已执行 | 软删除 RPC |
| `supabase/migrations/00141_force_logout_on_deletion.sql` | 已执行 | 强制登出所有设备 |
| `app/lib/data/models/user_profile.dart` | 已修改 | +deletedAt |
| `app/lib/data/repositories/auth_repository.dart` | 已修改 | doc 更新 |
| `.agent/instructions/ACCT-001-NULLABLE-LISTING-ID.md` | 可推迟 | listing_id 可空适配 |
| `.agent/instructions/ACCT-002-DELETED-USER-UI.md` | **待执行** | UI 适配 |
