import 'package:flutter/material.dart';

/// Displays a legal disclaimer for the campus carpool feature.
///
/// Must be shown before a user publishes or joins a carpool trip for
/// the first time. Returns true if the user accepted, false if declined.
class LegalDisclaimerDialog extends StatelessWidget {
  const LegalDisclaimerDialog({super.key});

  /// Shows the dialog and returns the user's choice.
  ///
  /// Returns true if the user tapped "同意并继续", false otherwise.
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
      title: const Text('校园拼车免责声明'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _DisclaimerItem(
            index: 1,
            text: '本拼车功能仅限校园互助出行，严禁非法营运或营利行为',
          ),
          SizedBox(height: 8),
          _DisclaimerItem(
            index: 2,
            text: '所有行程均由用户自行协商安排，平台不承担交通事故等任何责任',
          ),
          SizedBox(height: 8),
          _DisclaimerItem(
            index: 3,
            text: '请核实同行人身份，注意人身和财产安全',
          ),
          SizedBox(height: 8),
          _DisclaimerItem(
            index: 4,
            text: '发布虚假信息、恶意占座等行为将被封号处理',
          ),
          SizedBox(height: 8),
          _DisclaimerItem(
            index: 5,
            text: '使用本功能即表示您已阅读并同意以上条款',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('不同意'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('同意并继续'),
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
