// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'school.freezed.dart';
part 'school.g.dart';

/// A college or university that uses Smivo.
///
/// Each school has its own email domain (for registration),
/// pickup locations, and optional branding.
@freezed
abstract class School with _$School {
  const factory School({
    required String id,
    required String slug,
    required String name,
    @JsonKey(name: 'email_domain') required String emailDomain,
    @JsonKey(name: 'primary_color') String? primaryColor,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'is_active') @Default(false) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _School;

  factory School.fromJson(Map<String, dynamic> json) =>
      _$SchoolFromJson(json);
}
