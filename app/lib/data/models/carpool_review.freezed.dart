// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carpool_review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CarpoolReview {

 String get id;@JsonKey(name: 'trip_id') String get tripId;@JsonKey(name: 'reviewer_id') String get reviewerId;@JsonKey(name: 'reviewee_id') String get revieweeId;// NOTE: DB CHECK constraint enforces rating between 1 and 5.
 int get rating; String? get comment;@JsonKey(name: 'created_at') DateTime get createdAt;// Nested join — populated only by specific join queries
 UserProfile? get reviewer; UserProfile? get reviewee;
/// Create a copy of CarpoolReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarpoolReviewCopyWith<CarpoolReview> get copyWith => _$CarpoolReviewCopyWithImpl<CarpoolReview>(this as CarpoolReview, _$identity);

  /// Serializes this CarpoolReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarpoolReview&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.revieweeId, revieweeId) || other.revieweeId == revieweeId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewer, reviewer) || other.reviewer == reviewer)&&(identical(other.reviewee, reviewee) || other.reviewee == reviewee));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,reviewerId,revieweeId,rating,comment,createdAt,reviewer,reviewee);

@override
String toString() {
  return 'CarpoolReview(id: $id, tripId: $tripId, reviewerId: $reviewerId, revieweeId: $revieweeId, rating: $rating, comment: $comment, createdAt: $createdAt, reviewer: $reviewer, reviewee: $reviewee)';
}


}

/// @nodoc
abstract mixin class $CarpoolReviewCopyWith<$Res>  {
  factory $CarpoolReviewCopyWith(CarpoolReview value, $Res Function(CarpoolReview) _then) = _$CarpoolReviewCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'trip_id') String tripId,@JsonKey(name: 'reviewer_id') String reviewerId,@JsonKey(name: 'reviewee_id') String revieweeId, int rating, String? comment,@JsonKey(name: 'created_at') DateTime createdAt, UserProfile? reviewer, UserProfile? reviewee
});


$UserProfileCopyWith<$Res>? get reviewer;$UserProfileCopyWith<$Res>? get reviewee;

}
/// @nodoc
class _$CarpoolReviewCopyWithImpl<$Res>
    implements $CarpoolReviewCopyWith<$Res> {
  _$CarpoolReviewCopyWithImpl(this._self, this._then);

  final CarpoolReview _self;
  final $Res Function(CarpoolReview) _then;

/// Create a copy of CarpoolReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tripId = null,Object? reviewerId = null,Object? revieweeId = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? reviewer = freezed,Object? reviewee = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewer: freezed == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as UserProfile?,reviewee: freezed == reviewee ? _self.reviewee : reviewee // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}
/// Create a copy of CarpoolReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get reviewer {
    if (_self.reviewer == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.reviewer!, (value) {
    return _then(_self.copyWith(reviewer: value));
  });
}/// Create a copy of CarpoolReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get reviewee {
    if (_self.reviewee == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.reviewee!, (value) {
    return _then(_self.copyWith(reviewee: value));
  });
}
}


