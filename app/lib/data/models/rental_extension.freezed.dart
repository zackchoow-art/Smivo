// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rental_extension.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RentalExtension {

 String get id;@JsonKey(name: 'order_id') String get orderId;@JsonKey(name: 'requested_by') String get requestedBy;@JsonKey(name: 'request_type') String get requestType;@JsonKey(name: 'original_end_date') DateTime get originalEndDate;@JsonKey(name: 'new_end_date') DateTime get newEndDate;@JsonKey(name: 'price_diff') double get priceDiff;@JsonKey(name: 'new_total') double get newTotal; String get status;@JsonKey(name: 'responded_at') DateTime? get respondedAt;@JsonKey(name: 'rejection_note') String? get rejectionNote;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of RentalExtension
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RentalExtensionCopyWith<RentalExtension> get copyWith => _$RentalExtensionCopyWithImpl<RentalExtension>(this as RentalExtension, _$identity);

  /// Serializes this RentalExtension to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RentalExtension&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.originalEndDate, originalEndDate) || other.originalEndDate == originalEndDate)&&(identical(other.newEndDate, newEndDate) || other.newEndDate == newEndDate)&&(identical(other.priceDiff, priceDiff) || other.priceDiff == priceDiff)&&(identical(other.newTotal, newTotal) || other.newTotal == newTotal)&&(identical(other.status, status) || other.status == status)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.rejectionNote, rejectionNote) || other.rejectionNote == rejectionNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,requestedBy,requestType,originalEndDate,newEndDate,priceDiff,newTotal,status,respondedAt,rejectionNote,createdAt,updatedAt);

@override
String toString() {
  return 'RentalExtension(id: $id, orderId: $orderId, requestedBy: $requestedBy, requestType: $requestType, originalEndDate: $originalEndDate, newEndDate: $newEndDate, priceDiff: $priceDiff, newTotal: $newTotal, status: $status, respondedAt: $respondedAt, rejectionNote: $rejectionNote, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RentalExtensionCopyWith<$Res>  {
  factory $RentalExtensionCopyWith(RentalExtension value, $Res Function(RentalExtension) _then) = _$RentalExtensionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'requested_by') String requestedBy,@JsonKey(name: 'request_type') String requestType,@JsonKey(name: 'original_end_date') DateTime originalEndDate,@JsonKey(name: 'new_end_date') DateTime newEndDate,@JsonKey(name: 'price_diff') double priceDiff,@JsonKey(name: 'new_total') double newTotal, String status,@JsonKey(name: 'responded_at') DateTime? respondedAt,@JsonKey(name: 'rejection_note') String? rejectionNote,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$RentalExtensionCopyWithImpl<$Res>
    implements $RentalExtensionCopyWith<$Res> {
  _$RentalExtensionCopyWithImpl(this._self, this._then);

  final RentalExtension _self;
  final $Res Function(RentalExtension) _then;

/// Create a copy of RentalExtension
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? requestedBy = null,Object? requestType = null,Object? originalEndDate = null,Object? newEndDate = null,Object? priceDiff = null,Object? newTotal = null,Object? status = null,Object? respondedAt = freezed,Object? rejectionNote = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,requestedBy: null == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String,originalEndDate: null == originalEndDate ? _self.originalEndDate : originalEndDate // ignore: cast_nullable_to_non_nullable
as DateTime,newEndDate: null == newEndDate ? _self.newEndDate : newEndDate // ignore: cast_nullable_to_non_nullable
as DateTime,priceDiff: null == priceDiff ? _self.priceDiff : priceDiff // ignore: cast_nullable_to_non_nullable
as double,newTotal: null == newTotal ? _self.newTotal : newTotal // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectionNote: freezed == rejectionNote ? _self.rejectionNote : rejectionNote // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RentalExtension].
extension RentalExtensionPatterns on RentalExtension {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RentalExtension value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RentalExtension() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RentalExtension value)  $default,){
final _that = this;
switch (_that) {
case _RentalExtension():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RentalExtension value)?  $default,){
final _that = this;
switch (_that) {
case _RentalExtension() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'requested_by')  String requestedBy, @JsonKey(name: 'request_type')  String requestType, @JsonKey(name: 'original_end_date')  DateTime originalEndDate, @JsonKey(name: 'new_end_date')  DateTime newEndDate, @JsonKey(name: 'price_diff')  double priceDiff, @JsonKey(name: 'new_total')  double newTotal,  String status, @JsonKey(name: 'responded_at')  DateTime? respondedAt, @JsonKey(name: 'rejection_note')  String? rejectionNote, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RentalExtension() when $default != null:
return $default(_that.id,_that.orderId,_that.requestedBy,_that.requestType,_that.originalEndDate,_that.newEndDate,_that.priceDiff,_that.newTotal,_that.status,_that.respondedAt,_that.rejectionNote,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'requested_by')  String requestedBy, @JsonKey(name: 'request_type')  String requestType, @JsonKey(name: 'original_end_date')  DateTime originalEndDate, @JsonKey(name: 'new_end_date')  DateTime newEndDate, @JsonKey(name: 'price_diff')  double priceDiff, @JsonKey(name: 'new_total')  double newTotal,  String status, @JsonKey(name: 'responded_at')  DateTime? respondedAt, @JsonKey(name: 'rejection_note')  String? rejectionNote, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RentalExtension():
return $default(_that.id,_that.orderId,_that.requestedBy,_that.requestType,_that.originalEndDate,_that.newEndDate,_that.priceDiff,_that.newTotal,_that.status,_that.respondedAt,_that.rejectionNote,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'requested_by')  String requestedBy, @JsonKey(name: 'request_type')  String requestType, @JsonKey(name: 'original_end_date')  DateTime originalEndDate, @JsonKey(name: 'new_end_date')  DateTime newEndDate, @JsonKey(name: 'price_diff')  double priceDiff, @JsonKey(name: 'new_total')  double newTotal,  String status, @JsonKey(name: 'responded_at')  DateTime? respondedAt, @JsonKey(name: 'rejection_note')  String? rejectionNote, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RentalExtension() when $default != null:
return $default(_that.id,_that.orderId,_that.requestedBy,_that.requestType,_that.originalEndDate,_that.newEndDate,_that.priceDiff,_that.newTotal,_that.status,_that.respondedAt,_that.rejectionNote,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RentalExtension implements RentalExtension {
  const _RentalExtension({required this.id, @JsonKey(name: 'order_id') required this.orderId, @JsonKey(name: 'requested_by') required this.requestedBy, @JsonKey(name: 'request_type') required this.requestType, @JsonKey(name: 'original_end_date') required this.originalEndDate, @JsonKey(name: 'new_end_date') required this.newEndDate, @JsonKey(name: 'price_diff') this.priceDiff = 0.0, @JsonKey(name: 'new_total') required this.newTotal, this.status = 'pending', @JsonKey(name: 'responded_at') this.respondedAt, @JsonKey(name: 'rejection_note') this.rejectionNote, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _RentalExtension.fromJson(Map<String, dynamic> json) => _$RentalExtensionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'order_id') final  String orderId;
@override@JsonKey(name: 'requested_by') final  String requestedBy;
@override@JsonKey(name: 'request_type') final  String requestType;
@override@JsonKey(name: 'original_end_date') final  DateTime originalEndDate;
@override@JsonKey(name: 'new_end_date') final  DateTime newEndDate;
@override@JsonKey(name: 'price_diff') final  double priceDiff;
@override@JsonKey(name: 'new_total') final  double newTotal;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'responded_at') final  DateTime? respondedAt;
@override@JsonKey(name: 'rejection_note') final  String? rejectionNote;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of RentalExtension
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RentalExtensionCopyWith<_RentalExtension> get copyWith => __$RentalExtensionCopyWithImpl<_RentalExtension>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RentalExtensionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RentalExtension&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.originalEndDate, originalEndDate) || other.originalEndDate == originalEndDate)&&(identical(other.newEndDate, newEndDate) || other.newEndDate == newEndDate)&&(identical(other.priceDiff, priceDiff) || other.priceDiff == priceDiff)&&(identical(other.newTotal, newTotal) || other.newTotal == newTotal)&&(identical(other.status, status) || other.status == status)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.rejectionNote, rejectionNote) || other.rejectionNote == rejectionNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,requestedBy,requestType,originalEndDate,newEndDate,priceDiff,newTotal,status,respondedAt,rejectionNote,createdAt,updatedAt);

