import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_feedback.freezed.dart';
part 'user_feedback.g.dart';

@freezed
abstract class UserFeedback with _$UserFeedback {
  const factory UserFeedback({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String type,
    required String title,
    required String description,
    @JsonKey(name: 'screenshot_url') String? screenshotUrl,
    @JsonKey(name: 'device_info') Map<String, dynamic>? deviceInfo,
    @Default('submitted') String status,
    @JsonKey(name: 'admin_response') String? adminResponse,
    @JsonKey(name: 'points_awarded') @Default(0) int pointsAwarded,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserFeedback;

  factory UserFeedback.fromJson(Map<String, dynamic> json) =>
      _$UserFeedbackFromJson(json);
}
