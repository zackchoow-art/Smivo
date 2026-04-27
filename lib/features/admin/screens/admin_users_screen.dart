import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/admin/providers/admin_school_provider.dart';
import 'package:smivo/features/admin/providers/admin_users_provider.dart';

/// Admin screen for viewing and searching registered users.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';
  String? _selectedSchoolFilter;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final usersState = ref.watch(adminUsersProvider);
    final schoolsState = ref.watch(adminSchoolControllerProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminUsersProvider),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // School filter + search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                // School filter
                Expanded(
                  flex: 2,
                  child: schoolsState.when(
                    data: (schools) => DropdownButtonFormField<String?>(
                      initialValue: _selectedSchoolFilter,
                      decoration: InputDecoration(
                        labelText: 'Filter by School',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(radius.sm),
                        ),
                        filled: true,
                        fillColor: colors.surfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Schools'),
                        ),
                        ...schools.map(
                          (s) => DropdownMenuItem(
                            value: s.name,
                            child: Text(s.name),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedSchoolFilter = v),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
                const SizedBox(width: 12),
                // Search bar
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name, email…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.sm),
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainerLow,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // User list
          Expanded(
            child: usersState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Error: $err',
                    style: TextStyle(color: colors.error)),
              ),
              data: (users) {
                var filtered = users;

                // School filter
                if (_selectedSchoolFilter != null) {
                  filtered = filtered
                      .where((u) =>
                          (u['school_name'] ?? '')
                              .toString() ==
                          _selectedSchoolFilter)
                      .toList();
                }

                // Text search
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered.where((u) {
                    return (u['display_name'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(q) ||
                        (u['email'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(q);
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found.',
                      style: typo.bodyLarge
                          .copyWith(color: colors.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    return _UserCard(
                      user: user,
                      onTap: () => _showUserDetail(context, user),
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

  void _showUserDetail(BuildContext context, Map<String, dynamic> user) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final name = user['display_name'] ?? 'No name';
    final email = user['email'] ?? '';
    final school = user['school_name'] ?? 'Unknown';
    final avatarUrl = user['avatar_url'] as String?;
    final isVerified = user['email_verified'] == true;
    final createdAt = user['created_at'] != null
        ? DateFormat('yyyy-MM-dd HH:mm')
            .format(DateTime.parse(user['created_at']))
        : '-';
    final userId = user['id'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colors.surfaceContainerHigh,
              backgroundImage:
                  avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? Icon(Icons.person,
                      color: colors.onSurface.withValues(alpha: 0.5))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: typo.headlineSmall.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.verified,
                            color: colors.primary, size: 18),
                      ],
                    ],
                  ),
                  Text(
                    email,
                    style: typo.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'User ID', value: userId),
              _DetailRow(label: 'School', value: school),
              _DetailRow(
                label: 'Email Verified',
                value: isVerified ? 'Yes ✓' : 'No ✗',
              ),
              _DetailRow(label: 'Joined', value: createdAt),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Styled user card matching the admin card pattern.
class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final name = user['display_name'] ?? 'No name';
    final email = user['email'] ?? '';
    final school = user['school_name'] ?? 'Unknown';
    final avatarUrl = user['avatar_url'] as String?;
    final createdAt = user['created_at'] != null
        ? DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(user['created_at']))
        : '-';
    final isVerified = user['email_verified'] == true;

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
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: colors.surfaceContainerHigh,
          backgroundImage:
              avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Icon(Icons.person,
                  color: colors.onSurface.withValues(alpha: 0.5),
                  size: 20)
              : null,
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                name,
                style: typo.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isVerified) ...[
              const SizedBox(width: 6),
              Icon(Icons.verified, color: colors.primary, size: 16),
            ],
          ],
        ),
        subtitle: Text(
          '$email • $school • Joined $createdAt',
          style: typo.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Reusable detail row for user detail dialog.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final typo = context.smivoTypo;
    final colors = context.smivoColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: typo.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: typo.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
