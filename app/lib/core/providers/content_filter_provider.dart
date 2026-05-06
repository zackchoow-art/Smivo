import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/core/utils/content_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'content_filter_provider.g.dart';

const _blockCacheKey = 'cached_block_words';
const _warnCacheKey = 'cached_warn_words';
const _configCacheKey = 'cached_filter_config';

class FilterConfig {
  final bool enabled;
  final String warnAction;
  final String blockAction;
  // Custom message shown to the sender when warn-severity words are detected.
  // Loaded from system_configs key 'content_filter.warn_message'.
  final String warnMessage;

  const FilterConfig({
    required this.enabled,
    required this.warnAction,
    required this.blockAction,
    required this.warnMessage,
  });

  factory FilterConfig.fromJson(Map<String, dynamic> json) {
    // config values are stored as JSON strings in DB, so 'true' or '"show_warning"'
    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is String) return val == 'true';
      return true;
    }

    String parseStr(dynamic val) {
      if (val is String) return val.replaceAll('"', '');
      return val?.toString() ?? '';
    }

    return FilterConfig(
      enabled:
          json['content_filter.enabled'] != null
              ? parseBool(json['content_filter.enabled'])
              : true,
      warnAction:
          json['content_filter.warn_action'] != null
              ? parseStr(json['content_filter.warn_action'])
              : 'show_warning',
      blockAction:
          json['content_filter.block_action'] != null
              ? parseStr(json['content_filter.block_action'])
              : 'reject',
      // Fallback to a safe default if the config key has not been seeded yet.
      warnMessage:
          json['content_filter.warn_message'] != null
              ? parseStr(json['content_filter.warn_message'])
              : 'Please keep the conversation respectful. Messages with inappropriate language may be reported.',
    );
  }

  Map<String, dynamic> toJson() => {
    'content_filter.enabled': enabled,
    'content_filter.warn_action': warnAction,
    'content_filter.block_action': blockAction,
    'content_filter.warn_message': warnMessage,
  };
}

class FilterAction {
  final String processedText;
  final List<String> warnings;
  const FilterAction(this.processedText, this.warnings);
}

/// Applies content filter based on system configurations.
/// Returns a [FilterAction] containing processed text and warnings.
/// Throws an Exception if the content is completely blocked/rejected.
FilterAction applyContentFilter(
  String text,
  ContentFilter filter,
  FilterConfig config,
) {
  if (!config.enabled) return FilterAction(text, <String>[]);

  final result = filter.check(text);
  var processedText = text;
  final warnings = <String>[];

  if (result.hasBlock) {
    switch (config.blockAction) {
      case 'reject':
        throw Exception(
          'Your content contains restricted words and cannot be submitted.',
        );
      case 'mask':
        processedText = filter.mask(text);
        warnings.add(
          'Potential violation detected. Some content has been masked.',
        );
        break;
      case 'warn_only':
        warnings.add(
          'Warning: Your content may be reported for inappropriate language.',
        );
        break;
    }
  }

  // Surface the configured warn message to the caller so the UI can
  // display it as a SnackBar after the message is sent successfully.
  if (result.hasWarn && config.warnAction == 'show_warning') {
    warnings.add(config.warnMessage);
  }

  return FilterAction(processedText, warnings);
}

class _WordsResult {
  final List<String> blockWords;
  final List<String> warnWords;
  const _WordsResult(this.blockWords, this.warnWords);
}

@Riverpod(keepAlive: true)
class SensitiveWords extends _$SensitiveWords {
  @override
  Future<ContentFilter> build() async {
    final client = ref.watch(supabaseClientProvider);
    final prefs = await SharedPreferences.getInstance();

    final cachedBlock = prefs.getStringList(_blockCacheKey);
    final cachedWarn = prefs.getStringList(_warnCacheKey);

    if (cachedBlock != null && cachedBlock.isNotEmpty) {
      _syncInBackground(client, prefs);
      return ContentFilter(
        blockWords: cachedBlock,
        warnWords: cachedWarn ?? [],
      );
    }

    final words = await _fetchWordsFromSupabase(client);
    await prefs.setStringList(_blockCacheKey, words.blockWords);
    await prefs.setStringList(_warnCacheKey, words.warnWords);
    return ContentFilter(
      blockWords: words.blockWords,
      warnWords: words.warnWords,
    );
  }

  Future<void> _syncInBackground(
    SupabaseClient client,
    SharedPreferences prefs,
  ) async {
    try {
      final words = await _fetchWordsFromSupabase(client);
      await prefs.setStringList(_blockCacheKey, words.blockWords);
      await prefs.setStringList(_warnCacheKey, words.warnWords);
      state = AsyncValue.data(
        ContentFilter(blockWords: words.blockWords, warnWords: words.warnWords),
      );
    } catch (e) {
      debugPrint('Background sync for sensitive words failed: $e');
    }
  }

  Future<_WordsResult> _fetchWordsFromSupabase(SupabaseClient client) async {
    final data = await client
        .from('sensitive_words')
        .select('word, severity')
        .eq('is_active', true);

    final blockWords = <String>[];
    final warnWords = <String>[];

    for (final row in data) {
      final word = row['word'] as String;
      final severity = row['severity'] as String;
      if (severity == 'block') {
        blockWords.add(word);
      } else {
        warnWords.add(word);
      }
    }

    return _WordsResult(blockWords, warnWords);
  }
}

@Riverpod(keepAlive: true)
class FilterConfigState extends _$FilterConfigState {
  @override
  Future<FilterConfig> build() async {
    final client = ref.watch(supabaseClientProvider);
    final prefs = await SharedPreferences.getInstance();

    final cachedConfigStr = prefs.getString(_configCacheKey);

    if (cachedConfigStr != null) {
      _syncConfigInBackground(client, prefs);
      try {
        final json = jsonDecode(cachedConfigStr) as Map<String, dynamic>;
        return FilterConfig.fromJson(json);
      } catch (_) {}
    }

    final configMap = await _fetchConfigFromSupabase(client);
    final config = FilterConfig.fromJson(configMap);
    await prefs.setString(_configCacheKey, jsonEncode(config.toJson()));
    return config;
  }

  Future<void> _syncConfigInBackground(
    SupabaseClient client,
    SharedPreferences prefs,
  ) async {
    try {
      final configMap = await _fetchConfigFromSupabase(client);
      final config = FilterConfig.fromJson(configMap);
      await prefs.setString(_configCacheKey, jsonEncode(config.toJson()));
      state = AsyncValue.data(config);
    } catch (e) {
      debugPrint('Background sync for filter config failed: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchConfigFromSupabase(
    SupabaseClient client,
  ) async {
    final data = await client
        .from('system_configs')
        .select('config_key, config_value')
        .like('config_key', 'content_filter.%');

    final map = <String, dynamic>{};
    for (final row in data) {
      map[row['config_key'] as String] = row['config_value'];
    }
    return map;
  }
}
