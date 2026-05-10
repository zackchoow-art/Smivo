// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_dictionary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(SystemDictionary)
final systemDictionaryProvider = SystemDictionaryFamily._();

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
final class SystemDictionaryProvider
    extends
        $AsyncNotifierProvider<SystemDictionary, List<Map<String, String>>> {
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
  SystemDictionaryProvider._({
    required SystemDictionaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'systemDictionaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$systemDictionaryHash();

  @override
  String toString() {
    return r'systemDictionaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SystemDictionary create() => SystemDictionary();

  @override
  bool operator ==(Object other) {
    return other is SystemDictionaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$systemDictionaryHash() => r'8c4fa0dad0a6219856e01944ea31308ab1c8f684';

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

final class SystemDictionaryFamily extends $Family
    with
        $ClassFamilyOverride<
          SystemDictionary,
          AsyncValue<List<Map<String, String>>>,
          List<Map<String, String>>,
          FutureOr<List<Map<String, String>>>,
          String
        > {
  SystemDictionaryFamily._()
    : super(
        retry: null,
        name: r'systemDictionaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  SystemDictionaryProvider call(String dictType) =>
      SystemDictionaryProvider._(argument: dictType, from: this);

  @override
  String toString() => r'systemDictionaryProvider';
}

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

abstract class _$SystemDictionary
    extends $AsyncNotifier<List<Map<String, String>>> {
  late final _$args = ref.$arg as String;
  String get dictType => _$args;

  FutureOr<List<Map<String, String>>> build(String dictType);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<Map<String, String>>>,
              List<Map<String, String>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<Map<String, String>>>,
                List<Map<String, String>>
              >,
              AsyncValue<List<Map<String, String>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
