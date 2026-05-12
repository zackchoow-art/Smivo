# Task: Carpool V2 Phase 4 — Group Chat Enhancement + Trip Timeline

## Objective

Integrate carpool group chats into the main chat list, enhance the group chat
room UI, and build a trip timeline for post-departure tracking.

## Pre-Requisite: Read These Files First

1. `app/lib/data/models/carpool_trip.dart` — trip model
2. `app/lib/features/chat/screens/chat_list_screen.dart` — existing chat list
3. `app/lib/features/chat/screens/chat_room_screen.dart` — existing 1-on-1 chat
4. `app/lib/features/chat/providers/` — all chat providers
5. `app/lib/features/carpool/screens/group_chat_screen.dart` — current group chat
6. `app/lib/features/carpool/providers/group_chat_provider.dart` — group chat data
7. `app/lib/features/carpool/widgets/group_message_bubble.dart` — message bubble
8. `app/lib/features/carpool/widgets/group_member_sheet.dart` — member sheet
9. `app/lib/features/orders/screens/order_detail_screen.dart` — timeline reference
10. `app/lib/features/orders/widgets/` — look for timeline widget components
11. `app/lib/shared/widgets/smivo_user_avatar.dart` — standard avatar component
12. `supabase/migrations/00145_carpool_and_group_chat_schema.sql` — group schema
13. `supabase/migrations/00146_carpool_rpcs_and_triggers.sql` — group chat RPCs

## IMPORTANT: This phase has 3 sub-tasks. Complete them IN ORDER.

---

## Task 1: Group Chat in Chat List

### 1A. Create GroupChatListTile Widget

Create a new file: `app/lib/features/carpool/widgets/group_chat_list_tile.dart`

This widget represents a group chat entry in the main chat list.

```dart
class GroupChatListTile extends StatelessWidget {
  const GroupChatListTile({
    super.key,
    required this.roomName,      // "Smith College → Airport"
    required this.memberAvatars, // List<String?> of avatar URLs
    required this.lastMessage,   // Last message text
    required this.lastMessageTime,
    required this.onTap,
  });

  // ... build a ListTile where:
  // - leading: Overlapping avatar stack (max 4 visible + "+N" if more)
  //   Use Stack with Positioned, each SmivoUserAvatar offset by 16px
  // - title: roomName
  // - subtitle: lastMessage (single line, ellipsis)
  // - trailing: formatted time
}
```

### 1B. Integrate into Chat List

In `chat_list_screen.dart`, fetch group chat rooms the user belongs to and
display them in the same list. Group chats should:
- Appear alongside regular 1-on-1 chats
- Show all member avatars (overlapping) as the leading widget
- Show the group name (departure → destination) as title
- Be tappable → navigate to the group chat screen

### 1C. Hide Chat for Left/Kicked Members

Members with status 'left' or 'kicked' in `group_chat_members` should NOT
see the group chat in their list. Query with:
```sql
.eq('user_id', currentUserId)
-- group_chat_members must exist for this user
```

If the user has been removed from `group_chat_members` (the leave/kick RPCs
already handle this deletion), the row won't exist and they won't see it.

---

## Task 2: Group Chat Room Enhancement

### 2A. AppBar — Replace User Info with Member Avatar Row

In `group_chat_screen.dart`, update the AppBar:

```dart
AppBar(
  title: Text(roomName),  // "Smith → Airport"
  actions: [
    // Small overlapping avatar row
    Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: members.take(5).map((m) =>
          Padding(
            padding: const EdgeInsets.only(right: -8),
            child: SmivoUserAvatar(
              imageUrl: m.user?.avatarUrl,
              radius: 14,
            ),
          ),
        ).toList(),
      ),
    ),
    IconButton(
      icon: const Icon(Icons.group),
      onPressed: () {
        // Open member sheet
      },
    ),
  ],
)
```

### 2B. Message Bubble — Add Sender Avatar and Name

In `group_message_bubble.dart`, modify each message to show:

```
┌──────────────────────────────────┐
│ [Avatar] Message content here... │
│         Sender Name · 3:42 PM   │
└──────────────────────────────────┘
```

