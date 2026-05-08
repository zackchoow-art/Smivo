// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shake_feedback_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persists and exposes whether the "Shake to Report Bug" feature is enabled.
/// Default is false — user must explicitly enable in Settings.

@ProviderFor(ShakeFeedbackNotifier)
final shakeFeedbackProvider = ShakeFeedbackNotifierProvider._();

/// Persists and exposes whether the "Shake to Report Bug" feature is enabled.
/// Default is false — user must explicitly enable in Settings.
final class ShakeFeedbackNotifierProvider
    extends $NotifierProvider<ShakeFeedbackNotifier, bool> {
  /// Persists and exposes whether the "Shake to Report Bug" feature is enabled.
  /// Default is false — user must explicitly enable in Settings.
  ShakeFeedbackNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shakeFeedbackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shakeFeedbackNotifierHash();

  @$internal
  @override
  ShakeFeedbackNotifier create() => ShakeFeedbackNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shakeFeedbackNotifierHash() =>
    r'341f5aca9b959fbde8585bfde3e30abd07bb0d06';

/// Persists and exposes whether the "Shake to Report Bug" feature is enabled.
/// Default is false — user must explicitly enable in Settings.

abstract class _$ShakeFeedbackNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
