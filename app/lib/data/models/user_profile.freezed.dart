// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get id; String get email;@JsonKey(name: 'display_name') String? get displayName;@JsonKey(name: 'avatar_url') String? get avatarUrl; String get school;@JsonKey(name: 'school_id') String get schoolId;@JsonKey(name: 'is_verified') bool get isVerified;// Nested join — populated when querying with school join
 School? get schoolData;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;// User preference for receiving email notifications
@JsonKey(name: 'email_notifications_enabled') bool get emailNotificationsEnabled;// OneSignal device token for push notifications
@JsonKey(name: 'onesignal_player_id') String? get onesignalPlayerId;// Master push notification toggle
@JsonKey(name: 'push_notifications_enabled') bool get pushNotificationsEnabled;// -- Messages --
@JsonKey(name: 'push_messages') bool get pushMessages;@JsonKey(name: 'email_messages') bool get emailMessages;// -- Order Updates --
@JsonKey(name: 'push_order_updates') bool get pushOrderUpdates;@JsonKey(name: 'email_order_updates') bool get emailOrderUpdates;// -- Campus Announcements --
@JsonKey(name: 'push_campus_announcements') bool get pushCampusAnnouncements;@JsonKey(name: 'email_campus_announcements') bool get emailCampusAnnouncements;// -- Platform Announcements --
@JsonKey(name: 'push_announcements') bool get pushAnnouncements;@JsonKey(name: 'email_announcements') bool get emailAnnouncements;// -- Ratings --
@JsonKey(name: 'buyer_rating') double get buyerRating;@JsonKey(name: 'buyer_rating_count') int get buyerRatingCount;@JsonKey(name: 'seller_rating') double get sellerRating;@JsonKey(name: 'seller_rating_count') int get sellerRatingCount;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.school, school) || other.school == school)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.schoolData, schoolData) || other.schoolData == schoolData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.emailNotificationsEnabled, emailNotificationsEnabled) || other.emailNotificationsEnabled == emailNotificationsEnabled)&&(identical(other.onesignalPlayerId, onesignalPlayerId) || other.onesignalPlayerId == onesignalPlayerId)&&(identical(other.pushNotificationsEnabled, pushNotificationsEnabled) || other.pushNotificationsEnabled == pushNotificationsEnabled)&&(identical(other.pushMessages, pushMessages) || other.pushMessages == pushMessages)&&(identical(other.emailMessages, emailMessages) || other.emailMessages == emailMessages)&&(identical(other.pushOrderUpdates, pushOrderUpdates) || other.pushOrderUpdates == pushOrderUpdates)&&(identical(other.emailOrderUpdates, emailOrderUpdates) || other.emailOrderUpdates == emailOrderUpdates)&&(identical(other.pushCampusAnnouncements, pushCampusAnnouncements) || other.pushCampusAnnouncements == pushCampusAnnouncements)&&(identical(other.emailCampusAnnouncements, emailCampusAnnouncements) || other.emailCampusAnnouncements == emailCampusAnnouncements)&&(identical(other.pushAnnouncements, pushAnnouncements) || other.pushAnnouncements == pushAnnouncements)&&(identical(other.emailAnnouncements, emailAnnouncements) || other.emailAnnouncements == emailAnnouncements)&&(identical(other.buyerRating, buyerRating) || other.buyerRating == buyerRating)&&(identical(other.buyerRatingCount, buyerRatingCount) || other.buyerRatingCount == buyerRatingCount)&&(identical(other.sellerRating, sellerRating) || other.sellerRating == sellerRating)&&(identical(other.sellerRatingCount, sellerRatingCount) || other.sellerRatingCount == sellerRatingCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,email,displayName,avatarUrl,school,schoolId,isVerified,schoolData,createdAt,updatedAt,emailNotificationsEnabled,onesignalPlayerId,pushNotificationsEnabled,pushMessages,emailMessages,pushOrderUpdates,emailOrderUpdates,pushCampusAnnouncements,emailCampusAnnouncements,pushAnnouncements,emailAnnouncements,buyerRating,buyerRatingCount,sellerRating,sellerRatingCount]);

