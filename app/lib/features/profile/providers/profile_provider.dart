import 'dart:io';
import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/data/repositories/profile_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/core/providers/content_filter_provider.dart';

part 'profile_provider.g.dart';

@riverpod
class Profile extends _$Profile {
  @override
  FutureOr<UserProfile?> build() async {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    if (user == null) return null;

    final repo = ref.read(profileRepositoryProvider);
    final existing = await repo.getProfile(user.id);

    if (existing != null) return existing;

    // NOTE: Profile row missing — user was likely created outside
    // the normal signup flow (e.g. via Supabase Dashboard).
    // Auto-create with school derived from email domain.
    if (user.email != null) {
      return repo.createProfileForUser(userId: user.id, email: user.email!);
    }

    return null;
  }

  /// Update the current user's display name
  Future<void> updateDisplayName(String name) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(sensitiveWordsProvider).value;
      final config = ref.read(filterConfigStateProvider).value;

      var finalName = name.trim();

      if (filter != null && config != null) {
        final action = applyContentFilter(finalName, filter, config);
        finalName = action.processedText;
      }

      final updated = currentProfile.copyWith(displayName: finalName);
      return ref.read(profileRepositoryProvider).updateProfile(updated);
    });
  }

  /// Upload and update the user's avatar
  Future<void> updateAvatar(File file) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final avatarUrl = await ref
          .read(profileRepositoryProvider)
          .uploadAvatar(currentProfile.id, file);

      final updated = currentProfile.copyWith(avatarUrl: avatarUrl);
      return ref.read(profileRepositoryProvider).updateProfile(updated);
    });
  }

  /// Update the user's avatar from a URL (e.g. Open Peeps)
  Future<void> updateAvatarUrl(String url) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = currentProfile.copyWith(avatarUrl: url);
      return ref.read(profileRepositoryProvider).updateProfile(updated);
    });
  }

  /// Upload and update the user's avatar from raw bytes (Web-compatible).
  ///
  /// Uses [uploadAvatarBytes] from the repository which accepts [Uint8List]
  /// instead of [File], making this method safe to call on all platforms.
  Future<void> updateAvatarFromBytes(Uint8List bytes, String fileName) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final avatarUrl = await ref
          .read(profileRepositoryProvider)
          .uploadAvatarBytes(currentProfile.id, bytes, fileName);

      final updated = currentProfile.copyWith(avatarUrl: avatarUrl);
      return ref.read(profileRepositoryProvider).updateProfile(updated);
    });
  }

  /// Complete the onboarding process
  Future<void> completeProfileSetup({
    required String displayName,
    File? avatarFile,
  }) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      String? avatarUrl = currentProfile.avatarUrl;

      if (avatarFile != null) {
        avatarUrl = await ref
            .read(profileRepositoryProvider)
            .uploadAvatar(currentProfile.id, avatarFile);
      }

      final filter = ref.read(sensitiveWordsProvider).value;
      final config = ref.read(filterConfigStateProvider).value;

      var finalName = displayName.trim();

      if (filter != null && config != null) {
        final action = applyContentFilter(finalName, filter, config);
        finalName = action.processedText;
      }

      final updated = currentProfile.copyWith(
        displayName: finalName,
        avatarUrl: avatarUrl,
      );

      return ref.read(profileRepositoryProvider).updateProfile(updated);
    });
  }
}
