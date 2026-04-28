import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'app.dart';

/// App entry point.
///
/// Initializes dotenv, Supabase, and wraps the app in ProviderScope
/// for Riverpod dependency injection.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from assets/env file.
  await dotenv.load(fileName: 'assets/env');

  // Initialize Supabase with credentials from .env.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize OneSignal for push notifications.
  final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  if (oneSignalAppId.isNotEmpty) {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose); // TODO: Remove in production
    OneSignal.initialize(oneSignalAppId);
  }

  runApp(
    const ProviderScope(
      child: SmivoApp(),
    ),
  );
}
