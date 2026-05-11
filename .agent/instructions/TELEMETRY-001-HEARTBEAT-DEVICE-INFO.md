# TELEMETRY-001: Heartbeat Device Telemetry

> **Priority**: Medium  
> **Complexity**: Medium  
> **Scope**: DB migration + Flutter app + Admin dashboard + Privacy policy  
> **Estimated effort**: ~1.5 hours

---

## Objective

Enhance the heartbeat system to collect device telemetry data (app version, 
build number, device model, OS, IP address, locale) for debugging and user 
experience improvements. Display this data in the admin user detail page, and 
update the privacy policy to disclose this collection.

---

## Part 1: Database Migration

**File**: `supabase/migrations/00143_heartbeat_device_telemetry.sql`

Add new columns to `user_heartbeats`:

```sql
ALTER TABLE public.user_heartbeats
  ADD COLUMN IF NOT EXISTS build_number text,
  ADD COLUMN IF NOT EXISTS device_model text,
  ADD COLUMN IF NOT EXISTS os_version text,
  ADD COLUMN IF NOT EXISTS ip_address inet,
  ADD COLUMN IF NOT EXISTS locale text;

COMMENT ON COLUMN public.user_heartbeats.app_version IS 'Semantic version e.g. 1.2.0';
COMMENT ON COLUMN public.user_heartbeats.build_number IS 'Build number e.g. 42';
COMMENT ON COLUMN public.user_heartbeats.device_model IS 'Device model e.g. iPhone 15 Pro, Pixel 8';
COMMENT ON COLUMN public.user_heartbeats.os_version IS 'OS + version e.g. iOS 17.4, Android 14';
COMMENT ON COLUMN public.user_heartbeats.ip_address IS 'Client IP from request headers';
COMMENT ON COLUMN public.user_heartbeats.locale IS 'Device locale e.g. en_US, zh_CN';
```

**IP address capture**: Use a `BEFORE INSERT OR UPDATE` trigger to auto-capture 
the client IP from `inet_client_addr()`. This avoids requiring the client to 
self-report its IP (which could be spoofed):

```sql
CREATE OR REPLACE FUNCTION public.capture_client_ip()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- NOTE: inet_client_addr() returns the real client IP as seen by PostgreSQL.
  -- For Supabase, this is the PostgREST/API gateway IP, so we also check 
  -- the request header. If neither works, fall back to NULL.
  NEW.ip_address := COALESCE(
    (current_setting('request.headers', true)::json->>'x-forwarded-for')::inet,
    inet_client_addr()
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_capture_client_ip
  BEFORE INSERT OR UPDATE ON public.user_heartbeats
  FOR EACH ROW EXECUTE FUNCTION capture_client_ip();
```

**Important**: The IP extraction from `x-forwarded-for` header might contain 
comma-separated values (e.g., `"1.2.3.4, 5.6.7.8"`). Take only the FIRST one:

```sql
-- Safer extraction: take first IP from x-forwarded-for
NEW.ip_address := COALESCE(
  (split_part(
    current_setting('request.headers', true)::json->>'x-forwarded-for',
    ',', 1
  )::text)::inet,
  inet_client_addr()
);
```

Test this in the Supabase SQL editor first before committing.

**Execute migration**: Use the runner script after creating the file:
```bash
./supabase/scripts/run_migration.sh 00143
```

---

## Part 2: Flutter App — Collect and Send Telemetry

### 2.1 Add dependencies

Run in `app/`:
```bash
flutter pub add package_info_plus device_info_plus
```

- `package_info_plus`: provides app version + build number
- `device_info_plus`: provides device model, OS version

### 2.2 Create device info utility

**File**: `app/lib/core/utils/device_info_service.dart`

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Collects device telemetry for heartbeat reporting.
/// All fields are non-PII device metadata used for debugging.
class DeviceInfoService {
  static DeviceInfoService? _instance;
  
  String? appVersion;
  String? buildNumber;
  String? deviceModel;
  String? osVersion;
  String? platform;
  String? locale;
  
  DeviceInfoService._();
  
  /// Singleton — device info doesn't change during app lifetime.
  static Future<DeviceInfoService> instance() async {
    if (_instance != null) return _instance!;
    
    final svc = DeviceInfoService._();
    await svc._init();
    _instance = svc;
    return svc;
  }
  
