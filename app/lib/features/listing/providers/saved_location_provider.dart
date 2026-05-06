import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smivo/data/repositories/saved_location_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'saved_location_provider.g.dart';

/// Provides the list of user's custom saved pickup addresses.
///
/// Used in Create/Edit Listing to populate the history dropdown when
/// the user selects "Other (Specify in Chat)".
@riverpod
class SavedLocations extends _$SavedLocations {
  @override
  Future<List<String>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final repo = ref.watch(savedLocationRepositoryProvider);
    return repo.fetchSavedLocations(user.id);
  }

  /// Saves a new custom address and refreshes the list.
  Future<void> save(String label) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final repo = ref.read(savedLocationRepositoryProvider);
    await repo.upsertLocation(user.id, label);
    ref.invalidateSelf();
  }

  /// Deletes a saved address by label and refreshes.
  Future<void> delete(String label) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final repo = ref.read(savedLocationRepositoryProvider);
    await repo.deleteSavedLocation(user.id, label);
    ref.invalidateSelf();
  }

  /// Renames [oldLabel] to [newLabel] and refreshes.
  Future<void> rename(String oldLabel, String newLabel) async {
    final trimmed = newLabel.trim();
    if (trimmed.isEmpty || trimmed == oldLabel) return;
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final repo = ref.read(savedLocationRepositoryProvider);
    await repo.renameLocation(user.id, oldLabel, trimmed);
    ref.invalidateSelf();
  }
}
