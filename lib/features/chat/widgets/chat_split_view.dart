import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// A Master-Detail split layout for desktop Chat screens.
///
/// Left panel (320px) shows the chat list; right panel fills
/// the remaining width with the selected chat room or a placeholder.
/// This widget is a pure layout container — it contains no business logic.
class ChatSplitView extends StatelessWidget {
  const ChatSplitView({
    super.key,
    required this.chatList,
    this.chatRoom,
  });

  /// Widget displayed in the left 320px master panel.
  final Widget chatList;

  /// Widget displayed in the right detail panel.
  /// When null, a "Select a conversation" placeholder is shown.
  final Widget? chatRoom;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Row(
      children: [
        // Left master panel: fixed 320px width
        SizedBox(
          width: 320,
          child: chatList,
        ),
        // Vertical divider between panels
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: colors.outline.withValues(alpha: 0.12),
        ),
        // Right detail panel: fills remaining width
        Expanded(
          child: chatRoom ??
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: colors.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select a conversation',
                      style: typo.titleMedium.copyWith(
                        color: colors.outlineVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pick a chat from the left to start messaging',
                      style: typo.bodySmall.copyWith(
                        color: colors.outlineVariant,
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ],
    );
  }
}
