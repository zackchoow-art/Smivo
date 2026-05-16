// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_scheme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persists and exposes the user's chosen [SmivoColorScheme].
///
/// On first launch, defaults to [SmivoColorScheme.defaultScheme].
/// The selected scheme is saved to SharedPreferences so it survives
/// app restarts.
///
/// Widgets watch this provider via `ref.watch(colorSchemeProvider)`
/// and pass the scheme to [AppTheme.buildTheme].

@ProviderFor(ColorSchemeNotifier)
final colorSchemeProvider = ColorSchemeNotifierProvider._();

/// Persists and exposes the user's chosen [SmivoColorScheme].
///
/// On first launch, defaults to [SmivoColorScheme.defaultScheme].
/// The selected scheme is saved to SharedPreferences so it survives
/// app restarts.
///
/// Widgets watch this provider via `ref.watch(colorSchemeProvider)`
/// and pass the scheme to [AppTheme.buildTheme].
final class ColorSchemeNotifierProvider
    extends $NotifierProvider<ColorSchemeNotifier, SmivoColorScheme> {
  /// Persists and exposes the user's chosen [SmivoColorScheme].
  ///
  /// On first launch, defaults to [SmivoColorScheme.defaultScheme].
  /// The selected scheme is saved to SharedPreferences so it survives
  /// app restarts.
  ///
  /// Widgets watch this provider via `ref.watch(colorSchemeProvider)`
  /// and pass the scheme to [AppTheme.buildTheme].
  ColorSchemeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'colorSchemeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$colorSchemeNotifierHash();

  @$internal
  @override
  ColorSchemeNotifier create() => ColorSchemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmivoColorScheme value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmivoColorScheme>(value),
    );
  }
}

String _$colorSchemeNotifierHash() =>
    r'2d22bb9520ded3f296fd604484e5348dcb991294';

/// Persists and exposes the user's chosen [SmivoColorScheme].
///
/// On first launch, defaults to [SmivoColorScheme.defaultScheme].
/// The selected scheme is saved to SharedPreferences so it survives
/// app restarts.
///
/// Widgets watch this provider via `ref.watch(colorSchemeProvider)`
/// and pass the scheme to [AppTheme.buildTheme].

abstract class _$ColorSchemeNotifier extends $Notifier<SmivoColorScheme> {
  SmivoColorScheme build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SmivoColorScheme, SmivoColorScheme>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SmivoColorScheme, SmivoColorScheme>,
              SmivoColorScheme,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
