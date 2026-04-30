import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/system_dictionary.dart';
import 'package:smivo/data/repositories/school_data_repository.dart';

part 'status_resolver_provider.g.dart';

/// Cached provider that loads ALL system dictionaries once and
/// exposes a [StatusResolver] for looking up labels and colors.
@riverpod
Future<StatusResolver> statusResolver(Ref ref) async {
  try {
    final repo = ref.watch(schoolDataRepositoryProvider);
    final entries = await repo.fetchDictionaries();
    return StatusResolver(entries);
  } catch (_) {
    // NOTE: fallback to empty resolver — hardcoded defaults will kick in
    return StatusResolver([]);
  }
}

/// Centralized resolver for status labels and colors.
///
/// All order_status, rental_status, listing_status lookups
/// go through this class. Consumers call [label] and [color]
/// with a dict_type + dict_key, and get back DB-driven values
/// with hardcoded fallback.
class StatusResolver {
  final Map<String, Map<String, SystemDictionary>> _index = {};

  StatusResolver(List<SystemDictionary> entries) {
    for (final e in entries) {
      _index.putIfAbsent(e.dictType, () => {})[e.dictKey] = e;
    }
  }

  /// Get display label for a status key.
  /// Example: label('order_status', 'pending') → 'Pending'
  String label(String dictType, String key) {
    return _index[dictType]?[key]?.dictValue ?? _defaultLabel(dictType, key);
  }

  /// Get color for a status key.
  /// Example: color('order_status', 'pending') → Color(0xFFD97706)
  Color color(String dictType, String key) {
    final hex = _index[dictType]?[key]?.extra?['color'];
    if (hex != null) return _parseHex(hex);
    return _defaultColor(dictType, key);
  }

  // ── Convenience shortcuts ──────────────────────────────────

  String orderLabel(String status) => label('order_status', status);
  Color orderColor(String status) => color('order_status', status);

  String rentalLabel(String status) => label('rental_status', status);
  Color rentalColor(String status) => color('rental_status', status);

  String listingLabel(String status) => label('listing_status', status);
  Color listingColor(String status) => color('listing_status', status);

  // ── Hardcoded fallback ─────────────────────────────────────

  static String _defaultLabel(String dictType, String key) {
    // Convert snake_case to Title Case
    return key
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static Color _defaultColor(String dictType, String key) {
    switch (dictType) {
      case 'order_status':
        switch (key) {
          case 'pending':
            return const Color(0xFFD97706);
          case 'confirmed':
            return const Color(0xFF059669);
          case 'completed':
            return const Color(0xFF7C3AED);
          case 'cancelled':
            return const Color(0xFFDC2626);
          case 'missed':
            return const Color(0xFF6B7280);
        }
      case 'rental_status':
        switch (key) {
          case 'active':
            return const Color(0xFF059669);
          case 'return_requested':
            return const Color(0xFFD97706);
          case 'returned':
            return const Color(0xFF0891B2);
          case 'deposit_refunded':
            return const Color(0xFF7C3AED);
        }
      case 'listing_status':
        switch (key) {
          case 'active':
            return const Color(0xFF059669);
          case 'reserved':
            return const Color(0xFFD97706);
          case 'sold':
            return const Color(0xFF6B7280);
          case 'rented':
            return const Color(0xFF0891B2);
          case 'delisted':
            return const Color(0xFFDC2626);
        }
    }
    return const Color(0xFF6B7280);
  }

  static Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF6B7280);
    }
  }
}
