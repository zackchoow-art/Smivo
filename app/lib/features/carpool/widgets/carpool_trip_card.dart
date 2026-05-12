import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';

class CarpoolTripCard extends StatelessWidget {
  const CarpoolTripCard({
    super.key,
    required this.trip,
    this.onTap,
  });

  final CarpoolTrip trip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDriver = trip.role == 'driver';

    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RouteLine(
                          from: trip.departureAddress,
                          to: trip.destinationAddress,
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('MM-dd HH:mm')
                                  .format(trip.departureTime.toLocal()),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDriver
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isDriver ? '司机' : '拼车',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDriver
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: theme.dividerColor),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (trip.creator != null)
                        SmivoUserAvatar(
                          user: trip.creator!,
                          radius: 14,
                          enableTap: false,
                        )
                      else
                        CircleAvatar(
                          radius: 14,
                          child: Icon(Icons.person, size: 14),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        trip.creator?.displayName ?? 'Unknown',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.event_seat,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.availableSeats}/${trip.totalSeats} 座位',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({
    required this.from,
    required this.to,
    required this.theme,
  });

  final String from;
  final String to;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Icon(Icons.trip_origin, size: 12, color: theme.colorScheme.primary),
            Container(width: 2, height: 12, color: theme.dividerColor),
            Icon(Icons.location_on, size: 12, color: theme.colorScheme.error),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                from,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Text(
                to,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
