// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pickup_location.freezed.dart';
part 'pickup_location.g.dart';

/// A designated pickup/meeting spot on a school campus.
///
/// Used by sellers when creating listings. Buyers can also
/// suggest alternate spots if the seller allows it.
@freezed
abstract class PickupLocation with _$PickupLocation {
  const factory PickupLocation({
    required String id,
    @JsonKey(name: 'school_id') required String schoolId,
    required String name,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _PickupLocation;

  factory PickupLocation.fromJson(Map<String, dynamic> json) =>
      _$PickupLocationFromJson(json);
}
