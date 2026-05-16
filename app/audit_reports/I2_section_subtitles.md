# Task I-2: Section Subtitles Audit Report

## Summary
- Total section headers found: 122
- Using theme tokens correctly: 117
- Using hardcoded styles: 2
- Most common correct pattern: `typo.titleMedium`
- Distinct style variations found:
  - Hardcoded |  |  |  | Colors.red
  - Hardcoded |  |  |  | Colors.white
  - Hardcoded |  |  | FontWeight.bold | colors.primary
  - Other | Theme.of(context |  |  | 
  - Other | Theme.of(context |  |  | Theme.of(context
  - Theme Token |  |  |  | colors .onSurface
  - Theme Token | bodyLarge |  |  | 
  - Theme Token | bodyLarge |  |  | colors.onSurfaceVariant
  - Theme Token | bodyLarge |  | FontWeight.w600 | emailEnabled ? colors.onSurface : colors.onSurfaceVariant
  - Theme Token | bodyLarge |  | FontWeight.w600 | pushEnabled ? colors.onSurface : colors.onSurfaceVariant
  - Theme Token | bodyLarge |  | FontWeight.w700 | colors.onSurface
  - Theme Token | bodyMedium |  |  | 
  - Theme Token | bodyMedium |  |  | colors.onSurface
  - Theme Token | bodyMedium |  |  | colors.onSurfaceVariant
  - Theme Token | bodyMedium |  |  | colors.outlineVariant
  - Theme Token | bodyMedium |  |  | colors.primary
  - Theme Token | bodyMedium |  |  | theme.colorScheme.onSurfaceVariant
  - Theme Token | bodyMedium |  |  | theme.colorScheme.outline
  - Theme Token | bodyMedium |  | FontWeight.w500 | 
  - Theme Token | bodyMedium |  | FontWeight.w600 | 
  - Theme Token | bodyMedium |  | FontWeight.w600 | colors.primary
  - Theme Token | bodyMedium |  | FontWeight.w700 | colors.onSurface
  - Theme Token | bodyMedium |  | FontWeight.w700 | colors.primary
  - Theme Token | bodySmall |  |  | colors.onSurface.withValues( alpha: 0.6
  - Theme Token | bodySmall |  |  | colors.onSurfaceVariant
  - Theme Token | bodySmall |  |  | theme.colorScheme.outline.withValues(alpha: 0.7
  - Theme Token | bodySmall |  | FontWeight.bold | colors.success
  - Theme Token | displayLarge |  |  | colors.primary
  - Theme Token | headlineLarge |  |  | 
  - Theme Token | headlineLarge |  | FontWeight.bold | colors.primary
  - Theme Token | headlineLarge |  | FontWeight.w900 | 
  - Theme Token | headlineLarge |  | FontWeight.w900 | colors.onSurface
  - Theme Token | headlineMedium |  |  | colors.primary
  - Theme Token | headlineMedium |  | FontWeight.w700 | 
  - Theme Token | headlineMedium |  | FontWeight.w700 | colors.error
  - Theme Token | headlineSmall |  |  | 
  - Theme Token | headlineSmall |  | FontWeight.bold | 
  - Theme Token | headlineSmall |  | FontWeight.bold | colors.onSurface
  - Theme Token | headlineSmall |  | FontWeight.w600 | 
  - Theme Token | headlineSmall |  | FontWeight.w700 | 
  - Theme Token | headlineSmall |  | FontWeight.w800 | 
  - Theme Token | headlineSmall |  | FontWeight.w800 | colors.onPrimary
  - Theme Token | labelLarge |  |  | 
  - Theme Token | labelLarge |  |  | colors .onSurface
  - Theme Token | labelLarge |  |  | colors.onPrimary
  - Theme Token | labelLarge |  |  | colors.onSurface
  - Theme Token | labelLarge |  |  | colors.onSurfaceVariant
  - Theme Token | labelLarge |  |  | colors.outlineVariant
  - Theme Token | labelLarge |  |  | colors.primary
  - Theme Token | labelLarge |  |  | isValid ? colors.onPrimary : colors.onPrimary.withValues(alpha: 0.5
  - Theme Token | labelLarge |  | FontWeight.bold | colors.onPrimary
  - Theme Token | labelLarge |  | FontWeight.bold | colors.onSurface
  - Theme Token | labelLarge |  | FontWeight.w600 | 
  - Theme Token | labelLarge |  | FontWeight.w700 | colors.error
  - Theme Token | labelLarge |  | FontWeight.w700 | colors.onPrimary
  - Theme Token | labelSmall |  |  | Colors.white
  - Theme Token | labelSmall |  |  | Colors.white70
  - Theme Token | labelSmall |  |  | colors.onSurface.withValues(alpha: 0.5
  - Theme Token | labelSmall |  | FontWeight.bold | Colors.white
  - Theme Token | labelSmall |  | FontWeight.bold | colors.primary
  - Theme Token | labelSmall |  | FontWeight.bold | colors.success
  - Theme Token | labelSmall |  | FontWeight.w500 | colors.primary.withValues(alpha: 0.7
  - Theme Token | labelSmall |  | FontWeight.w600 | Colors.amber.shade800
  - Theme Token | labelSmall |  | FontWeight.w600 | colors.onSurface.withValues(alpha: 0.6
  - Theme Token | labelSmall |  | FontWeight.w700 | colors .surfaceContainerLowest
  - Theme Token | labelSmall |  | FontWeight.w700 | colors.surfaceContainerLowest
  - Theme Token | labelUppercase |  |  | 
  - Theme Token | titleLarge |  |  | 
  - Theme Token | titleMedium |  |  | 
  - Theme Token | titleMedium |  |  | colors.outlineVariant
  - Theme Token | titleMedium |  | FontWeight.bold | 
  - Theme Token | titleMedium |  | FontWeight.bold | Theme.of( context
  - Theme Token | titleMedium |  | FontWeight.bold | colors.onSurface
  - Theme Token | titleMedium |  | FontWeight.w600 | 
  - Theme Token | titleMedium |  | FontWeight.w700 | 
  - Theme Token | titleMedium |  | FontWeight.w800 | 
  - Theme Token | titleMedium |  | FontWeight.w800 | colors.onSurface
  - Theme Token | titleMedium |  | FontWeight.w800 | theme.colorScheme.onPrimary
  - Theme Token | titleSmall |  |  | theme.colorScheme.onSurfaceVariant

## Per-file Table
| File | Line # | Section Text | Style Source | Token Used | Font Size | Weight | Color Source | Icon? | Icon Color |
|------|--------|--------------|--------------|------------|-----------|--------|--------------|-------|------------|
| features/seller/screens/seller_center_screen.dart | 1565 | Awaiting\nDelivery | Theme Token | labelSmall |  | FontWeight.w700 | colors.surfaceContainerLowest | No |  |
| features/seller/screens/seller_center_screen.dart | 1794 | Close | Hardcoded |  |  | FontWeight.bold | colors.primary | No |  |
| features/seller/screens/transaction_management_screen.dart | 58 | Manage Transactions | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/seller/widgets/ikea_seller_order_card.dart | 231 | Awaiting | Theme Token | labelSmall |  | FontWeight.bold | Colors.white | No |  |
| features/seller/widgets/flat_seller_order_card.dart | 231 | Awaiting | Theme Token | labelSmall |  | FontWeight.bold | Colors.white | No |  |
| features/settings/screens/notification_settings_screen.dart | 155 | Master Switches | Theme Token | headlineSmall |  | FontWeight.bold |  | No |  |
| features/settings/screens/notification_settings_screen.dart | 198 | Category Preferences | Theme Token | headlineSmall |  | FontWeight.bold |  | No |  |
| features/settings/screens/system_settings_screen.dart | 56 | Display | Theme Token | titleMedium |  | FontWeight.w800 | colors.onSurface | No |  |
| features/settings/screens/system_settings_screen.dart | 86 | App Theme | Theme Token | bodyLarge |  | FontWeight.w700 | colors.onSurface | Yes | colors.settingsIcon |
| features/settings/screens/system_settings_screen.dart | 169 | Color Palette | Theme Token | bodyLarge |  | FontWeight.w700 | colors.onSurface | Yes | colors.settingsIcon |
| features/settings/screens/system_settings_screen.dart | 222 | Language | Theme Token | bodyLarge |  | FontWeight.w700 | colors.onSurface | Yes | colors.settingsIcon |
| features/settings/screens/system_settings_screen.dart | 244 | Storage | Theme Token | titleMedium |  | FontWeight.w800 | colors.onSurface | No |  |
| features/settings/screens/system_settings_screen.dart | 326 | Clear Local Cache | Theme Token | bodyLarge |  | FontWeight.w700 | colors.onSurface | Yes | colors.settingsIcon |
| features/settings/screens/system_settings_screen.dart | 352 | Feedback | Theme Token | titleMedium |  | FontWeight.w800 | colors.onSurface | No |  |
| features/settings/screens/system_settings_screen.dart | 381 | Shake to Report | Theme Token | bodyLarge |  | FontWeight.w700 | colors.onSurface | Yes | colors.settingsIcon |
| features/settings/screens/system_settings_screen.dart | 440 | Quick Navigation | Theme Token | bodyLarge |  | FontWeight.w700 | colors.onSurface | Yes | colors.settingsIcon |
| features/settings/screens/system_settings_screen.dart | 483 | Developer | Theme Token | titleMedium |  | FontWeight.w800 | colors.onSurface | No |  |
| features/settings/screens/system_settings_screen.dart | 516 | Debug Backend Data | Theme Token | bodyLarge |  | FontWeight.w700 | colors.onSurface | Yes | colors.settingsIcon |
| features/settings/screens/debug_data_screen.dart | 158 | Debug Backend Data | Theme Token | titleMedium |  |  |  | No |  |
| features/settings/screens/trust_and_safety_screen.dart | 26 | Trust & Safety | Theme Token | headlineSmall |  | FontWeight.w600 |  | No |  |
| features/settings/screens/submit_feedback_screen.dart | 169 | Feedback Type | Theme Token | labelLarge |  |  |  | No |  |
| features/settings/screens/submit_feedback_screen.dart | 188 | Description | Theme Token | labelLarge |  |  |  | No |  |
| features/settings/screens/edit_profile_screen.dart | 280 | Display Name | Theme Token | bodyMedium |  | FontWeight.w700 | colors.onSurface | No |  |
| features/settings/screens/edit_profile_screen.dart | 401 | Take a Photo | Theme Token | bodyLarge |  |  |  | Yes | colors.primary |
| features/settings/screens/edit_profile_screen.dart | 406 | Choose from Gallery | Theme Token | bodyLarge |  |  |  | Yes | colors.primary |
| features/settings/screens/edit_profile_screen.dart | 411 | Customize Avatar | Theme Token | bodyLarge |  |  |  | Yes | colors.primary |
| features/settings/screens/my_contributions_screen.dart | 26 | My Contributions | Theme Token | titleMedium |  |  |  | No |  |
| features/settings/screens/my_contributions_screen.dart | 79 | Max Level Reached! | Theme Token | labelSmall |  |  | Colors.white70 | No |  |
| features/settings/screens/my_contributions_screen.dart | 93 | Contribution History | Theme Token | titleMedium |  |  |  | No |  |
| features/settings/screens/my_feedbacks_screen.dart | 25 | My Feedbacks | Theme Token | titleMedium |  |  |  | No |  |
| features/settings/screens/my_feedbacks_screen.dart | 99 | New Feedback | Hardcoded |  |  |  | Colors.white | No |  |
| features/settings/widgets/avatar_customization_dialog.dart | 47 | Customize Avatar | Theme Token | headlineSmall |  |  |  | No |  |
| features/settings/widgets/category_notification_row.dart | 85 | Push Notification | Theme Token | bodyLarge |  | FontWeight.w600 | pushEnabled ? colors.onSurface : colors.onSurfaceVariant | No |  |
| features/settings/widgets/category_notification_row.dart | 104 | Email | Theme Token | bodyLarge |  | FontWeight.w600 | emailEnabled ? colors.onSurface : colors.onSurfaceVariant | No |  |
| features/settings/widgets/delete_account_bottom_sheet.dart | 436 | Deleting your account... | Theme Token | titleMedium |  | FontWeight.w600 |  | No |  |
| features/home/widgets/home_header.dart | 38 | Smivo | Theme Token | headlineMedium |  |  | colors.primary | No |  |
| features/home/widgets/home_header.dart | 88 | Verified | Theme Token | labelSmall |  | FontWeight.bold | colors.success | Yes | colors.success |
| features/carpool/screens/arrival_confirmation_screen.dart | 49 | Trip Summary | Other | Theme.of(context |  |  |  | No |  |
| features/carpool/screens/carpool_list_screen.dart | 323 | Start a Carpool Trip | Theme Token | titleMedium |  | FontWeight.w800 | theme.colorScheme.onPrimary | Yes | theme.colorScheme.onPrimary |
| features/carpool/screens/trip_proposals_screen.dart | 275 | New Proposal | Theme Token | titleLarge |  |  |  | No |  |
| features/carpool/screens/manage_trip_screen.dart | 350 | Trip Details | Theme Token | titleMedium |  |  |  | No |  |
| features/carpool/screens/create_carpool_screen.dart | 212 | Pricing Model | Theme Token | titleMedium |  |  |  | No |  |
| features/carpool/screens/create_carpool_screen.dart | 250 | Route | Theme Token | titleMedium |  |  |  | Yes | Colors.amber |
| features/carpool/screens/create_carpool_screen.dart | 284 | Trip Details | Theme Token | titleMedium |  |  |  | No |  |
| features/carpool/widgets/review_batch_sheet.dart | 160 | Rate Fellow Riders | Theme Token | titleLarge |  |  |  | No |  |
| features/carpool/widgets/group_member_sheet.dart | 53 | Trip Members | Theme Token | titleMedium |  | FontWeight.w700 |  | Yes | theme.colorScheme.primary |
| features/carpool/widgets/group_member_sheet.dart | 141 | Creator | Theme Token | labelSmall |  | FontWeight.w600 | Colors.amber.shade800 | No |  |
| features/carpool/widgets/trip_timeline.dart | 380 | Cost Settlement | Theme Token | titleMedium |  | FontWeight.w700 |  | No |  |
| features/chat/screens/chat_list_screen.dart | 538 | System Messages | Theme Token | titleMedium |  | FontWeight.w800 | colors.onSurface | Yes | colors.primary |
| features/chat/widgets/chat_split_view.dart | 48 | Select a conversation | Theme Token | titleMedium |  |  | colors.outlineVariant | Yes | colors.outlineVariant |
| features/auth/screens/login_screen.dart | 534 | NEW TO THE QUAD? | Theme Token | bodyLarge |  |  | colors.onSurfaceVariant | No |  |
| features/admin/screens/admin_users_screen.dart | 32 | Manage Users | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/admin/screens/admin_roles_screen.dart | 34 | Manage Roles | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/admin/screens/admin_listings_screen.dart | 32 | Manage Listings | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/admin/screens/admin_dictionary_screen.dart | 35 | System Dictionary | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/admin/screens/admin_faqs_screen.dart | 41 | Manage FAQs | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/admin/screens/admin_faqs_screen.dart | 258 | Global | Theme Token | labelSmall |  | FontWeight.bold | colors.primary | No |  |
| features/admin/screens/admin_orders_screen.dart | 31 | Manage Orders | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/admin/screens/admin_shell_screen.dart | 223 | Smivo Admin | Theme Token | titleMedium |  | FontWeight.w800 | colors.onSurface | Yes | colors.onPrimary |
| features/admin/screens/admin_shell_screen.dart | 298 | Smivo Admin | Theme Token | titleMedium |  | FontWeight.w800 |  | Yes | colors.onPrimary |
| features/admin/screens/admin_login_screen.dart | 80 | Management Console | Theme Token | bodyLarge |  |  | colors.onSurfaceVariant | No |  |
| features/admin/screens/admin_login_screen.dart | 101 | Sign In | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/admin/screens/admin_schools_screen.dart | 97 | Active | Theme Token | labelSmall |  | FontWeight.bold | colors.primary | No |  |
| features/admin/screens/admin_schools_screen.dart | 333 | Basic Info | Other | Theme.of(context |  |  |  | No |  |
| features/admin/screens/admin_schools_screen.dart | 387 | Location | Other | Theme.of(context |  |  |  | No |  |
| features/admin/screens/admin_dashboard_screen.dart | 29 | Dashboard | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/admin/screens/admin_dashboard_screen.dart | 57 | Platform Overview | Theme Token | headlineMedium |  | FontWeight.w700 |  | No |  |
| features/admin/screens/admin_dashboard_screen.dart | 125 | Quick Actions | Theme Token | headlineMedium |  | FontWeight.w700 |  | No |  |
| features/admin/screens/admin_dashboard_screen.dart | 187 | Danger Zone | Theme Token | headlineMedium |  | FontWeight.w700 | colors.error | No |  |
| features/admin/screens/admin_dashboard_screen.dart | 216 | Clear All Test Data | Theme Token | titleMedium |  | FontWeight.w700 |  | Yes | colors.error |
| features/admin/screens/admin_dashboard_screen.dart | 256 | Recent Orders | Theme Token | headlineMedium |  | FontWeight.w700 |  | No |  |
| features/admin/screens/admin_pickup_locations_screen.dart | 36 | Manage Pickup Locations | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/admin/screens/admin_categories_screen.dart | 35 | Manage Categories | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/admin/screens/admin_review_tags_screen.dart | 103 | Review Tags | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/admin/screens/admin_review_tags_screen.dart | 131 | Add New Tag | Theme Token | headlineSmall |  | FontWeight.w700 |  | No |  |
| features/admin/screens/admin_conditions_screen.dart | 35 | Manage Conditions | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/shared/widgets/order_review_form.dart | 80 | Rate the ${widget.role} | Theme Token | titleMedium |  | FontWeight.bold |  | No |  |
| features/profile/screens/profile_setup_screen.dart | 92 | Set up your Profile | Theme Token | headlineLarge |  |  |  | No |  |
| features/orders/screens/rental_order_detail_screen.dart | 534 | Delivery Confirmation | Theme Token | labelSmall |  |  | colors.onSurface.withValues(alpha: 0.5 | No |  |
| features/orders/screens/sale_order_detail_screen.dart | 361 | DELIVERY CONFIRMATION | Theme Token | labelSmall |  |  | colors.onSurface.withValues(alpha: 0.5 | No |  |
| features/orders/screens/order_detail_screen.dart | 46 | Order Details | Theme Token | headlineSmall |  | FontWeight.w800 |  | No |  |
| features/orders/widgets/rental_reminder_settings.dart | 130 | RENTAL REMINDER | Theme Token | labelSmall |  |  | colors.onSurface.withValues(alpha: 0.5 | Yes | colors.primary |
| features/orders/widgets/rental_reminder_settings.dart | 140 | Return Reminder Timing | Theme Token | titleMedium |  |  |  | No |  |
| features/orders/widgets/order_card.dart | 236 | COUNTERPARTY | Theme Token | labelSmall |  | FontWeight.w600 | colors.onSurface.withValues(alpha: 0.6 | No |  |
| features/orders/widgets/order_card.dart | 294 | PICKUP | Theme Token | labelSmall |  | FontWeight.w600 | colors.onSurface.withValues(alpha: 0.6 | No |  |
| features/orders/widgets/order_card.dart | 332 | View Order Snapshot | Theme Token | labelSmall |  | FontWeight.w500 | colors.primary.withValues(alpha: 0.7 | No |  |
| features/orders/widgets/order_card.dart | 360 | View Details | Theme Token | labelLarge |  |  | colors.onPrimary | No |  |
| features/orders/widgets/transaction_snapshot_modal.dart | 75 | Transaction Snapshot | Theme Token | labelSmall |  | FontWeight.bold | colors.primary | No |  |
| features/orders/widgets/order_info_section.dart | 59 | Order Info | Theme Token | titleMedium |  | FontWeight.bold |  | No |  |
| features/orders/widgets/list_order_card.dart | 111 | View Order Snapshot | Theme Token | labelSmall |  | FontWeight.w500 | colors.primary.withValues(alpha: 0.7 | No |  |
| features/orders/widgets/rental_extension_card.dart | 100 | RENTAL PERIOD CHANGES | Theme Token | labelSmall |  |  | colors.onSurface.withValues(alpha: 0.5 | No |  |
| features/orders/widgets/rental_extension_card.dart | 196 | Adjust Rental Period | Theme Token | titleMedium |  |  |  | No |  |
| features/orders/widgets/rental_extension_card.dart | 275 | New end date: | Theme Token | bodyMedium |  |  | colors.outlineVariant | No |  |
| features/orders/widgets/chat_history_section.dart | 44 | Chat History | Theme Token | titleMedium |  | FontWeight.bold |  | No |  |
| features/listing/screens/create_listing_form_screen.dart | 158 | Listing Privileges Suspended | Theme Token | headlineSmall |  | FontWeight.bold | colors.onSurface | Yes | colors.error |
| features/listing/screens/create_listing_form_screen.dart | 419 | Security Deposit | Theme Token | labelLarge |  | FontWeight.bold | colors.onSurface | Yes | colors.onSurface |
| features/listing/screens/create_listing_form_screen.dart | 496 | Pickup Location | Theme Token | labelLarge |  | FontWeight.bold | colors.onSurface | Yes | colors.onSurface |
| features/listing/screens/create_listing_form_screen.dart | 549 | Campus: ${school.name} | Theme Token | labelLarge |  | FontWeight.bold | colors.onSurface | Yes | colors.onSurface |
| features/listing/screens/create_listing_form_screen.dart | 586 | Available Date | Theme Token | labelLarge |  | FontWeight.bold | colors.onSurface | Yes | colors.onSurface |
| features/listing/screens/post_hub_screen.dart | 101 | Sell / Rent | Theme Token | headlineSmall |  | FontWeight.w800 | colors.onPrimary | No |  |
| features/listing/screens/post_hub_screen.dart | 119 | Create Listing | Theme Token | labelLarge |  | FontWeight.w700 | colors.onPrimary | No |  |
| features/listing/screens/post_hub_screen.dart | 165 | Carpool | Theme Token | headlineSmall |  | FontWeight.w800 | colors.onPrimary | No |  |
| features/listing/screens/listing_detail_screen.dart | 320 | Description | Theme Token | labelLarge |  | FontWeight.bold | colors.onSurface | Yes | colors.onSurface |
| features/listing/screens/listing_detail_screen.dart | 373 | Listing Rejected | Theme Token | titleMedium |  | FontWeight.bold | Theme.of( context | Yes | Theme.of(
                                                    context |
| features/listing/screens/listing_detail_screen.dart | 491 | Pickup Location | Theme Token | labelLarge |  | FontWeight.bold | colors.onSurface | Yes | colors.onSurface |
| features/listing/screens/listing_detail_screen.dart | 555 | Campus: ${school.name} | Theme Token | labelLarge |  |  | colors .onSurface | Yes | colors.onSurface |
| features/listing/screens/listing_detail_screen.dart | 583 | Available Date | Theme Token | labelLarge |  | FontWeight.bold | colors.onSurface | Yes | colors.onSurface |
| features/listing/screens/listing_detail_screen.dart | 704 | Campus: ${school.name} | Theme Token |  |  |  | colors .onSurface | Yes | colors
                                                                      .onSurface |
| features/listing/screens/listing_detail_screen.dart | 734 | Seller | Theme Token | labelLarge |  |  |  | No |  |
| features/listing/screens/listing_detail_screen.dart | 818 | Listing Stats | Theme Token | labelLarge |  | FontWeight.bold | colors.onSurface | Yes | colors.onSurface |
| features/listing/screens/listing_detail_screen.dart | 1220 | Item Unavailable | Theme Token | titleMedium |  | FontWeight.bold | colors.onSurface | Yes | colors.error |
| features/listing/screens/listing_detail_screen.dart | 1260 | Item Unavailable | Theme Token | titleMedium |  | FontWeight.bold |  | Yes | colors.outlineVariant |
| features/listing/widgets/photo_picker_section.dart | 39 | Add Photos | Theme Token | titleMedium |  | FontWeight.bold | colors.onSurface | Yes | colors.primary |
| features/listing/widgets/photo_picker_section.dart | 118 | COVER | Theme Token | labelSmall |  |  | Colors.white | No |  |
| features/listing/widgets/rental_options_section.dart | 120 | Rental Period | Theme Token | headlineSmall |  |  |  | No |  |
| features/listing/widgets/rental_options_section.dart | 168 | SECURITY DEPOSIT | Theme Token | labelSmall |  |  | colors.onSurface.withValues(alpha: 0.5 | Yes | colors.primary |
| features/listing/widgets/rental_options_section.dart | 319 | START DATE | Theme Token | labelSmall |  |  | colors.onSurface.withValues(alpha: 0.5 | No |  |
| features/listing/widgets/rental_options_section.dart | 364 | END DATE | Theme Token | labelSmall |  |  | colors.onSurface.withValues(alpha: 0.5 | No |  |
| features/listing/widgets/rental_options_section.dart | 431 | Rental Period: $periodText | Theme Token | bodyMedium |  |  | colors.onSurface | No |  |
| features/listing/widgets/rental_options_section.dart | 550 | START DATE | Theme Token | labelSmall |  |  | colors.onSurface.withValues(alpha: 0.5 | No |  |
| features/buyer/screens/buyer_center_screen.dart | 491 | Awaiting\nPickup | Theme Token | labelSmall |  | FontWeight.w700 | colors .surfaceContainerLowest | No |  |
| shared/widgets/pickup_address_selector.dart | 332 | Select pickup location | Theme Token | bodyMedium |  |  | colors.onSurfaceVariant | No |  |
