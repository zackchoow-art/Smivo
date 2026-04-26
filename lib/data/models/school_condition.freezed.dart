// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'school_condition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SchoolCondition {

 String get id;@JsonKey(name: 'school_id') String get schoolId; String get slug; String get name; String? get description;@JsonKey(name: 'display_order') int get displayOrder;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of SchoolCondition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchoolConditionCopyWith<SchoolCondition> get copyWith => _$SchoolConditionCopyWithImpl<SchoolCondition>(this as SchoolCondition, _$identity);

  /// Serializes this SchoolCondition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchoolCondition&&(identical(other.id, id) || other.id == id)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,schoolId,slug,name,description,displayOrder,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'SchoolCondition(id: $id, schoolId: $schoolId, slug: $slug, name: $name, description: $description, displayOrder: $displayOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SchoolConditionCopyWith<$Res>  {
  factory $SchoolConditionCopyWith(SchoolCondition value, $Res Function(SchoolCondition) _then) = _$SchoolConditionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'school_id') String schoolId, String slug, String name, String? description,@JsonKey(name: 'display_order') int displayOrder,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$SchoolConditionCopyWithImpl<$Res>
    implements $SchoolConditionCopyWith<$Res> {
  _$SchoolConditionCopyWithImpl(this._self, this._then);

  final SchoolCondition _self;
  final $Res Function(SchoolCondition) _then;

/// Create a copy of SchoolCondition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? schoolId = null,Object? slug = null,Object? name = null,Object? description = freezed,Object? displayOrder = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SchoolCondition].
extension SchoolConditionPatterns on SchoolCondition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchoolCondition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchoolCondition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchoolCondition value)  $default,){
final _that = this;
switch (_that) {
case _SchoolCondition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchoolCondition value)?  $default,){
final _that = this;
switch (_that) {
case _SchoolCondition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'school_id')  String schoolId,  String slug,  String name,  String? description, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchoolCondition() when $default != null:
return $default(_that.id,_that.schoolId,_that.slug,_that.name,_that.description,_that.displayOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'school_id')  String schoolId,  String slug,  String name,  String? description, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SchoolCondition():
return $default(_that.id,_that.schoolId,_that.slug,_that.name,_that.description,_that.displayOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'school_id')  String schoolId,  String slug,  String name,  String? description, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SchoolCondition() when $default != null:
return $default(_that.id,_that.schoolId,_that.slug,_that.name,_that.description,_that.displayOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SchoolCondition implements SchoolCondition {
  const _SchoolCondition({required this.id, @JsonKey(name: 'school_id') required this.schoolId, required this.slug, required this.name, this.description, @JsonKey(name: 'display_order') this.displayOrder = 0, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _SchoolCondition.fromJson(Map<String, dynamic> json) => _$SchoolConditionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'school_id') final  String schoolId;
@override final  String slug;
@override final  String name;
@override final  String? description;
@override@JsonKey(name: 'display_order') final  int displayOrder;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of SchoolCondition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchoolConditionCopyWith<_SchoolCondition> get copyWith => __$SchoolConditionCopyWithImpl<_SchoolCondition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchoolConditionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchoolCondition&&(identical(other.id, id) || other.id == id)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,schoolId,slug,name,description,displayOrder,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'SchoolCondition(id: $id, schoolId: $schoolId, slug: $slug, name: $name, description: $description, displayOrder: $displayOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SchoolConditionCopyWith<$Res> implements $SchoolConditionCopyWith<$Res> {
  factory _$SchoolConditionCopyWith(_SchoolCondition value, $Res Function(_SchoolCondition) _then) = __$SchoolConditionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'school_id') String schoolId, String slug, String name, String? description,@JsonKey(name: 'display_order') int displayOrder,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$SchoolConditionCopyWithImpl<$Res>
    implements _$SchoolConditionCopyWith<$Res> {
  __$SchoolConditionCopyWithImpl(this._self, this._then);

  final _SchoolCondition _self;
  final $Res Function(_SchoolCondition) _then;

/// Create a copy of SchoolCondition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? schoolId = null,Object? slug = null,Object? name = null,Object? description = freezed,Object? displayOrder = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SchoolCondition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
