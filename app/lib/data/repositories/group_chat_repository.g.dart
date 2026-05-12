// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_chat_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupChatRepository)
final groupChatRepositoryProvider = GroupChatRepositoryProvider._();

final class GroupChatRepositoryProvider
    extends
        $FunctionalProvider<
          GroupChatRepository,
          GroupChatRepository,
          GroupChatRepository
        >
    with $Provider<GroupChatRepository> {
  GroupChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupChatRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupChatRepositoryHash();

  @$internal
  @override
  $ProviderElement<GroupChatRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupChatRepository create(Ref ref) {
    return groupChatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupChatRepository>(value),
    );
  }
}

String _$groupChatRepositoryHash() =>
    r'2f3c68acfb50714678aac677096fdee35d019992';
