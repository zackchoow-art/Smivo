import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';

class CarpoolTripCard extends StatelessWidget {
  const CarpoolTripCard({
    super.key,
    required this.trip,
    this.currentUserId,
    this.onTap,
  });

  final CarpoolTrip trip;
  final String? currentUserId;
  final VoidCallback? onTap;

  String _getShortDesc(String? desc, String address) {
    if (desc != null && desc.isNotEmpty) return desc;
    if (address.length > 20) return '${address.substring(0, 20)}...';
    return address;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final depDesc = _getShortDesc(trip.departureDescription, trip.departureAddress);
    final destDesc = _getShortDesc(trip.destinationDescription, trip.destinationAddress);
    final isDriver = trip.role == 'driver';
    
    String? displayStatus;
    Color? statusColor;
    
    if (trip.status == 'cancelled') {
      displayStatus = 'Cancelled by Organizer';
      statusColor = theme.colorScheme.error;
    } else if (trip.status == 'departed') {
      displayStatus = 'Departed';
      statusColor = theme.colorScheme.onSurfaceVariant;
    } else if (trip.status == 'completed') {
      displayStatus = 'Completed';
      statusColor = theme.colorScheme.onSurfaceVariant;
    } else if (currentUserId != null && currentUserId != trip.creatorId) {
      try {
        final member = trip.members.firstWhere((m) => m.userId == currentUserId);
        if (member.status == 'cancelled') {
          displayStatus = 'You Cancelled';
          statusColor = theme.colorScheme.error;
        } else if (member.status == 'rejected') {
          displayStatus = 'Request Rejected';
          statusColor = theme.colorScheme.error;
        } else if (member.status == 'pending') {
          displayStatus = 'Pending Approval';
          statusColor = Colors.orange;
        }
      } catch (_) {}
    }

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
                    child: _RouteLine(
                      from: depDesc,
                      to: destDesc,
                      theme: theme,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: displayStatus != null 
                          ? statusColor!.withValues(alpha: 0.1) 
                          : (isDriver ? theme.colorScheme.primaryContainer : theme.colorScheme.tertiaryContainer),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayStatus ?? (isDriver ? 'Fixed Price' : 'Split Cost'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: displayStatus != null 
                            ? statusColor 
                            : (isDriver ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onTertiaryContainer),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MM-dd HH:mm').format(trip.departureTime.toLocal()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (trip.estimatedTotalPrice != null)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: isDriver
                                ? '\$${trip.estimatedTotalPrice!.toStringAsFixed(2)}/'
                                : '~\$${(trip.estimatedTotalPrice! / (trip.totalSeats + 1)).toStringAsFixed(2)}/',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: 'seat',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
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
                        const CircleAvatar(
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(trip.totalSeats, (index) {
                      final taken = trip.totalSeats - trip.availableSeats;
                      final isAvailable = index >= taken;
                      return Padding(
                        padding: EdgeInsets.only(left: index == 0 ? 0 : 4.0),
                        child: Icon(
                          isAvailable ? Icons.event_seat_outlined : Icons.event_seat,
                          size: 20,
                          color: isAvailable
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                      );
                    }),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 4),
            Icon(Icons.trip_origin, size: 12, color: theme.colorScheme.primary),
            Container(width: 2, height: 16, color: theme.dividerColor),
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
              const SizedBox(height: 8),
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
