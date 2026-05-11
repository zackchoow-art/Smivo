# IDENTITY-003: SmivoUserAvatar & SmivoUserIdentity Component Upgrade

> **Executor**: Gemini Pro / Claude Sonnet  
> **Reviewer**: Antigravity (Architect)  
> **Estimated Effort**: Medium-High  
> **Priority**: High

---

## Context

The `SmivoUserAvatar` and `SmivoUserIdentity` widgets in `app/lib/shared/widgets/` were
created in the previous iteration (IDENTITY-001/002). This task upgrades them with:

1. **Platform switch integration** (`system_settings.presence_show_online_dot`)
2. **Revised online/offline visual logic** (no more greyscale, cleaner dot behavior)
3. **SmivoUserIdentity layout restructuring** (remove label, add inline status, add
   message button, add trailing text slot)
4. **Chat feature integration** (ChatListItem, ChatRoomScreen AppBar, ChatPopup)

---

## ⚠️ Boundaries — READ BEFORE STARTING

### Files you MAY create or modify:

| File | Action |
|------|--------|
| `app/lib/shared/widgets/smivo_user_avatar.dart` | Modify |
| `app/lib/shared/widgets/smivo_user_identity.dart` | Modify |
| `app/lib/core/providers/presence_provider.dart` | **Create** (new) |
| `app/lib/features/chat/widgets/chat_list_item.dart` | Modify |
| `app/lib/features/chat/widgets/chat_popup.dart` | Modify |
| `app/lib/features/chat/screens/chat_room_screen.dart` | Modify |
| `app/lib/features/chat/screens/chat_list_screen.dart` | Modify (ChatConversation building) |
| `app/lib/features/chat/providers/chat_provider.dart` | Modify (ChatConversation class) |

### Files you MUST NOT modify:

- `app/lib/data/models/*.dart` — do NOT touch any freezed model files
- `app/lib/data/repositories/*.dart` — do NOT modify repository files
- `app/lib/core/router/*.dart` — no routing changes
- `supabase/migrations/*.sql` — no DB changes (the setting already exists)
- Any file in `admin/` or `website/`
- Any `.g.dart` or `.freezed.dart` generated files

### Technical constraints:

- `ChatRoom` model already has `UserProfile? buyer` and `UserProfile? seller` fields
  (joined via Supabase query in `ChatRepository.fetchChatRooms`). The `UserProfile`
  model already has `DateTime? lastActiveAt`.
- The `ChatConversation` class (in `chat_provider.dart`) is a plain Dart class, NOT
  a freezed model. You may safely add fields to it.
- `system_settings` table has key `presence.show_online_dot` with a `jsonb` boolean value.
- The existing pattern for reading `system_settings` is shown in
  `app/lib/features/settings/screens/settings_screen.dart` lines 11-27
  (`_settingsConfigProvider`). Follow the same pattern but create a **global cached
  Riverpod provider** instead of a screen-local one.
- All widgets must use design tokens from `context.smivoColors`, `context.smivoTypo`,
  `context.smivoRadius`. No hardcoded colors (except `Colors.green` for online dot is OK).

---

## Task 1: Create Presence Config Provider

**File**: `app/lib/core/providers/presence_provider.dart` (NEW)

Create a Riverpod provider that reads `presence.show_online_dot` from `system_settings`.

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

part 'presence_provider.g.dart';

