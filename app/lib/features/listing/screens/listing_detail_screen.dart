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
import 'package:smivo/data/repositories/school_repository.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/shared/providers/school_data_provider.dart';
import 'package:smivo/shared/widgets/action_error_dialog.dart';
import 'package:smivo/shared/widgets/action_success_dialog.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smivo/shared/widgets/themed_confirm_dialog.dart';

import 'package:smivo/core/providers/moderation_provider.dart';
import 'package:smivo/data/repositories/moderation_repository.dart';
import 'package:smivo/shared/widgets/report_dialog.dart';
import 'package:smivo/shared/widgets/pickup_address_selector.dart';

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
  // State for the buyer's address change section.
  String? _buyerResolvedAddress; // The address the buyer typed or selected
  String? _buyerResolvedPickupId; // null = custom text
  final GlobalKey<PickupAddressSelectorState> _buyerSelectorKey =
      GlobalKey<PickupAddressSelectorState>();
  bool _showChangeAddress = false;
  bool _datesInitialized = false;

  @override
  void dispose() {
    _buyerSelectorKey.currentState?.saveIfSpecifying();
    // NOTE: These providers are keepAlive:true to survive widget-tree
    // transitions (e.g. MONTH→DAY rate switch). Reset them on dispose so
    // navigating to a different listing always starts from a clean state.
    ref.invalidate(rentalStartDateProvider);
    ref.invalidate(rentalEndDateProvider);
    ref.invalidate(saleStartDateProvider);
    ref.invalidate(selectedRentalRateProvider);
    ref.invalidate(rentalDurationProvider);
    super.dispose();
  }

  Future<void> _showOrderSuccessDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder:
          (ctx) => ActionSuccessDialog(
            title: 'Order Submitted',
            message: 'Submitted successfully. Under platform review.',
            buttonText: 'OK',
            onPressed: () => Navigator.of(ctx).pop(),
          ),
    );
  }

  void _initializeDates(Listing listing) {
    if (_datesInitialized) return;
    _datesInitialized = true;

    // NOTE: Clamp to midnight-today so the date picker's firstDate is never
    // in the past. If availableDate is in the future, use it; otherwise use
    // today. Both are truncated to midnight for picker compatibility.
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final rawInitial = listing.availableDate ?? listing.createdAt;
    final availableMidnight = DateTime(
      rawInitial.year,
      rawInitial.month,
      rawInitial.day,
    );
    final initialDate =
        availableMidnight.isAfter(today) ? availableMidnight : today;

    // NOTE: Use Future.microtask so the provider state is written immediately
    // after the current build frame completes, before the next paint.
    // Providers are keepAlive:true so they won't be disposed during this gap.
    Future.microtask(() {
      if (!mounted) return;
      ref.read(rentalStartDateProvider.notifier).setDate(initialDate);
      ref
          .read(rentalEndDateProvider.notifier)
          .setDate(initialDate.add(const Duration(days: 1)));
      ref.read(saleStartDateProvider.notifier).setDate(initialDate);
    });
  }

  Future<void> _showDelistDialog(BuildContext context, WidgetRef ref, Listing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => ThemedConfirmDialog(
            title: 'Delist Item',
            message:
                'Are you sure you want to delist "${listing.title}"? '
                'This will cancel all pending offers and remove it from the marketplace.',
            confirmText: 'Delist',
            cancelText: 'Keep Listed',
            isDestructive: true,
          ),
    );

    if (confirmed == true) {
      // 1. Update listing status to cancelled
      final listingRepo = ref.read(listingRepositoryProvider);
      await listingRepo.delistListing(listing.id);
      // 2. Cancel all pending orders for this listing
      final orderRepo = ref.read(orderRepositoryProvider);
      await orderRepo.cancelAllPendingOrders(listing.id);
      // 3. Navigate back
      if (context.mounted) {
        // NOTE: Navigate to home (not sellerCenter) so the back
        // button always has a valid destination. Using goNamed to
        // sellerCenter cleared the nav stack, trapping the user.
        context.goNamed(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.id));

    // Initialize dates immediately if data is already available (cached)
    if (listingAsync.hasValue) {
      _initializeDates(listingAsync.value!);
    }

    // Also listen for data arriving asynchronously
    ref.listen<AsyncValue<Listing>>(
      listingDetailProvider(widget.id),
      (previous, next) {
        if (next.value != null) {
          _initializeDates(next.value!);
        }
      },
    );

    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
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
          final currentUserId = ref.watch(authStateProvider).value?.id;
          final isOwnListing =
              currentUserId != null && currentUserId == listing.sellerId;

          // NOTE: Date initialization is handled by _initializeDates() which
          // is called above (lines 154-165) and uses addPostFrameCallback.
          // No secondary init block needed here.

          final existingOrder = ref.watch(
            existingBuyerOrderProvider(listing.id),
          );
          final isBlockedBySeller = ref.watch(
            isBlockedBySellerProvider(listing.sellerId),
          );
          // Removed imageUrls map as we now pass the whole images list
          // NOTE: Tag removed per design — no overlay text on images.
          // Load DB conditions for dynamic label resolution
          final conditionsList = ref.watch(mySchoolConditionsProvider).value;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(listingDetailProvider(widget.id));
                  await ref.read(listingDetailProvider(widget.id).future);
                },
                child: SelectionArea(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListingImageCarousel(
                          images: listing.images,
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
                                // Uses secondaryContainer (Flat yellow / Teal accent)
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
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      size: 18,
                                      color: colors.onSurface,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Description',
                                      style: typo.labelLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 24),
                                  child: Text(
                                    listing.description ??
                                        'No description provided.',
                                    style: typo.bodyMedium,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (listing.moderationStatus == 'rejected' ||
                                    listing.moderationStatus ==
                                        'taken_down') ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.error
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                        radius.md,
                                      ),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.block,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Listing Rejected',
                                              style: typo.titleMedium.copyWith(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.error,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'This item was rejected for violating our community guidelines. Violation types:',
                                          style: typo.bodyMedium.copyWith(
                                            color: colors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          (listing.moderationNote ??
                                                  'Policy Violation')
                                              .replaceAll(
                                                RegExp(
                                                  r'^automatically rejected by (open ai|openai):\s*',
                                                  caseSensitive: false,
                                                ),
                                                '',
                                              )
                                              .replaceAll(
                                                RegExp(
                                                  r'^AI:\s*',
                                                  caseSensitive: false,
                                                ),
                                                '',
                                              ),
                                          style: typo.bodyLarge.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                if (!isSale) ...[
                                  if (!isOwnListing &&
                                      listing.status == 'active')
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
                                            ((listing.rentalWeeklyPrice !=
                                                        null &&
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
                                            (listing.rentalMonthlyPrice !=
                                                    null &&
                                                listing.rentalMonthlyPrice! >
                                                    0))
                                          const SizedBox(width: 12),
                                        if (listing.rentalMonthlyPrice !=
                                                null &&
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
                                // ── Pickup Location Section ──────────────────
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: 18,
                                                color: colors.onSurface,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Pickup Location',
                                                style: typo.labelLarge.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          // Display the listing's address as plain text.
                                          // Prefer customPickupNote (free-text address);
                                          // fall back to the preset location name.
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 24,
                                            ),
                                            child: Text(
                                              currentUserId == null
                                                  ? 'Please login to view'
                                                  : (listing.customPickupNote ??
                                                      listing.pickupLocation?.name ??
                                                      'Not specified'),
                                              style: typo.bodyMedium.copyWith(
                                                color: colors.onSurface,
                                              ),
                                            ),
                                          ),
                                          // School name for the listing's campus.
                                          // NOTE: Uses schoolByIdProvider (direct ID lookup) instead of
                                          // activeSchools so dev/test schools are never filtered out.
                                          Consumer(
                                            builder: (ctx, ref2, _) {
                                              final schoolAsync = ref2.watch(
                                                schoolByIdProvider(
                                                  listing.schoolId,
                                                ),
                                              );
                                              return schoolAsync.when(
                                                loading:
                                                    () => const SizedBox.shrink(),
                                                error:
                                                    (_, __) =>
                                                        const SizedBox.shrink(),
                                                data: (school) {
                                                  if (school == null) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 4,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.school_outlined,
                                                          size: 18,
                                                          color:
                                                              colors.onSurface,
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          'Campus: ${school.name}',
                                                          style: typo.labelLarge
                                                              .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    colors
                                                                        .onSurface,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                size: 18,
                                                color: colors.onSurface,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Available Date',
                                                style: typo.labelLarge.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 24,
                                            ),
                                            child: Text(
                                              DateFormat('MM/dd/yyyy').format(
                                                listing.availableDate ??
                                                    listing.createdAt,
                                              ),
                                              style: typo.bodyMedium.copyWith(
                                                color: colors.onSurface,
                                              ),
                                            ),
                                          ),
                                          // ── Buyer address-change section ──
                                          if (listing.allowPickupChange &&
                                              !isOwnListing &&
                                              currentUserId != null) ...[
                                            const SizedBox(height: 12),
                                            GestureDetector(
                                              onTap:
                                                  () => setState(
                                                    () =>
                                                        _showChangeAddress =
                                                            !_showChangeAddress,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        _showChangeAddress
                                                            ? Icons.expand_less
                                                            : Icons
                                                                .edit_location_alt_outlined,
                                                        size: 18,
                                                        color: colors.primary,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        _showChangeAddress
                                                            ? 'Cancel address change'
                                                            : 'Change pickup address',
                                                        style: typo.labelLarge
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  colors.primary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (_showChangeAddress) ...[
                                              const SizedBox(height: 12),
                                              // NOTE: PickupAddressSelector
                                              // handles preset + custom history
                                              // + 'Specify Address' in one widget.
                                              PickupAddressSelector(
                                                key: _buyerSelectorKey,
                                                onPickupIdChanged:
                                                    (id) => setState(
                                                      () =>
                                                          _buyerResolvedPickupId =
                                                              id,
                                                    ),
                                                onAddressChanged:
                                                    (addr) => setState(
                                                      () =>
                                                          _buyerResolvedAddress =
                                                              addr,
                                                    ),
                                              ),
                                              // Buyer's school name — shown below
                                              // the address selector they chose.
                                              Consumer(
                                                builder: (ctx2, ref2, _) {
                                                  final schoolAsync = ref2
                                                      .watch(mySchoolProvider);
                                                  return schoolAsync.when(
                                                    loading:
                                                        () =>
                                                            const SizedBox.shrink(),
                                                    error:
                                                        (_, __) =>
                                                            const SizedBox.shrink(),
                                                    data: (school) {
                                                      if (school == null) {
                                                        return const SizedBox.shrink();
                                                      }
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 6,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .school_outlined,
                                                              size: 18,
                                                              color:
                                                                  colors
                                                                      .onSurface,
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Text(
                                                              'Campus: ${school.name}',
                                                              style: typo
                                                                  .labelLarge
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        colors
                                                                            .onSurface,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ],
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
                                  if (currentUserId == null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                        'Please login to view',
                                        style: typo.bodyMedium.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  else
                                    SellerProfileCard(
                                      user: seller,
                                      onMessageTap: () async {
                                        final user =
                                            ref.read(authStateProvider).value;
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
                                          final order = existingOrder.value;
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
                                            otherUserProfile: listing.seller,
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
                                          showDialog(
                                            context: context,
                                            builder:
                                                (ctx) => ActionErrorDialog(
                                                  title: 'Chat Error',
                                                  message: e.toString(),
                                                ),
                                          );
                                        }
                                      },
                                    ),
                                ],
                                const SizedBox(height: 24),
                                // Stats Section — only visible on own listing
                                if (isOwnListing) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.bar_chart_outlined,
                                        size: 18,
                                        color: colors.onSurface,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Listing Stats',
                                        style: typo.labelLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                    ],
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
                                  if (listing.status == 'active' &&
                                      listing.moderationStatus != 'rejected' &&
                                      listing.moderationStatus !=
                                          'taken_down') ...[
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
                                          loading:
                                              () => const SizedBox.shrink(),
                                          error:
                                              (_, __) =>
                                                  const SizedBox.shrink(),
                                          data: (hasOrder) {
                                            if (hasOrder) {
                                              return const SizedBox.shrink();
                                            }
                                            return Row(
                                              children: [
                                                // Delist button
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed:
                                                        () => _showDelistDialog(
                                                          context,
                                                          ref,
                                                          listing,
                                                        ),
                                                    icon: Icon(
                                                      Icons.remove_circle_outline,
                                                      color: colors.error,
                                                      size: 18,
                                                    ),
                                                    label: Text(
                                                      'Delist',
                                                      style: typo.labelLarge.copyWith(
                                                        color: colors.error,
                                                      ),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      side: BorderSide(
                                                        color: colors.error,
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
                                                ),
                                                const SizedBox(width: 12),
                                                // NOTE: Edit Listing button navigates to
                                                // TransactionManagementScreen with the
                                                // edit section auto-expanded (section=edit).
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () {
                                                      context.pushNamed(
                                                        AppRoutes.transactionManagement,
                                                        pathParameters: {'id': listing.id},
                                                        queryParameters: {
                                                          'section': 'edit',
                                                        },
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.edit_outlined,
                                                      color: colors.primary,
                                                      size: 18,
                                                    ),
                                                    label: Text(
                                                      'Edit',
                                                      style: typo.labelLarge.copyWith(
                                                        color: colors.primary,
                                                      ),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      side: BorderSide(
                                                        color: colors.primary,
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
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ],
                                // NOTE: Show a banner when the buyer's previous offer
                                // was invalidated so they know to re-submit.
                                if (!isOwnListing)
                                  existingOrder.maybeWhen(
                                    data: (order) {
                                      if (order?.status != 'invalidated') {
                                        return const SizedBox.shrink();
                                      }
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: colors.warning.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(radius.card),
                                          border: Border.all(
                                            color: colors.warning,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.update,
                                              color: colors.warning,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                'The seller updated this listing. '
                                                'Please review and re-submit your offer.',
                                                style: typo.bodySmall.copyWith(
                                                  color: colors.onSurface,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    orElse: () => const SizedBox.shrink(),
                                  ),
                                // Primary Action Button — hidden on own listing
                                if (!isOwnListing)
                                  existingOrder.when(
                                    loading: () => const SizedBox.shrink(),
                                    error: (_, __) => const SizedBox.shrink(),
                                    data: (order) {
                                      // NOTE: If the order is invalidated, treat it as
                                      // 'no blocking order' so the buyer can re-submit.
                                      final isInvalidated =
                                          order?.status == 'invalidated';
                                      if (order != null && !isInvalidated) {
                                        final isSaleOrder =
                                            order.orderType == 'sale';
                                        final submittedDate = DateFormat(
                                          isSaleOrder
                                              ? 'MM/dd/yyyy HH:mm'
                                              : 'MMM d, yyyy · h:mm a',
                                        ).format(order.createdAt.toLocal());

                                        // Determine status-based UI
                                        String title;
                                        IconData icon = Icons.check_circle;
                                        Color iconColor = colors.success;

                                        if (order.status == 'pending') {
                                          title =
                                              isSaleOrder
                                                  ? 'Reserved'
                                                  : 'Application Submitted';
                                        } else if (order.status == 'confirmed') {
                                          title = 'Order Confirmed';
                                        } else if (order.status == 'completed') {
                                          title = 'Order Completed';
                                        } else if (order.status == 'cancelled') {
                                          title = 'Order Cancelled';
                                          icon = Icons.cancel;
                                          iconColor = colors.error;
                                        } else if (order.status == 'missed') {
                                          title = 'Offer Missed';
                                          icon = Icons.info_outline;
                                          iconColor = colors.outlineVariant;
                                        } else if (order.status == 'invalidated') {
                                          // NOTE: invalidated = seller updated the listing;
                                          // buyer must re-submit. Shown in pending section.
                                          title = 'Listing Updated';
                                          icon = Icons.update;
                                          iconColor = colors.warning;
                                        } else {
                                          title =
                                              'Order ${order.status.toUpperCase()}';
                                        }

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
                                                icon,
                                                color: iconColor,
                                                size: 28,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                title,
                                                style: typo.titleMedium.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              // NOTE: Awaiting approval subtitle — only shown for pending orders
                                              if (order.status == 'pending') ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Awaiting seller\'s approval',
                                                  style: typo.bodySmall.copyWith(
                                                    color: colors.outlineVariant,
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 4),
                                              Text(
                                                submittedDate,
                                                style: typo.bodySmall.copyWith(
                                                  color: colors.outlineVariant,
                                                ),
                                              ),
                                              // NOTE: Expected Pickup only shown for rental orders
                                              // (rentalStartDate is always set for rentals).
                                              // Sale orders have no equivalent scheduled date field.
                                              if (order.rentalStartDate != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Expected Pickup: ${DateFormat('MMM d, yyyy').format(order.rentalStartDate!.toLocal())}',
                                                  style: typo.bodySmall.copyWith(
                                                    color: colors.outlineVariant,
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 8),
                                              // Price display — different format for sale vs rental
                                              if (order.orderType ==
                                                  'rental') ...[
                                                Text(
                                                  _formatRentalSummary(order),
                                                  style: typo.bodyMedium
                                                      .copyWith(
                                                        color: colors.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                              // Cancel button — for pending or confirmed (unconfirmed delivery)
                                              if (order.status == 'pending' ||
                                                  (order.status ==
                                                          'confirmed' &&
                                                      !order
                                                          .deliveryConfirmedByBuyer &&
                                                      !order
                                                          .deliveryConfirmedBySeller)) ...[
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
                                                            (
                                                              ctx,
                                                            ) => ThemedConfirmDialog(
                                                              title:
                                                                  order.status == 'pending'
                                                                      ? 'Cancel Application'
                                                                      : 'Cancel Order',
                                                              message:
                                                                  order.status == 'pending'
                                                                      ? 'Are you sure you want to cancel your application?'
                                                                      : 'Are you sure you want to cancel this order?',
                                                              confirmText:
                                                                  order.status == 'pending'
                                                                      ? 'Cancel Application'
                                                                      : 'Cancel Order',
                                                              cancelText: 'Keep',
                                                              isDestructive: true,
                                                            ),
                                                      );
                                                      if (confirmed == true &&
                                                          context.mounted) {
                                                        try {
                                                          await ref
                                                              .read(
                                                                orderActionsProvider
                                                                    .notifier,
                                                              )
                                                              .cancelOrder(
                                                                order.id,
                                                              );
                                                          if (context.mounted) {
                                                            context.pop();
                                                          }
                                                        } catch (e) {
                                                          if (!context.mounted) return;
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (ctx) => ActionErrorDialog(
                                                                  title: 'Cancellation Failed',
                                                                  message: e.toString(),
                                                                ),
                                                          );
                                                        }
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
                                                    child: Text(
                                                      order.status == 'pending'
                                                          ? 'Cancel Application'
                                                          : 'Cancel Order',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      }

                                      // NOTE: Check if the seller has blocked
                                      // the current user via the dedicated
                                      // check_order_eligibility RPC.
                                      if (isBlockedBySeller.isLoading) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      }

                                      if (isBlockedBySeller.value == true) {
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
                                                Icons.block_outlined,
                                                color: colors.error,
                                                size: 28,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Item Unavailable',
                                                style: typo.titleMedium
                                                    .copyWith(
                                                      color: colors.onSurface,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'You cannot interact with this seller.',
                                                style: typo.bodySmall.copyWith(
                                                  color: colors.outlineVariant,
                                                ),
                                              ),
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
                                                style: typo.titleMedium
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
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

                                      // Sale Delivery Date Picker Section
                                      final Widget? saleDatePicker =
                                          (isSale &&
                                                  listing.status == 'active' &&
                                                  !isOwnListing)
                                              ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .local_shipping_outlined,
                                                        size: 18,
                                                        color: colors.onSurface,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        'Expected Delivery/Pickup',
                                                        style: typo.labelLarge
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  colors
                                                                      .onSurface,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                left: 24,
                                                              ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              _SaleDateBox(
                                                                listing:
                                                                    listing,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 24),
                                                ],
                                              )
                                              : null;

                                      final isSubmitting =
                                          ref
                                              .watch(orderActionsProvider)
                                              .isLoading;
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (saleDatePicker != null)
                                            saleDatePicker,
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed:
                                                  isSubmitting
                                                      ? null
                                                      : () async {
                                                        // Before submitting order, re-fetch listing to check if still active
                                                        try {
                                                          final freshListing = await ref
                                                              .read(
                                                                listingRepositoryProvider,
                                                              )
                                                              .fetchListing(
                                                                listing.id,
                                                              );
                                                          if (freshListing.status !=
                                                              'active') {
                                                            if (context.mounted) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    'This item is no longer available',
                                                                  ),
                                                                ),
                                                              );
                                                              // Refresh the page
                                                              ref.invalidate(
                                                                listingDetailProvider(
                                                                  widget.id,
                                                                ),
                                                              );
                                                            }
                                                            return;
                                                          }
                                                        } catch (_) {
                                                          // If fetch fails (e.g. item deleted), treat as unavailable
                                                          if (context.mounted) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'This item is no longer available',
                                                                ),
                                                              ),
                                                            );
                                                            ref.invalidate(
                                                              listingDetailProvider(
                                                                widget.id,
                                                              ),
                                                            );
                                                          }
                                                          return;
                                                        }
                                                        if (!context.mounted) return;

                                                        final user = ref
                                                            .read(
                                                              authStateProvider,
                                                            )
                                                            .value;
                                                        if (user == null) {
                                                          context.pushNamed(
                                                            AppRoutes.login,
                                                          );
                                                          return;
                                                        }
                                                        if (user.emailConfirmedAt ==
                                                            null) {
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
                                                        if (user.id ==
                                                            listing.sellerId) {
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
                                                            listing
                                                                .transactionType
                                                                .toLowerCase() ==
                                                            'rental';
                                                        double orderPrice;
                                                        DateTime? rentalStart,
                                                            rentalEnd;
                                                        if (isRental) {
                                                          final selectedRate =
                                                              ref.read(
                                                                selectedRentalRateProvider,
                                                              );
                                                          final startDate = ref
                                                              .read(
                                                                rentalStartDateProvider,
                                                              );
                                                          if (selectedRate ==
                                                              'DAY') {
                                                            final endDate = ref
                                                                .read(
                                                                  rentalEndDateProvider,
                                                                );
                                                            final daysDiff =
                                                                endDate
                                                                    .difference(
                                                                      startDate,
                                                                    )
                                                                    .inDays;
                                                            final days =
                                                                daysDiff > 0
                                                                    ? daysDiff
                                                                    : 1;
                                                            orderPrice =
                                                                (listing.rentalDailyPrice ??
                                                                    0) *
                                                                days;
                                                            rentalStart =
                                                                startDate;
                                                            rentalEnd = endDate;
                                                          } else if (selectedRate ==
                                                              'WEEK') {
                                                            final duration = ref
                                                                .read(
                                                                  rentalDurationProvider,
                                                                );
                                                            orderPrice =
                                                                (listing.rentalWeeklyPrice ??
                                                                    0) *
                                                                duration;
                                                            rentalStart =
                                                                startDate;
                                                            rentalEnd =
                                                                startDate.add(
                                                                  Duration(
                                                                    days:
                                                                        7 *
                                                                        duration,
                                                                  ),
                                                                );
                                                          } else {
                                                            final duration = ref
                                                                .read(
                                                                  rentalDurationProvider,
                                                                );
                                                            orderPrice =
                                                                (listing.rentalMonthlyPrice ??
                                                                    0) *
                                                                duration;
                                                            rentalStart =
                                                                startDate;
                                                            rentalEnd =
                                                                startDate.add(
                                                                  Duration(
                                                                    days:
                                                                        30 *
                                                                        duration,
                                                                  ),
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
                                                          orderPrice =
                                                              listing.price;
                                                          rentalStart = ref.read(
                                                            saleStartDateProvider,
                                                          );
                                                        }

                                                        // Pre-submission date validation based on available_date
                                                        if (listing.availableDate !=
                                                                null &&
                                                            rentalStart !=
                                                                null) {
                                                          final normalizedAvailableDate =
                                                              DateTime(
                                                                listing
                                                                    .availableDate!
                                                                    .year,
                                                                listing
                                                                    .availableDate!
                                                                    .month,
                                                                listing
                                                                    .availableDate!
                                                                    .day,
                                                              );
                                                          final normalizedRentalStart =
                                                              DateTime(
                                                                rentalStart
                                                                    .year,
                                                                rentalStart
                                                                    .month,
                                                                rentalStart
                                                                    .day,
                                                              );

                                                          if (normalizedRentalStart
                                                              .isBefore(
                                                                normalizedAvailableDate,
                                                              )) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  isRental
                                                                      ? 'Rental start date cannot be earlier than available date (${DateFormat('MM/dd').format(normalizedAvailableDate)})'
                                                                      : 'Delivery date cannot be earlier than available date (${DateFormat('MM/dd').format(normalizedAvailableDate)})',
                                                                ),
                                                                backgroundColor:
                                                                    colors
                                                                        .error,
                                                              ),
                                                            );
                                                            return;
                                                          }
                                                        }

                                                        // Rental duration validation
                                                        if (isRental &&
                                                            rentalEnd != null &&
                                                            rentalStart !=
                                                                null) {
                                                          if (rentalEnd
                                                                  .isBefore(
                                                                    rentalStart,
                                                                  ) ||
                                                              rentalEnd
                                                                  .isAtSameMomentAs(
                                                                    rentalStart,
                                                                  )) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: const Text(
                                                                  'Rental end date must be after the start date',
                                                                ),
                                                                backgroundColor:
                                                                    colors
                                                                        .error,
                                                              ),
                                                            );
                                                            return;
                                                          }
                                                        }

                                                        try {
                                                          // NOTE: Buyer address-change priority:
                                                          // 1. If buyer changed address: use buyer-selected address
                                                          //    + buyer's school name (text snapshot).
                                                          // 2. Otherwise: use listing's address + listing's school.
                                                          // Both values are snapshotted as text fields in the order.
                                                          final buyerChangedAddress =
                                                              _showChangeAddress &&
                                                              _buyerResolvedAddress !=
                                                                  null &&
                                                              _buyerResolvedAddress!
                                                                  .isNotEmpty;

                                                          final effectivePickupId =
                                                              buyerChangedAddress
                                                                  ? _buyerResolvedPickupId
                                                                  : listing
                                                                      .pickupLocationId;

                                                          final effectivePickupName =
                                                              buyerChangedAddress
                                                                  ? _buyerResolvedAddress!
                                                                  : (listing
                                                                          .customPickupNote ??
                                                                      listing
                                                                          .pickupLocation
                                                                          ?.name ??
                                                                      'Unknown Address');

                                                          // Write buyer's school when address changed,
                                                          // otherwise write the listing's school.
                                                          // NOTE: Not final — assigned inside try/catch branch
                                                          String schoolName = '';
                                                          if (buyerChangedAddress) {
                                                            final buyerSchool =
                                                                ref
                                                                    .read(
                                                                      mySchoolProvider,
                                                                    )
                                                                    .value;
                                                            schoolName =
                                                                buyerSchool
                                                                    ?.name ??
                                                                'Unknown School';
                                                          } else {
                                                            // NOTE: Do NOT resolve school name from the activeSchools
                                                            // local list. That list excludes schools whose slug starts
                                                            // with 'smivo-' (dev/test schools), so the lookup returns
                                                            // null for test accounts and causes 'Unknown School' to be
                                                            // persisted to the DB.
                                                            //
                                                            // Instead, fetch directly by ID — no slug filter applies.
                                                            try {
                                                              final school =
                                                                  await ref
                                                                      .read(
                                                                        schoolRepositoryProvider,
                                                                      )
                                                                      .fetchSchool(
                                                                        listing
                                                                            .schoolId,
                                                                      );
                                                              schoolName =
                                                                  school.name;
                                                            } catch (_) {
                                                              // Graceful fallback: use the schoolId UUID rather
                                                              // than the misleading 'Unknown School' string.
                                                              schoolName =
                                                                  listing
                                                                      .schoolId;
                                                            }
                                                          }


                                                          await ref
                                                              .read(
                                                                orderActionsProvider
                                                                    .notifier,
                                                              )
                                                              .createOrder(
                                                                listingId:
                                                                    listing.id,
                                                                sellerId:
                                                                    listing
                                                                        .sellerId,
                                                                price:
                                                                    orderPrice,
                                                                orderType:
                                                                    isRental
                                                                        ? 'rental'
                                                                        : 'sale',
                                                                rentalStartDate:
                                                                    rentalStart,
                                                                rentalEndDate:
                                                                    rentalEnd,
                                                                depositAmount:
                                                                    listing
                                                                        .depositAmount,
                                                                pickupLocationId:
                                                                    effectivePickupId,
                                                                pickupLocationName:
                                                                    effectivePickupName,
                                                                school:
                                                                    schoolName,
                                                              );
                                                          if (!context.mounted) {
                                                            return;
                                                          }
                                                          await _showOrderSuccessDialog(
                                                            context,
                                                          );
                                                          if (!context.mounted) {
                                                            return;
                                                          }
                                                          context.goNamed(
                                                            AppRoutes.home,
                                                          );
                                                        } catch (e) {
                                                          if (!context.mounted) {
                                                            return;
                                                          }

                                                          if (e
                                                              .toString()
                                                              .contains(
                                                                'in_progress',
                                                              )) {
                                                            return;
                                                          }

                                                          // Handle duplicate order submission gracefully
                                                          final isDuplicate = e
                                                              .toString()
                                                              .contains(
                                                                'unique_pending_order_per_buyer_listing',
                                                              );
                                                          final errorMessage =
                                                              isDuplicate
                                                                  ? 'You already have a pending application for this item.'
                                                                  : 'Failed to place order: ${e.toString()}';

                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                errorMessage,
                                                              ),
                                                              backgroundColor:
                                                                  isDuplicate
                                                                      ? colors
                                                                          .primary
                                                                      : colors
                                                                          .error,
                                                            ),
                                                          );
                                                        }
                                                      },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: colors.primary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        radius.button,
                                                      ),
                                                ),
                                                elevation: 0,
                                              ),
                                              child:
                                                  isSubmitting
                                                      ? SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2.5,
                                                              color:
                                                                  colors
                                                                      .onPrimary,
                                                            ),
                                                      )
                                                      : Text(
                                                        isSale
                                                            ? 'Request to Buy'
                                                            : 'Request to Rent',
                                                        style: typo.titleMedium
                                                            .copyWith(
                                                              color:
                                                                  colors
                                                                      .onPrimary,
                                                            ),
                                                      ),
                                            ),
                                          ),
                                        ],
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
                    // Share Button — hidden when listing is rejected / taken down by platform
                    // NOTE: We disable sharing rather than hiding the button entirely,
                    // so the user still sees where the share action would be. This also
                    // avoids the layout shifting that hiding would cause for other buttons.
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
                      child: Builder(
                        builder: (context) {
                          // NOTE: Reject sharing for content that was removed by the platform.
                          // 'rejected' = failed AI/manual review before publishing.
                          // 'taken_down' = removed after publishing (AI or admin action).
                          final isRemoved =
                              listing.moderationStatus == 'rejected' ||
                              listing.moderationStatus == 'taken_down';

                          return IconButton(
                            icon: Icon(
                              Icons.ios_share,
                              // Visually indicate the button is disabled
                              color: isRemoved
                                  ? colors.outlineVariant
                                  : colors.onSurface,
                            ),
                            // null disables the button — no tap response
                            onPressed: isRemoved
                                ? null
                                : () {
                                    // NOTE: Only share the bare URL. When a message
                                    // contains just a URL, iMessage / WeChat / Slack
                                    // will crawl it and render the rich preview card
                                    // (og:title, og:image, og:description).
                                    // Adding extra text alongside the URL often prevents
                                    // the platform from generating the preview card.
                                    const baseUrl = 'https://smivo.io';
                                    final listingUrl =
                                        '$baseUrl/listing/${listing.id}';
                                    final box =
                                        context.findRenderObject() as RenderBox?;
                                    SharePlus.instance.share(
                                      ShareParams(
                                        uri: Uri.parse(listingUrl),
                                        sharePositionOrigin: box != null
                                            ? box.localToGlobal(Offset.zero) &
                                                box.size
                                            : null,
                                      ),
                                    );
                                  },
                          );
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
                          final isSaved = isSavedAsync.value ?? false;
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
                                final user = ref.read(authStateProvider).value;
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
                            final user = ref.read(authStateProvider).value;
                            if (user == null) {
                              context.pushNamed(AppRoutes.login);
                              return;
                            }

                            if (value == 'report') {
                              final currentUserId = user.id;

                              // Check if already reported
                              try {
                                final repo = ref.read(
                                  moderationRepositoryProvider,
                                );
                                final hasReported = await repo
                                    .hasAlreadyReported(
                                      reporterId: currentUserId,
                                      reportedUserId: listing.sellerId,
                                      listingId: listing.id,
                                    );

                                if (hasReported) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'You have already reported this listing.',
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }
                              } catch (e) {
                                // Ignore error and proceed to dialog
                              }

                              if (!context.mounted) return;

                              showDialog(
                                context: context,
                                builder:
                                    (ctx) => ReportDialog(
                                      title: 'Report Listing',
                                      onSubmit: (category, reason) async {
                                        try {
                                          await ref
                                              .read(
                                                moderationActionsProvider
                                                    .notifier,
                                              )
                                              .reportContent(
                                                reportedUserId:
                                                    listing.sellerId,
                                                listingId: listing.id,
                                                reasonCategory: category,
                                                reason: reason,
                                              );
                                          if (context.mounted) {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (
                                                    ctx,
                                                  ) => const ActionSuccessDialog(
                                                    title: 'Success',
                                                    message:
                                                        'Submitted successfully. Under platform review.',
                                                  ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  e.toString().replaceAll(
                                                    'Exception: ',
                                                    '',
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                              );
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
                                          child: Text(
                                            'Block',
                                            style: typo.labelLarge.copyWith(color: colors.error),
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
                                PopupMenuItem(
                                  value: 'block',
                                  child: Text(
                                    'Block User',
                                    style: typo.labelLarge.copyWith(color: colors.error),
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
  final daysDiff =
      order.rentalEndDate!.difference(order.rentalStartDate!).inDays;
  final duration = daysDiff > 0 ? daysDiff : 1;
  final unitLabel = duration == 1 ? 'Day' : 'Days';
  return '$duration $unitLabel, Total: \$${order.totalPrice.toStringAsFixed(0)}';
}

class _SaleDateBox extends ConsumerWidget {
  const _SaleDateBox({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final providerDate = ref.watch(saleStartDateProvider);
    final formatter = DateFormat('MM/dd/yyyy');

    // NOTE: Compute the correct firstValidDate (same logic as the picker onTap)
    // so we can use it as a display fallback when the provider still holds the
    // DateTime.now() default (i.e., microtask hasn't fired yet on first frame).
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final rawFirstValid = listing.availableDate ?? listing.createdAt;
    final availableMidnight = DateTime(
      rawFirstValid.year,
      rawFirstValid.month,
      rawFirstValid.day,
    );
    final firstValidDate =
        availableMidnight.isAfter(today) ? availableMidnight : today;
    // If the provider date is before the earliest valid date, it's still the
    // stale default — show firstValidDate so the user sees the correct value
    // from the very first frame without waiting for the microtask.
    final startDate =
        providerDate.isBefore(firstValidDate) ? firstValidDate : providerDate;

    return GestureDetector(
      onTap: () async {
        // NOTE: Reuse firstValidDate and startDate computed in build() above —
        // they already apply the today-clamp and provider-fallback logic.
        final initDate =
            startDate.isBefore(firstValidDate) ? firstValidDate : startDate;

        final picked = await showDatePicker(
          context: context,
          initialDate: initDate,
          firstDate: firstValidDate,
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          ref.read(saleStartDateProvider.notifier).setDate(
            DateTime(picked.year, picked.month, picked.day),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(radius.input),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatter.format(startDate), style: typo.bodyMedium),
            const Icon(Icons.calendar_today_outlined, size: 16),
          ],
        ),
      ),
    );
  }
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
