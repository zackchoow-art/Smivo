// ⚠️ WARNING: Set kDebugBackdoorEnabled = false BEFORE deploying to production.
// Also run 00004_remove_debug_backdoor.sql in Supabase to clean up the database.
//
// This file exists solely to unblock development when real .edu email accounts
// are not available for testing. All backdoor code paths are guarded by
// kDebugBackdoorEnabled so they can never accidentally reach production
// if this flag is properly set to false.

/// Whether the debug authentication backdoor is active.
///
/// When true:
/// - The email prefix input switches to full-email mode for allowed test accounts
/// - .edu validation is skipped for [kDebugAllowedEmails]
/// - The database trigger also permits these emails (see 00003_debug_backdoor.sql)
///
/// MUST be false before any production deployment.
// HACK: Temporary development backdoor — must be reverted before launch.
const bool kDebugBackdoorEnabled = true;

/// Test accounts that bypass .edu validation when [kDebugBackdoorEnabled] is true.
///
/// These are fake Smivo-internal addresses used only for local/staging testing.
/// They must also be whitelisted in the Supabase database function
/// (see supabase/migrations/00003_debug_backdoor.sql).
const List<String> kDebugAllowedEmails = [
  'test1@smivo.dev',
  'test2@smivo.dev',
  'test3@smivo.dev',
];
