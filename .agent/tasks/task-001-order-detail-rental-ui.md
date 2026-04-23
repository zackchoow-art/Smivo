# Task 001: Order Detail — Rental Rate Buttons + Deposit Display

## Objective
Fix the order detail screen to:
1. Show rental rate buttons (Day/Week/Month) only when the listing has that rate > 0
2. Display the real `depositAmount` from the order

## STRICT SCOPE — Only modify these files:
1. `lib/data/models/order_listing_preview.dart` — **CREATE NEW**
2. `lib/data/models/order.dart` — change listing type
3. `lib/data/repositories/order_repository.dart` — expand select query
4. `lib/features/orders/screens/order_detail_screen.dart` — UI changes
5. Run `build_runner` at the end

**DO NOT** modify any other files. **DO NOT** touch ChatListingPreview, Listing model, home screen, or listing detail screen.

---

## Step 1: Create `lib/data/models/order_listing_preview.dart`

Create this file with EXACT content:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_listing_preview.freezed.dart';
part 'order_listing_preview.g.dart';

/// Listing data embedded in Order for order detail display.
///
/// Includes rental pricing fields so the order detail screen
/// can show which rental rate options are available.
@freezed
abstract class OrderListingPreview with _$OrderListingPreview {
  const factory OrderListingPreview({
    required String id,
    required String title,
    @Default([]) List<OrderListingImage> images,
    @JsonKey(name: 'rental_daily_price') double? rentalDailyPrice,
    @JsonKey(name: 'rental_weekly_price') double? rentalWeeklyPrice,
    @JsonKey(name: 'rental_monthly_price') double? rentalMonthlyPrice,
    @JsonKey(name: 'deposit_amount') @Default(0.0) double depositAmount,
  }) = _OrderListingPreview;

  factory OrderListingPreview.fromJson(Map<String, dynamic> json) =>
      _$OrderListingPreviewFromJson(json);
}

@freezed
abstract class OrderListingImage with _$OrderListingImage {
  const factory OrderListingImage({
    @JsonKey(name: 'image_url') required String imageUrl,
  }) = _OrderListingImage;

  factory OrderListingImage.fromJson(Map<String, dynamic> json) =>
      _$OrderListingImageFromJson(json);
}
```

## Step 2: Modify `lib/data/models/order.dart`

Change the import and the `listing` field type:

**Replace** this import:
```dart
import 'package:smivo/data/models/chat_listing_preview.dart';
```
**With:**
```dart
import 'package:smivo/data/models/order_listing_preview.dart';
```

**Replace** this line (around line 41):
```dart
    ChatListingPreview? listing,
```
**With:**
```dart
    OrderListingPreview? listing,
```

## Step 3: Modify `lib/data/repositories/order_repository.dart`

In the `fetchOrder` method (single order), **replace** the select string:
```dart
            *,
            buyer:user_profiles!buyer_id(*),
            seller:user_profiles!seller_id(*),
            listing:listings(id, title, images:listing_images(image_url))
```
**With:**
```dart
            *,
            buyer:user_profiles!buyer_id(*),
            seller:user_profiles!seller_id(*),
            listing:listings(id, title, rental_daily_price, rental_weekly_price, rental_monthly_price, deposit_amount, images:listing_images(image_url))
```

Also update `fetchOrders` (list query) with the SAME expanded select string, so order list cards can also access this data if needed later.

## Step 4: Modify `lib/features/orders/screens/order_detail_screen.dart`

### 4a. Add import at top (if not already present — it should auto-resolve, but just in case):
No new imports needed; we access rental data through `order.listing`.

### 4b. Add deposit display in `_buildInfoSection`

After the existing `_infoRow('Counterparty', ...)` line, add:

```dart
        // NOTE: Show deposit only for rental orders with non-zero deposit
        if (order.orderType == 'rental' && order.depositAmount > 0)
          _infoRow('Deposit', '\$${order.depositAmount.toStringAsFixed(2)}'),
```

### 4c. Add rental rate section for rental orders

In `_buildBody`, after the `_buildInfoSection` block and its SizedBox, add a new section for rental rates. Add this BEFORE the rental period section (the `if (order.orderType == 'rental' && order.rentalStartDate != null)` block):

```dart
          // Rental rate options (rental only, show available rates)
          if (order.orderType == 'rental' && order.listing != null)
            _buildRentalRates(order),
          if (order.orderType == 'rental' && order.listing != null)
            const SizedBox(height: AppSpacing.lg),
```

### 4d. Add the `_buildRentalRates` method

Add this new method to the class (e.g. after `_buildRentalSection`):

```dart
  Widget _buildRentalRates(Order order) {
    final listing = order.listing!;
    final hasDaily = (listing.rentalDailyPrice ?? 0) > 0;
    final hasWeekly = (listing.rentalWeeklyPrice ?? 0) > 0;
    final hasMonthly = (listing.rentalMonthlyPrice ?? 0) > 0;

    // NOTE: If no rates are available at all, don't show this section
    if (!hasDaily && !hasWeekly && !hasMonthly) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rental Rates', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            if (hasDaily)
              _rateChip(
                'Day',
                '\$${listing.rentalDailyPrice!.toStringAsFixed(2)}',
              ),
            if (hasDaily && (hasWeekly || hasMonthly))
              const SizedBox(width: AppSpacing.sm),
            if (hasWeekly)
              _rateChip(
                'Week',
                '\$${listing.rentalWeeklyPrice!.toStringAsFixed(2)}',
              ),
            if (hasWeekly && hasMonthly)
              const SizedBox(width: AppSpacing.sm),
            if (hasMonthly)
              _rateChip(
                'Month',
                '\$${listing.rentalMonthlyPrice!.toStringAsFixed(2)}',
              ),
          ],
        ),
      ],
    );
  }

  Widget _rateChip(String label, String price) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.outlineVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              price,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
```

## Step 5: Run build_runner

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

## Step 6: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors (not warnings or info). Write your report to `.agent/reports/report-001.md` with:
- List of files modified/created
- build_runner output (success or errors)
- flutter analyze errors (if any)
- Any issues encountered
