// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_role.freezed.dart';
part 'admin_role.g.dart';

/// An admin role assignment linking a user to a scope with a role tier.
///
/// Roles: operator (read-only), admin (school-level write),
/// sysadmin (platform-wide full access).
///
/// Scope: 'platform' (scope_id = null) or 'school' (scope_id = school uuid).
@freezed
abstract class AdminRole with _$AdminRole {
  const factory AdminRole({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String role,
    @JsonKey(name: 'scope_type') required String scopeType,
    @JsonKey(name: 'scope_id') String? scopeId,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // Joined fields from view/query
    @JsonKey(name: 'user_email') String? userEmail,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'school_name') String? schoolName,
  }) = _AdminRole;

  factory AdminRole.fromJson(Map<String, dynamic> json) =>
      _$AdminRoleFromJson(json);
}
