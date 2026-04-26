// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'school.freezed.dart';
part 'school.g.dart';

/// A college or university that uses Smivo.
///
/// Each school is a closed community container with its own
/// email domain, pickup locations, categories, conditions,
/// FAQs, and admin team. New schools are initialized with
/// default data via the seed_school_defaults() RPC.
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

    // Geographic info
    String? address,
    String? city,
    String? state,
    @JsonKey(name: 'zip_code') String? zipCode,
    @Default('US') String country,
    double? latitude,
    double? longitude,
    @Default('America/New_York') String timezone,

    // School profile
    @JsonKey(name: 'website_url') String? websiteUrl,
    String? description,
    @JsonKey(name: 'student_count') int? studentCount,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,

    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _School;

  factory School.fromJson(Map<String, dynamic> json) =>
      _$SchoolFromJson(json);
}
