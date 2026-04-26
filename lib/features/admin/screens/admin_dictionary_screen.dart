import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/system_dictionary.dart';
import 'package:smivo/data/repositories/school_data_repository.dart';
import 'package:smivo/features/admin/providers/admin_dictionary_provider.dart';

/// Admin screen for managing system data dictionaries.
class AdminDictionaryScreen extends ConsumerStatefulWidget {
  const AdminDictionaryScreen({super.key});

  @override
  ConsumerState<AdminDictionaryScreen> createState() => _AdminDictionaryScreenState();
}

class _AdminDictionaryScreenState extends ConsumerState<AdminDictionaryScreen> {
  String _selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final dictState = ref.watch(adminDictionariesProvider());
    final typesState = ref.watch(adminDictTypesProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text('System Dictionary', style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add entry',
            onPressed: () => _showDialog(context, null),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminDictionariesProvider);
              ref.invalidate(adminDictTypesProvider);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Type filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: typesState.when(
              data: (types) => Row(
                children: [
                  Text('Filter: ', style: typo.labelLarge),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip('All', 'all', colors),
                          ...types.map((t) => _filterChip(t, t, colors)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ),

          // Dictionary entries
          Expanded(
            child: dictState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: colors.error))),
              data: (entries) {
                final filtered = _selectedType == 'all'
                    ? entries
                    : entries.where((d) => d.dictType == _selectedType).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text('No entries.', style: typo.bodyLarge.copyWith(color: colors.onSurfaceVariant)),
                  );
                }

                // Group by dict_type
                final grouped = <String, List<SystemDictionary>>{};
                for (final d in filtered) {
                  grouped.putIfAbsent(d.dictType, () => []).add(d);
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  children: grouped.entries.map((group) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  group.key,
                                  style: typo.labelLarge.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${group.value.length} entries',
                                style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        ...group.value.map((dict) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(radius.sm),
                            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          child: ListTile(
                            dense: true,
                            title: Row(
                              children: [
                                // Color swatch from extra
                                if (dict.extra != null && dict.extra!['color'] != null)
                                  Container(
                                    width: 12, height: 12,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: _parseColor(dict.extra!['color']),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Text(
                                  '${dict.dictKey} → ${dict.dictValue}',
                                  style: typo.titleMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ],
                            ),
                            subtitle: dict.description != null
                                ? Text(dict.description!, style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant))
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, size: 18, color: colors.primary),
                                  onPressed: () => _showDialog(context, dict),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, size: 18, color: colors.error),
                                  onPressed: () => _confirmDelete(context, dict),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, dynamic colors) {
    final isSelected = _selectedType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedType = value),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  void _showDialog(BuildContext context, SystemDictionary? dict) {
    showDialog(
      context: context,
      builder: (context) => _DictionaryDialog(
        dict: dict,
        onSaved: () {
          ref.invalidate(adminDictionariesProvider);
          ref.invalidate(adminDictTypesProvider);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, SystemDictionary dict) {
    final colors = context.smivoColors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Delete "${dict.dictKey}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(schoolDataRepositoryProvider).deleteDictionary(dict.id);
              ref.invalidate(adminDictionariesProvider);
              ref.invalidate(adminDictTypesProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DictionaryDialog extends ConsumerStatefulWidget {
  final SystemDictionary? dict;
  final VoidCallback onSaved;

  const _DictionaryDialog({this.dict, required this.onSaved});

  @override
  ConsumerState<_DictionaryDialog> createState() => _DictionaryDialogState();
}

class _DictionaryDialogState extends ConsumerState<_DictionaryDialog> {
  late final TextEditingController _typeCtrl;
  late final TextEditingController _keyCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _orderCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _iconCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _typeCtrl = TextEditingController(text: widget.dict?.dictType ?? '');
    _keyCtrl = TextEditingController(text: widget.dict?.dictKey ?? '');
    _valueCtrl = TextEditingController(text: widget.dict?.dictValue ?? '');
    _descCtrl = TextEditingController(text: widget.dict?.description ?? '');
    _orderCtrl = TextEditingController(text: widget.dict?.displayOrder.toString() ?? '0');
    _colorCtrl = TextEditingController(text: widget.dict?.extra?['color'] ?? '');
    _iconCtrl = TextEditingController(text: widget.dict?.extra?['icon'] ?? '');
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    _descCtrl.dispose();
    _orderCtrl.dispose();
    _colorCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic>? extra;
    if (_colorCtrl.text.trim().isNotEmpty || _iconCtrl.text.trim().isNotEmpty) {
      extra = {};
      if (_colorCtrl.text.trim().isNotEmpty) extra['color'] = _colorCtrl.text.trim();
      if (_iconCtrl.text.trim().isNotEmpty) extra['icon'] = _iconCtrl.text.trim();
    }

    final dict = SystemDictionary(
      id: widget.dict?.id ?? '',
      dictType: _typeCtrl.text.trim(),
      dictKey: _keyCtrl.text.trim(),
      dictValue: _valueCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      extra: extra,
      displayOrder: int.tryParse(_orderCtrl.text.trim()) ?? 0,
      createdAt: widget.dict?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(schoolDataRepositoryProvider).upsertDictionary(dict);
    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.dict != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Entry' : 'New Entry'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _typeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dict Type',
                  hintText: 'e.g. order_status',
                ),
                validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Key',
                  hintText: 'e.g. pending',
                ),
                validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueCtrl,
                decoration: const InputDecoration(
                  labelText: 'Display Value',
                  hintText: 'e.g. Pending',
                ),
                validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Color Hex (optional)',
                  hintText: '#D97706',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _iconCtrl,
                decoration: const InputDecoration(
                  labelText: 'Icon Name (optional)',
                  hintText: 'schedule',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderCtrl,
                decoration: const InputDecoration(labelText: 'Display Order'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: Text(isEditing ? 'Save' : 'Add')),
      ],
    );
  }
}
