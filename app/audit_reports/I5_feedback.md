# I-5: Feedback Mechanism Audit Report
> Audit only — no source files were modified.
> Generated: 2026-05-16

---

## 1. API Documentation for Existing Dialog Widgets

### `ActionSuccessDialog` — `shared/widgets/action_success_dialog.dart`

```dart
class ActionSuccessDialog extends StatelessWidget {
  const ActionSuccessDialog({
    super.key,
    this.title = 'Success!',
    this.message = 'Submitted successfully. Under platform review.',
    this.buttonText = 'OK',
    this.onPressed,         // defaults to context.pop()
  });
```

| Parameter | Type | Default | Notes |
|-----------|------|---------|-------|
| `title` | `String` | `'Success!'` | Headline text |
| `message` | `String` | `'Submitted successfully. Under platform review.'` | Body text |
| `buttonText` | `String` | `'OK'` | Button label |
| `onPressed` | `VoidCallback?` | `null` → `context.pop()` | Override button action |

**Usage example:**
```dart
showDialog(
  context: context,
  builder: (ctx) => ActionSuccessDialog(
    title: 'Offer Accepted',
    message: 'The buyer has been notified.',
    buttonText: 'View Order',
    onPressed: () { Navigator.pop(ctx); context.pushNamed(AppRoutes.orderDetail, ...); },
  ),
);
```

---

### `ActionErrorDialog` — `shared/widgets/action_error_dialog.dart`

```dart
class ActionErrorDialog extends StatelessWidget {
  const ActionErrorDialog({
    super.key,
    this.title = 'Failed',
    this.message = 'An error occurred. Please try again.',
    this.buttonText = 'OK',
    this.onPressed,         // defaults to context.pop()
  });
```

| Parameter | Type | Default | Notes |
|-----------|------|---------|-------|
| `title` | `String` | `'Failed'` | Headline text |
| `message` | `String` | `'An error occurred. Please try again.'` | Body text |
| `buttonText` | `String` | `'OK'` | Button label |
| `onPressed` | `VoidCallback?` | `null` → `context.pop()` | Override button action |

**Usage example:**
```dart
showDialog(
  context: context,
  builder: (ctx) => ActionErrorDialog(
    title: 'Cannot Join Trip',
    message: 'This trip is now full.',
  ),
);
```

---

## 2. Complete Per-Occurrence Table

### SnackBar Occurrences (27 instances)

