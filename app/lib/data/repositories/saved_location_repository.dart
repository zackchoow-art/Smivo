import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

part 'saved_location_repository.g.dart';

/// Repository for managing user's saved custom pickup addresses.
///
/// Wraps the `user_saved_locations` table. The RPC
/// `upsert_user_saved_location` handles create-or-increment logic.
class SavedLocationRepository {
  const SavedLocationRepository(this._client);

  final SupabaseClient _client;

  /// Fetches saved locations for [userId], ordered by most-recently used.
  Future<List<String>> fetchSavedLocations(String userId) async {
    try {
      final rows = await _client
          .from('user_saved_locations')
          .select('label')
          .eq('user_id', userId)
          .order('last_used_at', ascending: false)
          .limit(20);
      return (rows as List).map((r) => r['label'] as String).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Saves or increments the use count for a custom address label.
  /// Returns the row ID.
  Future<String> upsertLocation(String userId, String label) async {
    try {
      final result = await _client.rpc(
        'upsert_user_saved_location',
        params: {'p_user_id': userId, 'p_label': label},
      );
      return result as String;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Deletes a saved location by its exact label for [userId].
  Future<void> deleteSavedLocation(String userId, String label) async {
    try {
      await _client
          .from('user_saved_locations')
          .delete()
          .eq('user_id', userId)
          .eq('label', label);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Renames a saved location from [oldLabel] to [newLabel].
  /// No-op if [newLabel] is identical to [oldLabel].
  Future<void> renameLocation(
    String userId,
    String oldLabel,
    String newLabel,
  ) async {
    if (oldLabel == newLabel) return;
    try {
      await _client
          .from('user_saved_locations')
          .update({
            'label': newLabel,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('label', oldLabel);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
SavedLocationRepository savedLocationRepository(Ref ref) =>
    SavedLocationRepository(ref.watch(supabaseClientProvider));
