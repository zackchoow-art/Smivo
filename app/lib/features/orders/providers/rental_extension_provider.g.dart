// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_extension_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all extension requests for a given order.

@ProviderFor(orderExtensions)
final orderExtensionsProvider = OrderExtensionsFamily._();

/// Fetches all extension requests for a given order.

final class OrderExtensionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RentalExtension>>,
          List<RentalExtension>,
          FutureOr<List<RentalExtension>>
        >
    with
        $FutureModifier<List<RentalExtension>>,
        $FutureProvider<List<RentalExtension>> {
  /// Fetches all extension requests for a given order.
  OrderExtensionsProvider._({
    required OrderExtensionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderExtensionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderExtensionsHash();

  @override
  String toString() {
    return r'orderExtensionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RentalExtension>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RentalExtension>> create(Ref ref) {
    final argument = this.argument as String;
    return orderExtensions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderExtensionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderExtensionsHash() => r'0643a539bc718191a83b999cf2b5a7c1d15b7809';

/// Fetches all extension requests for a given order.

final class OrderExtensionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RentalExtension>>, String> {
  OrderExtensionsFamily._()
    : super(
        retry: null,
        name: r'orderExtensionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches all extension requests for a given order.

  OrderExtensionsProvider call(String orderId) =>
      OrderExtensionsProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderExtensionsProvider';
}

/// Handles extension request actions (create, approve, reject).

@ProviderFor(RentalExtensionActions)
final rentalExtensionActionsProvider = RentalExtensionActionsProvider._();

/// Handles extension request actions (create, approve, reject).
final class RentalExtensionActionsProvider
    extends $AsyncNotifierProvider<RentalExtensionActions, void> {
  /// Handles extension request actions (create, approve, reject).
  RentalExtensionActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rentalExtensionActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rentalExtensionActionsHash();

  @$internal
  @override
  RentalExtensionActions create() => RentalExtensionActions();
}

String _$rentalExtensionActionsHash() =>
    r'580f65727b315cef1013fc21aa2c6046213b9c4b';

/// Handles extension request actions (create, approve, reject).

abstract class _$RentalExtensionActions extends $AsyncNotifier<void> {
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
