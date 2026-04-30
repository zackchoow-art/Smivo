# SMIVO 运营 SQL 查询手册

> **文档定位**:供项目主导者 / 运营人员日常在 Supabase 控制台直接执行的 SQL 查询合集。在 Admin Web 数据看板之外,也可作为深度查询工具。
>
> **使用方法**:在 Supabase 控制台 → SQL Editor 中粘贴执行。
>
> **配套文档**:
> - `00_DOCUMENT_INDEX.md`(总目录)
> - `06_PRESENCE_AND_FLAGS_SPEC.md`(数据来源)

---

## 0. 使用须知

- 所有查询基于 `user_profiles.last_active_at` 与 `hourly_active_users` 时间桶
- 时间字段统一为 UTC,如需本地时区(US Eastern Time)请用 `AT TIME ZONE 'America/New_York'`
- 涉及 `college_id` 的查询当前默认 Smith(NULL),未来扩展时按需筛选

---

## 1. DAU(Daily Active Users)系列

### 1.1 今日 DAU

```sql
SELECT COUNT(DISTINCT id) AS today_dau
FROM user_profiles 
WHERE last_active_at::date = CURRENT_DATE;
```

### 1.2 昨日 DAU

```sql
SELECT COUNT(DISTINCT id) AS yesterday_dau
FROM user_profiles 
WHERE last_active_at::date = CURRENT_DATE - INTERVAL '1 day';
```

### 1.3 近 7 日 DAU 趋势

```sql
SELECT 
  date_trunc('day', last_active_at)::date AS day, 
  COUNT(DISTINCT id) AS dau
FROM user_profiles 
WHERE last_active_at > now() - interval '7 days'
GROUP BY day 
ORDER BY day;
```

### 1.4 近 30 日 DAU 趋势

```sql
SELECT 
  date_trunc('day', last_active_at)::date AS day, 
  COUNT(DISTINCT id) AS dau
FROM user_profiles 
WHERE last_active_at > now() - interval '30 days'
GROUP BY day 
ORDER BY day;
```

### 1.5 周环比对比

```sql
WITH daily AS (
  SELECT 
    date_trunc('day', last_active_at)::date AS day, 
    COUNT(DISTINCT id) AS dau
  FROM user_profiles 
  WHERE last_active_at > now() - interval '14 days'
  GROUP BY day
)
SELECT 
  day,
  dau,
  LAG(dau, 7) OVER (ORDER BY day) AS dau_last_week,
  ROUND(100.0 * (dau - LAG(dau, 7) OVER (ORDER BY day)) / NULLIF(LAG(dau, 7) OVER (ORDER BY day), 0), 1) AS wow_pct
FROM daily
ORDER BY day DESC
LIMIT 7;
```

---

## 2. HAU(Hourly Active Users)系列

### 2.1 当前在线人数(过去 5 分钟活跃)

```sql
SELECT COUNT(*) AS online_now
FROM user_profiles 
WHERE last_active_at > now() - interval '5 minutes';
```

### 2.2 近 24 小时 HAU 曲线

```sql
SELECT 
  hour_bucket AT TIME ZONE 'America/New_York' AS hour_local,
  active_count
FROM hourly_active_users 
WHERE hour_bucket > now() - interval '24 hours'
ORDER BY hour_bucket;
```

### 2.3 一周内每天的"小时活跃峰值"

```sql
SELECT 
  hour_bucket::date AS day,
  MAX(active_count) AS peak_hau,
  (ARRAY_AGG(hour_bucket ORDER BY active_count DESC))[1] AT TIME ZONE 'America/New_York' AS peak_hour_local
FROM hourly_active_users 
WHERE hour_bucket > now() - interval '7 days'
GROUP BY day
ORDER BY day;
```

### 2.4 一周内"用户最活跃的小时段"分布

> 用于判断校园用户的活跃时段,辅助推送时机决策。

```sql
SELECT 
  EXTRACT(HOUR FROM hour_bucket AT TIME ZONE 'America/New_York') AS hour_of_day,
  ROUND(AVG(active_count), 1) AS avg_active
FROM hourly_active_users 
WHERE hour_bucket > now() - interval '7 days'
GROUP BY hour_of_day
ORDER BY hour_of_day;
```

---

## 3. 留存(Retention)系列

