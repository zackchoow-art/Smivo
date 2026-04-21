import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform detection helpers.
///
/// Per architecture.md: platform checks must live in core/utils/ only,
/// never inside widgets or providers.
class PlatformUtils {
  PlatformUtils._();

  /// True when running in a web browser.
  static bool get isWeb => kIsWeb;

  /// True when running on iOS (not web).
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// True when running on Android (not web).
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// True when running on any mobile platform.
  static bool get isMobile => isIOS || isAndroid;
}