@override
String toString() {
  return 'UserProfile(id: $id, email: $email, displayName: $displayName, avatarUrl: $avatarUrl, school: $school, schoolId: $schoolId, isVerified: $isVerified, schoolData: $schoolData, createdAt: $createdAt, updatedAt: $updatedAt, emailNotificationsEnabled: $emailNotificationsEnabled, onesignalPlayerId: $onesignalPlayerId, pushNotificationsEnabled: $pushNotificationsEnabled, pushMessages: $pushMessages, emailMessages: $emailMessages, pushOrderUpdates: $pushOrderUpdates, emailOrderUpdates: $emailOrderUpdates, pushCampusAnnouncements: $pushCampusAnnouncements, emailCampusAnnouncements: $emailCampusAnnouncements, pushAnnouncements: $pushAnnouncements, emailAnnouncements: $emailAnnouncements, buyerRating: $buyerRating, buyerRatingCount: $buyerRatingCount, sellerRating: $sellerRating, sellerRatingCount: $sellerRatingCount)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String id, String email,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl, String school,@JsonKey(name: 'school_id') String schoolId,@JsonKey(name: 'is_verified') bool isVerified, School? schoolData,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'email_notifications_enabled') bool emailNotificationsEnabled,@JsonKey(name: 'onesignal_player_id') String? onesignalPlayerId,@JsonKey(name: 'push_notifications_enabled') bool pushNotificationsEnabled,@JsonKey(name: 'push_messages') bool pushMessages,@JsonKey(name: 'email_messages') bool emailMessages,@JsonKey(name: 'push_order_updates') bool pushOrderUpdates,@JsonKey(name: 'email_order_updates') bool emailOrderUpdates,@JsonKey(name: 'push_campus_announcements') bool pushCampusAnnouncements,@JsonKey(name: 'email_campus_announcements') bool emailCampusAnnouncements,@JsonKey(name: 'push_announcements') bool pushAnnouncements,@JsonKey(name: 'email_announcements') bool emailAnnouncements,@JsonKey(name: 'buyer_rating') double buyerRating,@JsonKey(name: 'buyer_rating_count') int buyerRatingCount,@JsonKey(name: 'seller_rating') double sellerRating,@JsonKey(name: 'seller_rating_count') int sellerRatingCount
});


