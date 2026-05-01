// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_listing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Checks if a specific listing is saved by the current user.

@ProviderFor(isListingSaved)
final isListingSavedProvider = IsListingSavedFamily._();

/// Checks if a specific listing is saved by the current user.

final class IsListingSavedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Checks if a specific listing is saved by the current user.
  IsListingSavedProvider._({
    required IsListingSavedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isListingSavedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isListingSavedHash();

  @override
  String toString() {
    return r'isListingSavedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isListingSaved(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsListingSavedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isListingSavedHash() => r'c4c7bda69059581cbd18f2b2c12acb451edcb325';

/// Checks if a specific listing is saved by the current user.

final class IsListingSavedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  IsListingSavedFamily._()
    : super(
        retry: null,
        name: r'isListingSavedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Checks if a specific listing is saved by the current user.

  IsListingSavedProvider call(String listingId) =>
      IsListingSavedProvider._(argument: listingId, from: this);

  @override
  String toString() => r'isListingSavedProvider';
}

/// Fetches the current user's saved listings including listing details.

@ProviderFor(mySavedListings)
final mySavedListingsProvider = MySavedListingsProvider._();

/// Fetches the current user's saved listings including listing details.

final class MySavedListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedListing>>,
          List<SavedListing>,
          FutureOr<List<SavedListing>>
        >
    with
        $FutureModifier<List<SavedListing>>,
        $FutureProvider<List<SavedListing>> {
  /// Fetches the current user's saved listings including listing details.
  MySavedListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mySavedListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mySavedListingsHash();

  @$internal
  @override
  $FutureProviderElement<List<SavedListing>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SavedListing>> create(Ref ref) {
    return mySavedListings(ref);
  }
}

String _$mySavedListingsHash() => r'5b53bc9399562fb607d5b1bd6b462d2a8df4b795';

/// Mutation provider for save/unsave actions.

@ProviderFor(SavedListingActions)
final savedListingActionsProvider = SavedListingActionsProvider._();

/// Mutation provider for save/unsave actions.
final class SavedListingActionsProvider
    extends $NotifierProvider<SavedListingActions, AsyncValue<void>> {
  /// Mutation provider for save/unsave actions.
  SavedListingActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedListingActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedListingActionsHash();

  @$internal
  @override
  SavedListingActions create() => SavedListingActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$savedListingActionsHash() =>
    r'31ac4b8c693069b5f3dec7a89de117a6b88370eb';

/// Mutation provider for save/unsave actions.

abstract class _$SavedListingActions extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
