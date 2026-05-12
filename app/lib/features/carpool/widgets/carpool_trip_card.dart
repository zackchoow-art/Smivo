import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/data/models/carpool_trip.dart';

class CarpoolTripCard extends StatelessWidget {
  const CarpoolTripCard({
    super.key,
    required this.trip,
    this.onTap,
  });

  final CarpoolTrip trip;
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
                        Text(
                          '$depDesc → $destDesc',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEE, MMM d · h:mm a').format(trip.departureTime.toLocal()),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.secondaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.directions_car,
                        size: 32,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${trip.availableSeats} seats available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (trip.estimatedTotalPrice != null)
                    Text(
                      '\$${(trip.estimatedTotalPrice! / (trip.totalSeats + 1)).toStringAsFixed(2)}/person',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