/// Reads the platform switch `presence.show_online_dot` from system_settings.
///
/// Returns true if the online dot should be shown, false otherwise.
/// Defaults to true if the setting is missing or cannot be read.
@Riverpod(keepAlive: true)
class PresenceConfig extends _$PresenceConfig {
  @override
  Future<bool> build() async {
    final supabase = ref.watch(supabaseClientProvider);
    try {
      final res = await supabase
          .from('system_settings')
          .select('value')
          .eq('key', 'presence.show_online_dot')
          .maybeSingle();
      if (res == null) return true;
      final val = res['value'];
      return val == true || val == 'true';
    } catch (_) {
      return true;
    }
  }
}
```

After creating the file, run:
```bash
cd app && dart run build_runner build --delete-conflicting-outputs
```

---

## Task 2: Upgrade SmivoUserAvatar

**File**: `app/lib/shared/widgets/smivo_user_avatar.dart`

### Current behavior (to be REMOVED):
- Always shows online/offline dot
- Applies greyscale filter to offline avatars
- Always shows grey dot for offline

### New behavior:
- Accept an optional `showOnlineDot` parameter (defaults to null, meaning "use platform config")
- If platform switch `presence.show_online_dot` is **false** AND `showOnlineDot` is not explicitly true:
  - Show avatar normally (full color)
  - NO dot indicator at all
- If platform switch is **true** (or `showOnlineDot` is explicitly true):
  - User **online** (lastActiveAt within 10 min): avatar in full color, GREEN dot
  - User **offline**: avatar in full color (NO greyscale), NO dot
- GestureDetector + bottom sheet logic remains unchanged
- Keep the `enableTap` parameter (default true) so callers like `user_reviews_bottom_sheet.dart`
  can disable the tap behavior to avoid recursive sheet opening.

### New widget signature:

```dart
class SmivoUserAvatar extends ConsumerWidget {
  const SmivoUserAvatar({
    super.key,
    required this.user,
    this.radius = 20.0,
    this.role = 'seller',
    this.showOnlineDot, // null = follow platform config
    this.enableTap = true,
  });

  final UserProfile user;
  final double radius;
  final String role;
  final bool? showOnlineDot;
  final bool enableTap;
  // ...
}
```

### Implementation details:

1. Change from `StatelessWidget` to `ConsumerWidget` to read the presence provider.
2. Read `ref.watch(presenceConfigProvider).value ?? true` to get the platform switch.
3. Calculate `effectiveShowDot`: if `showOnlineDot != null`, use it; otherwise use platform config.
4. Calculate `isOnline` same as before: `lastActiveAt != null && diff.inMinutes <= 10`.
5. **Remove** the `ColorFiltered` greyscale wrapper entirely.
6. Only show dot when `effectiveShowDot && isOnline` (i.e., only show green dot for online users).
7. Keep `GestureDetector` with `enableTap` guard.

---

## Task 3: Upgrade SmivoUserIdentity

**File**: `app/lib/shared/widgets/smivo_user_identity.dart`

### Current behavior (to be CHANGED):
- Has optional `label` parameter shown above username (e.g., "SELLER")
- `LastActiveBadge` shown below email in the rating row
- `actionIcon` + `onActionTap` for a generic trailing icon button

### New layout structure:

```
┌─────────────────────────────────────────────────────────────┐
│  ┌──────┐  Name ···············  Last active   [💬 Message] │
│  │Avatar│  email@edu ·········                  Button      │
│  └──────┘  ⭐ 4.8 (12)            trailing text (right)    │
└─────────────────────────────────────────────────────────────┘
```

### Changes:

1. **Delete** the `label` parameter entirely. Remove the "SELLER" text block above the name.
2. **Left avatar**: Use `SmivoUserAvatar` (already done, keep it).
3. **Name row**: Username (left) + LastActiveBadge (right side of the same row).
   - Username font: change from `typo.titleMedium` to `typo.titleSmall` to make room.
   - LastActiveBadge: only show when `showPresence == true`.
   - Both should be in an `Expanded` + `Row` to handle overflow. Username gets `Flexible`
     with `overflow: TextOverflow.ellipsis`.
4. **Email row**: unchanged (second line).
5. **Rating row**: `UserRatingBadge` on left, then `Spacer()`, then the new `trailingText`
   widget on the right (right-aligned, smaller font `typo.labelSmall`).
6. **Message button**: New `showMessageButton` parameter (default `false`).
   When true, show a message icon button on the far right spanning the height of name+email
   rows. The button should use `colors.primary` color.
   - `onMessageTap` callback parameter.
   - The button sits in the rightmost column, vertically centered.
7. **Platform switch**: Add `showPresence` parameter (default null → follow platform config).
   Pass this to both `SmivoUserAvatar(showOnlineDot: showPresence)` and conditionally
   hide `LastActiveBadge`.

### New widget signature:

```dart
class SmivoUserIdentity extends ConsumerWidget {
  const SmivoUserIdentity({
    super.key,
    required this.user,
    this.showBackground = false,
    this.role = 'seller',
    // Presence
    this.showPresence, // null = follow platform config
    // Trailing text (bottom-right, e.g., order amount, status)
    this.trailingText,
    // Message button
    this.showMessageButton = false,
    this.onMessageTap,
  });

