import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/features/carpool/providers/carpool_detail_provider.dart';
import 'package:smivo/features/carpool/screens/group_chat_screen.dart';
import 'package:smivo/features/carpool/widgets/calendar_sync_button.dart';
import 'package:smivo/features/carpool/providers/carpool_lifecycle_provider.dart';
import 'package:smivo/features/carpool/widgets/trip_timeline.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:smivo/core/maps/map_route_preview.dart';
import 'package:smivo/core/maps/map_service.dart';
import 'package:smivo/features/carpool/widgets/member_avatar_row.dart';
import 'package:smivo/features/carpool/screens/manage_trip_screen.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/shared/widgets/action_error_dialog.dart';
import 'package:smivo/shared/widgets/action_success_dialog.dart';
import 'package:smivo/shared/widgets/themed_confirm_dialog.dart';
import 'package:smivo/features/carpool/widgets/legal_disclaimer_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/features/carpool/services/calendar_sync_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smivo/data/repositories/carpool_repository.dart';
import 'package:smivo/features/carpool/widgets/review_batch_sheet.dart';
import 'package:smivo/data/models/carpool_member.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/core/router/app_routes.dart';

class CarpoolDetailScreen extends ConsumerWidget {
  const CarpoolDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUserId = ref.watch(supabaseClientProvider).auth.currentUser?.id;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Please login to view trip details',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: ElevatedButton(
                  onPressed: () => context.pushNamed(AppRoutes.login),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final detailAsync = ref.watch(carpoolDetailProvider(tripId));

    // Auto-update calendar if previously synced
    ref.listen(carpoolDetailProvider(tripId), (previous, next) async {
      final trip = next.value;
      if (trip != null && trip.status == 'active') {
        final syncService = ref.read(calendarSyncServiceProvider);
        if (await syncService.hasSyncedTrip(trip.id)) {
          try {
            await syncService.syncTrip(trip);
          } catch (e) {
            debugPrint('Auto-sync failed: $e');
          }
        }
      }
    });