| # | File | Line # | Current Type | Message / Purpose | User Action Context | Migration Target | Priority |
|---|------|--------|-------------|-------------------|---------------------|-----------------|----------|
| S1 | `orders/screens/order_detail_screen.dart` | 23–24 | SnackBar | `'Action failed: ${next.error}'` — global order action error listener | After any order action fails | `ActionErrorDialog` | P1 |
| S2 | `orders/screens/rental_order_detail_screen.dart` | 1061–1062 | SnackBar | `'Item relisted — it's live on the marketplace again.'` — relist success | After relist button tapped | `ActionSuccessDialog` | P1 |
| S3 | `orders/screens/rental_order_detail_screen.dart` | 1072–1073 | SnackBar | `'Failed to relist. Please try again.'` — relist failure | After relist fails | `ActionErrorDialog` | P1 |
| S4 | `orders/screens/sale_order_detail_screen.dart` | 623–624 | SnackBar | `'Item relisted — it's live on the marketplace again.'` — relist success | After relist button tapped | `ActionSuccessDialog` | P1 |
| S5 | `orders/screens/sale_order_detail_screen.dart` | 634–635 | SnackBar | `'Failed to relist. Please try again.'` — relist failure | After relist fails | `ActionErrorDialog` | P1 |
| S6 | `orders/widgets/list_order_card.dart` | 204–206 | SnackBar | `'Error: $e'` — raw error on card action | After card swipe action fails | `ActionErrorDialog` | P1 |
| S7 | `orders/widgets/rental_extension_card.dart` | 395–396 | SnackBar | Extension submit failure with icon row | After submit extension fails | `ActionErrorDialog` | P1 |
| S8 | `orders/widgets/rental_extension_card.dart` | 673–674 | SnackBar | `'Extension rejected'` with red bg + icon | After seller rejects extension | `ActionErrorDialog` | P1 |
| S9 | `profile/screens/profile_setup_screen.dart` | 54–56 | SnackBar | `'Please enter your name'` — form validation | Before profile save | Keep as inline validation text | P2 |
| S10 | `seller/screens/transaction_management_screen.dart` | 929–932 | SnackBar | `'Offer accepted successfully'` | After seller accepts offer | `ActionSuccessDialog` | P1 |
| S11 | `seller/screens/transaction_management_screen.dart` | 944–947 | SnackBar | `'Failed to accept: $e'` | After offer acceptance fails | `ActionErrorDialog` | P1 |
| S12 | `settings/screens/debug_data_screen.dart` | 89–91 | SnackBar | `'Updated $key to $newVal'` — debug flag update | Debug/admin use only | Low priority — keep | P2 |
| S13 | `settings/screens/debug_data_screen.dart` | 95–97 | SnackBar | `'Failed to update: $e'` — debug error | Debug/admin use only | Low priority — keep | P2 |
| S14 | `settings/screens/debug_data_screen.dart` | 129–131 | SnackBar | `'Updated flag $key to $newVal'` — flag update | Debug/admin use only | Low priority — keep | P2 |
| S15 | `settings/screens/debug_data_screen.dart` | 135–137 | SnackBar | `'Failed to update setting: $e'` — debug error | Debug/admin use only | Low priority — keep | P2 |
| S16 | `settings/screens/edit_profile_screen.dart` | 481–482 | SnackBar | Error row with red bg — `_showError()` helper | After profile save fails | `ActionErrorDialog` | P1 |
| S17 | `settings/screens/my_feedbacks_screen.dart` | 86–87 | SnackBar | Feedback ban message (suspended until date / permanently) | When user tries to submit feedback while banned | `ActionErrorDialog` | P1 |
| S18 | `settings/screens/submit_feedback_screen.dart` | 57–58 | SnackBar | `'Please enter title and description'` — form validation | Before feedback submit | Keep as inline validation text | P2 |
| S19 | `settings/screens/submit_feedback_screen.dart` | 104–106 | SnackBar | `'Failed to submit: $e'` — submit error | After feedback submit fails | `ActionErrorDialog` | P1 |
| S20 | `settings/screens/system_settings_screen.dart` | 284–285 | SnackBar | `'Local cache cleared successfully'` with primary bg | After cache clear success | `ActionSuccessDialog` | P1 |
| S21 | `settings/screens/system_settings_screen.dart` | 296–297 | SnackBar | `'Failed to clear cache: $e'` with error bg | After cache clear fails | `ActionErrorDialog` | P1 |
| S22 | `settings/screens/trust_and_safety_screen.dart` | 171–174 | SnackBar | `'${user.displayName} unblocked.'` | After user unblock | `ActionSuccessDialog` | P1 |
| S23 | `shared/widgets/order_review_form.dart` | 49–50 | SnackBar | `'Failed to submit review: ${next.error}'` | After review submit fails | `ActionErrorDialog` | P1 |
| S24 | `shared/widgets/fullscreen_image_viewer.dart` | 53–54 | SnackBar | Permission error (photo library access) | On save attempt without permission | `ActionErrorDialog` | P1 |
| S25 | `shared/widgets/fullscreen_image_viewer.dart` | 71–72 | SnackBar | `'Cannot save without photo library access.'` | On save attempt | `ActionErrorDialog` | P1 |
| S26 | `shared/widgets/fullscreen_image_viewer.dart` | 90–91 | SnackBar | `'Image saved to gallery successfully!'` | After save success | `ActionSuccessDialog` | P1 |
| S27 | `shared/widgets/fullscreen_image_viewer.dart` | 96–97 | SnackBar | `'Failed to save image: $e'` | After save fails | `ActionErrorDialog` | P1 |
| S28 | `shared/widgets/report_dialog.dart` | 147–148 | SnackBar | `'Please provide a reason.'` — form validation inside dialog | Before report submit | Keep as inline text | P2 |
| S29 | `listing/screens/listing_detail_screen.dart` | ~2075 | SnackBar | Report submit error (raw exception message) | After report fails inside ReportDialog | `ActionErrorDialog` | P1 |

