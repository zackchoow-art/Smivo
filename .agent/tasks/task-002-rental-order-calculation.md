# Task 002: Wire Rental Order Calculation to Real Provider State

## Objective
When a buyer taps "Request to Rent", the order must use the rental configuration
the user selected in RentalOptionsSection (rate type, dates, duration) instead of
hardcoded values.

## STRICT SCOPE — Only modify these files:
1. `lib/features/listing/screens/listing_detail_screen.dart` — wire createOrder to providers
2. `lib/features/listing/providers/listing_detail_provider.dart` — fix default rate selection

**DO NOT** modify any other files.

---

## Step 1: Fix default rental rate selection

In `lib/features/listing/providers/listing_detail_provider.dart`, the
`SelectedRentalRate` provider defaults to `'MONTH'`. But if a listing only has
daily pricing, the default selection won't match any available option.

This is tricky because the provider doesn't know the listing. For now, keep the
default as `'DAY'` instead of `'MONTH'` (DAY is the most common rate and was the
original default checkbox in the create listing form).

**Replace** line 14:
```dart
  String build() => 'MONTH';
```
**With:**
```dart
  // NOTE: Default to DAY as it's the most commonly enabled rate.
  // The RentalOptionsSection auto-selects the first available rate on build.
  String build() => 'DAY';
```

## Step 2: Wire the "Request to Rent" button to real state

In `lib/features/listing/screens/listing_detail_screen.dart`, find the block
starting at line ~357 (the `isRental` section inside the onPressed callback):

```dart
                            final isRental = listing.transactionType.toLowerCase() == 'rental';
                            
                            // TEMPORARY: default to 7-day rental starting tomorrow
                            // TODO: Read from RentalOptionsSection state
                            DateTime? rentalStart;
                            DateTime? rentalEnd;
                            if (isRental) {
                              rentalStart = DateTime.now().add(const Duration(days: 1));
                              rentalEnd = rentalStart.add(const Duration(days: 7));
                            }
                            
                            try {
                              await ref.read(orderActionsProvider.notifier).createOrder(
                                listingId: listing.id,
                                sellerId: listing.sellerId,
                                price: listing.price,
                                orderType: isRental ? 'rental' : 'sale',
                                rentalStartDate: rentalStart,
                                rentalEndDate: rentalEnd,
                                depositAmount: listing.depositAmount,
                              );
```

**Replace** that entire block (from `final isRental` through the `createOrder(` call and its closing `);`)
with:

```dart
                            final isRental = listing.transactionType.toLowerCase() == 'rental';
                            
                            double orderPrice;
                            DateTime? rentalStart;
                            DateTime? rentalEnd;
                            
                            if (isRental) {
                              // Read rental configuration from providers
                              final selectedRate = ref.read(selectedRentalRateProvider);
                              final startDate = ref.read(rentalStartDateProvider);
                              
                              // Calculate price and end date based on selected rate type
                              if (selectedRate == 'DAY') {
                                final endDate = ref.read(rentalEndDateProvider);
                                final days = endDate.difference(startDate).inDays;
                                final effectiveDays = days > 0 ? days : 1;
                                orderPrice = (listing.rentalDailyPrice ?? 0) * effectiveDays;
                                rentalStart = startDate;
                                rentalEnd = endDate;
                              } else if (selectedRate == 'WEEK') {
                                final duration = ref.read(rentalDurationProvider);
                                final totalDays = 7 * duration;
                                orderPrice = (listing.rentalWeeklyPrice ?? 0) * duration;
                                rentalStart = startDate;
                                rentalEnd = startDate.add(Duration(days: totalDays));
                              } else {
                                // MONTH
                                final duration = ref.read(rentalDurationProvider);
                                orderPrice = (listing.rentalMonthlyPrice ?? 0) * duration;
                                rentalStart = startDate;
                                rentalEnd = DateTime(
                                  startDate.year,
                                  startDate.month + duration,
                                  startDate.day,
                                );
                              }
                              
                              // Guard: total price must be > 0
                              if (orderPrice <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid rental configuration. Please select a valid rate and period.'),
                                  ),
                                );
                                return;
                              }
                            } else {
                              // Sale: use listing price directly
                              orderPrice = listing.price;
                            }
                            
                            try {
                              await ref.read(orderActionsProvider.notifier).createOrder(
                                listingId: listing.id,
                                sellerId: listing.sellerId,
                                price: orderPrice,
                                orderType: isRental ? 'rental' : 'sale',
                                rentalStartDate: rentalStart,
                                rentalEndDate: rentalEnd,
                                depositAmount: listing.depositAmount,
                              );
```

**IMPORTANT**: The `try {` and `createOrder(` call are the END of this replacement.
Everything after (the success dialog, navigation, catch block) stays EXACTLY as is.

## Step 3: Fix the createOrder price handling

Currently in `orders_provider.dart` line 124-132, `createOrder` recalculates
total_price by multiplying `price * days`. But we are now passing the ALREADY
CALCULATED total as `price`. So we need to update createOrder to use the price
directly for rentals.

**WAIT — actually, re-read the code:**

```dart
      double totalPrice = price;
      if (orderType == 'rental' && 
          rentalStartDate != null && 
          rentalEndDate != null) {
        final days = rentalEndDate.difference(rentalStartDate).inDays;
        final effectiveDays = days > 0 ? days : 1;
        totalPrice = price * effectiveDays;
      }
```

This would DOUBLE-calculate. We need to fix this.

**Add this file to scope**: `lib/features/orders/providers/orders_provider.dart`

In the `createOrder` method, **replace** lines 123-132:
```dart
      // Calculate total price for rentals
      double totalPrice = price;
      if (orderType == 'rental' && 
          rentalStartDate != null && 
          rentalEndDate != null) {
        final days = rentalEndDate.difference(rentalStartDate).inDays;
        // Minimum 1 day
        final effectiveDays = days > 0 ? days : 1;
        totalPrice = price * effectiveDays;
      }
```

**With:**
```dart
      // NOTE: price is the pre-calculated total from the UI layer.
      // For sales: listing.price. For rentals: rate × duration.
      final totalPrice = price;
```

## Step 4: Add required imports

In `listing_detail_screen.dart`, make sure this import exists (it should already
be there since `listing_detail_provider.dart` is imported for `listingDetailProvider`):
```dart
import 'package:smivo/features/listing/providers/listing_detail_provider.dart';
```

Verify it IS already imported. If so, no action needed.

## Step 5: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors (not warnings or info). Write your report to
`.agent/reports/report-002.md` with:
- List of files modified
- Any issues encountered
- flutter analyze errors (if any)
