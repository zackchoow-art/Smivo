# Task: Carpool V2 Phase 2 — Create Screen + Card + List Sort

## Objective

Redesign the carpool creation form and trip card component, and add sort
toggle to the list page. All new DB columns are already in place (migration
00151). The Dart models have been updated.

## Pre-Requisite: Read These Files First

Before editing anything, read these files completely to understand the current
implementation:

1. `app/lib/data/models/carpool_trip.dart` — the updated model with new fields
2. `app/lib/features/carpool/screens/create_carpool_screen.dart` — current form
3. `app/lib/features/carpool/widgets/carpool_trip_card.dart` — current card
4. `app/lib/features/carpool/screens/carpool_list_screen.dart` — list page
5. `app/lib/features/carpool/providers/carpool_list_provider.dart` — list provider
6. `app/lib/features/carpool/providers/create_carpool_provider.dart` — create provider
7. `app/lib/data/repositories/carpool_repository.dart` — repository layer

## Task 1: Create Carpool Screen (`create_carpool_screen.dart`)

### 1A. Seat Selector — Replace DropdownButton with Number Stepper

Remove the current DropdownButton<int> for seats and replace with a row:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available Seats'),
        Text(
          'Number of empty seats you can offer',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
    Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: _totalSeats > 1
              ? () => setState(() => _totalSeats--)
              : null,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$_totalSeats',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: _totalSeats < 9
              ? () => setState(() => _totalSeats++)
              : null,
        ),
      ],
    ),
  ],
)
```

- Change default `_totalSeats` from 4 to 3
- Min: 1, Max: 9

### 1B. Add Estimated Total Price Field

Add a new `TextFormField` for estimated total price:

```dart
TextFormField(
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  decoration: const InputDecoration(
    labelText: 'Estimated Total Price (\$)',
    hintText: 'e.g. 120.00',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.attach_money),
  ),
  onChanged: (val) => setState(() => _estimatedTotalPrice = double.tryParse(val)),
)
```

- Add state variable: `double? _estimatedTotalPrice;`
- Place it after the luggage limit row
- This is optional (no validation required)
- Pass to provider as `estimatedTotalPrice` parameter

### 1C. Add Departure/Destination Description Fields

Add two `TextFormField` inputs for short descriptions:

```dart
TextFormField(
  controller: _departureDescController,
  decoration: const InputDecoration(
    labelText: 'Departure Name (e.g. Smith College)',
    border: OutlineInputBorder(),
  ),
)
```

And same for destination:
```dart
TextFormField(
  controller: _destinationDescController,
  decoration: const InputDecoration(
    labelText: 'Destination Name (e.g. Bradley Airport)',
    border: OutlineInputBorder(),
  ),
)
```

- Place these ABOVE the map location pickers, under the "Route" section title
- Add controllers: `_departureDescController`, `_destinationDescController`
- Pass to provider as `departureDescription` and `destinationDescription`
- These are optional fields

### 1D. Update Provider + Repository

In `create_carpool_provider.dart`, add the new parameters to the `createTrip`
method signature and pass them to the repository.

In `carpool_repository.dart`, update the `createTrip` method to include:
```dart
if (estimatedTotalPrice != null) 'estimated_total_price': estimatedTotalPrice,
if (departureDescription != null) 'departure_description': departureDescription,
if (destinationDescription != null) 'destination_description': destinationDescription,
```

### 1E. Price Disclaimer

Add a small info banner below the estimated price field:

```dart
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      Icon(Icons.info_outline, size: 16,
        color: theme.colorScheme.onSecondaryContainer),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'Actual cost may vary based on final headcount and total expenses.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    ],
  ),
)
```

---

## Task 2: Carpool Trip Card (`carpool_trip_card.dart`)

Completely redesign the card layout:

### New Layout Structure

```
┌───────────────────────────────────────────────────┐
│                                                   │
│  Smith College → Bradley Airport    ┌──────────┐  │
│  Mon, May 12 · 3:00 PM             │  Map/Icon │  │
│                                     │  Preview  │  │
│                                     └──────────┘  │
│                                                   │
│  3 seats available              $40.00/person     │
│                                                   │
└───────────────────────────────────────────────────┘
```

### Implementation Details

- **Top-left**: `departure_description → destination_description`
  (fallback to first 20 chars of address if description is null)
- **Second line**: Formatted departure time: `'EEE, MMM d · h:mm a'`
- **Top-right**: Square container (80×80) with gradient background + car icon
  - Use `Container` with `BoxDecoration(gradient: ...)` and centered `Icon(Icons.route)`
  - This is a placeholder for future real map thumbnails
- **Bottom-left**: `'${trip.availableSeats} seats available'`
- **Bottom-right**: Per-person price calculation
  - If `estimatedTotalPrice != null`:
    `'\$${(trip.estimatedTotalPrice! / (trip.totalSeats + 1)).toStringAsFixed(2)}/person'`
    (totalSeats + 1 because totalSeats = empty seats, plus the creator)
  - If null: don't show price
- **Remove**: The "Driver"/"Carpool" badge chip in the top-right

---

## Task 3: Carpool List Sort (`carpool_list_screen.dart` + provider)

### 3A. Sort Toggle Button

Add to AppBar actions (before the existing add button):

```dart
IconButton(
  icon: Icon(
    sortByDeparture ? Icons.schedule : Icons.access_time_filled,
  ),
  tooltip: sortByDeparture ? 'Sort by post time' : 'Sort by departure',
  onPressed: () => setState(() => sortByDeparture = !sortByDeparture),
),
```

### 3B. Sort State

Add a local state variable: `bool sortByDeparture = true;`

### 3C. Apply Sort

In the data builder, sort the list before rendering:

```dart
final sorted = [...trips];
sorted.sort((a, b) => sortByDeparture
    ? a.departureTime.compareTo(b.departureTime)
    : b.createdAt.compareTo(a.createdAt));
```

Use `sorted` instead of `trips` when building the ListView.

---

## Verification

After completing ALL changes:

1. Run: `cd app && dart run build_runner build --delete-conflicting-outputs`
   Wait for completion.
2. Run: `cd app && flutter analyze`
3. Confirm: **zero errors** (warnings/info are OK)

If either check fails, fix the issues before reporting.

## Rules

- **Do NOT modify any files outside the scope listed above.**
- **Do NOT change the router, navigation, or any other feature.**
- **All text must be in English (no Chinese).**
- **All comments must explain WHY, not WHAT.**
- **Read each file fully before modifying it.**
- Git commit message: `feat(carpool): v2 create screen, card redesign, and list sort`
- Do NOT push. Wait for review.
