// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_users_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminUsersHash() => r'87f71b75795d5a135399f59a2358b91b7ef9265d';

/// Fetches all registered users for the admin panel.
///
/// Copied from [adminUsers].
@ProviderFor(adminUsers)
final adminUsersProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      adminUsers,
      name: r'adminUsersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$adminUsersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminUsersRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