---

### System AlertDialog Occurrences (17 instances — P0)

| # | File | Line # | Current Type | Message / Purpose | User Action Context | Migration Target | Priority |
|---|------|--------|-------------|-------------------|---------------------|-----------------|----------|
| A1 | `carpool/screens/manage_trip_screen.dart` | 676–678 | AlertDialog (confirm) | `'Confirm Trip?'` — lock trip, notify members | Organizer taps Confirm Trip | `ThemedConfirmDialog` | P0 |
| A2 | `carpool/screens/manage_trip_screen.dart` | 978–980 | AlertDialog (confirm) | `'Reject Request'` — reject member join request | Organizer rejects member | `ThemedConfirmDialog` | P0 |
| A3 | `carpool/screens/manage_trip_screen.dart` | 891 (seller_center ref) | AlertDialog (info/custom) | Listing stats + cancelled offers info panel | Tapping listing in seller center | Custom info dialog — keep as is or extract widget | P0 |
| A4 | `chat/screens/chat_room_screen.dart` | 445–448 | AlertDialog (confirm) | `'Block User'` — confirm block action | User taps block icon | `ThemedConfirmDialog` | P0 |
| A5 | `listing/screens/listing_detail_screen.dart` | 137–140 | AlertDialog (info) | `'Delist Item'` — confirm delist with warning text | Seller taps Delist | `ThemedConfirmDialog` (destructive) | P0 |
| A6 | `listing/screens/listing_detail_screen.dart` | 1079–1086 | AlertDialog (confirm) | Cancel Application / Cancel Order confirmation | Buyer taps Cancel | `ThemedConfirmDialog` (destructive) | P0 |
| A7 | `listing/screens/listing_detail_screen.dart` | 2092–2095 | AlertDialog (confirm) | Block seller confirm | Buyer taps Block in listing detail | `ThemedConfirmDialog` | P0 |
| A8 | `orders/screens/rental_order_detail_screen.dart` | 908–911 | AlertDialog (custom) | Themed error dialog (`_showErrorDialog`) — icon, title, message with `colors.error` styling | After rental action fails | Replace with `ActionErrorDialog` | P0 |
| A9 | `orders/screens/rental_order_detail_screen.dart` | 969–972 | AlertDialog (confirm) | Generic `_showConfirmDialog(title, message)` helper — reused for pickup / return confirmations | Before delivery/return confirmation | `ThemedConfirmDialog` | P0 |
| A10 | `orders/screens/sale_order_detail_screen.dart` | 536–539 | AlertDialog (confirm) | Generic `_showConfirmDialog(title, message)` helper — confirm pickup | Before pickup confirmation | `ThemedConfirmDialog` | P0 |
| A11 | `orders/widgets/rental_extension_card.dart` | 587–590 | AlertDialog (confirm) | `'Approve Change'` — update dates and price | Seller taps Approve extension | `ThemedConfirmDialog` | P0 |
| A12 | `orders/widgets/rental_extension_card.dart` | 629–632 | AlertDialog (confirm+input) | `'Reject Change'` — with optional TextField for rejection note | Seller taps Reject extension | `ThemedConfirmDialog` (with input field variant) | P0 |
| A13 | `seller/screens/seller_center_screen.dart` | 1748–1751 | AlertDialog (info) | Listing stats panel (views, saves, offers, cancelled orders) | Tapping listing row in Seller Center | Custom info dialog — keep as is or extract | P0 |
| A14 | `seller/screens/transaction_management_screen.dart` | 891–894 | AlertDialog (confirm) | `'Accept Offer'` — accept with warning other offers cancelled | Seller taps Accept | `ThemedConfirmDialog` | P0 |
| A15 | `settings/screens/system_settings_screen.dart` | 254 | AlertDialog (loading) | `CircularProgressIndicator` inside showDialog — loading overlay | During cache clear | Keep — loading overlay pattern | P0 |
| A16 | `settings/widgets/address_management_section.dart` | 185 | AlertDialog (form) | Add/Edit address form inline dialog | User taps add/edit address | Keep — form dialog pattern (complex) | P0 |
| A17 | `settings/widgets/avatar_customization_dialog.dart` | 45 | AlertDialog (form) | Avatar style/seed customizer | User taps customize avatar | Keep — `AvatarCustomizationDialog` is a dedicated widget | P0 |

