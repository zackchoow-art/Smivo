# Task 005A: Order Pickup Location — Data Layer

## Objective
Add `pickup_location_id` to orders table and wire it through model + repository.

## STRICT SCOPE — Only modify/create these files:
1. `supabase/migrations/00018_order_pickup_location.sql` — **CREATE NEW**
2. `lib/data/models/order.dart` — add field + join type
3. `lib/data/repositories/order_repository.dart` — update queries
4. `lib/features/orders/providers/orders_provider.dart` — accept param in createOrder
5. `lib/features/listing/screens/listing_detail_screen.dart` — pass pickup ID when ordering
6. Run `build_runner`

**DO NOT** modify any other files.

---

## Step 1: Create migration file

Create `supabase/migrations/00018_order_pickup_location.sql`:

```sql
-- 00018: Add pickup_location_id to orders for location snapshot
ALTER TABLE orders
  ADD COLUMN pickup_location_id uuid REFERENCES pickup_locations(id);

-- NOTE: This is nullable because existing orders don't have it,
-- and sale orders from before this migration were created without it.
```

**IMPORTANT**: Do NOT run this migration. Just create the file. The user will
run it manually in Supabase SQL Editor.

## Step 2: Update Order model

In `lib/data/models/order.dart`:

### 2a. Add import for PickupLocation:
After the existing imports, add:
```dart
import 'package:smivo/data/models/pickup_location.dart';
```

### 2b. Add two new fields to the Order factory constructor.
Add these BEFORE the `// Nested join data` comment (before the `UserProfile? buyer` line):

```dart
    @JsonKey(name: 'pickup_location_id') String? pickupLocationId,
```

And add this AFTER `OrderListingPreview? listing,` (inside the nested join section):
```dart
    @JsonKey(name: 'pickup_location') PickupLocation? pickupLocation,
```

## Step 3: Update Order repository queries

In `lib/data/repositories/order_repository.dart`, update BOTH `fetchOrders` and
`fetchOrder` select strings.

The current select is:
```
            *,
            buyer:user_profiles!buyer_id(*),
            seller:user_profiles!seller_id(*),
            listing:listings(id, title, rental_daily_price, rental_weekly_price, rental_monthly_price, deposit_amount, images:listing_images(image_url))
```

**Replace** with (in BOTH methods):
```
            *,
            buyer:user_profiles!buyer_id(*),
            seller:user_profiles!seller_id(*),
            listing:listings(id, title, rental_daily_price, rental_weekly_price, rental_monthly_price, deposit_amount, images:listing_images(image_url)),
            pickup_location:pickup_locations(*)
```

Note the comma after the listing join and the new pickup_location join.

## Step 4: Update createOrder in orders_provider.dart

In `lib/features/orders/providers/orders_provider.dart`, update the `createOrder`
method:

### 4a. Add parameter
After `String school = 'Smith College',` add:
```dart
    String? pickupLocationId,
```

### 4b. Add to draft
In the `Order(` constructor, after `depositAmount: depositAmount,`, add:
```dart
        pickupLocationId: pickupLocationId,
```

## Step 5: Pass pickup location ID when creating order

In `lib/features/listing/screens/listing_detail_screen.dart`, find the
`createOrder(` call (around line 409-417). Add `pickupLocationId` parameter.

Find:
```dart
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

**Replace** with:
```dart
                              // NOTE: Use buyer's selected pickup if they changed it,
                              // otherwise fall back to seller's default pickup location.
                              final effectivePickupId = _selectedPickupLocationId 
                                  ?? listing.pickupLocationId;
                              
                              await ref.read(orderActionsProvider.notifier).createOrder(
                                listingId: listing.id,
                                sellerId: listing.sellerId,
                                price: orderPrice,
                                orderType: isRental ? 'rental' : 'sale',
                                rentalStartDate: rentalStart,
                                rentalEndDate: rentalEnd,
                                depositAmount: listing.depositAmount,
                                pickupLocationId: effectivePickupId,
                              );
```

## Step 6: Run build_runner

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

## Step 7: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-005a.md`.
