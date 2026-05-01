// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_listings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all listings for the admin panel.

@ProviderFor(adminListings)
final adminListingsProvider = AdminListingsProvider._();

/// Fetches all listings for the admin panel.

final class AdminListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Fetches all listings for the admin panel.
  AdminListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminListingsHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return adminListings(ref);
  }
}

String _$adminListingsHash() => r'8b7839487067f85ba98301f7c1555118e23b514b';
