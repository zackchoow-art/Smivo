import 'package:flutter/material.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/features/listing/providers/listing_detail_provider.dart';
import 'package:smivo/features/listing/widgets/listing_image_carousel.dart';
import 'package:smivo/features/listing/widgets/rental_options_section.dart';
import 'package:smivo/features/listing/widgets/seller_profile_card.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/chat/widgets/chat_popup.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/features/listing/providers/saved_listing_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/shared/providers/school_provider.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/repositories/listing_repository.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/shared/providers/school_data_provider.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:share_plus/share_plus.dart';

import 'package:smivo/core/providers/moderation_provider.dart';

/// Resolves a condition slug to a display label.
/// Accepts an optional conditions list from DB for dynamic lookup.
String _conditionLabel(String condition, [List? conditions]) {
  // NOTE: Try DB lookup first, fallback to hardcoded switch
  if (conditions != null) {
    final match = conditions.where((c) => c.slug == condition).firstOrNull;
    if (match != null) return match.name.toUpperCase();
  }
  switch (condition) {
    case 'new':
      return 'NEW';
    case 'like_new':
      return 'LIKE NEW';
    case 'good':
      return 'GOOD';
    case 'fair':
      return 'FAIR';
    case 'poor':
      return 'POOR';
    default:
      return condition.toUpperCase();
  }
}

class ListingDetailScreen extends ConsumerStatefulWidget {
  const ListingDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  String? _selectedPickupLocationId;

