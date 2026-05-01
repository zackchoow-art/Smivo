// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'school.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$School {

 String get id; String get slug; String get name;@JsonKey(name: 'email_domain') String get emailDomain;@JsonKey(name: 'primary_color') String? get primaryColor;@JsonKey(name: 'logo_url') String? get logoUrl;@JsonKey(name: 'is_active') bool get isActive;// Geographic info
 String? get address; String? get city; String? get state;@JsonKey(name: 'zip_code') String? get zipCode; String get country; double? get latitude; double? get longitude; String get timezone;// School profile
@JsonKey(name: 'website_url') String? get websiteUrl; String? get description;@JsonKey(name: 'student_count') int? get studentCount;@JsonKey(name: 'cover_image_url') String? get coverImageUrl;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchoolCopyWith<School> get copyWith => _$SchoolCopyWithImpl<School>(this as School, _$identity);

  /// Serializes this School to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is School&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.emailDomain, emailDomain) || other.emailDomain == emailDomain)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.studentCount, studentCount) || other.studentCount == studentCount)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,slug,name,emailDomain,primaryColor,logoUrl,isActive,address,city,state,zipCode,country,latitude,longitude,timezone,websiteUrl,description,studentCount,coverImageUrl,createdAt,updatedAt]);

@override
String toString() {
  return 'School(id: $id, slug: $slug, name: $name, emailDomain: $emailDomain, primaryColor: $primaryColor, logoUrl: $logoUrl, isActive: $isActive, address: $address, city: $city, state: $state, zipCode: $zipCode, country: $country, latitude: $latitude, longitude: $longitude, timezone: $timezone, websiteUrl: $websiteUrl, description: $description, studentCount: $studentCount, coverImageUrl: $coverImageUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SchoolCopyWith<$Res>  {
  factory $SchoolCopyWith(School value, $Res Function(School) _then) = _$SchoolCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String name,@JsonKey(name: 'email_domain') String emailDomain,@JsonKey(name: 'primary_color') String? primaryColor,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'is_active') bool isActive, String? address, String? city, String? state,@JsonKey(name: 'zip_code') String? zipCode, String country, double? latitude, double? longitude, String timezone,@JsonKey(name: 'website_url') String? websiteUrl, String? description,@JsonKey(name: 'student_count') int? studentCount,@JsonKey(name: 'cover_image_url') String? coverImageUrl,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$SchoolCopyWithImpl<$Res>
    implements $SchoolCopyWith<$Res> {
  _$SchoolCopyWithImpl(this._self, this._then);

  final School _self;
  final $Res Function(School) _then;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? emailDomain = null,Object? primaryColor = freezed,Object? logoUrl = freezed,Object? isActive = null,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? zipCode = freezed,Object? country = null,Object? latitude = freezed,Object? longitude = freezed,Object? timezone = null,Object? websiteUrl = freezed,Object? description = freezed,Object? studentCount = freezed,Object? coverImageUrl = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emailDomain: null == emailDomain ? _self.emailDomain : emailDomain // ignore: cast_nullable_to_non_nullable
as String,primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,studentCount: freezed == studentCount ? _self.studentCount : studentCount // ignore: cast_nullable_to_non_nullable
as int?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [School].
extension SchoolPatterns on School {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _School value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _School value)  $default,){
final _that = this;
switch (_that) {
case _School():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _School value)?  $default,){
final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String name, @JsonKey(name: 'email_domain')  String emailDomain, @JsonKey(name: 'primary_color')  String? primaryColor, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'is_active')  bool isActive,  String? address,  String? city,  String? state, @JsonKey(name: 'zip_code')  String? zipCode,  String country,  double? latitude,  double? longitude,  String timezone, @JsonKey(name: 'website_url')  String? websiteUrl,  String? description, @JsonKey(name: 'student_count')  int? studentCount, @JsonKey(name: 'cover_image_url')  String? coverImageUrl, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.emailDomain,_that.primaryColor,_that.logoUrl,_that.isActive,_that.address,_that.city,_that.state,_that.zipCode,_that.country,_that.latitude,_that.longitude,_that.timezone,_that.websiteUrl,_that.description,_that.studentCount,_that.coverImageUrl,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String name, @JsonKey(name: 'email_domain')  String emailDomain, @JsonKey(name: 'primary_color')  String? primaryColor, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'is_active')  bool isActive,  String? address,  String? city,  String? state, @JsonKey(name: 'zip_code')  String? zipCode,  String country,  double? latitude,  double? longitude,  String timezone, @JsonKey(name: 'website_url')  String? websiteUrl,  String? description, @JsonKey(name: 'student_count')  int? studentCount, @JsonKey(name: 'cover_image_url')  String? coverImageUrl, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _School():
return $default(_that.id,_that.slug,_that.name,_that.emailDomain,_that.primaryColor,_that.logoUrl,_that.isActive,_that.address,_that.city,_that.state,_that.zipCode,_that.country,_that.latitude,_that.longitude,_that.timezone,_that.websiteUrl,_that.description,_that.studentCount,_that.coverImageUrl,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String name, @JsonKey(name: 'email_domain')  String emailDomain, @JsonKey(name: 'primary_color')  String? primaryColor, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'is_active')  bool isActive,  String? address,  String? city,  String? state, @JsonKey(name: 'zip_code')  String? zipCode,  String country,  double? latitude,  double? longitude,  String timezone, @JsonKey(name: 'website_url')  String? websiteUrl,  String? description, @JsonKey(name: 'student_count')  int? studentCount, @JsonKey(name: 'cover_image_url')  String? coverImageUrl, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.emailDomain,_that.primaryColor,_that.logoUrl,_that.isActive,_that.address,_that.city,_that.state,_that.zipCode,_that.country,_that.latitude,_that.longitude,_that.timezone,_that.websiteUrl,_that.description,_that.studentCount,_that.coverImageUrl,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _School implements School {
  const _School({required this.id, required this.slug, required this.name, @JsonKey(name: 'email_domain') required this.emailDomain, @JsonKey(name: 'primary_color') this.primaryColor, @JsonKey(name: 'logo_url') this.logoUrl, @JsonKey(name: 'is_active') this.isActive = false, this.address, this.city, this.state, @JsonKey(name: 'zip_code') this.zipCode, this.country = 'US', this.latitude, this.longitude, this.timezone = 'America/New_York', @JsonKey(name: 'website_url') this.websiteUrl, this.description, @JsonKey(name: 'student_count') this.studentCount, @JsonKey(name: 'cover_image_url') this.coverImageUrl, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String name;
@override@JsonKey(name: 'email_domain') final  String emailDomain;
@override@JsonKey(name: 'primary_color') final  String? primaryColor;
@override@JsonKey(name: 'logo_url') final  String? logoUrl;
@override@JsonKey(name: 'is_active') final  bool isActive;
// Geographic info
@override final  String? address;
@override final  String? city;
@override final  String? state;
@override@JsonKey(name: 'zip_code') final  String? zipCode;
@override@JsonKey() final  String country;
@override final  double? latitude;
@override final  double? longitude;
@override@JsonKey() final  String timezone;
// School profile
@override@JsonKey(name: 'website_url') final  String? websiteUrl;
@override final  String? description;
@override@JsonKey(name: 'student_count') final  int? studentCount;
@override@JsonKey(name: 'cover_image_url') final  String? coverImageUrl;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchoolCopyWith<_School> get copyWith => __$SchoolCopyWithImpl<_School>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchoolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _School&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.emailDomain, emailDomain) || other.emailDomain == emailDomain)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.studentCount, studentCount) || other.studentCount == studentCount)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,slug,name,emailDomain,primaryColor,logoUrl,isActive,address,city,state,zipCode,country,latitude,longitude,timezone,websiteUrl,description,studentCount,coverImageUrl,createdAt,updatedAt]);

