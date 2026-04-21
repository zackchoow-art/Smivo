import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthException;

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'auth_repository.g.dart';

/// Handles all authentication and user profile Supabase operations.
class AuthRepository {
  const AuthRepository(this._client);

  final SupabaseClient _client;

  /// Signs up with email and password.
  ///
  /// Throws [AuthException] if signup fails (e.g. duplicate email).
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(email: email, password: password);
    } on AuthApiException catch (e) {
      throw AuthException(e.message, e);
    }
  }

  /// Resends the verification email for the given [email].
  Future<void> resendVerification(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } on AuthApiException catch (e) {
      throw AuthException(e.message, e);
    }
  }

  /// Signs in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthApiException catch (e) {
      throw AuthException(e.message, e);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthApiException catch (e) {
      throw AuthException(e.message, e);
    }
  }

  /// Returns the current user's profile, or null if not found.
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.tableUserProfiles)
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Creates or updates the user's profile.
  Future<UserProfile> upsertProfile(UserProfile profile) async {
    try {
      final data = await _client
          .from(AppConstants.tableUserProfiles)
          .upsert(profile.toJson())
          .select()
          .single();
      return UserProfile.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Returns the current auth user, or null if not authenticated.
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;
}

@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider));
