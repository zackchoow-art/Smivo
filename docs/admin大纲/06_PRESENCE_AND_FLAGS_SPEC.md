# SMIVO Presence 与 Feature Flag 模块规范

> **文档定位**:Smivo 用户在线状态(Presence)模块与通用 Feature Flag 系统的工程方案。两者作为基础设施,服务于"卖家活跃度标签"、"数据看板基础数据"、"功能开关"等多个场景。
>
> **配套文档**:
> - `00_DOCUMENT_INDEX.md`(总目录)
> - `01_MASTER_BRIEF.md`(产品全景)
> - `03_MULTI_TENANT_ARCHITECTURE.md`(多校架构)
> - `04_ADMIN_WEB_SPEC.md`(主任务规划与各页面布局)
> - `07_OPERATIONS_QUERIES.md`(运营 SQL 查询手册)

---

## 1. 设计哲学与决策记录

### 1.1 当前阶段范围

| 项目 | 状态 | 说明 |
|---|---|---|
| ✅ 心跳打点基建 | 当前阶段实施 | 更新 `last_active_at` |
| ✅ 时间桶采集 | 当前阶段实施 | `hourly_active_users` 累积数据 |
| ✅ Listing/聊天等用户信息组件的"活跃度"标签 | 当前阶段实施 | 受 Feature Flag 控制 |
| ✅ Feature Flag 通用基建 | 当前阶段实施 | `system_settings` 表 + Admin 管理页 |
| ✅ Admin Web 基础数据看板 | 当前阶段实施 | DAU/HAU 曲线 + 关键指标(详见 04 §15) |
| ⏸️ 高级数据看板 | 暂缓 | 留存漏斗、成交漏斗等需要埋点 |
| ⏸️ Supabase Realtime Presence | 暂缓 | 当前心跳打点足够 |

### 1.2 关键决策记录

| 决策维度 | 选择 | 理由 |
|---|---|---|
| Presence 实现方案 | 心跳打点(轮询式) | 准实时(1~3 分钟延迟)对 Smivo 场景足够;成本最低;不依赖 WebSocket 长连接 |
| 时间桶聚合策略 | `hourly_active_users` 表 + UPSERT | 数据从 Day 1 开始默默采集,未来做看板时直接有历史 |
| DAU 看板优先级 | 不在当前阶段做 | 看板需要数据沉淀;SQL 直查已足够运营初期使用 |
| Presence 标签作用域 | 受全局 Feature Flag 控制 | 一键开关全站显示,不做用户级开关 |
| Feature Flag 抽象层级 | 通用 `system_settings` 表 | 不为 Presence 单独做,作为后续多场景基建 |

### 1.3 升级触发条件(预留)

| 升级项 | 触发条件 |
|---|---|
| 接入 Supabase Realtime Presence(秒级精度) | 用户反馈"绿点不准确"成为高频投诉 |
| `unique_users` 数组改为独立明细表 | 单小时活跃用户超过 1000(扩张到 10 校以上)|
| 启动 DAU/HAU 看板 UI | 数据看板模块整体启动时 |

---

## 2. Presence 模块

### 2.1 数据库设计

