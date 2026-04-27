import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/school.dart';
import 'package:smivo/features/admin/providers/admin_auth_provider.dart';
import 'package:smivo/features/admin/providers/admin_school_provider.dart';

class AdminSchoolsScreen extends ConsumerWidget {
  const AdminSchoolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final schoolsState = ref.watch(adminSchoolControllerProvider);
    final adminCtx = ref.watch(adminContextProvider).valueOrNull;
    final canWrite = adminCtx?.canWrite(AdminModule.schools) ?? false;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Manage Schools'),
        backgroundColor: colors.surfaceContainerLowest,
        actions: [
          if (canWrite)
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
                trailing: canWrite
                    ? Row(
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
                      )
                    : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading schools: $err', style: TextStyle(color: colors.error)),
        ),
      ),
      floatingActionButton: canWrite
          ? FloatingActionButton(
              onPressed: () => _showSchoolDialog(context, ref, null),
              backgroundColor: colors.primary,
              child: Icon(Icons.add, color: colors.onPrimary),
            )
          : null,
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
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _zipCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _studentCountCtrl;
  late bool _isActive;
  bool _seedDefaults = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _slugCtrl = TextEditingController(text: widget.school?.slug ?? '');
    _nameCtrl = TextEditingController(text: widget.school?.name ?? '');
    _domainCtrl = TextEditingController(text: widget.school?.emailDomain ?? '');
    _colorCtrl = TextEditingController(text: widget.school?.primaryColor ?? '');
    _addressCtrl = TextEditingController(text: widget.school?.address ?? '');
    _cityCtrl = TextEditingController(text: widget.school?.city ?? '');
    _stateCtrl = TextEditingController(text: widget.school?.state ?? '');
    _zipCtrl = TextEditingController(text: widget.school?.zipCode ?? '');
    _latCtrl = TextEditingController(text: widget.school?.latitude?.toString() ?? '');
    _lngCtrl = TextEditingController(text: widget.school?.longitude?.toString() ?? '');
    _websiteCtrl = TextEditingController(text: widget.school?.websiteUrl ?? '');
    _descCtrl = TextEditingController(text: widget.school?.description ?? '');
    _studentCountCtrl = TextEditingController(text: widget.school?.studentCount?.toString() ?? '');
    _isActive = widget.school?.isActive ?? false;
  }

  @override
  void dispose() {
    _slugCtrl.dispose();
    _nameCtrl.dispose();
    _domainCtrl.dispose();
    _colorCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _websiteCtrl.dispose();
    _descCtrl.dispose();
    _studentCountCtrl.dispose();
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
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim().isEmpty ? null : _stateCtrl.text.trim(),
      zipCode: _zipCtrl.text.trim().isEmpty ? null : _zipCtrl.text.trim(),
      latitude: double.tryParse(_latCtrl.text.trim()),
      longitude: double.tryParse(_lngCtrl.text.trim()),
      websiteUrl: _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      studentCount: int.tryParse(_studentCountCtrl.text.trim()),
      createdAt: widget.school?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.school == null) {
      ref.read(adminSchoolControllerProvider.notifier).addSchool(
        newSchool,
        seedDefaults: _seedDefaults,
      );
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
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Basic Info ──
                Text('Basic Info', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name (e.g. Smith College)'),
                  validator: (val) => val != null && val.trim().isNotEmpty ? null : 'Required',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _slugCtrl,
                        decoration: const InputDecoration(labelText: 'Slug'),
                        validator: (val) => val != null && val.trim().isNotEmpty ? null : 'Required',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _domainCtrl,
                        decoration: const InputDecoration(labelText: 'Email Domain'),
                        validator: (val) => val != null && val.trim().isNotEmpty ? null : 'Required',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),

                const SizedBox(height: 24),
                Text('Location', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _stateCtrl, decoration: const InputDecoration(labelText: 'State'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _zipCtrl, decoration: const InputDecoration(labelText: 'ZIP'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _latCtrl, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _lngCtrl, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: TextInputType.number)),
                  ],
                ),

                const SizedBox(height: 24),
                Text('Branding', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _colorCtrl, decoration: const InputDecoration(labelText: 'Primary Color Hex'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _websiteCtrl, decoration: const InputDecoration(labelText: 'Website URL'))),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _studentCountCtrl,
                  decoration: const InputDecoration(labelText: 'Student Count'),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Is Active'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
                if (!isEditing)
                  SwitchListTile(
                    title: const Text('Seed Default Data'),
                    subtitle: const Text('Create default categories, conditions, pickup locations'),
                    value: _seedDefaults,
                    onChanged: (val) => setState(() => _seedDefaults = val),
                  ),
              ],
            ),
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