  Future<void> _init() async {
    // App version + build number
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;   // e.g. "1.2.0"
    buildNumber = packageInfo.buildNumber; // e.g. "42"
    
    // Platform
    if (kIsWeb) {
      platform = 'web';
      final webInfo = await DeviceInfoPlugin().webBrowserInfo;
      deviceModel = webInfo.browserName.name;  // e.g. "chrome"
      osVersion = webInfo.platform ?? 'web';
    } else if (Platform.isIOS) {
      platform = 'ios';
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      deviceModel = iosInfo.utsname.machine;  // e.g. "iPhone15,2"
      osVersion = 'iOS ${iosInfo.systemVersion}'; // e.g. "iOS 17.4"
    } else if (Platform.isAndroid) {
      platform = 'android';
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
      osVersion = 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
    } else {
      platform = 'unknown';
    }
    
    // Locale (from Platform)
    locale = kIsWeb ? 'web' : Platform.localeName; // e.g. "en_US"
  }
  
  /// Returns a map ready to be merged into the heartbeat upsert payload.
  Map<String, dynamic> toHeartbeatPayload() {
    return {
      'app_version': appVersion,
      'build_number': buildNumber,
      'device_model': deviceModel,
      'os_version': osVersion,
      'platform': platform,
      'locale': locale,
      // NOTE: ip_address is captured server-side via trigger — not sent by client
    };
  }
}
```

### 2.3 Update ProfileRepository.sendHeartbeat()

**File**: `app/lib/data/repositories/profile_repository.dart`

Update the `sendHeartbeat` method to accept and send the new fields:

```dart
/// Upserts heartbeat with device telemetry for online status + debugging.
Future<void> sendHeartbeat({
  required String userId,
  required Map<String, dynamic> deviceInfo,
}) async {
  await _client.from('user_heartbeats').upsert({
    'user_id': userId,
    'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    'updated_at': DateTime.now().toUtc().toIso8601String(),
    ...deviceInfo, // app_version, build_number, device_model, os_version, platform, locale
  }, onConflict: 'user_id');
}
```

Remove the old `appVersion` and `platform` named parameters since they're 
now part of `deviceInfo`.

### 2.4 Update HeartbeatManager provider

**File**: `app/lib/core/providers/heartbeat_provider.dart`

```dart
import 'dart:async';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/utils/device_info_service.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/data/repositories/profile_repository.dart';

part 'heartbeat_provider.g.dart';

/// Sends heartbeat every 5 minutes with device telemetry.
@Riverpod(keepAlive: true)
class HeartbeatManager extends _$HeartbeatManager {
  Timer? _timer;
  AppLifecycleListener? _listener;
  Map<String, dynamic>? _deviceInfo;

  @override
  void build() {
    _startHeartbeat();

    _listener = AppLifecycleListener(
      onResume: _startHeartbeat,
      onPause: _stopHeartbeat,
      onDetach: _stopHeartbeat,
    );

    ref.onDispose(() {
      _stopHeartbeat();
      _listener?.dispose();
    });
  }

  void _startHeartbeat() {
    _sendHeartbeat();
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _sendHeartbeat(),
    );
  }

  void _stopHeartbeat() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendHeartbeat() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      // Lazy-init device info — only resolved once per app session
      _deviceInfo ??= (await DeviceInfoService.instance()).toHeartbeatPayload();
      
      await ref
          .read(profileRepositoryProvider)
          .sendHeartbeat(userId: user.id, deviceInfo: _deviceInfo!);
    } catch (_) {
      // Heartbeat failure is non-critical — silently ignore
    }
  }
}
```

Remove the old `_getPlatform()` method — it's now part of DeviceInfoService.

### 2.5 Run code generation

```bash
cd app && dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

---

## Part 3: Admin Dashboard — Display Device Info

### 3.1 Update useUserDetail hook

**File**: `admin/src/hooks/useUsers.ts`

In `useUserDetail`, add a query to fetch the user's heartbeat:

After the `// 5. Fetch active bans` block (~line 166), add:

```typescript
// 6. Fetch latest heartbeat (device telemetry)
const { data: heartbeat } = await supabase
  .from('user_heartbeats')
  .select('last_seen_at, app_version, build_number, device_model, os_version, platform, ip_address, locale')
  .eq('user_id', userId)
  .maybeSingle();
```

Add `heartbeat` to the return object:

```typescript
return {
  user: { ... },
  listings: ...,
  orders: ...,
  bans: ...,
  heartbeat: heartbeat || null,  // ADD THIS
};
```

### 3.2 Update UserDetailPage

**File**: `admin/src/pages/users/UserDetailPage.tsx`

Add a "Device Info" card in the left column (profile card), below the 
"Active Restrictions" section (after line ~389). Destructure heartbeat from 
the data object at line 77: `const { user, listings, orders, heartbeat } = data;`

