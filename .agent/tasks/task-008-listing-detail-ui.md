# Task 008: Listing Detail Screen — UI Corrections

## Objective
Fix 4 visual issues on the listing detail page per requirements #2.

## STRICT SCOPE — Only modify:
- `lib/features/listing/screens/listing_detail_screen.dart`

**DO NOT** modify any other files.

---

## Change 1: Fixed floating back button (不随滚动消失)

The current layout is:
```dart
return Scaffold(
  body: ...
    data: (listing) {
      return SingleChildScrollView(
        child: Column(
          children: [
            ListingImageCarousel(...),
            Padding(...)
          ],
        ),
      );
    },
  ),
);
```

Wrap the `SingleChildScrollView` in a `Stack`, and add a positioned
back button that floats over the content:

```dart
return Scaffold(
  backgroundColor: AppColors.background,
  body: listingAsync.when(
    ...
    data: (listing) {
      // ... existing variable declarations ...
      
      return Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... existing children unchanged ...
              ],
            ),
          ),
          // Fixed floating back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      );
    },
  ),
);
```

## Change 2: Unify section header to "DESCRIPTION"

Find this code around line 178:
```dart
Text(
  isSale ? 'DESCRIPTION' : 'ABOUT THIS ITEM',
```

Replace with:
```dart
Text(
  'DESCRIPTION',
```

## Change 3: Move DESCRIPTION above pickup location

Currently the order is:
1. Title + Price
2. (Rental: Smith College Campus text)
3. (Rental: RentalOptionsSection)
4. DESCRIPTION
5. Pickup Location
6. Seller Card
7. Stats / Action Button

Move the DESCRIPTION section to come right after Title + Price and 
before the rental options. The new order should be:

1. Title + Price
2. **DESCRIPTION** (moved up)
3. (Rental: RentalOptionsSection)
4. Pickup Location
5. Seller Card
6. Stats / Action Button

## Change 4: Remove "Smith College Campus" text for rental items

Delete the entire block from approximately line 155-169:
```dart
if (!isSale) ...[
  const SizedBox(height: AppSpacing.sm),
  Row(
    children: [
      const Icon(Icons.location_on, color: AppColors.priceTagPrimary, size: 16),
      const SizedBox(width: AppSpacing.xs),
      Text(
        'Smith College Campus', // Default fallback
        ...
      ),
    ],
  ),
```

Keep the `RentalOptionsSection` — only remove the "Smith College Campus" Row.

## Step 5: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-008.md`.
