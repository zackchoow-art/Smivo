// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContentReport {

 String get id;@JsonKey(name: 'reporter_id') String get reporterId;@JsonKey(name: 'reported_user_id') String get reportedUserId;@JsonKey(name: 'listing_id') String? get listingId;@JsonKey(name: 'chat_room_id') String? get chatRoomId; String get reason; String get status;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'resolution_note') String? get resolutionNote;// Joined data for display
@JsonKey(name: 'reported_user') UserProfile? get reportedUser; Listing? get listing;
/// Create a copy of ContentReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentReportCopyWith<ContentReport> get copyWith => _$ContentReportCopyWithImpl<ContentReport>(this as ContentReport, _$identity);

  /// Serializes this ContentReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reporterId, reporterId) || other.reporterId == reporterId)&&(identical(other.reportedUserId, reportedUserId) || other.reportedUserId == reportedUserId)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.resolutionNote, resolutionNote) || other.resolutionNote == resolutionNote)&&(identical(other.reportedUser, reportedUser) || other.reportedUser == reportedUser)&&(identical(other.listing, listing) || other.listing == listing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reporterId,reportedUserId,listingId,chatRoomId,reason,status,createdAt,updatedAt,resolutionNote,reportedUser,listing);

@override
String toString() {
  return 'ContentReport(id: $id, reporterId: $reporterId, reportedUserId: $reportedUserId, listingId: $listingId, chatRoomId: $chatRoomId, reason: $reason, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, resolutionNote: $resolutionNote, reportedUser: $reportedUser, listing: $listing)';
}


}

/// @nodoc
abstract mixin class $ContentReportCopyWith<$Res>  {
  factory $ContentReportCopyWith(ContentReport value, $Res Function(ContentReport) _then) = _$ContentReportCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'reporter_id') String reporterId,@JsonKey(name: 'reported_user_id') String reportedUserId,@JsonKey(name: 'listing_id') String? listingId,@JsonKey(name: 'chat_room_id') String? chatRoomId, String reason, String status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'resolution_note') String? resolutionNote,@JsonKey(name: 'reported_user') UserProfile? reportedUser, Listing? listing
});


$UserProfileCopyWith<$Res>? get reportedUser;$ListingCopyWith<$Res>? get listing;

}
/// @nodoc
class _$ContentReportCopyWithImpl<$Res>
    implements $ContentReportCopyWith<$Res> {
  _$ContentReportCopyWithImpl(this._self, this._then);

  final ContentReport _self;
  final $Res Function(ContentReport) _then;

/// Create a copy of ContentReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reporterId = null,Object? reportedUserId = null,Object? listingId = freezed,Object? chatRoomId = freezed,Object? reason = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? resolutionNote = freezed,Object? reportedUser = freezed,Object? listing = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reporterId: null == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String,reportedUserId: null == reportedUserId ? _self.reportedUserId : reportedUserId // ignore: cast_nullable_to_non_nullable
as String,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String?,chatRoomId: freezed == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,resolutionNote: freezed == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String?,reportedUser: freezed == reportedUser ? _self.reportedUser : reportedUser // ignore: cast_nullable_to_non_nullable
as UserProfile?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as Listing?,
  ));
}
/// Create a copy of ContentReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get reportedUser {
    if (_self.reportedUser == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.reportedUser!, (value) {
    return _then(_self.copyWith(reportedUser: value));
  });
}/// Create a copy of ContentReport
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


