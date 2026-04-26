import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/school_condition.dart';
import 'package:smivo/data/repositories/school_data_repository.dart';

part 'admin_conditions_provider.g.dart';

/// Fetches conditions for a given school.
@riverpod
Future<List<SchoolCondition>> adminSchoolConditions(
  Ref ref,
  String schoolId,
) async {
  return ref.watch(schoolDataRepositoryProvider).fetchConditions(schoolId);
}
