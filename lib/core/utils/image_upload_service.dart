import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:smivo/core/theme/app_colors.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickAndCropImage(BuildContext context, {bool isAvatar = false}) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      // TEMPORARY BYPASS: skip cropping while debugging cropper layout issue
      // TODO: Re-enable ImageCropper.cropImage once we fix the render box error
      return image;

      /*
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: isAvatar ? CropAspectRatioPreset.square : CropAspectRatioPreset.original,
            lockAspectRatio: isAvatar,
          ),
          IOSUiSettings(
            title: 'Crop Image',
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
      */
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

  Future<XFile?> takePhotoAndCrop(BuildContext context, {bool isAvatar = false}) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return null;

      // TEMPORARY BYPASS: skip cropping while debugging cropper layout issue
      // TODO: Re-enable ImageCropper.cropImage once we fix the render box error
      return image;

      /*
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: isAvatar ? CropAspectRatioPreset.square : CropAspectRatioPreset.original,
            lockAspectRatio: isAvatar,
          ),
          IOSUiSettings(
            title: 'Crop Image',
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
      */
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
}
