// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_dictionary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SystemDictionary {

 String get id;@JsonKey(name: 'dict_type') String get dictType;@JsonKey(name: 'dict_key') String get dictKey;@JsonKey(name: 'dict_value') String get dictValue; String? get description; Map<String, dynamic>? get extra;@JsonKey(name: 'display_order') int get displayOrder;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of SystemDictionary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SystemDictionaryCopyWith<SystemDictionary> get copyWith => _$SystemDictionaryCopyWithImpl<SystemDictionary>(this as SystemDictionary, _$identity);

  /// Serializes this SystemDictionary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SystemDictionary&&(identical(other.id, id) || other.id == id)&&(identical(other.dictType, dictType) || other.dictType == dictType)&&(identical(other.dictKey, dictKey) || other.dictKey == dictKey)&&(identical(other.dictValue, dictValue) || other.dictValue == dictValue)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.extra, extra)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dictType,dictKey,dictValue,description,const DeepCollectionEquality().hash(extra),displayOrder,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'SystemDictionary(id: $id, dictType: $dictType, dictKey: $dictKey, dictValue: $dictValue, description: $description, extra: $extra, displayOrder: $displayOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SystemDictionaryCopyWith<$Res>  {
  factory $SystemDictionaryCopyWith(SystemDictionary value, $Res Function(SystemDictionary) _then) = _$SystemDictionaryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'dict_type') String dictType,@JsonKey(name: 'dict_key') String dictKey,@JsonKey(name: 'dict_value') String dictValue, String? description, Map<String, dynamic>? extra,@JsonKey(name: 'display_order') int displayOrder,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$SystemDictionaryCopyWithImpl<$Res>
    implements $SystemDictionaryCopyWith<$Res> {
  _$SystemDictionaryCopyWithImpl(this._self, this._then);

  final SystemDictionary _self;
  final $Res Function(SystemDictionary) _then;

/// Create a copy of SystemDictionary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dictType = null,Object? dictKey = null,Object? dictValue = null,Object? description = freezed,Object? extra = freezed,Object? displayOrder = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dictType: null == dictType ? _self.dictType : dictType // ignore: cast_nullable_to_non_nullable
as String,dictKey: null == dictKey ? _self.dictKey : dictKey // ignore: cast_nullable_to_non_nullable
as String,dictValue: null == dictValue ? _self.dictValue : dictValue // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,extra: freezed == extra ? _self.extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SystemDictionary].
extension SystemDictionaryPatterns on SystemDictionary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SystemDictionary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SystemDictionary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SystemDictionary value)  $default,){
final _that = this;
switch (_that) {
case _SystemDictionary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SystemDictionary value)?  $default,){
final _that = this;
switch (_that) {
case _SystemDictionary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'dict_type')  String dictType, @JsonKey(name: 'dict_key')  String dictKey, @JsonKey(name: 'dict_value')  String dictValue,  String? description,  Map<String, dynamic>? extra, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SystemDictionary() when $default != null:
return $default(_that.id,_that.dictType,_that.dictKey,_that.dictValue,_that.description,_that.extra,_that.displayOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'dict_type')  String dictType, @JsonKey(name: 'dict_key')  String dictKey, @JsonKey(name: 'dict_value')  String dictValue,  String? description,  Map<String, dynamic>? extra, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SystemDictionary():
return $default(_that.id,_that.dictType,_that.dictKey,_that.dictValue,_that.description,_that.extra,_that.displayOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'dict_type')  String dictType, @JsonKey(name: 'dict_key')  String dictKey, @JsonKey(name: 'dict_value')  String dictValue,  String? description,  Map<String, dynamic>? extra, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SystemDictionary() when $default != null:
return $default(_that.id,_that.dictType,_that.dictKey,_that.dictValue,_that.description,_that.extra,_that.displayOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SystemDictionary implements SystemDictionary {
  const _SystemDictionary({required this.id, @JsonKey(name: 'dict_type') required this.dictType, @JsonKey(name: 'dict_key') required this.dictKey, @JsonKey(name: 'dict_value') required this.dictValue, this.description, final  Map<String, dynamic>? extra, @JsonKey(name: 'display_order') this.displayOrder = 0, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _extra = extra;
  factory _SystemDictionary.fromJson(Map<String, dynamic> json) => _$SystemDictionaryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'dict_type') final  String dictType;
@override@JsonKey(name: 'dict_key') final  String dictKey;
@override@JsonKey(name: 'dict_value') final  String dictValue;
@override final  String? description;
 final  Map<String, dynamic>? _extra;
@override Map<String, dynamic>? get extra {
  final value = _extra;
  if (value == null) return null;
  if (_extra is EqualUnmodifiableMapView) return _extra;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'display_order') final  int displayOrder;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of SystemDictionary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SystemDictionaryCopyWith<_SystemDictionary> get copyWith => __$SystemDictionaryCopyWithImpl<_SystemDictionary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SystemDictionaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SystemDictionary&&(identical(other.id, id) || other.id == id)&&(identical(other.dictType, dictType) || other.dictType == dictType)&&(identical(other.dictKey, dictKey) || other.dictKey == dictKey)&&(identical(other.dictValue, dictValue) || other.dictValue == dictValue)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._extra, _extra)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dictType,dictKey,dictValue,description,const DeepCollectionEquality().hash(_extra),displayOrder,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'SystemDictionary(id: $id, dictType: $dictType, dictKey: $dictKey, dictValue: $dictValue, description: $description, extra: $extra, displayOrder: $displayOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SystemDictionaryCopyWith<$Res> implements $SystemDictionaryCopyWith<$Res> {
  factory _$SystemDictionaryCopyWith(_SystemDictionary value, $Res Function(_SystemDictionary) _then) = __$SystemDictionaryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'dict_type') String dictType,@JsonKey(name: 'dict_key') String dictKey,@JsonKey(name: 'dict_value') String dictValue, String? description, Map<String, dynamic>? extra,@JsonKey(name: 'display_order') int displayOrder,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$SystemDictionaryCopyWithImpl<$Res>
    implements _$SystemDictionaryCopyWith<$Res> {
  __$SystemDictionaryCopyWithImpl(this._self, this._then);

  final _SystemDictionary _self;
  final $Res Function(_SystemDictionary) _then;

/// Create a copy of SystemDictionary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dictType = null,Object? dictKey = null,Object? dictValue = null,Object? description = freezed,Object? extra = freezed,Object? displayOrder = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SystemDictionary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dictType: null == dictType ? _self.dictType : dictType // ignore: cast_nullable_to_non_nullable
as String,dictKey: null == dictKey ? _self.dictKey : dictKey // ignore: cast_nullable_to_non_nullable
as String,dictValue: null == dictValue ? _self.dictValue : dictValue // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,extra: freezed == extra ? _self._extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
