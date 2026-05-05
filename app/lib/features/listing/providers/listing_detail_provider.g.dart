// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State for the selected rental rate (DAY, WEEK, MONTH).
///
/// Defaults to 'MONTH' as per the primary design.

@ProviderFor(SelectedRentalRate)
final selectedRentalRateProvider = SelectedRentalRateProvider._();

/// State for the selected rental rate (DAY, WEEK, MONTH).
///
/// Defaults to 'MONTH' as per the primary design.
final class SelectedRentalRateProvider
    extends $NotifierProvider<SelectedRentalRate, String> {
  /// State for the selected rental rate (DAY, WEEK, MONTH).
  ///
  /// Defaults to 'MONTH' as per the primary design.
  SelectedRentalRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedRentalRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedRentalRateHash();

  @$internal
  @override
  SelectedRentalRate create() => SelectedRentalRate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedRentalRateHash() =>
    r'0c444cb1063da1555318c40dcba4f21ce0ae31fd';

/// State for the selected rental rate (DAY, WEEK, MONTH).
///
/// Defaults to 'MONTH' as per the primary design.

abstract class _$SelectedRentalRate extends $Notifier<String> {
  String build();
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
    element.handleCreate(ref, build);
  }
}

/// State for the rental duration stepper (e.g., number of months).

@ProviderFor(RentalDuration)
final rentalDurationProvider = RentalDurationProvider._();