```sql
-- ===== 索引(应用现有 user_profiles.last_active_at)=====
CREATE INDEX IF NOT EXISTS idx_profiles_last_active 
  ON user_profiles(last_active_at DESC);

-- ===== 时间桶聚合表 =====
CREATE TABLE hourly_active_users (
  hour_bucket   timestamptz NOT NULL,           -- 整点对齐: 2026-04-29 14:00:00
  college_id    uuid,                            -- 一校一区预留(NULL=Smith)
  active_count  int NOT NULL DEFAULT 0,
  unique_users  uuid[] DEFAULT ARRAY[]::uuid[],
  PRIMARY KEY (hour_bucket, college_id)
);
CREATE INDEX idx_hau_bucket ON hourly_active_users(hour_bucket DESC);

-- ===== 心跳打点 RPC =====
CREATE OR REPLACE FUNCTION ping_user_presence()
RETURNS void AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_college_id uuid;
  v_hour timestamptz := date_trunc('hour', now());
BEGIN
  -- 1. 更新用户的最后活跃时间
  UPDATE user_profiles 
  SET last_active_at = now()
  WHERE id = v_user_id
  RETURNING college_id INTO v_college_id;
  
  -- 2. 更新时间桶(UPSERT,避免重复用户重复计数)
  INSERT INTO hourly_active_users (hour_bucket, college_id, active_count, unique_users)
  VALUES (v_hour, v_college_id, 1, ARRAY[v_user_id])
  ON CONFLICT (hour_bucket, college_id)
  DO UPDATE SET
    unique_users = CASE 
      WHEN v_user_id = ANY(hourly_active_users.unique_users) 
      THEN hourly_active_users.unique_users
      ELSE array_append(hourly_active_users.unique_users, v_user_id)
    END,
    active_count = CASE 
      WHEN v_user_id = ANY(hourly_active_users.unique_users)
      THEN hourly_active_users.active_count
      ELSE hourly_active_users.active_count + 1
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 2.2 App 端打点策略

**触发时机与节流**:

| 触发时机 | 间隔策略 |
|---|---|
| 进入 App / 切前台 | 立刻打点 |
| 任意页面切换 | 节流 60 秒一次 |
| 心跳后台保活 | 5 分钟一次(仅前台,后台不打) |
| 聊天界面打开期间 | 30 秒一次(精度提升,可选) |

### 2.3 Flutter 模块结构

```
app/lib/
├── core/
│   └── system_settings/                    # Feature Flag 基础模块
│       ├── system_settings_service.dart
│       ├── system_settings_provider.dart
│       └── flag_keys.dart                  # 常量枚举所有 flag key
│
├── features/
│   └── presence/                           # Presence 模块
│       ├── presence_service.dart
│       ├── presence_lifecycle_observer.dart # 监听 App 前后台
│       └── presence_router_observer.dart   # 监听路由切换
│
└── shared/
    ├── widgets/
    │   └── user/                           # 统一的用户信息组件
    │       ├── user_avatar.dart            # 纯头像
    │       ├── user_avatar_with_presence.dart
    │       ├── user_info_chip.dart         # 列表常用版本
    │       └── user_info_card.dart         # 详情页大卡片
    │
    └── utils/
        └── presence_formatter.dart         # 活跃度文本/颜色统一计算
```

### 2.4 PresenceService 实现要点

```dart
class PresenceService {
  Timer? _heartbeatTimer;
  DateTime? _lastPingedAt;
  
  void onAppResumed() {
    _ping();
    _startHeartbeat();
  }
  
  void onAppPaused() {
    _heartbeatTimer?.cancel();
  }
  
  void onRouteChanged() {
    if (_lastPingedAt == null || 
        DateTime.now().difference(_lastPingedAt!).inSeconds > 60) {
      _ping();
    }
  }
  
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(minutes: 5), (_) => _ping());
  }
  
  Future<void> _ping() async {
    try {
      await Supabase.instance.client.rpc('ping_user_presence');
      _lastPingedAt = DateTime.now();
    } catch (e) {
      // 静默失败,不影响 UX
    }
  }
}
```

**接入位置**:
- `WidgetsBindingObserver` 监听生命周期 → 调 `onAppResumed/Paused`
- GoRouter 的 `redirect` 或 `refreshListenable` → 调 `onRouteChanged`

### 2.5 活跃度判定

```dart
enum PresenceLevel { online, recent, today, week, away }

PresenceLevel getPresenceLevel(DateTime? lastActiveAt) {
  if (lastActiveAt == null) return PresenceLevel.away;
  final diff = DateTime.now().difference(lastActiveAt);
  if (diff.inMinutes < 5)   return PresenceLevel.online;   // 绿点 + "在线"
  if (diff.inMinutes < 60)  return PresenceLevel.recent;   // "刚刚活跃"
  if (diff.inHours < 24)    return PresenceLevel.today;    // "今日活跃"
  if (diff.inDays < 7)      return PresenceLevel.week;     // "X 天前活跃"
  return PresenceLevel.away;                               // 不显示
}

String formatPresence(PresenceLevel level, DateTime? lastActive) {
  switch (level) {
    case PresenceLevel.online:  return '在线';
    case PresenceLevel.recent:  return '刚刚活跃';
    case PresenceLevel.today:   return '今日活跃';
    case PresenceLevel.week:    return '${DateTime.now().difference(lastActive!).inDays} 天前活跃';
    case PresenceLevel.away:    return '';
  }
}

Color presenceColor(PresenceLevel level) {
  switch (level) {
    case PresenceLevel.online:  return Colors.green;
    case PresenceLevel.recent:  return Colors.lightGreen;
    case PresenceLevel.today:   return Colors.grey;
    case PresenceLevel.week:    return Colors.grey.shade400;
    case PresenceLevel.away:    return Colors.transparent;
  }
}
```

### 2.6 用户信息组件统一(关键工程实践)

**目标**:把活跃度标签的接入收口在 4 个组件,所有出现用户信息的地方都用这些组件,不在业务代码中重复处理活跃度逻辑。

**组件层级**:

```dart
// 1. UserAvatar - 纯头像(用于头部、设置页等不需要活跃度的场景)
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  // ...
}

