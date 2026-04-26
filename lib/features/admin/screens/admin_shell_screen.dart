import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class AdminShellScreen extends StatelessWidget {
  const AdminShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    
    // Check if we are on a large screen
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Row(
        children: [
          // Sidebar
          if (isDesktop)
            Container(
              width: 250,
              color: colors.surfaceContainerLow,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Smivo Admin',
                    style: typo.headlineSmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _SidebarItem(
                    title: 'Dashboard',
                    icon: Icons.dashboard,
                    isSelected: currentPath == AppRoutes.adminDashboardPath,
                    onTap: () => context.goNamed(AppRoutes.adminDashboard),
                  ),
                  _SidebarItem(
                    title: 'Schools',
                    icon: Icons.school,
                    isSelected: currentPath == AppRoutes.adminSchoolsPath,
                    onTap: () => context.goNamed(AppRoutes.adminSchools),
                  ),
                  _SidebarItem(
                    title: 'Categories',
                    icon: Icons.category,
                    isSelected: currentPath == AppRoutes.adminCategoriesPath,
                    onTap: () => context.goNamed(AppRoutes.adminCategories),
                  ),
                  _SidebarItem(
                    title: 'FAQs',
                    icon: Icons.help,
                    isSelected: currentPath == AppRoutes.adminFaqsPath,
                    onTap: () => context.goNamed(AppRoutes.adminFaqs),
                  ),
                  const Spacer(),
                  _SidebarItem(
                    title: 'Exit Admin',
                    icon: Icons.exit_to_app,
                    isSelected: false,
                    onTap: () => context.goNamed(AppRoutes.home),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    border: Border(
                      bottom: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      if (!isDesktop)
                        IconButton(
                          icon: Icon(Icons.menu, color: colors.onSurface),
                          onPressed: () {
                            // TODO: Implement drawer for mobile admin
                          },
                        ),
                      const Spacer(),
                      // Profile Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colors.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.admin_panel_settings, color: colors.primary, size: 20),
                      ),
                    ],
                  ),
                ),
                // Nested Route Content
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.sm),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(radius.sm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: typo.labelLarge.copyWith(
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
