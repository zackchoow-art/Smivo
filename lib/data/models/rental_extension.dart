// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rental_extension.freezed.dart';
part 'rental_extension.g.dart';

/// Represents a rental period extension or shortening request.
///
/// Maps to the `rental_extensions` table. Buyers request changes,
/// sellers approve or reject them.
@freezed
abstract class RentalExtension with _$RentalExtension {
  const factory RentalExtension({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'requested_by') required String requestedBy,
    @JsonKey(name: 'request_type') required String requestType,
    @JsonKey(name: 'original_end_date') required DateTime originalEndDate,
    @JsonKey(name: 'new_end_date') required DateTime newEndDate,
    @JsonKey(name: 'price_diff') @Default(0.0) double priceDiff,
    @JsonKey(name: 'new_total') required double newTotal,
    @Default('pending') String status,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'rejection_note') String? rejectionNote,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _RentalExtension;

  factory RentalExtension.fromJson(Map<String, dynamic> json) =>
      _$RentalExtensionFromJson(json);
}
