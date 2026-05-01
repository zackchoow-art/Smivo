// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dictionary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all system dictionary entries, optionally filtered by type.

@ProviderFor(adminDictionaries)
final adminDictionariesProvider = AdminDictionariesFamily._();

/// Fetches all system dictionary entries, optionally filtered by type.

final class AdminDictionariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SystemDictionary>>,
          List<SystemDictionary>,
          FutureOr<List<SystemDictionary>>
        >
    with
        $FutureModifier<List<SystemDictionary>>,
        $FutureProvider<List<SystemDictionary>> {
  /// Fetches all system dictionary entries, optionally filtered by type.
  AdminDictionariesProvider._({
    required AdminDictionariesFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'adminDictionariesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminDictionariesHash();

  @override
  String toString() {
    return r'adminDictionariesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SystemDictionary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SystemDictionary>> create(Ref ref) {
    final argument = this.argument as String?;
    return adminDictionaries(ref, dictType: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminDictionariesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminDictionariesHash() => r'e944933d0126b22896cf3741948026b13c9240ce';

/// Fetches all system dictionary entries, optionally filtered by type.

final class AdminDictionariesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SystemDictionary>>, String?> {
  AdminDictionariesFamily._()
    : super(
        retry: null,
        name: r'adminDictionariesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches all system dictionary entries, optionally filtered by type.

  AdminDictionariesProvider call({String? dictType}) =>
      AdminDictionariesProvider._(argument: dictType, from: this);

  @override
  String toString() => r'adminDictionariesProvider';
}

/// Fetches distinct dict_type values for the filter dropdown.

@ProviderFor(adminDictTypes)
final adminDictTypesProvider = AdminDictTypesProvider._();

/// Fetches distinct dict_type values for the filter dropdown.

final class AdminDictTypesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Fetches distinct dict_type values for the filter dropdown.
  AdminDictTypesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminDictTypesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminDictTypesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return adminDictTypes(ref);
  }
}

String _$adminDictTypesHash() => r'b4921f2d9675ae6e0ba5012e23be88ec2afffcf3';
