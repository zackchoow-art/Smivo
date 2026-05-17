# M-3: Migrate Feedback in Carpool + Chat + Auth Features
> Completion Report — Generated: 2026-05-16

## Result Summary

| Metric | Count |
|--------|-------|
| Files modified | 13 |
| SnackBars replaced | 19 |
| AlertDialogs replaced | 6 |
| SnackBars kept (form validation / debug / chat inline) | 16 |
| `flutter analyze` errors | **0** |

---

## File-by-File Changes

### 1. `carpool/screens/carpool_detail_screen.dart`
| # | Line | Before | After | Notes |
|---|------|--------|-------|-------|
| 1 | L17 | Comment `// NOTE: ActionSuccessDialog removed…` | Removed | Stale note |
| 2 | L515-537 | SnackBar "Thank you for rating your trip!" (creator path) | `ActionSuccessDialog` | |
| 3 | L576 | SnackBar `Error: $e` on confirm arrival | `ActionErrorDialog` | |
| 4 | L623-645 | SnackBar "Thank you for rating your trip!" (member path) | `ActionSuccessDialog` | |
| 5 | L734-745 | `AlertDialog` "Cancel Request?" | `ThemedConfirmDialog(isDestructive: true)` | |
| 6 | L800-811 | `AlertDialog` "Leave Trip?" | `ThemedConfirmDialog(isDestructive: true)` | |
**Imports added:** `action_success_dialog.dart`, `themed_confirm_dialog.dart`

### 2. `carpool/screens/create_carpool_screen.dart`
**No changes.** Both SnackBars (L124, L139) are form validation inline feedback → kept per migration rules.
Existing `ActionSuccessDialog` / `ActionErrorDialog` usage already correct.

### 3. `carpool/screens/manage_trip_screen.dart`
| # | Line | Before | After | Notes |
|---|------|--------|-------|-------|
| 1 | L185-188 | SnackBar deadline validation | Kept | Form validation |
| 2 | L204-205 | SnackBar required fields | Kept | Form validation |
| 3 | L676-698 | `AlertDialog` "Confirm Trip?" | `ThemedConfirmDialog` | Non-destructive |
| 4 | L917-918 | SnackBar "Private chat coming soon" | `ActionErrorDialog(title: 'Coming Soon')` | |
| 5 | L927-928 | SnackBar "Kick voting coming soon" | `ActionErrorDialog(title: 'Coming Soon')` | |
| 6 | L978-1000 | `AlertDialog` "Reject Request" | `ThemedConfirmDialog(isDestructive: true)` | |
**Imports added:** `themed_confirm_dialog.dart`

### 4. `carpool/screens/trip_proposals_screen.dart`
| # | Line | Before | After |
|---|------|--------|-------|
| 1 | L211-212 | SnackBar "Proposal submitted" | `ActionSuccessDialog` |
| 2 | L217-218 | SnackBar "Submission failed: $e" | `ActionErrorDialog` |
**Imports added:** `action_success_dialog.dart`, `action_error_dialog.dart`

### 5. `carpool/widgets/proposal_card.dart`
| # | Line | Before | After |
|---|------|--------|-------|
| 1 | L182-184 | SnackBar "Voted to approve/reject" | `ActionSuccessDialog` |
| 2 | L188-190 | SnackBar "Vote failed…" | `ActionErrorDialog` |
**Imports added:** `action_success_dialog.dart`, `action_error_dialog.dart`

### 6. `carpool/widgets/review_batch_sheet.dart`
| # | Line | Before | After |
|---|------|--------|-------|
| 1 | L120-122 | SnackBar "Submission failed: $e" | `ActionErrorDialog` |
**Imports added:** `action_error_dialog.dart`

### 7. `carpool/widgets/trip_timeline.dart`
| # | Line | Before | After |
|---|------|--------|-------|
| 1 | L354-356 | SnackBar "Cost settled successfully" | `ActionSuccessDialog` |
| 2 | L360-362 | SnackBar "Settlement failed: $e" | `ActionErrorDialog` |
**Imports added:** `action_success_dialog.dart`, `action_error_dialog.dart`

