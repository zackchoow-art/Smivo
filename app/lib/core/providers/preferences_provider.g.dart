// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the SharedPreferences instance.
///
/// NOTE: keepAlive: true ensures the instance is only created once per app
/// launch and is never garbage-collected. AsyncNotifier is used because
/// SharedPreferences.getInstance() is async.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provides the SharedPreferences instance.
///
/// NOTE: keepAlive: true ensures the instance is only created once per app
/// launch and is never garbage-collected. AsyncNotifier is used because
/// SharedPreferences.getInstance() is async.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// Provides the SharedPreferences instance.
  ///
  /// NOTE: keepAlive: true ensures the instance is only created once per app
  /// launch and is never garbage-collected. AsyncNotifier is used because
  /// SharedPreferences.getInstance() is async.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'50d46e3f8d9f32715d0f3efabdce724e4b2593b4';

/// Persists and retrieves the last pickup location the user selected.
///
/// This is used in [CreateListingFormScreen] to pre-select the previous
/// pickup location when opening the form, improving UX for repeat sellers.
///
/// NOTE: keepAlive: true so the value survives tab switches and navigations.

@ProviderFor(LastPickupLocationId)
final lastPickupLocationIdProvider = LastPickupLocationIdProvider._();

/// Persists and retrieves the last pickup location the user selected.
///
/// This is used in [CreateListingFormScreen] to pre-select the previous
/// pickup location when opening the form, improving UX for repeat sellers.
///
/// NOTE: keepAlive: true so the value survives tab switches and navigations.
final class LastPickupLocationIdProvider
    extends $NotifierProvider<LastPickupLocationId, String?> {
  /// Persists and retrieves the last pickup location the user selected.
  ///
  /// This is used in [CreateListingFormScreen] to pre-select the previous
  /// pickup location when opening the form, improving UX for repeat sellers.
  ///
  /// NOTE: keepAlive: true so the value survives tab switches and navigations.
  LastPickupLocationIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastPickupLocationIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastPickupLocationIdHash();

  @$internal
  @override
  LastPickupLocationId create() => LastPickupLocationId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$lastPickupLocationIdHash() =>
    r'0c53c1a7ac991e93c636f4ace24a9dab08eeb0eb';

/// Persists and retrieves the last pickup location the user selected.
///
/// This is used in [CreateListingFormScreen] to pre-select the previous
/// pickup location when opening the form, improving UX for repeat sellers.
///
/// NOTE: keepAlive: true so the value survives tab switches and navigations.

abstract class _$LastPickupLocationId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
