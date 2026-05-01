// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persists and exposes the user's chosen [SmivoThemeVariant].
///
/// On first launch, defaults to [SmivoThemeVariant.teal]. The selected
/// variant is saved to SharedPreferences so it survives app restarts.
///
/// Widgets watch this provider via `ref.watch(themeProvider)`
/// and pass the variant to [AppTheme.buildTheme].

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

/// Persists and exposes the user's chosen [SmivoThemeVariant].
///
/// On first launch, defaults to [SmivoThemeVariant.teal]. The selected
/// variant is saved to SharedPreferences so it survives app restarts.
///
/// Widgets watch this provider via `ref.watch(themeProvider)`
/// and pass the variant to [AppTheme.buildTheme].
final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, SmivoThemeVariant> {
  /// Persists and exposes the user's chosen [SmivoThemeVariant].
  ///
  /// On first launch, defaults to [SmivoThemeVariant.teal]. The selected
  /// variant is saved to SharedPreferences so it survives app restarts.
  ///
  /// Widgets watch this provider via `ref.watch(themeProvider)`
  /// and pass the variant to [AppTheme.buildTheme].
  ThemeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmivoThemeVariant value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmivoThemeVariant>(value),
    );
  }
}

String _$themeNotifierHash() => r'dd8522f98eb10bc657444ab9e662192fec8fb526';

/// Persists and exposes the user's chosen [SmivoThemeVariant].
///
/// On first launch, defaults to [SmivoThemeVariant.teal]. The selected
/// variant is saved to SharedPreferences so it survives app restarts.
///
/// Widgets watch this provider via `ref.watch(themeProvider)`
/// and pass the variant to [AppTheme.buildTheme].

abstract class _$ThemeNotifier extends $Notifier<SmivoThemeVariant> {
  SmivoThemeVariant build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SmivoThemeVariant, SmivoThemeVariant>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SmivoThemeVariant, SmivoThemeVariant>,
              SmivoThemeVariant,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
