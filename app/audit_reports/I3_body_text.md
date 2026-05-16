# Task I-3: Body Text & Hardcoded TextStyles Audit Report

## Summary
- Total violations found: 134
- High severity (Raw TextStyle / GoogleFonts): 25
- Medium severity (Hardcoded colors): 109

## Violations by Feature Module
- **shared**: 34
- **settings**: 27
- **carpool**: 20
- **seller**: 16
- **chat**: 9
- **listing**: 9
- **orders**: 7
- **admin**: 4
- **buyer**: 3
- **auth**: 2
- **profile**: 2
- **home**: 1

## Top 10 Most Common Violation Patterns
1. `color: Colors.white,` (39 occurrences)
1. `style: TextStyle(` (5 occurrences)
1. `style: const TextStyle(` (5 occurrences)
1. `border: Border.all(color: Colors.white, width: 1.5),` (4 occurrences)
1. `color: Colors.green.shade600,` (4 occurrences)
1. `style: TextStyle(fontSize: 9, color: colors.onPrimary),` (4 occurrences)
1. `color: Colors.black.withValues(alpha: 0.3),` (3 occurrences)
1. `color: Colors.white70,` (3 occurrences)
1. `color: Colors.amber,` (3 occurrences)
1. `style: TextStyle(color: colors.error),` (2 occurrences)

