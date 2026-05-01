// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contribution_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContributionEntry {

 String get id;@JsonKey(name: 'user_id') String get userId; int get points;@JsonKey(name: 'source_type') String get sourceType;@JsonKey(name: 'source_id') String? get sourceId; String get description;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of ContributionEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributionEntryCopyWith<ContributionEntry> get copyWith => _$ContributionEntryCopyWithImpl<ContributionEntry>(this as ContributionEntry, _$identity);

  /// Serializes this ContributionEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributionEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.points, points) || other.points == points)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,points,sourceType,sourceId,description,createdAt);

@override
String toString() {
  return 'ContributionEntry(id: $id, userId: $userId, points: $points, sourceType: $sourceType, sourceId: $sourceId, description: $description, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ContributionEntryCopyWith<$Res>  {
  factory $ContributionEntryCopyWith(ContributionEntry value, $Res Function(ContributionEntry) _then) = _$ContributionEntryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, int points,@JsonKey(name: 'source_type') String sourceType,@JsonKey(name: 'source_id') String? sourceId, String description,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$ContributionEntryCopyWithImpl<$Res>
    implements $ContributionEntryCopyWith<$Res> {
  _$ContributionEntryCopyWithImpl(this._self, this._then);

  final ContributionEntry _self;
  final $Res Function(ContributionEntry) _then;

/// Create a copy of ContributionEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? points = null,Object? sourceType = null,Object? sourceId = freezed,Object? description = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContributionEntry].
extension ContributionEntryPatterns on ContributionEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributionEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributionEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributionEntry value)  $default,){
final _that = this;
switch (_that) {
case _ContributionEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributionEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ContributionEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  int points, @JsonKey(name: 'source_type')  String sourceType, @JsonKey(name: 'source_id')  String? sourceId,  String description, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributionEntry() when $default != null:
return $default(_that.id,_that.userId,_that.points,_that.sourceType,_that.sourceId,_that.description,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  int points, @JsonKey(name: 'source_type')  String sourceType, @JsonKey(name: 'source_id')  String? sourceId,  String description, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ContributionEntry():
return $default(_that.id,_that.userId,_that.points,_that.sourceType,_that.sourceId,_that.description,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  int points, @JsonKey(name: 'source_type')  String sourceType, @JsonKey(name: 'source_id')  String? sourceId,  String description, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ContributionEntry() when $default != null:
return $default(_that.id,_that.userId,_that.points,_that.sourceType,_that.sourceId,_that.description,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContributionEntry implements ContributionEntry {
  const _ContributionEntry({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.points, @JsonKey(name: 'source_type') required this.sourceType, @JsonKey(name: 'source_id') this.sourceId, required this.description, @JsonKey(name: 'created_at') this.createdAt});
  factory _ContributionEntry.fromJson(Map<String, dynamic> json) => _$ContributionEntryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  int points;
@override@JsonKey(name: 'source_type') final  String sourceType;
@override@JsonKey(name: 'source_id') final  String? sourceId;
@override final  String description;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of ContributionEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributionEntryCopyWith<_ContributionEntry> get copyWith => __$ContributionEntryCopyWithImpl<_ContributionEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContributionEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributionEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.points, points) || other.points == points)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,points,sourceType,sourceId,description,createdAt);

@override
String toString() {
  return 'ContributionEntry(id: $id, userId: $userId, points: $points, sourceType: $sourceType, sourceId: $sourceId, description: $description, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ContributionEntryCopyWith<$Res> implements $ContributionEntryCopyWith<$Res> {
  factory _$ContributionEntryCopyWith(_ContributionEntry value, $Res Function(_ContributionEntry) _then) = __$ContributionEntryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, int points,@JsonKey(name: 'source_type') String sourceType,@JsonKey(name: 'source_id') String? sourceId, String description,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$ContributionEntryCopyWithImpl<$Res>
    implements _$ContributionEntryCopyWith<$Res> {
  __$ContributionEntryCopyWithImpl(this._self, this._then);

  final _ContributionEntry _self;
  final $Res Function(_ContributionEntry) _then;

/// Create a copy of ContributionEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? points = null,Object? sourceType = null,Object? sourceId = freezed,Object? description = null,Object? createdAt = freezed,}) {
  return _then(_ContributionEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
