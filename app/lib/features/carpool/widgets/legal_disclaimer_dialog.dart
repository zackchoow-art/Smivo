import 'package:flutter/material.dart';

/// Displays a legal disclaimer for the campus carpool feature.
///
/// Must be shown before a user publishes or joins a carpool trip for
/// the first time. Returns true if the user accepted, false if declined.
class LegalDisclaimerDialog extends StatelessWidget {
  const LegalDisclaimerDialog({super.key});

  /// Shows the dialog and returns the user's choice.
  ///
  /// Returns true if the user tapped "Agree & Continue", false otherwise.
  static Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const LegalDisclaimerDialog(),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Campus Carpool Disclaimer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _DisclaimerItem(
            index: 1,
            text: 'This carpool feature is for campus mutual aid only. Illegal operation or for-profit behavior is strictly prohibited.',
          ),
          SizedBox(height: 8),
          _DisclaimerItem(
            index: 2,
            text: 'All trips are arranged by users. The platform is not responsible for any traffic accidents or other liabilities.',
          ),
          SizedBox(height: 8),
          _DisclaimerItem(
            index: 3,
            text: 'Please verify the identity of your fellow riders and pay attention to your personal and property safety.',
          ),
          SizedBox(height: 8),
          _DisclaimerItem(
            index: 4,
            text: 'Posting false information or maliciously reserving seats will result in account suspension.',
          ),
          SizedBox(height: 8),
          _DisclaimerItem(
            index: 5,
            text: 'By using this feature, you agree to the terms and conditions above.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Decline'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Agree & Continue'),
        ),
      ],
    );
  }
}

/// A single numbered disclaimer rule row.
class _DisclaimerItem extends StatelessWidget {
  const _DisclaimerItem({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$index. ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
