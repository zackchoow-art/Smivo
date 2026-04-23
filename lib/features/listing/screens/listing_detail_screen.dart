import 'package:flutter/material.dart';
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

String _conditionLabel(String condition) {
  switch (condition) {
    case 'new': return 'NEW';
    case 'like_new': return 'LIKE NEW';
    case 'good': return 'GOOD';
    case 'fair': return 'FAIR';
    case 'poor': return 'POOR';
    default: return condition.toUpperCase();
  }
}

class ListingDetailScreen extends ConsumerStatefulWidget {
  const ListingDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  String? _selectedPickupLocationId;

  Future<void> _showOrderSuccessDialog(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.xl)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle, color: colors.success, size: 64),
          const SizedBox(height: 12),
          Text('Order Submitted', style: typo.headlineSmall),
          const SizedBox(height: 4),
          Text('Waiting for seller approval.', style: typo.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.md)),
            ),
            child: Text('OK', style: TextStyle(color: colors.onPrimary)),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.id));
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.background,
      body: listingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(padding: const EdgeInsets.all(24),
            child: Text('Error loading listing: $err', style: typo.bodyMedium.copyWith(color: colors.error), textAlign: TextAlign.center)),
        ),
        data: (listing) {
          final isSale = listing.transactionType.toLowerCase() == 'sale';
          final seller = listing.seller;
          final currentUserId = ref.watch(authStateProvider).valueOrNull?.id;
          final isOwnListing = currentUserId != null && currentUserId == listing.sellerId;
          final existingOrder = ref.watch(existingBuyerOrderProvider(listing.id));
          final imageUrls = listing.images.map((img) => img.imageUrl).toList();
          // NOTE: Show real condition for sale items, availability for rentals
          final statusTag = isSale ? _conditionLabel(listing.condition) : 'AVAILABLE NOW';

          return Stack(children: [
            SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListingImageCarousel(imageUrls: imageUrls, tagText: statusTag, isSale: isSale),
              Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(listing.title, style: typo.displayLarge.copyWith(fontSize: 32, letterSpacing: -1, height: 1.1)),
                if (isSale) ...[
                  const SizedBox(height: 8),
                  Text('\$${listing.price.toStringAsFixed(0)}', style: typo.headlineLarge.copyWith(color: colors.priceAccent, fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 24),
                Text('DESCRIPTION', style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(listing.description ?? 'No description provided.', style: typo.bodyLarge),
                const SizedBox(height: 24),
                if (!isSale) ...[RentalOptionsSection(listing: listing), const SizedBox(height: 24)],
                // Pickup Location Selector
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.location_on_outlined, color: colors.priceAccent),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('PICKUP LOCATION', style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),
                      if (listing.allowPickupChange) GestureDetector(
                        onTap: () {},
                        child: Text('Change Location', style: typo.labelSmall.copyWith(color: colors.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.sm)),
                      child: !listing.allowPickupChange
                        ? Container(alignment: Alignment.centerLeft, height: 48,
                            child: Text(listing.pickupLocation?.name ?? 'Not specified', style: typo.titleMedium.copyWith(color: colors.onSurface)))
                        : DropdownButtonHideUnderline(child: Consumer(builder: (context, ref, _) {
                            final pickupsAsync = ref.watch(myPickupLocationsProvider);
                            return pickupsAsync.when(
                              loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
                              error: (err, _) => Container(alignment: Alignment.centerLeft, height: 48,
                                child: Text(listing.pickupLocation?.name ?? 'Unable to load', style: typo.bodyMedium)),
                              data: (locations) {
                                final selectedId = _selectedPickupLocationId ?? listing.pickupLocationId;
                                return DropdownButton<String>(
                                  value: selectedId, isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down, color: colors.primary),
                                  style: typo.titleMedium.copyWith(color: colors.onSurface),
                                  onChanged: (String? newId) => setState(() => _selectedPickupLocationId = newId),
                                  items: locations.map((loc) => DropdownMenuItem<String>(value: loc.id, child: Text(loc.name))).toList(),
                                );
                              },
                            );
                          })),
                    ),
                  ])),
                ]),
                const SizedBox(height: 24),
                // Seller Section — hidden on own listing
                if (seller != null && !isOwnListing) SellerProfileCard(
                  name: seller.displayName ?? 'Anonymous Student',
                  avatarUrl: seller.avatarUrl ?? 'https://i.pravatar.cc/150?u=${seller.id}',
                  rating: '4.9', reviewCount: 12,
                  label: isSale ? 'SELLER' : 'LISTED BY',
                  onMessageTap: () async {
                    final user = ref.read(authStateProvider).valueOrNull;
                    if (user == null) { context.pushNamed(AppRoutes.login); return; }
                    if (user.id == listing.sellerId) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This is your own listing'))); return;
                    }
                    try {
                      final chatRoom = await ref.read(chatRepositoryProvider).getOrCreateChatRoom(
                        listingId: listing.id, buyerId: user.id, sellerId: listing.sellerId);
                      if (!context.mounted) return;
                      showChatPopup(context, chatRoomId: chatRoom.id, otherUserName: listing.seller?.displayName ?? 'Seller',
                        otherUserAvatar: listing.seller?.avatarUrl, listingTitle: listing.title,
                        listingPrice: listing.price, listingImageUrl: listing.images.firstOrNull?.imageUrl);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Stats Section — only visible on own listing
                if (isOwnListing) ...[
                  Text('LISTING STATS', style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _StatCard(icon: Icons.visibility_outlined, label: 'Views', count: listing.viewCount),
                    const SizedBox(width: 12),
                    _StatCard(icon: Icons.bookmark_outline, label: 'Saves', count: listing.saveCount),
                    const SizedBox(width: 12),
                    _StatCard(icon: Icons.chat_bubble_outline, label: 'Inquiries', count: listing.inquiryCount),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(
                    onPressed: () => context.pushNamed(AppRoutes.transactionManagement, pathParameters: {'id': listing.id}),
                    icon: const Icon(Icons.manage_search), label: const Text('Manage Transactions'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.sm)),
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
                // Primary Action Button — hidden on own listing
                if (!isOwnListing) existingOrder.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (order) {
                    if (order != null) {
                      final submittedDate = DateFormat('MMM d, yyyy · h:mm a').format(order.createdAt.toLocal());
                      return Container(
                        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.sm)),
                        child: Column(children: [
                          Icon(Icons.check_circle, color: colors.success, size: 28),
                          const SizedBox(height: 4),
                          Text('Application Submitted', style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(submittedDate, style: typo.bodySmall.copyWith(color: colors.outlineVariant)),
                        ]),
                      );
                    }
                    return SizedBox(width: double.infinity, child: ElevatedButton(
                      onPressed: () async {
                        final user = ref.read(authStateProvider).valueOrNull;
                        if (user == null) { context.pushNamed(AppRoutes.login); return; }
                        if (user.emailConfirmedAt == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please verify your email first'))); return;
                        }
                        if (user.id == listing.sellerId) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You cannot buy your own listing'))); return;
                        }
                        final isRental = listing.transactionType.toLowerCase() == 'rental';
                        double orderPrice;
                        DateTime? rentalStart, rentalEnd;
                        if (isRental) {
                          final selectedRate = ref.read(selectedRentalRateProvider);
                          final startDate = ref.read(rentalStartDateProvider);
                          if (selectedRate == 'DAY') {
                            final endDate = ref.read(rentalEndDateProvider);
                            final days = endDate.difference(startDate).inDays;
                            orderPrice = (listing.rentalDailyPrice ?? 0) * (days > 0 ? days : 1);
                            rentalStart = startDate; rentalEnd = endDate;
                          } else if (selectedRate == 'WEEK') {
                            final duration = ref.read(rentalDurationProvider);
                            orderPrice = (listing.rentalWeeklyPrice ?? 0) * duration;
                            rentalStart = startDate; rentalEnd = startDate.add(Duration(days: 7 * duration));
                          } else {
                            final duration = ref.read(rentalDurationProvider);
                            orderPrice = (listing.rentalMonthlyPrice ?? 0) * duration;
                            rentalStart = startDate;
                            rentalEnd = DateTime(startDate.year, startDate.month + duration, startDate.day);
                          }
                          if (orderPrice <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid rental configuration. Please select a valid rate and period.'))); return;
                          }
                        } else {
                          orderPrice = listing.price;
                        }
                        try {
                          final effectivePickupId = _selectedPickupLocationId ?? listing.pickupLocationId;
                          await ref.read(orderActionsProvider.notifier).createOrder(
                            listingId: listing.id, sellerId: listing.sellerId, price: orderPrice,
                            orderType: isRental ? 'rental' : 'sale', rentalStartDate: rentalStart, rentalEndDate: rentalEnd,
                            depositAmount: listing.depositAmount, pickupLocationId: effectivePickupId);
                          if (!context.mounted) return;
                          await _showOrderSuccessDialog(context);
                          if (!context.mounted) return;
                          context.goNamed(AppRoutes.orders);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to place order: ${e.toString()}'), backgroundColor: colors.error));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary, padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.sm)), elevation: 0),
                      child: Text(isSale ? 'Place Order' : 'Request to Rent', style: typo.titleMedium.copyWith(color: colors.onPrimary)),
                    ));
                  },
                ),
                const SizedBox(height: 100),
              ])),
            ])),
            // Fixed floating back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8, left: 12,
              child: Container(
                decoration: BoxDecoration(color: colors.surfaceContainerLowest.withValues(alpha: 0.9), shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))]),
                child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.of(context).pop()),
              ),
            ),
            // Floating save button — hidden for own listings
            if (!isOwnListing) Positioned(
              top: MediaQuery.of(context).padding.top + 8, right: 12,
              child: Consumer(builder: (context, ref, _) {
                final isSavedAsync = ref.watch(isListingSavedProvider(listing.id));
                final isSaved = isSavedAsync.valueOrNull ?? false;
                return Container(
                  decoration: BoxDecoration(color: colors.surfaceContainerLowest.withValues(alpha: 0.9), shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 2))]),
                  child: IconButton(
                    icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: isSaved ? colors.primary : colors.onSurface),
                    onPressed: () {
                      final user = ref.read(authStateProvider).valueOrNull;
                      if (user == null) { context.pushNamed(AppRoutes.login); return; }
                      ref.read(savedListingActionsProvider.notifier).toggleSave(listing.id);
                    },
                  ),
                );
              }),
            ),
          ]);
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.count});
  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.md)),
      child: Column(children: [
        Icon(icon, color: colors.primary, size: 24),
        const SizedBox(height: 4),
        Text(count.toString(), style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: typo.bodySmall.copyWith(color: colors.outlineVariant)),
      ]),
    ));
  }
}
