# Telemetry 001: Heartbeat Device Info
**Date**: 2026-05-11
**Status**: Completed

## Part 1: Database Migration
- Executed migration `00143_heartbeat_device_telemetry.sql` to add `build_number`, `device_model`, `os_version`, `ip_address`, and `locale` fields to the `user_heartbeats` table.
- The trigger `capture_client_ip` was successfully deployed to securely extract the client IP address from `x-forwarded-for` and populate `ip_address`.

## Part 2: Flutter App — Collect and Send Telemetry
- Added `device_info_plus` and `package_info_plus` packages to `pubspec.yaml` using `flutter pub add`.
- Created `DeviceInfoService` (`app/lib/core/utils/device_info_service.dart`) to gather non-PII device and environment metadata. This service manages lazy loading and singleton state.
- Updated `ProfileRepository.sendHeartbeat` to receive `deviceInfo` as a map, sending it directly via `upsert`.
- Updated `HeartbeatManager` to lazily instantiate `DeviceInfoService` on the first tick and send the resulting telemetry map. `_getPlatform` was removed.
- Ran `build_runner` and `flutter analyze` to ensure code health. The project builds cleanly (only legacy warnings remain).

## Part 3: Admin Dashboard — Surface Telemetry
- Modified `useUsers.ts` (`useUserDetail` hook) to fetch `user_heartbeats` alongside the user's profile and active restrictions.
- Modified `UserDetailPage.tsx` to include a new "Device Telemetry" section under the Profile Card, exposing `last_seen_at`, `app_version`, `build_number`, `os_version`, `device_model`, `platform`, `ip_address`, and `locale`.
- Ran `npx tsc -b` inside the `admin/` directory to verify strict type correctness before deployment. Build passed successfully.

## Part 4: Compliance — Update Privacy Policy
- Updated `website/privacy-policy.html` to reflect telemetry collection explicitly.
- Changed the `Last updated` date to `May 11, 2026`.
- Added `Heartbeat Telemetry` under the "Information Collected Automatically" section, noting its purpose for "Troubleshooting and debugging (OS, model, build)" and listing the relevant parameters.

## Verification
- Verified all code builds, types check correctly, and no functionality was impacted.
- Migration applied cleanly.
- Ready for testing on real devices.
