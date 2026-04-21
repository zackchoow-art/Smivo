import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smivo/data/models/pickup_location.dart';
import 'package:smivo/data/models/school.dart';
import 'package:smivo/data/repositories/pickup_location_repository.dart';
import 'package:smivo/data/repositories/school_repository.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';

part 'school_provider.g.dart';

/// Fetches all active schools.
/// Used for displaying school lists (e.g. future registration dropdown).
@riverpod
Future<List<School>> activeSchools(Ref ref) async {
  final repository = ref.watch(schoolRepositoryProvider);
  return repository.fetchActiveSchools();
}

/// Fetches pickup locations for a specific school.
@riverpod
Future<List<PickupLocation>> pickupLocationsForSchool(
  Ref ref,
  String schoolId,
) async {
  final repository = ref.watch(pickupLocationRepositoryProvider);
  return repository.fetchForSchool(schoolId);
}

/// Convenience provider: pickup locations for the CURRENT 
/// user's school. Returns empty list if not logged in.
@riverpod
Future<List<PickupLocation>> myPickupLocations(Ref ref) async {
  final profile = ref.watch(profileProvider).valueOrNull;
  if (profile == null) return [];

  final repository = ref.watch(pickupLocationRepositoryProvider);
  return repository.fetchForSchool(profile.schoolId);
}

/// Convenience provider: the CURRENT user's school object.
/// Returns null if not logged in.
@riverpod
Future<School?> mySchool(Ref ref) async {
  final profile = ref.watch(profileProvider).valueOrNull;
  if (profile == null) return null;

  final repository = ref.watch(schoolRepositoryProvider);
  return repository.fetchSchool(profile.schoolId);
}