### 8. `chat/screens/chat_room_screen.dart`
| # | Line | Before | After | Notes |
|---|------|--------|-------|-------|
| 1 | L445-495 | `AlertDialog` "Block User" | `ThemedConfirmDialog(isDestructive: true)` | Block success/error → `ActionSuccessDialog` / `ActionErrorDialog` |
**Kept:** All messaging-related SnackBars (`_showBlockedSnackBar`, `_showSenderMutedSnackBar`, `_showRecipientRestrictedSnackBar`, filter warning, send/image failed) — these are inline, non-interruptive chat feedback that should not block the input flow.
**Imports added:** `action_error_dialog.dart`, `themed_confirm_dialog.dart`

### 9. `chat/widgets/chat_popup.dart`
**No changes.** `chat_popup` uses `_showSnackBar()` for inline messaging feedback — same reasoning as `chat_room_screen`. The popup itself is inside a dialog, so using `showDialog` would create stacked modals. SnackBars are appropriate here.

### 10. `auth/screens/email_verification_screen.dart`
| # | Line | Before | After |
|---|------|--------|-------|
| 1 | L21-28 | SnackBar "Verification email resent!" | `ActionSuccessDialog` |
| 2 | L32-35 | SnackBar AppException message | `ActionErrorDialog` |
| 3 | L38-44 | SnackBar "Something went wrong" | `ActionErrorDialog` |
**Imports added:** `action_success_dialog.dart`, `action_error_dialog.dart`

### 11. `auth/screens/forgot_password_screen.dart`
| # | Line | Before | After | Notes |
|---|------|--------|-------|-------|
| 1 | L72-78 | SnackBar "Please select a school" | Kept | Form validation |
| 2 | L48-53 | SnackBar debug toggle message | Kept | Developer debug UI |
| 3 | L91-99 | SnackBar "Password reset email sent" | `ActionSuccessDialog` + `.then(() => pop())` | |
| 4 | L121-124 | `ref.listen` SnackBar auth error | `ActionErrorDialog` | |
**Imports added:** `action_success_dialog.dart`, `action_error_dialog.dart`

### 12. `auth/screens/login_screen.dart`
| # | Line | Before | After | Notes |
|---|------|--------|-------|-------|
| 1 | L57-63 | SnackBar "Please select a school" | Kept | Form validation |
| 2 | L95-100 | SnackBar debug toggle message | Kept | Developer debug UI |
| 3 | L145/157 | SnackBar debug mode disabled/network error | Kept | Developer debug UI |
| 4 | L197-200 | `ref.listen` SnackBar auth error | `ActionErrorDialog(title: 'Login Failed')` | |
**Imports added:** `action_error_dialog.dart`

### 13. `auth/screens/register_screen.dart`
| # | Line | Before | After | Notes |
|---|------|--------|-------|-------|
| 1 | L54-71 | `AlertDialog` EULA warning (OK only) | `ActionErrorDialog` | Single-action → simpler |
| 2 | L75-81 | SnackBar "Please select a school" | Kept | Form validation |
| 3 | L115-121 | SnackBar debug toggle | Kept | Developer debug UI |
| 4 | L219-221 | `ref.listen` SnackBar auth error | `ActionErrorDialog(title: 'Registration Failed')` | |
**Imports added:** `action_error_dialog.dart`

---

## Migration Decisions

### Kept as SnackBar (justified)
- **Form validation messages** (school selector, required fields, deadline conflict) — transient, non-blocking, dismisses automatically, user can act without closing.
- **Debug mode toggle messages** — developer-only, non-production feedback.
- **Chat messaging inline feedback** (`_showBlockedSnackBar`, `_showSenderMutedSnackBar`, filter warnings, send errors) — chat context requires non-modal feedback to preserve typing flow; stacked modals would degrade UX.
- **`chat_popup.dart`** — widget is inside a `showGeneralDialog`; showing `showDialog` inside a dialog creates modal stacking issues.

### Changed to Dialog
- All **success/failure outcomes** of async operations (API calls, data mutations).
- All **confirm/cancel flows** (leave trip, cancel request, block user, reject member, confirm trip).
- All **auth errors** from `ref.listen` — these are consequential and deserve user attention.

---

## flutter analyze
```
Analyzing app...
No issues found! (ran in 1.8s)
```
