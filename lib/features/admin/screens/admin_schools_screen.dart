import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/school.dart';
import 'package:smivo/features/admin/providers/admin_school_provider.dart';

class AdminSchoolsScreen extends ConsumerWidget {
  const AdminSchoolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final schoolsState = ref.watch(adminSchoolControllerProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Manage Schools'),
        backgroundColor: colors.surfaceContainerLowest,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add new school',
            onPressed: () => _showSchoolDialog(context, ref, null),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: schoolsState.when(
        data: (schools) {
          if (schools.isEmpty) {
            return const Center(child: Text('No schools found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: schools.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final school = schools[index];
              return ListTile(
                title: Row(
                  children: [
                    Text(school.name, style: typo.titleMedium),
                    const SizedBox(width: 8),
                    if (school.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Active',
                          style: typo.labelSmall.copyWith(color: colors.primary),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  'Domain: @${school.emailDomain} • Slug: ${school.slug}',
                  style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: colors.primary,
                      onPressed: () => _showSchoolDialog(context, ref, school),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: colors.error),
                      onPressed: () => _confirmDelete(context, ref, school),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading schools: $err', style: TextStyle(color: colors.error)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSchoolDialog(context, ref, null),
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: colors.onPrimary),
      ),
    );
  }

  void _showSchoolDialog(BuildContext context, WidgetRef ref, School? school) {
    showDialog(
      context: context,
      builder: (context) => _SchoolDialog(school: school),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, School school) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete School'),
        content: Text('Are you sure you want to delete "${school.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(adminSchoolControllerProvider.notifier).deleteSchool(school.id);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: context.smivoColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SchoolDialog extends ConsumerStatefulWidget {
  final School? school;
  const _SchoolDialog({this.school});

  @override
  ConsumerState<_SchoolDialog> createState() => _SchoolDialogState();
}

class _SchoolDialogState extends ConsumerState<_SchoolDialog> {
  late final TextEditingController _slugCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _domainCtrl;
  late final TextEditingController _colorCtrl;
  late bool _isActive;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _slugCtrl = TextEditingController(text: widget.school?.slug ?? '');
    _nameCtrl = TextEditingController(text: widget.school?.name ?? '');
    _domainCtrl = TextEditingController(text: widget.school?.emailDomain ?? '');
    _colorCtrl = TextEditingController(text: widget.school?.primaryColor ?? '');
    _isActive = widget.school?.isActive ?? false;
  }

  @override
  void dispose() {
    _slugCtrl.dispose();
    _nameCtrl.dispose();
    _domainCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newSchool = School(
      id: widget.school?.id ?? '',
      slug: _slugCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      emailDomain: _domainCtrl.text.trim(),
      primaryColor: _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
      isActive: _isActive,
      createdAt: widget.school?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.school == null) {
      ref.read(adminSchoolControllerProvider.notifier).addSchool(newSchool);
    } else {
      ref.read(adminSchoolControllerProvider.notifier).updateSchool(newSchool);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.school != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit School' : 'New School'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name (e.g. Smith College)'),
                validator: (val) => val != null && val.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slugCtrl,
                decoration: const InputDecoration(labelText: 'Slug (e.g. smith)'),
                validator: (val) => val != null && val.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _domainCtrl,
                decoration: const InputDecoration(labelText: 'Email Domain (e.g. smith.edu)'),
                validator: (val) => val != null && val.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorCtrl,
                decoration: const InputDecoration(labelText: 'Primary Color Hex (optional)'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Active'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
