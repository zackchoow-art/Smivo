import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/listing/providers/saved_location_provider.dart';

/// Inline section on the Profile page for managing custom pickup addresses.
///
/// Displays the user's saved address list with Add / Edit / Delete actions.
/// All operations go through [savedLocationsProvider], which persists to the
/// `user_saved_locations` database table via [SavedLocationRepository].
class AddressManagementSection extends ConsumerWidget {
  const AddressManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final savedAsync = ref.watch(savedLocationsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(radius.xl),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: colors.settingsIcon,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Saved Addresses',
                  style: typo.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              // Add button
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: colors.primary),
                tooltip: 'Add new address',
                onPressed: () => _showEditDialog(context, ref, null),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'These addresses appear as quick-select options when you post a listing.',
            style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),

          // ── Address list ──────────────────────────────────────────────────
          savedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(
              'Failed to load addresses: $e',
              style: typo.bodySmall.copyWith(color: colors.error),
            ),
            data: (saved) {
              if (saved.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No saved addresses yet. Tap + to add one.',
                    style: typo.bodySmall
                        .copyWith(color: colors.onSurfaceVariant),
                  ),
                );
              }

              return Column(
                children: saved.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final addr = entry.value;
                  final isLast = idx == saved.length - 1;

                  return Column(
                    children: [
                      _AddressRow(
                        address: addr,
                        onEdit: () =>
                            _showEditDialog(context, ref, addr),
                        onDelete: () =>
                            _showDeleteConfirm(context, ref, addr),
                      ),
                      if (!isLast)
                        Divider(
                          color: colors.outlineVariant,
                          height: 1,
                          indent: 0,
                        ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  /// Opens an edit dialog. If [existing] is null it's in add mode.
  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String? existing,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _AddressEditDialog(existing: existing),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    WidgetRef ref,
    String address,
  ) {
    final colors = context.smivoColors;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Remove "$address" from your saved addresses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colors.error),
            onPressed: () {
              ref.read(savedLocationsProvider.notifier).delete(address);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Row widget ──────────────────────────────────────────────────────────────

class _AddressRow extends ConsumerWidget {
  const _AddressRow({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  final String address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = context.smivoTypo;
    final colors = context.smivoColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.place_outlined,
            size: 16,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              address,
              style: typo.bodyMedium.copyWith(color: colors.onSurface),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 18, color: colors.onSurfaceVariant),
            tooltip: 'Edit',
            visualDensity: VisualDensity.compact,
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 18, color: colors.onSurfaceVariant),
            tooltip: 'Delete',
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ── Edit / Add dialog ────────────────────────────────────────────────────────

class _AddressEditDialog extends ConsumerStatefulWidget {
  const _AddressEditDialog({this.existing});
  final String? existing;

  @override
  ConsumerState<_AddressEditDialog> createState() => _AddressEditDialogState();
}

class _AddressEditDialogState extends ConsumerState<_AddressEditDialog> {
  late final TextEditingController _ctrl;
  bool _loading = false;
  String? _error;

  bool get _isAdd => widget.existing == null;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.existing ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _ctrl.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'Address cannot be empty.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isAdd) {
        await ref.read(savedLocationsProvider.notifier).save(value);
      } else {
        await ref
            .read(savedLocationsProvider.notifier)
            .rename(widget.existing!, value);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to save: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isAdd ? 'Add Address' : 'Edit Address'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'e.g. Library main entrance',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isAdd ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
