// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'school_condition.freezed.dart';
part 'school_condition.g.dart';

/// An item condition option belonging to a specific school.
///
/// Replaces the hardcoded condition CHECK constraint with
/// database-driven options that can be customized per school.
@freezed
abstract class SchoolCondition with _$SchoolCondition {
  const factory SchoolCondition({
    required String id,
    @JsonKey(name: 'school_id') required String schoolId,
    required String slug,
    required String name,
    String? description,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _SchoolCondition;

  factory SchoolCondition.fromJson(Map<String, dynamic> json) =>
      _$SchoolConditionFromJson(json);
}
