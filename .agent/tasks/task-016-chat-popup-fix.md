# Task 016: Chat Popup 修复

## 分配给: Flash
## 复杂度: ⭐⭐
## 涉及文件
- `lib/features/chat/widgets/chat_popup.dart` (498 行)

## 重要规则
- 只做 UI 调整，不改业务逻辑
- 所有颜色/字体/圆角必须用主题 token（`context.smivoColors`, `context.smivoTypo`, `context.smivoRadius`）
- 读完整个文件再开始修改

## 修改清单

### A. 头像加载修复
找到 popup 左上角显示对方用户头像的 `CircleAvatar`。
- 确认 `backgroundImage` 正确使用 `NetworkImage(user.avatarUrl!)`
- 确认有空值检查：`avatarUrl != null && avatarUrl!.isNotEmpty`
- fallback 使用 `Icon(Icons.person)` 或首字母

### B. 用户名下方添加邮箱
在显示用户名的 `Text` widget 下方添加：
```dart
Text(
  otherUser?.email ?? '',
  style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
),
```
UserProfile model 已有 `email` 字段。

### C. 移除消息气泡中的头像
找到消息列表中每条消息的渲染代码，移除 `CircleAvatar`（发送方和接收方的头像都移除）。
只保留消息气泡本身。

### D. 图片消息加载修复
找到处理图片类型消息的代码（搜索 `image` 或 `Image.network`）。
- 确认图片 URL 正确（可能需要 Supabase Storage 的完整 URL）
- 添加 `loadingBuilder` 或 `errorBuilder` 防止加载失败白屏
- 确认图片容器有合理的 maxWidth/maxHeight 约束

### E. 主题一致性
搜索文件中的所有硬编码颜色值（如 `Color(0x...)`, `Colors.xxx`），全部替换为主题 token：
- 颜色 → `colors.xxx`
- 字体 → `typo.xxx`
- 圆角 → `radius.xxx`

## 验证
```bash
flutter analyze
```
必须零错误。
