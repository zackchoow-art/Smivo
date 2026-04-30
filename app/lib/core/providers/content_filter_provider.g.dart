// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sensitiveWordsHash() => r'0443ca5bcba5d63f7394b54ba80f9176c561769c';

/// Downloads and caches the sensitive word list from Supabase.
///
/// keepAlive ensures the list stays in memory across the app lifecycle.
/// The provider loads words with severity='block' and is_active=true.
/// If the table is empty (no words imported yet), the filter passes all content.
///
/// Copied from [SensitiveWords].
@ProviderFor(SensitiveWords)
final sensitiveWordsProvider =
    AsyncNotifierProvider<SensitiveWords, ContentFilter>.internal(
      SensitiveWords.new,
      name: r'sensitiveWordsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$sensitiveWordsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SensitiveWords = AsyncNotifier<ContentFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
