// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatTotalUnreadHash() => r'47864aa1bff7d6157ba7a22bffc2dd85aa45d4a0';

/// Total unread messages across all chat rooms for the current user.
///
/// Copied from [chatTotalUnread].
@ProviderFor(chatTotalUnread)
final chatTotalUnreadProvider = AutoDisposeFutureProvider<int>.internal(
  chatTotalUnread,
  name: r'chatTotalUnreadProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatTotalUnreadHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatTotalUnreadRef = AutoDisposeFutureProviderRef<int>;
String _$chatRoomHash() => r'4ebced0ba7644bbea6f60e69d12169995fcbeffa';

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

/// Fetches details for a single chat room.
///
/// Copied from [chatRoom].
@ProviderFor(chatRoom)
const chatRoomProvider = ChatRoomFamily();

/// Fetches details for a single chat room.
///
/// Copied from [chatRoom].
class ChatRoomFamily extends Family<AsyncValue<ChatRoom>> {
  /// Fetches details for a single chat room.
  ///
  /// Copied from [chatRoom].
  const ChatRoomFamily();

  /// Fetches details for a single chat room.
  ///
  /// Copied from [chatRoom].
  ChatRoomProvider call(String chatRoomId) {
    return ChatRoomProvider(chatRoomId);
  }

  @override
  ChatRoomProvider getProviderOverride(covariant ChatRoomProvider provider) {
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
  String? get name => r'chatRoomProvider';
}

/// Fetches details for a single chat room.
///
/// Copied from [chatRoom].
class ChatRoomProvider extends AutoDisposeFutureProvider<ChatRoom> {
  /// Fetches details for a single chat room.
  ///
  /// Copied from [chatRoom].
  ChatRoomProvider(String chatRoomId)
    : this._internal(
        (ref) => chatRoom(ref as ChatRoomRef, chatRoomId),
        from: chatRoomProvider,
        name: r'chatRoomProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$chatRoomHash,
        dependencies: ChatRoomFamily._dependencies,
        allTransitiveDependencies: ChatRoomFamily._allTransitiveDependencies,
        chatRoomId: chatRoomId,
      );

  ChatRoomProvider._internal(
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
    FutureOr<ChatRoom> Function(ChatRoomRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatRoomProvider._internal(
        (ref) => create(ref as ChatRoomRef),
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
  AutoDisposeFutureProviderElement<ChatRoom> createElement() {
    return _ChatRoomProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatRoomProvider && other.chatRoomId == chatRoomId;
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
mixin ChatRoomRef on AutoDisposeFutureProviderRef<ChatRoom> {
  /// The parameter `chatRoomId` of this provider.
  String get chatRoomId;
}

class _ChatRoomProviderElement
    extends AutoDisposeFutureProviderElement<ChatRoom>
    with ChatRoomRef {
  _ChatRoomProviderElement(super.provider);

  @override
  String get chatRoomId => (origin as ChatRoomProvider).chatRoomId;
}

String _$chatRoomListHash() => r'6ddc4d694558109e72731c990182e8528b5672c4';

/// Fetches the user's chat rooms and subscribes to global message
/// inserts to keep the list fresh.
///
/// When any new message arrives in any room the user participates in,
/// the list is re-fetched so last_message_at, last_message preview,
/// and unread counts all update in real-time.
///
/// Copied from [ChatRoomList].
@ProviderFor(ChatRoomList)
final chatRoomListProvider =
    AutoDisposeAsyncNotifierProvider<ChatRoomList, List<ChatRoom>>.internal(
      ChatRoomList.new,
      name: r'chatRoomListProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$chatRoomListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatRoomList = AutoDisposeAsyncNotifier<List<ChatRoom>>;
String _$chatMessagesHash() => r'c7bab1e54c16e8d88036ac3fd9fd50ae129df550';

abstract class _$ChatMessages
    extends BuildlessAutoDisposeAsyncNotifier<List<Message>> {
  late final String chatRoomId;

  FutureOr<List<Message>> build(String chatRoomId);
}

/// Manages messages for a single chat room with realtime updates.
///
/// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
/// New messages are appended to state; history is fetched once at build.
///
/// Copied from [ChatMessages].
@ProviderFor(ChatMessages)
const chatMessagesProvider = ChatMessagesFamily();

/// Manages messages for a single chat room with realtime updates.
///
/// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
/// New messages are appended to state; history is fetched once at build.
///
/// Copied from [ChatMessages].
class ChatMessagesFamily extends Family<AsyncValue<List<Message>>> {
  /// Manages messages for a single chat room with realtime updates.
  ///
  /// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
  /// New messages are appended to state; history is fetched once at build.
  ///
  /// Copied from [ChatMessages].
  const ChatMessagesFamily();

  /// Manages messages for a single chat room with realtime updates.
  ///
  /// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
  /// New messages are appended to state; history is fetched once at build.
  ///
  /// Copied from [ChatMessages].
  ChatMessagesProvider call(String chatRoomId) {
    return ChatMessagesProvider(chatRoomId);
  }

  @override
  ChatMessagesProvider getProviderOverride(
    covariant ChatMessagesProvider provider,
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
  String? get name => r'chatMessagesProvider';
}

/// Manages messages for a single chat room with realtime updates.
///
/// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
/// New messages are appended to state; history is fetched once at build.
///
/// Copied from [ChatMessages].
class ChatMessagesProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChatMessages, List<Message>> {
  /// Manages messages for a single chat room with realtime updates.
  ///
  /// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
  /// New messages are appended to state; history is fetched once at build.
  ///
  /// Copied from [ChatMessages].
  ChatMessagesProvider(String chatRoomId)
    : this._internal(
        () => ChatMessages()..chatRoomId = chatRoomId,
        from: chatMessagesProvider,
        name: r'chatMessagesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$chatMessagesHash,
        dependencies: ChatMessagesFamily._dependencies,
        allTransitiveDependencies:
            ChatMessagesFamily._allTransitiveDependencies,
        chatRoomId: chatRoomId,
      );

  ChatMessagesProvider._internal(
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
  FutureOr<List<Message>> runNotifierBuild(covariant ChatMessages notifier) {
    return notifier.build(chatRoomId);
  }

  @override
  Override overrideWith(ChatMessages Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMessagesProvider._internal(
        () => create()..chatRoomId = chatRoomId,
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
  AutoDisposeAsyncNotifierProviderElement<ChatMessages, List<Message>>
  createElement() {
    return _ChatMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesProvider && other.chatRoomId == chatRoomId;
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
mixin ChatMessagesRef on AutoDisposeAsyncNotifierProviderRef<List<Message>> {
  /// The parameter `chatRoomId` of this provider.
  String get chatRoomId;
}

class _ChatMessagesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChatMessages, List<Message>>
    with ChatMessagesRef {
  _ChatMessagesProviderElement(super.provider);

  @override
  String get chatRoomId => (origin as ChatMessagesProvider).chatRoomId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
