# 架构设计方案：心跳与时间桶（Heartbeat & Time Bucket）

## 1. 业务目标
实现 Smivo 平台的在线状态与活跃数据统计，包括：
1. **C端用户状态**：在用户主页、详情页、聊天列表中显示对方的在线/离线状态（绿点）。
2. **后台时段趋势图**：在管理后台查看每小时的用户在线人数走势折线图。
3. **后台活跃报表**：在管理后台统计 DAU（日活）和 MAU（月活）。

## 2. 核心挑战与解决思路
- 如果使用长连接（WebSocket/Supabase Presence），系统开销巨大且存在广播风暴风险。
- 如果用户每次操作都写入数据库，会导致数据库 `UPDATE` 锁死，拖垮 PostgreSQL。
- **解决方案**：采用“心跳防抖 + 数据库时序桶”的轻量化架构。

## 3. 数据库设计 (Supabase / PostgreSQL)

### 3.1 改造 `user_profiles` 表
增加 `last_active_at` (timestamptz) 字段，记录用户最后一次在线的精确时间。

### 3.2 新建 `hourly_active_users` 统计表
轻量级的时间桶表，用于生成后台折线图数据。
- 字段：`date_hour` (timestamptz) - 精确到小时的时间戳（如 `2024-05-01 14:00:00`）
- 字段：`user_id` (uuid) - 关联用户
- 主键：复合主键 `(date_hour, user_id)`

### 3.3 核心 RPC 函数 `ping_presence`
利用单个 SQL 事务高效完成两件事，极大降低数据库 IO：
```sql
CREATE OR REPLACE FUNCTION public.ping_presence()
RETURNS void AS $$
BEGIN
  -- 1. 更新用户的最后活跃时间
  UPDATE public.user_profiles 
  SET last_active_at = now() 
  WHERE id = auth.uid();

  -- 2. 写入本小时的时间桶（利用 ON CONFLICT 机制实现高性能去重）
  INSERT INTO public.hourly_active_users (date_hour, user_id)
  VALUES (date_trunc('hour', now()), auth.uid())
  ON CONFLICT (date_hour, user_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## 4. Flutter 端实现 (App)
- **心跳机制**：在应用全局作用域注入 `PresenceManager`（或复用现有的基础架构）。
- **防抖控制 (Debounce)**：设定逻辑，**每隔 5 分钟**最多向服务端发送一次心跳（调用 `ping_presence` RPC）。
- **状态展示 (C端 UI)**：UI 组件读取目标用户的 `user_profiles.last_active_at`，若与当前时间差小于 5 分钟，则判定为“在线”（亮绿点）；否则格式化显示为离线状态（如“X 分钟前活跃”）。

## 5. React 管理后台实现 (Admin Web)
- **日活 (DAU)**：基于 `user_profiles` 的 `last_active_at` 查询 24 小时内有活动的用户。
- **月活 (MAU)**：基于 `user_profiles` 的 `last_active_at` 查询 30 天内有活动的用户。
- **全天小时活跃趋势图**：
```sql
SELECT date_hour, count(user_id) as active_count 
FROM public.hourly_active_users 
WHERE date_hour >= (now() - interval '24 hours') 
GROUP BY date_hour 
ORDER BY date_hour;
```
（这条语句可以直接对接 React 图表库，完美渲染时段走势。）
