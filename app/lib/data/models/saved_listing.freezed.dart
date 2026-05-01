// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedListing {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'listing_id') String get listingId;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt; UserProfile? get user;@JsonKey(name: 'listing') Listing? get listing;
/// Create a copy of SavedListing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedListingCopyWith<SavedListing> get copyWith => _$SavedListingCopyWithImpl<SavedListing>(this as SavedListing, _$identity);

  /// Serializes this SavedListing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedListing&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.listing, listing) || other.listing == listing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,listingId,createdAt,updatedAt,user,listing);

@override
String toString() {
  return 'SavedListing(id: $id, userId: $userId, listingId: $listingId, createdAt: $createdAt, updatedAt: $updatedAt, user: $user, listing: $listing)';
}


}

/// @nodoc
abstract mixin class $SavedListingCopyWith<$Res>  {
  factory $SavedListingCopyWith(SavedListing value, $Res Function(SavedListing) _then) = _$SavedListingCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'listing_id') String listingId,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, UserProfile? user,@JsonKey(name: 'listing') Listing? listing
});


$UserProfileCopyWith<$Res>? get user;$ListingCopyWith<$Res>? get listing;

}
/// @nodoc
class _$SavedListingCopyWithImpl<$Res>
    implements $SavedListingCopyWith<$Res> {
  _$SavedListingCopyWithImpl(this._self, this._then);

  final SavedListing _self;
  final $Res Function(SavedListing) _then;

/// Create a copy of SavedListing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? listingId = null,Object? createdAt = null,Object? updatedAt = null,Object? user = freezed,Object? listing = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfile?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as Listing?,
  ));
}
/// Create a copy of SavedListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of SavedListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingCopyWith<$Res>? get listing {
    if (_self.listing == null) {
    return null;
  }

  return $ListingCopyWith<$Res>(_self.listing!, (value) {
    return _then(_self.copyWith(listing: value));
  });
}
}


/// Adds pattern-matching-related methods to [SavedListing].
extension SavedListingPatterns on SavedListing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedListing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedListing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedListing value)  $default,){
final _that = this;
switch (_that) {
case _SavedListing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedListing value)?  $default,){
final _that = this;
switch (_that) {
case _SavedListing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'listing_id')  String listingId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  UserProfile? user, @JsonKey(name: 'listing')  Listing? listing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedListing() when $default != null:
return $default(_that.id,_that.userId,_that.listingId,_that.createdAt,_that.updatedAt,_that.user,_that.listing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'listing_id')  String listingId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  UserProfile? user, @JsonKey(name: 'listing')  Listing? listing)  $default,) {final _that = this;
switch (_that) {
case _SavedListing():
return $default(_that.id,_that.userId,_that.listingId,_that.createdAt,_that.updatedAt,_that.user,_that.listing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'listing_id')  String listingId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  UserProfile? user, @JsonKey(name: 'listing')  Listing? listing)?  $default,) {final _that = this;
switch (_that) {
case _SavedListing() when $default != null:
return $default(_that.id,_that.userId,_that.listingId,_that.createdAt,_that.updatedAt,_that.user,_that.listing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedListing implements SavedListing {
  const _SavedListing({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'listing_id') required this.listingId, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.user, @JsonKey(name: 'listing') this.listing});
  factory _SavedListing.fromJson(Map<String, dynamic> json) => _$SavedListingFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'listing_id') final  String listingId;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override final  UserProfile? user;
@override@JsonKey(name: 'listing') final  Listing? listing;

/// Create a copy of SavedListing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedListingCopyWith<_SavedListing> get copyWith => __$SavedListingCopyWithImpl<_SavedListing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedListingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedListing&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.listing, listing) || other.listing == listing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,listingId,createdAt,updatedAt,user,listing);

@override
String toString() {
  return 'SavedListing(id: $id, userId: $userId, listingId: $listingId, createdAt: $createdAt, updatedAt: $updatedAt, user: $user, listing: $listing)';
}


}

/// @nodoc
abstract mixin class _$SavedListingCopyWith<$Res> implements $SavedListingCopyWith<$Res> {
  factory _$SavedListingCopyWith(_SavedListing value, $Res Function(_SavedListing) _then) = __$SavedListingCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'listing_id') String listingId,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, UserProfile? user,@JsonKey(name: 'listing') Listing? listing
});


@override $UserProfileCopyWith<$Res>? get user;@override $ListingCopyWith<$Res>? get listing;

}
/// @nodoc
class __$SavedListingCopyWithImpl<$Res>
    implements _$SavedListingCopyWith<$Res> {
  __$SavedListingCopyWithImpl(this._self, this._then);

  final _SavedListing _self;
  final $Res Function(_SavedListing) _then;

/// Create a copy of SavedListing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? listingId = null,Object? createdAt = null,Object? updatedAt = null,Object? user = freezed,Object? listing = freezed,}) {
  return _then(_SavedListing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfile?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as Listing?,
  ));
}

/// Create a copy of SavedListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of SavedListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingCopyWith<$Res>? get listing {
    if (_self.listing == null) {
    return null;
  }

  return $ListingCopyWith<$Res>(_self.listing!, (value) {
    return _then(_self.copyWith(listing: value));
  });
}
}

// dart format on