$SchoolCopyWith<$Res>? get schoolData;

}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? school = null,Object? schoolId = null,Object? isVerified = null,Object? schoolData = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? emailNotificationsEnabled = null,Object? onesignalPlayerId = freezed,Object? pushNotificationsEnabled = null,Object? pushMessages = null,Object? emailMessages = null,Object? pushOrderUpdates = null,Object? emailOrderUpdates = null,Object? pushCampusAnnouncements = null,Object? emailCampusAnnouncements = null,Object? pushAnnouncements = null,Object? emailAnnouncements = null,Object? buyerRating = null,Object? buyerRatingCount = null,Object? sellerRating = null,Object? sellerRatingCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,schoolData: freezed == schoolData ? _self.schoolData : schoolData // ignore: cast_nullable_to_non_nullable
as School?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,emailNotificationsEnabled: null == emailNotificationsEnabled ? _self.emailNotificationsEnabled : emailNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,onesignalPlayerId: freezed == onesignalPlayerId ? _self.onesignalPlayerId : onesignalPlayerId // ignore: cast_nullable_to_non_nullable
as String?,pushNotificationsEnabled: null == pushNotificationsEnabled ? _self.pushNotificationsEnabled : pushNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,pushMessages: null == pushMessages ? _self.pushMessages : pushMessages // ignore: cast_nullable_to_non_nullable
as bool,emailMessages: null == emailMessages ? _self.emailMessages : emailMessages // ignore: cast_nullable_to_non_nullable
as bool,pushOrderUpdates: null == pushOrderUpdates ? _self.pushOrderUpdates : pushOrderUpdates // ignore: cast_nullable_to_non_nullable
as bool,emailOrderUpdates: null == emailOrderUpdates ? _self.emailOrderUpdates : emailOrderUpdates // ignore: cast_nullable_to_non_nullable
as bool,pushCampusAnnouncements: null == pushCampusAnnouncements ? _self.pushCampusAnnouncements : pushCampusAnnouncements // ignore: cast_nullable_to_non_nullable
as bool,emailCampusAnnouncements: null == emailCampusAnnouncements ? _self.emailCampusAnnouncements : emailCampusAnnouncements // ignore: cast_nullable_to_non_nullable
as bool,pushAnnouncements: null == pushAnnouncements ? _self.pushAnnouncements : pushAnnouncements // ignore: cast_nullable_to_non_nullable
as bool,emailAnnouncements: null == emailAnnouncements ? _self.emailAnnouncements : emailAnnouncements // ignore: cast_nullable_to_non_nullable
as bool,buyerRating: null == buyerRating ? _self.buyerRating : buyerRating // ignore: cast_nullable_to_non_nullable
as double,buyerRatingCount: null == buyerRatingCount ? _self.buyerRatingCount : buyerRatingCount // ignore: cast_nullable_to_non_nullable
as int,sellerRating: null == sellerRating ? _self.sellerRating : sellerRating // ignore: cast_nullable_to_non_nullable
as double,sellerRatingCount: null == sellerRatingCount ? _self.sellerRatingCount : sellerRatingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SchoolCopyWith<$Res>? get schoolData {
    if (_self.schoolData == null) {
    return null;
  }

  return $SchoolCopyWith<$Res>(_self.schoolData!, (value) {
    return _then(_self.copyWith(schoolData: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String school, @JsonKey(name: 'school_id')  String schoolId, @JsonKey(name: 'is_verified')  bool isVerified,  School? schoolData, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'email_notifications_enabled')  bool emailNotificationsEnabled, @JsonKey(name: 'onesignal_player_id')  String? onesignalPlayerId, @JsonKey(name: 'push_notifications_enabled')  bool pushNotificationsEnabled, @JsonKey(name: 'push_messages')  bool pushMessages, @JsonKey(name: 'email_messages')  bool emailMessages, @JsonKey(name: 'push_order_updates')  bool pushOrderUpdates, @JsonKey(name: 'email_order_updates')  bool emailOrderUpdates, @JsonKey(name: 'push_campus_announcements')  bool pushCampusAnnouncements, @JsonKey(name: 'email_campus_announcements')  bool emailCampusAnnouncements, @JsonKey(name: 'push_announcements')  bool pushAnnouncements, @JsonKey(name: 'email_announcements')  bool emailAnnouncements, @JsonKey(name: 'buyer_rating')  double buyerRating, @JsonKey(name: 'buyer_rating_count')  int buyerRatingCount, @JsonKey(name: 'seller_rating')  double sellerRating, @JsonKey(name: 'seller_rating_count')  int sellerRatingCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.email,_that.displayName,_that.avatarUrl,_that.school,_that.schoolId,_that.isVerified,_that.schoolData,_that.createdAt,_that.updatedAt,_that.emailNotificationsEnabled,_that.onesignalPlayerId,_that.pushNotificationsEnabled,_that.pushMessages,_that.emailMessages,_that.pushOrderUpdates,_that.emailOrderUpdates,_that.pushCampusAnnouncements,_that.emailCampusAnnouncements,_that.pushAnnouncements,_that.emailAnnouncements,_that.buyerRating,_that.buyerRatingCount,_that.sellerRating,_that.sellerRatingCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String school, @JsonKey(name: 'school_id')  String schoolId, @JsonKey(name: 'is_verified')  bool isVerified,  School? schoolData, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'email_notifications_enabled')  bool emailNotificationsEnabled, @JsonKey(name: 'onesignal_player_id')  String? onesignalPlayerId, @JsonKey(name: 'push_notifications_enabled')  bool pushNotificationsEnabled, @JsonKey(name: 'push_messages')  bool pushMessages, @JsonKey(name: 'email_messages')  bool emailMessages, @JsonKey(name: 'push_order_updates')  bool pushOrderUpdates, @JsonKey(name: 'email_order_updates')  bool emailOrderUpdates, @JsonKey(name: 'push_campus_announcements')  bool pushCampusAnnouncements, @JsonKey(name: 'email_campus_announcements')  bool emailCampusAnnouncements, @JsonKey(name: 'push_announcements')  bool pushAnnouncements, @JsonKey(name: 'email_announcements')  bool emailAnnouncements, @JsonKey(name: 'buyer_rating')  double buyerRating, @JsonKey(name: 'buyer_rating_count')  int buyerRatingCount, @JsonKey(name: 'seller_rating')  double sellerRating, @JsonKey(name: 'seller_rating_count')  int sellerRatingCount)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.email,_that.displayName,_that.avatarUrl,_that.school,_that.schoolId,_that.isVerified,_that.schoolData,_that.createdAt,_that.updatedAt,_that.emailNotificationsEnabled,_that.onesignalPlayerId,_that.pushNotificationsEnabled,_that.pushMessages,_that.emailMessages,_that.pushOrderUpdates,_that.emailOrderUpdates,_that.pushCampusAnnouncements,_that.emailCampusAnnouncements,_that.pushAnnouncements,_that.emailAnnouncements,_that.buyerRating,_that.buyerRatingCount,_that.sellerRating,_that.sellerRatingCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String school, @JsonKey(name: 'school_id')  String schoolId, @JsonKey(name: 'is_verified')  bool isVerified,  School? schoolData, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'email_notifications_enabled')  bool emailNotificationsEnabled, @JsonKey(name: 'onesignal_player_id')  String? onesignalPlayerId, @JsonKey(name: 'push_notifications_enabled')  bool pushNotificationsEnabled, @JsonKey(name: 'push_messages')  bool pushMessages, @JsonKey(name: 'email_messages')  bool emailMessages, @JsonKey(name: 'push_order_updates')  bool pushOrderUpdates, @JsonKey(name: 'email_order_updates')  bool emailOrderUpdates, @JsonKey(name: 'push_campus_announcements')  bool pushCampusAnnouncements, @JsonKey(name: 'email_campus_announcements')  bool emailCampusAnnouncements, @JsonKey(name: 'push_announcements')  bool pushAnnouncements, @JsonKey(name: 'email_announcements')  bool emailAnnouncements, @JsonKey(name: 'buyer_rating')  double buyerRating, @JsonKey(name: 'buyer_rating_count')  int buyerRatingCount, @JsonKey(name: 'seller_rating')  double sellerRating, @JsonKey(name: 'seller_rating_count')  int sellerRatingCount)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.email,_that.displayName,_that.avatarUrl,_that.school,_that.schoolId,_that.isVerified,_that.schoolData,_that.createdAt,_that.updatedAt,_that.emailNotificationsEnabled,_that.onesignalPlayerId,_that.pushNotificationsEnabled,_that.pushMessages,_that.emailMessages,_that.pushOrderUpdates,_that.emailOrderUpdates,_that.pushCampusAnnouncements,_that.emailCampusAnnouncements,_that.pushAnnouncements,_that.emailAnnouncements,_that.buyerRating,_that.buyerRatingCount,_that.sellerRating,_that.sellerRatingCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.id, required this.email, @JsonKey(name: 'display_name') this.displayName, @JsonKey(name: 'avatar_url') this.avatarUrl, this.school = 'Smith College', @JsonKey(name: 'school_id') required this.schoolId, @JsonKey(name: 'is_verified') this.isVerified = false, this.schoolData, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'email_notifications_enabled') this.emailNotificationsEnabled = false, @JsonKey(name: 'onesignal_player_id') this.onesignalPlayerId, @JsonKey(name: 'push_notifications_enabled') this.pushNotificationsEnabled = true, @JsonKey(name: 'push_messages') this.pushMessages = true, @JsonKey(name: 'email_messages') this.emailMessages = false, @JsonKey(name: 'push_order_updates') this.pushOrderUpdates = true, @JsonKey(name: 'email_order_updates') this.emailOrderUpdates = false, @JsonKey(name: 'push_campus_announcements') this.pushCampusAnnouncements = true, @JsonKey(name: 'email_campus_announcements') this.emailCampusAnnouncements = false, @JsonKey(name: 'push_announcements') this.pushAnnouncements = true, @JsonKey(name: 'email_announcements') this.emailAnnouncements = false, @JsonKey(name: 'buyer_rating') this.buyerRating = 0.0, @JsonKey(name: 'buyer_rating_count') this.buyerRatingCount = 0, @JsonKey(name: 'seller_rating') this.sellerRating = 0.0, @JsonKey(name: 'seller_rating_count') this.sellerRatingCount = 0});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String id;
