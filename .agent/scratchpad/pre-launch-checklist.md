# Smivo Production Launch Checklist

## Database Cleanup
- [ ] **Remove Debug Backdoor**: Run `supabase/migrations/00004_remove_debug_backdoor.sql` in the production Supabase SQL Editor.
- [ ] **Clean Trigger Logic**: Verify `handle_new_user()` function in Supabase no longer contains any `@smivo.dev` or test email logic.
- [ ] **Purge Test Users**: Delete `test1@smivo.dev`, `test2@smivo.dev`, and `test3@smivo.dev` from the Supabase Auth dashboard.
- [ ] **Audit RLS Policies**: Verify Row Level Security (RLS) is enabled and correctly configured on all 7 tables:
    - `user_profiles`
    - `listings`
    - `listing_images`
    - `saved_listings`
    - `orders`
    - `chat_rooms`
    - `messages`
- [ ] **Storage Security**: Verify `listing-images` and `avatars` bucket policies strictly restrict `INSERT/UPDATE/DELETE` paths to `auth.uid()`.
- [ ] **Domain Restriction**: Test that a non-.edu email is rejected by the database (e.g., try registering `abc@gmail.com` from the app, should fail).
- [ ] **Verification Logic**: Test that the email verification trigger works (i.e., `is_verified` in `user_profiles` auto-updates to `true` after confirming email).
- [ ] **Security Smoke Test**:
    - [ ] Verify anonymous users cannot read `user_profiles`.
    - [ ] Verify User A cannot read User B's `orders`.
    - [ ] Verify User A cannot read User B's `chat_rooms` or `messages`.

## Code Cleanup
- [ ] **Disable Debug Flags**: Set `kDebugBackdoorEnabled = false` in `lib/core/constants/debug_constants.dart`.
- [ ] **Hide Debug UI**: Verify the "Debug Login" toggle in `login_screen.dart` is either removed or logically hidden in release builds.
- [ ] **Static Analysis**: Run `flutter analyze` and fix all warnings.
- [ ] **Formatting**: Run `dart format .` to ensure consistent formatting across the codebase.
- [ ] **Dead Code**: Remove unused imports, unused variables, and unreachable code.
- [ ] **Subscription Cleanup**: Verify all providers have proper `ref.onDispose` to cancel subscriptions (especially for chat Realtime channels).
- [ ] **TODO Audit**: Search codebase for `TODO` comments and resolve any that are critical for MVP.
- [ ] **Remove Hardcoded Data**: Search for any hardcoded test emails (e.g., `grep -r "test1@smivo.dev" .`) and remove them.
- [ ] **Placeholder Removal**: Ensure no "Coming Soon" or placeholder screens are accessible to real users.

## Supabase Project Settings
- [ ] **New Project**: Provision a dedicated **Production** Supabase project (do not use the development instance).
- [ ] **SMTP Provider**: Configure a custom SMTP provider (e.g., SendGrid, Resend, AWS SES) for verification emails. *The default Supabase SMTP has a 3-email-per-hour limit.*
- [ ] **Redirect Whitelist**: Add the production web URL and custom app schemes (e.g., `com.smivo://*`) to the Supabase Auth Redirect URLs.
- [ ] **Auth Hardening**: 
    - Set minimum password length (e.g., 8+ characters).
    - Review session duration and refresh token rotation settings.
- [ ] **Backup Policy**: Enable daily backups (requires Supabase Pro plan).
- [ ] **Monitoring**: Set up Supabase Log Alerts or external monitoring for database errors.

## Environment Variables
- [ ] **Production Config**: Copy `.env.example` to `.env`.
- [ ] **Fill Secrets**: 
    - `SUPABASE_URL`: Fill with production URL.
    - `SUPABASE_ANON_KEY`: Fill with production Anon key.
- [ ] **GitIgnore**: Confirm `.env` is listed in `.gitignore` to prevent accidental credential leakage.

## Build Configuration
- [ ] **Versioning**: Update `version:` in `pubspec.yaml` (e.g., `1.0.0+1`).
- [ ] **iOS Identity**: Set Bundle Identifier to `com.smivo` in Xcode.
- [ ] **Android Identity**: Set `applicationId` to `com.smivo` in `android/app/build.gradle`.
- [ ] **SDK Targets**: Verify `minSdkVersion` (26+) and `targetSdkVersion` match store requirements.
- [ ] **Branding**:
    - [ ] Generate and add app icons for all iOS/Android sizes.
    - [ ] Add native splash screen assets.

## App Store / Play Store
- [ ] **iOS Listing**: Create app entry in App Store Connect.
- [ ] **Android Listing**: Create app entry in Google Play Console.
- [ ] **Legal URLs**:
    - [ ] Privacy Policy URL (hosted on smivo.com or similar).
    - [ ] Terms of Service URL.
- [ ] **Store Assets**:
    - [ ] Take high-quality screenshots for all required device sizes (iPhone 6.7", 6.5", 5.5", Android Phone/Tablet).
    - [ ] Write localized app descriptions, keywords, and support info.

## Legal & Safety
- [ ] **Community Standards**: Publish guidelines on acceptable/prohibited items.
- [ ] **Terms & Privacy**: Finalize legal documents, specifically mentioning `.edu` email verification and data handling.
- [ ] **Moderation Plan**: Define how reported listings or users will be reviewed and removed.
- [ ] **Reporting Flow**: Ensure users can report a listing or another user from within the app.

## Performance & Cost
- [ ] **Plan Check**: Review Supabase usage dashboard and confirm the project is on the **Pro plan** for production.
- [ ] **Cost Estimation**: Estimate monthly costs based on expected user count (Compute, Egress, Storage).
- [ ] **Billing Alerts**: Set billing alerts at 50%, 80%, and 100% of the monthly budget.
- [ ] **Query Audit**: Review if any frequent queries are performing full table scans (check slow query logs).
- [ ] **Index Verification**: Verify indexes exist on all commonly-queried fields:
    - `seller_id`, `status`, `category`, `created_at` (listings)
    - `buyer_id`, `seller_id` (orders/chat)
- [ ] **Image Optimization**: Confirm images are compressed/resized before upload to avoid storage bloat and bandwidth overages.
- [ ] **CDN Activation**: Enable Supabase CDN for the `listing-images` bucket to reduce egress costs.

## Error Handling & Recovery
- [ ] **Offline Behavior**: Test app behavior when Supabase is unreachable (backend down).
- [ ] **Network Loss**: Test app behavior in Airplane Mode (no internet).
- [ ] **User-Friendly Errors**: Verify all `AppException` messages are friendly (no raw Supabase/SQL strings in the UI).
- [ ] **Auto-Reconnect**: Test that the app automatically recovers and refreshes when the network connection is restored.
- [ ] **Realtime Recovery**: Verify Realtime subscriptions successfully reconnect after a network interruption.

## Smoke Test Before Launch
- [ ] **End-to-End Auth**: Register a real `.edu` account and verify the email link works.
- [ ] **Email Performance**: Confirm verification email arrives within 2 minutes.
- [ ] **Listing Creation**: Post a listing with multiple photos and verify they appear in the feed.
- [ ] **Inter-Account Interaction**: Use a second account to browse, message, and save the listing.
- [ ] **Transaction Flow**: Complete an order flow (request -> confirm -> complete).
- [ ] **Persistence**: Logout and re-login to ensure all data (profile, saves, history) is preserved.
