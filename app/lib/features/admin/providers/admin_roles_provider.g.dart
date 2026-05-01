// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_roles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides all admin role assignments for the roles management screen.

@ProviderFor(adminRoles)
final adminRolesProvider = AdminRolesProvider._();

/// Provides all admin role assignments for the roles management screen.

final class AdminRolesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AdminRole>>,
          List<AdminRole>,
          FutureOr<List<AdminRole>>
        >
    with $FutureModifier<List<AdminRole>>, $FutureProvider<List<AdminRole>> {
  /// Provides all admin role assignments for the roles management screen.
  AdminRolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRolesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRolesHash();

  @$internal
  @override
  $FutureProviderElement<List<AdminRole>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AdminRole>> create(Ref ref) {
    return adminRoles(ref);
  }
}

String _$adminRolesHash() => r'fe9edc7f1d84d8671dc5debe188ce6bfeb3cacba';
