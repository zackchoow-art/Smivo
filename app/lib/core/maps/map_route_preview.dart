import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

import 'package:smivo/core/maps/map_service.dart';

/// Widget that displays a route preview between two locations.
///
/// On iOS: Shows a card with departure/destination, distance, and ETA,
/// plus a button to open the full route in the native Maps app.
/// On Web: Shows the same text card without the "Open in Maps" button.
///
/// NOTE: This does NOT render an interactive map with a drawn route.
/// Drawing polyline routes requires either Google Directions API (paid)
/// or native MKDirections (requires method channel). For MVP, we show
/// a clean info card + "View in Maps" to let the native app handle routing.
class MapRoutePreview extends StatelessWidget {
  const MapRoutePreview({
    super.key,
    required this.departure,
    required this.destination,
  });

  final MapLocation departure;
  final MapLocation destination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final route = estimateRoute(departure, destination);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route header with distance and ETA
          Row(
            children: [
              Icon(
                Icons.route,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Route Preview',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _InfoChip(
                icon: Icons.straighten,
                label: route.distanceDisplay,
                theme: theme,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.schedule,
                label: route.durationDisplay,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Departure → Destination visual
          _RouteStopRow(
            icon: Icons.trip_origin,
            iconColor: Colors.green.shade600,
            label: 'From',
            address: departure.displayName,
            theme: theme,
          ),

          // Connector line
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Container(
              width: 2,
              height: 24,
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),

          _RouteStopRow(
            icon: Icons.location_on,
            iconColor: Colors.red.shade600,
            label: 'To',
            address: destination.displayName,
            theme: theme,
          ),

          // "View in Maps" button — only on native platforms
          if (!kIsWeb) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map, size: 18),
                label: const Text('View Route in Maps'),
                onPressed: () => _openRouteInMaps(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Opens a route from departure to destination in the native maps app.
  Future<void> _openRouteInMaps() async {
    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isNotEmpty) {
      await availableMaps.first.showDirections(
        origin: Coords(departure.latitude, departure.longitude),
        originTitle: departure.displayName,
        destination: Coords(destination.latitude, destination.longitude),
        destinationTitle: destination.displayName,
      );
    }
  }
}

/// Small chip showing an icon + label (e.g. distance, duration).
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single row in the route visualization (departure or destination).
class _RouteStopRow extends StatelessWidget {
  const _RouteStopRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
    required this.theme,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                address,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
