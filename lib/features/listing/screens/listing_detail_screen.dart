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
  String? _selectedPickupLocation;

  void _showOrderSuccessDialog(BuildContext context) {
    showDialog(
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
          
          // Use joined images, fallback to empty list
          final imageUrls = listing.images.map((img) => img.imageUrl).toList();
          
          // Status tag logic
          final statusTag = isSale ? 'LIKE NEW' : 'AVAILABLE NOW';

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
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedPickupLocation ?? 'Student Union, North Entrance',
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                                      onChanged: listing.allowPickupChange 
                                        ? (String? newValue) {
                                            setState(() {
                                              _selectedPickupLocation = newValue;
                                            });
                                          }
                                        : null,
                                      items: <String>[
                                        'Student Union, North Entrance',
                                        'Library, 1st Floor',
                                        'Dorm A Lobby',
                                        'Cafeteria'
                                      ].map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),
                      
                      // Seller Section
                      if (seller != null)
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
                      
                      // Primary Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showOrderSuccessDialog(context);
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
