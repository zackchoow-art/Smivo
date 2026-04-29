import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

/// Provides the [SupabaseClient] instance to all repositories.
///
/// This is the single source of truth for the Supabase client.
/// Repositories receive it via Riverpod injection — they never
/// call Supabase.instance directly.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;
