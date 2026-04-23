import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

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

              // Buyer Center Card
              _HubCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Buyer Center',
                subtitle: 'Your purchase requests,\naccepted orders, and history.',
                gradient: [colors.gradientStart, colors.gradientEnd],
                onTap: () => context.pushNamed(AppRoutes.buyerCenter),
              ),
              const SizedBox(height: 16),

              // Seller Center Card
              _HubCard(
                icon: Icons.storefront_outlined,
                title: 'Seller Center',
                subtitle: 'Active listings, incoming\norders, and sales history.',
                gradient: [colors.secondaryGradientStart, colors.secondaryGradientEnd],
                onTap: () => context.pushNamed(AppRoutes.sellerCenter),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

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
