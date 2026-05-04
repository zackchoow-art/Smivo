// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_review_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orderReview)
final orderReviewProvider = OrderReviewFamily._();

final class OrderReviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserReview?>,
          UserReview?,
          FutureOr<UserReview?>
        >
    with $FutureModifier<UserReview?>, $FutureProvider<UserReview?> {
  OrderReviewProvider._({
    required OrderReviewFamily super.from,
    required ({String orderId, String reviewerId}) super.argument,
  }) : super(
         retry: null,
         name: r'orderReviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderReviewHash();

  @override
  String toString() {
    return r'orderReviewProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<UserReview?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserReview?> create(Ref ref) {
    final argument = this.argument as ({String orderId, String reviewerId});
    return orderReview(
      ref,
      orderId: argument.orderId,
      reviewerId: argument.reviewerId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrderReviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderReviewHash() => r'd9a80d7af37435ee7d7b95bc6e9a9ba1d6f5514e';

final class OrderReviewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<UserReview?>,
          ({String orderId, String reviewerId})
        > {
  OrderReviewFamily._()
    : super(
        retry: null,
        name: r'orderReviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrderReviewProvider call({
    required String orderId,
    required String reviewerId,
  }) => OrderReviewProvider._(
    argument: (orderId: orderId, reviewerId: reviewerId),
    from: this,
  );

  @override
  String toString() => r'orderReviewProvider';
}

@ProviderFor(reviewTags)
final reviewTagsProvider = ReviewTagsFamily._();

final class ReviewTagsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReviewTag>>,
          List<ReviewTag>,
          FutureOr<List<ReviewTag>>
        >
    with $FutureModifier<List<ReviewTag>>, $FutureProvider<List<ReviewTag>> {
  ReviewTagsProvider._({
    required ReviewTagsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'reviewTagsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reviewTagsHash();

  @override
  String toString() {
    return r'reviewTagsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ReviewTag>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ReviewTag>> create(Ref ref) {
    final argument = this.argument as String;
    return reviewTags(ref, role: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewTagsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reviewTagsHash() => r'5bc17dd32f8d71a024a89d378c11c9ac70a45aa6';

final class ReviewTagsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ReviewTag>>, String> {
  ReviewTagsFamily._()
    : super(
        retry: null,
        name: r'reviewTagsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReviewTagsProvider call({required String role}) =>
      ReviewTagsProvider._(argument: role, from: this);

  @override
  String toString() => r'reviewTagsProvider';
}

@ProviderFor(OrderReviewActions)
final orderReviewActionsProvider = OrderReviewActionsProvider._();

final class OrderReviewActionsProvider
    extends $AsyncNotifierProvider<OrderReviewActions, void> {
  OrderReviewActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderReviewActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderReviewActionsHash();

  @$internal
  @override
  OrderReviewActions create() => OrderReviewActions();
}

String _$orderReviewActionsHash() =>
    r'a7f7743bfd07e3ddf79c79b74cf72247728c585d';

abstract class _$OrderReviewActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
