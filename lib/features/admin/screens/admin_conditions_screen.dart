import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/school_condition.dart';
import 'package:smivo/data/repositories/school_data_repository.dart';
import 'package:smivo/features/admin/providers/admin_conditions_provider.dart';
import 'package:smivo/features/admin/providers/admin_school_provider.dart';

/// Admin screen for managing school-specific item conditions.
class AdminConditionsScreen extends ConsumerStatefulWidget {
  const AdminConditionsScreen({super.key});

  @override
  ConsumerState<AdminConditionsScreen> createState() => _AdminConditionsScreenState();
}

class _AdminConditionsScreenState extends ConsumerState<AdminConditionsScreen> {
  String? _selectedSchoolId;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final schoolsState = ref.watch(adminSchoolControllerProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text('Manage Conditions', style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (_selectedSchoolId != null)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add condition',
              onPressed: () => _showDialog(context, null),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // School selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: schoolsState.when(
              data: (schools) => DropdownButtonFormField<String>(
                initialValue: _selectedSchoolId,
                decoration: InputDecoration(
                  labelText: 'Select School',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.sm)),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                ),
                items: schools.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setState(() => _selectedSchoolId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
          Expanded(
            child: _selectedSchoolId == null
                ? Center(
                    child: Text(
                      'Select a school to manage its conditions.',
                      style: typo.bodyLarge.copyWith(color: colors.onSurfaceVariant),
                    ),
                  )
                : _buildList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final state = ref.watch(adminSchoolConditionsProvider(_selectedSchoolId!));

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: colors.error))),
      data: (conditions) {
        if (conditions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No conditions.', style: typo.bodyLarge.copyWith(color: colors.onSurfaceVariant)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await ref.read(schoolDataRepositoryProvider).seedSchoolDefaults(_selectedSchoolId!);
                    ref.invalidate(adminSchoolConditionsProvider(_selectedSchoolId!));
                  },
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Seed Defaults'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: conditions.length,
          itemBuilder: (context, index) {
            final cond = conditions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(radius.sm),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.star_half, color: Color(0xFF7C3AED), size: 20),
                ),
                title: Text(cond.name, style: typo.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${cond.description ?? "-"} • order: ${cond.displayOrder}',
                  style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: colors.primary),
                      onPressed: () => _showDialog(context, cond),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: colors.error),
                      onPressed: () => _confirmDelete(context, cond),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDialog(BuildContext context, SchoolCondition? condition) {
    showDialog(
      context: context,
      builder: (context) => _ConditionDialog(
        schoolId: _selectedSchoolId!,
        condition: condition,
        onSaved: () => ref.invalidate(adminSchoolConditionsProvider(_selectedSchoolId!)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SchoolCondition cond) {
    final colors = context.smivoColors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Condition'),
        content: Text('Delete "${cond.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(schoolDataRepositoryProvider).deleteCondition(cond.id);
              ref.invalidate(adminSchoolConditionsProvider(_selectedSchoolId!));
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

class _ConditionDialog extends ConsumerStatefulWidget {
  final String schoolId;
  final SchoolCondition? condition;
  final VoidCallback onSaved;

  const _ConditionDialog({required this.schoolId, this.condition, required this.onSaved});

  @override
  ConsumerState<_ConditionDialog> createState() => _ConditionDialogState();
}

class _ConditionDialogState extends ConsumerState<_ConditionDialog> {
  late final TextEditingController _slugCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _orderCtrl;
  late bool _isActive;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _slugCtrl = TextEditingController(text: widget.condition?.slug ?? '');
    _nameCtrl = TextEditingController(text: widget.condition?.name ?? '');
    _descCtrl = TextEditingController(text: widget.condition?.description ?? '');
    _orderCtrl = TextEditingController(text: widget.condition?.displayOrder.toString() ?? '0');
    _isActive = widget.condition?.isActive ?? true;
  }

  @override
  void dispose() {
    _slugCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cond = SchoolCondition(
      id: widget.condition?.id ?? '',
      schoolId: widget.schoolId,
      slug: _slugCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      displayOrder: int.tryParse(_orderCtrl.text.trim()) ?? 0,
      isActive: _isActive,
      createdAt: widget.condition?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(schoolDataRepositoryProvider).upsertCondition(cond);
    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.condition != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Condition' : 'New Condition'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slugCtrl,
                decoration: const InputDecoration(labelText: 'Slug'),
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
                controller: _orderCtrl,
                decoration: const InputDecoration(labelText: 'Display Order'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
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