### 3.1 注册次日留存

```sql
WITH new_users AS (
  SELECT id, created_at::date AS register_date
  FROM user_profiles
  WHERE created_at > now() - interval '30 days'
)
SELECT 
  register_date,
  COUNT(*) AS new_count,
  COUNT(*) FILTER (
    WHERE EXISTS (
      SELECT 1 FROM user_profiles up 
      WHERE up.id = nu.id 
        AND up.last_active_at::date = nu.register_date + INTERVAL '1 day'
    )
  ) AS d1_retained,
  ROUND(100.0 * COUNT(*) FILTER (
    WHERE EXISTS (
      SELECT 1 FROM user_profiles up 
      WHERE up.id = nu.id 
        AND up.last_active_at::date = nu.register_date + INTERVAL '1 day'
    )
  ) / NULLIF(COUNT(*), 0), 1) AS d1_retention_pct
FROM new_users nu
GROUP BY register_date
ORDER BY register_date DESC;
```

> **注**:此查询近似性较强(只看是否在注册次日有活跃记录,不区分时段)。Phase 9 上线后数据沉淀几周再使用更准确。

### 3.2 周活跃用户(WAU)

```sql
SELECT COUNT(DISTINCT id) AS wau
FROM user_profiles 
WHERE last_active_at > now() - interval '7 days';
```

### 3.3 DAU/WAU 黏性比

> 健康范围:0.2~0.5(社交类应用通常更高,工具类较低)

```sql
WITH dau AS (
  SELECT COUNT(DISTINCT id) AS d FROM user_profiles 
  WHERE last_active_at::date = CURRENT_DATE
),
wau AS (
  SELECT COUNT(DISTINCT id) AS w FROM user_profiles 
  WHERE last_active_at > now() - interval '7 days'
)
SELECT 
  d AS today_dau,
  w AS wau,
  ROUND(100.0 * d / NULLIF(w, 0), 1) AS dau_wau_ratio_pct
FROM dau, wau;
```

---

## 4. 新增注册系列

### 4.1 今日新增注册

```sql
SELECT COUNT(*) AS today_new
FROM user_profiles 
WHERE created_at::date = CURRENT_DATE;
```

### 4.2 近 7 日新增注册趋势

```sql
SELECT 
  created_at::date AS day, 
  COUNT(*) AS new_users
FROM user_profiles 
WHERE created_at > now() - interval '7 days'
GROUP BY day 
ORDER BY day;
```

### 4.3 累计注册用户

```sql
SELECT COUNT(*) AS total_users FROM user_profiles;
```

---

## 5. Listing 业务系列

### 5.1 今日新发布 Listing

```sql
SELECT COUNT(*) AS today_listings
FROM listings 
WHERE created_at::date = CURRENT_DATE;
```

### 5.2 各审核状态分布

```sql
SELECT 
  moderation_status, 
  COUNT(*) AS count
FROM listings 
GROUP BY moderation_status
ORDER BY count DESC;
```

### 5.3 当前待审核队列(按优先级与剩余时间)

```sql
SELECT 
  id, 
  title, 
  moderation_priority, 
  moderation_trigger,
  moderation_due_at,
  ROUND(EXTRACT(EPOCH FROM (moderation_due_at - now())) / 3600, 1) AS hours_remaining
FROM listings 
WHERE moderation_status = 'pending_review'
ORDER BY 
  CASE moderation_priority 
    WHEN 'urgent' THEN 1 
    WHEN 'normal' THEN 2 
    WHEN 'low' THEN 3 
  END,
  moderation_due_at ASC;
```

### 5.4 SLA 超时清单

```sql
SELECT 
  id, title, moderation_priority, moderation_due_at,
  ROUND(EXTRACT(EPOCH FROM (now() - moderation_due_at)) / 3600, 1) AS hours_overdue
FROM listings 
WHERE moderation_status = 'pending_review'
  AND moderation_due_at < now()
ORDER BY moderation_due_at ASC;
```

---

## 6. 治理系列

### 6.1 当前活跃举报数(待处理)

```sql
SELECT 
  status, COUNT(*) AS count
FROM user_reports 
GROUP BY status;
```

### 6.2 当前被封禁用户

