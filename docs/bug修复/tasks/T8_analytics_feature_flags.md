# T8: DAU/WAU/MAU 调查与实现 + Feature Flags 补全

## 任务目标
1. 调查日活(DAU)/周活(WAU)/月活(MAU)是否已实现，如未实现则实现
2. 在 Feature Flags 页面补全所有前端用到的数据库开关，每个添加描述

## 执行边界
### 允许修改：
- `admin/src/hooks/useAnalytics.ts`
- `admin/src/pages/AnalyticsPage.tsx`
- `admin/src/hooks/useFeatureFlags.ts`
- `admin/src/pages/settings/FeatureFlagsPage.tsx`
- `admin/src/hooks/useDashboard.ts`
- `admin/src/pages/DashboardPage.tsx`

### 严禁修改：
- `app/` 目录下任何文件
- `supabase/migrations/` 下现有文件
- `website/` 目录

### 允许新增：
- `supabase/migrations/` 下的新迁移文件（如需创建视图或函数）

## 实现要点

### 1. DAU/WAU/MAU 调查
**已有基础设施：**
- `admin/src/hooks/useAnalytics.ts` 已有 DAU Trend（基于 `hourly_active_users` 表）
- Dashboard 也有 `useDashboard.ts`

**需要确认：**
- `hourly_active_users` 表是否有数据？数据来源是什么？
- WAU（周活）和 MAU（月活）是否已实现？
- 检查 `app/` 中是否有心跳 (heartbeat) 机制上报用户活跃

**如果未实现：**
- DAU = 过去 24 小时内活跃的独立用户数
- WAU = 过去 7 天内活跃的独立用户数  
- MAU = 过去 30 天内活跃的独立用户数
- 在 AnalyticsPage 或 DashboardPage 展示这三个 KPI 卡片

### 2. Feature Flags 补全
**调查步骤：**
1. 搜索 app/ 和 admin/ 中所有读取 system_configs / feature_flags 的地方
2. 列出所有使用到的开关 key
3. 在 FeatureFlagsPage 中确保每个开关都有对应的 UI 控件
4. 每个开关添加描述：数据库哪张表的哪个字段

```bash
grep -rn "system_configs\|feature_flag\|system_settings" app/lib/ admin/src/ --include="*.dart" --include="*.ts" --include="*.tsx"
```

## 验证
```bash
cd /Users/george/smivo/admin && npx tsc -b
```

## 报告文件：`docs/bug修复/tasks/T8_report.md`
