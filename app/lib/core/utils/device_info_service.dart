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
