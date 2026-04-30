// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeNotifierHash() => r'dd8522f98eb10bc657444ab9e662192fec8fb526';

/// Persists and exposes the user's chosen [SmivoThemeVariant].
///
/// On first launch, defaults to [SmivoThemeVariant.teal]. The selected
/// variant is saved to SharedPreferences so it survives app restarts.
///
/// Widgets watch this provider via `ref.watch(themeNotifierProvider)`
/// and pass the variant to [AppTheme.buildTheme].
///
/// Copied from [ThemeNotifier].
@ProviderFor(ThemeNotifier)
final themeNotifierProvider =
    NotifierProvider<ThemeNotifier, SmivoThemeVariant>.internal(
      ThemeNotifier.new,
      name: r'themeNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$themeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeNotifier = Notifier<SmivoThemeVariant>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
