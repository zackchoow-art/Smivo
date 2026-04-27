// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_permission.freezed.dart';
part 'admin_permission.g.dart';

/// Per-module permission override for an admin role assignment.
///
/// If no AdminPermission row exists for a (role_id, module),
/// the role's default permission applies. This table is only
/// needed when overriding the default.
@freezed
abstract class AdminPermission with _$AdminPermission {
  const factory AdminPermission({
    required String id,
    @JsonKey(name: 'role_id') required String roleId,
    required String module,
    @Default('none') String permission,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AdminPermission;

  factory AdminPermission.fromJson(Map<String, dynamic> json) =>
      _$AdminPermissionFromJson(json);
}
