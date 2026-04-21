import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

/// App entry point.
///
/// Initializes dotenv, Supabase, and wraps the app in ProviderScope
/// for Riverpod dependency injection.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file.
  await dotenv.load(fileName: '.env');

  // Initialize Supabase with credentials from .env.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // NOTE: Initialize OneSignal here in Phase 2. See project-brief.md.

  runApp(
    const ProviderScope(
      child: SmivoApp(),
    ),
  );
}