```tsx
{/* Device & Session Info */}
{heartbeat && (
  <div className="ud-device-card">
    <h4 className="ud-section-label">Device & Session</h4>
    <div className="ud-device-grid">
      <div className="ud-device-row">
        <span className="ud-device-label">Last Active</span>
        <span className="ud-device-value">
          {heartbeat.last_seen_at 
            ? new Date(heartbeat.last_seen_at).toLocaleString() 
            : '—'}
        </span>
      </div>
      <div className="ud-device-row">
        <span className="ud-device-label">App Version</span>
        <span className="ud-device-value">
          {heartbeat.app_version || '—'}
          {heartbeat.build_number && ` (${heartbeat.build_number})`}
        </span>
      </div>
      <div className="ud-device-row">
        <span className="ud-device-label">Platform</span>
        <span className="ud-device-value">{heartbeat.platform || '—'}</span>
      </div>
      <div className="ud-device-row">
        <span className="ud-device-label">Device</span>
        <span className="ud-device-value">{heartbeat.device_model || '—'}</span>
      </div>
      <div className="ud-device-row">
        <span className="ud-device-label">OS</span>
        <span className="ud-device-value">{heartbeat.os_version || '—'}</span>
      </div>
      <div className="ud-device-row">
        <span className="ud-device-label">IP Address</span>
        <span className="ud-device-value ud-device-mono">
          {heartbeat.ip_address || '—'}
        </span>
      </div>
      <div className="ud-device-row">
        <span className="ud-device-label">Locale</span>
        <span className="ud-device-value">{heartbeat.locale || '—'}</span>
      </div>
    </div>
  </div>
)}
```

Add these CSS rules inside the existing `<style>` block:

```css
/* Device Info Card */
.ud-device-card {
  border-top: 1px solid var(--color-border-light);
  padding-top: 16px;
}
.ud-device-grid {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.ud-device-row {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
  padding: 4px 0;
}
.ud-device-label {
  color: var(--color-text-secondary);
  flex-shrink: 0;
}
.ud-device-value {
  font-weight: 500;
  color: var(--color-text-primary);
  text-align: right;
  word-break: break-all;
}
.ud-device-mono {
  font-family: 'SF Mono', 'Fira Code', monospace;
  font-size: 12px;
}
```

### 3.3 Type check

```bash
cd admin && npx tsc -b
```

---

## Part 4: Privacy Policy Update

**File**: `website/privacy-policy.html`

### 4.1 Update "1.2 Information Collected Automatically" table

Replace the existing table (lines 161-166) with an expanded version:

```html
<h3>1.2 Information Collected Automatically</h3>
<table>
  <tr><th>Data Type</th><th>Purpose</th><th>Technology</th></tr>
  <tr><td>Device identifier</td><td>Push notification delivery</td><td>OneSignal SDK</td></tr>
  <tr><td>App version & build number</td><td>Debugging and compatibility tracking</td><td>In-app telemetry</td></tr>
  <tr><td>Device model & operating system</td><td>Debugging and experience optimization</td><td>In-app telemetry</td></tr>
  <tr><td>IP address</td><td>Security, fraud prevention, and debugging</td><td>Server logs</td></tr>
  <tr><td>Device locale</td><td>Language and regional experience</td><td>In-app telemetry</td></tr>
  <tr><td>App usage data</td><td>Service improvement and debugging</td><td>Supabase Analytics</td></tr>
</table>
<p>This diagnostic data is collected periodically while you use the app and is used <strong>solely</strong> for debugging issues, improving app performance, and ensuring a smooth user experience. We do not use this information for advertising or user profiling.</p>
```

### 4.2 Update "Last updated" date

Change line 136:
```html
<p>Last updated: May 11, 2026</p>
```

---

## Verification Checklist

- [ ] Migration 00143 executed successfully
- [ ] `flutter pub add package_info_plus device_info_plus` completed
- [ ] `DeviceInfoService` created and collecting all fields
- [ ] `ProfileRepository.sendHeartbeat()` updated
- [ ] `HeartbeatManager` updated, removed old `_getPlatform()`
- [ ] `dart run build_runner build` succeeds
- [ ] `flutter analyze` → 0 errors
- [ ] Admin `useUserDetail` hook fetches heartbeat data
- [ ] Admin `UserDetailPage` displays device info card
- [ ] `npx tsc -b` passes (admin)
- [ ] Privacy policy updated with new data types + date
- [ ] Test: open app, wait 5 min, check `user_heartbeats` table for new fields
- [ ] Test: admin user detail page shows device info

---

## Notes

- **IP address is captured server-side** via PostgreSQL trigger, not sent by 
  the client. This prevents client-side IP spoofing.
- **Device info is cached** in `DeviceInfoService._instance` — resolved once 
  per app session, not on every heartbeat tick.
- **locale** uses `Platform.localeName` which gives the device's current 
  locale setting (e.g., "en_US"), not the app's language.
- The existing `platform` field is preserved and now populated by 
  `DeviceInfoService` instead of the old `_getPlatform()` method.
