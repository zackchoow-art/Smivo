# SETTINGS-003 执行报告

## 执行时间
2026-04-26

## 1. 修改概述

完成了 Delete Account 功能的全栈实现，共涉及 4 个文件：

| 文件 | 操作 | 说明 |
|------|------|------|
| `supabase/migrations/00033_delete_account_rpc.sql` | 新建 | RPC 函数定义 |
| `lib/data/repositories/auth_repository.dart` | 添加方法 | `deleteAccount()` |
| `lib/features/auth/providers/auth_provider.dart` | 添加方法 | `deleteAccount()` |
| `lib/features/settings/screens/settings_screen.dart` | 添加 UI | Delete Account 按钮 + 确认对话框 |

---

## 2. 关键代码变更

### 2a. SQL 迁移文件

```sql
CREATE OR REPLACE FUNCTION delete_own_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER          -- 提权执行，允许删除 auth.users
SET search_path = public
AS $$
BEGIN
  DELETE FROM user_profiles WHERE id = auth.uid();
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;

GRANT EXECUTE ON FUNCTION delete_own_account() TO authenticated;
```

**设计决策**：使用 `SECURITY DEFINER` 是因为普通用户无权直接操作 `auth.users` 表，RPC 函数以 owner（通常是 postgres role）权限运行，`auth.uid()` 确保用户只能删除自己。

### 2b. `auth_repository.dart` — `deleteAccount()`

```dart
Future<void> deleteAccount() async {
  try {
    await _client.rpc('delete_own_account');
    await _client.auth.signOut();
  } on PostgrestException catch (e) {
    throw DatabaseException('Failed to delete account: ${e.message}', e);
  }
}
```

### 2c. `auth_provider.dart` — `deleteAccount()`

```dart
Future<void> deleteAccount() async {
  state = const AsyncValue.loading();
  try {
    await ref.read(authRepositoryProvider).deleteAccount();
    state = const AsyncValue.data(null);
  } catch (e, st) {
    state = AsyncValue.error(_mapError(e, st), st);
  }
}
```

### 2d. `settings_screen.dart` — UI

在 Logout 按钮下方添加了 `TextButton("Delete Account")`：
- 使用 `colors.error.withValues(alpha: 0.7)` 浅红色，视觉权重低于 Logout
- 点击弹出 `AlertDialog` 二次确认
- 确认后调用 `authProvider.notifier.deleteAccount()`
- 删除成功后跳转到 Home 页面

---

## 3. `flutter analyze` 结果

```
Analyzing 3 items...
No issues found! (ran in 0.9s)
```

**0 error、0 warning、0 info**

---

## 4. ⚠️ 重要提醒

> **SQL 迁移文件已创建但未执行。**
> 请在 Supabase Dashboard → SQL Editor 中手动执行 `supabase/migrations/00033_delete_account_rpc.sql` 的内容。
> 在 RPC 函数创建之前，客户端调用 `deleteAccount()` 会收到 "function not found" 错误。
