import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/shared/providers/system_dictionary_provider.dart';

/// Hardcoded fallback — used when the DB query fails or is still loading
/// on first launch. Keeps the app functional offline.
const _fallbackCategories = {
  'spam': 'Spam or irrelevant',
  'harassment': 'Harassment or hate speech',
  'fraud': 'Scam or fraud',
  'inappropriate': 'Inappropriate content',
  'other': 'Other',
};

class ReportDialog extends ConsumerStatefulWidget {
  final String title;
  final Function(String category, String customReason) onSubmit;

  const ReportDialog({super.key, required this.title, required this.onSubmit});

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  String _selectedCategory = 'spam';
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// Converts the provider data into a {key: value} map, falling back to
  /// hardcoded defaults on error or while loading for the first time.
  Map<String, String> _resolveCategories(
    AsyncValue<List<Map<String, String>>> asyncDict,
  ) {
    return asyncDict.when(
      data: (items) {
        if (items.isEmpty) return _fallbackCategories;
        final map = <String, String>{};
        for (final item in items) {
          map[item['key']!] = item['value']!;
        }
        return map;
      },
      // NOTE: Show fallback while loading so the dialog is never empty.
      loading: () => _fallbackCategories,
      error: (_, __) => _fallbackCategories,
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncDict = ref.watch(systemDictionaryProvider('report_type'));
    final categories = _resolveCategories(asyncDict);

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
            ...categories.entries.map((entry) {
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
                    borderRadius: BorderRadius.circular(
                      context.smivoRadius.input,
                    ),
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
            final customReason =
                _selectedCategory == 'other'
                    ? _reasonController.text.trim()
                    : categories[_selectedCategory]!;

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
