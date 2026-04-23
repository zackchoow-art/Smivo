# Task 005B: Order Pickup Location — UI Display

## Prerequisites
Task 005A must be completed first (Order model has pickupLocation field).

## Objective
Display real pickup location name in order card and order detail screen.

## STRICT SCOPE — Only modify these files:
1. `lib/features/orders/widgets/order_card.dart` — show pickup name
2. `lib/features/orders/screens/order_detail_screen.dart` — show pickup name

**DO NOT** modify any other files.

---

## Step 1: Update order card pickup display

In `lib/features/orders/widgets/order_card.dart`, find line 278:
```dart
                    order.school, // Use order.school as fallback for pickup location context
```

**Replace** with:
```dart
                    order.pickupLocation?.name ?? order.school,
```

## Step 2: Update order detail screen

In `lib/features/orders/screens/order_detail_screen.dart`, find the
`_buildInfoSection` method. Add a pickup location row.

After the deposit row (the `if (order.orderType == 'rental' && order.depositAmount > 0)` line),
add:

```dart
        if (order.pickupLocation != null)
          _infoRow('Pickup', order.pickupLocation!.name),
```

## Step 3: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-005b.md`.
