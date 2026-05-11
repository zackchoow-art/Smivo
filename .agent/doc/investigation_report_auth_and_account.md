# 调查报告：平台配置校验与账户删除功能异常分析

**日期**：2026-05-11  
**状态**：调查完成，待修复方案确认  

---

## 1. 问题一：Debug 模式无法开启
### 1.1 现象描述
用户在 App 端的注册页/登录页长按 Logo 试图开启 Debug 模式时，即使平台后台已开启相关开关，App 仍提示：“Debug mode is disabled by the platform.”

### 1.2 技术根源分析
*   **触发条件**：App 端 `RegisterScreen` 和 `LoginScreen` 的 `_checkPlatformAndToggle` 函数。
*   **根本原因 (RLS 限制)**：
    *   数据库表 `public.system_configs` 的行级安全性 (RLS) 策略极其严格。
    *   现有的 RLS 策略（迁移 `00057`）仅允许 **已登录且具有 sysadmin 权限的用户** 读取配置。
    *   App 端用户在尝试开启 Debug 模式时通常处于 **未登录状态 (anon)**。
    *   由于权限不足，Supabase 查询返回空结果，App 代码默认将其视为“已禁用（false）”。

### 1.3 解决思路
*   **策略调整**：修改数据库 RLS 策略，允许匿名用户 (`anon`) 只读访问 `test_user.registration_enabled` 和 `test_user.login_enabled` 两个特定键值。

---

## 2. 问题二：活跃用户删除账户失败 (409 Conflict)
### 2.1 现象描述
新注册且无业务的用户可顺利删除账户，但发布过商品或有订单记录的用户点击删除账户无响应，Chrome 控制台报错：`409 (Conflict)`。

### 2.2 技术根源分析
*   **数据库死锁链**：
    1.  `delete_own_account()` 触发删除 `user_profiles`。
    2.  `listings` 表设置了级联删除 (`ON DELETE CASCADE`)，尝试跟随删除。
    3.  **冲突发生点**：`orders` 表的 `listing_id` 外键设置为 **`ON DELETE RESTRICT`**。
    4.  如果该商品存在任何关联订单（无论状态），数据库会为了保护订单证据而禁止删除该商品。
    5.  由于商品无法删除，级联动作失败，导致顶层的用户 Profile 无法删除，返回 `409` 错误。

### 2.3 解决思路
*   **方案 A (平滑脱敏)**：
    *   将 `orders.listing_id` 修改为可为空 (`NULL`)。
    *   将约束改为 `ON DELETE SET NULL`。这样删除账户时，订单历史得以保留，但不再锁定商品和用户。
*   **方案 B (彻底清理)**：
    *   将约束改为 `ON DELETE CASCADE`。但这会导致订单历史随账户一同彻底消失，可能影响平台对账和争议追溯。
*   **方案 C (逻辑重构)**：
    *   在 `delete_own_account` 函数中增加预清理步骤，先手动取消或脱敏相关记录。

---

## 3. 下一步计划
1.  **提交 SQL 补丁**：针对以上两个问题编写合并后的数据库迁移脚本。
2.  **App 端反馈优化**：在 App 端增加删除失败时的具体错误提示，避免“无响应”现象。
3.  **后台 UI 修复**：解决后台管理界面在关闭开关后导致按钮变灰不可逆的问题。
