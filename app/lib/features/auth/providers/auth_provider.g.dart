// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream of the current Supabase user.
///
/// This is the "Source of Truth" for authentication status across the app.
/// GoRouter and other providers listen to this to react to login/logout.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Stream of the current Supabase user.
///
/// This is the "Source of Truth" for authentication status across the app.
/// GoRouter and other providers listen to this to react to login/logout.

final class AuthStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<supabase.User?>,
          supabase.User?,
          Stream<supabase.User?>
        >
    with $FutureModifier<supabase.User?>, $StreamProvider<supabase.User?> {
  /// Stream of the current Supabase user.
  ///
  /// This is the "Source of Truth" for authentication status across the app.
  /// GoRouter and other providers listen to this to react to login/logout.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<supabase.User?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<supabase.User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'144bfa8203fd2c4fdc82dc20bf256e51139432a0';

@ProviderFor(Auth)
final authProvider = AuthProvider._();

final class AuthProvider extends $NotifierProvider<Auth, AsyncValue<void>> {
  AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$authHash() => r'b6711c65ae1d5a0b506fe4e26fb1b7a7f41fbcba';

abstract class _$Auth extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