---

### Custom Dialog Occurrences (Already Correct — P3)

| # | File | Line # | Current Type | Message / Purpose | Priority |
|---|------|--------|-------------|-------------------|----------|
| C1 | `admin/screens/admin_dashboard_screen.dart` | 570 | `ActionSuccessDialog` | Test data cleared: N records deleted | P3 ✅ |
| C2 | `carpool/screens/carpool_detail_screen.dart` | 687 | `ActionErrorDialog` | Leave trip error | P3 ✅ |
| C3 | `carpool/screens/carpool_detail_screen.dart` | 755 | `ActionErrorDialog` | Trip full (NO_SEATS) error | P3 ✅ |
| C4 | `carpool/screens/carpool_detail_screen.dart` | 780 | `ActionErrorDialog` | Trip cancelled error | P3 ✅ |
| C5 | `carpool/screens/carpool_detail_screen.dart` | 821 | `ActionErrorDialog` | Cannot join trip (generic) | P3 ✅ |
| C6 | `carpool/screens/carpool_detail_screen.dart` | 890 | `ActionErrorDialog` | Request join error (NO_SEATS) | P3 ✅ |
| C7 | `carpool/screens/carpool_detail_screen.dart` | 900 | `ActionErrorDialog` | Trip cancelled error | P3 ✅ |
| C8 | `carpool/screens/carpool_detail_screen.dart` | 911 | `ActionErrorDialog` | Generic join error | P3 ✅ |
| C9 | `carpool/screens/create_carpool_screen.dart` | 175 | `ActionSuccessDialog` | Trip created successfully | P3 ✅ |
| C10 | `carpool/screens/create_carpool_screen.dart` | 184 | `ActionErrorDialog` | Create trip error | P3 ✅ |
| C11 | `carpool/screens/manage_trip_screen.dart` | 252 | `ActionErrorDialog` | No changes to save | P3 ✅ |
| C12 | `carpool/screens/manage_trip_screen.dart` | 266 | `ActionErrorDialog` | Cannot modify — wrong status | P3 ✅ |
| C13 | `carpool/screens/manage_trip_screen.dart` | 285 | `ActionSuccessDialog` | Trip updated successfully | P3 ✅ |
| C14 | `carpool/screens/manage_trip_screen.dart` | 295 | `ActionErrorDialog` | Update failed | P3 ✅ |
| C15 | `carpool/screens/manage_trip_screen.dart` | 707 | `ActionErrorDialog` | Cannot confirm — wrong status | P3 ✅ |
| C16 | `carpool/screens/manage_trip_screen.dart` | 721 | `ActionSuccessDialog` | Trip confirmed successfully | P3 ✅ |
| C17 | `carpool/screens/manage_trip_screen.dart` | 737 | `ActionErrorDialog` | Failed to confirm | P3 ✅ |
| C18 | `carpool/screens/manage_trip_screen.dart` | 960 | `ActionSuccessDialog` | Member approved | P3 ✅ |
| C19 | `carpool/screens/manage_trip_screen.dart` | 969 | `ActionErrorDialog` | Failed to approve | P3 ✅ |
| C20 | `carpool/screens/manage_trip_screen.dart` | 1011 | `ActionSuccessDialog` | Settlement success | P3 ✅ |
| C21 | `carpool/screens/manage_trip_screen.dart` | 1020 | `ActionErrorDialog` | Settlement failed | P3 ✅ |
| C22 | `carpool/widgets/calendar_sync_button.dart` | 51 | `ActionSuccessDialog` | Added to system calendar | P3 ✅ |
| C23 | `carpool/widgets/calendar_sync_button.dart` | 60 | `ActionErrorDialog` | Calendar sync failed | P3 ✅ |
| C24 | `chat/screens/chat_room_screen.dart` | 789 | `ReportDialog` | Report chat | P3 ✅ |
| C25 | `chat/screens/chat_room_screen.dart` | 828 | `ActionSuccessDialog` | Report submitted | P3 ✅ |
| C26 | `listing/screens/create_listing_form_screen.dart` | 970 | `ActionSuccessDialog` | Listing created | P3 ✅ |
| C27 | `listing/screens/listing_detail_screen.dart` | 93 | `ActionSuccessDialog` | Listing saved/unsaved success | P3 ✅ |
| C28 | `listing/screens/listing_detail_screen.dart` | 2043 | `ReportDialog` | Report listing | P3 ✅ |
| C29 | `listing/screens/listing_detail_screen.dart` | 2065 | `ActionSuccessDialog` | Report submitted | P3 ✅ |
| C30 | `orders/widgets/rental_extension_card.dart` | 386 | `ActionSuccessDialog` | Extension submitted | P3 ✅ |
| C31 | `orders/widgets/rental_extension_card.dart` | 618 | `ActionSuccessDialog` | Extension approved | P3 ✅ |
| C32 | `orders/widgets/rental_reminder_settings.dart` | 87 | `ActionSuccessDialog` | Reminder preferences saved | P3 ✅ |
| C33 | `settings/screens/edit_profile_screen.dart` | 472 | `ActionSuccessDialog` | Profile updated (via `_showSuccess` helper — but wrong message "Under platform review") | P3 ⚠️ wrong message |
| C34 | `settings/screens/submit_feedback_screen.dart` | 92 | `ActionSuccessDialog` | Feedback submitted | P3 ✅ |
| C35 | `shared/widgets/order_review_form.dart` | 56 | `ActionSuccessDialog` | Review submitted | P3 ✅ |
| C36 | `carpool/screens/carpool_detail_screen.dart` | note L17 | — | Comment says ActionSuccessDialog removed — review uses SnackBar instead | ⚠️ regression noted |

