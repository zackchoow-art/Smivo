import 'dart:async';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/utils/device_info_service.dart';
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
      _deviceInfo ??= (await DeviceInfoService.instance()).toHeartbeatPayload();
      
      await ref
          .read(profileRepositoryProvider)
          .sendHeartbeat(userId: user.id, deviceInfo: _deviceInfo!);
    } catch (_) {
      // Heartbeat failure is non-critical — silently ignore
    }
  }
}
