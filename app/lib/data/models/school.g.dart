// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_School _$SchoolFromJson(Map<String, dynamic> json) => _School(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  emailDomain: json['email_domain'] as String,
  primaryColor: json['primary_color'] as String?,
  logoUrl: json['logo_url'] as String?,
  isActive: json['is_active'] as bool? ?? false,
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  zipCode: json['zip_code'] as String?,
  country: json['country'] as String? ?? 'US',
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  timezone: json['timezone'] as String? ?? 'America/New_York',
  websiteUrl: json['website_url'] as String?,
  description: json['description'] as String?,
  studentCount: (json['student_count'] as num?)?.toInt(),
  coverImageUrl: json['cover_image_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SchoolToJson(_School instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'email_domain': instance.emailDomain,
  'primary_color': instance.primaryColor,
  'logo_url': instance.logoUrl,
  'is_active': instance.isActive,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'zip_code': instance.zipCode,
  'country': instance.country,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'timezone': instance.timezone,
  'website_url': instance.websiteUrl,
  'description': instance.description,
  'student_count': instance.studentCount,
  'cover_image_url': instance.coverImageUrl,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
