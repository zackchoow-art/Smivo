// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the chat history for a specific chat room.

@ProviderFor(orderChatMessages)
final orderChatMessagesProvider = OrderChatMessagesFamily._();

/// Fetches the chat history for a specific chat room.

final class OrderChatMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Message>>,
          List<Message>,
          FutureOr<List<Message>>
        >
    with $FutureModifier<List<Message>>, $FutureProvider<List<Message>> {
  /// Fetches the chat history for a specific chat room.
  OrderChatMessagesProvider._({
    required OrderChatMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderChatMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderChatMessagesHash();

  @override
  String toString() {
    return r'orderChatMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Message>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Message>> create(Ref ref) {
    final argument = this.argument as String;
    return orderChatMessages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderChatMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderChatMessagesHash() => r'096266348be234a659159d5c7d7ee6c05bb4e933';

/// Fetches the chat history for a specific chat room.

final class OrderChatMessagesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Message>>, String> {
  OrderChatMessagesFamily._()
    : super(
        retry: null,
        name: r'orderChatMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches the chat history for a specific chat room.

  OrderChatMessagesProvider call(String chatRoomId) =>
      OrderChatMessagesProvider._(argument: chatRoomId, from: this);

  @override
  String toString() => r'orderChatMessagesProvider';
}

/// Finds the chat room for a listing between buyer and seller.
///
/// NOTE: Queries both buyer's and seller's chat rooms to ensure
/// visibility regardless of which party is viewing the order.

@ProviderFor(orderChatRoomId)
final orderChatRoomIdProvider = OrderChatRoomIdFamily._();

/// Finds the chat room for a listing between buyer and seller.
///
/// NOTE: Queries both buyer's and seller's chat rooms to ensure
/// visibility regardless of which party is viewing the order.

final class OrderChatRoomIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Finds the chat room for a listing between buyer and seller.
  ///
  /// NOTE: Queries both buyer's and seller's chat rooms to ensure
  /// visibility regardless of which party is viewing the order.
  OrderChatRoomIdProvider._({
    required OrderChatRoomIdFamily super.from,
    required ({String listingId, String buyerId, String sellerId})
    super.argument,
  }) : super(
         retry: null,
         name: r'orderChatRoomIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderChatRoomIdHash();

  @override
  String toString() {
    return r'orderChatRoomIdProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument =
        this.argument as ({String listingId, String buyerId, String sellerId});
    return orderChatRoomId(
      ref,
      listingId: argument.listingId,
      buyerId: argument.buyerId,
      sellerId: argument.sellerId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrderChatRoomIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderChatRoomIdHash() => r'3109790c764c99bfbc2e60e7a5b2306799df0775';

/// Finds the chat room for a listing between buyer and seller.
///
/// NOTE: Queries both buyer's and seller's chat rooms to ensure
/// visibility regardless of which party is viewing the order.

final class OrderChatRoomIdFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<String?>,
          ({String listingId, String buyerId, String sellerId})
        > {
  OrderChatRoomIdFamily._()
    : super(
        retry: null,
        name: r'orderChatRoomIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Finds the chat room for a listing between buyer and seller.
  ///
  /// NOTE: Queries both buyer's and seller's chat rooms to ensure
  /// visibility regardless of which party is viewing the order.

  OrderChatRoomIdProvider call({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) => OrderChatRoomIdProvider._(
    argument: (listingId: listingId, buyerId: buyerId, sellerId: sellerId),
    from: this,
  );

  @override
  String toString() => r'orderChatRoomIdProvider';
}
