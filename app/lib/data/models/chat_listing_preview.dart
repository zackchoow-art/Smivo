// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_listing_preview.freezed.dart';
part 'chat_listing_preview.g.dart';

/// Minimal listing data embedded in ChatRoom for chat list display.
///
/// Only includes the fields needed to show "product title + image"
/// in the chat list — not the full Listing model.
@freezed
abstract class ChatListingPreview with _$ChatListingPreview {
  const factory ChatListingPreview({
    required String id,
    required String title,
    // NOTE: Added for chat list search — populated by fetchChatRooms query.
    String? description,
    @Default(0.0) double price,
    @Default([]) List<ChatListingImage> images,
  }) = _ChatListingPreview;

  factory ChatListingPreview.fromJson(Map<String, dynamic> json) =>
      _$ChatListingPreviewFromJson(json);
}

@freezed
abstract class ChatListingImage with _$ChatListingImage {
  const factory ChatListingImage({
    @JsonKey(name: 'image_url') required String imageUrl,
  }) = _ChatListingImage;

  factory ChatListingImage.fromJson(Map<String, dynamic> json) =>
      _$ChatListingImageFromJson(json);
}
