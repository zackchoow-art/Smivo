import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/data/models/school_category.dart';
import 'package:smivo/data/models/school_condition.dart';
import 'package:smivo/data/repositories/school_data_repository.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';

part 'school_data_provider.g.dart';

/// Fetches active categories for the current user's school.
/// Falls back to AppConstants.categories if DB returns empty.
@riverpod
Future<List<SchoolCategory>> mySchoolCategories(Ref ref) async {
  final profile = ref.watch(profileProvider).value;
  if (profile == null) {
    // Not logged in — return hardcoded fallback as SchoolCategory objects
    return _fallbackCategories();
  }

  try {
    final repo = ref.watch(schoolDataRepositoryProvider);
    final categories = await repo.fetchCategories(profile.schoolId);
    final active = categories.where((c) => c.isActive).toList();

    // NOTE: Sort categories by displayOrder ascending as requested.
    active.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    // NOTE: fallback if DB has no data yet (e.g. migration not run)
    if (active.isEmpty) return _fallbackCategories();
    return active;
  } catch (_) {
    return _fallbackCategories();
  }
}

/// Fetches active conditions for the current user's school.
/// Falls back to hardcoded list if DB returns empty.
@riverpod
Future<List<SchoolCondition>> mySchoolConditions(Ref ref) async {
  final profile = ref.watch(profileProvider).value;
  if (profile == null) return _fallbackConditions();

  try {
    final repo = ref.watch(schoolDataRepositoryProvider);
    final conditions = await repo.fetchConditions(profile.schoolId);
    final active = conditions.where((c) => c.isActive).toList();

    // NOTE: Sort conditions by displayOrder (New -> Poor)
    active.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (active.isEmpty) return _fallbackConditions();
    return active;
  } catch (_) {
    return _fallbackConditions();
  }
}

/// Converts AppConstants.categories into SchoolCategory objects
/// so consumers have a uniform type regardless of data source.
List<SchoolCategory> _fallbackCategories() {
  // NOTE: Explicit display names for fallback, since slug-based
  // capitalization doesn't work well for multi-word categories.
  const fallbackNames = {
    'dorm': 'Dorm',
    'kitchen': 'Kitchen',
    'self_care': 'Self-care',
    'food': 'Food',
    'study_supplies': 'Study Supplies',
    'sports': 'Sports',
    'other': 'Others',
  };
  final list =
      AppConstants.categories.asMap().entries.map((e) {
        final slug = e.value;
        return SchoolCategory(
          id: 'fallback_${e.key}',
          schoolId: '',
          slug: slug,
          name:
              fallbackNames[slug] ?? slug[0].toUpperCase() + slug.substring(1),
          displayOrder: e.key,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
  // Sort by displayOrder (which matches the original index in AppConstants.categories)
  list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  return list;
}

/// Hardcoded fallback for conditions.
List<SchoolCondition> _fallbackConditions() {
  const fallback = [
    {'slug': 'new', 'name': 'New', 'desc': 'Brand new, never used'},
    {
      'slug': 'like_new',
      'name': 'Like New',
      'desc': 'Barely used, excellent condition',
    },
    {'slug': 'good', 'name': 'Good', 'desc': 'Normal wear and tear'},
    {
      'slug': 'fair',
      'name': 'Fair',
      'desc': 'Visible wear but fully functional',
    },
    {'slug': 'poor', 'name': 'Poor', 'desc': 'Heavy wear, may need repair'},
  ];
  final list =
      fallback.asMap().entries.map((e) {
        final item = e.value;
        return SchoolCondition(
          id: 'fallback_${e.key}',
          schoolId: '',
          slug: item['slug']!,
          name: item['name']!,
          description: item['desc'],
          displayOrder: e.key,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
  // Already sorted by displayOrder (index), but making it explicit
  list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  return list;
}
