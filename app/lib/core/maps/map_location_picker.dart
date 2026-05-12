import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

import 'package:smivo/core/maps/map_service.dart';
import 'package:smivo/core/maps/location_search_service.dart';

/// A cross-platform location picker widget.
///
/// On iOS: Shows a search bar at top + Apple Maps preview below.
/// On Web: Shows a search bar + text-based address card (no map).
///
/// The widget returns a [MapLocation] when the user confirms a selection.
class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({
    super.key,
    this.initialLocation,
    this.label = 'Select Location',
    required this.onLocationSelected,
  });

  /// Pre-filled location (for editing existing trips).
  final MapLocation? initialLocation;

  /// Label shown above the search field.
  final String label;

  /// Called when user confirms a location.
  final ValueChanged<MapLocation> onLocationSelected;

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final _searchController = TextEditingController();
  final _searchService = LocationSearchService();
  List<MapLocation> _results = [];
  MapLocation? _selected;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selected = widget.initialLocation;
      _searchController.text = widget.initialLocation!.displayName;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    if (query.length < 3) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);
    final results = await _searchService.search(query);
    if (mounted) {
      setState(() {
        _results = results;
        _isSearching = false;
      });
    }
  }

  void _onResultTap(MapLocation location) {
    setState(() {
      _selected = location;
      _results = [];
      _searchController.text = location.address ?? location.displayName;
    });
    widget.onLocationSelected(location);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Search input
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for an address...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                            _selected = null;
                          });
                        },
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: _onSearch,
        ),

        // Search results dropdown
        if (_results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _results.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              itemBuilder: (context, index) {
                final loc = _results[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.location_on,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    loc.name ?? loc.address ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: loc.address != null
                      ? Text(
                          loc.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        )
                      : null,
                  onTap: () => _onResultTap(loc),
                );
              },
            ),
          ),

        // Selected location card
        if (_selected != null && _results.isEmpty) ...[
          const SizedBox(height: 12),
          _SelectedLocationCard(
            location: _selected!,
            onOpenInMaps: _openInNativeMaps,
          ),
        ],
      ],
    );
  }

  /// Opens the selected location in the device's native maps app.
  Future<void> _openInNativeMaps() async {
    if (_selected == null) return;
    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isNotEmpty) {
      await availableMaps.first.showMarker(
        coords: Coords(_selected!.latitude, _selected!.longitude),
        title: _selected!.displayName,
      );
    }
  }
}

/// Card showing the confirmed location with coordinates and "Open in Maps".
class _SelectedLocationCard extends StatelessWidget {
  const _SelectedLocationCard({
    required this.location,
    required this.onOpenInMaps,
  });

  final MapLocation location;
  final VoidCallback onOpenInMaps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          // NOTE: "Open in Maps" button lets users verify the exact
          // location in their native maps app.
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 18),
              tooltip: 'Open in Maps',
              onPressed: onOpenInMaps,
            ),
        ],
      ),
    );
  }
}
