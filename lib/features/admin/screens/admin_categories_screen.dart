import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/school_category.dart';
import 'package:smivo/data/repositories/school_data_repository.dart';
import 'package:smivo/features/admin/providers/admin_auth_provider.dart';
import 'package:smivo/features/admin/providers/admin_categories_provider.dart';
import 'package:smivo/features/admin/providers/admin_school_provider.dart';

/// Admin screen for managing school-specific product categories.
class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  String? _selectedSchoolId;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final schoolsState = ref.watch(adminSchoolControllerProvider);
    final adminCtx = ref.watch(adminContextProvider).valueOrNull;
    final canWrite = adminCtx?.canWrite(AdminModule.categories) ?? false;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text('Manage Categories', style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (_selectedSchoolId != null && canWrite)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add category',
              onPressed: () => _showCategoryDialog(context, null),
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
                items: schools.map((s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(s.name),
                )).toList(),
                onChanged: (v) => setState(() => _selectedSchoolId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ),

          // Category list
          Expanded(
            child: _selectedSchoolId == null
                ? Center(
                    child: Text(
                      'Select a school to manage its categories.',
                      style: typo.bodyLarge.copyWith(color: colors.onSurfaceVariant),
                    ),
                  )
                : _buildCategoryList(context, canWrite),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, bool canWrite) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final categoriesState = ref.watch(adminSchoolCategoriesProvider(_selectedSchoolId!));

    return categoriesState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: colors.error))),
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No categories.', style: typo.bodyLarge.copyWith(color: colors.onSurfaceVariant)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _seedDefaults(context),
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Seed Defaults'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
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
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.category, color: colors.primary, size: 20),
                ),
                title: Text(cat.name, style: typo.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  'slug: ${cat.slug} • order: ${cat.displayOrder} • ${cat.isActive ? "Active" : "Inactive"}',
                  style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
                ),
                trailing: canWrite
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, size: 20, color: colors.primary),
                            onPressed: () => _showCategoryDialog(context, cat),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 20, color: colors.error),
                            onPressed: () => _confirmDelete(context, cat),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  void _showCategoryDialog(BuildContext context, SchoolCategory? category) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        schoolId: _selectedSchoolId!,
        category: category,
        onSaved: () => ref.invalidate(adminSchoolCategoriesProvider(_selectedSchoolId!)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SchoolCategory cat) {
    final colors = context.smivoColors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${cat.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(schoolDataRepositoryProvider).deleteCategory(cat.id);
              ref.invalidate(adminSchoolCategoriesProvider(_selectedSchoolId!));
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _seedDefaults(BuildContext context) async {
    await ref.read(schoolDataRepositoryProvider).seedSchoolDefaults(_selectedSchoolId!);
    ref.invalidate(adminSchoolCategoriesProvider(_selectedSchoolId!));
  }
}

class _CategoryDialog extends ConsumerStatefulWidget {
  final String schoolId;
  final SchoolCategory? category;
  final VoidCallback onSaved;

  const _CategoryDialog({
    required this.schoolId,
    this.category,
    required this.onSaved,
  });

  @override
  ConsumerState<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<_CategoryDialog> {
  late final TextEditingController _slugCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _iconCtrl;
  late final TextEditingController _orderCtrl;
  late bool _isActive;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _slugCtrl = TextEditingController(text: widget.category?.slug ?? '');
    _nameCtrl = TextEditingController(text: widget.category?.name ?? '');
    _iconCtrl = TextEditingController(text: widget.category?.icon ?? '');
    _orderCtrl = TextEditingController(text: widget.category?.displayOrder.toString() ?? '0');
    _isActive = widget.category?.isActive ?? true;
  }

  @override
  void dispose() {
    _slugCtrl.dispose();
    _nameCtrl.dispose();
    _iconCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cat = SchoolCategory(
      id: widget.category?.id ?? '',
      schoolId: widget.schoolId,
      slug: _slugCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      icon: _iconCtrl.text.trim().isEmpty ? null : _iconCtrl.text.trim(),
      displayOrder: int.tryParse(_orderCtrl.text.trim()) ?? 0,
      isActive: _isActive,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(schoolDataRepositoryProvider).upsertCategory(cat);
    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Category' : 'New Category'),
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
                decoration: const InputDecoration(labelText: 'Slug (lowercase, no spaces)'),
                validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _iconCtrl,
                decoration: const InputDecoration(labelText: 'Icon name (optional)'),
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
