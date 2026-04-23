// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderChatMessagesHash() => r'096266348be234a659159d5c7d7ee6c05bb4e933';

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

/// Fetches the chat history for a specific chat room.
///
/// Copied from [orderChatMessages].
@ProviderFor(orderChatMessages)
const orderChatMessagesProvider = OrderChatMessagesFamily();

/// Fetches the chat history for a specific chat room.
///
/// Copied from [orderChatMessages].
class OrderChatMessagesFamily extends Family<AsyncValue<List<Message>>> {
  /// Fetches the chat history for a specific chat room.
  ///
  /// Copied from [orderChatMessages].
  const OrderChatMessagesFamily();

  /// Fetches the chat history for a specific chat room.
  ///
  /// Copied from [orderChatMessages].
  OrderChatMessagesProvider call(String chatRoomId) {
    return OrderChatMessagesProvider(chatRoomId);
  }

  @override
  OrderChatMessagesProvider getProviderOverride(
    covariant OrderChatMessagesProvider provider,
  ) {
    return call(provider.chatRoomId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderChatMessagesProvider';
}

/// Fetches the chat history for a specific chat room.
///
/// Copied from [orderChatMessages].
class OrderChatMessagesProvider
    extends AutoDisposeFutureProvider<List<Message>> {
  /// Fetches the chat history for a specific chat room.
  ///
  /// Copied from [orderChatMessages].
  OrderChatMessagesProvider(String chatRoomId)
    : this._internal(
        (ref) => orderChatMessages(ref as OrderChatMessagesRef, chatRoomId),
        from: orderChatMessagesProvider,
        name: r'orderChatMessagesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$orderChatMessagesHash,
        dependencies: OrderChatMessagesFamily._dependencies,
        allTransitiveDependencies:
            OrderChatMessagesFamily._allTransitiveDependencies,
        chatRoomId: chatRoomId,
      );

  OrderChatMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatRoomId,
  }) : super.internal();

  final String chatRoomId;

  @override
  Override overrideWith(
    FutureOr<List<Message>> Function(OrderChatMessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderChatMessagesProvider._internal(
        (ref) => create(ref as OrderChatMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatRoomId: chatRoomId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Message>> createElement() {
    return _OrderChatMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderChatMessagesProvider && other.chatRoomId == chatRoomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatRoomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderChatMessagesRef on AutoDisposeFutureProviderRef<List<Message>> {
  /// The parameter `chatRoomId` of this provider.
  String get chatRoomId;
}

class _OrderChatMessagesProviderElement
    extends AutoDisposeFutureProviderElement<List<Message>>
    with OrderChatMessagesRef {
  _OrderChatMessagesProviderElement(super.provider);

  @override
  String get chatRoomId => (origin as OrderChatMessagesProvider).chatRoomId;
}

String _$orderChatRoomIdHash() => r'24a9e45414aa0c5fcbc2ba92a91f0694819caa1e';

/// Finds the chat room for a listing between buyer and seller.
///
/// Copied from [orderChatRoomId].
@ProviderFor(orderChatRoomId)
const orderChatRoomIdProvider = OrderChatRoomIdFamily();

/// Finds the chat room for a listing between buyer and seller.
///
/// Copied from [orderChatRoomId].
class OrderChatRoomIdFamily extends Family<AsyncValue<String?>> {
  /// Finds the chat room for a listing between buyer and seller.
  ///
  /// Copied from [orderChatRoomId].
  const OrderChatRoomIdFamily();

  /// Finds the chat room for a listing between buyer and seller.
  ///
  /// Copied from [orderChatRoomId].
  OrderChatRoomIdProvider call({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) {
    return OrderChatRoomIdProvider(
      listingId: listingId,
      buyerId: buyerId,
      sellerId: sellerId,
    );
  }

  @override
  OrderChatRoomIdProvider getProviderOverride(
    covariant OrderChatRoomIdProvider provider,
  ) {
    return call(
      listingId: provider.listingId,
      buyerId: provider.buyerId,
      sellerId: provider.sellerId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderChatRoomIdProvider';
}

/// Finds the chat room for a listing between buyer and seller.
///
/// Copied from [orderChatRoomId].
class OrderChatRoomIdProvider extends AutoDisposeFutureProvider<String?> {
  /// Finds the chat room for a listing between buyer and seller.
  ///
  /// Copied from [orderChatRoomId].
  OrderChatRoomIdProvider({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) : this._internal(
         (ref) => orderChatRoomId(
           ref as OrderChatRoomIdRef,
           listingId: listingId,
           buyerId: buyerId,
           sellerId: sellerId,
         ),
         from: orderChatRoomIdProvider,
         name: r'orderChatRoomIdProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$orderChatRoomIdHash,
         dependencies: OrderChatRoomIdFamily._dependencies,
         allTransitiveDependencies:
             OrderChatRoomIdFamily._allTransitiveDependencies,
         listingId: listingId,
         buyerId: buyerId,
         sellerId: sellerId,
       );

  OrderChatRoomIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
  }) : super.internal();

  final String listingId;
  final String buyerId;
  final String sellerId;

  @override
  Override overrideWith(
    FutureOr<String?> Function(OrderChatRoomIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderChatRoomIdProvider._internal(
        (ref) => create(ref as OrderChatRoomIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listingId: listingId,
        buyerId: buyerId,
        sellerId: sellerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _OrderChatRoomIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderChatRoomIdProvider &&
        other.listingId == listingId &&
        other.buyerId == buyerId &&
        other.sellerId == sellerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listingId.hashCode);
    hash = _SystemHash.combine(hash, buyerId.hashCode);
    hash = _SystemHash.combine(hash, sellerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderChatRoomIdRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `listingId` of this provider.
  String get listingId;

  /// The parameter `buyerId` of this provider.
  String get buyerId;

  /// The parameter `sellerId` of this provider.
  String get sellerId;
}

class _OrderChatRoomIdProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with OrderChatRoomIdRef {
  _OrderChatRoomIdProviderElement(super.provider);

  @override
  String get listingId => (origin as OrderChatRoomIdProvider).listingId;
  @override
  String get buyerId => (origin as OrderChatRoomIdProvider).buyerId;
  @override
  String get sellerId => (origin as OrderChatRoomIdProvider).sellerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