## Complete Violations Table
| File | Line # | Hardcoded Style | What It Should Be | Severity |
|------|--------|-----------------|-------------------|----------|
| features/seller/screens/seller_center_screen.dart | 1995 | `color: Colors.black.withValues(alpha: 0.3),` | Use context.smivoColors... | Medium |
| features/seller/screens/seller_center_screen.dart | 2017 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/seller/widgets/ikea_seller_order_card.dart | 234 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/seller/widgets/ikea_seller_order_card.dart | 346 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/seller/widgets/ikea_seller_order_card.dart | 449 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/seller/widgets/ikea_seller_order_card.dart | 546 | `color: Colors.black.withValues(alpha: 0.3),` | Use context.smivoColors... | Medium |
| features/seller/widgets/ikea_seller_order_card.dart | 568 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/seller/widgets/ikea_seller_order_card.dart | 600 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/seller/widgets/ikea_seller_order_card.dart | 682 | `border: Border.all(color: Colors.white, width: 1.5),` | Use context.smivoColors... | Medium |
| features/seller/widgets/flat_seller_order_card.dart | 234 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/seller/widgets/flat_seller_order_card.dart | 346 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/seller/widgets/flat_seller_order_card.dart | 449 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/seller/widgets/flat_seller_order_card.dart | 546 | `color: Colors.black.withValues(alpha: 0.3),` | Use context.smivoColors... | Medium |
| features/seller/widgets/flat_seller_order_card.dart | 568 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/seller/widgets/flat_seller_order_card.dart | 600 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/seller/widgets/flat_seller_order_card.dart | 682 | `border: Border.all(color: Colors.white, width: 1.5),` | Use context.smivoColors... | Medium |
| features/settings/screens/system_settings_screen.dart | 669 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/settings/screens/debug_data_screen.dart | 185 | `style: TextStyle(color: colors.error),` | Use typo.token.copyWith(...) | High |
| features/settings/screens/debug_data_screen.dart | 364 | `style: const TextStyle(color: Colors.red, fontSize: 14),` | Use typo.token.copyWith(...) | High |
| features/settings/screens/debug_data_screen.dart | 364 | `style: const TextStyle(color: Colors.red, fontSize: 14),` | Use context.smivoColors... | Medium |
| features/settings/screens/submit_feedback_screen.dart | 145 | `labelStyle: TextStyle(` | Use typo.token.copyWith(...) | High |
| features/settings/screens/submit_feedback_screen.dart | 240 | `color: Colors.black54,` | Use context.smivoColors... | Medium |
| features/settings/screens/submit_feedback_screen.dart | 245 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/settings/screens/submit_feedback_screen.dart | 302 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/settings/screens/edit_profile_screen.dart | 237 | `color: Colors.orange.withAlpha(20),` | Use context.smivoColors... | Medium |
| features/settings/screens/edit_profile_screen.dart | 246 | `color: Colors.orange,` | Use context.smivoColors... | Medium |
| features/settings/screens/edit_profile_screen.dart | 485 | `const Icon(Icons.error_outline, color: Colors.white),` | Use context.smivoColors... | Medium |
| features/settings/screens/my_contributions_screen.dart | 60 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/settings/screens/my_contributions_screen.dart | 67 | `color: Colors.white70,` | Use context.smivoColors... | Medium |
| features/settings/screens/my_contributions_screen.dart | 75 | `color: Colors.white70,` | Use context.smivoColors... | Medium |
| features/settings/screens/my_contributions_screen.dart | 82 | `color: Colors.white70,` | Use context.smivoColors... | Medium |
| features/settings/screens/my_feedbacks_screen.dart | 99 | `icon: const Icon(Icons.add, color: Colors.white),` | Use context.smivoColors... | Medium |
| features/settings/screens/my_feedbacks_screen.dart | 102 | `style: TextStyle(color: Colors.white),` | Use typo.token.copyWith(...) | High |
| features/settings/screens/my_feedbacks_screen.dart | 102 | `style: TextStyle(color: Colors.white),` | Use context.smivoColors... | Medium |
| features/settings/screens/my_feedbacks_screen.dart | 230 | `color: Colors.black.withAlpha(10),` | Use context.smivoColors... | Medium |
| features/settings/screens/my_feedbacks_screen.dart | 430 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/settings/screens/my_feedbacks_screen.dart | 498 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/settings/screens/my_feedbacks_screen.dart | 505 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/settings/widgets/flippable_report_card.dart | 119 | `color: Colors.black.withAlpha(10),` | Use context.smivoColors... | Medium |
| features/settings/widgets/flippable_report_card.dart | 405 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/settings/widgets/flippable_report_card.dart | 660 | `color: Colors.black.withAlpha(8),` | Use context.smivoColors... | Medium |
| features/settings/widgets/flippable_report_card.dart | 756 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/settings/widgets/avatar_customization_dialog.dart | 119 | `child: Text('Cancel', style: TextStyle(color: colors.outlineVariant)),` | Use typo.token.copyWith(...) | High |
| features/home/widgets/featured_listing_card.dart | 142 | `style: typo.priceStyle.copyWith(color: Colors.white),` | Use context.smivoColors... | Medium |
| features/carpool/screens/group_chat_screen.dart | 342 | `hintStyle: TextStyle(color: theme.colorScheme.outline),` | Use typo.token.copyWith(...) | High |
| features/carpool/screens/group_chat_screen.dart | 446 | `child: Icon(Icons.trip_origin, size: 16, color: Colors.green.shade600),` | Use context.smivoColors... | Medium |
| features/carpool/screens/group_chat_screen.dart | 468 | `child: Icon(Icons.location_on, size: 16, color: Colors.red.shade600),` | Use context.smivoColors... | Medium |
| features/carpool/screens/manage_trip_screen.dart | 550 | `color: Colors.orange),` | Use context.smivoColors... | Medium |
| features/carpool/screens/manage_trip_screen.dart | 558 | `color: Colors.green),` | Use context.smivoColors... | Medium |
| features/carpool/screens/manage_trip_screen.dart | 566 | `color: Colors.grey),` | Use context.smivoColors... | Medium |
| features/carpool/screens/manage_trip_screen.dart | 867 | `icon: Icon(Icons.check, color: Colors.green.shade600),` | Use context.smivoColors... | Medium |
| features/carpool/screens/create_carpool_screen.dart | 237 | `const Icon(Icons.lightbulb, color: Colors.amber, size: 20),` | Use context.smivoColors... | Medium |
| features/carpool/screens/carpool_detail_screen.dart | 521 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/carpool/screens/carpool_detail_screen.dart | 551 | `color: Colors.green.shade600,` | Use context.smivoColors... | Medium |
| features/carpool/screens/carpool_detail_screen.dart | 558 | `color: Colors.green.shade600,` | Use context.smivoColors... | Medium |
| features/carpool/screens/carpool_detail_screen.dart | 629 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/carpool/screens/carpool_detail_screen.dart | 659 | `color: Colors.green.shade600,` | Use context.smivoColors... | Medium |
| features/carpool/screens/carpool_detail_screen.dart | 666 | `color: Colors.green.shade600,` | Use context.smivoColors... | Medium |
| features/carpool/screens/carpool_detail_screen.dart | 852 | `Icon(Icons.lightbulb, size: 16, color: Colors.amber.shade600),` | Use context.smivoColors... | Medium |
| features/carpool/widgets/group_chat_list_tile.dart | 99 | `style: TextStyle(` | Use typo.token.copyWith(...) | High |
| features/carpool/widgets/group_member_sheet.dart | 138 | `color: Colors.amber.shade100,` | Use context.smivoColors... | Medium |
| features/carpool/widgets/group_member_sheet.dart | 144 | `color: Colors.amber.shade800,` | Use context.smivoColors... | Medium |
| features/carpool/widgets/group_member_sheet.dart | 189 | `color: Colors.amber,` | Use context.smivoColors... | Medium |
| features/carpool/widgets/group_member_sheet.dart | 199 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/chat/screens/chat_list_screen.dart | 571 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/chat/screens/chat_room_screen.dart | 467 | `style: TextStyle(color: Colors.red),` | Use typo.token.copyWith(...) | High |
| features/chat/screens/chat_room_screen.dart | 467 | `style: TextStyle(color: Colors.red),` | Use context.smivoColors... | Medium |
| features/chat/widgets/chat_list_item.dart | 185 | `style: TextStyle(` | Use typo.token.copyWith(...) | High |
| features/chat/widgets/chat_popup.dart | 164 | `color: Colors.red.shade700,` | Use context.smivoColors... | Medium |
| features/chat/widgets/chat_popup.dart | 172 | `color: Colors.red.shade700,` | Use context.smivoColors... | Medium |
| features/chat/widgets/chat_popup.dart | 188 | `_showSnackBar(warning, color: Colors.amber.shade800);` | Use context.smivoColors... | Medium |
| features/chat/widgets/chat_popup.dart | 198 | `color: Colors.orange.shade700,` | Use context.smivoColors... | Medium |
| features/chat/widgets/chat_popup.dart | 202 | `_showSnackBar('Send failed: ${e.toString()}', color: Colors.red.shade700);` | Use context.smivoColors... | Medium |
| features/auth/screens/login_screen.dart | 595 | `style: const TextStyle(` | Use typo.token.copyWith(...) | High |
| features/auth/screens/login_screen.dart | 612 | `style: const TextStyle(` | Use typo.token.copyWith(...) | High |
| features/admin/screens/admin_faqs_screen.dart | 225 | `color: Color(0xFFEA580C),` | Use context.smivoColors... | Medium |
| features/admin/screens/admin_schools_screen.dart | 72 | `color: Color(0xFF2563EB),` | Use context.smivoColors... | Medium |
| features/admin/screens/admin_pickup_locations_screen.dart | 180 | `color: Color(0xFF059669),` | Use context.smivoColors... | Medium |
| features/admin/screens/admin_conditions_screen.dart | 177 | `color: Color(0xFF7C3AED),` | Use context.smivoColors... | Medium |
| features/shared/widgets/user_reviews_bottom_sheet.dart | 128 | `Icon(Icons.star_rounded, color: Colors.amber, size: 28),` | Use context.smivoColors... | Medium |
| features/shared/widgets/user_reviews_bottom_sheet.dart | 267 | `color: Colors.amber,` | Use context.smivoColors... | Medium |
| features/shared/widgets/order_review_form.dart | 98 | `color: Colors.amber,` | Use context.smivoColors... | Medium |
| features/shared/widgets/order_review_form.dart | 195 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/profile/screens/profile_setup_screen.dart | 148 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/profile/screens/profile_setup_screen.dart | 203 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/orders/widgets/rental_reminder_settings.dart | 277 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/orders/widgets/order_timeline.dart | 140 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/orders/widgets/order_timeline.dart | 146 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/orders/widgets/rental_extension_card.dart | 351 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/orders/widgets/rental_extension_card.dart | 399 | `const Icon(Icons.error_outline, color: Colors.white),` | Use context.smivoColors... | Medium |
| features/orders/widgets/rental_extension_card.dart | 521 | `style: TextStyle(color: colors.error),` | Use typo.token.copyWith(...) | High |
| features/orders/widgets/rental_extension_card.dart | 677 | `Icon(Icons.error_outline, color: Colors.white),` | Use context.smivoColors... | Medium |
| features/listing/screens/create_listing_form_screen.dart | 404 | `style: TextStyle(` | Use typo.token.copyWith(...) | High |
| features/listing/screens/create_listing_form_screen.dart | 693 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/listing/screens/create_listing_form_screen.dart | 792 | `borderSide: BorderSide(color: Colors.grey.shade200),` | Use context.smivoColors... | Medium |
| features/listing/widgets/photo_picker_section.dart | 115 | `color: Colors.black.withValues(alpha: 0.7),` | Use context.smivoColors... | Medium |
| features/listing/widgets/photo_picker_section.dart | 120 | `style: typo.labelSmall.copyWith(color: Colors.white),` | Use context.smivoColors... | Medium |
| features/listing/widgets/photo_picker_section.dart | 140 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/listing/widgets/saved_listing_card.dart | 116 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/listing/widgets/listing_image_carousel.dart | 106 | `color: Colors.black.withValues(alpha: 0.4),` | Use context.smivoColors... | Medium |
| features/listing/widgets/listing_image_carousel.dart | 115 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| features/buyer/screens/buyer_center_screen.dart | 436 | `style: TextStyle(` | Use typo.token.copyWith(...) | High |
| features/buyer/widgets/flat_buyer_order_card.dart | 95 | `border: Border.all(color: Colors.white, width: 1.5),` | Use context.smivoColors... | Medium |
| features/buyer/widgets/ikea_buyer_order_card.dart | 95 | `border: Border.all(color: Colors.white, width: 1.5),` | Use context.smivoColors... | Medium |
| shared/widgets/fullscreen_image_viewer.dart | 136 | `iconTheme: const IconThemeData(color: Colors.white),` | Use context.smivoColors... | Medium |
| shared/widgets/fullscreen_image_viewer.dart | 144 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| shared/widgets/fullscreen_image_viewer.dart | 182 | `const Icon(Icons.block, color: Colors.grey, size: 48),` | Use context.smivoColors... | Medium |
| shared/widgets/fullscreen_image_viewer.dart | 186 | `style: const TextStyle(color: Colors.grey, fontSize: 14),` | Use typo.token.copyWith(...) | High |
| shared/widgets/fullscreen_image_viewer.dart | 186 | `style: const TextStyle(color: Colors.grey, fontSize: 14),` | Use context.smivoColors... | Medium |
| shared/widgets/fullscreen_image_viewer.dart | 210 | `color: Colors.black,` | Use context.smivoColors... | Medium |
| shared/widgets/fullscreen_image_viewer.dart | 230 | `color: Colors.black.withValues(alpha: 0.5),` | Use context.smivoColors... | Medium |
| shared/widgets/fullscreen_image_viewer.dart | 235 | `style: const TextStyle(` | Use typo.token.copyWith(...) | High |
| shared/widgets/fullscreen_image_viewer.dart | 236 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| shared/widgets/navigation_rail_bar.dart | 113 | `style: TextStyle(` | Use typo.token.copyWith(...) | High |
| shared/widgets/navigation_rail_bar.dart | 169 | `style: TextStyle(fontSize: 9, color: colors.onPrimary),` | Use typo.token.copyWith(...) | High |
| shared/widgets/navigation_rail_bar.dart | 178 | `style: TextStyle(fontSize: 9, color: colors.onPrimary),` | Use typo.token.copyWith(...) | High |
| shared/widgets/navigation_rail_bar.dart | 203 | `style: TextStyle(fontSize: 9, color: colors.onPrimary),` | Use typo.token.copyWith(...) | High |
| shared/widgets/navigation_rail_bar.dart | 212 | `style: TextStyle(fontSize: 9, color: colors.onPrimary),` | Use typo.token.copyWith(...) | High |
| shared/widgets/smivo_user_avatar.dart | 79 | `color: Colors.green,` | Use context.smivoColors... | Medium |
| shared/widgets/moderation_aware_image.dart | 112 | `color: Colors.grey[200],` | Use context.smivoColors... | Medium |
| shared/widgets/moderation_aware_image.dart | 113 | `child: const Icon(Icons.broken_image, color: Colors.grey),` | Use context.smivoColors... | Medium |
| shared/widgets/moderation_aware_image.dart | 121 | `color: Colors.grey[100],` | Use context.smivoColors... | Medium |
| shared/widgets/moderation_aware_image.dart | 163 | `color: Colors.black.withValues(alpha: 0.4),` | Use context.smivoColors... | Medium |
| shared/widgets/moderation_aware_image.dart | 172 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| shared/widgets/moderation_aware_image.dart | 179 | `style: const TextStyle(` | Use typo.token.copyWith(...) | High |
| shared/widgets/moderation_aware_image.dart | 180 | `color: Colors.white,` | Use context.smivoColors... | Medium |
| shared/widgets/moderation_aware_image.dart | 207 | `color: Colors.grey[200],` | Use context.smivoColors... | Medium |
| shared/widgets/moderation_aware_image.dart | 216 | `const Icon(Icons.block, color: Colors.grey, size: 28),` | Use context.smivoColors... | Medium |
| shared/widgets/moderation_aware_image.dart | 221 | `style: const TextStyle(` | Use typo.token.copyWith(...) | High |
| shared/widgets/moderation_aware_image.dart | 222 | `color: Colors.grey,` | Use context.smivoColors... | Medium |
| shared/widgets/themed_confirm_dialog.dart | 85 | `style: TextStyle(color: colors.onSurfaceVariant),` | Use typo.token.copyWith(...) | High |
| shared/widgets/themed_confirm_dialog.dart | 96 | `child: Text(confirmText, style: TextStyle(color: confirmTextColor)),` | Use typo.token.copyWith(...) | High |
| shared/widgets/floating_quick_nav.dart | 162 | `color: Colors.black.withValues(alpha: 0.25),` | Use context.smivoColors... | Medium |
| shared/widgets/floating_quick_nav.dart | 313 | `color: Colors.black.withValues(alpha: 0.15),` | Use context.smivoColors... | Medium |
