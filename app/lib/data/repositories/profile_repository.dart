import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final supabase.SupabaseClient _client;

  ProfileRepository(this._client);

  /// Fetch a user profile by ID.
  ///
  /// Returns null if no profile row exists (e.g. user was
  /// created outside the normal signup trigger flow).
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final data =
          await _client
              .from('user_profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      if (data == null) return null;
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

  /// Create a new profile for a user that bypassed the DB trigger.
  ///
  /// Looks up the school_id from the user's email domain.
  /// Falls back to the first active school if no domain match.
  Future<UserProfile> createProfileForUser({
    required String userId,
    required String email,
  }) async {
    try {
      final domain = email.split('@').last;

      // Look up school by email domain
      final schoolRow =
          await _client
              .from('schools')
              .select('id')
              .eq('email_domain', domain)
              .eq('is_active', true)
              .maybeSingle();

      String? schoolId = schoolRow?['id'] as String?;

      // Fallback: use first active school
      if (schoolId == null) {
        final fallback =
            await _client
                .from('schools')
                .select('id')
                .eq('is_active', true)
                .limit(1)
                .maybeSingle();
        schoolId = fallback?['id'] as String?;
      }

      if (schoolId == null) {
        throw AppException.database(
          'No active school found for domain: $domain',
        );
      }

      final data =
          await _client
              .from('user_profiles')
              .insert({'id': userId, 'email': email, 'school_id': schoolId})
              .select()
              .single();

      return UserProfile.fromJson(data);
    } on supabase.PostgrestException catch (e) {
      throw AppException.database('Failed to create profile: ${e.message}', e);
    } catch (e) {
      throw AppException.unknown(
        'An unexpected error occurred while creating profile',
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
      final data =
          await _client
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
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName; // Bucket RLS allows any path for auth users

      await _client.storage
          .from('avatars')
          .upload(
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
      await _client.storage
          .from('avatars')
          .uploadBinary(
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

  /// Stores the OneSignal player ID for push notification targeting.
  Future<void> updatePushToken({
    required String userId,
    required String playerId,
  }) async {
    try {
      await _client
          .from('user_profiles')
          .update({'onesignal_player_id': playerId})
          .eq('id', userId);
    } on supabase.PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Updates notification preferences for the user.
  Future<void> updateNotificationPreferences({
    required String userId,
    required bool emailNotificationsEnabled,
    required bool pushNotificationsEnabled,
    required bool pushMessages,
    required bool emailMessages,
    required bool pushOrderUpdates,
    required bool emailOrderUpdates,
    required bool pushCampusAnnouncements,
    required bool emailCampusAnnouncements,
    required bool pushAnnouncements,
    required bool emailAnnouncements,
  }) async {
    try {
      await _client
          .from('user_profiles')
          .update({
            'email_notifications_enabled': emailNotificationsEnabled,
            'push_notifications_enabled': pushNotificationsEnabled,
            'push_messages': pushMessages,
            'email_messages': emailMessages,
            'push_order_updates': pushOrderUpdates,
            'email_order_updates': emailOrderUpdates,
            'push_campus_announcements': pushCampusAnnouncements,
            'email_campus_announcements': emailCampusAnnouncements,
            'push_announcements': pushAnnouncements,
            'email_announcements': emailAnnouncements,
          })
          .eq('id', userId);
    } on supabase.PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Upserts heartbeat for online status tracking.
  /// Uses ON CONFLICT to keep the table at one row per user.
  Future<void> sendHeartbeat({
    required String userId,
    String? appVersion,
    String? platform,
  }) async {
    await _client.from('user_heartbeats').upsert({
      'user_id': userId,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      'app_version': appVersion,
      'platform': platform,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  /// Fetches last_active_at for a specific user.
  Future<DateTime?> getLastActiveAt(String userId) async {
    final data = await _client
        .from('user_heartbeats')
        .select('last_seen_at')
        .eq('user_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return DateTime.tryParse(data['last_seen_at'] as String);
  }

  /// Checks if the user currently has an active ban within the given scopes.
  /// Returns the expiration date of the ban if active, otherwise null.
  Future<DateTime?> getActiveBan(String userId, List<String> scopes) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final data = await _client
          .from('user_bans')
          .select('expires_at')
          .eq('user_id', userId)
          .inFilter('scope', scopes)
          .isFilter('lifted_at', null)
          .or('expires_at.is.null,expires_at.gt.$now')
          .order('banned_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      if (data['expires_at'] == null) {
        // Permanent ban, return a far future date to represent 'permanent'
        return DateTime(2099, 12, 31);
      }
      return DateTime.tryParse(data['expires_at'] as String);
    } catch (e) {
      debugPrint('Failed to check listing ban: $e');
      return null;
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
