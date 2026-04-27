import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/pickup_location.dart';
import 'package:smivo/data/repositories/school_data_repository.dart';
import 'package:smivo/features/admin/providers/admin_auth_provider.dart';
import 'package:smivo/features/admin/providers/admin_pickup_locations_provider.dart';
import 'package:smivo/features/admin/providers/admin_school_provider.dart';

/// Admin screen for managing school-specific pickup locations.
class AdminPickupLocationsScreen extends ConsumerStatefulWidget {
  const AdminPickupLocationsScreen({super.key});

  @override
  ConsumerState<AdminPickupLocationsScreen> createState() =>
      _AdminPickupLocationsScreenState();
}

class _AdminPickupLocationsScreenState
    extends ConsumerState<AdminPickupLocationsScreen> {
  String? _selectedSchoolId;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final schoolsState = ref.watch(adminSchoolControllerProvider);
    final adminCtx = ref.watch(adminContextProvider).valueOrNull;
    final canWrite =
        adminCtx?.canWrite(AdminModule.pickupLocations) ?? false;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Manage Pickup Locations',
          style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (_selectedSchoolId != null && canWrite)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add pickup location',
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius.sm),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                ),
                items: schools
                    .map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
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
                      'Select a school to manage its pickup locations.',
                      style: typo.bodyLarge
                          .copyWith(color: colors.onSurfaceVariant),
                    ),
                  )
                : _buildList(context, canWrite),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, bool canWrite) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final state =
        ref.watch(adminSchoolPickupLocationsProvider(_selectedSchoolId!));

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error: $e', style: TextStyle(color: colors.error)),
      ),
      data: (locations) {
        if (locations.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No pickup locations.',
                  style:
                      typo.bodyLarge.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(schoolDataRepositoryProvider)
                        .seedSchoolDefaults(_selectedSchoolId!);
                    ref.invalidate(
                      adminSchoolPickupLocationsProvider(_selectedSchoolId!),
                    );
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
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final loc = locations[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(radius.sm),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF059669),
                    size: 20,
                  ),
                ),
                title: Text(
                  loc.name,
                  style: typo.titleMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Order: ${loc.displayOrder} • ${loc.isActive ? "Active" : "Inactive"}',
                  style: typo.bodySmall
                      .copyWith(color: colors.onSurfaceVariant),
                ),
                trailing: canWrite
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                                size: 20, color: colors.primary),
                            onPressed: () => _showDialog(context, loc),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                size: 20, color: colors.error),
                            onPressed: () => _confirmDelete(context, loc),
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

  void _showDialog(BuildContext context, PickupLocation? location) {
    showDialog(
      context: context,
      builder: (context) => _PickupLocationDialog(
        schoolId: _selectedSchoolId!,
        location: location,
        onSaved: () => ref.invalidate(
          adminSchoolPickupLocationsProvider(_selectedSchoolId!),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PickupLocation loc) {
    final colors = context.smivoColors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pickup Location'),
        content: Text('Delete "${loc.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(schoolDataRepositoryProvider)
                  .deletePickupLocation(loc.id);
              ref.invalidate(
                adminSchoolPickupLocationsProvider(_selectedSchoolId!),
              );
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

class _PickupLocationDialog extends ConsumerStatefulWidget {
  final String schoolId;
  final PickupLocation? location;
  final VoidCallback onSaved;

  const _PickupLocationDialog({
    required this.schoolId,
    this.location,
    required this.onSaved,
  });

  @override
  ConsumerState<_PickupLocationDialog> createState() =>
      _PickupLocationDialogState();
}

class _PickupLocationDialogState
    extends ConsumerState<_PickupLocationDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _orderCtrl;
  late bool _isActive;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.location?.name ?? '');
    _orderCtrl = TextEditingController(
      text: widget.location?.displayOrder.toString() ?? '0',
    );
    _isActive = widget.location?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loc = PickupLocation(
      id: widget.location?.id ?? '',
      schoolId: widget.schoolId,
      name: _nameCtrl.text.trim(),
      displayOrder: int.tryParse(_orderCtrl.text.trim()) ?? 0,
      isActive: _isActive,
      createdAt: widget.location?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref
        .read(schoolDataRepositoryProvider)
        .upsertPickupLocation(loc);
    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.location != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Location' : 'New Location'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Location Name'),
                validator: (v) =>
                    v != null && v.trim().isNotEmpty ? null : 'Required',
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
