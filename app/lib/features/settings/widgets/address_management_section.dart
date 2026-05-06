import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/listing/providers/saved_location_provider.dart';

/// Collapsible section on the Profile / Edit Profile page for managing
/// custom pickup addresses.
///
/// - Tap the header to expand / collapse.
/// - Add / Edit: opens an inline AlertDialog.
/// - Delete: first tap turns the icon red (pending confirmation);
///   second tap executes the delete. Tapping elsewhere cancels.
class AddressManagementSection extends ConsumerStatefulWidget {
  const AddressManagementSection({super.key});

  @override
  ConsumerState<AddressManagementSection> createState() =>
      _AddressManagementSectionState();
}

class _AddressManagementSectionState
    extends ConsumerState<AddressManagementSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final savedAsync = ref.watch(savedLocationsProvider);

    return Container(
      width: double.infinity,
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
        children: [
          // ── Collapsible header ──────────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(radius.xl),
              bottom: _expanded
                  ? Radius.zero
                  : Radius.circular(radius.xl),
            ),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: colors.settingsIcon,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Saved Addresses',
                      style: typo.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  // Add button — only visible when expanded
                  if (_expanded)
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: colors.primary,
                        size: 20,
                      ),
                      tooltip: 'Add new address',
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          _showEditDialog(context, existing: null),
                    ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded body ───────────────────────────────────────────────────
          if (_expanded) ...[
            Divider(
              color: colors.outlineVariant,
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'These addresses appear as quick-select options when you post a listing.',
                    style: typo.bodySmall
                        .copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  savedAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Text(
                      'Failed to load addresses: $e',
                      style:
                          typo.bodySmall.copyWith(color: colors.error),
                    ),
                    data: (saved) {
                      if (saved.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No saved addresses yet. Tap + to add one.',
                            style: typo.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
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
                                onEdit: () => _showEditDialog(
                                  context,
                                  existing: addr,
                                ),
                                onDeleteConfirmed: () => ref
                                    .read(savedLocationsProvider.notifier)
                                    .delete(addr),
                              ),
                              if (!isLast)
                                Divider(
                                  color: colors.outlineVariant,
                                  height: 1,
                                ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  void _showEditDialog(BuildContext context, {required String? existing}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _AddressEditDialog(existing: existing),
    );
  }
}

// ── Address row with inline two-tap delete confirmation ─────────────────────

class _AddressRow extends ConsumerStatefulWidget {
  const _AddressRow({
    required this.address,
    required this.onEdit,
    required this.onDeleteConfirmed,
  });

  final String address;
  final VoidCallback onEdit;
  final VoidCallback onDeleteConfirmed;

  @override
  ConsumerState<_AddressRow> createState() => _AddressRowState();
}

class _AddressRowState extends ConsumerState<_AddressRow> {
  /// Whether the user has tapped delete once (pending confirmation).
  bool _pendingDelete = false;

  @override
  Widget build(BuildContext context) {
    final typo = context.smivoTypo;
    final colors = context.smivoColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.place_outlined, size: 15, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.address,
              style: typo.bodyMedium.copyWith(color: colors.onSurface),
            ),
          ),

          // Edit button — hidden during pending-delete to avoid accidents.
          if (!_pendingDelete)
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 17, color: colors.onSurfaceVariant),
              tooltip: 'Edit',
              visualDensity: VisualDensity.compact,
              onPressed: widget.onEdit,
            ),

          // Delete / Confirm delete button (two-tap pattern).
          _pendingDelete
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cancel
                    IconButton(
                      icon: Icon(Icons.close,
                          size: 17, color: colors.onSurfaceVariant),
                      tooltip: 'Cancel',
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          setState(() => _pendingDelete = false),
                    ),
                    // Confirm
                    IconButton(
                      icon: Icon(Icons.check,
                          size: 17, color: colors.error),
                      tooltip: 'Confirm delete',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        setState(() => _pendingDelete = false);
                        widget.onDeleteConfirmed();
                      },
                    ),
                  ],
                )
              : IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 17, color: colors.onSurfaceVariant),
                  tooltip: 'Delete',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _pendingDelete = true),
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
