import 'package:flutter/material.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';

import 'package:smivo/features/buyer/screens/buyer_center_screen.dart';
import 'package:smivo/features/seller/screens/seller_center_screen.dart';
import 'package:smivo/features/listing/screens/saved_listings_screen.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _selectedIndex = 0; // 0: Buyer, 1: Seller, 2: Saved

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final unreadBuyerCount =
        ref.watch(unreadBuyerUpdatesCountProvider).value ?? 0;
    final unreadSellerCount =
        ref.watch(unreadSellerUpdatesCountProvider).value ?? 0;
    // NOTE: ContentWidthConstraint centers the hub cards on desktop.
    // On desktop the two cards also switch to a Row for better space use.
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Breakpoints.isDesktop(screenWidth);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  // Left Menu Column
                  Container(
                    width: 360,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Orders',
                          style: typo.headlineLarge.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Track your campus transactions.',
                          style: typo.bodyMedium.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _HubCard(
                                  icon: Icons.shopping_bag_outlined,
                                  title: 'Buyer Center',
                                  subtitle:
                                      'Your purchase requests,\naccepted orders, and history.',
                                  gradient: [
                                    colors.gradientStart,
                                    colors.gradientEnd,
                                  ],
                                  onTap: () => setState(() => _selectedIndex = 0),
                                  badgeCount: unreadBuyerCount,
                                  isSelected: _selectedIndex == 0,
                                ),
                                const SizedBox(height: 16),
                                _HubCard(
                                  icon: Icons.storefront_outlined,
                                  title: 'Seller Center',
                                  subtitle:
                                      'Active listings, incoming\norders, and sales history.',
                                  gradient: [
                                    colors.secondaryGradientStart,
                                    colors.secondaryGradientEnd,
                                  ],
                                  onTap: () => setState(() => _selectedIndex = 1),
                                  badgeCount: unreadSellerCount,
                                  isSelected: _selectedIndex == 1,
                                ),
                                const SizedBox(height: 16),
                                _HubCard(
                                  icon: Icons.bookmark_outline,
                                  title: 'Saved Items',
                                  subtitle:
                                      'Listings you have saved\nfor later viewing.',
                                  gradient: [
                                    colors.tertiary,
                                    colors.onSecondaryContainer,
                                  ],
                                  onTap: () => setState(() => _selectedIndex = 2),
                                  badgeCount: 0,
                                  isSelected: _selectedIndex == 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Vertical Divider
                  Container(
                    width: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.2),
                  ),
                  // Right Content Column
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _selectedIndex == 0
                          ? const BuyerCenterScreen(key: ValueKey(0))
                          : _selectedIndex == 1
                              ? const SellerCenterScreen(key: ValueKey(1))
                              : const SavedListingsScreen(key: ValueKey(2)),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Orders',
                      style: typo.headlineLarge.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your campus transactions.',
                      style: typo.bodyMedium.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _HubCard(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Buyer Center',
                              subtitle:
                                  'Your purchase requests,\naccepted orders, and history.',
                              gradient: [
                                colors.gradientStart,
                                colors.gradientEnd,
                              ],
                              onTap: () => context.pushNamed(AppRoutes.buyerCenter),
                              badgeCount: unreadBuyerCount,
                            ),
                            const SizedBox(height: 16),
                            _HubCard(
                              icon: Icons.storefront_outlined,
                              title: 'Seller Center',
                              subtitle:
                                  'Active listings, incoming\norders, and sales history.',
                              gradient: [
                                colors.secondaryGradientStart,
                                colors.secondaryGradientEnd,
                              ],
                              onTap: () => context.pushNamed(AppRoutes.sellerCenter),
                              badgeCount: unreadSellerCount,
                            ),
                            const SizedBox(height: 16),
                            _HubCard(
                              icon: Icons.bookmark_outline,
                              title: 'Saved Items',
                              subtitle:
                                  'Listings you have saved\nfor later viewing.',
                              gradient: [
                                colors.tertiary,
                                colors.onSecondaryContainer,
                              ],
                              onTap: () => context.pushNamed(AppRoutes.savedListings),
                              badgeCount: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.badgeCount = 0,
    this.isSelected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  final int badgeCount;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final colors = context.smivoColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radius.xl),
          border: isSelected
              ? Border.all(color: colors.onSurface, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 12),
              )
            else
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typo.headlineSmall.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: typo.bodyMedium.copyWith(
                      color: colors.onPrimary.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: colors.onPrimary.withValues(alpha: 0.3),
                  size: 64,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.error,
                        borderRadius: BorderRadius.circular(radius.full),
                        border: Border.all(color: gradient.last, width: 2),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: typo.labelSmall.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
