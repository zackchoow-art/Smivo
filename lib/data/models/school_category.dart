// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'school_category.freezed.dart';
part 'school_category.g.dart';

/// A product category belonging to a specific school.
///
/// Replaces the hardcoded ItemCategory enum with database-driven
/// categories that can be customized per school.
@freezed
abstract class SchoolCategory with _$SchoolCategory {
  const factory SchoolCategory({
    required String id,
    @JsonKey(name: 'school_id') required String schoolId,
    required String slug,
    required String name,
    String? icon,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _SchoolCategory;

  factory SchoolCategory.fromJson(Map<String, dynamic> json) =>
      _$SchoolCategoryFromJson(json);
}