  final UserProfile user;
  final bool showBackground;
  final String role;
  final bool? showPresence;
  final String? trailingText;
  final bool showMessageButton;
  final VoidCallback? onMessageTap;
  // ...
}
```

---

## Task 4: Add UserProfile to ChatConversation

**File**: `app/lib/features/chat/providers/chat_provider.dart`

### Add a `UserProfile? partnerProfile` field to the `ChatConversation` class:

```dart
class ChatConversation {
  // ... existing fields ...
  final UserProfile? partnerProfile; // NEW: full profile of the other party

  ChatConversation({
    // ... existing params ...
    this.partnerProfile,
  });
}
```

### Update `_buildConversation` in `chat_list_screen.dart`:

In `chat_list_screen.dart`, the method `_buildConversation` already computes
`otherUser` as `isBuyer ? room.seller : room.buyer`. Simply pass it through:

```dart
return ChatConversation(
  // ... existing fields ...
  partnerProfile: otherUser, // NEW
);
```

---

## Task 5: Upgrade ChatListItem with SmivoUserAvatar

**File**: `app/lib/features/chat/widgets/chat_list_item.dart`

### Current: Uses raw `CircleAvatar` with `conversation.avatarUrl`.
### New: Use `SmivoUserAvatar` when `conversation.partnerProfile` is available.

Replace the `CircleAvatar` block (lines 106-123) with:

```dart
if (conversation.partnerProfile != null)
  SmivoUserAvatar(
    user: conversation.partnerProfile!,
    radius: 24,
    enableTap: false, // Don't open review sheet from chat list
  )
else
  CircleAvatar(
    radius: 24,
    backgroundColor: colors.surfaceContainer,
    backgroundImage: conversation.avatarUrl != null
        ? NetworkImage(conversation.avatarUrl!)
        : null,
    child: conversation.avatarUrl == null && conversation.initials != null
        ? Text(
            conversation.initials!,
            style: typo.titleMedium.copyWith(color: colors.onSurface),
          )
        : null,
  ),
```

Keep the unread badge `Positioned` overlay in the `Stack` — just change the avatar widget inside.

Add `import 'package:smivo/shared/widgets/smivo_user_avatar.dart';` at the top.

---

## Task 6: Upgrade ChatRoomScreen AppBar with SmivoUserAvatar

**File**: `app/lib/features/chat/screens/chat_room_screen.dart`

### Current: Lines 373-392 use raw `CircleAvatar` in the AppBar.
### New: Replace with `SmivoUserAvatar`.

In the `data: (room)` block of the AppBar title builder (around line 366-428):

```dart
data: (room) {
  final otherUser =
      room.buyerId == currentUserId ? room.seller : room.buyer;
  if (otherUser == null) return const SizedBox();
  return Row(
    children: [
      SmivoUserAvatar(
        user: otherUser,
        radius: 18,
        role: room.buyerId == currentUserId ? 'seller' : 'buyer',
        enableTap: true,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              otherUser.displayName ?? 'User',
              style: typo.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (otherUser.email.isNotEmpty)
              Text(
                otherUser.email,
                style: typo.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            UserRatingBadge(
              user: otherUser,
              role: room.buyerId == currentUserId ? 'seller' : 'buyer',
            ),
          ],
        ),
      ),
    ],
  );
},
```

Add `import 'package:smivo/shared/widgets/smivo_user_avatar.dart';` at the top.

---

## Task 7: Upgrade ChatPopup Header with SmivoUserAvatar

**File**: `app/lib/features/chat/widgets/chat_popup.dart`

### Problem: The popup receives `otherUserAvatar` / `otherUserName` as strings,
### not a `UserProfile`. We need to bridge this.

### Step 7a: Add `UserProfile? otherUserProfile` parameter to both `showChatPopup` and `ChatPopupWidget`:

```dart
Future<void> showChatPopup(
  BuildContext context, {
  required String chatRoomId,
  required String otherUserName,
  String? otherUserAvatar,
  String? otherUserEmail,
  UserProfile? otherUserProfile, // NEW
  required String listingTitle,
  required double listingPrice,
  String? listingImageUrl,
  String? priceLabel,
}) { ... }
```

Similarly for `ChatPopupWidget`.

### Step 7b: In the header builder (line 276), conditionally use SmivoUserAvatar:

```dart
if (widget.otherUserProfile != null)
  SmivoUserAvatar(
    user: widget.otherUserProfile!,
    radius: 24,
    enableTap: true,
  )
