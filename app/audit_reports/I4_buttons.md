# I-4: Button Styles Audit Report

## 1. Summary by Category
- **Primary/Submit**: 28
- **Secondary**: 7
- **Destructive**: 184
- **Neutral/Dismiss**: 9
- **Unclear**: 112

## 2. Style Usage Summary
- **Correctly styled (Uses Theme/Default)**: 254
- **Needing fix (Hardcoded styles)**: 86

## 3. Recommended Canonical Styles

- **Primary/Submit**: `FilledButton` or `ElevatedButton` with `theme.colorScheme.primary` as the background color and `theme.colorScheme.onPrimary` as the foreground. No hardcoded colors.
- **Secondary**: `OutlinedButton` with `theme.colorScheme.primary` for the border and foreground color.
- **Destructive**: `OutlinedButton` or `TextButton` with `theme.colorScheme.error` for the border and foreground color. Alternatively, `FilledButton` with `theme.colorScheme.error` background.
- **Neutral/Dismiss**: `TextButton` with default foreground color or a muted color like `theme.colorScheme.onSurface.withOpacity(0.6)`.

## 4. Complete Button Table

| File | Line # | Widget Type | Label/Action Text | Semantic Category | Current Style | Uses Theme? | Issues |
|------|--------|-------------|-------------------|-------------------|---------------|-------------|--------|
| `features/seller/screens/seller_center_screen.dart` | 116 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/seller/screens/seller_center_screen.dart` | 1467 | `InkWell` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/seller/screens/seller_center_screen.dart` | 1599 | `InkWell` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/seller/screens/seller_center_screen.dart` | 1792 | `TextButton` | Close | Neutral/Dismiss | Custom (Hardcoded) | No | Hardcoded style |
| `features/seller/screens/transaction_management_screen.dart` | 50 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/seller/screens/transaction_management_screen.dart` | 321 | `TextButton` | Chat | Secondary | Default | Yes |  |
| `features/seller/screens/transaction_management_screen.dart` | 525 | `TextButton` | Chat | Secondary | Default | Yes |  |
| `features/seller/screens/transaction_management_screen.dart` | 851 | `TextButton` | Chat | Secondary | Default | Yes |  |
| `features/seller/screens/transaction_management_screen.dart` | 900 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/seller/screens/transaction_management_screen.dart` | 906 | `TextButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/seller/screens/transaction_management_screen.dart` | 910 | `TextButton` | Accept | Primary/Submit | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/screens/settings_screen.dart` | 149 | `OutlinedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/settings/screens/settings_screen.dart` | 164 | `OutlinedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/screens/settings_screen.dart` | 204 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/settings/screens/system_settings_screen.dart` | 491 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/settings/screens/system_settings_screen.dart` | 636 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/settings/screens/debug_data_screen.dart` | 159 | `IconButton` | Icon | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/screens/debug_data_screen.dart` | 167 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/settings/screens/trust_and_safety_screen.dart` | 32 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/settings/screens/trust_and_safety_screen.dart` | 162 | `TextButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/settings/screens/trust_and_safety_screen.dart` | 182 | `TextButton` | Unblock | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/screens/submit_feedback_screen.dart` | 230 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/settings/screens/submit_feedback_screen.dart` | 249 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/settings/screens/submit_feedback_screen.dart` | 285 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/screens/submit_feedback_screen.dart` | 287 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/screens/edit_profile_screen.dart` | 324 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/settings/screens/edit_profile_screen.dart` | 353 | `TextButton` | Delete Account | Destructive | Default | Yes |  |
| `features/settings/screens/help_screen.dart` | 92 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/arrival_confirmation_screen.dart` | 106 | `ElevatedButton` | Yes | Primary/Submit | Default | Yes |  |
| `features/carpool/screens/arrival_confirmation_screen.dart` | 113 | `OutlinedButton` | Not yet | Destructive | Default | Yes |  |
| `features/carpool/screens/group_chat_screen.dart` | 166 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/group_chat_screen.dart` | 367 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/carpool_list_screen.dart` | 190 | `TextButton` | Clear Filters | Neutral/Dismiss | Default | Yes |  |
| `features/carpool/screens/carpool_list_screen.dart` | 233 | `ElevatedButton` | Retry | Primary/Submit | Default | Yes |  |
| `features/carpool/screens/carpool_list_screen.dart` | 287 | `InkWell` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/carpool_list_screen.dart` | 476 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/carpool_list_screen.dart` | 533 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/trip_proposals_screen.dart` | 84 | `ElevatedButton` | Retry | Primary/Submit | Default | Yes |  |
| `features/carpool/screens/trip_proposals_screen.dart` | 355 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 379 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 393 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 467 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 487 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 585 | `ElevatedButton` | Retry | Primary/Submit | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 660 | `ElevatedButton` | Confirm Trip | Primary/Submit | Custom (Hardcoded) | No | Hardcoded style |
| `features/carpool/screens/manage_trip_screen.dart` | 664 | `ElevatedButton` | Confirm Trip | Primary/Submit | Custom (Theme) | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 685 | `TextButton` | Wait | Neutral/Dismiss | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 689 | `TextButton` | Yes | Primary/Submit | Custom (Theme) | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 691 | `TextButton` | Yes | Primary/Submit | Custom (Theme) | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 860 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 866 | `IconButton` | Icon | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `features/carpool/screens/manage_trip_screen.dart` | 869 | `IconButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/carpool/screens/manage_trip_screen.dart` | 903 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 912 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 922 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 987 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 991 | `TextButton` | Reject | Destructive | Custom (Theme) | Yes |  |
| `features/carpool/screens/manage_trip_screen.dart` | 993 | `TextButton` | Reject | Destructive | Custom (Theme) | Yes |  |
| `features/carpool/screens/create_carpool_screen.dart` | 313 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/create_carpool_screen.dart` | 327 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/create_carpool_screen.dart` | 424 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/create_carpool_screen.dart` | 444 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 59 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 384 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 479 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 569 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 587 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 679 | `OutlinedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 696 | `OutlinedButton` | Cancel Trip | Destructive | Custom (Theme) | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 707 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 730 | `OutlinedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 738 | `TextButton` | Wait | Neutral/Dismiss | Custom (Theme) | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 739 | `TextButton` | Wait | Neutral/Dismiss | Custom (Theme) | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 741 | `TextButton` | Yes | Primary/Submit | Custom (Theme) | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 764 | `OutlinedButton` | Cancel Request | Primary/Submit | Custom (Theme) | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 771 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 796 | `OutlinedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 804 | `TextButton` | Wait | Neutral/Dismiss | Custom (Theme) | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 805 | `TextButton` | Wait | Neutral/Dismiss | Custom (Theme) | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 807 | `TextButton` | Yes | Primary/Submit | Custom (Theme) | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 830 | `OutlinedButton` | Leave Trip | Destructive | Custom (Theme) | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 840 | `ElevatedButton` | Application submitted | Primary/Submit | Default | Yes |  |
| `features/carpool/screens/carpool_detail_screen.dart` | 871 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/chat/screens/chat_list_screen.dart` | 234 | `ElevatedButton` | Retry | Primary/Submit | Default | Yes |  |
| `features/chat/screens/chat_list_screen.dart` | 429 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/chat/screens/chat_list_screen.dart` | 462 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/chat/screens/chat_room_screen.dart` | 349 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/chat/screens/chat_room_screen.dart` | 422 | `TextButton` | 
 | Unclear | Default | Yes |  |
