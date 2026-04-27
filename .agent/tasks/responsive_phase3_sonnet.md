# Task: Phase 3 — Chat 页面响应式适配

## 执行边界 ⚠️
- **只修改/新建本文件列出的文件**，不得修改其他文件
- **不得修改业务逻辑、Provider、Repository、Model、router**
- 新建文件路径必须严格遵循下列指定路径
- 使用 `LayoutBuilder` + `Breakpoints` 类判断屏幕尺寸

## Breakpoints（已有，直接用）
```dart
Breakpoints.isMobile(width)   // < 600
Breakpoints.isTablet(width)   // 600-1024
Breakpoints.isDesktop(width)  // > 1024
```

---

### 3-1. 新建 `lib/features/chat/widgets/chat_split_view.dart`
**桌面 Master-Detail 布局**：
- 左侧面板：固定宽度 320px，显示聊天列表
- 右侧面板：填充剩余宽度，显示选中的聊天室
- 左右之间用 `VerticalDivider` 分隔
- 左侧面板需要接收 `chatList` Widget
- 右侧面板需要接收 `chatRoom` Widget 或占位符 "Select a conversation"
- 这个 Widget 是一个纯布局容器，不含任何业务逻辑

### 3-2. `lib/features/chat/screens/chat_list_screen.dart` (283 行)
- 使用 `LayoutBuilder`：
  - 手机：保持原样
  - 平板/桌面：内容区 `ContentWidthConstraint(maxWidth: 768)`

### 3-3. `lib/features/chat/screens/chat_room_screen.dart` (475 行)
- 消息区域桌面时 `ContentWidthConstraint(maxWidth: 720)` 居中
- 输入框区域桌面时也 `ContentWidthConstraint(maxWidth: 720)` 居中

### 3-4. `lib/features/chat/widgets/chat_list_item.dart` (194 行)
- 不需要修改（列表项自适应宽度）

### 3-5. `lib/features/chat/widgets/chat_popup.dart` (535 行)
- 桌面模式时弹窗 maxWidth 固定 480px
- 使用 `ConstrainedBox`

---

## 完成后必做
1. 运行 `flutter analyze --no-fatal-infos`
2. 确保 **0 errors**
3. 将执行报告写入 `.agent/reports/responsive_phase3_report.md`
