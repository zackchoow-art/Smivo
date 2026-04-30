import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/core/utils/content_filter.dart';

part 'content_filter_provider.g.dart';

/// Downloads and caches the sensitive word list from Supabase.
///
/// keepAlive ensures the list stays in memory across the app lifecycle.
/// The provider loads words with severity='block' and is_active=true.
/// If the table is empty (no words imported yet), the filter passes all content.
@Riverpod(keepAlive: true)
class SensitiveWords extends _$SensitiveWords {
  @override
  Future<ContentFilter> build() async {
    final client = ref.watch(supabaseClientProvider);
    final data = await client
        .from('sensitive_words')
        .select('word')
        .eq('is_active', true)
        .eq('severity', 'block');

    final words = data.map((row) => row['word'] as String).toList();
    return ContentFilter(words);
  }
}
