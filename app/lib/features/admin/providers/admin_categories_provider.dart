import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/school_category.dart';
import 'package:smivo/data/repositories/school_data_repository.dart';

part 'admin_categories_provider.g.dart';

/// Fetches categories for a given school.
@riverpod
Future<List<SchoolCategory>> adminSchoolCategories(
  Ref ref,
  String schoolId,
) async {
  return ref.watch(schoolDataRepositoryProvider).fetchCategories(schoolId);
}
