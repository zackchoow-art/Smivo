import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/core/utils/image_moderation_service.dart';

part 'storage_repository.g.dart';

/// Handles file upload/delete operations via Supabase Storage.
///
/// NOTE: All upload methods call [ImageModerationService.moderateAsync]
/// after a successful upload. This is fire-and-forget — the business flow
/// is never blocked or terminated due to moderation.
class StorageRepository {
  const StorageRepository(this._client, this._moderation);

  final SupabaseClient _client;
  final ImageModerationService _moderation;

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
      final url = _client.storage
          .from(AppConstants.bucketListingImages)
          .getPublicUrl(path);

      // Non-blocking AI moderation — never awaited in the calling flow.
      unawaited(
        _moderation.moderateAsync(
          imageUrl: url,
          targetType: 'listing_image',
          targetId: listingId,
          userId: userId,
        ),
      );

      return url;
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
      // NOTE: Avatar images are not moderated — they go through the DiceBear
      // avatar picker which uses generated SVGs, not user-uploaded content.
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
    String? userId,
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
      final url = _client.storage
          .from(AppConstants.bucketOrderFiles)
          .getPublicUrl(basePath);

      // Moderate chat images if we have a user ID.
      if (userId != null) {
        unawaited(
          _moderation.moderateAsync(
            imageUrl: url,
            targetType: 'chat_image',
            targetId: orderId ?? chatRoomId,
            userId: userId,
          ),
        );
      }

      return url;
    } on StorageException catch (e) {
      throw AppStorageException(e.message, e);
    }
  }

  /// Uploads order evidence photo and returns its public URL.
  Future<String> uploadEvidenceImage({
    required String orderId,
    required String fileName,
    required Uint8List fileBytes,
    required String userId,
  }) async {
    try {
      final path = '$orderId/evidence/$fileName';
      await _client.storage
          .from(AppConstants.bucketOrderFiles)
          .uploadBinary(path, fileBytes);
      final url = _client.storage
          .from(AppConstants.bucketOrderFiles)
          .getPublicUrl(path);

      unawaited(
        _moderation.moderateAsync(
          imageUrl: url,
          targetType: 'evidence',
          targetId: orderId,
          userId: userId,
        ),
      );

      return url;
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

  /// Uploads a feedback screenshot and returns its public URL.
  Future<String> uploadFeedbackImage({
    required String userId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      final path = 'feedbacks/$userId/$fileName';
      await _client.storage
          .from(AppConstants.bucketOrderFiles)
          .uploadBinary(path, fileBytes);
      final url = _client.storage
          .from(AppConstants.bucketOrderFiles)
          .getPublicUrl(path);

      unawaited(
        _moderation.moderateAsync(
          imageUrl: url,
          targetType: 'feedback',
          targetId: userId,
          userId: userId,
        ),
      );

      return url;
    } on StorageException catch (e) {
      throw AppStorageException(e.message, e);
    }
  }
}

@riverpod
StorageRepository storageRepository(Ref ref) => StorageRepository(
  ref.watch(supabaseClientProvider),
  ImageModerationService(ref.watch(supabaseClientProvider)),
);