| `features/chat/screens/chat_room_screen.dart` | 442 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/chat/screens/chat_room_screen.dart` | 459 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/chat/screens/chat_room_screen.dart` | 463 | `TextButton` | Block | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/chat/screens/chat_room_screen.dart` | 712 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/chat/screens/chat_room_screen.dart` | 742 | `IconButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/auth/screens/register_screen.dart` | 63 | `TextButton` | OK | Unclear | Default | Yes |  |
| `features/auth/screens/register_screen.dart` | 258 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/auth/screens/register_screen.dart` | 605 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/auth/screens/register_screen.dart` | 607 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/auth/screens/login_screen.dart` | 208 | `IconButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/auth/screens/login_screen.dart` | 479 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/auth/screens/login_screen.dart` | 481 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/auth/screens/login_screen.dart` | 551 | `OutlinedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/auth/screens/login_screen.dart` | 555 | `OutlinedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/auth/screens/email_verification_screen.dart` | 73 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/auth/screens/email_verification_screen.dart` | 222 | `TextButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/auth/screens/email_verification_screen.dart` | 224 | `TextButton` | 
 | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `features/auth/screens/forgot_password_screen.dart` | 143 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/auth/screens/forgot_password_screen.dart` | 346 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/auth/screens/forgot_password_screen.dart` | 348 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_users_screen.dart` | 41 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_users_screen.dart` | 113 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_users_screen.dart` | 299 | `TextButton` | Close | Neutral/Dismiss | Default | Yes |  |
| `features/admin/screens/admin_roles_screen.dart` | 44 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_roles_screen.dart` | 49 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_roles_screen.dart` | 181 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_roles_screen.dart` | 185 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_roles_screen.dart` | 194 | `FilledButton` | Remove | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_roles_screen.dart` | 292 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_roles_screen.dart` | 296 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_roles_screen.dart` | 424 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_roles_screen.dart` | 428 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_roles_screen.dart` | 536 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_roles_screen.dart` | 540 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_listings_screen.dart` | 41 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_dictionary_screen.dart` | 45 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_dictionary_screen.dart` | 50 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_dictionary_screen.dart` | 239 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_dictionary_screen.dart` | 251 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_dictionary_screen.dart` | 327 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_dictionary_screen.dart` | 331 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_dictionary_screen.dart` | 340 | `FilledButton` | Delete | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_dictionary_screen.dart` | 504 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_dictionary_screen.dart` | 508 | `FilledButton` | isEditing ? 'Save' : 'Add | Primary/Submit | Default | Yes |  |
| `features/admin/screens/admin_faqs_screen.dart` | 51 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_faqs_screen.dart` | 56 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_faqs_screen.dart` | 274 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_faqs_screen.dart` | 284 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_faqs_screen.dart` | 332 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_faqs_screen.dart` | 336 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_faqs_screen.dart` | 343 | `FilledButton` | Delete | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_faqs_screen.dart` | 480 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_faqs_screen.dart` | 484 | `FilledButton` | isEditing ? 'Save' : 'Add | Primary/Submit | Default | Yes |  |
| `features/admin/screens/admin_orders_screen.dart` | 40 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_shell_screen.dart` | 58 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_login_screen.dart` | 149 | `FilledButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_login_screen.dart` | 151 | `FilledButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_login_screen.dart` | 183 | `TextButton` | Back to Smivo | Secondary | Default | Yes |  |
| `features/admin/screens/admin_schools_screen.dart` | 27 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_schools_screen.dart` | 118 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_schools_screen.dart` | 131 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_schools_screen.dart` | 189 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_schools_screen.dart` | 193 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_schools_screen.dart` | 200 | `FilledButton` | Delete | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_schools_screen.dart` | 495 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_schools_screen.dart` | 499 | `FilledButton` | isEditing ? 'Save' : 'Add | Primary/Submit | Default | Yes |  |
| `features/admin/screens/admin_dashboard_screen.dart` | 38 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_dashboard_screen.dart` | 233 | `FilledButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_dashboard_screen.dart` | 241 | `FilledButton` | Clear Data | Neutral/Dismiss | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_dashboard_screen.dart` | 501 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_dashboard_screen.dart` | 508 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_dashboard_screen.dart` | 517 | `FilledButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_dashboard_screen.dart` | 645 | `TextButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_dashboard_screen.dart` | 653 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_dashboard_screen.dart` | 836 | `InkWell` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_pickup_locations_screen.dart` | 46 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_pickup_locations_screen.dart` | 139 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_pickup_locations_screen.dart` | 199 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_pickup_locations_screen.dart` | 207 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_pickup_locations_screen.dart` | 250 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_pickup_locations_screen.dart` | 254 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_pickup_locations_screen.dart` | 264 | `FilledButton` | Delete | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_pickup_locations_screen.dart` | 365 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_pickup_locations_screen.dart` | 369 | `FilledButton` | isEditing ? 'Save' : 'Add | Primary/Submit | Default | Yes |  |
| `features/admin/screens/admin_categories_screen.dart` | 45 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_categories_screen.dart` | 140 | `FilledButton` | Seed Defaults | Unclear | Default | Yes |  |
| `features/admin/screens/admin_categories_screen.dart` | 189 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_categories_screen.dart` | 198 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_categories_screen.dart` | 241 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_categories_screen.dart` | 245 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_categories_screen.dart` | 255 | `FilledButton` | Delete | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_categories_screen.dart` | 386 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_categories_screen.dart` | 390 | `FilledButton` | isEditing ? 'Save' : 'Add | Primary/Submit | Default | Yes |  |
| `features/admin/screens/admin_review_tags_screen.dart` | 59 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_review_tags_screen.dart` | 63 | `TextButton` | Delete | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_review_tags_screen.dart` | 65 | `TextButton` | Delete | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_review_tags_screen.dart` | 99 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_review_tags_screen.dart` | 177 | `FilledButton` | Add Tag | Unclear | Default | Yes |  |
| `features/admin/screens/admin_review_tags_screen.dart` | 251 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_conditions_screen.dart` | 45 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_conditions_screen.dart` | 136 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_conditions_screen.dart` | 196 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_conditions_screen.dart` | 204 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/admin/screens/admin_conditions_screen.dart` | 247 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_conditions_screen.dart` | 251 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/admin/screens/admin_conditions_screen.dart` | 261 | `FilledButton` | Delete | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/admin/screens/admin_conditions_screen.dart` | 386 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/admin/screens/admin_conditions_screen.dart` | 390 | `FilledButton` | isEditing ? 'Save' : 'Add | Primary/Submit | Default | Yes |  |
| `features/profile/screens/profile_setup_screen.dart` | 105 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/profile/screens/profile_setup_screen.dart` | 189 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/profile/screens/profile_setup_screen.dart` | 192 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/orders_screen.dart` | 227 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/orders/screens/rental_order_detail_screen.dart` | 391 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/orders/screens/rental_order_detail_screen.dart` | 398 | `ElevatedButton` | isActing
 | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/rental_order_detail_screen.dart` | 678 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/orders/screens/rental_order_detail_screen.dart` | 687 | `ElevatedButton` | isActing ? 'Processing...' : 'Request Return | Primary/Submit | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/rental_order_detail_screen.dart` | 716 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/orders/screens/rental_order_detail_screen.dart` | 728 | `ElevatedButton` | isActing ? 'Processing...' : 'Confirm Return | Primary/Submit | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/rental_order_detail_screen.dart` | 764 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/orders/screens/rental_order_detail_screen.dart` | 777 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/rental_order_detail_screen.dart` | 852 | `OutlinedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/orders/screens/rental_order_detail_screen.dart` | 888 | `OutlinedButton` | 
 | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/rental_order_detail_screen.dart` | 948 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/rental_order_detail_screen.dart` | 950 | `ElevatedButton` | OK | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/rental_order_detail_screen.dart` | 976 | `TextButton` | No | Destructive | Default | Yes |  |
| `features/orders/screens/rental_order_detail_screen.dart` | 980 | `TextButton` | Yes | Primary/Submit | Default | Yes |  |
| `features/orders/screens/rental_order_detail_screen.dart` | 1035 | `TextButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/rental_order_detail_screen.dart` | 1036 | `TextButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/sale_order_detail_screen.dart` | 243 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/orders/screens/sale_order_detail_screen.dart` | 250 | `ElevatedButton` | isActing ? 'Processing...' : 'Confirm Pickup | Primary/Submit | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/sale_order_detail_screen.dart` | 500 | `OutlinedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/orders/screens/sale_order_detail_screen.dart` | 516 | `OutlinedButton` | 
 | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/sale_order_detail_screen.dart` | 543 | `TextButton` | No | Destructive | Default | Yes |  |
| `features/orders/screens/sale_order_detail_screen.dart` | 547 | `TextButton` | Yes | Primary/Submit | Default | Yes |  |
| `features/orders/screens/sale_order_detail_screen.dart` | 600 | `TextButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/sale_order_detail_screen.dart` | 601 | `TextButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/screens/order_detail_screen.dart` | 38 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/listing/screens/create_listing_form_screen.dart` | 122 | `TextButton` | Go Back | Secondary | Default | Yes |  |
| `features/listing/screens/create_listing_form_screen.dart` | 670 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/listing/screens/create_listing_form_screen.dart` | 675 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/listing/screens/post_hub_screen.dart` | 223 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 147 | `TextButton` | Keep Listed | Unclear | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 151 | `TextButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 168 | `TextButton` | Delist | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/listing/screens/listing_detail_screen.dart` | 906 | `OutlinedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 923 | `OutlinedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/listing/screens/listing_detail_screen.dart` | 1077 | `OutlinedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 1100 | `TextButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 1111 | `TextButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 1118 | `TextButton` | 
 | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `features/listing/screens/listing_detail_screen.dart` | 1162 | `OutlinedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/listing/screens/listing_detail_screen.dart` | 1353 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 1783 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/listing/screens/listing_detail_screen.dart` | 1853 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 1898 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 1958 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 2106 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/listing/screens/listing_detail_screen.dart` | 2111 | `TextButton` | Block | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/listing/screens/listing_detail_screen.dart` | 2324 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/notifications/screens/notification_center_screen.dart` | 47 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/notifications/screens/notification_center_screen.dart` | 70 | `TextButton` | Mark Read | Unclear | Default | Yes |  |
| `features/notifications/screens/notification_center_screen.dart` | 159 | `TextButton` | Mark Read | Unclear | Default | Yes |  |
| `features/notifications/screens/notification_center_screen.dart` | 286 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/buyer/screens/buyer_center_screen.dart` | 96 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/buyer/screens/buyer_center_screen.dart` | 369 | `InkWell` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/settings/widgets/avatar_customization_dialog.dart` | 98 | `ElevatedButton` | Randomize | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/widgets/avatar_customization_dialog.dart` | 102 | `ElevatedButton` | Randomize | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/widgets/avatar_customization_dialog.dart` | 117 | `TextButton` | Cancel | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/widgets/avatar_customization_dialog.dart` | 121 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/widgets/avatar_customization_dialog.dart` | 123 | `ElevatedButton` | Save Avatar | Primary/Submit | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/widgets/address_management_section.dart` | 77 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/settings/widgets/address_management_section.dart` | 233 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/settings/widgets/address_management_section.dart` | 250 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/settings/widgets/address_management_section.dart` | 261 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/settings/widgets/address_management_section.dart` | 272 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/settings/widgets/address_management_section.dart` | 366 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/settings/widgets/address_management_section.dart` | 370 | `FilledButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/settings/widgets/delete_account_bottom_sheet.dart` | 184 | `OutlinedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/widgets/delete_account_bottom_sheet.dart` | 186 | `OutlinedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/widgets/delete_account_bottom_sheet.dart` | 205 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/widgets/delete_account_bottom_sheet.dart` | 207 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/widgets/delete_account_bottom_sheet.dart` | 277 | `IconButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/settings/widgets/delete_account_bottom_sheet.dart` | 389 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/settings/widgets/delete_account_bottom_sheet.dart` | 391 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/home/widgets/home_category_chips.dart` | 81 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/home/widgets/home_search_bar.dart` | 51 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/home/widgets/home_header.dart` | 136 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/home/widgets/home_header.dart` | 179 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/widgets/legal_disclaimer_dialog.dart` | 57 | `TextButton` | Decline | Destructive | Default | Yes |  |
| `features/carpool/widgets/legal_disclaimer_dialog.dart` | 61 | `ElevatedButton` | Agree & Continue | Primary/Submit | Default | Yes |  |
| `features/carpool/widgets/proposal_card.dart` | 153 | `OutlinedButton` | Reject | Destructive | Custom (Theme) | Yes |  |
| `features/carpool/widgets/proposal_card.dart` | 155 | `OutlinedButton` | Reject | Destructive | Custom (Theme) | Yes |  |
| `features/carpool/widgets/proposal_card.dart` | 161 | `ElevatedButton` | Approve | Unclear | Default | Yes |  |
| `features/carpool/widgets/review_batch_sheet.dart` | 194 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/widgets/review_batch_sheet.dart` | 258 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/carpool/widgets/group_chat_list_tile.dart` | 43 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/widgets/trip_timeline.dart` | 430 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/widgets/calendar_sync_button.dart` | 75 | `TextButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/carpool/widgets/calendar_sync_button.dart` | 85 | `TextButton` | _hasSynced ? 'Update Calendar' : 'Add to Calendar | Unclear | Default | Yes |  |
| `features/chat/widgets/chat_list_item.dart` | 84 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/chat/widgets/chat_popup.dart` | 332 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/chat/widgets/chat_popup.dart` | 535 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/shared/widgets/order_review_form.dart` | 88 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/shared/widgets/order_review_form.dart` | 158 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/shared/widgets/order_review_form.dart` | 175 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/widgets/rental_reminder_settings.dart` | 263 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/widgets/rental_reminder_settings.dart` | 265 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/widgets/order_card.dart` | 348 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/orders/widgets/order_card.dart` | 364 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/widgets/transaction_snapshot_modal.dart` | 91 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/orders/widgets/evidence_photo_section.dart` | 83 | `OutlinedButton` | Icon | Unclear | Default | Yes |  |
| `features/orders/widgets/list_order_card.dart` | 134 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/orders/widgets/list_order_card.dart` | 145 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/orders/widgets/list_order_card.dart` | 160 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/orders/widgets/rental_extension_card.dart` | 140 | `OutlinedButton` | Adjust Rental Period | Secondary | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/widgets/rental_extension_card.dart` | 142 | `OutlinedButton` | Adjust Rental Period | Secondary | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/widgets/rental_extension_card.dart` | 197 | `IconButton` | Icon | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/widgets/rental_extension_card.dart` | 229 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/orders/widgets/rental_extension_card.dart` | 245 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `features/orders/widgets/rental_extension_card.dart` | 328 | `ElevatedButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/orders/widgets/rental_extension_card.dart` | 339 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/widgets/rental_extension_card.dart` | 517 | `TextButton` | Reject | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/widgets/rental_extension_card.dart` | 524 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/widgets/rental_extension_card.dart` | 526 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `features/orders/widgets/rental_extension_card.dart` | 596 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/orders/widgets/rental_extension_card.dart` | 600 | `TextButton` | Approve | Unclear | Default | Yes |  |
| `features/orders/widgets/rental_extension_card.dart` | 650 | `TextButton` | Cancel | Destructive | Default | Yes |  |
| `features/orders/widgets/rental_extension_card.dart` | 654 | `TextButton` | Reject | Destructive | Default | Yes |  |
| `features/listing/widgets/photo_picker_section.dart` | 19 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/listing/widgets/photo_picker_section.dart` | 67 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/listing/widgets/photo_picker_section.dart` | 127 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/listing/widgets/rental_options_section.dart` | 215 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/listing/widgets/rental_options_section.dart` | 462 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `features/notifications/widgets/notification_list_item.dart` | 23 | `InkWell` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `shared/widgets/custom_app_bar.dart` | 31 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `shared/widgets/fullscreen_image_viewer.dart` | 121 | `IconButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `shared/widgets/navigation_rail_bar.dart` | 83 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `shared/widgets/navigation_rail_bar.dart` | 128 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `shared/widgets/action_error_dialog.dart` | 43 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `shared/widgets/action_error_dialog.dart` | 45 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `shared/widgets/action_success_dialog.dart` | 43 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `shared/widgets/action_success_dialog.dart` | 45 | `ElevatedButton` | Unknown/Dynamic | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `shared/widgets/address_combobox.dart` | 150 | `IconButton` | Icon | Unclear | Custom (Hardcoded) | No | Hardcoded style |
| `shared/widgets/message_badge_icon.dart` | 15 | `IconButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `shared/widgets/smivo_user_identity.dart` | 96 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `shared/widgets/report_dialog.dart` | 130 | `TextButton` | Cancel | Destructive | Custom (Hardcoded) | No | Hardcoded style |
| `shared/widgets/report_dialog.dart` | 139 | `TextButton` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `shared/widgets/floating_quick_nav.dart` | 303 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `shared/widgets/app_error_widget.dart` | 41 | `OutlinedButton` | Retry | Primary/Submit | Default | Yes |  |
| `shared/widgets/collapsing_title_app_bar.dart` | 26 | `IconButton` | Icon | Unclear | Default | Yes |  |
| `shared/widgets/bottom_nav_bar.dart` | 58 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
| `shared/widgets/bottom_nav_bar.dart` | 129 | `GestureDetector` | Unknown/Dynamic | Destructive | Default | Yes |  |
