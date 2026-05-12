import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';

/// Hub page displayed when user taps the "Post" button in bottom navigation.
///
/// Shows two large gradient entry cards:
///   1. **Sell / Rent**: navigates to the listing creation flow
///   2. **Carpool**: navigates to the carpool trip discovery page
///
/// Designed to be expandable — future cards (e.g. Wishlist) can be added here.
class PostHubScreen extends StatelessWidget {
  const PostHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Breakpoints.isDesktop(screenWidth);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Publish'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ContentWidthConstraint(
            maxWidth: 800,
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildListingCard(context)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCarpoolCard(context)),
                    ],
                  )
                : Column(
                    children: [
                      _buildListingCard(context),
                      const SizedBox(height: 20),
                      _buildCarpoolCard(context),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return _PostHubCard(
      onTap: () => context.pushNamed(AppRoutes.createListing),
      gradient: [colors.gradientStart, colors.gradientEnd],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon row
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(radius.lg),
            ),
            child: Icon(
              Icons.sell_outlined,
              size: 28,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sell / Rent',
            style: typo.headlineSmall.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'List furniture, electronics, books,\nand more for sale or rental.',
            style: typo.bodyMedium.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Create Listing',
                style: typo.labelLarge.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: colors.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarpoolCard(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return _PostHubCard(
      onTap: () => context.pushNamed(AppRoutes.carpoolList),
      gradient: [colors.secondaryGradientStart, colors.secondaryGradientEnd],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon row
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(radius.lg),
            ),
            child: Icon(
              Icons.directions_car_outlined,
              size: 28,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Carpool',
            style: typo.headlineSmall.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share rides to airports, malls,\nand nearby towns with classmates.',
            style: typo.bodyMedium.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Find or Post a Ride',
                style: typo.labelLarge.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: colors.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gradient card shared by both hub entries.
///
/// Provides consistent styling: rounded corners, gradient background,
/// shadow, and ink splash effect.
class _PostHubCard extends StatelessWidget {
  const _PostHubCard({
    required this.onTap,
    required this.gradient,
    required this.child,
  });

  final VoidCallback onTap;
  final List<Color> gradient;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = context.smivoRadius;

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
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
