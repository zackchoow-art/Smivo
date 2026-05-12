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

                    // Info Card
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.trip_origin,
                                      size: 16,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(trip.departureAddress,
                                        style: theme.textTheme.bodyLarge),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 7.0, top: 4, bottom: 4),
                                child: Container(
                                    width: 2,
                                    height: 16,
                                    color: theme.dividerColor),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16,
                                      color: theme.colorScheme.error),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(trip.destinationAddress,
                                        style: theme.textTheme.bodyLarge),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              _InfoRow(
                                icon: Icons.access_time,
                                label: 'Departure Time',
                                value: DateFormat('yyyy-MM-dd HH:mm')
                                    .format(trip.departureTime.toLocal()),
                              ),
                              if (trip.estimatedArrivalTime != null) ...[
                                const SizedBox(height: 8),
                                _InfoRow(
                                  icon: Icons.flag,
                                  label: 'Est. Arrival',
                                  value: DateFormat('HH:mm').format(
                                      trip.estimatedArrivalTime!.toLocal()),
                                ),
                              ],
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.event_seat,
                                label: 'Available Seats',
                                value:
                                    '${trip.availableSeats}/${trip.totalSeats} Seats',
                              ),
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
                              if (trip.note != null &&
                                  trip.note!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Notes:',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(trip.note!,
                                    style: theme.textTheme.bodyMedium),
                              ],
                            ],
                          ),
                        ),
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
                              enableTap: false,
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                      title: Text(
                          trip.creator?.displayName ?? 'Unknown'),
                      subtitle: Text(
                          trip.role == 'driver' ? 'Driver' : 'Organizer'),
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
                            .where((m) => m.status == 'approved')
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
