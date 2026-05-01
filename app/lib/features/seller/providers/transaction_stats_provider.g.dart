// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all orders for a specific listing with realtime updates.

@ProviderFor(ListingOrders)
final listingOrdersProvider = ListingOrdersFamily._();

/// Fetches all orders for a specific listing with realtime updates.
final class ListingOrdersProvider
    extends $AsyncNotifierProvider<ListingOrders, List<Order>> {
  /// Fetches all orders for a specific listing with realtime updates.
  ListingOrdersProvider._({
    required ListingOrdersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listingOrdersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingOrdersHash();

  @override
  String toString() {
    return r'listingOrdersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ListingOrders create() => ListingOrders();

  @override
  bool operator ==(Object other) {
    return other is ListingOrdersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingOrdersHash() => r'064286f0aa8dc4ca8ba22106d08e0a7763839aa0';

/// Fetches all orders for a specific listing with realtime updates.

final class ListingOrdersFamily extends $Family
    with
        $ClassFamilyOverride<
          ListingOrders,
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>,
          String
        > {
  ListingOrdersFamily._()
    : super(
        retry: null,
        name: r'listingOrdersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches all orders for a specific listing with realtime updates.

  ListingOrdersProvider call(String listingId) =>
      ListingOrdersProvider._(argument: listingId, from: this);

  @override
  String toString() => r'listingOrdersProvider';
}

/// Fetches all orders for a specific listing with realtime updates.

abstract class _$ListingOrders extends $AsyncNotifier<List<Order>> {
  late final _$args = ref.$arg as String;
  String get listingId => _$args;

  FutureOr<List<Order>> build(String listingId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Fetches all saves for a specific listing with realtime updates.

@ProviderFor(ListingSaves)
final listingSavesProvider = ListingSavesFamily._();

/// Fetches all saves for a specific listing with realtime updates.
final class ListingSavesProvider
    extends $AsyncNotifierProvider<ListingSaves, List<SavedListing>> {
  /// Fetches all saves for a specific listing with realtime updates.
  ListingSavesProvider._({
    required ListingSavesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listingSavesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingSavesHash();

  @override
  String toString() {
    return r'listingSavesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ListingSaves create() => ListingSaves();

  @override
  bool operator ==(Object other) {
    return other is ListingSavesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingSavesHash() => r'223400792a3d0f6d3bfba5101983fad763d4df89';

/// Fetches all saves for a specific listing with realtime updates.

final class ListingSavesFamily extends $Family
    with
        $ClassFamilyOverride<
          ListingSaves,
          AsyncValue<List<SavedListing>>,
          List<SavedListing>,
          FutureOr<List<SavedListing>>,
          String
        > {
  ListingSavesFamily._()
    : super(
        retry: null,
        name: r'listingSavesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches all saves for a specific listing with realtime updates.

  ListingSavesProvider call(String listingId) =>
      ListingSavesProvider._(argument: listingId, from: this);

  @override
  String toString() => r'listingSavesProvider';
}

/// Fetches all saves for a specific listing with realtime updates.

abstract class _$ListingSaves extends $AsyncNotifier<List<SavedListing>> {
  late final _$args = ref.$arg as String;
  String get listingId => _$args;

  FutureOr<List<SavedListing>> build(String listingId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SavedListing>>, List<SavedListing>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SavedListing>>, List<SavedListing>>,
              AsyncValue<List<SavedListing>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
