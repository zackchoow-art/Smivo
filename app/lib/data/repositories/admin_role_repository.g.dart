// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_role_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminRoleRepository)
final adminRoleRepositoryProvider = AdminRoleRepositoryProvider._();

final class AdminRoleRepositoryProvider
    extends
        $FunctionalProvider<
          AdminRoleRepository,
          AdminRoleRepository,
          AdminRoleRepository
        >
    with $Provider<AdminRoleRepository> {
  AdminRoleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRoleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRoleRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminRoleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminRoleRepository create(Ref ref) {
    return adminRoleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminRoleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminRoleRepository>(value),
    );
  }
}

String _$adminRoleRepositoryHash() =>
    r'b439e6109532b371ea7a8ec4882838e9bb936fae';
