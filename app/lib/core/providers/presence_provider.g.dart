// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads the platform switch `presence.show_online_dot` from system_settings.
///
/// Returns true if the online dot should be shown, false otherwise.
/// Defaults to true if the setting is missing or cannot be read.

@ProviderFor(PresenceConfig)
final presenceConfigProvider = PresenceConfigProvider._();

/// Reads the platform switch `presence.show_online_dot` from system_settings.
///
/// Returns true if the online dot should be shown, false otherwise.
/// Defaults to true if the setting is missing or cannot be read.
final class PresenceConfigProvider
    extends $AsyncNotifierProvider<PresenceConfig, bool> {
  /// Reads the platform switch `presence.show_online_dot` from system_settings.
  ///
  /// Returns true if the online dot should be shown, false otherwise.
  /// Defaults to true if the setting is missing or cannot be read.
  PresenceConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presenceConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presenceConfigHash();

  @$internal
  @override
  PresenceConfig create() => PresenceConfig();
}

String _$presenceConfigHash() => r'b4670fe337d08b5540ed3f8b024a1884b468da19';

/// Reads the platform switch `presence.show_online_dot` from system_settings.
///
/// Returns true if the online dot should be shown, false otherwise.
/// Defaults to true if the setting is missing or cannot be read.

abstract class _$PresenceConfig extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
