// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'school_admin.freezed.dart';
part 'school_admin.g.dart';

/// An admin assignment linking a user to a school with a role.
///
/// Roles: super_admin (platform-wide), admin (school-level),
/// moderator (read + content review).
@freezed
abstract class SchoolAdmin with _$SchoolAdmin {
  const factory SchoolAdmin({
    required String id,
    @JsonKey(name: 'school_id') required String schoolId,
    @JsonKey(name: 'user_id') required String userId,
    @Default('admin') String role,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _SchoolAdmin;

  factory SchoolAdmin.fromJson(Map<String, dynamic> json) =>
      _$SchoolAdminFromJson(json);
}
