// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'school_admin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchoolAdmin {

 String get id;@JsonKey(name: 'school_id') String get schoolId;@JsonKey(name: 'user_id') String get userId; String get role;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of SchoolAdmin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchoolAdminCopyWith<SchoolAdmin> get copyWith => _$SchoolAdminCopyWithImpl<SchoolAdmin>(this as SchoolAdmin, _$identity);

  /// Serializes this SchoolAdmin to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchoolAdmin&&(identical(other.id, id) || other.id == id)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,schoolId,userId,role,createdAt,updatedAt);

@override
String toString() {
  return 'SchoolAdmin(id: $id, schoolId: $schoolId, userId: $userId, role: $role, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SchoolAdminCopyWith<$Res>  {
  factory $SchoolAdminCopyWith(SchoolAdmin value, $Res Function(SchoolAdmin) _then) = _$SchoolAdminCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'school_id') String schoolId,@JsonKey(name: 'user_id') String userId, String role,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$SchoolAdminCopyWithImpl<$Res>
    implements $SchoolAdminCopyWith<$Res> {
  _$SchoolAdminCopyWithImpl(this._self, this._then);

  final SchoolAdmin _self;
  final $Res Function(SchoolAdmin) _then;

/// Create a copy of SchoolAdmin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? schoolId = null,Object? userId = null,Object? role = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SchoolAdmin].
extension SchoolAdminPatterns on SchoolAdmin {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchoolAdmin value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchoolAdmin() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchoolAdmin value)  $default,){
final _that = this;
switch (_that) {
case _SchoolAdmin():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchoolAdmin value)?  $default,){
final _that = this;
switch (_that) {
case _SchoolAdmin() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'school_id')  String schoolId, @JsonKey(name: 'user_id')  String userId,  String role, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchoolAdmin() when $default != null:
return $default(_that.id,_that.schoolId,_that.userId,_that.role,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'school_id')  String schoolId, @JsonKey(name: 'user_id')  String userId,  String role, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SchoolAdmin():
return $default(_that.id,_that.schoolId,_that.userId,_that.role,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'school_id')  String schoolId, @JsonKey(name: 'user_id')  String userId,  String role, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SchoolAdmin() when $default != null:
return $default(_that.id,_that.schoolId,_that.userId,_that.role,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SchoolAdmin implements SchoolAdmin {
  const _SchoolAdmin({required this.id, @JsonKey(name: 'school_id') required this.schoolId, @JsonKey(name: 'user_id') required this.userId, this.role = 'admin', @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _SchoolAdmin.fromJson(Map<String, dynamic> json) => _$SchoolAdminFromJson(json);

@override final  String id;
@override@JsonKey(name: 'school_id') final  String schoolId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey() final  String role;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of SchoolAdmin
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchoolAdminCopyWith<_SchoolAdmin> get copyWith => __$SchoolAdminCopyWithImpl<_SchoolAdmin>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchoolAdminToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchoolAdmin&&(identical(other.id, id) || other.id == id)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,schoolId,userId,role,createdAt,updatedAt);

@override
String toString() {
  return 'SchoolAdmin(id: $id, schoolId: $schoolId, userId: $userId, role: $role, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SchoolAdminCopyWith<$Res> implements $SchoolAdminCopyWith<$Res> {
  factory _$SchoolAdminCopyWith(_SchoolAdmin value, $Res Function(_SchoolAdmin) _then) = __$SchoolAdminCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'school_id') String schoolId,@JsonKey(name: 'user_id') String userId, String role,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$SchoolAdminCopyWithImpl<$Res>
    implements _$SchoolAdminCopyWith<$Res> {
  __$SchoolAdminCopyWithImpl(this._self, this._then);

  final _SchoolAdmin _self;
  final $Res Function(_SchoolAdmin) _then;

/// Create a copy of SchoolAdmin
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? schoolId = null,Object? userId = null,Object? role = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SchoolAdmin(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
