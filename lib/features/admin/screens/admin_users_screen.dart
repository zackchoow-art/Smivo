import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/admin/providers/admin_users_provider.dart';

/// Admin screen for viewing and searching registered users.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final usersState = ref.watch(adminUsersProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text('Manage Users', style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
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
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by name, email, or school…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.md)),
                filled: true,
                fillColor: colors.surfaceContainerLow,
              ),
            ),
          ),
          // User list
          Expanded(
            child: usersState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Error: $err', style: TextStyle(color: colors.error)),
              ),
              data: (users) {
                final filtered = _searchQuery.isEmpty
                    ? users
                    : users.where((u) {
                        final q = _searchQuery.toLowerCase();
                        return (u['display_name'] ?? '').toString().toLowerCase().contains(q) ||
                            (u['email'] ?? '').toString().toLowerCase().contains(q) ||
                            (u['school_name'] ?? '').toString().toLowerCase().contains(q);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text('No users found.', style: typo.bodyLarge.copyWith(color: colors.onSurfaceVariant)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    final name = user['display_name'] ?? 'No name';
                    final email = user['email'] ?? '';
                    final school = user['school_name'] ?? 'Unknown';
                    final avatarUrl = user['avatar_url'] as String?;
                    final createdAt = user['created_at'] != null
                        ? DateFormat('yyyy-MM-dd').format(DateTime.parse(user['created_at']))
                        : '-';
                    final isVerified = user['email_verified'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(radius.sm),
                        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: colors.surfaceContainerHigh,
                          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? Icon(Icons.person, color: colors.onSurface.withValues(alpha: 0.5), size: 20)
                              : null,
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(name, style: typo.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.verified, color: colors.primary, size: 16),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '$email • $school • Joined $createdAt',
                          style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: PopupMenuButton<String>(
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'view', child: Text('View Details')),
                            // TODO: Add ban/suspend actions in future
                          ],
                          onSelected: (value) {
                            // TODO: Implement user detail view
                          },
                        ),
                      ),
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
}
