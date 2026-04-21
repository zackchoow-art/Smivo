/// Validation helpers for form inputs.
///
/// All validators return null on success or an error message on failure,
/// matching the signature expected by TextFormField's `validator`.
///
/// Email input convention:
///   Users type ONLY the prefix (e.g. "jsmith"). The app appends the
///   school domain (e.g. "@smith.edu") before calling Supabase.
///   When multiple schools are supported (Phase 2), the domain will come
///   from a school selector dropdown — users still only type the prefix.
class Validators {
  Validators._();

  // ── Boolean helpers (used inside providers before throwing) ─

  /// Returns true if [fullEmail] ends with a .edu TLD (case-insensitive).
  ///
  /// Used as a final safety check on the assembled full email before
  /// sending to Supabase. The database trigger is the ultimate guard.
  static bool isEduEmail(String fullEmail) =>
      fullEmail.trim().toLowerCase().endsWith('.edu');

  /// Returns true if [password] meets minimum strength:
  /// ≥8 characters, ≥1 letter (a–z / A–Z), ≥1 digit.
  static bool isStrongPassword(String password) =>
      password.length >= 8 &&
      RegExp(r'[a-zA-Z]').hasMatch(password) &&
      RegExp(r'[0-9]').hasMatch(password);

  // ── Form validators (return String? for TextFormField) ──────

  /// Validates an email PREFIX — the part the user actually types.
  ///
  /// The full email is assembled as: "${prefix.trim()}@smith.edu"
  /// Only letters, digits, dots, underscores, and hyphens are allowed.
  /// Maximum prefix length is 64 characters (RFC 5321 local-part limit).
  ///
  /// Example valid inputs: "jsmith", "j.smith", "j_smith2"
  static String? emailPrefix(String? prefix) {
    if (prefix == null || prefix.trim().isEmpty) {
      return 'Please enter your university username';
    }
    final trimmed = prefix.trim();
    if (trimmed.length > 64) {
      return 'Username is too long';
    }
    // Only allow characters safe in an email local-part
    if (!RegExp(r'^[a-zA-Z0-9._\-]+$').hasMatch(trimmed)) {
      return 'Username can only contain letters, numbers, dots, underscores, and hyphens';
    }
    return null;
  }

  /// Validates a full .edu email address (used for debug-mode full-email input).
  ///
  /// NOTE: This is only called when [kDebugBackdoorEnabled] is true and the
  /// user has switched to full-email mode. Never called in normal flow.
  static String? eduEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    if (!email.trim().contains('@')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates that [value] is not null or empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates that [value] is a valid non-negative price.
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Please enter a valid number';
    }
    if (parsed < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  /// Validates password meets Smivo's minimum strength requirements.
  ///
  /// Rules: ≥8 characters, at least one letter, at least one digit.
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates that [confirm] matches [password].
  static String? confirmPassword(String? password, String? confirm) {
    if (confirm == null || confirm.isEmpty) return 'Please confirm your password';
    if (password != confirm) return 'Passwords do not match';
    return null;
  }
}
