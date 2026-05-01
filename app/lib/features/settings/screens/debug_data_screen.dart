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
    
    // Determine if it's a boolean value string
    if (currentVal != 'true' && currentVal != 'false') return;

    final newVal = currentVal == 'true' ? 'false' : 'true';
    try {
      await client.from('system_configs').update({
        'config_value': newVal,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', config['id']);
      
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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final asyncData = ref.watch(debugDataProvider);

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
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: colors.error))),
        data: (data) {
          final configs = data['system_configs'] as List<dynamic>;
          final dictsGrouped = data['system_dictionaries'] as Map<String, List<dynamic>>;
          final wordsSummary = data['sensitive_words_summary'] as Map<String, int>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('System Configs', typo, colors),
              ...configs.map((c) {
                final isBool = c['config_value'] == 'true' || c['config_value'] == 'false';
                return ListTile(
                  title: Text(c['config_key'], style: typo.bodyLarge),
                  subtitle: Text(c['description'] ?? '', style: typo.bodySmall),
                  trailing: isBool
                      ? Switch(
                          value: c['config_value'] == 'true',
                          onChanged: (_) => _toggleConfig(ref, context, c),
                          activeColor: colors.primary,
                        )
                      : Text(c['config_value'].toString(), style: typo.bodyMedium),
                );
              }),
              const Divider(height: 32),
              
              _buildSectionHeader('System Dictionaries', typo, colors),
              ...dictsGrouped.entries.map((entry) {
                return ExpansionTile(
                  title: Text('${entry.key} (${entry.value.length})', style: typo.bodyLarge),
                  children: entry.value.map((dict) {
                    return ListTile(
                      title: Text(dict['dict_key'] ?? dict['dict_value'] ?? 'Unknown', style: typo.bodyMedium),
                      subtitle: Text(dict['dict_value'] ?? '', style: typo.bodySmall),
                      trailing: Icon(
                        dict['is_active'] == true ? Icons.check_circle : Icons.cancel,
                        color: dict['is_active'] == true ? colors.success : colors.error,
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
                ...wordsSummary.entries.map((e) => ListTile(
                  title: Text(e.key, style: typo.bodyLarge),
                  trailing: Text('${e.value} words', style: typo.bodyMedium),
                )),
                
              const SizedBox(height: 64),
            ],
          );
        },
      ),
    );
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