@override final  String email;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey() final  String school;
@override@JsonKey(name: 'school_id') final  String schoolId;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
// Nested join — populated when querying with school join
@override final  School? schoolData;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
// User preference for receiving email notifications
@override@JsonKey(name: 'email_notifications_enabled') final  bool emailNotificationsEnabled;
// OneSignal device token for push notifications
@override@JsonKey(name: 'onesignal_player_id') final  String? onesignalPlayerId;
// Master push notification toggle
@override@JsonKey(name: 'push_notifications_enabled') final  bool pushNotificationsEnabled;
// -- Messages --
@override@JsonKey(name: 'push_messages') final  bool pushMessages;
@override@JsonKey(name: 'email_messages') final  bool emailMessages;
// -- Order Updates --
@override@JsonKey(name: 'push_order_updates') final  bool pushOrderUpdates;
@override@JsonKey(name: 'email_order_updates') final  bool emailOrderUpdates;
// -- Campus Announcements --
@override@JsonKey(name: 'push_campus_announcements') final  bool pushCampusAnnouncements;
@override@JsonKey(name: 'email_campus_announcements') final  bool emailCampusAnnouncements;
// -- Platform Announcements --
@override@JsonKey(name: 'push_announcements') final  bool pushAnnouncements;
@override@JsonKey(name: 'email_announcements') final  bool emailAnnouncements;
// -- Ratings --
@override@JsonKey(name: 'buyer_rating') final  double buyerRating;
@override@JsonKey(name: 'buyer_rating_count') final  int buyerRatingCount;
@override@JsonKey(name: 'seller_rating') final  double sellerRating;
@override@JsonKey(name: 'seller_rating_count') final  int sellerRatingCount;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.school, school) || other.school == school)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.schoolData, schoolData) || other.schoolData == schoolData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.emailNotificationsEnabled, emailNotificationsEnabled) || other.emailNotificationsEnabled == emailNotificationsEnabled)&&(identical(other.onesignalPlayerId, onesignalPlayerId) || other.onesignalPlayerId == onesignalPlayerId)&&(identical(other.pushNotificationsEnabled, pushNotificationsEnabled) || other.pushNotificationsEnabled == pushNotificationsEnabled)&&(identical(other.pushMessages, pushMessages) || other.pushMessages == pushMessages)&&(identical(other.emailMessages, emailMessages) || other.emailMessages == emailMessages)&&(identical(other.pushOrderUpdates, pushOrderUpdates) || other.pushOrderUpdates == pushOrderUpdates)&&(identical(other.emailOrderUpdates, emailOrderUpdates) || other.emailOrderUpdates == emailOrderUpdates)&&(identical(other.pushCampusAnnouncements, pushCampusAnnouncements) || other.pushCampusAnnouncements == pushCampusAnnouncements)&&(identical(other.emailCampusAnnouncements, emailCampusAnnouncements) || other.emailCampusAnnouncements == emailCampusAnnouncements)&&(identical(other.pushAnnouncements, pushAnnouncements) || other.pushAnnouncements == pushAnnouncements)&&(identical(other.emailAnnouncements, emailAnnouncements) || other.emailAnnouncements == emailAnnouncements)&&(identical(other.buyerRating, buyerRating) || other.buyerRating == buyerRating)&&(identical(other.buyerRatingCount, buyerRatingCount) || other.buyerRatingCount == buyerRatingCount)&&(identical(other.sellerRating, sellerRating) || other.sellerRating == sellerRating)&&(identical(other.sellerRatingCount, sellerRatingCount) || other.sellerRatingCount == sellerRatingCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,email,displayName,avatarUrl,school,schoolId,isVerified,schoolData,createdAt,updatedAt,emailNotificationsEnabled,onesignalPlayerId,pushNotificationsEnabled,pushMessages,emailMessages,pushOrderUpdates,emailOrderUpdates,pushCampusAnnouncements,emailCampusAnnouncements,pushAnnouncements,emailAnnouncements,buyerRating,buyerRatingCount,sellerRating,sellerRatingCount]);

