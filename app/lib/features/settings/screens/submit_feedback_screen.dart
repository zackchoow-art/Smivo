import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/settings/providers/feedback_provider.dart';

class SubmitFeedbackScreen extends ConsumerStatefulWidget {
  const SubmitFeedbackScreen({super.key});

  @override
  ConsumerState<SubmitFeedbackScreen> createState() => _SubmitFeedbackScreenState();
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
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
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

    try {
      Uint8List? imageBytes;
      String? imageFileName;
      
      if (_selectedImage != null) {
        imageBytes = await _selectedImage!.readAsBytes();
        imageFileName = _selectedImage!.name;
      }

      await ref.read(submitFeedbackActionProvider.notifier).submit(
        type: _selectedType,
        title: title,
        description: description,
        deviceInfo: {
          'platform': Theme.of(context).platform.toString(),
        },
        imageBytes: imageBytes,
        imageFileName: imageFileName,
      );
      
      if (!mounted || !context.mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thank You'),
          content: const Text('Your feedback has been submitted successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feedback Type', style: typo.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['bug', 'improvement', 'feature_request', 'other'].map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type.replaceAll('_', ' ').toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                  selectedColor: colors.primary.withAlpha(50),
                  labelStyle: TextStyle(
                    color: isSelected ? colors.primary : colors.onSurfaceVariant,
                  ),
                );
              }).toList(),
            ),
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
                hintText: 'Detailed explanation of the issue or suggestion...',
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
                    child: kIsWeb
                        ? Image.network(_selectedImage!.path, height: 120, width: double.infinity, fit: BoxFit.cover)
                        : Image.file(File(_selectedImage!.path), height: 120, width: double.infinity, fit: BoxFit.cover),
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
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
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
                    border: Border.all(color: colors.outlineVariant, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 32, color: colors.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text('Tap to select image', style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant)),
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
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
