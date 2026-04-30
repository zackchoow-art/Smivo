/// Typed exception hierarchy for the Smivo app.
///
/// Repositories catch raw Supabase/platform errors and rethrow as one
/// of these types. Providers and UI can then pattern-match to show
/// user-friendly messages without leaking implementation details.
sealed class AppException implements Exception {
  const AppException(this.message, [this.originalError]);

  /// Human-readable description of what went wrong.
  final String message;

  /// The original error for debugging (never shown to users).
  final Object? originalError;

  @override
  String toString() => '$runtimeType: $message';

  factory AppException.database(String message, [Object? error]) =
      DatabaseException;

  factory AppException.storage(String message, [Object? error]) =
      AppStorageException;

  factory AppException.unknown(String message, [Object? error]) =
      UnknownException;
}

class UnknownException extends AppException {
  const UnknownException(super.message, [super.originalError]);
}

/// Network-level failures (timeout, no internet, DNS).
class NetworkException extends AppException {
  const NetworkException(super.message, [super.originalError]);
}

/// Authentication failures (invalid credentials, expired session).
class AuthException extends AppException {
  const AuthException(super.message, [super.originalError]);
}

/// Database query failures (RLS denied, constraint violation).
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.originalError]);
}

/// Storage failures (upload failed, file not found, quota exceeded).
class AppStorageException extends AppException {
  const AppStorageException(super.message, [super.originalError]);
}
