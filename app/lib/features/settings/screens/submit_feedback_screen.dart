import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/core/utils/image_upload_service.dart';
import 'package:smivo/features/settings/providers/feedback_provider.dart';
import 'package:smivo/features/shared/providers/system_dictionary_provider.dart';
import 'package:smivo/shared/widgets/action_success_dialog.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';

class SubmitFeedbackScreen extends ConsumerStatefulWidget {
  const SubmitFeedbackScreen({super.key});

  @override
  ConsumerState<SubmitFeedbackScreen> createState() =>
      _SubmitFeedbackScreenState();
}

class _SubmitFeedbackScreenState extends ConsumerState<SubmitFeedbackScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'bug';
  XFile? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await ImageUploadService.showSourcePicker(context);
    if (source == null) return;
    if (!mounted) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _submit() async {
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (title.trim().isEmpty || description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and description')),
      );
      return;
    }

    final platform = Theme.of(context).platform.toString();

    try {
      Uint8List? imageBytes;
      String? imageFileName;

      if (_selectedImage != null) {
        imageBytes = await _selectedImage!.readAsBytes();
        imageFileName = _selectedImage!.name;
      }

      if (!mounted) return;

      await ref
          .read(submitFeedbackActionProvider.notifier)
          .submit(
            type: _selectedType,
            title: title,
            description: description,
            deviceInfo: {'platform': platform},
            imageBytes: imageBytes,
            imageFileName: imageFileName,
          );

      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (context) => ActionSuccessDialog(
              title: 'Thank You',
              message: 'Submitted successfully. Under platform review.',
              buttonText: 'OK',
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
            ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    }
  }

  /// Hardcoded fallback — used while DB query is loading or on error.
  static const _fallbackTypes = [
    {'key': 'bug', 'value': 'Bug Report'},
    {'key': 'improvement', 'value': 'Improvement'},
    {'key': 'feature_request', 'value': 'Feature Request'},
    {'key': 'other', 'value': 'Other'},
  ];

  /// Builds ChoiceChips from database-driven feedback types.
  Widget _buildFeedbackTypeChips(dynamic colors) {
    final asyncDict = ref.watch(systemDictionaryProvider('feedback_type'));
    final items = asyncDict.when(
      data: (list) => list.isEmpty ? _fallbackTypes : list,
      loading: () => _fallbackTypes,
      error: (_, __) => _fallbackTypes,
    );

    return Wrap(
      spacing: 8,
      children: items.map((item) {
        final key = item['key']!;
        final label = item['value']!;
        final isSelected = _selectedType == key;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedType = key);
          },
          selectedColor: colors.primary.withAlpha(50),
          labelStyle: TextStyle(
            color: isSelected ? colors.primary : colors.onSurfaceVariant,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(submitFeedbackActionProvider).isLoading;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Report an Issue', style: typo.titleMedium),
        backgroundColor: colors.surface,
        elevation: 0,
      ),
      body: Center(
        child: ContentWidthConstraint(
          maxWidth: 640,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Feedback Type', style: typo.labelLarge),
                const SizedBox(height: 8),
                _buildFeedbackTypeChips(colors),
                const SizedBox(height: 24),
                Text('Title', style: typo.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Short summary',
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Description', style: typo.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText:
                        'Detailed explanation of the issue or suggestion...',
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Screenshot (Optional)', style: typo.labelLarge),
                const SizedBox(height: 8),
                if (_selectedImage != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            kIsWeb
                                ? Image.network(
                                  _selectedImage!.path,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                                : Image.file(
                                  File(_selectedImage!.path),
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.outlineVariant,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to select image',
                            style: typo.bodyMedium.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('Submit Feedback'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
