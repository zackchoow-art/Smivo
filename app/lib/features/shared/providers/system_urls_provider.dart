import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_provider.dart';

part 'system_urls_provider.g.dart';

const _urlCacheKey = 'cached_system_urls';

@Riverpod(keepAlive: true)
class SystemUrls extends _$SystemUrls {
  @override
  Future<Map<String, String>> build() async {
    final client = ref.watch(supabaseClientProvider);
    final prefs = await SharedPreferences.getInstance();

    final cachedStr = prefs.getString(_urlCacheKey);
    
    if (cachedStr != null) {
      _syncInBackground(client, prefs);
      try {
        final Map<String, dynamic> json = jsonDecode(cachedStr);
        return json.map((key, value) => MapEntry(key, value.toString()));
      } catch (_) {}
    }

    final urls = await _fetchFromSupabase(client);
    await prefs.setString(_urlCacheKey, jsonEncode(urls));
    return urls;
  }

  Future<void> _syncInBackground(SupabaseClient client, SharedPreferences prefs) async {
    try {
      final urls = await _fetchFromSupabase(client);
      await prefs.setString(_urlCacheKey, jsonEncode(urls));
      state = AsyncValue.data(urls);
    } catch (e) {
      debugPrint('Background sync for system URLs failed: $e');
    }
  }

  Future<Map<String, String>> _fetchFromSupabase(SupabaseClient client) async {
    final data = await client
        .from('system_dictionaries')
        .select('dict_key, dict_value')
        .eq('dict_type', 'system_url')
        .eq('is_active', true);

    final map = <String, String>{};
    for (final row in data) {
      map[row['dict_key'] as String] = row['dict_value'] as String;
    }
    return map;
  }
}