// 2. UserAvatarWithPresence - 头像 + 绿点(用于聊天列表)
class UserAvatarWithPresence extends ConsumerWidget {
  final String? avatarUrl;
  final DateTime? lastActiveAt;
  final double size;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(systemSettingsProvider);
    final showPresence = settings.isEnabled('presence.enabled') 
                       && settings.isEnabled('presence.show_online_dot');
    final level = getPresenceLevel(lastActiveAt);
    
    return Stack(
      children: [
        UserAvatar(avatarUrl: avatarUrl, size: size),
        if (showPresence && level == PresenceLevel.online)
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              width: size * 0.3, height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// 3. UserInfoChip - 头像 + 名字 + 活跃度文字(列表常用)
// 4. UserInfoCard - 大卡片版本(详情页用)
```

**全局替换规则**:Phase 7 阶段,所有出现以下模式的代码都必须替换为统一组件:
- `CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl))` → `UserAvatar`
- 头像 + 名字组合 → `UserInfoChip`
- 详情页的卖家信息块 → `UserInfoCard`

### 2.7 显示位置(锁定)

> **决策**:在所有"显示用户信息的小组件"上显示活跃度,由全局 Feature Flag 统一控制。

具体位置:
- ✅ Listing 详情页 — 卖家信息卡(`UserInfoCard`)
- ✅ 聊天列表 — 每个对话头像(`UserAvatarWithPresence`)
- ✅ 聊天界面顶部 — 对方头像(`UserAvatarWithPresence`)
- ✅ 订单详情页 — 交易方信息(`UserInfoChip`)
- ✅ 用户主页(若实现)— 顶部信息块(`UserInfoCard`)
- ❌ Listing 卡片列表 — **不显示**(信息密度过高,影响浏览节奏)

---

## 3. Feature Flag 通用基建

### 3.1 数据库设计

```sql
CREATE TABLE system_settings (
  key           text PRIMARY KEY,                  -- 'presence.enabled'
  value         jsonb NOT NULL,                    -- {"enabled": true}
  description   text,                              -- 给 admin 看的说明
  updated_by    uuid REFERENCES user_profiles(id),
  updated_at    timestamptz DEFAULT now()
);

ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- 任何人可读(包括未登录,因为 App 启动时就需要拉取)
CREATE POLICY "anyone_read_settings" ON system_settings 
  FOR SELECT USING (true);

-- 仅 admin 可写
CREATE POLICY "admin_write_settings" ON system_settings 
  FOR ALL USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));

-- 初始化常用 Flag
INSERT INTO system_settings (key, value, description) VALUES
  ('presence.enabled',          '{"enabled": true}',  'Presence 活跃度标签全局显示开关'),
  ('presence.show_online_dot',  '{"enabled": true}',  '是否显示绿点(否=只显示文字)'),
  ('moderation.strict_mode',    '{"enabled": false}', '是否启用所有 Listing 强制事前审核(应急开关)'),
  ('registration.enabled',      '{"enabled": true}',  '是否开放新用户注册');
```

### 3.2 命名约定

`<domain>.<feature>` 双段式命名:
- `presence.enabled`,`presence.show_online_dot`
- `moderation.strict_mode`,`moderation.image_ai_check`
- `plaza.enabled`(Plaza 启动时使用)
- `registration.enabled`,`registration.invite_only`

**禁止**:用户级 flag(如 `user.123.beta`)。本系统是全局 flag,用户级走灰度发布机制(未来基建)。

### 3.3 App 端服务

```dart
// app/lib/core/system_settings/system_settings_service.dart
class SystemSettingsService {
  Map<String, dynamic> _cache = {};
  DateTime? _lastFetched;
  
  Future<void> refresh() async {
    final result = await Supabase.instance.client
      .from('system_settings').select();
    _cache = { for (var r in result) r['key']: r['value'] };
    _lastFetched = DateTime.now();
  }
  
  /// 1 小时自动刷新一次
  Future<void> ensureFresh() async {
    if (_lastFetched == null || 
        DateTime.now().difference(_lastFetched!).inMinutes > 60) {
      await refresh();
    }
  }
  
  bool isEnabled(String key) => _cache[key]?['enabled'] == true;
  T? get<T>(String key, String field) => _cache[key]?[field] as T?;
}

