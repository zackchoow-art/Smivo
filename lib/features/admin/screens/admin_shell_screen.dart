import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// Admin shell with sidebar navigation (desktop) and drawer (mobile).
///
/// Wraps all admin sub-routes with a persistent layout.
class AdminShellScreen extends StatelessWidget {
  const AdminShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    final currentPath = GoRouterState.of(context).uri.path;

    final navItems = _buildNavItems(currentPath);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      drawer: isDesktop ? null : _buildDrawer(context, navItems),
      body: Row(
        children: [
          // Persistent sidebar on desktop
          if (isDesktop) _buildSidebar(context, navItems),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar with hamburger on mobile
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    border: Border(
                      bottom: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (!isDesktop)
                        IconButton(
                          icon: Icon(Icons.menu, color: colors.onSurface),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      const Spacer(),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colors.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.admin_panel_settings, color: colors.primary, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text('Admin', style: typo.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_NavItem> _buildNavItems(String currentPath) {
    return [
      _NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard, AppRoutes.adminDashboardPath, AppRoutes.adminDashboard),
      _NavItem('Users', Icons.people_outline, Icons.people, AppRoutes.adminUsersPath, AppRoutes.adminUsers),
      _NavItem('Listings', Icons.storefront_outlined, Icons.storefront, AppRoutes.adminListingsPath, AppRoutes.adminListings),
      _NavItem('Orders', Icons.receipt_long_outlined, Icons.receipt_long, AppRoutes.adminOrdersPath, AppRoutes.adminOrders),
      _NavItem('Schools', Icons.school_outlined, Icons.school, AppRoutes.adminSchoolsPath, AppRoutes.adminSchools),
      _NavItem('Categories', Icons.category_outlined, Icons.category, AppRoutes.adminCategoriesPath, AppRoutes.adminCategories),
      _NavItem('Conditions', Icons.star_half_outlined, Icons.star_half, AppRoutes.adminConditionsPath, AppRoutes.adminConditions),
      _NavItem('FAQs', Icons.help_outline, Icons.help, AppRoutes.adminFaqsPath, AppRoutes.adminFaqs),
      _NavItem('Dictionary', Icons.book_outlined, Icons.book, AppRoutes.adminDictionaryPath, AppRoutes.adminDictionary),
    ];
  }

  Widget _buildSidebar(BuildContext context, List<_NavItem> items) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Brand header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.admin_panel_settings, color: colors.onPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Smivo Admin',
                  style: typo.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Nav items
          ...items.map((item) {
            final isSelected = currentPath == item.path;
            return _SidebarNavItem(
              title: item.title,
              icon: isSelected ? item.selectedIcon : item.icon,
              isSelected: isSelected,
              onTap: () => context.goNamed(item.routeName),
            );
          }),
          const Spacer(),
          // Exit
          Divider(color: colors.outlineVariant.withValues(alpha: 0.3), indent: 20, endIndent: 20),
          _SidebarNavItem(
            title: 'Logout',
            icon: Icons.logout,
            isSelected: false,
            onTap: () => context.goNamed(AppRoutes.adminLogin),
          ),
          _SidebarNavItem(
            title: 'Back to App',
            icon: Icons.arrow_back,
            isSelected: false,
            onTap: () => context.goNamed(AppRoutes.home),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, List<_NavItem> items) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final currentPath = GoRouterState.of(context).uri.path;

    return Drawer(
      backgroundColor: colors.surfaceContainerLow,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.admin_panel_settings, color: colors.onPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Smivo Admin',
                    style: typo.titleMedium.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Divider(color: colors.outlineVariant.withValues(alpha: 0.3)),
            ...items.map((item) {
              final isSelected = currentPath == item.path;
              return ListTile(
                leading: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                ),
                title: Text(
                  item.title,
                  style: typo.labelLarge.copyWith(
                    color: isSelected ? colors.primary : colors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedTileColor: colors.primary.withValues(alpha: 0.1),
                onTap: () {
                  Navigator.of(context).pop();
                  context.goNamed(item.routeName);
                },
              );
            }),
            const Spacer(),
            Divider(color: colors.outlineVariant.withValues(alpha: 0.3)),
            ListTile(
              leading: Icon(Icons.logout, color: colors.onSurfaceVariant),
              title: Text('Logout', style: typo.labelLarge.copyWith(color: colors.onSurfaceVariant)),
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed(AppRoutes.adminLogin);
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_back, color: colors.onSurfaceVariant),
              title: Text('Back to App', style: typo.labelLarge.copyWith(color: colors.onSurfaceVariant)),
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed(AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
  final String routeName;

  _NavItem(this.title, this.icon, this.selectedIcon, this.path, this.routeName);
}

class _SidebarNavItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(radius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
