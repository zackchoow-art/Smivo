import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/utils/image_upload_service.dart';

part 'create_listing_provider.g.dart';

// State for the form mode ('sale' or 'rent')
@riverpod
class ListingFormMode extends _$ListingFormMode {
  @override
  String build({required String initialMode}) {
    return initialMode;
  }

  void setMode(String mode) {
    state = mode;
  }
}

// State for the selected cropped photos (max 5)
@riverpod
class ListingPhotos extends _$ListingPhotos {
  @override
  List<String> build() => [];

  Future<void> addPhoto(BuildContext context) async {
    if (state.length >= 5) return;

    final service = ImageUploadService();
    final path = await service.pickAndCropImage(context);

    if (path != null) {
      state = [...state, path];
    }
  }

  void removePhoto(int index) {
    final newState = List<String>.from(state);
    newState.removeAt(index);
    state = newState;
  }
}

// State for Category Selection
@riverpod
class SelectedListingCategory extends _$SelectedListingCategory {
  @override
  String? build() => null;

  void setCategory(String category) {
    state = category;
  }
}