// app/lib/core/system_settings/flag_keys.dart
class FlagKeys {
  static const presenceEnabled = 'presence.enabled';
  static const presenceShowDot = 'presence.show_online_dot';
  static const moderationStrictMode = 'moderation.strict_mode';
  static const registrationEnabled = 'registration.enabled';
}
```

**初始化**:`main.dart` 启动时第一时间调 `SystemSettingsService().refresh()`,失败则使用本地 fallback(全部 enabled = true)。

### 3.4 Admin Web 管理页

**路由**:`/settings/feature-flags`

**UI 极简**:Toggle 列表
```
┌──────────────────────────────────────────────────────┐
│ Feature Flags                                         │
├──────────────────────────────────────────────────────┤
│ presence.enabled                              [ ON ]  │
│ Presence 活跃度标签全局显示开关                       │
│ 上次更新:Alice · 2 小时前                            │
├──────────────────────────────────────────────────────┤
│ presence.show_online_dot                      [ ON ]  │
│ 是否显示绿点(否=只显示文字)                         │
├──────────────────────────────────────────────────────┤
│ moderation.strict_mode                       [ OFF ]  │
│ 是否启用所有 Listing 强制事前审核(应急开关)         │
├──────────────────────────────────────────────────────┤
│ ...                                                   │
└──────────────────────────────────────────────────────┘
```

**Edge Function**:
- `GET /admin/system-settings` — 列出全部 flag(带 description 与 updated info)
- `PATCH /admin/system-settings/:key` — 修改 flag,自动写 audit log

### 3.5 生效延迟说明

| 场景 | 生效时长 |
|---|---|
| Admin 切换 flag | 立即生效(数据库已更新)|
| 已在线 App 用户感知 | **最多 1 小时**(本地缓存周期)|
| 强制实时推送变更 | 暂不实现(未来可通过 Realtime Channel)|

> **应急场景提醒**:`moderation.strict_mode` 这种应急开关,1 小时延迟可能不够。未来可加"强制刷新设置"的 Realtime 推送通道。当前阶段不实现。

---

## 4. 工时估算

| 任务 | 工时 |
|---|---|
| Presence DB + RPC + 时间桶 | 0.5 天 |
| App 端 PresenceService + 生命周期接入 | 1 天 |
| 统一的用户信息组件(`UserAvatar` 等)+ 全局替换 | 1.5 天 |
| `system_settings` 表 + RLS + 初始化 | 0.5 天 |
| App 端 `SystemSettingsService` | 0.5 天 |
| Admin Web Feature Flag 管理页 | 0.5 天 |
| 运营 SQL 手册编写(见 `OPERATIONS_QUERIES.md`) | 0.5 天 |
| 联调 + 测试 | 0.5 天 |
| **小计** | **5.5 天** |

对应 SPEC v1.1 中的 **Phase 8(Presence + Feature Flag App 端接入)** + **Phase 1 中的 Feature Flag 管理页**。

---

## 5. 已知风险与待办

| 风险 | 缓解策略 | 状态 |
|---|---|---|
| 心跳打点过于频繁,服务器写压力大 | 节流 60s + 后台不打 + 数据库索引优化 | 设计已规避 |
| Feature Flag 缓存延迟导致应急开关失效 | 当前接受 1 小时延迟;未来加 Realtime 强推 | 已记录 |
| `unique_users` 数组随用户量增长性能劣化 | 用户量 > 1000/小时时迁移到独立明细表 | 已记录触发条件 |
| 用户隐私顾虑("我不想被人看到在线") | 通过 Feature Flag 全局禁用;未来加用户级 opt-out | 设计已覆盖 |
| 时间桶数据无限累积 | 未来加 cron 归档(>90 天数据移到冷存储) | 已记录 |
| Presence 心跳 RPC 失败影响主流程 | App 端静默失败,不阻塞 UX | 设计已覆盖 |

---

## 6. 验收标准

- [ ] DB 迁移已部署:`hourly_active_users` 表存在,`ping_user_presence` RPC 可调用
- [ ] App 端启动 5 分钟后,自己的 `last_active_at` 已被更新
- [ ] App 切前台、切页面均触发打点(查日志或数据库可验证)
- [ ] Listing 详情页能看到卖家"今日活跃"等文字标签
- [ ] 聊天列表能看到在线对方的头像绿点
- [ ] 切换 `presence.enabled` 为 false,刷新 App 后所有活跃度标签消失
- [ ] Admin Web `/settings/feature-flags` 能看到所有 flag 并切换
- [ ] 任何 flag 切换都在 `admin_audit_logs` 留下记录
- [ ] SQL 手册中的查询能正常返回数据

---

*文档版本:v1.0 · 维护者:Smivo 项目主导*
*最后更新:2026-04-29*
