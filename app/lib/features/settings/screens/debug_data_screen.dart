import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

// --- Debug Data Provider ---

final debugDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final client = ref.watch(supabaseClientProvider);

  // 1. Fetch system configs
  final configsData = await client.from('system_configs').select('*').order('config_key');
  
  // 2. Fetch system dictionaries and group by dict_type
  final dictsData = await client.from('system_dictionaries').select('*').order('dict_type').order('display_order');
  final dictsGrouped = <String, List<dynamic>>{};
  for (final row in dictsData) {
    final type = row['dict_type'] as String;
    dictsGrouped.putIfAbsent(type, () => []).add(row);
  }

  // 3. Fetch sensitive words and group by category/severity
  final wordsData = await client.from('sensitive_words').select('category, severity, is_active');
  final wordsGrouped = <String, int>{};
  for (final row in wordsData) {
    final cat = row['category'] as String? ?? 'general';
    final sev = row['severity'] as String? ?? 'warn';
    final key = '$cat ($sev)';
    wordsGrouped[key] = (wordsGrouped[key] ?? 0) + 1;
  }

  return {
    'system_configs': configsData,
    'system_dictionaries': dictsGrouped,
    'sensitive_words_summary': wordsGrouped,
  };
});

class DebugDataScreen extends ConsumerWidget {
  const DebugDataScreen({super.key});

  Future<void> _toggleConfig(WidgetRef ref, BuildContext context, Map<String, dynamic> config) async {
    final client = ref.read(supabaseClientProvider);
    final key = config['config_key'];
    final currentVal = config['config_value'];
    
    // Determine if it's a boolean value
    final isTrue = currentVal == true || currentVal == 'true';
    final isFalse = currentVal == false || currentVal == 'false';
    if (!isTrue && !isFalse) return;

    final newVal = isTrue ? false : true;
    try {
      await client.from('system_configs').update({
        'config_value': newVal,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('config_key', key);
      
      ref.invalidate(debugDataProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated $key to $newVal')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('DebugDataScreen: build() called');
    try {
      final colors = context.smivoColors;
      final typo = context.smivoTypo;
      debugPrint('DebugDataScreen: Theme initialized');
      final asyncData = ref.watch(debugDataProvider);
      debugPrint('DebugDataScreen: Provider watched, state: ${asyncData.runtimeType}');

      return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text('Debug Backend Data', style: typo.titleMedium),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.onSurface),
            onPressed: () => ref.invalidate(debugDataProvider),
          ),
        ],
      ),
      body: asyncData.when(
        loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (e, stackTrace) => Center(child: SelectableText('Provider Error:\n$e\n$stackTrace', style: TextStyle(color: colors.error))),
        data: (data) {
          try {
            final configs = data['system_configs'] as List<dynamic>;
            final dictsGrouped = data['system_dictionaries'] as Map<String, List<dynamic>>;
            final wordsSummary = data['sensitive_words_summary'] as Map<String, int>;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('System Configs', typo, colors),
                ...configs.map<Widget>((c) {
                  final configMap = c as Map;
                  final val = configMap['config_value'];
                  final isBool = val == true || val == false || val == 'true' || val == 'false';
                  final boolVal = val == true || val == 'true';
                  
                  return ListTile(
                    title: Text(configMap['config_key']?.toString() ?? 'Unknown', style: typo.bodyLarge),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isBool) ...[
                          Text(val?.toString() ?? '', style: typo.bodyMedium.copyWith(color: colors.primary)),
                          const SizedBox(height: 4),
                        ],
                        Text(configMap['description']?.toString() ?? '', style: typo.bodySmall),
                      ],
                    ),
                    trailing: isBool
                        ? Switch(
                            value: boolVal,
                            onChanged: (_) => _toggleConfig(ref, context, Map<String, dynamic>.from(configMap)),
                            activeThumbColor: colors.primary,
                            activeTrackColor: colors.primary.withAlpha(100),
                          )
                        : null,
                  );
                }),
                const Divider(height: 32),
                
                _buildSectionHeader('System Dictionaries', typo, colors),
                ...dictsGrouped.entries.map<Widget>((entry) {
                  return ExpansionTile(
                    title: Text('${entry.key} (${entry.value.length})', style: typo.bodyLarge),
                    children: entry.value.map<Widget>((dict) {
                      final dictMap = dict as Map;
                      return ListTile(
                        title: Text(dictMap['dict_key']?.toString() ?? dictMap['dict_value']?.toString() ?? 'Unknown', style: typo.bodyMedium),
                        subtitle: Text(dictMap['dict_value']?.toString() ?? '', style: typo.bodySmall),
                        trailing: Icon(
                          dictMap['is_active'] == true ? Icons.check_circle : Icons.cancel,
                          color: dictMap['is_active'] == true ? colors.success : colors.error,
                          size: 16,
                        ),
                      );
                    }).toList(),
                  );
                }),
                const Divider(height: 32),

                _buildSectionHeader('Sensitive Words Summary', typo, colors),
                if (wordsSummary.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No sensitive words configured.'),
                  )
                else
                  ...wordsSummary.entries.map<Widget>((e) => ListTile(
                    title: Text(e.key, style: typo.bodyLarge),
                    trailing: Text('${e.value} words', style: typo.bodyMedium),
                  )),
                  
                const SizedBox(height: 64),
              ],
            );
          } catch (e, stackTrace) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                'UI Build Error:\n$e\n\nStackTrace:\n$stackTrace',
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            );
          }
        },
      ),
    );
    } catch (e, st) {
      debugPrint('CRITICAL ERROR in DebugDataScreen build: $e\n$st');
      return Scaffold(
        appBar: AppBar(title: const Text('Fatal Error')),
        body: Center(child: Text('Fatal Error: $e')),
      );
    }
  }

  Widget _buildSectionHeader(String title, dynamic typo, dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: typo.titleMedium.copyWith(color: colors.primary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
