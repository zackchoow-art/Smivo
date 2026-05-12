import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/features/carpool/providers/carpool_detail_provider.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:smivo/core/maps/map_route_preview.dart';
import 'package:smivo/core/maps/map_service.dart';
import 'package:smivo/features/carpool/widgets/member_avatar_row.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';

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
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
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
                            address: trip.departureAddress,
                          ),
                          destination: MapLocation(
                            latitude: trip.destinationLat!,
                            longitude: trip.destinationLng!,
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
                          // Card 1: Description Card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.trip_origin, color: theme.colorScheme.primary),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          trip.departureDescription ?? trip.departureAddress,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 11),
                                    child: Container(
                                      width: 2, height: 24,
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: theme.colorScheme.error),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          trip.destinationDescription ?? trip.destinationAddress,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Card 2: Full Address Card
                          Card(
                            color: theme.colorScheme.surfaceContainerLow,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Full Addresses',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant)),
                                  const SizedBox(height: 8),
                                  _InfoRow(icon: Icons.trip_origin, label: 'From',
                                    value: trip.departureAddress),
                                  const SizedBox(height: 4),
                                  _InfoRow(icon: Icons.location_on, label: 'To',
                                    value: trip.destinationAddress),
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
                                  ),
                                  if (trip.estimatedArrivalTime != null) ...[
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      icon: Icons.flag,
                                      label: 'Est. Arrival',
                                      value: DateFormat('yyyy-MM-dd HH:mm').format(trip.estimatedArrivalTime!.toLocal()),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.event_seat,
                                    label: 'Available Seats',
                                    value: '${trip.availableSeats}',
                                  ),
                                  if (trip.estimatedTotalPrice != null) ...[
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      icon: Icons.attach_money,
                                      label: 'Estimated Total',
                                      value: '\$${trip.estimatedTotalPrice!.toStringAsFixed(2)}',
                                    ),
                                    const SizedBox(height: 4),
                                    _InfoRow(
                                      icon: Icons.people,
                                      label: 'Est. Per Person',
                                      value: '\$${(trip.estimatedTotalPrice! / (trip.totalSeats + 1)).toStringAsFixed(2)}',
                                    ),
                                  ],
                                  if (trip.luggageLimit != null) ...[
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      icon: Icons.luggage,
                                      label: 'Luggage Limit',
                                      value: trip.luggageLimit!,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.verified_user,
                                    label: 'Approval Mode',
                                    value: trip.approvalMode == 'auto'
                                        ? 'Auto-approve'
                                        : 'Manual approval',
                                  ),
                                  if (trip.note != null && trip.note!.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      'Notes:',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(trip.note!, style: theme.textTheme.bodyMedium),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Creator Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Organizer',
                          style: theme.textTheme.titleMedium),
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
                        tooltip: 'Group Chat',
                        onPressed: () {
                          // TODO: Navigate to group chat for this trip
                        },
                      ),
                    ),

                    // Members Row
                    const SizedBox(height: 16),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Joined Members',
                          style: theme.textTheme.titleMedium),
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
                                  // TODO: Navigate to members management
                                },
                                child: const Text('Manage Members'),
                              ),
                            ),
                          ],
                        ),
                      ] else if (isMember) ...[
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
                          child: Text(
                            'Price shown is an estimate and may change based on final headcount.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: trip.availableSeats > 0 &&
                                    trip.status == 'active'
                                ? () {
                                    ref
                                        .read(
                                            carpoolDetailProvider(tripId)
                                                .notifier)
                                        .requestJoin();
                                  }
                                : null,
                            child: Text(trip.availableSeats > 0
                                ? 'Request to Join'
                                : 'Full'),
                          ),
                        ),
                      ],
                      // Placeholder for CalendarSyncButton (Phase 8)
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_month, size: 18),
                        label: const Text('Add to Calendar'),
                      ),
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
