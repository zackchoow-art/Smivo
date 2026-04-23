# Report 005B: Order Pickup Location — UI Display

## Files Modified
1. `lib/features/orders/widgets/order_card.dart`
2. `lib/features/orders/screens/order_detail_screen.dart`

## Changes Implemented
- **Order Card**:
    - Updated the pickup information row to display the actual `pickupLocation.name`.
    - Added a fallback to `order.school` if the specific pickup location is unavailable.
- **Order Detail Screen**:
    - Added a new "Pickup" row to the "Order Info" section.
    - The row dynamically displays the name of the designated pickup location for the order.

## Issues Encountered
- None.

## Verification Results
- `flutter analyze`: **0 Errors** (81 info/warnings related to existing deprecated members and unused imports).