@override
String toString() {
  return 'UserProfile(id: $id, email: $email, displayName: $displayName, avatarUrl: $avatarUrl, school: $school, schoolId: $schoolId, isVerified: $isVerified, schoolData: $schoolData, createdAt: $createdAt, updatedAt: $updatedAt, emailNotificationsEnabled: $emailNotificationsEnabled, onesignalPlayerId: $onesignalPlayerId, pushNotificationsEnabled: $pushNotificationsEnabled, pushMessages: $pushMessages, emailMessages: $emailMessages, pushOrderUpdates: $pushOrderUpdates, emailOrderUpdates: $emailOrderUpdates, pushCampusAnnouncements: $pushCampusAnnouncements, emailCampusAnnouncements: $emailCampusAnnouncements, pushAnnouncements: $pushAnnouncements, emailAnnouncements: $emailAnnouncements, buyerRating: $buyerRating, buyerRatingCount: $buyerRatingCount, sellerRating: $sellerRating, sellerRatingCount: $sellerRatingCount)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String email,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl, String school,@JsonKey(name: 'school_id') String schoolId,@JsonKey(name: 'is_verified') bool isVerified, School? schoolData,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'email_notifications_enabled') bool emailNotificationsEnabled,@JsonKey(name: 'onesignal_player_id') String? onesignalPlayerId,@JsonKey(name: 'push_notifications_enabled') bool pushNotificationsEnabled,@JsonKey(name: 'push_messages') bool pushMessages,@JsonKey(name: 'email_messages') bool emailMessages,@JsonKey(name: 'push_order_updates') bool pushOrderUpdates,@JsonKey(name: 'email_order_updates') bool emailOrderUpdates,@JsonKey(name: 'push_campus_announcements') bool pushCampusAnnouncements,@JsonKey(name: 'email_campus_announcements') bool emailCampusAnnouncements,@JsonKey(name: 'push_announcements') bool pushAnnouncements,@JsonKey(name: 'email_announcements') bool emailAnnouncements,@JsonKey(name: 'buyer_rating') double buyerRating,@JsonKey(name: 'buyer_rating_count') int buyerRatingCount,@JsonKey(name: 'seller_rating') double sellerRating,@JsonKey(name: 'seller_rating_count') int sellerRatingCount
});


