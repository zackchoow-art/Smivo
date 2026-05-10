import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_provider.dart';

part 'system_dictionary_provider.g.dart';

/// Generic provider that fetches dictionary items by [dictType] from the
/// `system_dictionaries` table.
///
/// Returns a list of `{key, value}` maps preserving display_order.
/// Uses SharedPreferences as an offline cache — on cache hit the provider
/// returns instantly and refreshes in the background, exactly like
/// [SystemUrls].
///
/// NOTE: keepAlive is intentionally false here (default). Each dict_type is
/// a separate family member, and we don't need all of them persisted for the
/// entire session — they're only needed while the relevant screen is mounted.
@riverpod
class SystemDictionary extends _$SystemDictionary {
  @override
  Future<List<Map<String, String>>> build(String dictType) async {
    final client = ref.watch(supabaseClientProvider);
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_dict_$dictType';

    final cachedStr = prefs.getString(cacheKey);
    if (cachedStr != null) {
      // Return cache immediately, sync in background.
      _syncInBackground(client, prefs, cacheKey, dictType);
      try {
        final List<dynamic> json = jsonDecode(cachedStr);
        return json
            .map(
              (e) => Map<String, String>.from(
                (e as Map).map(
                  (k, v) => MapEntry(k.toString(), v.toString()),
                ),
              ),
            )
            .toList();
      } catch (_) {
        // Cache corrupt — fall through to network fetch.
      }
    }

    final items = await _fetchFromSupabase(client, dictType);
    await prefs.setString(cacheKey, jsonEncode(items));
    return items;
  }

  Future<void> _syncInBackground(
    SupabaseClient client,
    SharedPreferences prefs,
    String cacheKey,
    String dictType,
  ) async {
    try {
      final items = await _fetchFromSupabase(client, dictType);
      await prefs.setString(cacheKey, jsonEncode(items));
      state = AsyncValue.data(items);
    } catch (e) {
      debugPrint('Background sync for dict "$dictType" failed: $e');
    }
  }

  Future<List<Map<String, String>>> _fetchFromSupabase(
    SupabaseClient client,
    String dictType,
  ) async {
    final data = await client
        .from('system_dictionaries')
        .select('dict_key, dict_value')
        .eq('dict_type', dictType)
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return (data as List)
        .map(
          (row) => {
            'key': row['dict_key'] as String,
            'value': row['dict_value'] as String,
          },
        )
        .toList();
  }
}