- Sender avatar: small `SmivoUserAvatar(radius: 12)` to the left of the bubble
- Sender name: displayed below the message, before the timestamp
- Format: `"Display Name · HH:mm"` or `"Display Name · Yesterday HH:mm"`
- For the current user's own messages, avatar goes on the right side
- System messages (message_type == 'system') don't show avatar or name

### 2C. Message History for New Members

New members joining via `accept_carpool_member` RPC are added to
`group_chat_members`. They should see all previous messages.

The current implementation likely fetches messages by room_id.
Verify this works: new members should NOT be filtered by join date.
If there's any date-based filtering, remove it so all history is visible.

---

## Task 3: Trip Timeline

### 3A. Create Trip Timeline Widget

Create: `app/lib/features/carpool/widgets/trip_timeline.dart`

Reference the order detail timeline pattern from:
`app/lib/features/orders/screens/order_detail_screen.dart`

The timeline should show these events:

```
○ Trip Created                    May 12, 3:00 PM
│
○ Alice joined                    May 12, 4:15 PM
│
○ Bob joined                      May 12, 5:30 PM
│
● Departed                        May 13, 2:00 PM
│
○ Charlie left (2h before dep.)   May 13, 12:00 PM
│
● Arrived                         May 13, 4:30 PM
│
○ Cost settled: $120.00 total     May 13, 4:45 PM
   ($40.00/person)
```

Build the timeline steps dynamically from:
- `trip.createdAt` → "Trip Created"
- Each member's `joinedAt` → "Name joined"
- Members with `cancelledAt` → "Name left (Xh before departure)"
- Trip lifecycle events from the trip status

### 3B. Cost Settlement (Post-Arrival)

When the trip status is 'arrived' or 'completed', show a settlement card:

**For the trip creator:**
```dart
Card(
  child: Column(
    children: [
      Text('Cost Settlement'),
      TextFormField(
        labelText: 'Actual Total Cost (\$)',
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
      // Show calculated per-person split
      Text('Per person: \$XX.XX (N people)'),
      ElevatedButton(child: Text('Confirm Settlement')),
    ],
  ),
)
```

**For regular members:**
```dart
Card(
  child: Column(
    children: [
      Text('Cost Settlement'),
      Text('Total: \$120.00'),
      Text('Your share: \$40.00'),
      // If not yet settled, show "Waiting for organizer..."
    ],
  ),
)
```

### 3C. Database Support for Settlement

Create a new migration file: `supabase/migrations/00152_carpool_settlement.sql`

```sql
ALTER TABLE public.carpool_trips
  ADD COLUMN IF NOT EXISTS actual_total_cost numeric(10,2),
  ADD COLUMN IF NOT EXISTS settled_at timestamptz;

COMMENT ON COLUMN public.carpool_trips.actual_total_cost
  IS 'Actual total cost entered by creator after arrival';
COMMENT ON COLUMN public.carpool_trips.settled_at
  IS 'Timestamp when the creator confirmed the final cost';
```

Also add these fields to the Dart model:
```dart
@JsonKey(name: 'actual_total_cost') double? actualTotalCost,
@JsonKey(name: 'settled_at') DateTime? settledAt,
```

And add a repository method:
```dart
Future<void> settleTripCost(String tripId, double actualTotalCost) async {
  await _client.from('carpool_trips').update({
    'actual_total_cost': actualTotalCost,
    'settled_at': DateTime.now().toIso8601String(),
  }).eq('id', tripId);
}
```

---

## Verification

After completing ALL changes:

1. Run: `cd app && dart run build_runner build --delete-conflicting-outputs`
2. Run: `cd app && flutter analyze`
3. Confirm: **zero errors** (warnings/info are OK)
4. If you created a new migration file, do NOT run it. Just create the file.

## Rules

- **Do NOT modify any files outside the scope listed above.**
- **Do NOT change existing 1-on-1 chat functionality.**
- **All text must be in English.**
- **All comments must explain WHY, not WHAT.**
- **Read each file fully before modifying it.**
- Git commit message: `feat(carpool): v2 group chat integration and trip timeline`
- Do NOT push or run migrations. Wait for review.
