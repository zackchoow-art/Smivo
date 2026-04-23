# Report 005A: Order Pickup Location — Data Layer

## Files Created/Modified
1. `supabase/migrations/00018_order_pickup_location.sql` — **Created**
2. `lib/data/models/order.dart` — **Modified**
3. `lib/data/repositories/order_repository.dart` — **Modified**
4. `lib/features/orders/providers/orders_provider.dart` — **Modified**
5. `lib/features/listing/screens/listing_detail_screen.dart` — **Modified**

## Changes Implemented
- **Database Schema**: Created a migration file to add `pickup_location_id` to the `orders` table.
- **Order Model**: 
    - Added `pickupLocationId` field for persistence.
    - Added nested `pickupLocation` object for joined data retrieval.
    - Regenerated code using `build_runner`.
- **Order Repository**:
    - Updated `fetchOrders` and `fetchOrder` select queries to join with the `pickup_locations` table.
    - Modified `createOrder` to strip the `pickup_location` join field before insertion to avoid database errors.
- **Orders Provider**:
    - Updated `createOrder` action to accept `pickupLocationId` as an optional parameter.
    - Ensured the ID is passed into the `Order` draft object.
- **UI Integration**:
    - Updated `ListingDetailScreen` to calculate an `effectivePickupId` (buyer's selection OR seller's default).
    - Passed this ID when calling the order creation action.

## Issues Encountered
- None.

## Verification Results
- `build_runner`: **Success**
- `flutter analyze`: **0 Errors** (81 info/warnings related to existing deprecated members and unused imports).
