import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// A themed confirm/cancel dialog that replaces raw [AlertDialog] usage
/// for destructive or consequential user actions.
///
/// Returns `true` when the user confirms, `false` (or `null`) when cancelled.
///
/// Usage:
/// ```dart
/// final confirmed = await showDialog<bool>(
///   context: context,
///   builder: (ctx) => ThemedConfirmDialog(
///     title: 'Delete Item',
///     message: 'This cannot be undone.',
///     confirmText: 'Delete',
///     isDestructive: true,
///   ),
/// );
/// if (confirmed == true) { ... }
/// ```
class ThemedConfirmDialog extends StatelessWidget {
  final String title;
  final String message;

  /// Label for the confirm button. Defaults to 'Confirm'.
  final String confirmText;

  /// Label for the cancel button. Defaults to 'Cancel'.
  final String cancelText;

  /// When true the confirm button uses [colors.error] instead of [colors.primary].
  /// Use for irreversible destructive actions (delete, delist, block).
  final bool isDestructive;

  /// Optional extra content rendered between the message and the buttons.
  /// Use for TextField inputs (e.g. rejection note).
  final Widget? child;

  const ThemedConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    // NOTE: confirm color switches to error for destructive actions so users
    // visually understand the weight of their decision.
    final confirmColor = isDestructive ? colors.error : colors.primary;
    final confirmTextColor = isDestructive ? Colors.white : colors.onPrimary;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.dialog),
      ),
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(title, style: typo.headlineSmall),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: typo.bodyMedium),
          if (child != null) ...[const SizedBox(height: 12), child!],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius.button),
            ),
          ),
          child: Text(
            confirmText,
            style: typo.labelLarge.copyWith(color: confirmTextColor),
          ),
        ),
      ],
    );
  }
}