/// Adds pattern-matching-related methods to [CarpoolReview].
extension CarpoolReviewPatterns on CarpoolReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarpoolReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarpoolReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarpoolReview value)  $default,){
final _that = this;
switch (_that) {
case _CarpoolReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarpoolReview value)?  $default,){
final _that = this;
switch (_that) {
case _CarpoolReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trip_id')  String tripId, @JsonKey(name: 'reviewer_id')  String reviewerId, @JsonKey(name: 'reviewee_id')  String revieweeId,  int rating,  String? comment, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? reviewer,  UserProfile? reviewee)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarpoolReview() when $default != null:
return $default(_that.id,_that.tripId,_that.reviewerId,_that.revieweeId,_that.rating,_that.comment,_that.createdAt,_that.reviewer,_that.reviewee);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trip_id')  String tripId, @JsonKey(name: 'reviewer_id')  String reviewerId, @JsonKey(name: 'reviewee_id')  String revieweeId,  int rating,  String? comment, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? reviewer,  UserProfile? reviewee)  $default,) {final _that = this;
switch (_that) {
case _CarpoolReview():
return $default(_that.id,_that.tripId,_that.reviewerId,_that.revieweeId,_that.rating,_that.comment,_that.createdAt,_that.reviewer,_that.reviewee);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'trip_id')  String tripId, @JsonKey(name: 'reviewer_id')  String reviewerId, @JsonKey(name: 'reviewee_id')  String revieweeId,  int rating,  String? comment, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? reviewer,  UserProfile? reviewee)?  $default,) {final _that = this;
switch (_that) {
case _CarpoolReview() when $default != null:
return $default(_that.id,_that.tripId,_that.reviewerId,_that.revieweeId,_that.rating,_that.comment,_that.createdAt,_that.reviewer,_that.reviewee);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CarpoolReview implements CarpoolReview {
  const _CarpoolReview({required this.id, @JsonKey(name: 'trip_id') required this.tripId, @JsonKey(name: 'reviewer_id') required this.reviewerId, @JsonKey(name: 'reviewee_id') required this.revieweeId, required this.rating, this.comment, @JsonKey(name: 'created_at') required this.createdAt, this.reviewer, this.reviewee});
  factory _CarpoolReview.fromJson(Map<String, dynamic> json) => _$CarpoolReviewFromJson(json);

@override final  String id;
@override@JsonKey(name: 'trip_id') final  String tripId;
@override@JsonKey(name: 'reviewer_id') final  String reviewerId;
@override@JsonKey(name: 'reviewee_id') final  String revieweeId;
// NOTE: DB CHECK constraint enforces rating between 1 and 5.
@override final  int rating;
@override final  String? comment;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
// Nested join — populated only by specific join queries
@override final  UserProfile? reviewer;
@override final  UserProfile? reviewee;

/// Create a copy of CarpoolReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarpoolReviewCopyWith<_CarpoolReview> get copyWith => __$CarpoolReviewCopyWithImpl<_CarpoolReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarpoolReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarpoolReview&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.revieweeId, revieweeId) || other.revieweeId == revieweeId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewer, reviewer) || other.reviewer == reviewer)&&(identical(other.reviewee, reviewee) || other.reviewee == reviewee));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,reviewerId,revieweeId,rating,comment,createdAt,reviewer,reviewee);

@override
String toString() {
  return 'CarpoolReview(id: $id, tripId: $tripId, reviewerId: $reviewerId, revieweeId: $revieweeId, rating: $rating, comment: $comment, createdAt: $createdAt, reviewer: $reviewer, reviewee: $reviewee)';
}


}

/// @nodoc
abstract mixin class _$CarpoolReviewCopyWith<$Res> implements $CarpoolReviewCopyWith<$Res> {
  factory _$CarpoolReviewCopyWith(_CarpoolReview value, $Res Function(_CarpoolReview) _then) = __$CarpoolReviewCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'trip_id') String tripId,@JsonKey(name: 'reviewer_id') String reviewerId,@JsonKey(name: 'reviewee_id') String revieweeId, int rating, String? comment,@JsonKey(name: 'created_at') DateTime createdAt, UserProfile? reviewer, UserProfile? reviewee
});


@override $UserProfileCopyWith<$Res>? get reviewer;@override $UserProfileCopyWith<$Res>? get reviewee;

}
/// @nodoc
class __$CarpoolReviewCopyWithImpl<$Res>
    implements _$CarpoolReviewCopyWith<$Res> {
  __$CarpoolReviewCopyWithImpl(this._self, this._then);

  final _CarpoolReview _self;
  final $Res Function(_CarpoolReview) _then;

/// Create a copy of CarpoolReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tripId = null,Object? reviewerId = null,Object? revieweeId = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? reviewer = freezed,Object? reviewee = freezed,}) {
  return _then(_CarpoolReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewer: freezed == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as UserProfile?,reviewee: freezed == reviewee ? _self.reviewee : reviewee // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}

/// Create a copy of CarpoolReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get reviewer {
    if (_self.reviewer == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.reviewer!, (value) {
    return _then(_self.copyWith(reviewer: value));
  });
}/// Create a copy of CarpoolReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get reviewee {
    if (_self.reviewee == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.reviewee!, (value) {
    return _then(_self.copyWith(reviewee: value));
  });
}
}

// dart format on
