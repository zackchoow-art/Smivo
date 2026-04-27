import 'package:flutter/material.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final pendingBuyerCount = ref.watch(pendingBuyerOrdersCountProvider).valueOrNull ?? 0;
    final pendingSellerCount = ref.watch(pendingSellerOrdersCountProvider).valueOrNull ?? 0;
    // NOTE: ContentWidthConstraint centers the hub cards on desktop.
    // On desktop the two cards also switch to a Row for better space use.
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Breakpoints.isDesktop(screenWidth);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Orders',
                style: typo.headlineLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your campus transactions.',
                style: typo.bodyMedium.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              // NOTE: ContentWidthConstraint keeps hub cards readable at wide widths.
              // On desktop the two cards are arranged in a Row for equal visual weight.
              Expanded(
                child: ContentWidthConstraint(
                  maxWidth: 960,
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _HubCard(
                                icon: Icons.shopping_bag_outlined,
                                title: 'Buyer Center',
                                subtitle: 'Your purchase requests,\naccepted orders, and history.',
                                gradient: [colors.gradientStart, colors.gradientEnd],
                                onTap: () => context.pushNamed(AppRoutes.buyerCenter),
                                badgeCount: pendingBuyerCount,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _HubCard(
                                icon: Icons.storefront_outlined,
                                title: 'Seller Center',
                                subtitle: 'Active listings, incoming\norders, and sales history.',
                                gradient: [colors.secondaryGradientStart, colors.secondaryGradientEnd],
                                onTap: () => context.pushNamed(AppRoutes.sellerCenter),
                                badgeCount: pendingSellerCount,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _HubCard(
                                icon: Icons.bookmark_outline,
                                title: 'Saved Items',
                                subtitle: 'Listings you have saved\nfor later viewing.',
                                gradient: [colors.tertiary, colors.onSecondaryContainer],
                                onTap: () => context.pushNamed(AppRoutes.savedListings),
                                badgeCount: 0,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _HubCard(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Buyer Center',
                              subtitle: 'Your purchase requests,\naccepted orders, and history.',
                              gradient: [colors.gradientStart, colors.gradientEnd],
                              onTap: () => context.pushNamed(AppRoutes.buyerCenter),
                              badgeCount: pendingBuyerCount,
                            ),
                            const SizedBox(height: 16),
                            _HubCard(
                              icon: Icons.storefront_outlined,
                              title: 'Seller Center',
                              subtitle: 'Active listings, incoming\norders, and sales history.',
                              gradient: [colors.secondaryGradientStart, colors.secondaryGradientEnd],
                              onTap: () => context.pushNamed(AppRoutes.sellerCenter),
                              badgeCount: pendingSellerCount,
                            ),
                            const SizedBox(height: 16),
                            _HubCard(
                              icon: Icons.bookmark_outline,
                              title: 'Saved Items',
                              subtitle: 'Listings you have saved\nfor later viewing.',
                              gradient: [colors.tertiary, colors.onSecondaryContainer],
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final colors = context.smivoColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radius.xl),
          boxShadow: [
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
                  Row(
                    children: [
                      Text(
                        title,
                        style: typo.headlineSmall.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (badgeCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: BorderRadius.circular(radius.full),
                          ),
                          child: Text(
                            badgeCount > 99 ? '99+' : badgeCount.toString(),
                            style: typo.labelSmall.copyWith(color: colors.onPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
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
            Icon(
              icon,
              color: colors.onPrimary.withValues(alpha: 0.3),
              size: 64,
            ),
          ],
        ),
      ),
    );
  }
}
