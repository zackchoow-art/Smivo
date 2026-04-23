# Task 007: Restore Image Cropper — Web + Mobile

## Objective
Re-enable the image_cropper functionality that was temporarily bypassed.
The cropper.js is already configured in web/index.html.
The image_cropper package (^12.2.1) is already in pubspec.yaml.

## STRICT SCOPE — Only modify this file:
1. `lib/core/utils/image_upload_service.dart`

**DO NOT** modify any other files.

---

## Step 1: Rewrite the entire file

Replace the entire contents of `lib/core/utils/image_upload_service.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smivo/core/theme/app_colors.dart';

/// Handles image picking and cropping for both mobile and web platforms.
///
/// Uses image_picker for selection and image_cropper (backed by cropper.js
/// on web, uCrop on Android, TOCropViewController on iOS) for cropping.
class ImageUploadService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery and crop it.
  Future<XFile?> pickAndCropImage(
    BuildContext context, {
    bool isAvatar = false,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image == null) return null;

      return _cropImage(context, image.path, isAvatar: isAvatar);
    } catch (e) {
      debugPrint('Error picking/cropping image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process image.')),
        );
      }
      return null;
    }
  }

  /// Take a photo with camera and crop it.
  Future<XFile?> takePhotoAndCrop(
    BuildContext context, {
    bool isAvatar = false,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image == null) return null;

      return _cropImage(context, image.path, isAvatar: isAvatar);
    } catch (e) {
      debugPrint('Error taking/cropping photo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process photo.')),
        );
      }
      return null;
    }
  }

  /// Internal: crop the image at [sourcePath].
  ///
  /// Configures platform-specific UI:
  /// - Android: uCrop with Material toolbar
  /// - iOS: TOCropViewController
  /// - Web: cropper.js in a dialog
  Future<XFile?> _cropImage(
    BuildContext context,
    String sourcePath, {
    required bool isAvatar,
  }) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      // NOTE: For avatars, force square aspect ratio.
      // For listing photos, let the user choose freely.
      aspectRatio: isAvatar
          ? const CropAspectRatio(ratioX: 1, ratioY: 1)
          : null,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isAvatar ? 'Crop Avatar' : 'Crop Photo',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: isAvatar
              ? CropAspectRatioPreset.square
              : CropAspectRatioPreset.original,
          lockAspectRatio: isAvatar,
        ),
        IOSUiSettings(
          title: isAvatar ? 'Crop Avatar' : 'Crop Photo',
          aspectRatioLockEnabled: isAvatar,
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(width: 520, height: 520),
        ),
      ],
    );

    if (croppedFile != null) {
      return XFile(croppedFile.path);
    }
    return null;
  }
}
```

## Step 2: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-007.md`.
