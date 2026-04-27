import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/pickup_location.dart';
import 'package:smivo/data/repositories/school_data_repository.dart';

part 'admin_pickup_locations_provider.g.dart';

/// Fetches pickup locations for a specific school.
@riverpod
Future<List<PickupLocation>> adminSchoolPickupLocations(
  Ref ref,
  String schoolId,
) async {
  return ref.watch(schoolDataRepositoryProvider).fetchPickupLocations(schoolId);
}
