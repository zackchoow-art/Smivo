// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_role.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminRole {

 String get id;@JsonKey(name: 'user_id') String get userId; String get role;@JsonKey(name: 'scope_type') String get scopeType;@JsonKey(name: 'scope_id') String? get scopeId;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;// Joined fields from view/query
@JsonKey(name: 'user_email') String? get userEmail;@JsonKey(name: 'user_name') String? get userName;@JsonKey(name: 'school_name') String? get schoolName;
/// Create a copy of AdminRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminRoleCopyWith<AdminRole> get copyWith => _$AdminRoleCopyWithImpl<AdminRole>(this as AdminRole, _$identity);

  /// Serializes this AdminRole to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminRole&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,role,scopeType,scopeId,isActive,createdAt,updatedAt,userEmail,userName,schoolName);

@override
String toString() {
  return 'AdminRole(id: $id, userId: $userId, role: $role, scopeType: $scopeType, scopeId: $scopeId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, userEmail: $userEmail, userName: $userName, schoolName: $schoolName)';
}


}

/// @nodoc
abstract mixin class $AdminRoleCopyWith<$Res>  {
  factory $AdminRoleCopyWith(AdminRole value, $Res Function(AdminRole) _then) = _$AdminRoleCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String role,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String? scopeId,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'user_email') String? userEmail,@JsonKey(name: 'user_name') String? userName,@JsonKey(name: 'school_name') String? schoolName
});




}
/// @nodoc
class _$AdminRoleCopyWithImpl<$Res>
    implements $AdminRoleCopyWith<$Res> {
  _$AdminRoleCopyWithImpl(this._self, this._then);

  final AdminRole _self;
  final $Res Function(AdminRole) _then;

/// Create a copy of AdminRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? role = null,Object? scopeType = null,Object? scopeId = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? userEmail = freezed,Object? userName = freezed,Object? schoolName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: freezed == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminRole].
extension AdminRolePatterns on AdminRole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminRole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminRole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminRole value)  $default,){
final _that = this;
switch (_that) {
case _AdminRole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminRole value)?  $default,){
final _that = this;
switch (_that) {
case _AdminRole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String role, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String? scopeId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'user_email')  String? userEmail, @JsonKey(name: 'user_name')  String? userName, @JsonKey(name: 'school_name')  String? schoolName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminRole() when $default != null:
return $default(_that.id,_that.userId,_that.role,_that.scopeType,_that.scopeId,_that.isActive,_that.createdAt,_that.updatedAt,_that.userEmail,_that.userName,_that.schoolName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String role, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String? scopeId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'user_email')  String? userEmail, @JsonKey(name: 'user_name')  String? userName, @JsonKey(name: 'school_name')  String? schoolName)  $default,) {final _that = this;
switch (_that) {
case _AdminRole():
return $default(_that.id,_that.userId,_that.role,_that.scopeType,_that.scopeId,_that.isActive,_that.createdAt,_that.updatedAt,_that.userEmail,_that.userName,_that.schoolName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String role, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String? scopeId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'user_email')  String? userEmail, @JsonKey(name: 'user_name')  String? userName, @JsonKey(name: 'school_name')  String? schoolName)?  $default,) {final _that = this;
switch (_that) {
case _AdminRole() when $default != null:
return $default(_that.id,_that.userId,_that.role,_that.scopeType,_that.scopeId,_that.isActive,_that.createdAt,_that.updatedAt,_that.userEmail,_that.userName,_that.schoolName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminRole implements AdminRole {
  const _AdminRole({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.role, @JsonKey(name: 'scope_type') required this.scopeType, @JsonKey(name: 'scope_id') this.scopeId, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'user_email') this.userEmail, @JsonKey(name: 'user_name') this.userName, @JsonKey(name: 'school_name') this.schoolName});
  factory _AdminRole.fromJson(Map<String, dynamic> json) => _$AdminRoleFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String role;
@override@JsonKey(name: 'scope_type') final  String scopeType;
@override@JsonKey(name: 'scope_id') final  String? scopeId;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
// Joined fields from view/query
@override@JsonKey(name: 'user_email') final  String? userEmail;
@override@JsonKey(name: 'user_name') final  String? userName;
@override@JsonKey(name: 'school_name') final  String? schoolName;

/// Create a copy of AdminRole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminRoleCopyWith<_AdminRole> get copyWith => __$AdminRoleCopyWithImpl<_AdminRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminRole&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,role,scopeType,scopeId,isActive,createdAt,updatedAt,userEmail,userName,schoolName);

@override
String toString() {
  return 'AdminRole(id: $id, userId: $userId, role: $role, scopeType: $scopeType, scopeId: $scopeId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, userEmail: $userEmail, userName: $userName, schoolName: $schoolName)';
}


}

/// @nodoc
abstract mixin class _$AdminRoleCopyWith<$Res> implements $AdminRoleCopyWith<$Res> {
  factory _$AdminRoleCopyWith(_AdminRole value, $Res Function(_AdminRole) _then) = __$AdminRoleCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String role,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String? scopeId,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'user_email') String? userEmail,@JsonKey(name: 'user_name') String? userName,@JsonKey(name: 'school_name') String? schoolName
});




}
/// @nodoc
class __$AdminRoleCopyWithImpl<$Res>
    implements _$AdminRoleCopyWith<$Res> {
  __$AdminRoleCopyWithImpl(this._self, this._then);

  final _AdminRole _self;
  final $Res Function(_AdminRole) _then;

/// Create a copy of AdminRole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? role = null,Object? scopeType = null,Object? scopeId = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? userEmail = freezed,Object? userName = freezed,Object? schoolName = freezed,}) {
  return _then(_AdminRole(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: freezed == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
