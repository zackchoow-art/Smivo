1. **修复系统消息清除问题**：
   - 原因：数据库的 `notifications` 表缺少允许用户删除自己通知的 RLS Policy（DELETE Policy），导致接口请求虽然成功（返回200）但实际未删除，触发乐观更新后刷新又恢复。
   - 行动：创建迁移文件 `00158_add_delete_policy_notifications.sql` 并执行，允许用户删除自己的通知。

2. **修复 iOS 推送通知点击后跳转问题**：
   - 原因：`push-notification` 的 Edge Function 返回的 `action_url` 为 `/group-chat/<id>`，而 GoRouter 未注册该路由，触发异常跳转到 `home`。
   - 行动：在 `app_routes.dart` 和 `router.dart` 中添加 `groupChatRoom` 路由，并映射到 `GroupChatScreen`。

3. **修复群聊消息的通知分类和底部 Chat 未读数红点**：
   - 原因1：`NotificationRepository` 仅排除了 `new_message`，未排除群聊类型的 `group_message`，导致它混入了系统消息。
   - 原因2：底部导航栏的未读红点绑定的 `chatTotalUnreadProvider` 当前只统计了单聊（`chatRoomListProvider`），漏掉了群聊的未读。
   - 行动：在 `NotificationRepository` 中过滤掉 `group_message`。在 `chat_provider.dart` 中修改总未读统计，将 `groupUnreadCountsProvider` 纳入计算。

4. **双击底部 Chat 图标回顶**：
   - 确认：这一功能在 `ResponsiveScaffold` 和 `ChatListScreen` 的 `chatScrollTriggerProvider` 中已完全实现（已验证代码）。若后续测试发现未生效，可能是没有触发，但在代码层面逻辑已闭环。

5. **标准化 Post 页（使其拥有底部导航栏和大标题）**：
   - 行动：将 `PostHub` 从顶级独立路由移入 `router.dart` 的 `StatefulShellRoute` 分支（作为第 3 个分支，Orders变为第 4 个）。
   - 修改 `BottomNavBar` 和 `ResponsiveScaffold` 将其关联到分支导航。
   - 修改 `post_hub_screen.dart`，移除 `AppBar`，加入类似 `OrdersScreen` 的大号标题。

6. **修复 iPad / 桌面版群聊的分屏显示**：
   - 原因：`ChatListScreen` 中 `_GroupChatListSection` 当前硬编码为直接 `Navigator.push` 全屏页面，没有接入 `ChatSplitView` 的选定状态逻辑。
   - 行动：传入 `isDesktop` 标记，当为桌面端时，将选中项记录为 `group_${tripId}`，并在 `ChatSplitView` 渲染逻辑中分发渲染 `GroupChatScreen`，从而保持右侧分屏。

确认后我将开始执行这些修改。
