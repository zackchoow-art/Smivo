// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_scroll_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Triggers scroll-to-top on the Home feed when [trigger] is called.

@ProviderFor(HomeScrollTrigger)
final homeScrollTriggerProvider = HomeScrollTriggerProvider._();

/// Triggers scroll-to-top on the Home feed when [trigger] is called.
final class HomeScrollTriggerProvider
    extends $NotifierProvider<HomeScrollTrigger, int> {
  /// Triggers scroll-to-top on the Home feed when [trigger] is called.
  HomeScrollTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeScrollTriggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeScrollTriggerHash();

  @$internal
  @override
  HomeScrollTrigger create() => HomeScrollTrigger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$homeScrollTriggerHash() => r'b30d72f9721ef15c05b9dafd10a06f9458e78a3d';

/// Triggers scroll-to-top on the Home feed when [trigger] is called.

abstract class _$HomeScrollTrigger extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Triggers scroll-to-top on the Chat list when [trigger] is called.

@ProviderFor(ChatScrollTrigger)
final chatScrollTriggerProvider = ChatScrollTriggerProvider._();

/// Triggers scroll-to-top on the Chat list when [trigger] is called.
final class ChatScrollTriggerProvider
    extends $NotifierProvider<ChatScrollTrigger, int> {
  /// Triggers scroll-to-top on the Chat list when [trigger] is called.
  ChatScrollTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatScrollTriggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatScrollTriggerHash();

  @$internal
  @override
  ChatScrollTrigger create() => ChatScrollTrigger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$chatScrollTriggerHash() => r'd04084e6ae730643c44f1bfeb873b0500cf4cb50';

/// Triggers scroll-to-top on the Chat list when [trigger] is called.

abstract class _$ChatScrollTrigger extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
