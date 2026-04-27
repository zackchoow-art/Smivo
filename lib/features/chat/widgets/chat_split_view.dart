import 'package:flutter/material.dart';

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
    return Row(
      children: [
        // Left master panel: fixed 320px width
        SizedBox(
          width: 320,
          child: chatList,
        ),
        // Vertical divider between panels
        const VerticalDivider(width: 1, thickness: 1),
        // Right detail panel: fills remaining width
        Expanded(
          child: chatRoom ??
              const Center(
                child: Text(
                  'Select a conversation',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
        ),
      ],
    );
  }
}
