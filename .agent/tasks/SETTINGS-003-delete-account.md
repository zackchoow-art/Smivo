# SETTINGS-003: Delete Account 功能

## 目标
在 Settings 主页添加"Delete Account"功能，包含前端 UI 和后端 Supabase 逻辑。

## 修改文件
1. `lib/features/settings/screens/settings_screen.dart` — 添加 Delete Account 按钮
2. `lib/features/auth/providers/auth_provider.dart` — 添加 deleteAccount 方法
3. `lib/data/repositories/auth_repository.dart` — 添加 deleteAccount 方法
4. `supabase/migrations/00033_delete_account_rpc.sql` — 创建 RPC 函数

## 不要修改的文件
- ❌ 不修改其他 settings 子页面
- ❌ 不修改 profile_repository.dart
- ❌ 不修改 router.dart

## 需求详细

### 1. Supabase RPC 函数

创建一个 SQL 迁移文件 `supabase/migrations/00033_delete_account_rpc.sql`：

```sql
-- Delete current user's account and all associated data.
-- Called via RPC from the client side.
-- SECURITY: Uses auth.uid() to ensure users can only delete their own account.
CREATE OR REPLACE FUNCTION delete_own_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Delete user profile (cascades handled by foreign keys)
  DELETE FROM user_profiles WHERE id = auth.uid();
  
  -- Delete the auth user
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;

-- Only authenticated users can call this
GRANT EXECUTE ON FUNCTION delete_own_account() TO authenticated;
```

**注意**：这个 SQL 文件只需要创建，不需要执行。用户会手动在 Supabase Dashboard 执行。

### 2. Auth Repository

在 `lib/data/repositories/auth_repository.dart` 中添加方法：

```dart
/// Delete the current user's account via RPC.
/// This removes all user data and the auth record.
Future<void> deleteAccount() async {
  try {
    await _client.rpc('delete_own_account');
    await _client.auth.signOut();
  } on PostgrestException catch (e) {
    throw AppException.database('Failed to delete account: ${e.message}', e);
  }
}
```

先查看 `auth_repository.dart` 的现有结构，在合适位置添加。

### 3. Auth Provider

在 `lib/features/auth/providers/auth_provider.dart` 的 `Auth` class 中添加：

```dart
/// Permanently deletes the current user's account.
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

### 4. Settings Screen UI

在 `settings_screen.dart` 的 Logout 按钮下方（第 87 行后），添加 Delete Account 按钮：

```dart
const SizedBox(height: 16),
Center(child: Consumer(builder: (context, ref, child) {
  return TextButton(
    onPressed: () => _showDeleteConfirmation(context, ref),
    child: Text('Delete Account', style: typo.labelLarge.copyWith(
      color: colors.error.withValues(alpha: 0.7),
      fontWeight: FontWeight.w500,
    )),
  );
})),
```

添加确认对话框方法（在 `SettingsScreen` class 内或作为静态方法）：

由于 `SettingsScreen` 是 `StatelessWidget`，需要在 build 方法外定义或改为一个函数。
最简方案：由于要用 `ref`，在 `Consumer` 内部直接写 dialog：

```dart
void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete Account'),
      content: const Text(
        'This action is permanent and cannot be undone. '
        'All your listings, orders, messages, and profile data will be deleted.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await ref.read(authProvider.notifier).deleteAccount();
            if (context.mounted) {
              context.goNamed(AppRoutes.home);
            }
          },
          style: TextButton.styleFrom(foregroundColor: colors.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
```

注意：因为 `SettingsScreen` 是 `StatelessWidget`，`_showDeleteConfirmation` 不能是实例方法。
**解决方案**：要么改成 StatefulWidget，要么把它变成一个 static/top-level 函数传入 ref。

**最简方案**：在 Consumer builder 内直接 inline 写 showDialog 调用。

## 严格边界
- ❌ 不修改 `settings_screen.dart` 中已有的菜单卡片和 Help 入口
- ❌ 不修改 router.dart
- ❌ 不修改其他 settings 子页面

## 验证步骤

```bash
cd /Users/george/smivo && flutter analyze
```

## 执行报告

写入：`.agent/reports/SETTINGS-003-report.md`

报告需包含：
1. 创建的 SQL 迁移文件路径
2. 修改的代码文件列表和关键变更
3. flutter analyze 结果
4. 提醒用户在 Supabase Dashboard 执行 SQL
