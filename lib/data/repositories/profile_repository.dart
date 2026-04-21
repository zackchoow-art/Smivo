import 'dart:io';
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
      final data = await _client
          .from('user_profiles')
          .update(profile.toJson())
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
}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  // Assuming supabaseClientProvider exists in core/
  // If not, we will need to define it or use the global instance for now.
  // Based on architecture rules, it should be provided.
  // I will check lib/core/providers/supabase_provider.dart if it exists.
  return ProfileRepository(supabase.Supabase.instance.client);
}
