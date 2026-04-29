// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserReview {

 String get id;@JsonKey(name: 'order_id') String get orderId;@JsonKey(name: 'reviewer_id') String get reviewerId;@JsonKey(name: 'target_user_id') String get targetUserId; String get role;// 'buyer' or 'seller' (the role of the target user)
 int get rating; String? get comment;@JsonKey(name: 'created_at') DateTime get createdAt;// Nested join data
 UserProfile? get reviewer;@JsonKey(name: 'tags') List<ReviewTag> get tags;
/// Create a copy of UserReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserReviewCopyWith<UserReview> get copyWith => _$UserReviewCopyWithImpl<UserReview>(this as UserReview, _$identity);

  /// Serializes this UserReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserReview&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.role, role) || other.role == role)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewer, reviewer) || other.reviewer == reviewer)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,reviewerId,targetUserId,role,rating,comment,createdAt,reviewer,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'UserReview(id: $id, orderId: $orderId, reviewerId: $reviewerId, targetUserId: $targetUserId, role: $role, rating: $rating, comment: $comment, createdAt: $createdAt, reviewer: $reviewer, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $UserReviewCopyWith<$Res>  {
  factory $UserReviewCopyWith(UserReview value, $Res Function(UserReview) _then) = _$UserReviewCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'reviewer_id') String reviewerId,@JsonKey(name: 'target_user_id') String targetUserId, String role, int rating, String? comment,@JsonKey(name: 'created_at') DateTime createdAt, UserProfile? reviewer,@JsonKey(name: 'tags') List<ReviewTag> tags
});


$UserProfileCopyWith<$Res>? get reviewer;

}
/// @nodoc
class _$UserReviewCopyWithImpl<$Res>
    implements $UserReviewCopyWith<$Res> {
  _$UserReviewCopyWithImpl(this._self, this._then);

  final UserReview _self;
  final $Res Function(UserReview) _then;

/// Create a copy of UserReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? reviewerId = null,Object? targetUserId = null,Object? role = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? reviewer = freezed,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewer: freezed == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as UserProfile?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<ReviewTag>,
  ));
}
/// Create a copy of UserReview
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
}
}


/// Adds pattern-matching-related methods to [UserReview].
extension UserReviewPatterns on UserReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserReview value)  $default,){
final _that = this;
switch (_that) {
case _UserReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserReview value)?  $default,){
final _that = this;
switch (_that) {
case _UserReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'reviewer_id')  String reviewerId, @JsonKey(name: 'target_user_id')  String targetUserId,  String role,  int rating,  String? comment, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? reviewer, @JsonKey(name: 'tags')  List<ReviewTag> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserReview() when $default != null:
return $default(_that.id,_that.orderId,_that.reviewerId,_that.targetUserId,_that.role,_that.rating,_that.comment,_that.createdAt,_that.reviewer,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'reviewer_id')  String reviewerId, @JsonKey(name: 'target_user_id')  String targetUserId,  String role,  int rating,  String? comment, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? reviewer, @JsonKey(name: 'tags')  List<ReviewTag> tags)  $default,) {final _that = this;
switch (_that) {
case _UserReview():
return $default(_that.id,_that.orderId,_that.reviewerId,_that.targetUserId,_that.role,_that.rating,_that.comment,_that.createdAt,_that.reviewer,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'reviewer_id')  String reviewerId, @JsonKey(name: 'target_user_id')  String targetUserId,  String role,  int rating,  String? comment, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? reviewer, @JsonKey(name: 'tags')  List<ReviewTag> tags)?  $default,) {final _that = this;
switch (_that) {
case _UserReview() when $default != null:
return $default(_that.id,_that.orderId,_that.reviewerId,_that.targetUserId,_that.role,_that.rating,_that.comment,_that.createdAt,_that.reviewer,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserReview extends UserReview {
  const _UserReview({required this.id, @JsonKey(name: 'order_id') required this.orderId, @JsonKey(name: 'reviewer_id') required this.reviewerId, @JsonKey(name: 'target_user_id') required this.targetUserId, required this.role, required this.rating, this.comment, @JsonKey(name: 'created_at') required this.createdAt, this.reviewer, @JsonKey(name: 'tags') final  List<ReviewTag> tags = const []}): _tags = tags,super._();
  factory _UserReview.fromJson(Map<String, dynamic> json) => _$UserReviewFromJson(json);

@override final  String id;
@override@JsonKey(name: 'order_id') final  String orderId;
@override@JsonKey(name: 'reviewer_id') final  String reviewerId;
@override@JsonKey(name: 'target_user_id') final  String targetUserId;
@override final  String role;
// 'buyer' or 'seller' (the role of the target user)
@override final  int rating;
@override final  String? comment;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
// Nested join data
@override final  UserProfile? reviewer;
 final  List<ReviewTag> _tags;
@override@JsonKey(name: 'tags') List<ReviewTag> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of UserReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserReviewCopyWith<_UserReview> get copyWith => __$UserReviewCopyWithImpl<_UserReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserReview&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.role, role) || other.role == role)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewer, reviewer) || other.reviewer == reviewer)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,reviewerId,targetUserId,role,rating,comment,createdAt,reviewer,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'UserReview(id: $id, orderId: $orderId, reviewerId: $reviewerId, targetUserId: $targetUserId, role: $role, rating: $rating, comment: $comment, createdAt: $createdAt, reviewer: $reviewer, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$UserReviewCopyWith<$Res> implements $UserReviewCopyWith<$Res> {
  factory _$UserReviewCopyWith(_UserReview value, $Res Function(_UserReview) _then) = __$UserReviewCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'reviewer_id') String reviewerId,@JsonKey(name: 'target_user_id') String targetUserId, String role, int rating, String? comment,@JsonKey(name: 'created_at') DateTime createdAt, UserProfile? reviewer,@JsonKey(name: 'tags') List<ReviewTag> tags
});


@override $UserProfileCopyWith<$Res>? get reviewer;

}
/// @nodoc
class __$UserReviewCopyWithImpl<$Res>
    implements _$UserReviewCopyWith<$Res> {
  __$UserReviewCopyWithImpl(this._self, this._then);

  final _UserReview _self;
  final $Res Function(_UserReview) _then;

/// Create a copy of UserReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? reviewerId = null,Object? targetUserId = null,Object? role = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? reviewer = freezed,Object? tags = null,}) {
  return _then(_UserReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewer: freezed == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as UserProfile?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<ReviewTag>,
  ));
}

/// Create a copy of UserReview
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
}
}

// dart format on
