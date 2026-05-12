import 'dart:math' as math;



/// Data class representing a geographic location with optional metadata.
class MapLocation {
  const MapLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeId,
    this.name,
  });

  final double latitude;
  final double longitude;
  final String? address;

  /// Platform-specific place identifier.
  final String? placeId;

  /// Human-readable name (e.g. "Smith College").
  final String? name;

  /// Returns name if available, otherwise address, otherwise coordinates.
  String get displayName => name ?? address ?? '$latitude, $longitude';

  @override
  String toString() => 'MapLocation($displayName, $latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapLocation &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// Simple route info returned by ETA estimation.
class RouteInfo {
  const RouteInfo({
    required this.distanceMeters,
    required this.durationMinutes,
  });

  final double distanceMeters;
  final int durationMinutes;

  /// Human-readable distance (e.g. "12.3 km").
  String get distanceDisplay {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.toStringAsFixed(0)} m';
  }

  /// Human-readable duration (e.g. "1 h 15 min").
  String get durationDisplay {
    if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      return mins > 0 ? '$hours h $mins min' : '$hours h';
    }
    return '$durationMinutes min';
  }
}

/// Estimates travel info between two locations using Haversine formula.
///
/// NOTE: This is straight-line distance × 1.3 road factor, not actual
/// road routing. For accurate directions, users should tap "Open in Maps".
RouteInfo estimateRoute(MapLocation origin, MapLocation destination) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRadians(destination.latitude - origin.latitude);
  final dLon = _toRadians(destination.longitude - origin.longitude);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(origin.latitude)) *
          math.cos(_toRadians(destination.latitude)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  final straightLineKm = earthRadiusKm * c;

  // HACK: Multiply by 1.3 to approximate actual road distance from
  // straight-line; assume 50 km/h average for suburban college areas.
  final roadDistanceMeters = straightLineKm * 1.3 * 1000;
  final durationMinutes = (straightLineKm * 1.3 / 50 * 60).ceil();

  return RouteInfo(
    distanceMeters: roadDistanceMeters,
    durationMinutes: durationMinutes < 1 ? 1 : durationMinutes,
  );
}

double _toRadians(double degrees) => degrees * math.pi / 180;
