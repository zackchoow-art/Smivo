import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/core/utils/content_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'content_filter_provider.g.dart';

const _cacheKey = 'cached_sensitive_words';

/// Downloads and caches the sensitive word list from Supabase.
///
/// keepAlive ensures the list stays in memory across the app lifecycle.
/// The provider first loads from SharedPreferences for instant startup,
/// then silently syncs the latest words from Supabase in the background.
@Riverpod(keepAlive: true)
class SensitiveWords extends _$SensitiveWords {
  @override
  Future<ContentFilter> build() async {
    final client = ref.watch(supabaseClientProvider);
    final prefs = await SharedPreferences.getInstance();

    final cachedWords = prefs.getStringList(_cacheKey);
    
    // If we have cached words, return them instantly for fast startup,
    // and trigger a background sync to update the cache.
    if (cachedWords != null && cachedWords.isNotEmpty) {
      _syncInBackground(client, prefs);
      return ContentFilter(cachedWords);
    }

    // No cache yet (first launch), await the network fetch
    final words = await _fetchFromSupabase(client);
    await prefs.setStringList(_cacheKey, words);
    return ContentFilter(words);
  }

  Future<void> _syncInBackground(SupabaseClient client, SharedPreferences prefs) async {
    try {
      final words = await _fetchFromSupabase(client);
      await prefs.setStringList(_cacheKey, words);
      // Update Riverpod state with the fresh list
      state = AsyncValue.data(ContentFilter(words));
    } catch (e) {
      debugPrint('Background sync for sensitive words failed: $e');
    }
  }

  Future<List<String>> _fetchFromSupabase(SupabaseClient client) async {
    final data = await client
        .from('sensitive_words')
        .select('word')
        .eq('is_active', true)
        .eq('severity', 'block');

    return data.map((row) => row['word'] as String).toList();
  }
}
