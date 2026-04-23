import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// Reusable error display widget for AsyncValue error states.
///
/// Shows an error icon, message, and optional retry button.
/// Use this in AsyncValue.when(error:) handlers for consistency.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.message,
    this.onRetry,
    super.key,
  });

  /// The error message to display.
  final String message;

  /// Optional callback for a retry button. If null, no button is shown.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colors.error,
              semanticLabel: 'Error icon',
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
