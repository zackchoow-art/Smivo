// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'144bfa8203fd2c4fdc82dc20bf256e51139432a0';

/// Stream of the current Supabase user.
///
/// This is the "Source of Truth" for authentication status across the app.
/// GoRouter and other providers listen to this to react to login/logout.
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<supabase.User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<supabase.User?>;
String _$authHash() => r'0fce0b128e6c6f8d163517de8bca3fb5cacc8108';

/// See also [Auth].
@ProviderFor(Auth)
final authProvider =
    AutoDisposeNotifierProvider<Auth, AsyncValue<void>>.internal(
      Auth.new,
      name: r'authProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product') ? null : _$authHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Auth = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
