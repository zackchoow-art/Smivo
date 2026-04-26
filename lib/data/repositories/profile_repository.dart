import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final supabase.SupabaseClient _client;

  ProfileRepository(this._client);

  /// Fetch a user profile by ID
  Future<UserProfile> getProfile(String userId) async {
    try {
      final data = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return UserProfile.fromJson(data);
    } on supabase.PostgrestException catch (e) {
      throw AppException.database('Failed to fetch profile: ${e.message}', e);
    } catch (e) {
      throw AppException.unknown(
        'An unexpected error occurred while fetching profile',
        e,
      );
    }
  }

  /// Update an existing profile
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      // NOTE: Only send mutable columns — exclude virtual joins (schoolData),
      // readonly fields (id, email, createdAt), and server-managed timestamps.
      final updateData = {
        'display_name': profile.displayName,
        'avatar_url': profile.avatarUrl,
        'school': profile.school,
        'school_id': profile.schoolId,
        'is_verified': profile.isVerified,
        'email_notifications_enabled': profile.emailNotificationsEnabled,
      };
      final data = await _client
          .from('user_profiles')
          .update(updateData)
          .eq('id', profile.id)
          .select()
          .single();
      
      return UserProfile.fromJson(data);
    } on supabase.PostgrestException catch (e) {
      throw AppException.database('Failed to update profile: ${e.message}', e);
    } catch (e) {
      throw AppException.unknown(
        'An unexpected error occurred while updating profile',
        e,
      );
    }
  }

  /// Upload an avatar image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadAvatar(String userId, File file) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName; // Bucket RLS allows any path for auth users

      await _client.storage.from('avatars').upload(
            filePath,
            file,
            fileOptions: const supabase.FileOptions(upsert: true),
          );

      return _client.storage.from('avatars').getPublicUrl(filePath);
    } on supabase.StorageException catch (e) {
      throw AppException.storage('Failed to upload avatar: ${e.message}', e);
    } catch (e) {
      throw AppException.unknown(
        'An unexpected error occurred while uploading avatar',
        e,
      );
    }
  }

  /// Upload an avatar from raw bytes (cross-platform, works on Web).
  ///
  /// Unlike [uploadAvatar] which requires a [File] object (dart:io),
  /// this method accepts [Uint8List] bytes directly, making it usable
  /// on Web where dart:io is unavailable.
  Future<String> uploadAvatarBytes(
    String userId,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final filePath =
          '$userId-${DateTime.now().millisecondsSinceEpoch}-$fileName';
      await _client.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: const supabase.FileOptions(upsert: true),
          );
      return _client.storage.from('avatars').getPublicUrl(filePath);
    } on supabase.StorageException catch (e) {
      throw AppException.storage('Failed to upload avatar: ${e.message}', e);
    } catch (e) {
      throw AppException.unknown(
        'An unexpected error occurred while uploading avatar bytes',
        e,
      );
    }
  }

  /// Updates the user's email notification preference.
  ///
  /// Isolated update — only touches the email_notifications_enabled column
  /// to avoid accidentally overwriting other profile data.
  Future<void> updateEmailNotificationPref({
    required String userId,
    required bool enabled,
  }) async {
    try {
      await _client
          .from('user_profiles')
          .update({'email_notifications_enabled': enabled})
          .eq('id', userId);
    } on supabase.PostgrestException catch (e) {
      throw AppException.database('Failed to update email pref: ${e.message}', e);
    }
  }
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  // Assuming supabaseClientProvider exists in core/
  // If not, we will need to define it or use the global instance for now.
  // Based on architecture rules, it should be provided.
  // I will check lib/core/providers/supabase_provider.dart if it exists.
  return ProfileRepository(supabase.Supabase.instance.client);
}
