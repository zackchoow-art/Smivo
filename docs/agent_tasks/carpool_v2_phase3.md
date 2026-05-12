# Task: Carpool V2 Phase 3 — Trip Details Page Redesign

## Objective

Redesign the Trip Details page (`carpool_detail_screen.dart`) to use the new
V2 fields (departure/destination descriptions, estimated pricing) and improve
the member display. All new DB columns are already in place.

## Pre-Requisite: Read These Files First

1. `app/lib/data/models/carpool_trip.dart` — updated model with V2 fields
2. `app/lib/data/models/carpool_member.dart` — updated with cancellation fields
3. `app/lib/features/carpool/screens/carpool_detail_screen.dart` — current page
4. `app/lib/features/carpool/widgets/member_avatar_row.dart` — current member row
5. `app/lib/shared/widgets/smivo_user_avatar.dart` — standard avatar component

## Task 1: Route Information — Dual Card Layout

### Card 1: Description Card (prominent)

Replace the current single route display with a styled card showing the
short descriptions:

```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            Icon(Icons.trip_origin, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                trip.departureDescription ?? trip.departureAddress,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 11),
          child: Container(
            width: 2, height: 24,
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        Row(
          children: [
            Icon(Icons.location_on, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                trip.destinationDescription ?? trip.destinationAddress,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
)
```

### Card 2: Full Address Card (collapsible or secondary)

A second card showing full physical addresses in smaller text:

```dart
Card(
  color: theme.colorScheme.surfaceContainerLow,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Full Addresses',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        _InfoRow(icon: Icons.trip_origin, label: 'From',
          value: trip.departureAddress),
        const SizedBox(height: 4),
        _InfoRow(icon: Icons.location_on, label: 'To',
          value: trip.destinationAddress),
      ],
    ),
  ),
)
```

## Task 2: Time Display

Under the Departure Time info row, add the arrival time:

```dart
_InfoRow(
  icon: Icons.access_time,
  label: 'Departure Time',
  value: DateFormat('yyyy-MM-dd HH:mm').format(trip.departureTime.toLocal()),
),
if (trip.estimatedArrivalTime != null) ...[
  const SizedBox(height: 8),
  _InfoRow(
    icon: Icons.flag,
    label: 'Est. Arrival',
    value: DateFormat('yyyy-MM-dd HH:mm').format(
        trip.estimatedArrivalTime!.toLocal()),
  ),
],
```

Note: The arrival time may already be displayed. Ensure it shows the full
date-time format, not just `HH:mm`.

## Task 3: Seat Display

Change from `'3/3 Seats'` to just `'3'`:

```dart
_InfoRow(
  icon: Icons.event_seat,
  label: 'Available Seats',
  value: '${trip.availableSeats}',
),
```

## Task 4: Estimated Price Display

Add a new info row for the price, if available:

```dart
if (trip.estimatedTotalPrice != null) ...[
  const SizedBox(height: 8),
  _InfoRow(
    icon: Icons.attach_money,
    label: 'Estimated Total',
    value: '\$${trip.estimatedTotalPrice!.toStringAsFixed(2)}',
  ),
  const SizedBox(height: 4),
  _InfoRow(
    icon: Icons.people,
    label: 'Est. Per Person',
    value: '\$${(trip.estimatedTotalPrice! / (trip.totalSeats + 1)).toStringAsFixed(2)}',
  ),
],
```

## Task 5: Organizer Section

Replace the current plain `ListTile` with the standard `SmivoUserAvatar`:

```dart
ListTile(
  leading: SmivoUserAvatar(
    imageUrl: trip.creator?.avatarUrl,
    radius: 24,
  ),
  title: Text(trip.creator?.displayName ?? 'Unknown'),
  subtitle: Text(trip.role == 'driver' ? 'Driver' : 'Organizer'),
  trailing: IconButton(
    icon: const Icon(Icons.chat_bubble_outline),
    tooltip: 'Group Chat',
    onPressed: () {
      // TODO: Navigate to group chat for this trip
    },
  ),
),
```

## Task 6: Joined Members — Exclude Creator

In the members display section, filter out the creator:

```dart
final joinedMembers = trip.members
    .where((m) => m.status == 'approved' && m.userId != trip.creatorId)
    .toList();
```

Use this filtered list when displaying the member avatars and counts.

## Task 7: Price Disclaimer for Join Requests

Before the "Request to Join" button, add a subtle warning:

```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  child: Text(
    'Price shown is an estimate and may change based on final headcount.',
    style: theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.outline,
      fontStyle: FontStyle.italic,
    ),
    textAlign: TextAlign.center,
  ),
),
```

## Verification

After completing ALL changes:

1. Run: `cd app && flutter analyze`
2. Confirm: **zero errors** (warnings/info are OK)

## Rules

- **Do NOT modify any files outside the scope listed above.**
- **Do NOT change the router, navigation, or any other feature.**
- **All text must be in English.**
- **All comments must explain WHY, not WHAT.**
- **Read each file fully before modifying it.**
- Git commit message: `feat(carpool): v2 trip details page redesign`
- Do NOT push. Wait for review.
