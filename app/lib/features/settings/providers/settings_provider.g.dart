// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationSettingsState)
final notificationSettingsStateProvider = NotificationSettingsStateProvider._();

final class NotificationSettingsStateProvider
    extends
        $NotifierProvider<NotificationSettingsState, NotificationPreferences> {
  NotificationSettingsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsStateHash();

  @$internal
  @override
  NotificationSettingsState create() => NotificationSettingsState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPreferences>(value),
    );
  }
}

String _$notificationSettingsStateHash() =>
    r'9339f82564880a5090808990e60f2aebba05d9d3';

abstract class _$NotificationSettingsState
    extends $Notifier<NotificationPreferences> {
  NotificationPreferences build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<NotificationPreferences, NotificationPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationPreferences, NotificationPreferences>,
              NotificationPreferences,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
