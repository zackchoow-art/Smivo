// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches and manages the group chat room for a carpool trip.

@ProviderFor(GroupChatRoomData)
final groupChatRoomDataProvider = GroupChatRoomDataFamily._();

/// Fetches and manages the group chat room for a carpool trip.
final class GroupChatRoomDataProvider
    extends $AsyncNotifierProvider<GroupChatRoomData, model.GroupChatRoom> {
  /// Fetches and manages the group chat room for a carpool trip.
  GroupChatRoomDataProvider._({
    required GroupChatRoomDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupChatRoomDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupChatRoomDataHash();

  @override
  String toString() {
    return r'groupChatRoomDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GroupChatRoomData create() => GroupChatRoomData();

  @override
  bool operator ==(Object other) {
    return other is GroupChatRoomDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupChatRoomDataHash() => r'737527e28be914ac73389c5c4e15453c5f8a0a89';

/// Fetches and manages the group chat room for a carpool trip.

final class GroupChatRoomDataFamily extends $Family
    with
        $ClassFamilyOverride<
          GroupChatRoomData,
          AsyncValue<model.GroupChatRoom>,
          model.GroupChatRoom,
          FutureOr<model.GroupChatRoom>,
          String
        > {
  GroupChatRoomDataFamily._()
    : super(
        retry: null,
        name: r'groupChatRoomDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches and manages the group chat room for a carpool trip.

  GroupChatRoomDataProvider call(String tripId) =>
      GroupChatRoomDataProvider._(argument: tripId, from: this);

  @override
  String toString() => r'groupChatRoomDataProvider';
}

/// Fetches and manages the group chat room for a carpool trip.

abstract class _$GroupChatRoomData extends $AsyncNotifier<model.GroupChatRoom> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  FutureOr<model.GroupChatRoom> build(String tripId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<model.GroupChatRoom>, model.GroupChatRoom>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<model.GroupChatRoom>, model.GroupChatRoom>,
              AsyncValue<model.GroupChatRoom>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Manages group chat messages with Realtime subscription.
///
/// On build, fetches the full message history and subscribes to
/// new messages via Supabase Realtime. On dispose, unsubscribes
/// the channel to prevent memory leaks and ghost subscriptions.

@ProviderFor(GroupChatMessages)
final groupChatMessagesProvider = GroupChatMessagesFamily._();

/// Manages group chat messages with Realtime subscription.
///
/// On build, fetches the full message history and subscribes to
/// new messages via Supabase Realtime. On dispose, unsubscribes
/// the channel to prevent memory leaks and ghost subscriptions.
final class GroupChatMessagesProvider
    extends $AsyncNotifierProvider<GroupChatMessages, List<GroupMessage>> {
  /// Manages group chat messages with Realtime subscription.
  ///
  /// On build, fetches the full message history and subscribes to
  /// new messages via Supabase Realtime. On dispose, unsubscribes
  /// the channel to prevent memory leaks and ghost subscriptions.
  GroupChatMessagesProvider._({
    required GroupChatMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupChatMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupChatMessagesHash();

  @override
  String toString() {
    return r'groupChatMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GroupChatMessages create() => GroupChatMessages();

  @override
  bool operator ==(Object other) {
    return other is GroupChatMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupChatMessagesHash() => r'1bdd8cf86603005de75a79788d41976985bcab25';

/// Manages group chat messages with Realtime subscription.
///
/// On build, fetches the full message history and subscribes to
/// new messages via Supabase Realtime. On dispose, unsubscribes
/// the channel to prevent memory leaks and ghost subscriptions.

final class GroupChatMessagesFamily extends $Family
    with
        $ClassFamilyOverride<
          GroupChatMessages,
          AsyncValue<List<GroupMessage>>,
          List<GroupMessage>,
          FutureOr<List<GroupMessage>>,
          String
        > {
  GroupChatMessagesFamily._()
    : super(
        retry: null,
        name: r'groupChatMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Manages group chat messages with Realtime subscription.
  ///
  /// On build, fetches the full message history and subscribes to
  /// new messages via Supabase Realtime. On dispose, unsubscribes
  /// the channel to prevent memory leaks and ghost subscriptions.

  GroupChatMessagesProvider call(String roomId) =>
      GroupChatMessagesProvider._(argument: roomId, from: this);

  @override
  String toString() => r'groupChatMessagesProvider';
}

/// Manages group chat messages with Realtime subscription.
///
/// On build, fetches the full message history and subscribes to
/// new messages via Supabase Realtime. On dispose, unsubscribes
/// the channel to prevent memory leaks and ghost subscriptions.

abstract class _$GroupChatMessages extends $AsyncNotifier<List<GroupMessage>> {
  late final _$args = ref.$arg as String;
  String get roomId => _$args;

  FutureOr<List<GroupMessage>> build(String roomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<GroupMessage>>, List<GroupMessage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<GroupMessage>>, List<GroupMessage>>,
              AsyncValue<List<GroupMessage>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