@override
String toString() {
  return 'School(id: $id, slug: $slug, name: $name, emailDomain: $emailDomain, primaryColor: $primaryColor, logoUrl: $logoUrl, isActive: $isActive, address: $address, city: $city, state: $state, zipCode: $zipCode, country: $country, latitude: $latitude, longitude: $longitude, timezone: $timezone, websiteUrl: $websiteUrl, description: $description, studentCount: $studentCount, coverImageUrl: $coverImageUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SchoolCopyWith<$Res> implements $SchoolCopyWith<$Res> {
  factory _$SchoolCopyWith(_School value, $Res Function(_School) _then) = __$SchoolCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String name,@JsonKey(name: 'email_domain') String emailDomain,@JsonKey(name: 'primary_color') String? primaryColor,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'is_active') bool isActive, String? address, String? city, String? state,@JsonKey(name: 'zip_code') String? zipCode, String country, double? latitude, double? longitude, String timezone,@JsonKey(name: 'website_url') String? websiteUrl, String? description,@JsonKey(name: 'student_count') int? studentCount,@JsonKey(name: 'cover_image_url') String? coverImageUrl,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$SchoolCopyWithImpl<$Res>
    implements _$SchoolCopyWith<$Res> {
  __$SchoolCopyWithImpl(this._self, this._then);

  final _School _self;
  final $Res Function(_School) _then;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? emailDomain = null,Object? primaryColor = freezed,Object? logoUrl = freezed,Object? isActive = null,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? zipCode = freezed,Object? country = null,Object? latitude = freezed,Object? longitude = freezed,Object? timezone = null,Object? websiteUrl = freezed,Object? description = freezed,Object? studentCount = freezed,Object? coverImageUrl = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_School(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emailDomain: null == emailDomain ? _self.emailDomain : emailDomain // ignore: cast_nullable_to_non_nullable
as String,primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,studentCount: freezed == studentCount ? _self.studentCount : studentCount // ignore: cast_nullable_to_non_nullable
as int?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