---

### ModalBottomSheet Occurrences (12 instances)

| # | File | Line # | Purpose | Migration Target | Priority |
|---|------|--------|---------|-----------------|----------|
| B1 | `carpool/screens/arrival_confirmation_screen.dart` | 150 | Review batch sheet (ReviewBatchSheet) | Keep — complex multi-step sheet | Keep |
| B2 | `carpool/screens/carpool_detail_screen.dart` | 499 | Join trip confirmation sheet | Keep — used for legal disclaimer | Keep |
| B3 | `carpool/screens/carpool_detail_screen.dart` | 607 | Leave trip confirmation sheet | Keep — inline content | Keep |
| B4 | `carpool/screens/create_carpool_screen.dart` | 46 | Legal disclaimer sheet | Keep — `LegalDisclaimerDialog` pattern | Keep |
| B5 | `carpool/screens/group_chat_screen.dart` | 110 | Chat options bottom sheet | Keep — action sheet | Keep |
| B6 | `carpool/screens/manage_trip_screen.dart` | 102 | Trip edit form sheet | Keep — complex form | Keep |
| B7 | `carpool/screens/trip_proposals_screen.dart` | 107 | Proposal vote sheet | Keep — complex | Keep |
| B8 | `orders/widgets/transaction_snapshot_modal.dart` | 31 | Order snapshot info | Keep — complex info sheet | Keep |
| B9 | `settings/screens/edit_profile_screen.dart` | 388 | Avatar picker sheet (camera/gallery/customize) | Keep — action sheet | Keep |
| B10 | `settings/widgets/delete_account_bottom_sheet.dart` | 21 | Delete account confirmation with text | Keep — content too long for dialog | Keep |
| B11 | `shared/widgets/user_rating_badge.dart` | 32 | User rating details sheet | Keep — info sheet | Keep |
| B12 | `shared/widgets/smivo_user_avatar.dart` | 56 | User profile preview sheet | Keep — info sheet | Keep |

---

## 3. Summary

| Type | Count |
|------|-------|
| **SnackBar** | **29** |
| **System AlertDialog (P0 — must replace)** | **17** |
| **ActionSuccessDialog** (already correct ✅) | **18** |
| **ActionErrorDialog** (already correct ✅) | **17** |
| **ReportDialog** (keep as-is ✅) | **2** |
| **ModalBottomSheet** (keep as-is ✅) | **12** |

