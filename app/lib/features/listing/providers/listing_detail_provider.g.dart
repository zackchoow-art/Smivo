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
        isAutoDispose: false,
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
    r'976feda20eece2b1625727d6a07dbadf895182a1';

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
        isAutoDispose: false,
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

String _$rentalDurationHash() => r'5fcd25470d5e4fa1f4a93bcf099131c22dc1452f';

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
        isAutoDispose: false,
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

String _$rentalStartDateHash() => r'18a95333f63699b9bd293e49e6d3f86c8016efe9';

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
        isAutoDispose: false,
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

String _$rentalEndDateHash() => r'0d976bf0c9f713bee2e66c8b0c1dcbcbc151223a';

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

/// State for the selected sale delivery/pickup start date.

@ProviderFor(SaleStartDate)
final saleStartDateProvider = SaleStartDateProvider._();

/// State for the selected sale delivery/pickup start date.
final class SaleStartDateProvider
    extends $NotifierProvider<SaleStartDate, DateTime> {
  /// State for the selected sale delivery/pickup start date.
  SaleStartDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleStartDateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleStartDateHash();

  @$internal
  @override
  SaleStartDate create() => SaleStartDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$saleStartDateHash() => r'c6636a1c86fd8ee6f586350bccae7ceee50014c0';

/// State for the selected sale delivery/pickup start date.

abstract class _$SaleStartDate extends $Notifier<DateTime> {
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
///
/// NOTE: Subscribes to a Realtime channel scoped to the specific listing so
/// any INSERT/UPDATE on its orders row immediately re-fetches this provider
/// and invalidates listingDetail. This drives the real-time UI update for
/// buttons and status cards when the seller accepts, cancels, etc.

@ProviderFor(existingBuyerOrder)
final existingBuyerOrderProvider = ExistingBuyerOrderFamily._();

/// Checks if the current user already has a pending/confirmed order
/// for this listing. Returns the order if found, null otherwise.
///
/// NOTE: Subscribes to a Realtime channel scoped to the specific listing so
/// any INSERT/UPDATE on its orders row immediately re-fetches this provider
/// and invalidates listingDetail. This drives the real-time UI update for
/// buttons and status cards when the seller accepts, cancels, etc.

final class ExistingBuyerOrderProvider
    extends $FunctionalProvider<AsyncValue<Order?>, Order?, FutureOr<Order?>>
    with $FutureModifier<Order?>, $FutureProvider<Order?> {
  /// Checks if the current user already has a pending/confirmed order
  /// for this listing. Returns the order if found, null otherwise.
  ///
  /// NOTE: Subscribes to a Realtime channel scoped to the specific listing so
  /// any INSERT/UPDATE on its orders row immediately re-fetches this provider
  /// and invalidates listingDetail. This drives the real-time UI update for
  /// buttons and status cards when the seller accepts, cancels, etc.
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
    r'152bd514357c56d3e24b5f34ef0849b31b01cff6';

/// Checks if the current user already has a pending/confirmed order
/// for this listing. Returns the order if found, null otherwise.
///
/// NOTE: Subscribes to a Realtime channel scoped to the specific listing so
/// any INSERT/UPDATE on its orders row immediately re-fetches this provider
/// and invalidates listingDetail. This drives the real-time UI update for
/// buttons and status cards when the seller accepts, cancels, etc.

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
  ///
  /// NOTE: Subscribes to a Realtime channel scoped to the specific listing so
  /// any INSERT/UPDATE on its orders row immediately re-fetches this provider
  /// and invalidates listingDetail. This drives the real-time UI update for
  /// buttons and status cards when the seller accepts, cancels, etc.

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
