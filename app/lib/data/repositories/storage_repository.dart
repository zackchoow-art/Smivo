import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

part 'storage_repository.g.dart';

/// Handles file upload/delete operations via Supabase Storage.
class StorageRepository {
  const StorageRepository(this._client);

  final SupabaseClient _client;

  /// Uploads a listing image and returns its public URL.
  Future<String> uploadListingImage({
    required String userId,
    required String listingId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      final path = '$userId/$listingId/$fileName';
      await _client.storage
          .from(AppConstants.bucketListingImages)
          .uploadBinary(path, fileBytes);
      return _client.storage
          .from(AppConstants.bucketListingImages)
          .getPublicUrl(path);
    } on StorageException catch (e) {
      throw AppStorageException(e.message, e);
    }
  }

  /// Uploads a user avatar and returns its public URL.
  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      final path = 'avatars/$userId/$fileName';
      await _client.storage
          .from(AppConstants.bucketAvatars)
          .uploadBinary(path, fileBytes);
      return _client.storage
          .from(AppConstants.bucketAvatars)
          .getPublicUrl(path);
    } on StorageException catch (e) {
      throw AppStorageException(e.message, e);
    }
  }

  /// Uploads a chat message image and returns its public URL.
  ///
  /// If orderId is available, stores under order folder.
  /// Falls back to chatRoomId subfolder if no order exists yet.
  Future<String> uploadChatMessageImage({
    required String chatRoomId,
    required String fileName,
    required Uint8List fileBytes,
    String? orderId,
  }) async {
    try {
      // Prefer order-based path; fall back to chat room path
      final basePath =
          orderId != null
              ? '$orderId/chat/$fileName'
              : 'unlinked/$chatRoomId/$fileName';
      await _client.storage
          .from(AppConstants.bucketOrderFiles)
          .uploadBinary(basePath, fileBytes);
      return _client.storage
          .from(AppConstants.bucketOrderFiles)
          .getPublicUrl(basePath);
    } on StorageException catch (e) {
      throw AppStorageException(e.message, e);
    }
  }

  /// Deletes a file from a bucket.
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } on StorageException catch (e) {
      throw AppStorageException(e.message, e);
    }
  }
}

@riverpod
StorageRepository storageRepository(Ref ref) =>
    StorageRepository(ref.watch(supabaseClientProvider));