else
  CircleAvatar(
    // existing fallback code
  ),
```

### Step 7c: Update ALL callers of `showChatPopup` to pass `otherUserProfile` when available.

Callers to update (search for `showChatPopup(` in these files):
- `app/lib/features/orders/widgets/order_info_section.dart`
- `app/lib/features/orders/widgets/list_order_card.dart`
- `app/lib/features/listing/screens/listing_detail_screen.dart`
- `app/lib/features/seller/screens/transaction_management_screen.dart` (3 call sites)

For each caller: if you have access to a `UserProfile` object, pass it.
If not, pass `null` and the fallback `CircleAvatar` will be used.

Add `import 'package:smivo/data/models/user_profile.dart';` to `chat_popup.dart`.

---

## Task 8: Update existing SmivoUserIdentity call sites

### 8a. `seller_profile_card.dart`
- Remove `label: 'SELLER'` parameter if present (it was already removed in IDENTITY-001,
  but verify).
- Add `showMessageButton: true` and `onMessageTap: ...` if the card currently has a
  separate message button outside the identity card. If there's a message button outside,
  move it inside.

### 8b. `order_info_section.dart`
- Remove `label` parameter from SmivoUserIdentity calls.
- Pass `trailingText` when appropriate (e.g., order amount).
- If the section has a separate chat/message button, move it into
  `showMessageButton: true` + `onMessageTap`.

### 8c. Verify `transaction_management_screen.dart`
- The Saves tab (line 278) and Views tab still use raw CircleAvatar — these display
  anonymous viewers without full UserProfile. Leave them as CircleAvatar (they don't
  have enough data for SmivoUserAvatar).
- The Offers tab (line 724) has `SmivoUserAvatar` already — verify it still works
  after the upgrade.

---

## Verification Steps

After completing ALL tasks, run:

```bash
cd app && dart run build_runner build --delete-conflicting-outputs
cd app && flutter analyze
```

### Expected outcome:
- `build_runner` completes with 0 errors
- `flutter analyze` shows 0 NEW warnings/errors (existing legacy warnings are OK)

### Manual verification checklist:
- [ ] `SmivoUserAvatar` shows GREEN dot only when user is online AND platform switch is on
- [ ] `SmivoUserAvatar` shows NO dot when user is offline (regardless of platform switch)
- [ ] `SmivoUserAvatar` shows NO dot when platform switch is off
- [ ] `SmivoUserAvatar` shows full-color avatar always (no greyscale)
- [ ] `SmivoUserIdentity` has no "SELLER"/"BUYER" label above name
- [ ] `SmivoUserIdentity` shows last-active text next to name (when presence enabled)
- [ ] `SmivoUserIdentity` trailing text appears right-aligned on rating row
- [ ] `SmivoUserIdentity` message button appears when enabled
- [ ] `ChatListItem` uses SmivoUserAvatar with online dot
- [ ] `ChatRoomScreen` AppBar uses SmivoUserAvatar
- [ ] `ChatPopup` header uses SmivoUserAvatar when UserProfile available

---

## Execution Report

Save execution report to: `.agent/reports/IDENTITY-003-EXECUTION-REPORT.md`

The report must include:
1. List of every file created or modified with a 1-line description of the change
2. Full output of `flutter analyze` (last 30 lines minimum)
3. Any issues encountered and how they were resolved
4. List of remaining `CircleAvatar` usages and justification for why each was NOT replaced
