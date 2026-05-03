// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_listing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userListingBan)
final userListingBanProvider = UserListingBanProvider._();

final class UserListingBanProvider
    extends
        $FunctionalProvider<
          AsyncValue<DateTime?>,
          DateTime?,
          FutureOr<DateTime?>
        >
    with $FutureModifier<DateTime?>, $FutureProvider<DateTime?> {
  UserListingBanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userListingBanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userListingBanHash();

  @$internal
  @override
  $FutureProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DateTime?> create(Ref ref) {
    return userListingBan(ref);
  }
}

String _$userListingBanHash() => r'10efa7d7732e2e7cf82473c601ed9a9d2bbcac47';

@ProviderFor(ListingFormMode)
final listingFormModeProvider = ListingFormModeFamily._();

final class ListingFormModeProvider
    extends $NotifierProvider<ListingFormMode, String> {
  ListingFormModeProvider._({
    required ListingFormModeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listingFormModeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingFormModeHash();

  @override
  String toString() {
    return r'listingFormModeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ListingFormMode create() => ListingFormMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ListingFormModeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingFormModeHash() => r'63ea35fa8d3c5579e57cdd2c4e07dc6ecec963f5';

final class ListingFormModeFamily extends $Family
    with $ClassFamilyOverride<ListingFormMode, String, String, String, String> {
  ListingFormModeFamily._()
    : super(
        retry: null,
        name: r'listingFormModeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ListingFormModeProvider call({required String initialMode}) =>
      ListingFormModeProvider._(argument: initialMode, from: this);

  @override
  String toString() => r'listingFormModeProvider';
}

abstract class _$ListingFormMode extends $Notifier<String> {
  late final _$args = ref.$arg as String;
  String get initialMode => _$args;

  String build({required String initialMode});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(initialMode: _$args));
  }
}

@ProviderFor(ListingPhotos)
final listingPhotosProvider = ListingPhotosProvider._();

final class ListingPhotosProvider
    extends $NotifierProvider<ListingPhotos, List<XFile>> {
  ListingPhotosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listingPhotosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listingPhotosHash();

  @$internal
  @override
  ListingPhotos create() => ListingPhotos();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<XFile> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<XFile>>(value),
    );
  }
}

String _$listingPhotosHash() => r'f7ecdd1b2e7f326f79659b05544928185ff7698d';

abstract class _$ListingPhotos extends $Notifier<List<XFile>> {
  List<XFile> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<XFile>, List<XFile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<XFile>, List<XFile>>,
              List<XFile>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedListingCategory)
final selectedListingCategoryProvider = SelectedListingCategoryProvider._();

final class SelectedListingCategoryProvider
    extends $NotifierProvider<SelectedListingCategory, String?> {
  SelectedListingCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedListingCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedListingCategoryHash();

  @$internal
  @override
  SelectedListingCategory create() => SelectedListingCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedListingCategoryHash() =>
    r'4ff6322d15c5611c92013d7bd7ffaa9b74fb0743';

abstract class _$SelectedListingCategory extends $Notifier<String?> {
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

/// Handles the async submission of the create listing form.
///
/// Reads photo paths from ListingPhotos, reads form fields
/// as parameters, uploads photos + creates the listing +
/// creates listing_images records — all via the repository's
/// atomic createListingWithImages method.

@ProviderFor(CreateListingAction)
final createListingActionProvider = CreateListingActionProvider._();

/// Handles the async submission of the create listing form.
///
/// Reads photo paths from ListingPhotos, reads form fields
/// as parameters, uploads photos + creates the listing +
/// creates listing_images records — all via the repository's
/// atomic createListingWithImages method.
final class CreateListingActionProvider
    extends $NotifierProvider<CreateListingAction, AsyncValue<Listing?>> {
  /// Handles the async submission of the create listing form.
  ///
  /// Reads photo paths from ListingPhotos, reads form fields
  /// as parameters, uploads photos + creates the listing +
  /// creates listing_images records — all via the repository's
  /// atomic createListingWithImages method.
  CreateListingActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createListingActionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createListingActionHash();

  @$internal
  @override
  CreateListingAction create() => CreateListingAction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Listing?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Listing?>>(value),
    );
  }
}

String _$createListingActionHash() =>
    r'abc29cd9f55c070440566162f3f79e16739705a2';

/// Handles the async submission of the create listing form.
///
/// Reads photo paths from ListingPhotos, reads form fields
/// as parameters, uploads photos + creates the listing +
/// creates listing_images records — all via the repository's
/// atomic createListingWithImages method.

abstract class _$CreateListingAction extends $Notifier<AsyncValue<Listing?>> {
  AsyncValue<Listing?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Listing?>, AsyncValue<Listing?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Listing?>, AsyncValue<Listing?>>,
              AsyncValue<Listing?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