```sql
SELECT 
  u.id, u.display_name, u.email, 
  b.ban_type, b.reason_code, b.expires_at, b.created_at
FROM user_bans b
JOIN user_profiles u ON u.id = b.user_id
WHERE b.is_active = true
ORDER BY b.created_at DESC;
```

### 6.3 高频举报者(可能存在滥用)

```sql
SELECT 
  reporter_id,
  u.display_name,
  COUNT(*) AS reports_count,
  COUNT(*) FILTER (WHERE status = 'dismissed') AS dismissed_count,
  ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'dismissed') / NULLIF(COUNT(*), 0), 1) AS dismiss_rate_pct
FROM user_reports r
JOIN user_profiles u ON u.id = r.reporter_id
WHERE created_at > now() - interval '30 days'
GROUP BY reporter_id, u.display_name
HAVING COUNT(*) >= 5
ORDER BY reports_count DESC;
```

### 6.4 敏感词命中频率

```sql
SELECT 
  action,
  COUNT(*) AS hits
FROM admin_audit_logs
WHERE action LIKE 'sensitive_word_%'
  AND created_at > now() - interval '7 days'
GROUP BY action;
```

---

## 7. 健康度综合 Dashboard(一屏看完)

将多个查询拼合成一份"运营日报":

```sql
WITH 
today_dau AS (
  SELECT COUNT(DISTINCT id) AS v FROM user_profiles 
  WHERE last_active_at::date = CURRENT_DATE
),
yesterday_dau AS (
  SELECT COUNT(DISTINCT id) AS v FROM user_profiles 
  WHERE last_active_at::date = CURRENT_DATE - INTERVAL '1 day'
),
total_users AS (
  SELECT COUNT(*) AS v FROM user_profiles
),
today_new_users AS (
  SELECT COUNT(*) AS v FROM user_profiles 
  WHERE created_at::date = CURRENT_DATE
),
online_now AS (
  SELECT COUNT(*) AS v FROM user_profiles 
  WHERE last_active_at > now() - interval '5 minutes'
),
today_listings AS (
  SELECT COUNT(*) AS v FROM listings 
  WHERE created_at::date = CURRENT_DATE
),
pending_moderation AS (
  SELECT COUNT(*) AS v FROM listings 
  WHERE moderation_status = 'pending_review'
),
overdue_moderation AS (
  SELECT COUNT(*) AS v FROM listings 
  WHERE moderation_status = 'pending_review' AND moderation_due_at < now()
),
pending_reports AS (
  SELECT COUNT(*) AS v FROM user_reports 
  WHERE status = 'pending'
),
active_bans AS (
  SELECT COUNT(*) AS v FROM user_bans WHERE is_active = true
)
SELECT 
  '今日 DAU' AS metric, today_dau.v::text AS value FROM today_dau
UNION ALL SELECT '昨日 DAU', yesterday_dau.v::text FROM yesterday_dau
UNION ALL SELECT '当前在线', online_now.v::text FROM online_now
UNION ALL SELECT '累计用户', total_users.v::text FROM total_users
UNION ALL SELECT '今日新增', today_new_users.v::text FROM today_new_users
UNION ALL SELECT '今日新 Listing', today_listings.v::text FROM today_listings
UNION ALL SELECT '⏳ 待审核', pending_moderation.v::text FROM pending_moderation
UNION ALL SELECT '🚨 SLA 超时', overdue_moderation.v::text FROM overdue_moderation
UNION ALL SELECT '⏳ 待处理举报', pending_reports.v::text FROM pending_reports
UNION ALL SELECT '🚫 被封禁中', active_bans.v::text FROM active_bans;
```

> **建议**:每天上午执行一次,作为运营日报。未来可做成 cron 自动发邮件。

---

## 8. 维护与扩展

### 8.1 数据归档(未来)

`hourly_active_users` 长期累积会变大。建议在用户量稳定后,加一个 cron 任务,把 90 天前的数据归档到冷存储:

```sql
-- 示例:导出 90 天前数据到 archived_hourly_active_users(归档后删除原数据)
-- 当前阶段不实施,留待数据看板模块时一并处理
```

### 8.2 院系维度(未来)

当 `user_profiles.department` 字段添加后,可在所有查询中加 `JOIN user_profiles ON ... WHERE department = 'CS'`。

---

*文档版本:v1.0 · 维护者:Smivo 项目主导*
*最后更新:2026-04-29*
