// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserFeedback {

 String get id;@JsonKey(name: 'user_id') String get userId; String get type; String get title; String get description;@JsonKey(name: 'screenshot_url') String? get screenshotUrl;@JsonKey(name: 'device_info') Map<String, dynamic>? get deviceInfo; String get status;@JsonKey(name: 'admin_response') String? get adminResponse;@JsonKey(name: 'points_awarded') int get pointsAwarded;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of UserFeedback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFeedbackCopyWith<UserFeedback> get copyWith => _$UserFeedbackCopyWithImpl<UserFeedback>(this as UserFeedback, _$identity);

  /// Serializes this UserFeedback to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.screenshotUrl, screenshotUrl) || other.screenshotUrl == screenshotUrl)&&const DeepCollectionEquality().equals(other.deviceInfo, deviceInfo)&&(identical(other.status, status) || other.status == status)&&(identical(other.adminResponse, adminResponse) || other.adminResponse == adminResponse)&&(identical(other.pointsAwarded, pointsAwarded) || other.pointsAwarded == pointsAwarded)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,title,description,screenshotUrl,const DeepCollectionEquality().hash(deviceInfo),status,adminResponse,pointsAwarded,createdAt,updatedAt);

@override
String toString() {
  return 'UserFeedback(id: $id, userId: $userId, type: $type, title: $title, description: $description, screenshotUrl: $screenshotUrl, deviceInfo: $deviceInfo, status: $status, adminResponse: $adminResponse, pointsAwarded: $pointsAwarded, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserFeedbackCopyWith<$Res>  {
  factory $UserFeedbackCopyWith(UserFeedback value, $Res Function(UserFeedback) _then) = _$UserFeedbackCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String type, String title, String description,@JsonKey(name: 'screenshot_url') String? screenshotUrl,@JsonKey(name: 'device_info') Map<String, dynamic>? deviceInfo, String status,@JsonKey(name: 'admin_response') String? adminResponse,@JsonKey(name: 'points_awarded') int pointsAwarded,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$UserFeedbackCopyWithImpl<$Res>
    implements $UserFeedbackCopyWith<$Res> {
  _$UserFeedbackCopyWithImpl(this._self, this._then);

  final UserFeedback _self;
  final $Res Function(UserFeedback) _then;

/// Create a copy of UserFeedback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? description = null,Object? screenshotUrl = freezed,Object? deviceInfo = freezed,Object? status = null,Object? adminResponse = freezed,Object? pointsAwarded = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,screenshotUrl: freezed == screenshotUrl ? _self.screenshotUrl : screenshotUrl // ignore: cast_nullable_to_non_nullable
as String?,deviceInfo: freezed == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,adminResponse: freezed == adminResponse ? _self.adminResponse : adminResponse // ignore: cast_nullable_to_non_nullable
as String?,pointsAwarded: null == pointsAwarded ? _self.pointsAwarded : pointsAwarded // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserFeedback].
extension UserFeedbackPatterns on UserFeedback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFeedback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFeedback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFeedback value)  $default,){
final _that = this;
switch (_that) {
case _UserFeedback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFeedback value)?  $default,){
final _that = this;
switch (_that) {
case _UserFeedback() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String type,  String title,  String description, @JsonKey(name: 'screenshot_url')  String? screenshotUrl, @JsonKey(name: 'device_info')  Map<String, dynamic>? deviceInfo,  String status, @JsonKey(name: 'admin_response')  String? adminResponse, @JsonKey(name: 'points_awarded')  int pointsAwarded, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFeedback() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.title,_that.description,_that.screenshotUrl,_that.deviceInfo,_that.status,_that.adminResponse,_that.pointsAwarded,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String type,  String title,  String description, @JsonKey(name: 'screenshot_url')  String? screenshotUrl, @JsonKey(name: 'device_info')  Map<String, dynamic>? deviceInfo,  String status, @JsonKey(name: 'admin_response')  String? adminResponse, @JsonKey(name: 'points_awarded')  int pointsAwarded, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserFeedback():
return $default(_that.id,_that.userId,_that.type,_that.title,_that.description,_that.screenshotUrl,_that.deviceInfo,_that.status,_that.adminResponse,_that.pointsAwarded,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String type,  String title,  String description, @JsonKey(name: 'screenshot_url')  String? screenshotUrl, @JsonKey(name: 'device_info')  Map<String, dynamic>? deviceInfo,  String status, @JsonKey(name: 'admin_response')  String? adminResponse, @JsonKey(name: 'points_awarded')  int pointsAwarded, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserFeedback() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.title,_that.description,_that.screenshotUrl,_that.deviceInfo,_that.status,_that.adminResponse,_that.pointsAwarded,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserFeedback implements UserFeedback {
  const _UserFeedback({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.type, required this.title, required this.description, @JsonKey(name: 'screenshot_url') this.screenshotUrl, @JsonKey(name: 'device_info') final  Map<String, dynamic>? deviceInfo, this.status = 'submitted', @JsonKey(name: 'admin_response') this.adminResponse, @JsonKey(name: 'points_awarded') this.pointsAwarded = 0, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _deviceInfo = deviceInfo;
  factory _UserFeedback.fromJson(Map<String, dynamic> json) => _$UserFeedbackFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String type;
@override final  String title;
@override final  String description;
@override@JsonKey(name: 'screenshot_url') final  String? screenshotUrl;
 final  Map<String, dynamic>? _deviceInfo;
@override@JsonKey(name: 'device_info') Map<String, dynamic>? get deviceInfo {
  final value = _deviceInfo;
  if (value == null) return null;
  if (_deviceInfo is EqualUnmodifiableMapView) return _deviceInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  String status;
@override@JsonKey(name: 'admin_response') final  String? adminResponse;
@override@JsonKey(name: 'points_awarded') final  int pointsAwarded;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of UserFeedback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFeedbackCopyWith<_UserFeedback> get copyWith => __$UserFeedbackCopyWithImpl<_UserFeedback>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserFeedbackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.screenshotUrl, screenshotUrl) || other.screenshotUrl == screenshotUrl)&&const DeepCollectionEquality().equals(other._deviceInfo, _deviceInfo)&&(identical(other.status, status) || other.status == status)&&(identical(other.adminResponse, adminResponse) || other.adminResponse == adminResponse)&&(identical(other.pointsAwarded, pointsAwarded) || other.pointsAwarded == pointsAwarded)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,title,description,screenshotUrl,const DeepCollectionEquality().hash(_deviceInfo),status,adminResponse,pointsAwarded,createdAt,updatedAt);

@override
String toString() {
  return 'UserFeedback(id: $id, userId: $userId, type: $type, title: $title, description: $description, screenshotUrl: $screenshotUrl, deviceInfo: $deviceInfo, status: $status, adminResponse: $adminResponse, pointsAwarded: $pointsAwarded, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserFeedbackCopyWith<$Res> implements $UserFeedbackCopyWith<$Res> {
  factory _$UserFeedbackCopyWith(_UserFeedback value, $Res Function(_UserFeedback) _then) = __$UserFeedbackCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String type, String title, String description,@JsonKey(name: 'screenshot_url') String? screenshotUrl,@JsonKey(name: 'device_info') Map<String, dynamic>? deviceInfo, String status,@JsonKey(name: 'admin_response') String? adminResponse,@JsonKey(name: 'points_awarded') int pointsAwarded,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$UserFeedbackCopyWithImpl<$Res>
    implements _$UserFeedbackCopyWith<$Res> {
  __$UserFeedbackCopyWithImpl(this._self, this._then);

  final _UserFeedback _self;
  final $Res Function(_UserFeedback) _then;

/// Create a copy of UserFeedback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? description = null,Object? screenshotUrl = freezed,Object? deviceInfo = freezed,Object? status = null,Object? adminResponse = freezed,Object? pointsAwarded = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserFeedback(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,screenshotUrl: freezed == screenshotUrl ? _self.screenshotUrl : screenshotUrl // ignore: cast_nullable_to_non_nullable
as String?,deviceInfo: freezed == deviceInfo ? _self._deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,adminResponse: freezed == adminResponse ? _self.adminResponse : adminResponse // ignore: cast_nullable_to_non_nullable
as String?,pointsAwarded: null == pointsAwarded ? _self.pointsAwarded : pointsAwarded // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
