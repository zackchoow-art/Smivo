// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminContextHash() => r'e3d308c7359b97c5a87adcd88949a1ceb6cd5714';

/// Provider that loads the current user's admin context.
///
/// Used by the admin shell to filter sidebar items and by
/// individual admin screens to gate write operations.
///
/// Copied from [adminContext].
@ProviderFor(adminContext)
final adminContextProvider = AutoDisposeFutureProvider<AdminContext>.internal(
  adminContext,
  name: r'adminContextProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$adminContextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminContextRef = AutoDisposeFutureProviderRef<AdminContext>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
