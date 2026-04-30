import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class ReportDialog extends StatefulWidget {
  final String title;
  final Function(String category, String customReason) onSubmit;

  const ReportDialog({
    super.key,
    required this.title,
    required this.onSubmit,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String _selectedCategory = 'spam';
  final _reasonController = TextEditingController();

  final Map<String, String> _categories = {
    'spam': 'Spam or irrelevant',
    'harassment': 'Harassment or hate speech',
    'fraud': 'Scam or fraud',
    'inappropriate': 'Inappropriate content',
    'other': 'Other',
  };

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.smivoRadius.xl),
      ),
      backgroundColor: context.smivoColors.surface,
      title: Text(
        widget.title,
        style: context.smivoTypo.titleMedium.copyWith(
          color: context.smivoColors.onSurface,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please select a reason:',
              style: context.smivoTypo.bodyMedium.copyWith(
                color: context.smivoColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ..._categories.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(
                  entry.value,
                  style: context.smivoTypo.bodyMedium.copyWith(
                    color: context.smivoColors.onSurface,
                  ),
                ),
                value: entry.key,
                groupValue: _selectedCategory,
                activeColor: context.smivoColors.primary,
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              );
            }),
            if (_selectedCategory == 'other') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.smivoRadius.input),
                  ),
                  hintText: 'Please provide more details...',
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: context.smivoTypo.labelLarge.copyWith(
              color: context.smivoColors.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            final customReason = _selectedCategory == 'other'
                ? _reasonController.text.trim()
                : _categories[_selectedCategory]!;
            
            if (_selectedCategory == 'other' && customReason.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please provide a reason.')),
              );
              return;
            }

            widget.onSubmit(_selectedCategory, customReason);
            Navigator.pop(context);
          },
          child: Text(
            'Submit',
            style: context.smivoTypo.labelLarge.copyWith(
              color: context.smivoColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
