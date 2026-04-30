import 'package:freezed_annotation/freezed_annotation.dart';

part 'contribution_entry.freezed.dart';
part 'contribution_entry.g.dart';

@freezed
abstract class ContributionEntry with _$ContributionEntry {
  const factory ContributionEntry({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required int points,
    @JsonKey(name: 'source_type') required String sourceType,
    @JsonKey(name: 'source_id') String? sourceId,
    required String description,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ContributionEntry;

  factory ContributionEntry.fromJson(Map<String, dynamic> json) =>
      _$ContributionEntryFromJson(json);
}
