# Task 017: ChatRoom 界面改造

## 分配给: Flash
## 复杂度: ⭐⭐
## 涉及文件
- `lib/features/chat/screens/chat_room_screen.dart` (355 行)

## 重要规则
- 只做 UI 调整，不改消息发送/接收的业务逻辑
- 所有颜色/字体/圆角必须用主题 token
- 读完整个文件再开始修改

## 修改清单

### A. AppBar 改造
当前：中间显示 "Chat" 标题。
改为：
```dart
AppBar(
  leading: BackButton(),
  title: Row(children: [
    CircleAvatar(
      radius: 18,
      backgroundImage: otherUser?.avatarUrl != null && otherUser!.avatarUrl!.isNotEmpty
          ? NetworkImage(otherUser.avatarUrl!)
          : null,
      child: otherUser?.avatarUrl == null || otherUser!.avatarUrl!.isEmpty
          ? Icon(Icons.person, size: 18)
          : null,
    ),
    const SizedBox(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(otherUser?.displayName ?? 'User', style: typo.titleMedium),
      Text(otherUser?.email ?? '', style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant)),
    ]),
  ]),
  titleSpacing: 0,
)
```

### B. 移除消息气泡中的头像
同 Task-016：找到消息气泡中的 CircleAvatar，全部移除。

### C. 消息下方添加时间戳
在每条消息气泡下方添加时间戳：
```dart
Padding(
  padding: const EdgeInsets.only(top: 4),
  child: Text(
    DateFormat('yyyy-MM-dd HH:mm').format(message.createdAt.toLocal()),
    style: typo.labelSmall.copyWith(color: colors.outlineVariant),
  ),
)
```
需要 `import 'package:intl/intl.dart';`

### D. 图片消息改进
找到图片消息的渲染区域：
1. 移除外框/边框装饰（去掉包裹图片的 `Container` 的 `decoration`）
2. 限制图片尺寸：`maxWidth: 200, maxHeight: 200`
3. 添加点击查看原图功能：
```dart
GestureDetector(
  onTap: () => showDialog(
    context: context,
    builder: (_) => Dialog(
      child: InteractiveViewer(
        child: Image.network(message.imageUrl!),
      ),
    ),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(radius.card),
    child: Image.network(
      message.imageUrl!,
      width: 200,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(Icons.broken_image),
    ),
  ),
)
```

### E. 主题一致性
替换所有硬编码颜色/字体值为主题 token。

## 验证
```bash
flutter analyze
```
必须零错误。