/// Adds pattern-matching-related methods to [ContentReport].
extension ContentReportPatterns on ContentReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentReport value)  $default,){
final _that = this;
switch (_that) {
case _ContentReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentReport value)?  $default,){
final _that = this;
switch (_that) {
case _ContentReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'reporter_id')  String reporterId, @JsonKey(name: 'reported_user_id')  String reportedUserId, @JsonKey(name: 'listing_id')  String? listingId, @JsonKey(name: 'chat_room_id')  String? chatRoomId,  String reason,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'resolution_note')  String? resolutionNote, @JsonKey(name: 'reported_user')  UserProfile? reportedUser,  Listing? listing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentReport() when $default != null:
return $default(_that.id,_that.reporterId,_that.reportedUserId,_that.listingId,_that.chatRoomId,_that.reason,_that.status,_that.createdAt,_that.updatedAt,_that.resolutionNote,_that.reportedUser,_that.listing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'reporter_id')  String reporterId, @JsonKey(name: 'reported_user_id')  String reportedUserId, @JsonKey(name: 'listing_id')  String? listingId, @JsonKey(name: 'chat_room_id')  String? chatRoomId,  String reason,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'resolution_note')  String? resolutionNote, @JsonKey(name: 'reported_user')  UserProfile? reportedUser,  Listing? listing)  $default,) {final _that = this;
switch (_that) {
case _ContentReport():
return $default(_that.id,_that.reporterId,_that.reportedUserId,_that.listingId,_that.chatRoomId,_that.reason,_that.status,_that.createdAt,_that.updatedAt,_that.resolutionNote,_that.reportedUser,_that.listing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'reporter_id')  String reporterId, @JsonKey(name: 'reported_user_id')  String reportedUserId, @JsonKey(name: 'listing_id')  String? listingId, @JsonKey(name: 'chat_room_id')  String? chatRoomId,  String reason,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'resolution_note')  String? resolutionNote, @JsonKey(name: 'reported_user')  UserProfile? reportedUser,  Listing? listing)?  $default,) {final _that = this;
switch (_that) {
case _ContentReport() when $default != null:
return $default(_that.id,_that.reporterId,_that.reportedUserId,_that.listingId,_that.chatRoomId,_that.reason,_that.status,_that.createdAt,_that.updatedAt,_that.resolutionNote,_that.reportedUser,_that.listing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentReport implements ContentReport {
  const _ContentReport({required this.id, @JsonKey(name: 'reporter_id') required this.reporterId, @JsonKey(name: 'reported_user_id') required this.reportedUserId, @JsonKey(name: 'listing_id') this.listingId, @JsonKey(name: 'chat_room_id') this.chatRoomId, required this.reason, required this.status, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'resolution_note') this.resolutionNote, @JsonKey(name: 'reported_user') this.reportedUser, this.listing});
  factory _ContentReport.fromJson(Map<String, dynamic> json) => _$ContentReportFromJson(json);

@override final  String id;
@override@JsonKey(name: 'reporter_id') final  String reporterId;
@override@JsonKey(name: 'reported_user_id') final  String reportedUserId;
@override@JsonKey(name: 'listing_id') final  String? listingId;
@override@JsonKey(name: 'chat_room_id') final  String? chatRoomId;
@override final  String reason;
@override final  String status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'resolution_note') final  String? resolutionNote;
// Joined data for display
@override@JsonKey(name: 'reported_user') final  UserProfile? reportedUser;
@override final  Listing? listing;

/// Create a copy of ContentReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentReportCopyWith<_ContentReport> get copyWith => __$ContentReportCopyWithImpl<_ContentReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reporterId, reporterId) || other.reporterId == reporterId)&&(identical(other.reportedUserId, reportedUserId) || other.reportedUserId == reportedUserId)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.resolutionNote, resolutionNote) || other.resolutionNote == resolutionNote)&&(identical(other.reportedUser, reportedUser) || other.reportedUser == reportedUser)&&(identical(other.listing, listing) || other.listing == listing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reporterId,reportedUserId,listingId,chatRoomId,reason,status,createdAt,updatedAt,resolutionNote,reportedUser,listing);

@override
String toString() {
  return 'ContentReport(id: $id, reporterId: $reporterId, reportedUserId: $reportedUserId, listingId: $listingId, chatRoomId: $chatRoomId, reason: $reason, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, resolutionNote: $resolutionNote, reportedUser: $reportedUser, listing: $listing)';
}


}

/// @nodoc
abstract mixin class _$ContentReportCopyWith<$Res> implements $ContentReportCopyWith<$Res> {
  factory _$ContentReportCopyWith(_ContentReport value, $Res Function(_ContentReport) _then) = __$ContentReportCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'reporter_id') String reporterId,@JsonKey(name: 'reported_user_id') String reportedUserId,@JsonKey(name: 'listing_id') String? listingId,@JsonKey(name: 'chat_room_id') String? chatRoomId, String reason, String status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'resolution_note') String? resolutionNote,@JsonKey(name: 'reported_user') UserProfile? reportedUser, Listing? listing
});


@override $UserProfileCopyWith<$Res>? get reportedUser;@override $ListingCopyWith<$Res>? get listing;

}
/// @nodoc
class __$ContentReportCopyWithImpl<$Res>
    implements _$ContentReportCopyWith<$Res> {
  __$ContentReportCopyWithImpl(this._self, this._then);

  final _ContentReport _self;
  final $Res Function(_ContentReport) _then;

/// Create a copy of ContentReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reporterId = null,Object? reportedUserId = null,Object? listingId = freezed,Object? chatRoomId = freezed,Object? reason = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? resolutionNote = freezed,Object? reportedUser = freezed,Object? listing = freezed,}) {
  return _then(_ContentReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reporterId: null == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String,reportedUserId: null == reportedUserId ? _self.reportedUserId : reportedUserId // ignore: cast_nullable_to_non_nullable
as String,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String?,chatRoomId: freezed == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,resolutionNote: freezed == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String?,reportedUser: freezed == reportedUser ? _self.reportedUser : reportedUser // ignore: cast_nullable_to_non_nullable
as UserProfile?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as Listing?,
  ));
}

/// Create a copy of ContentReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get reportedUser {
    if (_self.reportedUser == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.reportedUser!, (value) {
    return _then(_self.copyWith(reportedUser: value));
  });
}/// Create a copy of ContentReport
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
