// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_review_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderReviewHash() => r'c7a9842a829b77769764672a7050024c333e5b73';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [orderReview].
@ProviderFor(orderReview)
const orderReviewProvider = OrderReviewFamily();

/// See also [orderReview].
class OrderReviewFamily extends Family<AsyncValue<UserReview?>> {
  /// See also [orderReview].
  const OrderReviewFamily();

  /// See also [orderReview].
  OrderReviewProvider call({
    required String orderId,
    required String reviewerId,
  }) {
    return OrderReviewProvider(orderId: orderId, reviewerId: reviewerId);
  }

  @override
  OrderReviewProvider getProviderOverride(
    covariant OrderReviewProvider provider,
  ) {
    return call(orderId: provider.orderId, reviewerId: provider.reviewerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderReviewProvider';
}

/// See also [orderReview].
class OrderReviewProvider extends AutoDisposeFutureProvider<UserReview?> {
  /// See also [orderReview].
  OrderReviewProvider({required String orderId, required String reviewerId})
    : this._internal(
        (ref) => orderReview(
          ref as OrderReviewRef,
          orderId: orderId,
          reviewerId: reviewerId,
        ),
        from: orderReviewProvider,
        name: r'orderReviewProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$orderReviewHash,
        dependencies: OrderReviewFamily._dependencies,
        allTransitiveDependencies: OrderReviewFamily._allTransitiveDependencies,
        orderId: orderId,
        reviewerId: reviewerId,
      );

  OrderReviewProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
    required this.reviewerId,
  }) : super.internal();

  final String orderId;
  final String reviewerId;

  @override
  Override overrideWith(
    FutureOr<UserReview?> Function(OrderReviewRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderReviewProvider._internal(
        (ref) => create(ref as OrderReviewRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
        reviewerId: reviewerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserReview?> createElement() {
    return _OrderReviewProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderReviewProvider &&
        other.orderId == orderId &&
        other.reviewerId == reviewerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);
    hash = _SystemHash.combine(hash, reviewerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderReviewRef on AutoDisposeFutureProviderRef<UserReview?> {
  /// The parameter `orderId` of this provider.
  String get orderId;

  /// The parameter `reviewerId` of this provider.
  String get reviewerId;
}

class _OrderReviewProviderElement
    extends AutoDisposeFutureProviderElement<UserReview?>
    with OrderReviewRef {
  _OrderReviewProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderReviewProvider).orderId;
  @override
  String get reviewerId => (origin as OrderReviewProvider).reviewerId;
}

String _$reviewTagsHash() => r'004f6f54d1318de17183cf511fba3dc4de1eb8da';

/// See also [reviewTags].
@ProviderFor(reviewTags)
const reviewTagsProvider = ReviewTagsFamily();

/// See also [reviewTags].
class ReviewTagsFamily extends Family<AsyncValue<List<ReviewTag>>> {
  /// See also [reviewTags].
  const ReviewTagsFamily();

  /// See also [reviewTags].
  ReviewTagsProvider call({required String role}) {
    return ReviewTagsProvider(role: role);
  }

  @override
  ReviewTagsProvider getProviderOverride(
    covariant ReviewTagsProvider provider,
  ) {
    return call(role: provider.role);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reviewTagsProvider';
}

/// See also [reviewTags].
class ReviewTagsProvider extends AutoDisposeFutureProvider<List<ReviewTag>> {
  /// See also [reviewTags].
  ReviewTagsProvider({required String role})
    : this._internal(
        (ref) => reviewTags(ref as ReviewTagsRef, role: role),
        from: reviewTagsProvider,
        name: r'reviewTagsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$reviewTagsHash,
        dependencies: ReviewTagsFamily._dependencies,
        allTransitiveDependencies: ReviewTagsFamily._allTransitiveDependencies,
        role: role,
      );

  ReviewTagsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.role,
  }) : super.internal();

  final String role;

  @override
  Override overrideWith(
    FutureOr<List<ReviewTag>> Function(ReviewTagsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReviewTagsProvider._internal(
        (ref) => create(ref as ReviewTagsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        role: role,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ReviewTag>> createElement() {
    return _ReviewTagsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewTagsProvider && other.role == role;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, role.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReviewTagsRef on AutoDisposeFutureProviderRef<List<ReviewTag>> {
  /// The parameter `role` of this provider.
  String get role;
}

class _ReviewTagsProviderElement
    extends AutoDisposeFutureProviderElement<List<ReviewTag>>
    with ReviewTagsRef {
  _ReviewTagsProviderElement(super.provider);

  @override
  String get role => (origin as ReviewTagsProvider).role;
}

String _$orderReviewActionsHash() =>
    r'93ea494edef532da666a42dab8fc9121cc1bbad0';

/// See also [OrderReviewActions].
@ProviderFor(OrderReviewActions)
final orderReviewActionsProvider =
    AutoDisposeAsyncNotifierProvider<OrderReviewActions, void>.internal(
      OrderReviewActions.new,
      name: r'orderReviewActionsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$orderReviewActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderReviewActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