@override $SchoolCopyWith<$Res>? get schoolData;

}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? school = null,Object? schoolId = null,Object? isVerified = null,Object? schoolData = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? emailNotificationsEnabled = null,Object? onesignalPlayerId = freezed,Object? pushNotificationsEnabled = null,Object? pushMessages = null,Object? emailMessages = null,Object? pushOrderUpdates = null,Object? emailOrderUpdates = null,Object? pushCampusAnnouncements = null,Object? emailCampusAnnouncements = null,Object? pushAnnouncements = null,Object? emailAnnouncements = null,Object? buyerRating = null,Object? buyerRatingCount = null,Object? sellerRating = null,Object? sellerRatingCount = null,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,schoolData: freezed == schoolData ? _self.schoolData : schoolData // ignore: cast_nullable_to_non_nullable
as School?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,emailNotificationsEnabled: null == emailNotificationsEnabled ? _self.emailNotificationsEnabled : emailNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,onesignalPlayerId: freezed == onesignalPlayerId ? _self.onesignalPlayerId : onesignalPlayerId // ignore: cast_nullable_to_non_nullable
as String?,pushNotificationsEnabled: null == pushNotificationsEnabled ? _self.pushNotificationsEnabled : pushNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,pushMessages: null == pushMessages ? _self.pushMessages : pushMessages // ignore: cast_nullable_to_non_nullable
as bool,emailMessages: null == emailMessages ? _self.emailMessages : emailMessages // ignore: cast_nullable_to_non_nullable
as bool,pushOrderUpdates: null == pushOrderUpdates ? _self.pushOrderUpdates : pushOrderUpdates // ignore: cast_nullable_to_non_nullable
as bool,emailOrderUpdates: null == emailOrderUpdates ? _self.emailOrderUpdates : emailOrderUpdates // ignore: cast_nullable_to_non_nullable
as bool,pushCampusAnnouncements: null == pushCampusAnnouncements ? _self.pushCampusAnnouncements : pushCampusAnnouncements // ignore: cast_nullable_to_non_nullable
as bool,emailCampusAnnouncements: null == emailCampusAnnouncements ? _self.emailCampusAnnouncements : emailCampusAnnouncements // ignore: cast_nullable_to_non_nullable
as bool,pushAnnouncements: null == pushAnnouncements ? _self.pushAnnouncements : pushAnnouncements // ignore: cast_nullable_to_non_nullable
as bool,emailAnnouncements: null == emailAnnouncements ? _self.emailAnnouncements : emailAnnouncements // ignore: cast_nullable_to_non_nullable
as bool,buyerRating: null == buyerRating ? _self.buyerRating : buyerRating // ignore: cast_nullable_to_non_nullable
as double,buyerRatingCount: null == buyerRatingCount ? _self.buyerRatingCount : buyerRatingCount // ignore: cast_nullable_to_non_nullable
as int,sellerRating: null == sellerRating ? _self.sellerRating : sellerRating // ignore: cast_nullable_to_non_nullable
as double,sellerRatingCount: null == sellerRatingCount ? _self.sellerRatingCount : sellerRatingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SchoolCopyWith<$Res>? get schoolData {
    if (_self.schoolData == null) {
    return null;
  }

  return $SchoolCopyWith<$Res>(_self.schoolData!, (value) {
    return _then(_self.copyWith(schoolData: value));
  });
}
}

// dart format on
