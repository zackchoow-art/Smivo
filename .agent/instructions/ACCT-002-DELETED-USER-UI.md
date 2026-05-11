# 指令文件：Account Deletion App-Side UI Adaptation (ACCT-002)

## 背景

数据库迁移 `00140` 已将 `delete_own_account()` 改为优雅的软删除模式：
- 用户 Profile 保留但匿名化（display_name = 'Deleted User'，deleted_at != null）
- Auth 账户保留但禁用（banned + email scrambled）
- 已完成订单保留，进行中订单取消
- 聊天会话收到系统告别消息

App 端的 `UserProfile` 模型已添加 `deletedAt` 字段。代码生成已完成。

## 任务清单

### 1. 聊天室：阻止向已删除用户发送消息

**文件**: `app/lib/features/chat/screens/chat_room_screen.dart`

在消息输入区域，检查聊天对象的 `deletedAt` 是否不为空。如果已删除：
- 隐藏消息输入框
- 显示一个居中文本提示："This user has deleted their account. Messages can no longer be delivered."
- 样式：灰色文字，带 ⚠️ 图标，类似 disabled 状态

**如何获取对方 Profile**：
- 聊天室已有 `buyer` 和 `seller` 嵌套数据
- 根据当前用户 ID 判断对方：`partner = (currentUserId == room.buyerId) ? room.seller : room.buyer`
- 检查 `partner?.deletedAt != null`

### 2. 聊天列表：标记已删除用户的会话

**文件**: `app/lib/features/chat/widgets/chat_list_item.dart`

在聊天列表项中，如果对方已删除：
- 显示名称为 "Deleted User"（后端已设置）
- 头像显示默认图标（后端已清空 avatar_url）
- 可选：添加一个细微的 "Account deleted" 副标题或灰色标记

**无需特殊处理**：后端已将 display_name 改为 "Deleted User"，avatar_url 改为 null。现有 UI 会自然降级显示。只需确认不会崩溃。

### 3. 系统消息样式

**文件**: `app/lib/features/chat/screens/chat_room_screen.dart`（消息气泡渲染区域）

当前 `system` 类型消息没有特殊样式，会作为普通消息气泡显示。添加特殊处理：

```dart
if (message.messageType == 'system') {
  return Center(
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message.content,
        style: typo.bodySmall.copyWith(
          color: colors.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
```

### 4. 聊天弹窗：同样阻止发送

**文件**: `app/lib/features/chat/widgets/chat_popup.dart`

应用与 chat_room_screen 相同的逻辑：检查对方 `deletedAt`，如果已删除则禁用输入。

### 5. SmivoUserAvatar：已删除用户标记

**文件**: `app/lib/shared/widgets/smivo_user_avatar.dart`（或对应位置）

如果传入的 `UserProfile` 的 `deletedAt != null`：
- 不显示在线状态点（绿色/灰色都不显示）
- 头像使用默认 placeholder（avatar_url 已是 null）
- 无需灰度处理

### 6. 订单详情页：显示 "Deleted User"

**文件**:
- `app/lib/features/orders/screens/sale_order_detail_screen.dart`
- `app/lib/features/orders/screens/rental_order_detail_screen.dart`

在完成的历史订单中，对方显示为 "Deleted User"（后端已设置 display_name）。
- 确保不会因为 avatar_url 为 null 或其他字段改变而崩溃
- 隐藏 "Message" 按钮如果对方 `deletedAt != null`

### 7. 删除确认对话框：更新文案

**文件**: `app/lib/features/settings/screens/edit_profile_screen.dart`

更新删除确认对话框文案，反映新的软删除行为：

```
'Your account will be deactivated permanently. All active listings will be delisted, '
'pending orders will be cancelled, and your chat partners will be notified. '
'Completed orders will be preserved in the system.'
```

### 8. 删除按钮交互：改为 await + 错误反馈

**文件**: `app/lib/features/settings/screens/edit_profile_screen.dart`

当前删除是 fire-and-forget。改为 await + 错误提示：

```dart
onPressed: () async {
  Navigator.pop(dialogContext);
  try {
    await ref
        .read(authProvider.notifier)
        .deleteAccount();
    if (context.mounted) {
      context.goNamed(AppRoutes.home);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete account. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
},
```

## 执行边界

- **仅修改** 上述列出的 App 文件
- **不要修改** 数据库或迁移文件
- **不要修改** `admin/` 目录
- **不要修改** `auth_repository.dart`（已更新）
- **不要修改** `user_profile.dart` 模型（已更新）

## 验收标准

1. `flutter analyze` 无 error
2. 系统消息（message_type == 'system'）有居中灰色样式
3. 已删除用户的聊天输入框被禁用并显示提示
4. 订单详情页对方为已删除用户时不崩溃
5. 删除确认对话框文案已更新
6. 删除失败时用户看到错误 SnackBar

## 执行报告保存位置

`/Users/george/smivo/.agent/reports/ACCT-002-execution-report.md`
