import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/features/carpool/providers/carpool_detail_provider.dart';
import 'package:smivo/features/carpool/screens/group_chat_screen.dart';
import 'package:smivo/features/carpool/widgets/calendar_sync_button.dart';
import 'package:smivo/features/carpool/widgets/trip_timeline.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:smivo/core/maps/map_route_preview.dart';
import 'package:smivo/core/maps/map_service.dart';
import 'package:smivo/features/carpool/widgets/member_avatar_row.dart';
import 'package:smivo/features/carpool/screens/manage_trip_screen.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/shared/widgets/action_error_dialog.dart';
import 'package:smivo/features/carpool/widgets/legal_disclaimer_dialog.dart';
import 'package:share_plus/share_plus.dart';

class CarpoolDetailScreen extends ConsumerWidget {
  const CarpoolDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(carpoolDetailProvider(tripId));
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
                      Share.shareUri(
                        Uri.parse('https://smivo.io/carpool/${trip.id}'),
                        sharePositionOrigin: box != null
                            ? box.localToGlobal(Offset.zero) & box.size
                            : null,
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
                            address: trip.departureDescription ?? trip.departureAddress,
                          ),
                          destination: MapLocation(
                            latitude: trip.destinationLat!,
                            longitude: trip.destinationLng!,
                            address: trip.destinationDescription ?? trip.destinationAddress,
                          ),
                        ),
                      ),

                    // Route & Info Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card 1: Full Address Card
                          Card(
                            color: theme.colorScheme.surfaceContainerLow,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Full Addresses',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant)),
                                  const SizedBox(height: 8),
                                  _InfoRow(icon: Icons.trip_origin, iconColor: Colors.green.shade600, label: 'From',
                                    value: trip.departureAddress, labelWidth: 45, oldValue: getOld('departure_address', trip.departureAddress)),
                                  const SizedBox(height: 4),
                                  _InfoRow(icon: Icons.location_on, iconColor: Colors.red.shade600, label: 'To',
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
                                    icon: Icons.event_seat,
                                    label: 'Available Seats',
                                    value: '${trip.availableSeats}',
                                    labelWidth: 130,
                                  ),
                                  if (trip.estimatedTotalPrice != null) ...[
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      icon: Icons.attach_money,
                                      label: 'Estimated Total',
                                      value: '\$${trip.estimatedTotalPrice!.toStringAsFixed(2)}',
                                      oldValue: getOld('estimated_total_price', '\$${trip.estimatedTotalPrice!.toStringAsFixed(2)}',
                                          (v) => '\$${(v as num).toStringAsFixed(2)}'),
                                      labelWidth: 130,
                                    ),
                                    const SizedBox(height: 4),
                                    _InfoRow(
                                      icon: Icons.people,
                                      label: 'Est. Per Person',
                                      value: '\$${(trip.estimatedTotalPrice! / (trip.totalSeats + 1)).toStringAsFixed(2)}',
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

                    // Cost Settlement — shows after trip arrives
                    if (['arrived', 'completed'].contains(trip.status))
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
                padding: const EdgeInsets.all(16),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCreator) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(carpoolDetailProvider(tripId)
                                          .notifier)
                                      .cancelTrip();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      theme.colorScheme.error,
                                ),
                                child: const Text('Cancel Trip'),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                        ),
                      ] else if (isMember) ...[
                        if (snapshot != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    ref.read(carpoolDetailProvider(tripId).notifier).leaveTrip();
                                  },
                                  style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                                  child: const Text('Cancel Request'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await ref.read(carpoolRepositoryProvider).acceptTripChanges(tripId);
                                      ref.invalidate(carpoolDetailProvider(tripId));
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                                    }
                                  },
                                  child: const Text('Accept Changes'),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                ref
                                    .read(carpoolDetailProvider(tripId)
                                        .notifier)
                                    .leaveTrip();
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
                                  'Price shown is an estimate and may change based on final headcount.',
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
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'This trip is now full. Refreshing...',
                                            ),
                                          ),
                                        );
                                        // Refresh to show updated seat count
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
                      // Real CalendarSyncButton with 1-hour reminder
                      if (isCreator || isMember) ...[
                        const SizedBox(height: 8),
                        CalendarSyncButton(trip: trip),
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
        Icon(icon, size: 16, color: iconColor ?? theme.colorScheme.onSurfaceVariant),
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
                  color: oldValue != null ? Colors.green.shade600 : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
