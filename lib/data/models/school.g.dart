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
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
