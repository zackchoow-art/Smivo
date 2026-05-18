import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// A resizable Master-Detail split layout for desktop Chat screens.
///
/// Left panel (chat list) and right panel (chat room) are separated by a
/// draggable divider. The user can drag horizontally to resize the panels,
/// with hard limits to ensure both panels always have usable space.
///
/// Constraints:
///   - Minimum left panel width : [_kMinLeftWidth]   (240 px)
///   - Maximum left panel width : [_kMaxLeftWidth]   (480 px)
///   - Default left panel width : [_kDefaultLeftWidth] (320 px)
class ChatSplitView extends StatefulWidget {
  const ChatSplitView({super.key, required this.chatList, this.chatRoom});

  /// Widget displayed in the left master panel.
  final Widget chatList;

  /// Widget displayed in the right detail panel.
  /// When null, a "Select a conversation" placeholder is shown.
  final Widget? chatRoom;

  @override
  State<ChatSplitView> createState() => _ChatSplitViewState();
}

class _ChatSplitViewState extends State<ChatSplitView> {
  // NOTE: Clamp range chosen so both panels stay readable at all times.
  static const double _kDefaultLeftWidth = 320;
  static const double _kMinLeftWidth = 240;
  static const double _kMaxLeftWidth = 480;

  // Divider hit-target is wider than the visible line for easy grabbing.
  static const double _kDividerHitWidth = 12;
  static const double _kDividerVisibleWidth = 1;

  double _leftWidth = _kDefaultLeftWidth;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Row(
      children: [
        // ── Left master panel ────────────────────────────────────────────
        SizedBox(width: _leftWidth, child: widget.chatList),

        // ── Draggable divider ────────────────────────────────────────────
        // GestureDetector sits over a wider hit area centred on the 1px line.
        MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) => setState(() => _isDragging = true),
            onHorizontalDragUpdate: (details) {
              setState(() {
                _leftWidth = (_leftWidth + details.delta.dx).clamp(
                  _kMinLeftWidth,
                  _kMaxLeftWidth,
                );
              });
            },
            onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
            child: SizedBox(
              width: _kDividerHitWidth,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  // NOTE: Highlight divider while dragging to give feedback.
                  width: _isDragging ? 3 : _kDividerVisibleWidth,
                  color: _isDragging
                      ? colors.primary.withValues(alpha: 0.5)
                      : colors.outline.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
        ),

        // ── Right detail panel ───────────────────────────────────────────
        Expanded(
          child: widget.chatRoom ??
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
