// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the user's chat rooms and subscribes to global message
/// inserts to keep the list fresh.
///
/// When any new message arrives in any room the user participates in,
/// the list is re-fetched so last_message_at, last_message preview,
/// and unread counts all update in real-time.

@ProviderFor(ChatRoomList)
final chatRoomListProvider = ChatRoomListProvider._();

/// Fetches the user's chat rooms and subscribes to global message
/// inserts to keep the list fresh.
///
/// When any new message arrives in any room the user participates in,
/// the list is re-fetched so last_message_at, last_message preview,
/// and unread counts all update in real-time.
final class ChatRoomListProvider
    extends $AsyncNotifierProvider<ChatRoomList, List<ChatRoom>> {
  /// Fetches the user's chat rooms and subscribes to global message
  /// inserts to keep the list fresh.
  ///
  /// When any new message arrives in any room the user participates in,
  /// the list is re-fetched so last_message_at, last_message preview,
  /// and unread counts all update in real-time.
  ChatRoomListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRoomListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRoomListHash();

  @$internal
  @override
  ChatRoomList create() => ChatRoomList();
}

String _$chatRoomListHash() => r'2dc1a79e020e31e4746445b0cb7fb8bac6608488';

/// Fetches the user's chat rooms and subscribes to global message
/// inserts to keep the list fresh.
///
/// When any new message arrives in any room the user participates in,
/// the list is re-fetched so last_message_at, last_message preview,
/// and unread counts all update in real-time.

abstract class _$ChatRoomList extends $AsyncNotifier<List<ChatRoom>> {
  FutureOr<List<ChatRoom>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ChatRoom>>, List<ChatRoom>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ChatRoom>>, List<ChatRoom>>,
              AsyncValue<List<ChatRoom>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Manages messages for a single chat room with realtime updates.
///
/// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
/// New messages are appended to state; history is fetched once at build.

@ProviderFor(ChatMessages)
final chatMessagesProvider = ChatMessagesFamily._();

/// Manages messages for a single chat room with realtime updates.
///
/// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
/// New messages are appended to state; history is fetched once at build.
final class ChatMessagesProvider
    extends $AsyncNotifierProvider<ChatMessages, List<Message>> {
  /// Manages messages for a single chat room with realtime updates.
  ///
  /// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
  /// New messages are appended to state; history is fetched once at build.
  ChatMessagesProvider._({
    required ChatMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatMessagesHash();

  @override
  String toString() {
    return r'chatMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatMessages create() => ChatMessages();

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatMessagesHash() => r'279ed715be8280af24470d7b521daff9c69d4488';

/// Manages messages for a single chat room with realtime updates.
///
/// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
/// New messages are appended to state; history is fetched once at build.

final class ChatMessagesFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatMessages,
          AsyncValue<List<Message>>,
          List<Message>,
          FutureOr<List<Message>>,
          String
        > {
  ChatMessagesFamily._()
    : super(
        retry: null,
        name: r'chatMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Manages messages for a single chat room with realtime updates.
  ///
  /// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
  /// New messages are appended to state; history is fetched once at build.

  ChatMessagesProvider call(String chatRoomId) =>
      ChatMessagesProvider._(argument: chatRoomId, from: this);

  @override
  String toString() => r'chatMessagesProvider';
}

/// Manages messages for a single chat room with realtime updates.
///
/// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
/// New messages are appended to state; history is fetched once at build.

abstract class _$ChatMessages extends $AsyncNotifier<List<Message>> {
  late final _$args = ref.$arg as String;
  String get chatRoomId => _$args;

  FutureOr<List<Message>> build(String chatRoomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Message>>, List<Message>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Message>>, List<Message>>,
              AsyncValue<List<Message>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Total unread messages across all chat rooms for the current user.

@ProviderFor(chatTotalUnread)
final chatTotalUnreadProvider = ChatTotalUnreadProvider._();

/// Total unread messages across all chat rooms for the current user.

final class ChatTotalUnreadProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Total unread messages across all chat rooms for the current user.
  ChatTotalUnreadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatTotalUnreadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatTotalUnreadHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return chatTotalUnread(ref);
  }
}

String _$chatTotalUnreadHash() => r'766f09408ddd139fdccccc9e3afb9a19f9986397';

/// Fetches details for a single chat room.

@ProviderFor(chatRoom)
final chatRoomProvider = ChatRoomFamily._();

/// Fetches details for a single chat room.

final class ChatRoomProvider
    extends
        $FunctionalProvider<AsyncValue<ChatRoom>, ChatRoom, FutureOr<ChatRoom>>
    with $FutureModifier<ChatRoom>, $FutureProvider<ChatRoom> {
  /// Fetches details for a single chat room.
  ChatRoomProvider._({
    required ChatRoomFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatRoomProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatRoomHash();

  @override
  String toString() {
    return r'chatRoomProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChatRoom> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ChatRoom> create(Ref ref) {
    final argument = this.argument as String;
    return chatRoom(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatRoomProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatRoomHash() => r'dfa61495195d0eab1107eeafed58b8eeca37a763';

/// Fetches details for a single chat room.

final class ChatRoomFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChatRoom>, String> {
  ChatRoomFamily._()
    : super(
        retry: null,
        name: r'chatRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches details for a single chat room.

  ChatRoomProvider call(String chatRoomId) =>
      ChatRoomProvider._(argument: chatRoomId, from: this);

  @override
  String toString() => r'chatRoomProvider';
}

/// Tracks the ID of the chat room currently being viewed by the user.
/// This is used to suppress push notifications for the active conversation.

@ProviderFor(ActiveChatRoom)
final activeChatRoomProvider = ActiveChatRoomProvider._();

/// Tracks the ID of the chat room currently being viewed by the user.
/// This is used to suppress push notifications for the active conversation.
final class ActiveChatRoomProvider
    extends $NotifierProvider<ActiveChatRoom, String?> {
  /// Tracks the ID of the chat room currently being viewed by the user.
  /// This is used to suppress push notifications for the active conversation.
  ActiveChatRoomProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeChatRoomProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeChatRoomHash();

  @$internal
  @override
  ActiveChatRoom create() => ActiveChatRoom();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$activeChatRoomHash() => r'181496c2b4a5b83d0cbe4d9fd446167eea19ad32';

/// Tracks the ID of the chat room currently being viewed by the user.
/// This is used to suppress push notifications for the active conversation.

abstract class _$ActiveChatRoom extends $Notifier<String?> {
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
