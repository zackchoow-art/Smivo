// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that loads the current user's admin context.
///
/// Used by the admin shell to filter sidebar items and by
/// individual admin screens to gate write operations.

@ProviderFor(adminContext)
final adminContextProvider = AdminContextProvider._();

/// Provider that loads the current user's admin context.
///
/// Used by the admin shell to filter sidebar items and by
/// individual admin screens to gate write operations.

final class AdminContextProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminContext>,
          AdminContext,
          FutureOr<AdminContext>
        >
    with $FutureModifier<AdminContext>, $FutureProvider<AdminContext> {
  /// Provider that loads the current user's admin context.
  ///
  /// Used by the admin shell to filter sidebar items and by
  /// individual admin screens to gate write operations.
  AdminContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminContextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminContextHash();

  @$internal
  @override
  $FutureProviderElement<AdminContext> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdminContext> create(Ref ref) {
    return adminContext(ref);
  }
}

String _$adminContextHash() => r'7d269ea820ecc83e6160a617d3dfd778f698a0d8';
