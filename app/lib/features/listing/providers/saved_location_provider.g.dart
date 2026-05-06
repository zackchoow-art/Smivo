// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the list of user's custom saved pickup addresses.
///
/// Used in Create/Edit Listing to populate the history dropdown when
/// the user selects "Other (Specify in Chat)".

@ProviderFor(SavedLocations)
final savedLocationsProvider = SavedLocationsProvider._();

/// Provides the list of user's custom saved pickup addresses.
///
/// Used in Create/Edit Listing to populate the history dropdown when
/// the user selects "Other (Specify in Chat)".
final class SavedLocationsProvider
    extends $AsyncNotifierProvider<SavedLocations, List<String>> {
  /// Provides the list of user's custom saved pickup addresses.
  ///
  /// Used in Create/Edit Listing to populate the history dropdown when
  /// the user selects "Other (Specify in Chat)".
  SavedLocationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedLocationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedLocationsHash();

  @$internal
  @override
  SavedLocations create() => SavedLocations();
}

String _$savedLocationsHash() => r'22a11f075d6f76623488a2dded6482cbac6fa268';

/// Provides the list of user's custom saved pickup addresses.
///
/// Used in Create/Edit Listing to populate the history dropdown when
/// the user selects "Other (Specify in Chat)".

abstract class _$SavedLocations extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
