import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/admin_role.dart';
import 'package:smivo/data/repositories/admin_role_repository.dart';
import 'package:smivo/features/admin/providers/admin_auth_provider.dart';
import 'package:smivo/features/admin/providers/admin_roles_provider.dart';
import 'package:smivo/features/admin/providers/admin_school_provider.dart';

/// Admin screen for managing user roles and permissions.
class AdminRolesScreen extends ConsumerStatefulWidget {
  const AdminRolesScreen({super.key});

  @override
  ConsumerState<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends ConsumerState<AdminRolesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final rolesState = ref.watch(adminRolesProvider);
    final adminCtx = ref.watch(adminContextProvider).valueOrNull;
    final canWrite = adminCtx?.canWrite(AdminModule.roles) ?? false;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text('Manage Roles', style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (canWrite)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Assign role',
              onPressed: () => _showAssignDialog(context),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminRolesProvider),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by name or email…',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.md)),
                filled: true,
                fillColor: colors.surfaceContainerLow,
              ),
            ),
          ),
          Expanded(
            child: rolesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: colors.error))),
              data: (roles) {
                var filtered = roles;
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = roles.where((r) =>
                    (r.userName ?? '').toLowerCase().contains(q) ||
                    (r.userEmail ?? '').toLowerCase().contains(q)).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text('No roles found.', style: typo.bodyLarge.copyWith(color: colors.onSurfaceVariant)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final role = filtered[index];
                    return _RoleCard(
                      role: role,
                      canWrite: canWrite,
                      onEdit: () => _showEditDialog(context, role),
                      onDelete: () => _confirmDelete(context, role),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _AssignRoleDialog(
        onSaved: () => ref.invalidate(adminRolesProvider),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AdminRole role) {
    showDialog(
      context: context,
      builder: (ctx) => _EditRoleDialog(
        role: role,
        onSaved: () => ref.invalidate(adminRolesProvider),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminRole role) {
    final colors = context.smivoColors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Role'),
        content: Text('Remove ${role.role} role for ${role.userName ?? role.userEmail}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(adminRoleRepositoryProvider).deleteRole(role.id);
              ref.invalidate(adminRolesProvider);
              ref.invalidate(adminContextProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final AdminRole role;
  final bool canWrite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoleCard({required this.role, required this.canWrite, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final roleColor = switch (role.role) {
      'sysadmin' => const Color(0xFFDC2626),
      'admin' => const Color(0xFF2563EB),
      _ => const Color(0xFF059669),
    };

    final roleLabel = switch (role.role) {
      'sysadmin' => 'System Admin',
      'admin' => 'Admin',
      _ => 'Operator',
    };

    final scopeLabel = role.scopeType == 'platform'
        ? 'Platform'
        : role.schoolName ?? 'School';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.sm),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.1),
          child: Icon(
            role.role == 'sysadmin' ? Icons.shield : role.role == 'admin' ? Icons.admin_panel_settings : Icons.person,
            color: roleColor,
            size: 20,
          ),
        ),
        title: Text(
          role.userName ?? role.userEmail ?? 'Unknown',
          style: typo.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${role.userEmail ?? ''} • $scopeLabel',
          style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                roleLabel,
                style: typo.labelSmall.copyWith(color: roleColor, fontWeight: FontWeight.bold),
              ),
            ),
            if (!role.isActive) ...[
              const SizedBox(width: 4),
              Icon(Icons.block, size: 16, color: colors.error),
            ],
            if (canWrite) ...[
              const SizedBox(width: 8),
              IconButton(icon: Icon(Icons.edit, size: 20, color: colors.primary), onPressed: onEdit),
              IconButton(icon: Icon(Icons.delete, size: 20, color: colors.error), onPressed: onDelete),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Assign Role Dialog ────────────────────────────────────────

class _AssignRoleDialog extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _AssignRoleDialog({required this.onSaved});

  @override
  ConsumerState<_AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends ConsumerState<_AssignRoleDialog> {
  final _userIdCtrl = TextEditingController();
  String _role = 'operator';
  String _scopeType = 'school';
  String? _scopeId;
  bool _loading = false;

  @override
  void dispose() {
    _userIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schoolsState = ref.watch(adminSchoolControllerProvider);

    return AlertDialog(
      title: const Text('Assign Role'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _userIdCtrl,
              decoration: const InputDecoration(
                labelText: 'User ID (UUID)',
                hintText: 'Paste user UUID here',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'operator', child: Text('Operator')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'sysadmin', child: Text('System Admin')),
              ],
              onChanged: (v) => setState(() {
                _role = v ?? 'operator';
                if (_role == 'sysadmin') _scopeType = 'platform';
              }),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _scopeType,
              decoration: const InputDecoration(labelText: 'Scope'),
              items: const [
                DropdownMenuItem(value: 'platform', child: Text('Platform')),
                DropdownMenuItem(value: 'school', child: Text('School')),
              ],
              onChanged: (v) => setState(() {
                _scopeType = v ?? 'school';
                if (_scopeType == 'platform') _scopeId = null;
              }),
            ),
            if (_scopeType == 'school') ...[
              const SizedBox(height: 16),
              schoolsState.when(
                data: (schools) => DropdownButtonFormField<String>(
                  initialValue: _scopeId,
                  decoration: const InputDecoration(labelText: 'School'),
                  items: schools.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                  onChanged: (v) => setState(() => _scopeId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Assign'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final userId = _userIdCtrl.text.trim();
    if (userId.isEmpty) return;
    if (_scopeType == 'school' && _scopeId == null) return;

    setState(() => _loading = true);
    try {
      await ref.read(adminRoleRepositoryProvider).createRole(
        userId: userId,
        role: _role,
        scopeType: _scopeType,
        scopeId: _scopeType == 'platform' ? null : _scopeId,
      );
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ─── Edit Role Dialog ──────────────────────────────────────────

class _EditRoleDialog extends ConsumerStatefulWidget {
  final AdminRole role;
  final VoidCallback onSaved;
  const _EditRoleDialog({required this.role, required this.onSaved});

  @override
  ConsumerState<_EditRoleDialog> createState() => _EditRoleDialogState();
}

class _EditRoleDialogState extends ConsumerState<_EditRoleDialog> {
  late String _role;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _role = widget.role.role;
    _isActive = widget.role.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Role: ${widget.role.userName ?? widget.role.userEmail}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Role'),
            items: const [
              DropdownMenuItem(value: 'operator', child: Text('Operator')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'sysadmin', child: Text('System Admin')),
            ],
            onChanged: (v) => setState(() => _role = v ?? _role),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Active'),
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            await ref.read(adminRoleRepositoryProvider).updateRole(
              widget.role.id,
              role: _role,
              isActive: _isActive,
            );
            widget.onSaved();
            ref.invalidate(adminContextProvider);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