---

## 4. Files Requiring `ThemedConfirmDialog`

The following files contain `showDialog` + `AlertDialog` used exclusively as **confirm/cancel** patterns. These are the highest-priority targets for the new `ThemedConfirmDialog` component:

| File | Instances | Confirm Scenarios |
|------|-----------|-------------------|
| `carpool/screens/manage_trip_screen.dart` | 2 | Confirm trip lock, Reject member request |
| `chat/screens/chat_room_screen.dart` | 1 | Block user |
| `listing/screens/listing_detail_screen.dart` | 2 | Delist item, Cancel order, Block seller |
| `orders/screens/rental_order_detail_screen.dart` | 1 | Confirm delivery/return (generic helper) |
| `orders/screens/sale_order_detail_screen.dart` | 1 | Confirm pickup (generic helper) |
| `orders/widgets/rental_extension_card.dart` | 2 | Approve change, Reject change (with text input) |
| `seller/screens/transaction_management_screen.dart` | 1 | Accept offer |

**Special case:** `rental_extension_card.dart` L629 needs a `ThemedConfirmDialog` variant with an optional `TextField` input for the rejection note.

---

## 5. Estimated Change Count Per File

| File | SnackBar→Replace | AlertDialog→Replace | Total Changes |
|------|-----------------|---------------------|---------------|
| `orders/screens/order_detail_screen.dart` | 1 | — | 1 |
| `orders/screens/rental_order_detail_screen.dart` | 2 | 2 | 4 |
| `orders/screens/sale_order_detail_screen.dart` | 2 | 1 | 3 |
| `orders/widgets/list_order_card.dart` | 1 | — | 1 |
| `orders/widgets/rental_extension_card.dart` | 2 | 2 | 4 |
| `seller/screens/transaction_management_screen.dart` | 2 | 1 | 3 |
| `seller/screens/seller_center_screen.dart` | — | 1 (info panel — low priority) | 1 |
| `settings/screens/edit_profile_screen.dart` | 1 | — | 1 |
| `settings/screens/my_feedbacks_screen.dart` | 1 | — | 1 |
| `settings/screens/submit_feedback_screen.dart` | 2 | — | 2 |
| `settings/screens/system_settings_screen.dart` | 2 | 1 (loading) | 3 |
| `settings/screens/trust_and_safety_screen.dart` | 1 | — | 1 |
| `shared/widgets/order_review_form.dart` | 1 | — | 1 |
| `shared/widgets/fullscreen_image_viewer.dart` | 4 | — | 4 |
| `listing/screens/listing_detail_screen.dart` | 1 | 3 | 4 |
| `chat/screens/chat_room_screen.dart` | — | 1 | 1 |
| `carpool/screens/manage_trip_screen.dart` | — | 2 | 2 |
| **TOTAL** | **23** | **14** | **37** |

---

## 6. Notable Issues / Anomalies

1. **`edit_profile_screen.dart` L472** — `ActionSuccessDialog` used but `_showSuccess()` hard-codes `'Submitted successfully. Under platform review.'` as the message regardless of what was actually updated. Should pass the actual `message` parameter.

2. **`carpool_detail_screen.dart` L17 comment** — explicitly notes `ActionSuccessDialog` was removed and replaced with SnackBar for review completion. This is a regression — should be reverted to use `ActionSuccessDialog`.

3. **`rental_order_detail_screen.dart` L908** — a locally-crafted themed error dialog (`_showErrorDialog` helper) that mimics `ActionErrorDialog` but duplicates its implementation. Should be replaced with `ActionErrorDialog` directly.

4. **`seller_center_screen.dart` L1748** — uses raw `AlertDialog` as an info panel (listing stats). This is not a confirm/cancel pattern — it needs a custom info sheet or a new `ThemedInfoDialog` variant.

5. **`profile_setup_screen.dart` L54** — SnackBar for form validation (`'Please enter your name'`). Should be replaced with inline error text, not a dialog.
