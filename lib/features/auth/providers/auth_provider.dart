import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/constants/debug_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/utils/validators.dart';
import 'package:smivo/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

part 'auth_provider.g.dart';

/// Stream of the current Supabase user.
///
/// This is the "Source of Truth" for authentication status across the app.
/// GoRouter and other providers listen to this to react to login/logout.
@riverpod
Stream<supabase.User?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges.map((state) => state.session?.user);
}

@riverpod
class Auth extends _$Auth {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Maps Supabase AuthApiException strings to user-friendly English AppExceptions.
  AppException _mapError(Object error, StackTrace stackTrace) {
    if (error is AppException) return error;

    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('user already registered')) {
      return AuthException('This email is already registered', error);
    }
    if (errorStr.contains('invalid login credentials')) {
      return AuthException('Incorrect email or password', error);
    }
    if (errorStr.contains('network') || errorStr.contains('socketexception')) {
      return NetworkException(
        'Network connection failed. Please check your connection',
        error,
      );
    }
    if (errorStr.contains('email not confirmed')) {
      return AuthException('Email not confirmed', error);
    }
    if (errorStr.contains('database error')) {
      return DatabaseException(
        'Server is temporarily unavailable. Please try again later',
        error,
      );
    }

    return AuthException('Something went wrong. Please try again', error);
  }

  /// Normal Sign-Up using campus email prefix.
  ///
  /// Appends "@smith.edu" automatically.
  Future<void> signUp(String prefix, String password) async {
    state = const AsyncValue.loading();
    try {
      final fullEmail = "${prefix.trim()}@smith.edu";

      // Use Validators to get specific password error messages
      final passwordError = Validators.password(password);
      if (passwordError != null) {
        throw AuthException(passwordError);
      }

      await ref.read(authRepositoryProvider).signUp(
            email: fullEmail,
            password: password,
          );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(_mapError(e, st), st);
    }
  }

  /// Debug Sign-Up using full email address.
  ///
  /// Only available when [kDebugBackdoorEnabled] is true.
  Future<void> signUpDebug(String fullEmail, String password) async {
    state = const AsyncValue.loading();
    try {
      if (!kDebugBackdoorEnabled) {
        throw const AuthException(
          'Debug authentication is not available in this build',
        );
      }

      // Debug signup still requires a strong password
      final passwordError = Validators.password(password);
      if (passwordError != null) {
        throw AuthException(passwordError);
      }

      await ref.read(authRepositoryProvider).signUp(
            email: fullEmail.trim(),
            password: password,
          );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(_mapError(e, st), st);
    }
  }

  /// Normal Login using campus email prefix.
  ///
  /// Appends "@smith.edu" automatically.
  Future<void> login(String prefix, String password) async {
    state = const AsyncValue.loading();
    try {
      final fullEmail = "${prefix.trim()}@smith.edu";
      await ref.read(authRepositoryProvider).signIn(
            email: fullEmail,
            password: password,
          );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      // Per requirements: ignore "Email not confirmed" error here as router handles it
      if (e.toString().contains('Email not confirmed')) {
        state = const AsyncValue.data(null);
        return;
      }
      state = AsyncValue.error(_mapError(e, st), st);
    }
  }

  /// Debug Login using full email address.
  ///
  /// Only available when [kDebugBackdoorEnabled] is true.
  Future<void> loginDebug(String fullEmail, String password) async {
    state = const AsyncValue.loading();
    try {
      if (!kDebugBackdoorEnabled) {
        throw const AuthException(
          'Debug authentication is not available in this build',
        );
      }

      await ref.read(authRepositoryProvider).signIn(
            email: fullEmail.trim(),
            password: password,
          );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(_mapError(e, st), st);
    }
  }

  /// Signs out and resets state.
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(_mapError(e, st), st);
    }
  }

  /// Permanently deletes the current user's account.
  ///
  /// Calls the server-side RPC to remove all user data,
  /// then signs out locally.
  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(_mapError(e, st), st);
    }
  }

  /// Resends the verification email for a specific [email].
  Future<void> resendVerification(String email) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).resendVerification(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(_mapError(e, st), st);
    }
  }
}
