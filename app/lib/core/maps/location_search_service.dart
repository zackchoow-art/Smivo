import 'package:geocoding/geocoding.dart' as geocoding;

import 'package:smivo/core/maps/map_service.dart';

/// Location search service using the [geocoding] package.
///
/// Works on all platforms (iOS, Android, Web) for free by using
/// the OS-native geocoding APIs (CLGeocoder on iOS, Geocoder on Android,
/// browser Geolocation API on Web).
class LocationSearchService {
  /// Searches for locations matching [query].
  ///
  /// Returns a list of [MapLocation] results. On iOS this uses Apple's
  /// CLGeocoder (free, no API key needed). Results are limited to 5.
  Future<List<MapLocation>> search(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final locations = await geocoding.locationFromAddress(query);
      final results = <MapLocation>[];

      for (final loc in locations.take(5)) {
        // Reverse-geocode each result to get a formatted address
        final placemarks = await geocoding.placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        final placemark = placemarks.isNotEmpty ? placemarks.first : null;

        results.add(MapLocation(
          latitude: loc.latitude,
          longitude: loc.longitude,
          address: _formatPlacemark(placemark),
          name: placemark?.name,
        ));
      }

      return results;
    } catch (e) {
      // NOTE: geocoding can throw on invalid/unfound addresses.
      // Return empty list instead of crashing.
      return [];
    }
  }

  /// Reverse-geocodes coordinates into a readable address.
  Future<MapLocation?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) return null;

      final placemark = placemarks.first;
      return MapLocation(
        latitude: latitude,
        longitude: longitude,
        address: _formatPlacemark(placemark),
        name: placemark.name,
      );
    } catch (e) {
      return null;
    }
  }

  /// Formats a [Placemark] into a single-line address string.
  String _formatPlacemark(geocoding.Placemark? p) {
    if (p == null) return 'Unknown location';
    final parts = <String>[
      if (p.street != null && p.street!.isNotEmpty) p.street!,
      if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
      if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
        p.administrativeArea!,
      if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode!,
    ];
    return parts.join(', ');
  }
}
