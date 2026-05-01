import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/data/repositories/profile_repository.dart';

part 'heartbeat_provider.g.dart';

/// Sends heartbeat every 5 minutes while the app is in foreground.
/// keepAlive: true — lives for the entire app session.
///
/// Uses AppLifecycleListener (Flutter 3.13+) to pause heartbeat
/// when app goes to background and resume when returning.
@Riverpod(keepAlive: true)
class HeartbeatManager extends _$HeartbeatManager {
  Timer? _timer;
  AppLifecycleListener? _listener;

  @override
  void build() {
    // Start heartbeat on build
    _startHeartbeat();

    // Listen to app lifecycle
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
    // Send immediately, then every 5 minutes
    _sendHeartbeat();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _sendHeartbeat());
  }

  void _stopHeartbeat() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendHeartbeat() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      await ref.read(profileRepositoryProvider).sendHeartbeat(
        userId: user.id,
        platform: _getPlatform(),
      );
    } catch (_) {
      // Heartbeat failure is non-critical — silently ignore
    }
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }
}