/// State for the rental duration stepper (e.g., number of months).
final class RentalDurationProvider
    extends $NotifierProvider<RentalDuration, int> {
  /// State for the rental duration stepper (e.g., number of months).
  RentalDurationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rentalDurationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rentalDurationHash();

  @$internal
  @override
  RentalDuration create() => RentalDuration();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$rentalDurationHash() => r'62604c48adfb3516ef753d97c78d83a7d454efba';

/// State for the rental duration stepper (e.g., number of months).

abstract class _$RentalDuration extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// State for the selected rental start date.

@ProviderFor(RentalStartDate)
final rentalStartDateProvider = RentalStartDateProvider._();

/// State for the selected rental start date.
final class RentalStartDateProvider
    extends $NotifierProvider<RentalStartDate, DateTime> {
  /// State for the selected rental start date.
  RentalStartDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rentalStartDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rentalStartDateHash();

  @$internal
  @override
  RentalStartDate create() => RentalStartDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$rentalStartDateHash() => r'd67d0d05098bab1c0ee6b6be17e2bf1a3e257658';

/// State for the selected rental start date.

abstract class _$RentalStartDate extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// State for the selected rental end date.

@ProviderFor(RentalEndDate)
final rentalEndDateProvider = RentalEndDateProvider._();

/// State for the selected rental end date.
final class RentalEndDateProvider
    extends $NotifierProvider<RentalEndDate, DateTime> {
  /// State for the selected rental end date.
  RentalEndDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rentalEndDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rentalEndDateHash();

  @$internal
  @override
  RentalEndDate create() => RentalEndDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$rentalEndDateHash() => r'76e9032b9f4ae8d55d573e3b2db5759a2cb49271';

/// State for the selected rental end date.

abstract class _$RentalEndDate extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Fetches a single listing with all joined details (images, seller) from Supabase.
///
/// Takes a listing [id] as a parameter.

@ProviderFor(listingDetail)
final listingDetailProvider = ListingDetailFamily._();

/// Fetches a single listing with all joined details (images, seller) from Supabase.
///
/// Takes a listing [id] as a parameter.

final class ListingDetailProvider
    extends $FunctionalProvider<AsyncValue<Listing>, Listing, FutureOr<Listing>>
    with $FutureModifier<Listing>, $FutureProvider<Listing> {
  /// Fetches a single listing with all joined details (images, seller) from Supabase.
  ///
  /// Takes a listing [id] as a parameter.
  ListingDetailProvider._({
    required ListingDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listingDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingDetailHash();

  @override
  String toString() {
    return r'listingDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Listing> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Listing> create(Ref ref) {
    final argument = this.argument as String;
    return listingDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingDetailHash() => r'a4a0ba2b896898f073cc4d5b5142a4190e4843a8';

/// Fetches a single listing with all joined details (images, seller) from Supabase.
///
/// Takes a listing [id] as a parameter.

final class ListingDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Listing>, String> {
  ListingDetailFamily._()
    : super(
        retry: null,
        name: r'listingDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches a single listing with all joined details (images, seller) from Supabase.
  ///
  /// Takes a listing [id] as a parameter.

  ListingDetailProvider call(String id) =>
      ListingDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'listingDetailProvider';
}

/// Checks if the current user already has a pending/confirmed order
/// for this listing. Returns the order if found, null otherwise.

@ProviderFor(existingBuyerOrder)
final existingBuyerOrderProvider = ExistingBuyerOrderFamily._();

/// Checks if the current user already has a pending/confirmed order
/// for this listing. Returns the order if found, null otherwise.

final class ExistingBuyerOrderProvider
    extends $FunctionalProvider<AsyncValue<Order?>, Order?, FutureOr<Order?>>
    with $FutureModifier<Order?>, $FutureProvider<Order?> {
  /// Checks if the current user already has a pending/confirmed order
  /// for this listing. Returns the order if found, null otherwise.
  ExistingBuyerOrderProvider._({
    required ExistingBuyerOrderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'existingBuyerOrderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$existingBuyerOrderHash();

  @override
  String toString() {
    return r'existingBuyerOrderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Order?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Order?> create(Ref ref) {
    final argument = this.argument as String;
    return existingBuyerOrder(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExistingBuyerOrderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$existingBuyerOrderHash() =>
    r'874b403ef9faa1be3aa3629be4f5efd545cba55d';

/// Checks if the current user already has a pending/confirmed order
/// for this listing. Returns the order if found, null otherwise.

final class ExistingBuyerOrderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Order?>, String> {
  ExistingBuyerOrderFamily._()
    : super(
        retry: null,
        name: r'existingBuyerOrderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Checks if the current user already has a pending/confirmed order
  /// for this listing. Returns the order if found, null otherwise.

  ExistingBuyerOrderProvider call(String listingId) =>
      ExistingBuyerOrderProvider._(argument: listingId, from: this);

  @override
  String toString() => r'existingBuyerOrderProvider';
}

/// Checks if a listing has any confirmed (in-progress) orders.
///
/// Used to hide the delist button when a rental listing has been accepted
/// by the seller but the listing status is still 'active' (pre-delivery).

@ProviderFor(listingHasConfirmedOrder)
final listingHasConfirmedOrderProvider = ListingHasConfirmedOrderFamily._();

/// Checks if a listing has any confirmed (in-progress) orders.
///
/// Used to hide the delist button when a rental listing has been accepted
/// by the seller but the listing status is still 'active' (pre-delivery).

final class ListingHasConfirmedOrderProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Checks if a listing has any confirmed (in-progress) orders.
  ///
  /// Used to hide the delist button when a rental listing has been accepted
  /// by the seller but the listing status is still 'active' (pre-delivery).
  ListingHasConfirmedOrderProvider._({
    required ListingHasConfirmedOrderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listingHasConfirmedOrderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingHasConfirmedOrderHash();

  @override
  String toString() {
    return r'listingHasConfirmedOrderProvider'
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
    return listingHasConfirmedOrder(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingHasConfirmedOrderProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingHasConfirmedOrderHash() =>
    r'6fe69a6198d5f248e78e60721c631551e9f0d227';

/// Checks if a listing has any confirmed (in-progress) orders.
///
/// Used to hide the delist button when a rental listing has been accepted
/// by the seller but the listing status is still 'active' (pre-delivery).

final class ListingHasConfirmedOrderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  ListingHasConfirmedOrderFamily._()
    : super(
        retry: null,
        name: r'listingHasConfirmedOrderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Checks if a listing has any confirmed (in-progress) orders.
  ///
  /// Used to hide the delist button when a rental listing has been accepted
  /// by the seller but the listing status is still 'active' (pre-delivery).

  ListingHasConfirmedOrderProvider call(String listingId) =>
      ListingHasConfirmedOrderProvider._(argument: listingId, from: this);

  @override
  String toString() => r'listingHasConfirmedOrderProvider';
}

/// Checks whether the current user is blocked by the seller of a listing.
///
/// Used on the listing detail page to render "Item Unavailable" instead of
/// the order button when the seller has blocked the buyer.
///
/// NOTE: Uses [check_order_eligibility] RPC (SECURITY DEFINER) which ONLY
/// checks the block relationship — not mute or freeze status — so being
/// platform-muted does NOT prevent ordering.

@ProviderFor(isBlockedBySeller)
final isBlockedBySellerProvider = IsBlockedBySellerFamily._();

/// Checks whether the current user is blocked by the seller of a listing.
///
/// Used on the listing detail page to render "Item Unavailable" instead of
/// the order button when the seller has blocked the buyer.
///
/// NOTE: Uses [check_order_eligibility] RPC (SECURITY DEFINER) which ONLY
/// checks the block relationship — not mute or freeze status — so being
/// platform-muted does NOT prevent ordering.

final class IsBlockedBySellerProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Checks whether the current user is blocked by the seller of a listing.
  ///
  /// Used on the listing detail page to render "Item Unavailable" instead of
  /// the order button when the seller has blocked the buyer.
  ///
  /// NOTE: Uses [check_order_eligibility] RPC (SECURITY DEFINER) which ONLY
  /// checks the block relationship — not mute or freeze status — so being
  /// platform-muted does NOT prevent ordering.
  IsBlockedBySellerProvider._({
    required IsBlockedBySellerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isBlockedBySellerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isBlockedBySellerHash();

  @override
  String toString() {
    return r'isBlockedBySellerProvider'
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
    return isBlockedBySeller(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsBlockedBySellerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isBlockedBySellerHash() => r'dbe5002938bb009f8d0c8f6c3b506b733898075b';

/// Checks whether the current user is blocked by the seller of a listing.
///
/// Used on the listing detail page to render "Item Unavailable" instead of
/// the order button when the seller has blocked the buyer.
///
/// NOTE: Uses [check_order_eligibility] RPC (SECURITY DEFINER) which ONLY
/// checks the block relationship — not mute or freeze status — so being
/// platform-muted does NOT prevent ordering.

final class IsBlockedBySellerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  IsBlockedBySellerFamily._()
    : super(
        retry: null,
        name: r'isBlockedBySellerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Checks whether the current user is blocked by the seller of a listing.
  ///
  /// Used on the listing detail page to render "Item Unavailable" instead of
  /// the order button when the seller has blocked the buyer.
  ///
  /// NOTE: Uses [check_order_eligibility] RPC (SECURITY DEFINER) which ONLY
  /// checks the block relationship — not mute or freeze status — so being
  /// platform-muted does NOT prevent ordering.

  IsBlockedBySellerProvider call(String sellerId) =>
      IsBlockedBySellerProvider._(argument: sellerId, from: this);

  @override
  String toString() => r'isBlockedBySellerProvider';
}
