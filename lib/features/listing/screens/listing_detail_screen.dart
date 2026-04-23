import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/listing/providers/listing_detail_provider.dart';
import 'package:smivo/features/listing/widgets/listing_image_carousel.dart';
import 'package:smivo/features/listing/widgets/rental_options_section.dart';
import 'package:smivo/features/listing/widgets/seller_profile_card.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/chat/widgets/chat_popup.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/shared/providers/school_provider.dart';

String _conditionLabel(String condition) {
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
  const ListingDetailScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  String? _selectedPickupLocationId;

  Future<void> _showOrderSuccessDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Order Submitted',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Waiting for seller approval.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: listingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Error loading listing: $err',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (listing) {
          final isSale = listing.transactionType.toLowerCase() == 'sale';
          final seller = listing.seller;
          final currentUserId = ref.watch(authStateProvider).valueOrNull?.id;
          final isOwnListing = currentUserId != null && currentUserId == listing.sellerId;
          
          // Use joined images, fallback to empty list
          final imageUrls = listing.images.map((img) => img.imageUrl).toList();
          
          // Status tag logic
          // NOTE: Show real condition for sale items, availability for rentals
          final statusTag = isSale ? _conditionLabel(listing.condition) : 'AVAILABLE NOW';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListingImageCarousel(
                  imageUrls: imageUrls,
                  tagText: statusTag,
                  isSale: isSale,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 32,
                          letterSpacing: -1,
                          height: 1.1,
                        ),
                      ),
                      
                      if (isSale) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '\$${listing.price.toStringAsFixed(0)}',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.priceTagPrimary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      
                      if (!isSale) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.priceTagPrimary, size: 16),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Smith College Campus', // Default fallback
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onSurface.withValues(alpha: 0.7),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        RentalOptionsSection(listing: listing),
                      ],

                      const SizedBox(height: AppSpacing.xl),
                      
                      // Description Section
                      Text(
                        isSale ? 'DESCRIPTION' : 'ABOUT THIS ITEM',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        listing.description ?? 'No description provided.',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Pickup Location Selector
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.priceTagPrimary),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'PICKUP LOCATION',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.onSurface.withValues(alpha: 0.5),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (listing.allowPickupChange)
                                      GestureDetector(
                                        onTap: () {},
                                        child: Text(
                                          'Change Location',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  ),
                                  child: !listing.allowPickupChange
                                      ? Container(
                                          alignment: Alignment.centerLeft,
                                          height: 48,
                                          child: Text(
                                            listing.pickupLocation?.name ?? 'Not specified',
                                            style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                                          ),
                                        )
                                      : DropdownButtonHideUnderline(
                                          child: Consumer(
                                            builder: (context, ref, _) {
                                              final pickupsAsync = ref.watch(myPickupLocationsProvider);
                                              return pickupsAsync.when(
                                                loading: () => const SizedBox(
                                                  height: 48,
                                                  child: Center(child: CircularProgressIndicator()),
                                                ),
                                                error: (err, _) => Container(
                                                  alignment: Alignment.centerLeft,
                                                  height: 48,
                                                  child: Text(
                                                    listing.pickupLocation?.name ?? 'Unable to load',
                                                    style: AppTextStyles.bodyMedium,
                                                  ),
                                                ),
                                                data: (locations) {
                                                  // Build a selected-location id (use listing's pickup as default 
                                                  // unless user has changed it)
                                                  final selectedId = _selectedPickupLocationId ?? 
                                                      listing.pickupLocationId;
                                                  
                                                  return DropdownButton<String>(
                                                    value: selectedId,
                                                    isExpanded: true,
                                                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                                                    onChanged: (String? newId) {
                                                      setState(() {
                                                        _selectedPickupLocationId = newId;
                                                      });
                                                    },
                                                    items: locations.map((loc) {
                                                      return DropdownMenuItem<String>(
                                                        value: loc.id,
                                                        child: Text(loc.name),
                                                      );
                                                    }).toList(),
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

                      const SizedBox(height: AppSpacing.xl),
                      
                      // Seller Section — hidden on own listing
                      if (seller != null && !isOwnListing)
                        SellerProfileCard(
                          name: seller.displayName ?? 'Anonymous Student',
                          avatarUrl: seller.avatarUrl ?? 'https://i.pravatar.cc/150?u=${seller.id}',
                          rating: '4.9', // Hardcoded placeholder for rating (Phase 2)
                          reviewCount: 12, // Hardcoded placeholder for reviews (Phase 2)
                          label: isSale ? 'SELLER' : 'LISTED BY',
                          onMessageTap: () async {
                            final user = ref.read(authStateProvider).valueOrNull;
                            if (user == null) {
                              context.pushNamed(AppRoutes.login);
                              return;
                            }

                            if (user.id == listing.sellerId) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('This is your own listing')),
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
                              showChatPopup(
                                context,
                                chatRoomId: chatRoom.id,
                                otherUserName: listing.seller?.displayName ?? 'Seller',
                                otherUserAvatar: listing.seller?.avatarUrl,
                                listingTitle: listing.title,
                                listingPrice: listing.price,
                                listingImageUrl: listing.images.firstOrNull?.imageUrl,
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        ),
                      
                      const SizedBox(height: AppSpacing.xl),

                      // Stats Section — only visible on own listing
                      if (isOwnListing) ...[
                        Text(
                          'LISTING STATS',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.5),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            _StatCard(
                              icon: Icons.visibility_outlined,
                              label: 'Views',
                              count: listing.viewCount,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _StatCard(
                              icon: Icons.bookmark_outline,
                              label: 'Saves',
                              count: listing.saveCount,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _StatCard(
                              icon: Icons.chat_bubble_outline,
                              label: 'Inquiries',
                              count: listing.inquiryCount,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      
                      // Primary Action Button — hidden on own listing
                      if (!isOwnListing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final user = ref.read(authStateProvider).valueOrNull;
                            
                            // Guard 1: must be logged in
                            if (user == null) {
                              context.pushNamed(AppRoutes.login);
                              return;
                            }
                            
                            // Guard 2: email must be verified
                            if (user.emailConfirmedAt == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please verify your email first')),
                              );
                              return;
                            }
                            
                            // Guard 3: can't buy your own listing
                            if (user.id == listing.sellerId) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('You cannot buy your own listing')),
                              );
                              return;
                            }
                            
                            final isRental = listing.transactionType.toLowerCase() == 'rental';
                            
                            double orderPrice;
                            DateTime? rentalStart;
                            DateTime? rentalEnd;
                            
                            if (isRental) {
                              // Read rental configuration from providers
                              final selectedRate = ref.read(selectedRentalRateProvider);
                              final startDate = ref.read(rentalStartDateProvider);
                              
                              // Calculate price and end date based on selected rate type
                              if (selectedRate == 'DAY') {
                                final endDate = ref.read(rentalEndDateProvider);
                                final days = endDate.difference(startDate).inDays;
                                final effectiveDays = days > 0 ? days : 1;
                                orderPrice = (listing.rentalDailyPrice ?? 0) * effectiveDays;
                                rentalStart = startDate;
                                rentalEnd = endDate;
                              } else if (selectedRate == 'WEEK') {
                                final duration = ref.read(rentalDurationProvider);
                                final totalDays = 7 * duration;
                                orderPrice = (listing.rentalWeeklyPrice ?? 0) * duration;
                                rentalStart = startDate;
                                rentalEnd = startDate.add(Duration(days: totalDays));
                              } else {
                                // MONTH
                                final duration = ref.read(rentalDurationProvider);
                                orderPrice = (listing.rentalMonthlyPrice ?? 0) * duration;
                                rentalStart = startDate;
                                rentalEnd = DateTime(
                                  startDate.year,
                                  startDate.month + duration,
                                  startDate.day,
                                );
                              }
                              
                              // Guard: total price must be > 0
                              if (orderPrice <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid rental configuration. Please select a valid rate and period.'),
                                  ),
                                );
                                return;
                              }
                            } else {
                              // Sale: use listing price directly
                              orderPrice = listing.price;
                            }
                            
                            try {
                              // NOTE: Use buyer's selected pickup if they changed it,
                              // otherwise fall back to seller's default pickup location.
                              final effectivePickupId = _selectedPickupLocationId 
                                  ?? listing.pickupLocationId;
                              
                              await ref.read(orderActionsProvider.notifier).createOrder(
                                listingId: listing.id,
                                sellerId: listing.sellerId,
                                price: orderPrice,
                                orderType: isRental ? 'rental' : 'sale',
                                rentalStartDate: rentalStart,
                                rentalEndDate: rentalEnd,
                                depositAmount: listing.depositAmount,
                                pickupLocationId: effectivePickupId,
                              );
                              
                              if (!context.mounted) return;
                              
                              // Show success dialog (existing UI)
                              await _showOrderSuccessDialog(context);
                              
                              if (!context.mounted) return;
                              
                              // Navigate to orders page after success dialog dismissed
                              context.goNamed(AppRoutes.orders);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to place order: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isSale ? 'Place Order' : 'Request to Rent',
                            style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              count.toString(),
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.outlineVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