@override
String toString() {
  return 'RentalExtension(id: $id, orderId: $orderId, requestedBy: $requestedBy, requestType: $requestType, originalEndDate: $originalEndDate, newEndDate: $newEndDate, priceDiff: $priceDiff, newTotal: $newTotal, status: $status, respondedAt: $respondedAt, rejectionNote: $rejectionNote, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RentalExtensionCopyWith<$Res> implements $RentalExtensionCopyWith<$Res> {
  factory _$RentalExtensionCopyWith(_RentalExtension value, $Res Function(_RentalExtension) _then) = __$RentalExtensionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'requested_by') String requestedBy,@JsonKey(name: 'request_type') String requestType,@JsonKey(name: 'original_end_date') DateTime originalEndDate,@JsonKey(name: 'new_end_date') DateTime newEndDate,@JsonKey(name: 'price_diff') double priceDiff,@JsonKey(name: 'new_total') double newTotal, String status,@JsonKey(name: 'responded_at') DateTime? respondedAt,@JsonKey(name: 'rejection_note') String? rejectionNote,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$RentalExtensionCopyWithImpl<$Res>
    implements _$RentalExtensionCopyWith<$Res> {
  __$RentalExtensionCopyWithImpl(this._self, this._then);

  final _RentalExtension _self;
  final $Res Function(_RentalExtension) _then;

/// Create a copy of RentalExtension
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? requestedBy = null,Object? requestType = null,Object? originalEndDate = null,Object? newEndDate = null,Object? priceDiff = null,Object? newTotal = null,Object? status = null,Object? respondedAt = freezed,Object? rejectionNote = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_RentalExtension(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,requestedBy: null == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String,originalEndDate: null == originalEndDate ? _self.originalEndDate : originalEndDate // ignore: cast_nullable_to_non_nullable
as DateTime,newEndDate: null == newEndDate ? _self.newEndDate : newEndDate // ignore: cast_nullable_to_non_nullable
as DateTime,priceDiff: null == priceDiff ? _self.priceDiff : priceDiff // ignore: cast_nullable_to_non_nullable
as double,newTotal: null == newTotal ? _self.newTotal : newTotal // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectionNote: freezed == rejectionNote ? _self.rejectionNote : rejectionNote // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