  Future<void> _showOrderSuccessDialog(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius.xl),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: colors.success, size: 64),
                const SizedBox(height: 12),
                Text('Order Submitted', style: typo.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'Waiting for seller approval.',
                  style: typo.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius.md),
                    ),
                  ),
                  child: Text('OK', style: TextStyle(color: colors.onPrimary)),
                ),
              ],
            ),
          ),
    );
  }

  void _showDelistDialog(BuildContext context, WidgetRef ref, Listing listing) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delist Item'),
            content: Text(
              'Are you sure you want to delist "${listing.title}"? '
              'This will cancel all pending offers and remove it from the marketplace.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Keep Listed'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  // 1. Update listing status to cancelled
                  final listingRepo = ref.read(listingRepositoryProvider);
                  await listingRepo.delistListing(listing.id);
                  // 2. Cancel all pending orders for this listing
                  final orderRepo = ref.read(orderRepositoryProvider);
                  await orderRepo.cancelAllPendingOrders(listing.id);
                  // 3. Navigate back
                  if (context.mounted) {
                    context.goNamed(AppRoutes.sellerCenter);
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delist'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.id));
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    // NOTE: LayoutBuilder at screen level drives responsive layout decisions
    // for the information section below the image carousel.
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Breakpoints.isDesktop(screenWidth);

    return Scaffold(
      backgroundColor: colors.background,
      body: listingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading listing: $err',
                  style: typo.bodyMedium.copyWith(color: colors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        data: (listing) {
          final isSale = listing.transactionType.toLowerCase() == 'sale';
          final seller = listing.seller;
          final currentUserId = ref.watch(authStateProvider).valueOrNull?.id;
          final isOwnListing =
              currentUserId != null && currentUserId == listing.sellerId;
          final existingOrder = ref.watch(
            existingBuyerOrderProvider(listing.id),
          );
          final imageUrls = listing.images.map((img) => img.imageUrl).toList();
          // NOTE: Tag removed per design — no overlay text on images.
          // Load DB conditions for dynamic label resolution
          final conditionsList =
              ref.watch(mySchoolConditionsProvider).valueOrNull;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(listingDetailProvider(widget.id));
                  await ref.read(listingDetailProvider(widget.id).future);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListingImageCarousel(
                        imageUrls: imageUrls,
                        tagText: null,
                        isSale: isSale,
                      ),
                      // NOTE: ContentWidthConstraint centers the info section on tablet/desktop.
                      // On mobile it has no effect (screen < maxWidth).
                      ContentWidthConstraint(
                        maxWidth: isDesktop ? 768 : double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.title,
                                style: typo.displayLarge.copyWith(
                                  fontSize: 32,
                                  letterSpacing: -1,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // NOTE: Condition label with themed background chip.
                              // Uses secondaryContainer (IKEA yellow / Teal accent)
                              // for visual prominence below the title.
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    radius.sm,
                                  ),
                                ),
                                child: Text(
                                  _conditionLabel(
                                    listing.condition,
                                    conditionsList,
                                  ).toUpperCase(),
                                  style: typo.bodySmall.copyWith(
                                    color: colors.onSecondaryContainer,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (isSale) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '\$${listing.price.toStringAsFixed(0)}',
                                  style: typo.headlineLarge.copyWith(
                                    color: colors.priceAccent,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              Text(
                                'DESCRIPTION',
                                style: typo.labelSmall.copyWith(
                                  color: colors.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                listing.description ??
                                    'No description provided.',
                                style: typo.bodyLarge,
                              ),
                              const SizedBox(height: 24),
                              if (!isSale) ...[
                                if (!isOwnListing && listing.status == 'active')
                                  RentalOptionsSection(listing: listing),
                                if (isOwnListing) ...[
                                  const SizedBox(height: 16),
                                  // Read-only rental rates display
                                  Row(
                                    children: [
                                      if (listing.rentalDailyPrice != null &&
                                          listing.rentalDailyPrice! > 0)
                                        _ReadOnlyRateCard(
                                          label: 'Day',
                                          price: listing.rentalDailyPrice!,
                                        ),
                                      if (listing.rentalDailyPrice != null &&
                                          listing.rentalDailyPrice! > 0 &&
                                          ((listing.rentalWeeklyPrice != null &&
                                                  listing.rentalWeeklyPrice! >
                                                      0) ||
                                              (listing.rentalMonthlyPrice !=
                                                      null &&
                                                  listing.rentalMonthlyPrice! >
                                                      0)))
                                        const SizedBox(width: 12),
                                      if (listing.rentalWeeklyPrice != null &&
                                          listing.rentalWeeklyPrice! > 0)
                                        _ReadOnlyRateCard(
                                          label: 'Week',
                                          price: listing.rentalWeeklyPrice!,
                                        ),
                                      if (listing.rentalWeeklyPrice != null &&
                                          listing.rentalWeeklyPrice! > 0 &&
                                          (listing.rentalMonthlyPrice != null &&
                                              listing.rentalMonthlyPrice! > 0))
                                        const SizedBox(width: 12),
                                      if (listing.rentalMonthlyPrice != null &&
                                          listing.rentalMonthlyPrice! > 0)
                                        _ReadOnlyRateCard(
                                          label: 'Month',
                                          price: listing.rentalMonthlyPrice!,
                                        ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 24),
                              ],
                              // Pickup Location Selector
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: colors.priceAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'PICKUP LOCATION',
                                              style: typo.labelSmall.copyWith(
                                                color: colors.onSurface
                                                    .withValues(alpha: 0.5),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            if (listing.allowPickupChange &&
                                                !isOwnListing)
                                              GestureDetector(
                                                onTap: () {},
                                                child: Text(
                                                  'Change Location',
                                                  style: typo.labelSmall
                                                      .copyWith(
                                                        color: colors.primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(
                                              radius.input,
                                            ),
                                          ),
                                          child:
                                              !listing.allowPickupChange ||
                                                      isOwnListing
                                                  ? Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    height: 48,
                                                    child: Text(
                                                      listing
                                                              .pickupLocation
                                                              ?.name ??
                                                          'Not specified',
                                                      style: typo.titleMedium
                                                          .copyWith(
                                                            color:
                                                                colors
                                                                    .onSurface,
                                                          ),
                                                    ),
                                                  )
                                                  : DropdownButtonHideUnderline(
                                                    child: Consumer(
                                                      builder: (
                                                        context,
                                                        ref,
                                                        _,
                                                      ) {
                                                        final pickupsAsync = ref
                                                            .watch(
                                                              myPickupLocationsProvider,
                                                            );
                                                        return pickupsAsync.when(
                                                          loading:
                                                              () => const SizedBox(
                                                                height: 48,
                                                                child: Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                ),
                                                              ),
                                                          error:
                                                              (
                                                                err,
                                                                _,
                                                              ) => Container(
                                                                alignment:
                                                                    Alignment
                                                                        .centerLeft,
                                                                height: 48,
                                                                child: Text(
                                                                  listing
                                                                          .pickupLocation
                                                                          ?.name ??
                                                                      'Unable to load',
                                                                  style:
                                                                      typo.bodyMedium,
                                                                ),
                                                              ),
                                                          data: (locations) {
                                                            final selectedId =
                                                                _selectedPickupLocationId ??
                                                                listing
                                                                    .pickupLocationId;
                                                            return DropdownButton<
                                                              String
                                                            >(
                                                              value: selectedId,
                                                              isExpanded: true,
                                                              icon: Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                                color:
                                                                    colors
                                                                        .primary,
                                                              ),
                                                              style: typo
                                                                  .titleMedium
                                                                  .copyWith(
                                                                    color:
                                                                        colors
                                                                            .onSurface,
                                                                  ),
                                                              onChanged:
                                                                  (
                                                                    String?
                                                                    newId,
                                                                  ) => setState(
                                                                    () =>
                                                                        _selectedPickupLocationId =
                                                                            newId,
                                                                  ),
                                                              items:
                                                                  locations
                                                                      .map(
                                                                        (
                                                                          loc,
                                                                        ) => DropdownMenuItem<
                                                                          String
                                                                        >(
                                                                          value:
                                                                              loc.id,
                                                                          child: Text(
                                                                            loc.name,
                                                                          ),
                                                                        ),
                                                                      )
                                                                      .toList(),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Seller Section — hidden on own listing
                              if (seller != null && !isOwnListing) ...[
                                Text('Seller', style: typo.labelLarge),
                                const SizedBox(height: 8),
                                SellerProfileCard(
                                  user: seller,
                                  label: isSale ? 'SELLER' : 'LISTED BY',
                                  onMessageTap: () async {
                                    final user =
                                        ref.read(authStateProvider).valueOrNull;
                                    if (user == null) {
                                      context.pushNamed(AppRoutes.login);
                                      return;
                                    }
                                    if (user.id == listing.sellerId) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'This is your own listing',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    try {
                                      final chatRoom = await ref
                                          .read(chatRepositoryProvider)
                                          .getOrCreateChatRoom(
                                            listingId: listing.id,
                                            buyerId: user.id,
                                            sellerId: listing.sellerId,
                                          );
                                      if (!context.mounted) return;

                                      // Use existing order info if available
                                      final order = existingOrder.valueOrNull;
                                      final price =
                                          order?.totalPrice ?? listing.price;
                                      final priceLabel =
                                          order != null &&
                                                  order.orderType == 'rental'
                                              ? _formatRentalSummary(order)
                                              : null;

                                      showChatPopup(
                                        context,
                                        chatRoomId: chatRoom.id,
                                        otherUserName:
                                            listing.seller?.displayName ??
                                            'Seller',
                                        otherUserAvatar:
                                            listing.seller?.avatarUrl,
                                        otherUserEmail: listing.seller?.email,
                                        listingTitle: listing.title,
                                        listingPrice: price,
                                        priceLabel: priceLabel,
                                        listingImageUrl:
                                            listing
                                                .images
                                                .firstOrNull
                                                ?.imageUrl,
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  },
                                ),
                              ],
                              const SizedBox(height: 24),
                              // Stats Section — only visible on own listing
                              if (isOwnListing) ...[
                                Text(
                                  'LISTING STATS',
                                  style: typo.labelSmall.copyWith(
                                    color: colors.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _StatCard(
                                      icon: Icons.visibility_outlined,
                                      label: 'Views',
                                      count: listing.viewCount,
                                      onTap: () async {
                                        await context.pushNamed(
                                          AppRoutes.transactionManagement,
                                          pathParameters: {'id': listing.id},
                                          queryParameters: {'tab': '0'},
                                        );
                                        // NOTE: Refresh stats when returning from transaction management
                                        ref.invalidate(
                                          listingDetailProvider(widget.id),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    _StatCard(
                                      icon: Icons.bookmark_outline,
                                      label: 'Saves',
                                      count: listing.saveCount,
                                      onTap: () async {
                                        await context.pushNamed(
                                          AppRoutes.transactionManagement,
                                          pathParameters: {'id': listing.id},
                                          queryParameters: {'tab': '1'},
                                        );
                                        ref.invalidate(
                                          listingDetailProvider(widget.id),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    _StatCard(
                                      icon: Icons.local_offer_outlined,
                                      label: 'Offers',
                                      count: listing.inquiryCount,
                                      onTap: () async {
                                        await context.pushNamed(
                                          AppRoutes.transactionManagement,
                                          pathParameters: {'id': listing.id},
                                          queryParameters: {'tab': '2'},
                                        );
                                        ref.invalidate(
                                          listingDetailProvider(widget.id),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                if (listing.status == 'active') ...[
                                  // NOTE: Hide delist button if listing has confirmed orders
                                  // (rental accepted but pre-delivery: listing is still 'active')
                                  Builder(
                                    builder: (context) {
                                      final hasConfirmed = ref.watch(
                                        listingHasConfirmedOrderProvider(
                                          listing.id,
                                        ),
                                      );
                                      return hasConfirmed.when(
                                        loading: () => const SizedBox.shrink(),
                                        error:
                                            (_, __) => const SizedBox.shrink(),
                                        data: (hasOrder) {
                                          if (hasOrder)
                                            return const SizedBox.shrink();
                                          return SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton.icon(
                                              onPressed:
                                                  () => _showDelistDialog(
                                                    context,
                                                    ref,
                                                    listing,
                                                  ),
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.red,
                                              ),
                                              label: const Text(
                                                'Delist This Item',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                side: const BorderSide(
                                                  color: Colors.red,
                                                  width: 1.5,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        radius.button,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ],
                              // Primary Action Button — hidden on own listing
                              if (!isOwnListing)
                                existingOrder.when(
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                  data: (order) {
                                    if (order != null) {
                                      final submittedDate = DateFormat(
                                        'MMM d, yyyy · h:mm a',
                                      ).format(order.createdAt.toLocal());
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: colors.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(
                                            radius.card,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: colors.success,
                                              size: 28,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Application Submitted',
                                              style: typo.titleMedium.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              submittedDate,
                                              style: typo.bodySmall.copyWith(
                                                color: colors.outlineVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Price display — different format for sale vs rental
                                            if (order.orderType ==
                                                'rental') ...[
                                              Text(
                                                _formatRentalSummary(order),
                                                style: typo.bodyMedium.copyWith(
                                                  color: colors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ] else ...[
                                              Text(
                                                '\$${order.totalPrice.toStringAsFixed(0)}',
                                                style: typo.titleMedium
                                                    .copyWith(
                                                      color: colors.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                            // Cancel button — only for pending orders
                                            if (order.status == 'pending') ...[
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                width: double.infinity,
                                                child: OutlinedButton(
                                                  onPressed: () async {
                                                    final confirmed = await showDialog<
                                                      bool
                                                    >(
                                                      context: context,
                                                      builder:
                                                          (ctx) => AlertDialog(
                                                            title: const Text(
                                                              'Cancel Application',
                                                            ),
                                                            content: const Text(
                                                              'Are you sure you want to cancel your application?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed:
                                                                    () =>
                                                                        Navigator.pop(
                                                                          ctx,
                                                                          false,
                                                                        ),
                                                                child:
                                                                    const Text(
                                                                      'Keep',
                                                                    ),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () =>
                                                                        Navigator.pop(
                                                                          ctx,
                                                                          true,
                                                                        ),
                                                                style: TextButton.styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                                child: const Text(
                                                                  'Cancel Application',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                    );
                                                    if (confirmed == true &&
                                                        context.mounted) {
                                                      await ref
                                                          .read(
                                                            orderActionsProvider
                                                                .notifier,
                                                          )
                                                          .cancelOrder(
                                                            order.id,
                                                          );
                                                    }
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        colors.error,
                                                    side: BorderSide(
                                                      color: colors.error,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            radius.button,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Cancel Application',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    }

                                    if (listing.status != 'active') {
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: colors.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(
                                            radius.card,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons
                                                  .remove_shopping_cart_outlined,
                                              color: colors.outlineVariant,
                                              size: 28,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Item Unavailable',
                                              style: typo.titleMedium.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'This listing is no longer active on the market.',
                                              style: typo.bodySmall.copyWith(
                                                color: colors.outlineVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final user =
                                              ref
                                                  .read(authStateProvider)
                                                  .valueOrNull;
                                          if (user == null) {
                                            context.pushNamed(AppRoutes.login);
                                            return;
                                          }
                                          if (user.emailConfirmedAt == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please verify your email first',
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          if (user.id == listing.sellerId) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'You cannot buy your own listing',
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          final isRental =
                                              listing.transactionType
                                                  .toLowerCase() ==
                                              'rental';
                                          double orderPrice;
                                          DateTime? rentalStart, rentalEnd;
                                          if (isRental) {
                                            final selectedRate = ref.read(
                                              selectedRentalRateProvider,
                                            );
                                            final startDate = ref.read(
                                              rentalStartDateProvider,
                                            );
                                            if (selectedRate == 'DAY') {
                                              final endDate = ref.read(
                                                rentalEndDateProvider,
                                              );
                                              final days =
                                                  endDate
                                                      .difference(startDate)
                                                      .inDays;
                                              orderPrice =
                                                  (listing.rentalDailyPrice ??
                                                      0) *
                                                  (days > 0 ? days : 1);
                                              rentalStart = startDate;
                                              rentalEnd = endDate;
                                            } else if (selectedRate == 'WEEK') {
                                              final duration = ref.read(
                                                rentalDurationProvider,
                                              );
                                              orderPrice =
                                                  (listing.rentalWeeklyPrice ??
                                                      0) *
                                                  duration;
                                              rentalStart = startDate;
                                              rentalEnd = startDate.add(
                                                Duration(days: 7 * duration),
                                              );
                                            } else {
                                              final duration = ref.read(
                                                rentalDurationProvider,
                                              );
                                              orderPrice =
                                                  (listing.rentalMonthlyPrice ??
                                                      0) *
                                                  duration;
                                              rentalStart = startDate;
                                              rentalEnd = DateTime(
                                                startDate.year,
                                                startDate.month + duration,
                                                startDate.day,
                                              );
                                            }
                                            if (orderPrice <= 0) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Invalid rental configuration. Please select a valid rate and period.',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                          } else {
                                            orderPrice = listing.price;
                                          }
                                          try {
                                            final effectivePickupId =
                                                _selectedPickupLocationId ??
                                                listing.pickupLocationId;
                                            await ref
                                                .read(
                                                  orderActionsProvider.notifier,
                                                )
                                                .createOrder(
                                                  listingId: listing.id,
                                                  sellerId: listing.sellerId,
                                                  price: orderPrice,
                                                  orderType:
                                                      isRental
                                                          ? 'rental'
                                                          : 'sale',
                                                  rentalStartDate: rentalStart,
                                                  rentalEndDate: rentalEnd,
                                                  depositAmount:
                                                      listing.depositAmount,
                                                  pickupLocationId:
                                                      effectivePickupId,
                                                );
                                            if (!context.mounted) return;
                                            await _showOrderSuccessDialog(
                                              context,
                                            );
                                            if (!context.mounted) return;
                                            context.goNamed(AppRoutes.home);
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Failed to place order: ${e.toString()}',
                                                ),
                                                backgroundColor: colors.error,
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colors.primary,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              radius.button,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          isSale
                                              ? 'Request to Buy'
                                              : 'Request to Rent',
                                          style: typo.titleMedium.copyWith(
                                            color: colors.onPrimary,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Fixed floating back button
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(AppRoutes.home);
                      }
                    },
                  ),
                ),
              ),
              // Floating top-right actions (Share, Save, More)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 12,
                child: Row(
                  children: [
                    // Share Button (Always visible)
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLowest.withValues(
                          alpha: 0.9,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.ios_share, color: colors.onSurface),
                        onPressed: () {
                          final shareText = isSale
                              ? 'Check out ${listing.title} for \$${listing.price.toStringAsFixed(0)} on Smivo!\n\nhttps://smivo.io/listing/${listing.id}'
                              : 'Check out ${listing.title} on Smivo!\n\nhttps://smivo.io/listing/${listing.id}';
                          Share.share(shareText);
                        },
                      ),
                    ),
                    if (!isOwnListing) ...[
                      const SizedBox(width: 8),
                      Consumer(
                        builder: (context, ref, _) {
                          final isSavedAsync = ref.watch(
                            isListingSavedProvider(listing.id),
                          );
                          final isSaved = isSavedAsync.valueOrNull ?? false;
                          return Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest.withValues(
                                alpha: 0.9,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color:
                                    isSaved ? colors.primary : colors.onSurface,
                              ),
                              onPressed: () {
                                final user =
                                    ref.read(authStateProvider).valueOrNull;
                                if (user == null) {
                                  context.pushNamed(AppRoutes.login);
                                  return;
                                }
                                ref
                                    .read(savedListingActionsProvider.notifier)
                                    .toggleSave(listing.id);
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLowest.withValues(
                            alpha: 0.9,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: PopupMenuButton<String>(
                          icon: Icon(Icons.more_horiz, color: colors.onSurface),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(radius.md),
                          ),
                          onSelected: (value) async {
                            final user =
                                ref.read(authStateProvider).valueOrNull;
                            if (user == null) {
                              context.pushNamed(AppRoutes.login);
                              return;
                            }

                            if (value == 'report') {
                              final reasonController = TextEditingController();
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          radius.xl,
                                        ),
                                      ),
                                      title: const Text('Report Listing'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Please describe why this listing is objectionable:',
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: reasonController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      radius.input,
                                                    ),
                                              ),
                                              hintText: 'Reason...',
                                            ),
                                            maxLines: 3,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, true),
                                          child: const Text(
                                            'Submit',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true &&
                                  context.mounted &&
                                  reasonController.text.isNotEmpty) {
                                await ref
                                    .read(moderationActionsProvider.notifier)
                                    .reportContent(
                                      reportedUserId: listing.sellerId,
                                      listingId: listing.id,
                                      reason: reasonController.text,
                                    );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Report submitted successfully.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            } else if (value == 'block') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          radius.xl,
                                        ),
                                      ),
                                      title: const Text('Block User'),
                                      content: const Text(
                                        'Are you sure you want to block this user? Their listings will be instantly removed from your feed.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, true),
                                          child: const Text(
                                            'Block',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                if (!context.mounted) return;
                                final goRouter = GoRouter.of(context);
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                try {
                                  await ref
                                      .read(moderationActionsProvider.notifier)
                                      .blockUser(listing.sellerId);
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('User blocked.'),
                                    ),
                                  );
                                  goRouter.goNamed(AppRoutes.home);
                                } catch (e) {
                                  debugPrint('Error blocking user: $e');
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error blocking user: $e'),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'report',
                                  child: Text('Report Listing'),
                                ),
                                const PopupMenuItem(
                                  value: 'block',
                                  child: Text(
                                    'Block User',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                        ),
                      ),
                    ], // end if (!isOwnListing)
                  ], // end Row children
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReadOnlyRateCard extends StatelessWidget {
  const _ReadOnlyRateCard({required this.label, required this.price});
  final String label;
  final double price;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(radius.md),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: typo.labelSmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${price.toStringAsFixed(0)}',
              style: typo.titleMedium.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRentalSummary(Order order) {
  if (order.rentalStartDate == null || order.rentalEndDate == null) {
    return 'Total: \$${order.totalPrice.toStringAsFixed(0)}';
  }
  final days = order.rentalEndDate!.difference(order.rentalStartDate!).inDays;
  final duration = days > 0 ? days : 1;
  final unitLabel = duration == 1 ? 'Day' : 'Days';
  return '$duration $unitLabel, Total: \$${order.totalPrice.toStringAsFixed(0)}';
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(radius.md),
          ),
          child: Column(
            children: [
              Icon(icon, color: colors.primary, size: 24),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