    final currentProfile = ref.watch(profileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        actions: [
          detailAsync.maybeWhen(
            data: (trip) => trip != null
                ? IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      final box = context.findRenderObject() as RenderBox?;
                      SharePlus.instance.share(
                        ShareParams(
                          uri: Uri.parse('https://smivo.io/carpool/${trip.id}'),
                          sharePositionOrigin: box != null
                              ? box.localToGlobal(Offset.zero) & box.size
                              : null,
                        ),
                      );
                    },
                  )
                : const SizedBox(),
            orElse: () => const SizedBox(),
          ),
        ],
      ),
      body: detailAsync.when(
        data: (trip) {
          if (trip == null) {
            return const Center(child: Text('Trip not found'));
          }

          final isCreator = currentProfile?.id == trip.creatorId;
          final myMemberRecord = trip.members
              .where((m) => m.userId == currentProfile?.id)
              .firstOrNull;
          final isMember =
              myMemberRecord != null && myMemberRecord.status == 'approved';
          final isPending =
              myMemberRecord != null && myMemberRecord.status == 'pending';

          final now = DateTime.now();
          final isPastDeparture = trip.departureTime.isBefore(now);
          final canConfirmArrival = isPastDeparture && trip.status == 'confirmed' && (isCreator || isMember);
          
          final reviewsAsync = ref.watch(tripReviewsProvider(trip.id));
          final hasReviewed = reviewsAsync.value?.any(
                (r) => r.reviewerId == currentProfile?.id,
              ) ??
              false;
          // NOTE: isReviewEligible = status qualifies AND user is a participant.
          // canReview adds the !hasReviewed guard so the button hides after submission.
          final isReviewEligible =
              (trip.status == 'arrived' || trip.status == 'completed') &&
              (isCreator || isMember);
          final canReview = isReviewEligible && !hasReviewed;
          // NOTE: Counts creator + all non-cancelled approved members.
          // Used for final per-person cost in settled split-cost trips.
          final activeMemberCount = trip.members
              .where(
                (m) =>
                    m.cancelledAt == null &&
                    (m.status == 'approved' || m.role == 'creator'),
              )
              .length;

          final snapshot = myMemberRecord?.lastAcknowledgedSnapshot;

          String? getOld(String key, String currentVal, [String Function(dynamic)? fmt]) {
            if (snapshot == null || !snapshot.containsKey(key)) return null;
            final oldRaw = snapshot[key];
            if (oldRaw == null) return null;
            final oldStr = fmt != null ? fmt(oldRaw) : oldRaw.toString();
            return oldStr != currentVal ? oldStr : null;
          }

          String estArrivalStr = 'Pending';
          if (trip.estimatedArrivalTime != null) {
            estArrivalStr = DateFormat('yyyy-MM-dd HH:mm').format(trip.estimatedArrivalTime!.toLocal());
          } else if (trip.departureLat != null && trip.departureLng != null && trip.destinationLat != null && trip.destinationLng != null) {
            final route = estimateRoute(
              MapLocation(latitude: trip.departureLat!, longitude: trip.departureLng!),
              MapLocation(latitude: trip.destinationLat!, longitude: trip.destinationLng!),
            );
            final calculatedTime = trip.departureTime.add(Duration(minutes: route.durationMinutes));
            estArrivalStr = DateFormat('yyyy-MM-dd HH:mm').format(calculatedTime.toLocal());
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                        // Map Route Preview — uses MapLocation objects
                    if (trip.departureLat != null &&
                        trip.departureLng != null &&
                        trip.destinationLat != null &&
                        trip.destinationLng != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: MapRoutePreview(
                          departure: MapLocation(
                            latitude: trip.departureLat!,
                            longitude: trip.departureLng!,
                            name: trip.departureDescription,
                            address: trip.departureAddress,
                          ),
                          destination: MapLocation(
                            latitude: trip.destinationLat!,
                            longitude: trip.destinationLng!,
                            name: trip.destinationDescription,
                            address: trip.destinationAddress,
                          ),
                        ),
                      ),

                    // Route & Info Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card 1: Full Addresses Card
                          Card(
                            elevation: 0,
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Full Addresses',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant)),
                                  const SizedBox(height: 8),
                                  _InfoRow(icon: Icons.trip_origin, iconColor: theme.colorScheme.primary, label: 'From',
                                    value: trip.departureAddress, labelWidth: 45, oldValue: getOld('departure_address', trip.departureAddress)),
                                  const SizedBox(height: 4),
                                  _InfoRow(icon: Icons.location_on, iconColor: theme.colorScheme.error, label: 'To',
                                    value: trip.destinationAddress, labelWidth: 45, oldValue: getOld('destination_address', trip.destinationAddress)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Card 3: Trip Details
                          Card(
                            elevation: 0,
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoRow(
                                    icon: Icons.access_time,
                                    label: 'Departure Time',
                                    value: DateFormat('yyyy-MM-dd HH:mm').format(trip.departureTime.toLocal()),
                                    oldValue: getOld('departure_time', DateFormat('yyyy-MM-dd HH:mm').format(trip.departureTime.toLocal()),
                                        (v) => DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(v as String).toLocal())),
                                    labelWidth: 130,
                                  ),
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.flag,
                                    label: 'Est. Arrival',
                                    value: estArrivalStr,
                                    labelWidth: 130,
                                  ),
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.groups,
                                    label: 'Total Seats',
                                    value: '${trip.totalSeats}',
                                    oldValue: getOld('total_seats', '${trip.totalSeats}', (v) => '$v'),
                                    labelWidth: 130,
                                  ),
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.event_seat,
                                    label: 'Available Seats',
                                    value: '${trip.availableSeats}',
                                    labelWidth: 130,
                                  ),
                                  // --- Driver: fixed per-person price ---
                                  if (trip.role == 'driver' &&
                                      trip.estimatedTotalPrice != null) ...[
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      icon: Icons.attach_money,
                                      label: 'Fixed Price',
                                      value:
                                          '\$${trip.estimatedTotalPrice!.toStringAsFixed(2)}/person',
                                      oldValue: getOld(
                                        'estimated_total_price',
                                        '\$${trip.estimatedTotalPrice!.toStringAsFixed(2)}/person',
                                        (v) =>
                                            '\$${(v as num).toStringAsFixed(2)}/person',
                                      ),
                                      labelWidth: 130,
                                    ),
                                  ],
                                  // --- Organizer: estimated total + per-person ---
                                  if (trip.role != 'driver' &&
                                      trip.estimatedTotalPrice != null) ...[
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      icon: Icons.attach_money,
                                      label: 'Est. Total',
                                      value:
                                          '\$${trip.estimatedTotalPrice!.toStringAsFixed(2)}',
                                      oldValue: getOld(
                                        'estimated_total_price',
                                        '\$${trip.estimatedTotalPrice!.toStringAsFixed(2)}',
                                        (v) =>
                                            '\$${(v as num).toStringAsFixed(2)}',
                                      ),
                                      labelWidth: 130,
                                    ),
                                    const SizedBox(height: 4),
                                    _InfoRow(
                                      icon: Icons.people,
                                      label: 'Est. Per Person',
                                      // NOTE: totalSeats = passenger seats only;
                                      // +1 includes the organizer in the split.
                                      value:
                                          '~\$${(trip.estimatedTotalPrice! / (trip.totalSeats + 1)).toStringAsFixed(2)}',
                                      labelWidth: 130,
                                    ),
                                  ],
                                  // --- Organizer settled: actual final cost ---
                                  if (trip.role != 'driver' &&
                                      trip.actualTotalCost != null &&
                                      activeMemberCount > 0) ...[
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      icon: Icons.check_circle_outline,
                                      label: 'Final Total',
                                      value:
                                          '\$${trip.actualTotalCost!.toStringAsFixed(2)}',
                                      labelWidth: 130,
                                    ),
                                    const SizedBox(height: 4),
                                    _InfoRow(
                                      icon: Icons.person,
                                      label: 'Final Per Person',
                                      // NOTE: activeMemberCount = creator + non-cancelled
                                      // approved members (the real headcount at settlement).
                                      value:
                                          '\$${(trip.actualTotalCost! / activeMemberCount).toStringAsFixed(2)} ($activeMemberCount people)',
                                      labelWidth: 130,
                                    ),
                                  ],
                                  if (trip.luggageLimit != null) ...[
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      icon: Icons.luggage,
                                      label: 'Luggage Limit',
                                      value: trip.luggageLimit!,
                                      oldValue: getOld('luggage_limit', trip.luggageLimit!),
                                      labelWidth: 130,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.verified_user,
                                    label: 'Approval Mode',
                                    value: trip.approvalMode == 'auto'
                                        ? 'Auto-approve'
                                        : 'Manual approval',
                                    labelWidth: 130,
                                  ),
                                  if (trip.note != null && trip.note!.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.notes, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Notes:',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 24.0),
                                      child: Text(
                                        trip.note!,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Creator Card
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Organizer',
                          style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ),
                    ListTile(
                      leading: trip.creator != null
                          ? SmivoUserAvatar(
                              user: trip.creator!,
                              radius: 24,
                              enableTap: true,
                            )
                          : const CircleAvatar(
                              radius: 24,
                              child: Icon(Icons.person),
                            ),
                      title: Text(trip.creator?.displayName ?? 'Unknown'),
                      subtitle: Text(trip.role == 'driver' ? 'Driver' : 'Organizer'),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        tooltip: 'Message Organizer',
                        onPressed: (!isCreator && (isMember || isPending))
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GroupChatScreen(tripId: trip.id),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),

                    // Members Row
                    const SizedBox(height: 16),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Joined Members',
                          style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      child: MemberAvatarRow(
                        members: trip.members
                            .where((m) => m.status == 'approved' && m.userId != trip.creatorId)
                            .toList(),
                        totalSeats: trip.totalSeats,
                      ),
                    ),

                    // Trip Timeline — shows lifecycle events dynamically
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TripTimeline(trip: trip),
                    ),

                    // Cost Settlement — shows after trip arrives (only for organizers, hidden for fixed-price drivers)
                    if ((trip.status == 'arrived' || trip.status == 'completed') && trip.role == 'organizer')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CostSettlementCard(
                          trip: trip,
                          isCreator: isCreator,
                          activeMemberCount: trip.members
                              .where((m) =>
                                  m.cancelledAt == null &&
                                  (m.status == 'approved' || m.role == 'creator'))
                              .length,
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color:
                          theme.shadowColor.withValues(alpha: 0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: SafeArea(
                  minimum: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (trip.status == 'cancelled' || trip.status == 'completed') ...[
                        Center(
                          child: Text(
                            'This trip was ${trip.status} on ${DateFormat('yyyy-MM-dd').format(trip.updatedAt.toLocal())}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: trip.status == 'cancelled' ? theme.colorScheme.error : theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (canReview) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final membersToReview =
                                    List<CarpoolMember>.from(trip.members);
                                if (trip.creator != null) {
                                  membersToReview.add(CarpoolMember(
                                    id: 'creator',
                                    tripId: trip.id,
                                    userId: trip.creatorId,
                                    role: 'creator',
                                    status: 'approved',
                                    createdAt: DateTime.now(),
                                    user: trip.creator,
                                  ));
                                }
                                // Ensure current user is filtered out
                                final filteredMembers = membersToReview
                                    .where((m) => m.userId != currentProfile!.id)
                                    .toList();
                                final result =
                                    await showModalBottomSheet<bool>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (ctx) => ReviewBatchSheet(
                                    tripId: trip.id,
                                    members: filteredMembers,
                                  ),
                                );

                                if (result == true) {
                                  if (!context.mounted) return;
                                  context.pop();
                                  if (!context.mounted) return;
                                  // NOTE: Show success after pop so dialog
                                  // appears on the previous screen's context.
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => const ActionSuccessDialog(
                                      title: 'Thank You!',
                                      message: 'Your trip ratings have been submitted.',
                                    ),
                                  );
                                }
                              },
                              child: const Text('Rate your Trip'),
                            ),
                          ),
                        ] else if (isReviewEligible) ...[
                          const SizedBox(height: 16),
                          // Show confirmation that user has already rated
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "You've already rated this trip",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ] else ...[
                        if (canConfirmArrival) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await ref.read(carpoolRepositoryProvider).markArrived(tripId);
                                  ref.invalidate(carpoolDetailProvider(tripId));
                                } catch (e) {
                                  if (!context.mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => ActionErrorDialog(
                                      title: 'Error',
                                      message: e.toString(),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Confirm Arrival'),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (canReview) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final membersToReview =
                                    List<CarpoolMember>.from(trip.members);
                                if (trip.creator != null) {
                                  membersToReview.add(CarpoolMember(
                                    id: 'creator',
                                    tripId: trip.id,
                                    userId: trip.creatorId,
                                    role: 'creator',
                                    status: 'approved',
                                    createdAt: DateTime.now(),
                                    user: trip.creator,
                                  ));
                                }
                                // Ensure current user is filtered out
                                final filteredMembers = membersToReview
                                    .where((m) => m.userId != currentProfile!.id)
                                    .toList();
                                final result =
                                    await showModalBottomSheet<bool>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (ctx) => ReviewBatchSheet(
                                    tripId: trip.id,
                                    members: filteredMembers,
                                  ),
                                );

                                if (result == true) {
                                  if (!context.mounted) return;
                                  context.pop();
                                  if (!context.mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => const ActionSuccessDialog(
                                      title: 'Thank You!',
                                      message: 'Your trip ratings have been submitted.',
                                    ),
                                  );
                                }
                              },
                              child: const Text('Rate your Trip'),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ] else if (isReviewEligible) ...[
                          // Show confirmation that user has already rated
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "You've already rated this trip",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (isCreator) ...[
                          Row(
                            children: [
                              if (trip.status == 'active' || trip.status == 'inactive') ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    try {
                                      await ref.read(carpoolDetailProvider(tripId).notifier).cancelTrip();
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => ActionErrorDialog(
                                          title: 'Cannot Cancel',
                                          message: e.toString().contains('TRIP_LOCKED')
                                              ? 'Cannot cancel this trip as it has already been confirmed.'
                                              : e.toString(),
                                        ),
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        theme.colorScheme.error,
                                  ),
                                  child: const Text('Cancel Trip'),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                              if (trip.status == 'active' || trip.status == 'inactive') ...[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ManageTripScreen(
                                            tripId: trip.id,
                                            creatorId: trip.creatorId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Manage Trip'),
                                  ),
                                ),
                              ],
                            ],
                        ),
                      ] else if (isMember) ...[
                        if (snapshot != null) ...[
                          Row(
                            children: [
                              if (trip.status == 'active' || trip.status == 'inactive') ...[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => const ThemedConfirmDialog(
                                          title: 'Cancel Request?',
                                          message: 'Are you sure you want to cancel your request? You will not be able to rejoin unless the organizer updates the trip details.',
                                          confirmText: 'Yes, Cancel',
                                          cancelText: 'Wait',
                                          isDestructive: true,
                                        ),
                                      );
                                      if (confirmed != true) return;

                                      try {
                                        await ref.read(carpoolDetailProvider(tripId).notifier).leaveTrip();
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => ActionErrorDialog(
                                            title: 'Cannot Cancel',
                                            message: e.toString().contains('TRIP_LOCKED')
                                                ? 'Cannot leave this trip as it has already been confirmed.'
                                                : e.toString(),
                                          ),
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                                    child: const Text('Cancel Request'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await ref.read(carpoolRepositoryProvider).acceptTripChanges(tripId);
                                      ref.invalidate(carpoolDetailProvider(tripId));
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => ActionErrorDialog(
                                          title: 'Failed',
                                          message: e.toString(),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Accept Changes'),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          if (trip.status == 'active' || trip.status == 'inactive')
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => const ThemedConfirmDialog(
                                      title: 'Leave Trip?',
                                      message: 'Are you sure you want to leave this trip? You will not be able to rejoin unless the organizer updates the trip details.',
                                      confirmText: 'Yes, Leave',
                                      cancelText: 'Wait',
                                      isDestructive: true,
                                    ),
                                  );
                                  if (confirmed != true) return;

                                  try {
                                    await ref.read(carpoolDetailProvider(tripId).notifier).leaveTrip();
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => ActionErrorDialog(
                                        title: 'Cannot Leave',
                                        message: e.toString().contains('TRIP_LOCKED')
                                            ? 'Cannot leave this trip as it has already been confirmed.'
                                            : e.toString(),
                                      ),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                ),
                                child: const Text('Leave Trip'),
                              ),
                            ),
                        ],
                      ] else if (isPending) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: null,
                            child:
                                const Text('Application submitted, pending approval'),
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb, size: 16, color: Colors.amber.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  trip.role == 'driver'
                                      ? 'Fixed Price: You will pay exactly the fixed amount shown upon completion.'
                                      : 'Split Cost: Price shown is an estimate and may change based on final total expenses and headcount.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: trip.availableSeats > 0 &&
                                    trip.status == 'active'
                                ? () async {
                                    // Show Disclaimer before joining
                                    final agreed = await LegalDisclaimerDialog.show(context);
                                    if (agreed != true) return;

                                    try {
                                      await ref
                                          .read(
                                              carpoolDetailProvider(tripId)
                                                  .notifier)
                                          .requestJoin();
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      if (e.toString().contains('NO_SEATS')) {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => const ActionErrorDialog(
                                            title: 'Trip Full',
                                            message: 'This trip is now full. Refreshing...',
                                          ),
                                        );
                                        // Refresh to show updated seat count
                                        ref.invalidate(carpoolDetailProvider(tripId));
                                      } else if (e.toString().contains('TRIP_CANCELLED')) {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => const ActionErrorDialog(
                                            title: 'Trip Cancelled',
                                            message: 'This trip has been cancelled by the organizer.',
                                          ),
                                        );
                                        ref.invalidate(carpoolDetailProvider(tripId));
                                      } else {
                                        // Extract clean message if it's an AppException
                                        final errorMsg = e is AppException ? e.message : e.toString();
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => ActionErrorDialog(
                                            title: 'Cannot Join Trip',
                                            message: errorMsg,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null,
                            child: Text(trip.availableSeats > 0
                                ? 'Request to Join'
                                : 'Full'),
                          ),
                        ),
                      ],
                    ],
                      // Real CalendarSyncButton with 1-hour reminder (hidden for past trips)
                      if ((trip.status == 'active' || trip.status == 'inactive' || trip.status == 'confirmed') && (isCreator || isMember)) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: CalendarSyncButton(trip: trip),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Failed to load: $error')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.labelWidth,
    this.iconColor,
    this.oldValue,
  });

  final IconData icon;
  final String label;
  final String value;
  final double? labelWidth;
  final Color? iconColor;
  final String? oldValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        SizedBox(
          width: labelWidth,
          child: Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (oldValue != null) ...[
                Text(
                  oldValue!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: oldValue != null ? theme.colorScheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
