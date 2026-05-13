import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class ActionErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const ActionErrorDialog({
    super.key,
    this.title = 'Failed',
    this.message = 'An error occurred. Please try again.',
    this.buttonText = 'OK',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.dialog),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: colors.error, size: 80),
          const SizedBox(height: 24),
          Text(
            title,
            style: typo.headlineSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: typo.bodyMedium),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed ?? () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius.button),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(color: colors.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
