import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

part 'presence_provider.g.dart';

/// Reads the platform switch `presence.show_online_dot` from system_settings.
///
/// Returns true if the online dot should be shown, false otherwise.
/// Defaults to true if the setting is missing or cannot be read.
@Riverpod(keepAlive: true)
class PresenceConfig extends _$PresenceConfig {
  @override
  Future<bool> build() async {
    final supabase = ref.watch(supabaseClientProvider);
    try {
      final res = await supabase
          .from('system_settings')
          .select('value')
          .eq('key', 'presence.show_online_dot')
          .maybeSingle();
      if (res == null) return true;
      final val = res['value'];
      return val == true || val == 'true';
    } catch (_) {
      return true;
    }
  }
}
